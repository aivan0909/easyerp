-- ============================================================
-- migration_cost.sql — 落地成本 + 移動加權平均成本 所需欄位
-- 部署順序：... -> void_functions.sql -> migration_cost.sql -> cost_functions.sql
-- ============================================================

-- 收貨單頭：補「額外費用總額」(運費/關稅等,一次性費用,依金額比例分攤到各行)
ALTER TABLE pmds_t ADD COLUMN IF NOT EXISTS pmds006 numeric(15,2) DEFAULT 0;

-- 庫存彙總表：補「移動加權平均成本」，每次收貨後重新計算
ALTER TABLE inaj_t ADD COLUMN IF NOT EXISTS inaj006 numeric(15,4) DEFAULT 0;

-- 出貨單表身：補「本次出貨成本金額」(COGS)，出貨確認當下依平均成本計算並寫入，
-- 之後毛利報表直接讀這個欄位，不用重算
ALTER TABLE xmdl_t ADD COLUMN IF NOT EXISTS xmdl006 numeric(15,2);

-- 收貨單表身：補「本行分攤到的落地成本」與「本行落地單位成本」，方便日後追溯/稽核
ALTER TABLE pmdt_t ADD COLUMN IF NOT EXISTS pmdt007 numeric(15,2) DEFAULT 0; -- 分攤到的額外費用
ALTER TABLE pmdt_t ADD COLUMN IF NOT EXISTS pmdt008 numeric(15,4);          -- 落地單位成本(本行商品金額+分攤費用)/驗收數量
