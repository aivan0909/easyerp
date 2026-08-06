-- ============================================================
-- migration_void.sql — 補上「取消確認/作廢」功能所需欄位
-- 部署順序：schema.sql -> functions.sql -> migration_void.sql -> void_functions.sql
-- ============================================================

-- 收貨單頭：補作廢者/作廢時間
ALTER TABLE pmds_t ADD COLUMN IF NOT EXISTS pmdsvoidid  varchar(80);
ALTER TABLE pmds_t ADD COLUMN IF NOT EXISTS pmdsvoiddt  timestamptz;

-- 出貨單頭：補作廢者/作廢時間(對稱)
ALTER TABLE xmdk_t ADD COLUMN IF NOT EXISTS xmdkvoidid  varchar(80);
ALTER TABLE xmdk_t ADD COLUMN IF NOT EXISTS xmdkvoiddt  timestamptz;

-- 應付帳款單頭：原本 demo 版精簡掉了 status，這裡補上
ALTER TABLE apca_t ADD COLUMN IF NOT EXISTS apcastatus  varchar(10) DEFAULT '1';

-- 應收帳款單頭：同上，補上 status(對稱)
ALTER TABLE xrca_t ADD COLUMN IF NOT EXISTS xrcastatus  varchar(10) DEFAULT '1';
