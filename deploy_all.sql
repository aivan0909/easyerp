-- ============================================================
-- ERP Á≥ªÁµ± ??Supabase (PostgreSQL) Schema
-- ?ΩÂ?Ë¶èÂ?Ôº?Á¢ºÂ?Á∂?+ Ê•≠Â?Ê¨Ñ‰?ÊµÅÊ∞¥Á∑®Ë?(001,002...) + ?∫Â??öÁî®Ê¨Ñ‰?
-- Â∞çÊ??åERPË≥áÊ?Â≠óÂÖ∏.xlsx?çË??åÁ¥¢ÂºïË®≠Ë®à„ÄçÂ∑•‰ΩúË°®
-- ?®ÁΩ≤?πÂ?ÔºöSupabase Dashboard > SQL Editor Ë≤º‰??∑Ë?ÔºåÊ? supabase db push
-- ============================================================

-- ========== ‰∏ªÊ? ==========

CREATE TABLE imaa_t (
  imaaent    integer NOT NULL,
  imaacode   varchar(20) NOT NULL,
  imaa001    varchar(100),          -- ?ÜÂ??çÁ®±
  imaa002    varchar(100),          -- Ë¶èÊ†º
  imaa003    varchar(20),           -- ?ÜÂ??ÜÈ?
  imaa004    varchar(10),           -- ?Æ‰?
  imaa005    numeric(15,2),         -- ?ÉËÄÉÊ??¨ÂÉπ
  imaa006    numeric(15,2),         -- ?ÉËÄÉÂîÆ??  imaa007    numeric(15,3) DEFAULT 0, -- ÂÆâÂÖ®Â∫´Â???  imaaownid  varchar(20), imaaowndp varchar(10),
  imaacrtid  varchar(20), imaacrtdp varchar(10), imaacrtdt timestamptz DEFAULT now(),
  imaamodid  varchar(20), imaamoddt timestamptz,
  imaastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (imaaent, imaacode)
);

