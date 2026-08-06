-- ============================================================
-- cost_functions.sql — 落地成本分攤 + 移動加權平均成本 + 毛利報表
-- 部署順序：... -> void_functions.sql -> migration_cost.sql -> cost_functions.sql
--
-- 設計原則：
--   1. 落地成本(運費/關稅等)依「金額比例」分攤到收貨單各行(未記錄重量/體積,
--      故先用金額比例;若日後要改重量/體積分攤,只需替換分攤公式)
--   2. 移動加權平均成本：每次收貨後，用「這批的落地成本」重新計算商品的
--      平均成本，存在 inaj_t.inaj006
--   3. 出貨當下讀取「目前平均成本」計算這筆銷售的成本(COGS)，寫入
--      xmdl_t.xmdl006，之後毛利報表直接讀這個欄位，不用重算
--   4. 已知限制：取消收貨/取消出貨(void_*)目前只還原「數量」，不會逆算
--      平均成本回到取消前的狀態(平均成本本質上是滾動計算，精確逆算意義不大，
--      此版本先不處理，日後有需要再補)
-- ============================================================

-- ------------------------------------------------------------
-- 覆寫：確認收貨（加入落地成本分攤 + 移動加權平均成本）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_goods_receipt(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header    pmds_t%ROWTYPE;
  v_line      pmdt_t%ROWTYPE;
  v_ap_docno  varchar;
  v_ap_total  numeric := 0;
  v_ap_seq    integer := 0;
  v_line_total_amt numeric := 0;   -- 這批收貨的商品總金額(分攤基礎)
  v_allocated numeric;             -- 本行分攤到的額外費用
  v_landed_unit_cost numeric;      -- 本行落地單位成本
  v_old_qty   numeric;
  v_old_avg   numeric;
  v_new_avg   numeric;
BEGIN
  SELECT * INTO v_header FROM pmds_t WHERE pmdsent = p_ent AND pmdsdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 收貨單不存在 %', p_docno;
  END IF;
  IF v_header.pmdsstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: 此收貨單已確認 %', p_docno;
  END IF;

  v_ap_docno := fn_next_docno('AP');

  -- 這批收貨的商品總金額，作為分攤額外費用(運費/關稅)的比例基礎
  SELECT COALESCE(SUM(pmdt005), 0) INTO v_line_total_amt
  FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno;

  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    -- 1) 依金額比例分攤額外費用，算出本行落地單位成本
    IF v_line_total_amt > 0 THEN
      v_allocated := v_header.pmds006 * (v_line.pmdt005 / v_line_total_amt);
    ELSE
      v_allocated := 0;
    END IF;
    v_landed_unit_cost := CASE WHEN v_line.pmdt003 > 0 THEN (v_line.pmdt005 + v_allocated) / v_line.pmdt003 ELSE 0 END;

    UPDATE pmdt_t SET pmdt007 = v_allocated, pmdt008 = v_landed_unit_cost
    WHERE pmdtent = p_ent AND pmdtdocno = p_docno AND pmdtseq = v_line.pmdtseq;

    -- 2) 加庫存(既有邏輯)
    PERFORM fn_stock_in(p_ent, v_line.pmdt001, v_header.pmds004, v_line.pmdt003, 'GR', p_docno, v_line.pmdtseq);

    -- 3) 重新計算移動加權平均成本
    --    fn_stock_in 已經把數量加進 inaj003，所以「加之前的庫存量」= 目前值 - 本次收貨量
    SELECT inaj003 - v_line.pmdt003, inaj006 INTO v_old_qty, v_old_avg
    FROM inaj_t WHERE inajent = p_ent AND inaj001 = v_line.pmdt001 AND inaj002 = v_header.pmds004;

    IF (v_old_qty + v_line.pmdt003) > 0 THEN
      v_new_avg := (v_old_qty * COALESCE(v_old_avg, 0) + v_line.pmdt003 * v_landed_unit_cost) / (v_old_qty + v_line.pmdt003);
    ELSE
      v_new_avg := v_landed_unit_cost;
    END IF;

    UPDATE inaj_t SET inaj006 = v_new_avg
    WHERE inajent = p_ent AND inaj001 = v_line.pmdt001 AND inaj002 = v_header.pmds004;

    -- 4) 核銷回採購單(既有邏輯)
    PERFORM fn_record_reconciliation(
      p_ent, 'PO', v_header.pmds002, v_line.pmdt006,
      'GR', p_docno, v_line.pmdtseq,
      v_line.pmdt001, v_line.pmdt003, v_line.pmdt005
    );

    v_ap_seq := v_ap_seq + 1;
    v_ap_total := v_ap_total + v_line.pmdt005;

    INSERT INTO apcb_t (apcbent, apcbdocno, apcbseq, apcb001, apcb002, apcb003, apcb004, apcb005)
    VALUES (p_ent, v_ap_docno, v_ap_seq, v_line.pmdt001, v_line.pmdt003, v_line.pmdt004, v_line.pmdt005, v_line.pmdtseq);
  END LOOP;

  INSERT INTO apca_t (apcaent, apcadocno, apca001, apca002, apca003, apca004)
  VALUES (p_ent, v_ap_docno, v_header.pmds003, p_docno, v_ap_total, 0);

  UPDATE pmds_t SET pmdsstatus = '1', pmdscnfid = p_user, pmdscnfdt = now()
  WHERE pmdsent = p_ent AND pmdsdocno = p_docno;

  RETURN jsonb_build_object(
    'docno', p_docno,
    'payableDocNo', v_ap_docno,
    'payableAmount', v_ap_total
  );
