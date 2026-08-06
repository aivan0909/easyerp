-- ============================================================
-- migration_user_email.sql — 讓 ooag_t 能顯示登入用的 email
-- 部署順序：... -> cost_functions.sql -> migration_user_email.sql
--
-- 背景：auth.users(Supabase Auth 內建表)存放 email/密碼，前端無法直接查詢。
-- 解法：ooag_t 補一個 email 欄位，用觸發器在使用者註冊/登入時自動同步過來。
-- ============================================================

-- 1) ooag_t 補 email 欄位
ALTER TABLE ooag_t ADD COLUMN IF NOT EXISTS ooag006 varchar(255);
CREATE INDEX IF NOT EXISTS ooag_email_ix ON ooag_t (ooag006);

-- 2) 觸發器函式：auth.users 新增使用者時，自動在 ooag_t 建立/更新對應資料
--    SECURITY DEFINER：以建立此函式者(通常是資料庫管理員)的權限執行，
--    這樣才能繞過 ooag_t 的 RLS 限制寫入資料(一般使用者不能自己寫入 ooag_t)
CREATE OR REPLACE FUNCTION handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO ooag_t (ooagent, ooagcode, ooag001, ooag006, ooagstatus)
  VALUES (1, NEW.id::text, split_part(NEW.email, '@', 1), NEW.email, '1')
  ON CONFLICT (ooagent, ooagcode) DO UPDATE SET ooag006 = EXCLUDED.ooag006;
  RETURN NEW;
END;
$$;

-- 3) 掛上觸發器：每次 auth.users 新增一筆，就自動觸發上面的函式
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_auth_user();

-- 4) 使用者登入時同步更新最後登入時間與(若有變更的) email
CREATE OR REPLACE FUNCTION handle_auth_user_login()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE ooag_t SET ooag005 = now(), ooag006 = NEW.email
  WHERE ooagent = 1 AND ooagcode = NEW.id::text;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;
CREATE TRIGGER on_auth_user_login
  AFTER UPDATE OF last_sign_in_at ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_auth_user_login();