CREATE TABLE cusa_t (
  cusaent    integer NOT NULL,
  cusacode   varchar(20) NOT NULL,
  cusa001    varchar(100),          -- ÂÆ¢Êà∂?çÁ®±
  cusa002    varchar(20),           -- Áµ±‰?Á∑®Ë?
  cusa003    varchar(50),           -- ?ØÁµ°‰∫?  cusa004    varchar(20),           -- ?ªË©±
  cusa005    varchar(200),          -- ?∞Â?
  cusa006    varchar(20),           -- ‰ªòÊ¨æÊ¢ù‰ª∂
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

-- ‰ΩøÁî®?Ö‰∏ªÊ™îÔ???Supabase Auth Â∞çÊ?Ôºåooagcode Âª∫Ë≠∞?¥Êé•??auth.users.id (uuid ËΩ?text)
CREATE TABLE ooag_t (
  ooagent    integer NOT NULL,
  ooagcode   varchar(36) NOT NULL,  -- Â∞çÊ? auth.users.id
  ooag001    varchar(50),           -- ÂßìÂ?
  ooag003    varchar(10),           -- ËßíËâ≤‰ª?¢º(FK rola_t)
  ooag004    varchar(20),           -- ‰ªãÈù¢‰∏ªÈ?
  ooag005    timestamptz,           -- ?ÄÂæåÁôª?•Ê???  ooagstatus varchar(10) DEFAULT '1',
  PRIMARY KEY (ooagent, ooagcode)
);

CREATE TABLE rola_t (
  rolaent  integer NOT NULL,
  rolacode varchar(10) NOT NULL,
  rola001  varchar(50),
  rola002  varchar(1) DEFAULT '0', -- ?ØÂê¶ÁÆ°Á???  rolastatus varchar(10) DEFAULT '1',
  PRIMARY KEY (rolaent, rolacode)
);

CREATE TABLE rolb_t (
  rolbent  integer NOT NULL,
  rolbcode varchar(10) NOT NULL,
  rolbseq  integer NOT NULL,
  rolb001  varchar(20), -- Ê®°Á?‰ª?¢º
  rolb002  varchar(1) DEFAULT '0', -- ?ØÊ™¢Ë¶?  rolb003  varchar(1) DEFAULT '0', -- ?ØÁ∑®Ëº?  rolb004  varchar(1) DEFAULT '0', -- ?ØÂà™??  rolb005  varchar(1) DEFAULT '0', -- ?ØÂØ©??  PRIMARY KEY (rolbent, rolbcode, rolbseq)
);

-- ========== ?∑Ë≤®Ë®ÇÂñÆ ==========

CREATE TABLE xmda_t (
  xmdaent    integer NOT NULL,
  xmdadocno  varchar(20) NOT NULL,
  xmdadocdt  date DEFAULT current_date,
  xmda002    varchar(20),  -- Ê•≠Â?‰∫∫Âì°
  xmda004    varchar(20),  -- ÂÆ¢Êà∂Á∑®Ë?
  xmdacnfid  varchar(80), xmdacnfdt timestamptz,
  xmdastatus varchar(10) DEFAULT '0', -- 0?âÁ®ø 1Â∑≤Á¢∫Ë™?  PRIMARY KEY (xmdaent, xmdadocno)
);

CREATE TABLE xmdc_t (
  xmdcent   integer NOT NULL,
  xmdcdocno varchar(20) NOT NULL,
  xmdcseq   integer NOT NULL,
  xmdc001   varchar(20),   -- ?ÜÂ?Á∑®Ë?
  xmdc002   numeric(15,3), -- Ë®ÇË≥º?∏È?
  xmdc003   numeric(15,2), -- ?ÆÂÉπ
  xmdc004   numeric(15,2), -- Â∞èË??ëÈ?
  xmdc005   numeric(15,3) DEFAULT 0, -- Â∑≤Âá∫Ë≤®Êï∏??  xmdc006   numeric(15,2) DEFAULT 0, -- Â∑≤Ê†∏?∑È?È°?  PRIMARY KEY (xmdcent, xmdcdocno, xmdcseq)
);

-- ========== ?∫Ë≤®??==========

CREATE TABLE xmdk_t (
  xmdkent    integer NOT NULL,
  xmdkdocno  varchar(20) NOT NULL,
  xmdkdocdt  date DEFAULT current_date,
  xmdk004    varchar(20), -- ÂÆ¢Êà∂Á∑®Ë?
  xmdk005    varchar(20), -- ‰æÜÊ?Ë®ÇÂñÆ?ÆË?
  xmdk006    varchar(10), -- ?∫Ë≤®?âÂ∫´‰ª?¢º
  xmdkcnfid  varchar(80), xmdkcnfdt timestamptz,
  xmdkstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (xmdkent, xmdkdocno)
);

CREATE TABLE xmdl_t (
  xmdlent   integer NOT NULL,
  xmdldocno varchar(20) NOT NULL,
  xmdlseq   integer NOT NULL,
  xmdl001   varchar(20),
  xmdl002   numeric(15,3), -- ?∫Ë≤®?∏È?
  xmdl003   numeric(15,2), -- ?ÆÂÉπ
  xmdl004   numeric(15,2), -- Â∞èË??ëÈ?
  xmdl005   integer,       -- ‰æÜÊ?Ë®ÇÂñÆ?ÆË∫´Â∫èË?
  PRIMARY KEY (xmdlent, xmdldocno, xmdlseq)
);

-- ========== ?âÊî∂Â∏≥Ê¨æ??==========

CREATE TABLE xrca_t (
  xrcaent   integer NOT NULL,
  xrcadocno varchar(20) NOT NULL,
  xrcadocdt date DEFAULT current_date,
  xrca001   varchar(20),  -- ÂÆ¢Êà∂Á∑®Ë?
  xrca002   varchar(20),  -- ‰æÜÊ??∫Ë≤®?ÆË?
  xrca003   numeric(15,2),-- ?âÊî∂Á∏ΩÈ?È°?  xrca004   numeric(15,2) DEFAULT 0, -- Â∑≤Êî∂?ëÈ?
  xrca006   date,         -- ?∞Ê???  PRIMARY KEY (xrcaent, xrcadocno)
);

CREATE TABLE xrcb_t (
  xrcbent   integer NOT NULL,
  xrcbdocno varchar(20) NOT NULL,
  xrcbseq   integer NOT NULL,
  xrcb001   varchar(20),
  xrcb002   numeric(15,3),
  xrcb003   numeric(15,2),
  xrcb004   numeric(15,2),
  xrcb005   integer,       -- ‰æÜÊ??∫Ë≤®?ÆË∫´Â∫èË?
  PRIMARY KEY (xrcbent, xrcbdocno, xrcbseq)
);

-- ========== ?°Ë≥º??==========

CREATE TABLE pmdl_t (
  pmdlent    integer NOT NULL,
  pmdldocno  varchar(20) NOT NULL,
  pmdldocdt  date DEFAULT current_date,
  pmdl004    varchar(20),  -- ‰æõÊ??ÜÁ∑®??  pmdlcnfid  varchar(80), pmdlcnfdt timestamptz,
  pmdlstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (pmdlent, pmdldocno)
);

CREATE TABLE pmdn_t (
  pmdnent   integer NOT NULL,
  pmdndocno varchar(20) NOT NULL,
  pmdnseq   integer NOT NULL,
  pmdn001   varchar(20),
  pmdn002   numeric(15,3), -- ?°Ë≥º?∏È?
  pmdn003   numeric(15,2), -- ?ÆÂÉπ
  pmdn004   numeric(15,2), -- Â∞èË??ëÈ?
  pmdn005   numeric(15,3) DEFAULT 0, -- Â∑≤ÂÖ•Â∫´Êï∏??  pmdn006   numeric(15,2) DEFAULT 0, -- Â∑≤Ê†∏?∑È?È°?  PRIMARY KEY (pmdnent, pmdndocno, pmdnseq)
);

-- ========== ?∂Ë≤®?•Â∫´??==========

CREATE TABLE pmds_t (
  pmdsent    integer NOT NULL,
  pmdsdocno  varchar(20) NOT NULL,
  pmdsdocdt  date DEFAULT current_date,
  pmds002    varchar(20), -- ‰æÜÊ??°Ë≥º?ÆË?
  pmds003    varchar(20), -- ‰æõÊ??ÜÁ∑®??  pmds004    varchar(10), -- ?∂Ë≤®?âÂ∫´‰ª?¢º
  pmdscnfid  varchar(80), pmdscnfdt timestamptz,
  pmdsstatus varchar(10) DEFAULT '0',
  PRIMARY KEY (pmdsent, pmdsdocno)
);

CREATE TABLE pmdt_t (
  pmdtent   integer NOT NULL,
  pmdtdocno varchar(20) NOT NULL,
  pmdtseq   integer NOT NULL,
  pmdt001   varchar(20),
  pmdt002   numeric(15,3), -- ?∂Ë≤®?∏È?
  pmdt003   numeric(15,3), -- È©óÊî∂?àÊ†º?∏È?
  pmdt004   numeric(15,2), -- ?ÆÂÉπ
  pmdt005   numeric(15,2), -- Â∞èË??ëÈ?
  pmdt006   integer,       -- ‰æÜÊ??°Ë≥º?ÆË∫´Â∫èË?
  PRIMARY KEY (pmdtent, pmdtdocno, pmdtseq)
);

-- ========== ?â‰?Â∏≥Ê¨æ??==========

CREATE TABLE apca_t (
  apcaent   integer NOT NULL,
  apcadocno varchar(20) NOT NULL,
  apcadocdt date DEFAULT current_date,
  apca001   varchar(20),  -- ‰æõÊ??ÜÁ∑®??  apca002   varchar(20),  -- ‰æÜÊ??∂Ë≤®?ÆË?
  apca003   numeric(15,2),-- ?â‰?Á∏ΩÈ?È°?  apca004   numeric(15,2) DEFAULT 0, -- Â∑≤‰??ëÈ?
  apca006   date,         -- ?∞Ê???  PRIMARY KEY (apcaent, apcadocno)
);

CREATE TABLE apcb_t (
  apcbent   integer NOT NULL,
  apcbdocno varchar(20) NOT NULL,
  apcbseq   integer NOT NULL,
  apcb001   varchar(20),
  apcb002   numeric(15,3),
  apcb003   numeric(15,2),
  apcb004   numeric(15,2),
  apcb005   integer,       -- ‰æÜÊ??∂Ë≤®?ÆË∫´Â∫èË?
  PRIMARY KEY (apcbent, apcbdocno, apcbseq)
);

-- ========== Â∫´Â??áÊ†∏??==========

CREATE TABLE inag_t (
  inagent   integer NOT NULL,
  inagdocno varchar(20) NOT NULL,
  inagdocdt timestamptz DEFAULT now(),
  inag001   varchar(20),  -- ?ÜÂ?Á∑®Ë?
  inag002   varchar(10),  -- ?âÂ∫´‰ª?¢º
  inag003   varchar(20),  -- ?∞Â?È°ûÂà•
  inag004   varchar(10),  -- ‰æÜÊ??ÆÊ?È°ûÂ?
  inag005   varchar(20),  -- ‰æÜÊ??ÆË?
  inag006   integer,      -- ‰æÜÊ??ÆË∫´Â∫èË?
  inag007   varchar(1),   -- ?∞Â??πÂ?(+/-)
  inag008   numeric(15,3),-- ?∞Â??∏È?
  inag009   numeric(15,3),-- ?∞Â?ÂæåÁ?È§òÊï∏??  PRIMARY KEY (inagent, inagdocno)
);

CREATE TABLE inaj_t (
  inajent integer NOT NULL,
  inaj001 varchar(20) NOT NULL,
  inaj002 varchar(10) NOT NULL,
  inaj003 numeric(15,3) DEFAULT 0, -- ?æÊ?Â∫´Â???  inaj004 numeric(15,3) DEFAULT 0, -- Â∑≤È??ôÊï∏??  inaj005 numeric(15,3) DEFAULT 0, -- ?®ÈÄîÊï∏??  PRIMARY KEY (inajent, inaj001, inaj002)
);

CREATE TABLE reca_t (
  recaent   integer NOT NULL,
  recadocno varchar(20) NOT NULL,
  reca001   varchar(10),  -- ‰æÜÊ??ÆÊ?È°ûÂ?(SO/PO)
  reca002   varchar(20),  -- ‰æÜÊ??ÆË?
  reca003   integer,      -- ‰æÜÊ??ÆË∫´Â∫èË?
  reca004   varchar(10),  -- ?ÆÊ??ÆÊ?È°ûÂ?(SH/GR)
  reca005   varchar(20),  -- ?ÆÊ??ÆË?
  reca006   integer,      -- ?ÆÊ??ÆË∫´Â∫èË?
  reca007   varchar(20),  -- ?ÜÂ?Á∑®Ë?
  reca008   numeric(15,3),-- ?¨Ê¨°?∏Èä∑?∏È?
  reca009   numeric(15,2),-- ?¨Ê¨°?∏Èä∑?ëÈ?
  reca012   varchar(1),   -- ?∏Èä∑?Ä??  reca013   date,
  PRIMARY KEY (recaent, recadocno)
);

-- ?ÆË?Â∫èË?Ë°??ñ‰ª£ App Á´ØË??∂È?Ë®àÊï∏??Á¢∫‰?Â§ö‰∫∫?åÊ?‰ΩøÁî®‰∏çÊ??çË?)
CREATE TABLE doc_seq_t (
  seq_key   varchar(30) PRIMARY KEY,
  seq_value integer NOT NULL DEFAULT 0
);

