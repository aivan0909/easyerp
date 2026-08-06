-- ============================================================
-- ERP 系統 — Supabase (PostgreSQL) Schema
-- 命名規則：4碼前綴 + 業務欄位流水編號(001,002...) + 固定通用欄位
-- 對應「ERP資料字典.xlsx」與「索引設計」工作表
-- 部署方式：Supabase Dashboard > SQL Editor 貼上執行，或 supabase db push
-- ============================================================

-- ========== 主檔 ==========

CREATE TABLE imaa_t (
  imaaent    integer NOT NULL,
  imaacode   varchar(20) NOT NULL,
  imaa001    varchar(100),          -- 商品名稱
  imaa002    varchar(100),          -- 規格
  imaa003    varchar(20),           -- 商品分類
  imaa004    varchar(10),           -- 單位
  imaa005    numeric(15,2),         -- 參考成本價
  imaa006    numeric(15,2),         -- 參考售價
  imaa007    numeric(15,3) DEFAULT 0, -- 安全庫存量
  imaaownid  varchar(20), imaaowndp varchar(10),
  imaacrtid  varchar(20), imaacrtdp varchar(10), imaacrtdt timestamptz DEFAULT now(),
  imaamodid  varchar(20), imaamoddt timestamptz,
  imaastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (imaaent, imaacode)
);

CREATE TABLE cusa_t (
  cusaent    integer NOT NULL,
  cusacode   varchar(20) NOT NULL,
  cusa001    varchar(100),          -- 客戶名稱
  cusa002    varchar(20),           -- 統一編號
  cusa003    varchar(50),           -- 聯絡人
  cusa004    varchar(20),           -- 電話
  cusa005    varchar(200),          -- 地址
  cusa006    varchar(20),           -- 付款條件
  cusacrtid  varchar(20), cusacrtdt timestamptz DEFAULT now(),
  cusastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (cusaent, cusacode)
);

CREATE TABLE vnda_t (
  vndaent    integer NOT NULL,
  vndacode   varchar(20) NOT NULL,
  vnda001    varchar(100),
  vnda002    varchar(20),
  vnda003    varchar(50),
  vnda004    varchar(20),
  vnda005    varchar(200),
  vnda006    varchar(20),
  vndacrtid  varchar(20), vndacrtdt timestamptz DEFAULT now(),
  vndastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (vndaent, vndacode)
);

CREATE TABLE inaa_t (
  inaaent    integer NOT NULL,
  inaacode   varchar(10) NOT NULL,
  inaa001    varchar(50),
  inaa002    varchar(10),
  inaastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (inaaent, inaacode)
);

-- 使用者主檔：與 Supabase Auth 對應，ooagcode 建議直接用 auth.users.id (uuid 轉 text)
CREATE TABLE ooag_t (
  ooagent    integer NOT NULL,
  ooagcode   varchar(36) NOT NULL,  -- 對應 auth.users.id
  ooag001    varchar(50),           -- 姓名
  ooag003    varchar(10),           -- 角色代碼(FK rola_t)
  ooag004    varchar(20),           -- 介面主題
  ooag005    timestamptz,           -- 最後登入時間
  ooagstatus varchar(10) DEFAULT '1',
  PRIMARY KEY (ooagent, ooagcode)
);

CREATE TABLE rola_t (
  rolaent  integer NOT NULL,
  rolacode varchar(10) NOT NULL,
  rola001  varchar(50),
  rola002  varchar(1) DEFAULT '0', -- 是否管理員
  rolastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (rolaent, rolacode)
);

CREATE TABLE rolb_t (
  rolbent  integer NOT NULL,
  rolbcode varchar(10) NOT NULL,
  rolbseq  integer NOT NULL,
  rolb001  varchar(20), -- 模組代碼
  rolb002  varchar(1) DEFAULT '0', -- 可檢視
  rolb003  varchar(1) DEFAULT '0', -- 可編輯
  rolb004  varchar(1) DEFAULT '0', -- 可刪除
  rolb005  varchar(1) DEFAULT '0', -- 可審核
  PRIMARY KEY (rolbent, rolbcode, rolbseq)
);

-- ========== 銷貨訂單 ==========

CREATE TABLE xmda_t (
  xmdaent    integer NOT NULL,
  xmdadocno  varchar(20) NOT NULL,
  xmdadocdt  date DEFAULT current_date,
  xmda002    varchar(20),  -- 業務人員
  xmda004    varchar(20),  -- 客戶編號
  xmdacnfid  varchar(80), xmdacnfdt timestamptz,
  xmdastatus varchar(10) DEFAULT '0', -- 0草稿 1已確認
  PRIMARY KEY (xmdaent, xmdadocno)
);

