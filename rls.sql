-- ============================================================
-- ERP 系統 — Row Level Security (RLS) 政策 (修正版)
-- ============================================================

-- ========== 1. RLS Helper 函數 ==========

-- 取得當前登入使用者的企業代碼 (ooagent)
CREATE OR REPLACE FUNCTION get_auth_user_ent()
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT ooagent FROM ooag_t 
  WHERE ooagcode = auth.uid()::text 
  LIMIT 1;
$$;

-- 檢查當前登入使用者是否為系統管理員 (rola002 = '1')
CREATE OR REPLACE FUNCTION is_auth_user_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT COALESCE(r.rola002 = '1', false)
  FROM ooag_t o
  JOIN rola_t r ON r.rolaent = o.ooagent AND r.rolacode = o.ooag003
  WHERE o.ooagcode = auth.uid()::text
  LIMIT 1;
$$;


-- ========== 2. 成員基本資料與權限表 (啟用 RLS) ==========

-- [ooag_t] 使用者檔案表
ALTER TABLE ooag_t ENABLE ROW LEVEL SECURITY;

-- 允許 authenticated 使用者新增自己的檔案，限制 ooagcode 必須等於 auth.uid()
DROP POLICY IF EXISTS ooag_insert_policy ON ooag_t;
CREATE POLICY ooag_insert_policy ON ooag_t FOR INSERT TO authenticated
  WITH CHECK (ooagcode = auth.uid()::text);

-- 允許 authenticated 使用者查詢自己的檔案
DROP POLICY IF EXISTS ooag_select_policy ON ooag_t;
CREATE POLICY ooag_select_policy ON ooag_t FOR SELECT TO authenticated
  USING (ooagcode = auth.uid()::text);

-- 允許 authenticated 使用者更新自己的檔案 (例如介面主題)
DROP POLICY IF EXISTS ooag_update_policy ON ooag_t;
CREATE POLICY ooag_update_policy ON ooag_t FOR UPDATE TO authenticated
  USING (ooagcode = auth.uid()::text)
  WITH CHECK (ooagcode = auth.uid()::text);


-- [rola_t] 角色表 (只允許讀取，不允許寫入)
ALTER TABLE rola_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rola_select_policy ON rola_t;
CREATE POLICY rola_select_policy ON rola_t FOR SELECT TO authenticated
  USING (true);


-- [rolb_t] 角色模組權限明細表 (只允許讀取，不允許寫入)
ALTER TABLE rolb_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rolb_select_policy ON rolb_t;
CREATE POLICY rolb_select_policy ON rolb_t FOR SELECT TO authenticated
  USING (true);


-- [doc_seq_t] 單號序號表 (允許讀取與更新以讓 fn_next_docno 運作)
ALTER TABLE doc_seq_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS doc_seq_policy ON doc_seq_t;
CREATE POLICY doc_seq_policy ON doc_seq_t FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- ========== 3. 其他業務表 (暫時停用 RLS，待確認方案後套用) ==========

ALTER TABLE imaa_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE cusa_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE vnda_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE inaa_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xmda_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xmdc_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xmdk_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xmdl_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xrca_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE xrcb_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE pmdl_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE pmdn_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE pmds_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE pmdt_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE apca_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE apcb_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE inag_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE inaj_t DISABLE ROW LEVEL SECURITY;
ALTER TABLE reca_t DISABLE ROW LEVEL SECURITY;