-- ============================================================
-- Á¥¢Â?Ôºà‰??åÁ¥¢ÂºïË®≠Ë®à„ÄçÂ∑•‰ΩúË°®Ë£ú‰??•Ë©¢?®‰??¨Á¥¢ÂºïÔ?PK Â∑≤Âú®Âª∫Ë°®?ÇÂ?Áæ©Ô?
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
-- ============================================================
-- ERP Á≥ªÁµ± ???∏Â?Ê•≠Â??èËºØ(PostgreSQL Functions)
-- Â∞çÊ??åERP-APIË®≠Ë??á‰ª∂.md?çÁ¨¨ 8?? ÁØÄ
-- ?®ÁΩ≤ÔºöSupabase SQL Editor ?∑Ë??¨Ê?Ê°??Ä?àÂü∑Ë°?schema.sql)
-- ?ºÂè´?πÂ?(?çÁ´Ø supabase-js)Ôº?--   const { data, error } = await supabase.rpc('confirm_shipment', {
--     p_ent: 1, p_docno: 'SH-20260805-0001', p_user: userId
--   });
-- ============================================================

-- ------------------------------------------------------------
-- 1. ?ÆË??¢Á??®Ô??®Ë??ôÂ∫´Â∫èË?Ë°®Ô??ñ‰ª£ App Á´ØË??∂È?Ë®àÊï∏??--    Â§ö‰∫∫?åÊ??ºÂè´‰πü‰??ÉÈ?Ë§áÔ???UPDATE ... RETURNING ‰øùË??üÂ??ßÔ?
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_next_docno(p_prefix text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_key   text := p_prefix || '-' || to_char(current_date, 'YYYYMMDD');
  v_value integer;
BEGIN
  INSERT INTO doc_seq_t (seq_key, seq_value) VALUES (v_key, 1)
  ON CONFLICT (seq_key) DO UPDATE SET seq_value = doc_seq_t.seq_value + 1
  RETURNING seq_value INTO v_value;

  RETURN v_key || '-' || lpad(v_value::text, 4, '0');
END;
$$;

-- ------------------------------------------------------------
-- 2. ?∏Èä∑?çÂ?ÔºöË??ÜÂ??ãÈ???src_doc_type ?ØËÉΩ??SO ??PO)
--    Â∞çÊ? Node.js PoC ??reconciliationService.record()
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_record_reconciliation(
  p_ent integer,
  p_src_doc_type varchar,   -- 'SO' ??'PO'
  p_src_doc_no   varchar,
  p_src_doc_seq  integer,
  p_dst_doc_type varchar,   -- 'SH' ??'GR'
  p_dst_doc_no   varchar,
  p_dst_doc_seq  integer,
  p_item_code    varchar,
  p_qty          numeric,
  p_amount       numeric
) RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_qty     numeric;
  v_already_done  numeric;
  v_remaining     numeric;
  v_new_done      numeric;
  v_status        varchar;
  v_recadocno     varchar;