CREATE TABLE xmdc_t (
  xmdcent   integer NOT NULL,
  xmdcdocno varchar(20) NOT NULL,
  xmdcseq   integer NOT NULL,
  xmdc001   varchar(20),   -- 商品編號
  xmdc002   numeric(15,3), -- 訂購數量
  xmdc003   numeric(15,2), -- 單價
  xmdc004   numeric(15,2), -- 小計金額
  xmdc005   numeric(15,3) DEFAULT 0, -- 已出貨數量
  xmdc006   numeric(15,2) DEFAULT 0, -- 已核銷金額
  PRIMARY KEY (xmdcent, xmdcdocno, xmdcseq)
);

-- ========== 出貨單 ==========

CREATE TABLE xmdk_t (
  xmdkent    integer NOT NULL,
  xmdkdocno  varchar(20) NOT NULL,
  xmdkdocdt  date DEFAULT current_date,
  xmdk004    varchar(20), -- 客戶編號
  xmdk005    varchar(20), -- 來源訂單單號
  xmdk006    varchar(10), -- 出貨倉庫代碼
  xmdkcnfid  varchar(80), xmdkcnfdt timestamptz,
  xmdkstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (xmdkent, xmdkdocno)
);

CREATE TABLE xmdl_t (
  xmdlent   integer NOT NULL,
  xmdldocno varchar(20) NOT NULL,
  xmdlseq   integer NOT NULL,
  xmdl001   varchar(20),
  xmdl002   numeric(15,3), -- 出貨數量
  xmdl003   numeric(15,2), -- 單價
  xmdl004   numeric(15,2), -- 小計金額
  xmdl005   integer,       -- 來源訂單單身序號
  PRIMARY KEY (xmdlent, xmdldocno, xmdlseq)
);

-- ========== 應收帳款單 ==========

CREATE TABLE xrca_t (
  xrcaent   integer NOT NULL,
  xrcadocno varchar(20) NOT NULL,
  xrcadocdt date DEFAULT current_date,
  xrca001   varchar(20),  -- 客戶編號
  xrca002   varchar(20),  -- 來源出貨單號
  xrca003   numeric(15,2),-- 應收總金額
  xrca004   numeric(15,2) DEFAULT 0, -- 已收金額
  xrca006   date,         -- 到期日
  PRIMARY KEY (xrcaent, xrcadocno)
);

CREATE TABLE xrcb_t (
  xrcbent   integer NOT NULL,
  xrcbdocno varchar(20) NOT NULL,
  xrcbseq   integer NOT NULL,
  xrcb001   varchar(20),
  xrcb002   numeric(15,3),
  xrcb003   numeric(15,2),
  xrcb004   numeric(15,2),
  xrcb005   integer,       -- 來源出貨單身序號
  PRIMARY KEY (xrcbent, xrcbdocno, xrcbseq)
);

-- ========== 採購單 ==========

CREATE TABLE pmdl_t (
  pmdlent    integer NOT NULL,
  pmdldocno  varchar(20) NOT NULL,
  pmdldocdt  date DEFAULT current_date,
  pmdl004    varchar(20),  -- 供應商編號
  pmdlcnfid  varchar(80), pmdlcnfdt timestamptz,
  pmdlstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (pmdlent, pmdldocno)
);

CREATE TABLE pmdn_t (
  pmdnent   integer NOT NULL,
  pmdndocno varchar(20) NOT NULL,
  pmdnseq   integer NOT NULL,
  pmdn001   varchar(20),
  pmdn002   numeric(15,3), -- 採購數量
  pmdn003   numeric(15,2), -- 單價
  pmdn004   numeric(15,2), -- 小計金額
  pmdn005   numeric(15,3) DEFAULT 0, -- 已入庫數量
  pmdn006   numeric(15,2) DEFAULT 0, -- 已核銷金額
  PRIMARY KEY (pmdnent, pmdndocno, pmdnseq)
);

-- ========== 收貨入庫單 ==========

CREATE TABLE pmds_t (
  pmdsent    integer NOT NULL,
  pmdsdocno  varchar(20) NOT NULL,
  pmdsdocdt  date DEFAULT current_date,
  pmds002    varchar(20), -- 來源採購單號
  pmds003    varchar(20), -- 供應商編號
  pmds004    varchar(10), -- 收貨倉庫代碼
  pmdscnfid  varchar(80), pmdscnfdt timestamptz,
  pmdsstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (pmdsent, pmdsdocno)
);

