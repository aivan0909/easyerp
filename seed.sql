-- ============================================================
-- ERP 系統 — 初始化種子資料 (seed.sql)
-- 部署方式：Supabase SQL Editor 執行本檔案，或以管理者權限部署
-- ============================================================

-- 1. 寫入預設角色主檔 (rola_t)
-- ADMIN: 系統管理員 (rola002='1')
-- STAFF: 一般職員 (rola002='0')
INSERT INTO rola_t (rolaent, rolacode, rola001, rola002, rolastatus)
VALUES 
  (1, 'ADMIN', '系統管理員', '1', '1'),
  (1, 'STAFF', '一般職員', '0', '1')
ON CONFLICT (rolaent, rolacode) DO UPDATE 
SET rola001 = EXCLUDED.rola001, rola002 = EXCLUDED.rola002, rolastatus = EXCLUDED.rolastatus;

-- 2. 寫入一般職員的細部模組權限明細 (rolb_t)
-- 管理員 (ADMIN) 角色不需要寫入此明細，程式會直接由 rola002='1' 判斷放行全部
INSERT INTO rolb_t (rolbent, rolbcode, rolbseq, rolb001, rolb002, rolb003, rolb004, rolb005)
VALUES
  (1, 'STAFF', 1, '銷貨訂單', '1', '1', '0', '0'),
  (1, 'STAFF', 2, '出貨單', '1', '1', '0', '0'),
  (1, 'STAFF', 3, '採購單', '1', '1', '0', '0'),
  (1, 'STAFF', 4, '庫存查詢', '1', '0', '0', '0')
ON CONFLICT (rolbent, rolbcode, rolbseq) DO UPDATE 
SET rolb001 = EXCLUDED.rolb001, rolb002 = EXCLUDED.rolb002, rolb003 = EXCLUDED.rolb003, rolb004 = EXCLUDED.rolb004, rolb005 = EXCLUDED.rolb005;

-- 3. 建立第一個系統管理員帳號 (ooag_t)
-- 對應目前登入的使用者 id: e627ab6c-235c-486d-81c0-d1be7c54a3ae
INSERT INTO ooag_t (ooagent, ooagcode, ooag001, ooag003, ooag004, ooagstatus)
VALUES
  (1, 'e627ab6c-235c-486d-81c0-d1be7c54a3ae', '系統管理員', 'ADMIN', 'obsidian', '1')
ON CONFLICT (ooagent, ooagcode) DO UPDATE
SET ooag001 = EXCLUDED.ooag001, ooag003 = EXCLUDED.ooag003, ooag004 = EXCLUDED.ooag004, ooagstatus = EXCLUDED.ooagstatus;