BEGIN
  -- ‰æù‰?Ê∫êÂñÆ?öÈ??ãÂ??ãÊü•Ë©¢Â??âË°®Ôºå‰∏¶??FOR UPDATE ?ñÂ?Ë©≤Ë?Ôº?  -- ?øÂ??åÂ??ÅÂ??ÇË¢´?©Á??∫Ë≤®?ÆÊ†∏?∑Ê??ºÁ?Á´∂Áà≠Ê¢ù‰ª∂(race condition)
  IF p_src_doc_type = 'SO' THEN
    SELECT xmdc002, xmdc005 INTO v_order_qty, v_already_done
    FROM xmdc_t WHERE xmdcent = p_ent AND xmdcdocno = p_src_doc_no AND xmdcseq = p_src_doc_seq
    FOR UPDATE;
  ELSIF p_src_doc_type = 'PO' THEN
    SELECT pmdn002, pmdn005 INTO v_order_qty, v_already_done
    FROM pmdn_t WHERE pmdnent = p_ent AND pmdndocno = p_src_doc_no AND pmdnseq = p_src_doc_seq
    FOR UPDATE;
  ELSE
    RAISE EXCEPTION 'UNSUPPORTED_SRC_TYPE: ‰∏çÊîØ?¥Á?‰æÜÊ??ÆÊ?È°ûÂ? %', p_src_doc_type;
  END IF;

  IF v_order_qty IS NULL THEN
    RAISE EXCEPTION 'SRC_DOC_NOT_FOUND: ‰æÜÊ??ÆË∫´‰∏çÂ???% % #%', p_src_doc_type, p_src_doc_no, p_src_doc_seq;
  END IF;

  v_remaining := v_order_qty - v_already_done;
  IF p_qty > v_remaining + 0.0001 THEN
    RAISE EXCEPTION 'QTY_EXCEED_SOURCE: ?∏Èä∑?∏È?(%)Ë∂ÖÈ?‰æÜÊ??ÆÂâ©È§òÂèØ?∏Èä∑??%)', p_qty, v_remaining;
  END IF;

  v_new_done := v_already_done + p_qty;
  v_status := CASE WHEN v_new_done >= v_order_qty - 0.0001 THEN '2' ELSE '1' END;
  v_recadocno := fn_next_docno('REC');

  INSERT INTO reca_t (recaent, recadocno, reca001, reca002, reca003, reca004, reca005, reca006,
                       reca007, reca008, reca009, reca012, reca013)
  VALUES (p_ent, v_recadocno, p_src_doc_type, p_src_doc_no, p_src_doc_seq,
          p_dst_doc_type, p_dst_doc_no, p_dst_doc_seq, p_item_code, p_qty, p_amount, v_status, current_date);

  IF p_src_doc_type = 'SO' THEN
    UPDATE xmdc_t SET xmdc005 = v_new_done
    WHERE xmdcent = p_ent AND xmdcdocno = p_src_doc_no AND xmdcseq = p_src_doc_seq;
  ELSIF p_src_doc_type = 'PO' THEN
    UPDATE pmdn_t SET pmdn005 = v_new_done
    WHERE pmdnent = p_ent AND pmdndocno = p_src_doc_no AND pmdnseq = p_src_doc_seq;
  END IF;

  RETURN v_recadocno;