END;
$$;

-- ------------------------------------------------------------
-- 覆寫：確認出貨（加入出貨當下的成本計算,COGS)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_shipment(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header    xmdk_t%ROWTYPE;
  v_line      xmdl_t%ROWTYPE;
  v_ar_docno  varchar;
  v_ar_total  numeric := 0;
  v_ar_seq    integer := 0;
  v_avg_cost  numeric;
  v_cogs      numeric;
BEGIN
  SELECT * INTO v_header FROM xmdk_t WHERE xmdkent = p_ent AND xmdkdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 出貨單不存在 %', p_docno;
  END IF;
  IF v_header.xmdkstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: 此出貨單已確認 %', p_docno;
  END IF;

  v_ar_docno := fn_next_docno('AR');

  FOR v_line IN SELECT * FROM xmdl_t WHERE xmdlent = p_ent AND xmdldocno = p_docno ORDER BY xmdlseq
  LOOP
    -- 1) 出貨前先讀取「目前的移動加權平均成本」，算出這筆銷售的成本(COGS)
    SELECT inaj006 INTO v_avg_cost FROM inaj_t
    WHERE inajent = p_ent AND inaj001 = v_line.xmdl001 AND inaj002 = v_header.xmdk006;
    v_cogs := COALESCE(v_avg_cost, 0) * v_line.xmdl002;

    UPDATE xmdl_t SET xmdl006 = v_cogs
    WHERE xmdlent = p_ent AND xmdldocno = p_docno AND xmdlseq = v_line.xmdlseq;

    -- 2) 扣庫存(既有邏輯)
    PERFORM fn_stock_out(p_ent, v_line.xmdl001, v_header.xmdk006, v_line.xmdl002, 'SH', p_docno, v_line.xmdlseq);

    -- 3) 核銷回訂單(既有邏輯)
    PERFORM fn_record_reconciliation(
      p_ent, 'SO', v_header.xmdk005, v_line.xmdl005,
      'SH', p_docno, v_line.xmdlseq,
      v_line.xmdl001, v_line.xmdl002, v_line.xmdl004
    );

    v_ar_seq := v_ar_seq + 1;
    v_ar_total := v_ar_total + v_line.xmdl004;

    INSERT INTO xrcb_t (xrcbent, xrcbdocno, xrcbseq, xrcb001, xrcb002, xrcb003, xrcb004, xrcb005)
    VALUES (p_ent, v_ar_docno, v_ar_seq, v_line.xmdl001, v_line.xmdl002, v_line.xmdl003, v_line.xmdl004, v_line.xmdlseq);
  END LOOP;

  INSERT INTO xrca_t (xrcaent, xrcadocno, xrca001, xrca002, xrca003, xrca004)
  VALUES (p_ent, v_ar_docno, v_header.xmdk004, p_docno, v_ar_total, 0);

  UPDATE xmdk_t SET xmdkstatus = '1', xmdkcnfid = p_user, xmdkcnfdt = now()
  WHERE xmdkent = p_ent AND xmdkdocno = p_docno;

  RETURN jsonb_build_object(
    'docno', p_docno,
    'receivableDocNo', v_ar_docno,
    'receivableAmount', v_ar_total
  );
END;
$$;

-- ------------------------------------------------------------
-- 毛利報表 View：逐筆出貨明細的營收/成本/毛利/毛利率
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW profit_report_v WITH (security_invoker = true) AS
SELECT
  k.xmdkent        AS ent,
  k.xmdkdocno      AS shipment_no,
  k.xmdkdocdt      AS ship_date,
  k.xmdk004        AS customer_code,
  l.xmdlseq        AS line_seq,
  l.xmdl001        AS item_code,
  l.xmdl002        AS qty,
  l.xmdl003        AS unit_price,
  l.xmdl004         AS revenue,
  COALESCE(l.xmdl006, 0) AS cogs,
  (l.xmdl004 - COALESCE(l.xmdl006, 0)) AS gross_profit,
  CASE WHEN l.xmdl004 > 0
    THEN round((l.xmdl004 - COALESCE(l.xmdl006, 0)) / l.xmdl004 * 100, 1)
    ELSE NULL
  END AS margin_pct
FROM xmdl_t l
JOIN xmdk_t k ON k.xmdkent = l.xmdlent AND k.xmdkdocno = l.xmdldocno
WHERE k.xmdkstatus = '1';
