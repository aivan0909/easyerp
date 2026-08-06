-- ============================================================
-- migration_rls_helpers.sql — 管理員權限判斷輔助函式 + 帳號管理相關 RLS
-- 部署順序：... -> migration_user_email.sql -> migration_rls_helpers.sql
-- ============================================================

-- 0) 刪除寬鬆的舊政策以修復越權漏洞
DROP POLICY IF EXISTS ooag_policy ON ooag_t;

-- 判斷目前登入者是否為管理員(依 ooag_t.ooag003 對應 rola_t.rola002)
-- 這支函式會被多個 RLS 政策重複使用，統一寫一次，之後其他表要開放
-- 「管理員可以看/改全部資料」時，都可以直接呼叫這支函式，不用重複寫判斷邏輯
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM ooag_t o
    JOIN rola_t r ON r.rolaent = o.ooagent AND r.rolacode = o.ooag003
    WHERE o.ooagent = 1 AND o.ooagcode = auth.uid()::text AND r.rola002 = '1'
  );
$$;

-- 允許管理員更新任何人的 ooag_t 資料(基本資料編輯用途)
-- 注意：一般使用者原本就有「只能改自己那筆」的政策(先前已設定)，
-- 這裡是「新增」一條給管理員的例外規則，兩條政策並存，符合其一即可通過
DROP POLICY IF EXISTS ooag_admin_update ON ooag_t;
CREATE POLICY ooag_admin_update ON ooag_t
  FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- 允許管理員查詢所有使用者(原本的政策可能只開放看自己,這裡加開管理員例外)
DROP POLICY IF EXISTS ooag_admin_select ON ooag_t;
CREATE POLICY ooag_admin_select ON ooag_t
  FOR SELECT
  USING (is_admin());
