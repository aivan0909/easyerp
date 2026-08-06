-- ============================================================
-- ERP 系統 — 核心業務邏輯(PostgreSQL Functions)
-- 對應「ERP-API設計文件.md」第 8、9 節
-- 部署：Supabase SQL Editor 執行本檔案(需先執行 schema.sql)
-- 呼叫方式(前端 supabase-js)：
--   const { data, error } = await supabase.rpc('confirm_shipment', {
--     p_ent: 1, p_docno: 'SH-20260805-0001', p_user: userId
--   });
-- ============================================================

-- ------------------------------------------------------------
-- 1. 單號產生器：用資料庫序號表，取代 App 端記憶體計數器
--    多人同時呼叫也不會重複（用 UPDATE ... RETURNING 保證原子性）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_next_docno(p_prefix text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_key   text := p_prefix || '-' || to_char(current_date, 'YYYYMMDD');
  v_value integer;
BEGIN
  INSERT INTO doc_seq_t (seq_key, seq_value) VALUES (v_key, 1)
  ON CONFLICT (seq_key) DO UPDATE SET seq_value = doc_seq_t.seq_value + 1
  RETURNING seq_value INTO v_value;

  RETURN v_key || '-' || lpad(v_value::text, 4, '0');
END;
$$;

-- ------------------------------------------------------------
-- 2. 核銷服務：處理多型關聯(src_doc_type 可能是 SO 或 PO)
--    對應 Node.js PoC 的 reconciliationService.record()
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_record_reconciliation(
  p_ent integer,
  p_src_doc_type varchar,   -- 'SO' 或 'PO'
  p_src_doc_no   varchar,
  p_src_doc_seq  integer,
  p_dst_doc_type varchar,   -- 'SH' 或 'GR'
  p_dst_doc_no   varchar,
  p_dst_doc_seq  integer,
  p_item_code    varchar,
  p_qty          numeric,
  p_amount       numeric
) RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_qty     numeric;
  v_already_done  numeric;
  v_remaining     numeric;
  v_new_done      numeric;
  v_status        varchar;
  v_recadocno     varchar;
BEGIN
  -- 依來源單據類型動態查詢對應表，並加 FOR UPDATE 鎖定該行，
  -- 避免同商品同時被兩筆出貨單核銷時發生競爭條件(race condition)
  IF p_src_doc_type = 'SO' THEN
    SELECT xmdc002, xmdc005 INTO v_order_qty, v_already_done
    FROM xmdc_t WHERE xmdcent = p_ent AND xmdcdocno = p_src_doc_no AND xmdcseq = p_src_doc_seq
    FOR UPDATE;
  ELSIF p_src_doc_type = 'PO' THEN
    SELECT pmdn002, pmdn005 INTO v_order_qty, v_already_done
    FROM pmdn_t WHERE pmdnent = p_ent AND pmdndocno = p_src_doc_no AND pmdnseq = p_src_doc_seq
    FOR UPDATE;
  ELSE
    RAISE EXCEPTION 'UNSUPPORTED_SRC_TYPE: 不支援的來源單據類型 %', p_src_doc_type;
  END IF;

  IF v_order_qty IS NULL THEN
    RAISE EXCEPTION 'SRC_DOC_NOT_FOUND: 來源單身不存在 % % #%', p_src_doc_type, p_src_doc_no, p_src_doc_seq;
  END IF;

  v_remaining := v_order_qty - v_already_done;
  IF p_qty > v_remaining + 0.0001 THEN
    RAISE EXCEPTION 'QTY_EXCEED_SOURCE: 核銷數量(%)超過來源單剩餘可核銷量(%)', p_qty, v_remaining;
  END IF;

  v_new_done := v_already_done + p_qty;
  v_status := CASE WHEN v_new_done >= v_order_qty - 0.0001 THEN '2' ELSE '1' END;
  v_recadocno := fn_next_docno('REC');

  INSERT INTO reca_t (recaent, recadocno, reca001, reca002, reca003, reca004, reca005, reca006,
                       reca007, reca008, reca009, reca012, reca013)
  VALUES (p_ent, v_recadocno, p_src_doc_type, p_src_doc_no, p_src_doc_seq,
          p_dst_doc_type, p_dst_doc_no, p_dst_doc_seq, p_item_code, p_qty, p_amount, v_status, current_date);

  IF p_src_doc_type = 'SO' THEN
    UPDATE xmdc_t SET xmdc005 = v_new_done
    WHERE xmdcent = p_ent AND xmdcdocno = p_src_doc_no AND xmdcseq = p_src_doc_seq;
  ELSIF p_src_doc_type = 'PO' THEN
    UPDATE pmdn_t SET pmdn005 = v_new_done
    WHERE pmdnent = p_ent AND pmdndocno = p_src_doc_no AND pmdnseq = p_src_doc_seq;
  END IF;

  RETURN v_recadocno;
END;
$$;

-- ------------------------------------------------------------
-- 3. 庫存出庫：檢查現有量足夠 -> 寫 inag_t -> 更新 inaj_t
--    FOR UPDATE 鎖定庫存彙總行，避免手機多人同時出貨造成超賣
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stock_out(
  p_ent integer, p_item_code varchar, p_wh_code varchar, p_qty numeric,
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_current numeric;
  v_new_balance numeric;
  v_inagdocno varchar;
BEGIN
  -- 若彙總列不存在先建立一列，再鎖定
  INSERT INTO inaj_t (inajent, inaj001, inaj002, inaj003, inaj004, inaj005)
  VALUES (p_ent, p_item_code, p_wh_code, 0, 0, 0)
  ON CONFLICT (inajent, inaj001, inaj002) DO NOTHING;

  SELECT inaj003 INTO v_current FROM inaj_t
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code
  FOR UPDATE;

  IF v_current < p_qty - 0.0001 THEN
    RAISE EXCEPTION 'STOCK_INSUFFICIENT: 商品 % 庫存不足(現有 %，需要 %)', p_item_code, v_current, p_qty;
  END IF;

  v_new_balance := v_current - p_qty;
  v_inagdocno := fn_next_docno('INAG');

  INSERT INTO inag_t (inagent, inagdocno, inag001, inag002, inag003, inag004, inag005, inag006, inag007, inag008, inag009)
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, '銷貨出貨', p_src_doc_type, p_src_doc_no, p_src_doc_seq, '-', p_qty, v_new_balance);

  UPDATE inaj_t SET inaj003 = v_new_balance
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code;
END;
$$;

-- ------------------------------------------------------------
-- 4. 核心動作：確認出貨
--    整個函式本身就是一個資料庫交易，任何一步 RAISE EXCEPTION
--    都會讓前面已執行的 INSERT/UPDATE 自動全部回滾（Postgres 原生特性）
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
BEGIN
  SELECT * INTO v_header FROM xmdk_t WHERE xmdkent = p_ent AND xmdkdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 出貨單不存在 %', p_docno;
  END IF;
  IF v_header.xmdkstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: 此出貨單已確認 %', p_docno;
  END IF;

  v_ar_docno := fn_next_docno('AR');

  -- 逐行：扣庫存 -> 核銷回訂單 -> 累計應收金額
  FOR v_line IN SELECT * FROM xmdl_t WHERE xmdlent = p_ent AND xmdldocno = p_docno ORDER BY xmdlseq
  LOOP
    PERFORM fn_stock_out(p_ent, v_line.xmdl001, v_header.xmdk006, v_line.xmdl002, 'SH', p_docno, v_line.xmdlseq);

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
-- 5. 庫存入庫：與 fn_stock_out 對稱，方向相反，不用檢查是否足夠
--    同樣用 FOR UPDATE 鎖定庫存彙總行，避免多人同時收貨造成加總錯誤
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stock_in(
  p_ent integer, p_item_code varchar, p_wh_code varchar, p_qty numeric,
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_current numeric;
  v_new_balance numeric;
  v_inagdocno varchar;
BEGIN
  INSERT INTO inaj_t (inajent, inaj001, inaj002, inaj003, inaj004, inaj005)
  VALUES (p_ent, p_item_code, p_wh_code, 0, 0, 0)
  ON CONFLICT (inajent, inaj001, inaj002) DO NOTHING;

  SELECT inaj003 INTO v_current FROM inaj_t
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code
  FOR UPDATE;

  v_new_balance := v_current + p_qty;
  v_inagdocno := fn_next_docno('INAG');

  INSERT INTO inag_t (inagent, inagdocno, inag001, inag002, inag003, inag004, inag005, inag006, inag007, inag008, inag009)
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, '採購入庫', p_src_doc_type, p_src_doc_no, p_src_doc_seq, '+', p_qty, v_new_balance);

  UPDATE inaj_t SET inaj003 = v_new_balance
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code;
END;
$$;

-- ------------------------------------------------------------
-- 6. 核心動作：確認收貨(對稱於 confirm_shipment)
--    採購單(PO) -> 收貨入庫單(GR) -> 應付帳款單(AP)
--    差異：fn_record_reconciliation 的 p_src_doc_type 改傳 'PO'，
--          fn_stock_out 換成 fn_stock_in，xrca/xrcb 換成 apca/apcb
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
BEGIN
  SELECT * INTO v_header FROM pmds_t WHERE pmdsent = p_ent AND pmdsdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: 收貨單不存在 %', p_docno;
  END IF;
  IF v_header.pmdsstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: 此收貨單已確認 %', p_docno;
  END IF;

  v_ap_docno := fn_next_docno('AP');

  -- 逐行：加庫存(用驗收合格數量 pmdt003,而非收貨數量 pmdt002) -> 核銷回採購單 -> 累計應付金額
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    PERFORM fn_stock_in(p_ent, v_line.pmdt001, v_header.pmds004, v_line.pmdt003, 'GR', p_docno, v_line.pmdtseq);

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
