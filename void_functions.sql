-- ============================================================
-- void_functions.sql — 取消確認/作廢功能
-- 部署順序：schema.sql -> functions.sql -> migration_void.sql -> void_functions.sql
--
-- 設計原則：
--   1. 不做實體刪除，一律用 status='9'(作廢) 標記，保留稽核軌跡
--   2. 兩階段檢查：先把整張單每一行都檢查過，全部通過才真正執行還原，
--      避免「扣一半才發現不能取消」
--   3. 判斷可否取消的條件是「現有庫存 ≥ 當初異動數量」，不特別區分
--      造成庫存變動的原因(出貨/調整/其他)，涵蓋範圍更完整也更不易有漏洞
--   4. 若對應的應收/應付帳款已有收付款紀錄，一律不允許取消，
--      需改走退貨/折讓等正式流程
-- ============================================================

-- ------------------------------------------------------------
-- 1. 取消確認收貨單（對應：採購 -> 收貨 -> 應付 這條線）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_goods_receipt(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header  pmds_t%ROWTYPE;
  v_line    pmdt_t%ROWTYPE;
  v_ap      apca_t%ROWTYPE;
  v_current numeric;
  v_reca    reca_t%ROWTYPE;
  v_voided_count integer := 0;
BEGIN
  SELECT * INTO v_header FROM pmds_t WHERE pmdsent = p_ent AND pmdsdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 收貨單不存在 %', p_docno;
  END IF;
  IF v_header.pmdsstatus <> '1' THEN
    RAISE EXCEPTION 'DOC_NOT_CONFIRMED: 只有已確認的收貨單才能取消(目前狀態=%)', v_header.pmdsstatus;
  END IF;

  -- 檢查對應應付帳款單是否已有付款
  SELECT * INTO v_ap FROM apca_t WHERE apcaent = p_ent AND apca002 = p_docno FOR UPDATE;
  IF FOUND AND v_ap.apca004 > 0.0001 THEN
    RAISE EXCEPTION 'AP_ALREADY_PAID: 對應應付帳款單(%)已有付款紀錄(已付 %)，無法取消收貨，請改用退貨流程', v_ap.apcadocno, v_ap.apca004;
  END IF;

  -- 第一輪：逐行檢查庫存是否足夠扣回(此批貨完全沒被動用過)
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    SELECT inaj003 INTO v_current FROM inaj_t
    WHERE inajent = p_ent AND inaj001 = v_line.pmdt001 AND inaj002 = v_header.pmds004
    FOR UPDATE;

    IF v_current IS NULL OR v_current < v_line.pmdt003 - 0.0001 THEN
      RAISE EXCEPTION 'STOCK_ALREADY_CONSUMED: 商品 % 目前庫存(%)不足以扣回當初收貨數量(%)，此批貨已被動用，無法直接取消，請改用退貨流程',
        v_line.pmdt001, coalesce(v_current, 0), v_line.pmdt003;
    END IF;
  END LOOP;

  -- 第二輪：全部通過檢查，才真正執行還原
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    -- 反向庫存異動(扣回)
    PERFORM fn_stock_out(p_ent, v_line.pmdt001, v_header.pmds004, v_line.pmdt003, 'GR_VOID', p_docno, v_line.pmdtseq);

    -- 找到對應核銷紀錄，標記作廢，並回沖採購單已入庫數量
    SELECT * INTO v_reca FROM reca_t
    WHERE recaent = p_ent AND reca004 = 'GR' AND reca005 = p_docno AND reca006 = v_line.pmdtseq;

    IF FOUND THEN
      UPDATE reca_t SET reca012 = '9' WHERE recaent = p_ent AND recadocno = v_reca.recadocno;
      UPDATE pmdn_t SET pmdn005 = pmdn005 - v_reca.reca008
      WHERE pmdnent = p_ent AND pmdndocno = v_reca.reca002 AND pmdnseq = v_reca.reca003;
      v_voided_count := v_voided_count + 1;
    END IF;
  END LOOP;

  -- 作廢收貨單
  UPDATE pmds_t SET pmdsstatus = '9', pmdsvoidid = p_user, pmdsvoiddt = now()
  WHERE pmdsent = p_ent AND pmdsdocno = p_docno;

  -- 一併作廢對應應付帳款單(前面已確認未付款，可安全作廢)
  IF v_ap.apcadocno IS NOT NULL THEN
    UPDATE apca_t SET apcastatus = '9' WHERE apcaent = p_ent AND apcadocno = v_ap.apcadocno;
  END IF;

  RETURN jsonb_build_object(
    'docno', p_docno, 'status', 'voided',
    'reconciliationVoided', v_voided_count,
    'payableVoided', v_ap.apcadocno
  );
END;
$$;

-- ------------------------------------------------------------
-- 2. 取消確認出貨單（對稱：銷貨 -> 出貨 -> 應收 這條線）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_shipment(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header  xmdk_t%ROWTYPE;
  v_line    xmdl_t%ROWTYPE;
  v_ar      xrca_t%ROWTYPE;
  v_reca    reca_t%ROWTYPE;
  v_voided_count integer := 0;
BEGIN
  SELECT * INTO v_header FROM xmdk_t WHERE xmdkent = p_ent AND xmdkdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 出貨單不存在 %', p_docno;
  END IF;
  IF v_header.xmdkstatus <> '1' THEN
    RAISE EXCEPTION 'DOC_NOT_CONFIRMED: 只有已確認的出貨單才能取消(目前狀態=%)', v_header.xmdkstatus;
  END IF;

  -- 出貨的還原是「加回庫存」，不需要檢查庫存是否足夠(這點跟收貨取消不同，
  -- 加庫存永遠可以執行)，但要檢查對應應收帳款是否已收款
  SELECT * INTO v_ar FROM xrca_t WHERE xrcaent = p_ent AND xrca002 = p_docno FOR UPDATE;
  IF FOUND AND v_ar.xrca004 > 0.0001 THEN
    RAISE EXCEPTION 'AR_ALREADY_PAID: 對應應收帳款單(%)已有收款紀錄(已收 %)，無法取消出貨，請改用退貨流程', v_ar.xrcadocno, v_ar.xrca004;
  END IF;

  FOR v_line IN SELECT * FROM xmdl_t WHERE xmdlent = p_ent AND xmdldocno = p_docno ORDER BY xmdlseq
  LOOP
    -- 反向庫存異動(加回)
    PERFORM fn_stock_in(p_ent, v_line.xmdl001, v_header.xmdk006, v_line.xmdl002, 'SH_VOID', p_docno, v_line.xmdlseq);

    -- 找到對應核銷紀錄，標記作廢，並回沖訂單已出貨數量
    SELECT * INTO v_reca FROM reca_t
    WHERE recaent = p_ent AND reca004 = 'SH' AND reca005 = p_docno AND reca006 = v_line.xmdlseq;

    IF FOUND THEN
      UPDATE reca_t SET reca012 = '9' WHERE recaent = p_ent AND recadocno = v_reca.recadocno;
      UPDATE xmdc_t SET xmdc005 = xmdc005 - v_reca.reca008
      WHERE xmdcent = p_ent AND xmdcdocno = v_reca.reca002 AND xmdcseq = v_reca.reca003;
      v_voided_count := v_voided_count + 1;
    END IF;
  END LOOP;

  UPDATE xmdk_t SET xmdkstatus = '9', xmdkvoidid = p_user, xmdkvoiddt = now()
  WHERE xmdkent = p_ent AND xmdkdocno = p_docno;

  IF v_ar.xrcadocno IS NOT NULL THEN
    UPDATE xrca_t SET xrcastatus = '9' WHERE xrcaent = p_ent AND xrcadocno = v_ar.xrcadocno;
  END IF;

  RETURN jsonb_build_object(
    'docno', p_docno, 'status', 'voided',
    'reconciliationVoided', v_voided_count,
    'receivableVoided', v_ar.xrcadocno
  );
END;
$$;

-- ------------------------------------------------------------
-- 3. 取消確認銷貨訂單
--    只檢查底下有沒有還在生效中(非作廢)的出貨單引用它，
--    不涉及庫存還原(訂單本身不影響庫存，出貨才影響)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_sales_order(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header xmda_t%ROWTYPE;
  v_active_count integer;
BEGIN
  SELECT * INTO v_header FROM xmda_t WHERE xmdaent = p_ent AND xmdadocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 訂單不存在 %', p_docno;
  END IF;
  IF v_header.xmdastatus = '9' THEN
    RAISE EXCEPTION 'ALREADY_VOIDED: 此訂單已經作廢過了';
  END IF;

  SELECT count(*) INTO v_active_count FROM xmdk_t
  WHERE xmdkent = p_ent AND xmdk005 = p_docno AND xmdkstatus <> '9';

  IF v_active_count > 0 THEN
    RAISE EXCEPTION 'HAS_ACTIVE_SHIPMENT: 此訂單底下還有 % 張生效中的出貨單，請先取消/作廢那些出貨單才能取消此訂單', v_active_count;
  END IF;

  UPDATE xmda_t SET xmdastatus = '9', xmdavoidid = p_user, xmdavoiddt = now()
  WHERE xmdaent = p_ent AND xmdadocno = p_docno;

  RETURN jsonb_build_object('docno', p_docno, 'status', 'voided');
END;
$$;

-- ------------------------------------------------------------
-- 4. 取消確認採購單(對稱)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_purchase_order(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header pmdl_t%ROWTYPE;
  v_active_count integer;
BEGIN
  SELECT * INTO v_header FROM pmdl_t WHERE pmdlent = p_ent AND pmdldocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 採購單不存在 %', p_docno;
  END IF;
  IF v_header.pmdlstatus = '9' THEN
    RAISE EXCEPTION 'ALREADY_VOIDED: 此採購單已經作廢過了';
  END IF;

  SELECT count(*) INTO v_active_count FROM pmds_t
  WHERE pmdsent = p_ent AND pmds002 = p_docno AND pmdsstatus <> '9';

  IF v_active_count > 0 THEN
    RAISE EXCEPTION 'HAS_ACTIVE_RECEIPT: 此採購單底下還有 % 張生效中的收貨單，請先取消/作廢那些收貨單才能取消此採購單', v_active_count;
  END IF;

  UPDATE pmdl_t SET pmdlstatus = '9', pmdlvoidid = p_user, pmdlvoiddt = now()
  WHERE pmdlent = p_ent AND pmdldocno = p_docno;

  RETURN jsonb_build_object('docno', p_docno, 'status', 'voided');
END;
$$;

-- ------------------------------------------------------------
-- 5. 給前端列表用的「排除作廢」View
--    Antigravity 開發列表畫面時建議查這些 View 而非原始表，
--    這樣作廢的單據就不會出現在畫面上，不用每個查詢都手動加 WHERE status<>'9'
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW xmda_active_v WITH (security_invoker = true) AS SELECT * FROM xmda_t WHERE xmdastatus <> '9';
CREATE OR REPLACE VIEW xmdk_active_v WITH (security_invoker = true) AS SELECT * FROM xmdk_t WHERE xmdkstatus <> '9';
CREATE OR REPLACE VIEW pmdl_active_v WITH (security_invoker = true) AS SELECT * FROM pmdl_t WHERE pmdlstatus <> '9';
CREATE OR REPLACE VIEW pmds_active_v WITH (security_invoker = true) AS SELECT * FROM pmds_t WHERE pmdsstatus <> '9';
