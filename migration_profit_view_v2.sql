-- ============================================================
-- migration_profit_view_v2.sql — 毛利報表補上商品名稱/規格
-- 部署順序：... -> migration_rls_helpers.sql -> migration_profit_view_v2.sql
--
-- 原因：profit_report_v 原本只帶 xmdl001(商品編號)，前端「銷售毛利明細清單」
-- 的品名規格欄位需要顯示 imaa_t.imaa001(商品名稱)，故補上 JOIN。
-- ============================================================

DROP VIEW IF EXISTS profit_report_v;

CREATE VIEW profit_report_v WITH (security_invoker = true) AS
SELECT
  k.xmdkent        AS ent,
  k.xmdkdocno      AS shipment_no,
  k.xmdkdocdt      AS ship_date,
  k.xmdk004        AS customer_code,
  l.xmdlseq        AS line_seq,
  l.xmdl001        AS item_code,
  i.imaa001        AS item_name,   -- 商品名稱(對應您要的「品名規格」)
  i.imaa002        AS item_spec,   -- 規格
  l.xmdl002        AS qty,
  l.xmdl003        AS unit_price,
  l.xmdl004        AS revenue,
  COALESCE(l.xmdl006, 0) AS cogs,
  (l.xmdl004 - COALESCE(l.xmdl006, 0)) AS gross_profit,
  CASE WHEN l.xmdl004 > 0
    THEN round((l.xmdl004 - COALESCE(l.xmdl006, 0)) / l.xmdl004 * 100, 1)
    ELSE NULL
  END AS margin_pct
FROM xmdl_t l
JOIN xmdk_t k ON k.xmdkent = l.xmdlent AND k.xmdkdocno = l.xmdldocno
LEFT JOIN imaa_t i ON i.imaaent = l.xmdlent AND i.imaacode = l.xmdl001
WHERE k.xmdkstatus = '1';