END;
$$;

-- ------------------------------------------------------------
-- 3. Â∫´Â??∫Â∫´ÔºöÊ™¢?•Áèæ?âÈ?Ë∂≥Â? -> ÂØ?inag_t -> ?¥Êñ∞ inaj_t
--    FOR UPDATE ?ñÂ?Â∫´Â?ÂΩôÁ∏ΩË°åÔ??øÂ??ãÊ?Â§ö‰∫∫?åÊ??∫Ë≤®?†Ê?Ë∂ÖË≥£
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stock_out(
  p_ent integer, p_item_code varchar, p_wh_code varchar, p_qty numeric,
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_current numeric;
  v_new_balance numeric;
  v_inagdocno varchar;
BEGIN
  -- ?•Â?Á∏ΩÂ?‰∏çÂ??®Â?Âª∫Á?‰∏Ä?óÔ??çÈ?ÂÆ?  INSERT INTO inaj_t (inajent, inaj001, inaj002, inaj003, inaj004, inaj005)
  VALUES (p_ent, p_item_code, p_wh_code, 0, 0, 0)
  ON CONFLICT (inajent, inaj001, inaj002) DO NOTHING;

  SELECT inaj003 INTO v_current FROM inaj_t
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code
  FOR UPDATE;

  IF v_current < p_qty - 0.0001 THEN
    RAISE EXCEPTION 'STOCK_INSUFFICIENT: ?ÜÂ? % Â∫´Â?‰∏çË∂≥(?æÊ? %ÔºåÈ?Ë¶?%)', p_item_code, v_current, p_qty;
  END IF;

  v_new_balance := v_current - p_qty;
  v_inagdocno := fn_next_docno('INAG');

  INSERT INTO inag_t (inagent, inagdocno, inag001, inag002, inag003, inag004, inag005, inag006, inag007, inag008, inag009)
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, '?∑Ë≤®?∫Ë≤®', p_src_doc_type, p_src_doc_no, p_src_doc_seq, '-', p_qty, v_new_balance);

  UPDATE inaj_t SET inaj003 = v_new_balance
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code;
END;
$$;

