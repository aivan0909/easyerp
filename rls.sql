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


-- ========== 2. 成員基本資料與權限表 RLS ==========

-- [ooag_t] 使用者檔案表
ALTER TABLE ooag_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ooag_insert_policy ON ooag_t;
CREATE POLICY ooag_insert_policy ON ooag_t FOR INSERT TO authenticated
  WITH CHECK (ooagcode = auth.uid()::text);

DROP POLICY IF EXISTS ooag_select_policy ON ooag_t;
CREATE POLICY ooag_select_policy ON ooag_t FOR SELECT TO authenticated
  USING (ooagcode = auth.uid()::text);

DROP POLICY IF EXISTS ooag_update_policy ON ooag_t;
CREATE POLICY ooag_update_policy ON ooag_t FOR UPDATE TO authenticated
  USING (ooagcode = auth.uid()::text)
  WITH CHECK (ooagcode = auth.uid()::text);


-- [rola_t] 角色表 (唯讀)
ALTER TABLE rola_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rola_select_policy ON rola_t;
CREATE POLICY rola_select_policy ON rola_t FOR SELECT TO authenticated
  USING (true);


-- [rolb_t] 角色模組權限明細表 (唯讀)
ALTER TABLE rolb_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rolb_select_policy ON rolb_t;
CREATE POLICY rolb_select_policy ON rolb_t FOR SELECT TO authenticated
  USING (true);


-- [doc_seq_t] 單號序號表 (允許 authenticated 使用者新增與更新以讓 fn_next_docno 運作)
ALTER TABLE doc_seq_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS doc_seq_policy ON doc_seq_t;
CREATE POLICY doc_seq_policy ON doc_seq_t FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- ========== 3. 其他業務表 RLS 政策 (管理員可見全部，一般人僅限自己企業) ==========

-- [imaa_t] 商品表
ALTER TABLE imaa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS imaa_policy ON imaa_t;
CREATE POLICY imaa_policy ON imaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR imaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR imaaent = get_auth_user_ent());

-- [cusa_t] 客戶表
ALTER TABLE cusa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS cusa_policy ON cusa_t;
CREATE POLICY cusa_policy ON cusa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR cusaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR cusaent = get_auth_user_ent());

-- [vnda_t] 供應商表
ALTER TABLE vnda_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS vnda_policy ON vnda_t;
CREATE POLICY vnda_policy ON vnda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR vndaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR vndaent = get_auth_user_ent());

-- [inaa_t] 倉庫表
ALTER TABLE inaa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inaa_policy ON inaa_t;
CREATE POLICY inaa_policy ON inaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inaaent = get_auth_user_ent());

-- [xmda_t] 銷貨訂單頭
ALTER TABLE xmda_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmda_policy ON xmda_t;
CREATE POLICY xmda_policy ON xmda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdaent = get_auth_user_ent());

-- [xmdc_t] 銷貨訂單身
ALTER TABLE xmdc_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdc_policy ON xmdc_t;
CREATE POLICY xmdc_policy ON xmdc_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdcent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdcent = get_auth_user_ent());

-- [xmdk_t] 出貨單頭
ALTER TABLE xmdk_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdk_policy ON xmdk_t;
CREATE POLICY xmdk_policy ON xmdk_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdkent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdkent = get_auth_user_ent());

-- [xmdl_t] 出貨單身
ALTER TABLE xmdl_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdl_policy ON xmdl_t;
CREATE POLICY xmdl_policy ON xmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdlent = get_auth_user_ent());

-- [xrca_t] 應收單頭
ALTER TABLE xrca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xrca_policy ON xrca_t;
CREATE POLICY xrca_policy ON xrca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcaent = get_auth_user_ent());

-- [xrcb_t] 應收單身
ALTER TABLE xrcb_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xrcb_policy ON xrcb_t;
CREATE POLICY xrcb_policy ON xrcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcbent = get_auth_user_ent());

-- [pmdl_t] 採購單頭
ALTER TABLE pmdl_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdl_policy ON pmdl_t;
CREATE POLICY pmdl_policy ON pmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdlent = get_auth_user_ent());

-- [pmdn_t] 採購單身
ALTER TABLE pmdn_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdn_policy ON pmdn_t;
CREATE POLICY pmdn_policy ON pmdn_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdnent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdnent = get_auth_user_ent());

-- [pmds_t] 收貨單頭
ALTER TABLE pmds_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmds_policy ON pmds_t;
CREATE POLICY pmds_policy ON pmds_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdsent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdsent = get_auth_user_ent());

-- [pmdt_t] 收貨單身
ALTER TABLE pmdt_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdt_policy ON pmdt_t;
CREATE POLICY pmdt_policy ON pmdt_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdtent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdtent = get_auth_user_ent());

-- [apca_t] 應付單頭
ALTER TABLE apca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS apca_policy ON apca_t;
CREATE POLICY apca_policy ON apca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcaent = get_auth_user_ent());

-- [apcb_t] 應付單身
ALTER TABLE apcb_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS apcb_policy ON apcb_t;
CREATE POLICY apcb_policy ON apcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcbent = get_auth_user_ent());

-- [inag_t] 庫存異動歷史
ALTER TABLE inag_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inag_policy ON inag_t;
CREATE POLICY inag_policy ON inag_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inagent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inagent = get_auth_user_ent());

-- [inaj_t] 庫存現有量
ALTER TABLE inaj_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inaj_policy ON inaj_t;
CREATE POLICY inaj_policy ON inaj_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inajent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inajent = get_auth_user_ent());

-- [reca_t] 核銷明細
ALTER TABLE reca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS reca_policy ON reca_t;
CREATE POLICY reca_policy ON reca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR recaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR recaent = get_auth_user_ent());
