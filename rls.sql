-- ============================================================
-- ERP 系統 — Row Level Security (RLS) 政策
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

-- ========== 2. 針對各表啟用 RLS 與套用政策 ==========

-- 主檔與基本資料
ALTER TABLE imaa_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY imaa_policy ON imaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR imaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR imaaent = get_auth_user_ent());

ALTER TABLE cusa_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY cusa_policy ON cusa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR cusaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR cusaent = get_auth_user_ent());

ALTER TABLE vnda_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY vnda_policy ON vnda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR vndaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR vndaent = get_auth_user_ent());

ALTER TABLE inaa_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY inaa_policy ON inaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inaaent = get_auth_user_ent());

ALTER TABLE ooag_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY ooag_policy ON ooag_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR ooagent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR ooagent = get_auth_user_ent());

ALTER TABLE rola_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY rola_policy ON rola_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR rolaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR rolaent = get_auth_user_ent());

ALTER TABLE rolb_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY rolb_policy ON rolb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR rolbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR rolbent = get_auth_user_ent());

-- 銷貨模組
ALTER TABLE xmda_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xmda_policy ON xmda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdaent = get_auth_user_ent());

ALTER TABLE xmdc_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xmdc_policy ON xmdc_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdcent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdcent = get_auth_user_ent());

ALTER TABLE xmdk_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xmdk_policy ON xmdk_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdkent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdkent = get_auth_user_ent());

ALTER TABLE xmdl_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xmdl_policy ON xmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdlent = get_auth_user_ent());

ALTER TABLE xrca_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xrca_policy ON xrca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcaent = get_auth_user_ent());

ALTER TABLE xrcb_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY xrcb_policy ON xrcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcbent = get_auth_user_ent());

-- 採購模組
ALTER TABLE pmdl_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY pmdl_policy ON pmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdlent = get_auth_user_ent());

ALTER TABLE pmdn_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY pmdn_policy ON pmdn_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdnent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdnent = get_auth_user_ent());

ALTER TABLE pmds_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY pmds_policy ON pmds_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdsent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdsent = get_auth_user_ent());

ALTER TABLE pmdt_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY pmdt_policy ON pmdt_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdtent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdtent = get_auth_user_ent());

ALTER TABLE apca_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY apca_policy ON apca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcaent = get_auth_user_ent());

ALTER TABLE apcb_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY apcb_policy ON apcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcbent = get_auth_user_ent());

-- 庫存與核銷
ALTER TABLE inag_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY inag_policy ON inag_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inagent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inagent = get_auth_user_ent());

ALTER TABLE inaj_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY inaj_policy ON inaj_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inajent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inajent = get_auth_user_ent());

ALTER TABLE reca_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY reca_policy ON reca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR recaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR recaent = get_auth_user_ent());

-- 單號序號表 (沒有企業欄位，允許所有登入用戶讀取與修改)
ALTER TABLE doc_seq_t ENABLE ROW LEVEL SECURITY;
CREATE POLICY doc_seq_policy ON doc_seq_t FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