-- ------------------------------------------------------------
-- 4. ?∏Â??ï‰?ÔºöÁ¢∫Ë™çÂá∫Ë≤?--    ?¥ÂÄãÂáΩÂºèÊú¨Ë∫´Â∞±?Ø‰??ãË??ôÂ∫´‰∫§Ê?Ôºå‰ªª‰Ωï‰?Ê≠?RAISE EXCEPTION
--    ?ΩÊ?ËÆìÂ??¢Â∑≤?∑Ë???INSERT/UPDATE ?™Â??®ÈÉ®?ûÊªæÔºàPostgres ?üÁ??πÊÄßÔ?
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_shipment(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header    xmdk_t%ROWTYPE;
  v_line      xmdl_t%ROWTYPE;
  v_ar_docno  varchar;
  v_ar_total  numeric := 0;
  v_ar_seq    integer := 0;
BEGIN
  SELECT * INTO v_header FROM xmdk_t WHERE xmdkent = p_ent AND xmdkdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: ?∫Ë≤®?Æ‰?Â≠òÂú® %', p_docno;
  END IF;
  IF v_header.xmdkstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: Ê≠§Âá∫Ë≤®ÂñÆÂ∑≤Á¢∫Ë™?%', p_docno;
  END IF;

  v_ar_docno := fn_next_docno('AR');

  -- ?êË?ÔºöÊâ£Â∫´Â? -> ?∏Èä∑?ûË???-> Á¥ØË??âÊî∂?ëÈ?
  FOR v_line IN SELECT * FROM xmdl_t WHERE xmdlent = p_ent AND xmdldocno = p_docno ORDER BY xmdlseq
  LOOP
    PERFORM fn_stock_out(p_ent, v_line.xmdl001, v_header.xmdk006, v_line.xmdl002, 'SH', p_docno, v_line.xmdlseq);

    PERFORM fn_record_reconciliation(
      p_ent, 'SO', v_header.xmdk005, v_line.xmdl005,
      'SH', p_docno, v_line.xmdlseq,
      v_line.xmdl001, v_line.xmdl002, v_line.xmdl004
    );

    v_ar_seq := v_ar_seq + 1;
    v_ar_total := v_ar_total + v_line.xmdl004;

    INSERT INTO xrcb_t (xrcbent, xrcbdocno, xrcbseq, xrcb001, xrcb002, xrcb003, xrcb004, xrcb005)
    VALUES (p_ent, v_ar_docno, v_ar_seq, v_line.xmdl001, v_line.xmdl002, v_line.xmdl003, v_line.xmdl004, v_line.xmdlseq);
  END LOOP;

  INSERT INTO xrca_t (xrcaent, xrcadocno, xrca001, xrca002, xrca003, xrca004)
  VALUES (p_ent, v_ar_docno, v_header.xmdk004, p_docno, v_ar_total, 0);

  UPDATE xmdk_t SET xmdkstatus = '1', xmdkcnfid = p_user, xmdkcnfdt = now()
  WHERE xmdkent = p_ent AND xmdkdocno = p_docno;

  RETURN jsonb_build_object(
    'docno', p_docno,
    'receivableDocNo', v_ar_docno,
    'receivableAmount', v_ar_total
  );
END;
$$;

-- ------------------------------------------------------------
-- 5. Â∫´Â??•Â∫´ÔºöË? fn_stock_out Â∞çÁ®±ÔºåÊñπ?ëÁõ∏?çÔ?‰∏çÁî®Ê™¢Êü•?ØÂê¶Ë∂≥Â?
--    ?åÊ®£??FOR UPDATE ?ñÂ?Â∫´Â?ÂΩôÁ∏ΩË°åÔ??øÂ?Â§ö‰∫∫?åÊ??∂Ë≤®?†Ê??†Á∏Ω?ØË™§
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stock_in(
  p_ent integer, p_item_code varchar, p_wh_code varchar, p_qty numeric,
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_current numeric;
  v_new_balance numeric;
  v_inagdocno varchar;
BEGIN
  INSERT INTO inaj_t (inajent, inaj001, inaj002, inaj003, inaj004, inaj005)
  VALUES (p_ent, p_item_code, p_wh_code, 0, 0, 0)
  ON CONFLICT (inajent, inaj001, inaj002) DO NOTHING;

  SELECT inaj003 INTO v_current FROM inaj_t
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code
  FOR UPDATE;

  v_new_balance := v_current + p_qty;
  v_inagdocno := fn_next_docno('INAG');

  INSERT INTO inag_t (inagent, inagdocno, inag001, inag002, inag003, inag004, inag005, inag006, inag007, inag008, inag009)
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, '?°Ë≥º?•Â∫´', p_src_doc_type, p_src_doc_no, p_src_doc_seq, '+', p_qty, v_new_balance);

  UPDATE inaj_t SET inaj003 = v_new_balance
  WHERE inajent = p_ent AND inaj001 = p_item_code AND inaj002 = p_wh_code;
END;
$$;

-- ------------------------------------------------------------
-- 6. ?∏Â??ï‰?ÔºöÁ¢∫Ë™çÊî∂Ë≤?Â∞çÁ®±??confirm_shipment)
--    ?°Ë≥º??PO) -> ?∂Ë≤®?•Â∫´??GR) -> ?â‰?Â∏≥Ê¨æ??AP)
--    Â∑ÆÁï∞Ôºöfn_record_reconciliation ??p_src_doc_type ?πÂÇ≥ 'PO'Ôº?--          fn_stock_out ?õÊ? fn_stock_inÔºåxrca/xrcb ?õÊ? apca/apcb
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_goods_receipt(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header    pmds_t%ROWTYPE;
  v_line      pmdt_t%ROWTYPE;
  v_ap_docno  varchar;
  v_ap_total  numeric := 0;
  v_ap_seq    integer := 0;
BEGIN
  SELECT * INTO v_header FROM pmds_t WHERE pmdsent = p_ent AND pmdsdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: ?∂Ë≤®?Æ‰?Â≠òÂú® %', p_docno;
  END IF;
  IF v_header.pmdsstatus = '1' THEN
    RAISE EXCEPTION 'DOC_ALREADY_CONFIRMED: Ê≠§Êî∂Ë≤®ÂñÆÂ∑≤Á¢∫Ë™?%', p_docno;
  END IF;

  v_ap_docno := fn_next_docno('AP');

  -- ?êË?ÔºöÂ?Â∫´Â?(?®È??∂Â??ºÊï∏??pmdt003,?åÈ??∂Ë≤®?∏È? pmdt002) -> ?∏Èä∑?ûÊé°Ë≥ºÂñÆ -> Á¥ØË??â‰??ëÈ?
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    PERFORM fn_stock_in(p_ent, v_line.pmdt001, v_header.pmds004, v_line.pmdt003, 'GR', p_docno, v_line.pmdtseq);

    PERFORM fn_record_reconciliation(
      p_ent, 'PO', v_header.pmds002, v_line.pmdt006,
      'GR', p_docno, v_line.pmdtseq,
      v_line.pmdt001, v_line.pmdt003, v_line.pmdt005
    );

    v_ap_seq := v_ap_seq + 1;
    v_ap_total := v_ap_total + v_line.pmdt005;

    INSERT INTO apcb_t (apcbent, apcbdocno, apcbseq, apcb001, apcb002, apcb003, apcb004, apcb005)
    VALUES (p_ent, v_ap_docno, v_ap_seq, v_line.pmdt001, v_line.pmdt003, v_line.pmdt004, v_line.pmdt005, v_line.pmdtseq);
  END LOOP;

  INSERT INTO apca_t (apcaent, apcadocno, apca001, apca002, apca003, apca004)
  VALUES (p_ent, v_ap_docno, v_header.pmds003, p_docno, v_ap_total, 0);

  UPDATE pmds_t SET pmdsstatus = '1', pmdscnfid = p_user, pmdscnfdt = now()
  WHERE pmdsent = p_ent AND pmdsdocno = p_docno;

  RETURN jsonb_build_object(
    'docno', p_docno,
    'payableDocNo', v_ap_docno,
    'payableAmount', v_ap_total
  );
END;
$$;
-- ============================================================
-- ERP Á≥ªÁµ± ??Row Level Security (RLS) ?øÁ?
-- ============================================================

-- ========== 1. RLS Helper ?ΩÊï∏ ==========

-- ?ñÂ??∂Â??ªÂÖ•‰ΩøÁî®?ÖÁ?‰ºÅÊ•≠‰ª?¢º (ooagent)
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

-- Ê™¢Êü•?∂Â??ªÂÖ•‰ΩøÁî®?ÖÊòØ?¶ÁÇ∫Á≥ªÁµ±ÁÆ°Á???(rola002 = '1')
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


-- ========== 2. ?êÂì°?∫Êú¨Ë≥áÊ??áÊ??êË°® RLS ==========

-- [ooag_t] ‰ΩøÁî®?ÖÊ?Ê°àË°®
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


-- [rola_t] ËßíËâ≤Ë°?(?ØË?)
ALTER TABLE rola_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rola_select_policy ON rola_t;
CREATE POLICY rola_select_policy ON rola_t FOR SELECT TO authenticated
  USING (true);


-- [rolb_t] ËßíËâ≤Ê®°Á?Ê¨äÈ??éÁ¥∞Ë°?(?ØË?)
ALTER TABLE rolb_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rolb_select_policy ON rolb_t;
CREATE POLICY rolb_select_policy ON rolb_t FOR SELECT TO authenticated
  USING (true);


-- [doc_seq_t] ?ÆË?Â∫èË?Ë°?(?ÅË®± authenticated ‰ΩøÁî®?ÖÊñ∞Â¢ûË??¥Êñ∞‰ª•Ë? fn_next_docno ?ã‰?)
ALTER TABLE doc_seq_t ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS doc_seq_policy ON doc_seq_t;
CREATE POLICY doc_seq_policy ON doc_seq_t FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- ========== 3. ?∂‰?Ê•≠Â?Ë°?RLS ?øÁ? (ÁÆ°Á??°ÂèØË¶ãÂÖ®?®Ô?‰∏Ä?¨‰∫∫?ÖÈ??™Â∑±‰ºÅÊ•≠) ==========

-- [imaa_t] ?ÜÂ?Ë°?ALTER TABLE imaa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS imaa_policy ON imaa_t;
CREATE POLICY imaa_policy ON imaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR imaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR imaaent = get_auth_user_ent());