CREATE TABLE pmdt_t (
  pmdtent   integer NOT NULL,
  pmdtdocno varchar(20) NOT NULL,
  pmdtseq   integer NOT NULL,
  pmdt001   varchar(20),
  pmdt002   numeric(15,3), -- 收貨數量
  pmdt003   numeric(15,3), -- 驗收合格數量
  pmdt004   numeric(15,2), -- 單價
  pmdt005   numeric(15,2), -- 小計金額
  pmdt006   integer,       -- 來源採購單身序號
  PRIMARY KEY (pmdtent, pmdtdocno, pmdtseq)
);

-- ========== 應付帳款單 ==========

CREATE TABLE apca_t (
  apcaent   integer NOT NULL,
  apcadocno varchar(20) NOT NULL,
  apcadocdt date DEFAULT current_date,
  apca001   varchar(20),  -- 供應商編號
  apca002   varchar(20),  -- 來源收貨單號
  apca003   numeric(15,2),-- 應付總金額
  apca004   numeric(15,2) DEFAULT 0, -- 已付金額
  apca006   date,         -- 到期日
  PRIMARY KEY (apcaent, apcadocno)
);

CREATE TABLE apcb_t (
  apcbent   integer NOT NULL,
  apcbdocno varchar(20) NOT NULL,
  apcbseq   integer NOT NULL,
  apcb001   varchar(20),
  apcb002   numeric(15,3),
  apcb003   numeric(15,2),
  apcb004   numeric(15,2),
  apcb005   integer,       -- 來源收貨單身序號
  PRIMARY KEY (apcbent, apcbdocno, apcbseq)
);

-- ========== 庫存與核銷 ==========

CREATE TABLE inag_t (
  inagent   integer NOT NULL,
  inagdocno varchar(20) NOT NULL,
  inagdocdt timestamptz DEFAULT now(),
  inag001   varchar(20),  -- 商品編號
  inag002   varchar(10),  -- 倉庫代碼
  inag003   varchar(20),  -- 異動類別
  inag004   varchar(10),  -- 來源單據類型
  inag005   varchar(20),  -- 來源單號
  inag006   integer,      -- 來源單身序號
  inag007   varchar(1),   -- 異動方向(+/-)
  inag008   numeric(15,3),-- 異動數量
  inag009   numeric(15,3),-- 異動後結餘數量
  PRIMARY KEY (inagent, inagdocno)
);

CREATE TABLE inaj_t (
  inajent integer NOT NULL,
  inaj001 varchar(20) NOT NULL,
  inaj002 varchar(10) NOT NULL,
  inaj003 numeric(15,3) DEFAULT 0, -- 現有庫存量
  inaj004 numeric(15,3) DEFAULT 0, -- 已預留數量
  inaj005 numeric(15,3) DEFAULT 0, -- 在途數量
  PRIMARY KEY (inajent, inaj001, inaj002)
);

CREATE TABLE reca_t (
  recaent   integer NOT NULL,
  recadocno varchar(20) NOT NULL,
  reca001   varchar(10),  -- 來源單據類型(SO/PO)
  reca002   varchar(20),  -- 來源單號
  reca003   integer,      -- 來源單身序號
  reca004   varchar(10),  -- 目標單據類型(SH/GR)
  reca005   varchar(20),  -- 目標單號
  reca006   integer,      -- 目標單身序號
  reca007   varchar(20),  -- 商品編號
  reca008   numeric(15,3),-- 本次核銷數量
  reca009   numeric(15,2),-- 本次核銷金額
  reca012   varchar(1),   -- 核銷狀態
  reca013   date,
  PRIMARY KEY (recaent, recadocno)
);

-- 單號序號表(取代 App 端記憶體計數器,確保多人同時使用不會重複)
CREATE TABLE doc_seq_t (
  seq_key   varchar(30) PRIMARY KEY,
  seq_value integer NOT NULL DEFAULT 0
);

-- ============================================================
-- 索引（依「索引設計」工作表補上查詢用一般索引；PK 已在建表時定義）
-- ============================================================
CREATE INDEX xmda_ix1 ON xmda_t (xmdaent, xmda004);
CREATE INDEX xmdk_ix1 ON xmdk_t (xmdkent, xmdk005);
CREATE INDEX xrca_ix1 ON xrca_t (xrcaent, xrca001, xrca006);
CREATE INDEX pmdl_ix1 ON pmdl_t (pmdlent, pmdl004);
CREATE INDEX pmds_ix1 ON pmds_t (pmdsent, pmds002);
CREATE INDEX apca_ix1 ON apca_t (apcaent, apca001, apca006);
CREATE INDEX inag_ix1 ON inag_t (inagent, inag001, inag002);
CREATE INDEX reca_ix1 ON reca_t (recaent, reca002);
CREATE INDEX reca_ix2 ON reca_t (recaent, reca005);