-- [cusa_t] ÂÆ¢Êà∂Ë°?ALTER TABLE cusa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS cusa_policy ON cusa_t;
CREATE POLICY cusa_policy ON cusa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR cusaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR cusaent = get_auth_user_ent());

-- [vnda_t] ‰æõÊ??ÜË°®
ALTER TABLE vnda_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS vnda_policy ON vnda_t;
CREATE POLICY vnda_policy ON vnda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR vndaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR vndaent = get_auth_user_ent());

-- [inaa_t] ?âÂ∫´Ë°?ALTER TABLE inaa_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inaa_policy ON inaa_t;
CREATE POLICY inaa_policy ON inaa_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inaaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inaaent = get_auth_user_ent());

-- [xmda_t] ?∑Ë≤®Ë®ÇÂñÆ??ALTER TABLE xmda_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmda_policy ON xmda_t;
CREATE POLICY xmda_policy ON xmda_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdaent = get_auth_user_ent());

-- [xmdc_t] ?∑Ë≤®Ë®ÇÂñÆË∫?ALTER TABLE xmdc_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdc_policy ON xmdc_t;
CREATE POLICY xmdc_policy ON xmdc_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdcent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdcent = get_auth_user_ent());

-- [xmdk_t] ?∫Ë≤®?ÆÈ†≠
ALTER TABLE xmdk_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdk_policy ON xmdk_t;
CREATE POLICY xmdk_policy ON xmdk_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdkent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdkent = get_auth_user_ent());

-- [xmdl_t] ?∫Ë≤®?ÆË∫´
ALTER TABLE xmdl_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xmdl_policy ON xmdl_t;
CREATE POLICY xmdl_policy ON xmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xmdlent = get_auth_user_ent());

-- [xrca_t] ?âÊî∂?ÆÈ†≠
ALTER TABLE xrca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xrca_policy ON xrca_t;
CREATE POLICY xrca_policy ON xrca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcaent = get_auth_user_ent());

-- [xrcb_t] ?âÊî∂?ÆË∫´
ALTER TABLE xrcb_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS xrcb_policy ON xrcb_t;
CREATE POLICY xrcb_policy ON xrcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR xrcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR xrcbent = get_auth_user_ent());

-- [pmdl_t] ?°Ë≥º?ÆÈ†≠
ALTER TABLE pmdl_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdl_policy ON pmdl_t;
CREATE POLICY pmdl_policy ON pmdl_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdlent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdlent = get_auth_user_ent());

-- [pmdn_t] ?°Ë≥º?ÆË∫´
ALTER TABLE pmdn_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdn_policy ON pmdn_t;
CREATE POLICY pmdn_policy ON pmdn_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdnent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdnent = get_auth_user_ent());

-- [pmds_t] ?∂Ë≤®?ÆÈ†≠
ALTER TABLE pmds_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmds_policy ON pmds_t;
CREATE POLICY pmds_policy ON pmds_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdsent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdsent = get_auth_user_ent());

-- [pmdt_t] ?∂Ë≤®?ÆË∫´
ALTER TABLE pmdt_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pmdt_policy ON pmdt_t;
CREATE POLICY pmdt_policy ON pmdt_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR pmdtent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR pmdtent = get_auth_user_ent());

-- [apca_t] ?â‰??ÆÈ†≠
ALTER TABLE apca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS apca_policy ON apca_t;
CREATE POLICY apca_policy ON apca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcaent = get_auth_user_ent());

-- [apcb_t] ?â‰??ÆË∫´
ALTER TABLE apcb_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS apcb_policy ON apcb_t;
CREATE POLICY apcb_policy ON apcb_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR apcbent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR apcbent = get_auth_user_ent());

-- [inag_t] Â∫´Â??∞Â?Ê≠∑Âè≤
ALTER TABLE inag_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inag_policy ON inag_t;
CREATE POLICY inag_policy ON inag_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inagent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inagent = get_auth_user_ent());

-- [inaj_t] Â∫´Â??æÊ???ALTER TABLE inaj_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inaj_policy ON inaj_t;
CREATE POLICY inaj_policy ON inaj_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR inajent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR inajent = get_auth_user_ent());

-- [reca_t] ?∏Èä∑?éÁ¥∞
ALTER TABLE reca_t ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS reca_policy ON reca_t;
CREATE POLICY reca_policy ON reca_t FOR ALL TO authenticated
  USING (is_auth_user_admin() OR recaent = get_auth_user_ent())
  WITH CHECK (is_auth_user_admin() OR recaent = get_auth_user_ent());
