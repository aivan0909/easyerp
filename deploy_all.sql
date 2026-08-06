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
  xmdacnfid  varchar(20), xmdacnfdt timestamptz,
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
  xmdkcnfid  varchar(20), xmdkcnfdt timestamptz,
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
  pmdl004    varchar(20),  -- ‰æõÊ??ÜÁ∑®??  pmdlcnfid  varchar(20), pmdlcnfdt timestamptz,
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
  pmdscnfid  varchar(20), pmdscnfdt timestamptz,
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
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer,
  p_category varchar DEFAULT '?∑Ë≤®?∫Ë≤®'
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
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, p_category, p_src_doc_type, p_src_doc_no, p_src_doc_seq, '-', p_qty, v_new_balance);

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
  p_src_doc_type varchar, p_src_doc_no varchar, p_src_doc_seq integer,
  p_category varchar DEFAULT '?°Ë≥º?•Â∫´'
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
  VALUES (p_ent, v_inagdocno, p_item_code, p_wh_code, p_category, p_src_doc_type, p_src_doc_no, p_src_doc_seq, '+', p_qty, v_new_balance);

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
-- migration_void.sql ??Ë£ú‰??åÂ?Ê∂àÁ¢∫Ë™?‰ΩúÂª¢?çÂ??ΩÊ??ÄÊ¨Ñ‰?
-- ?®ÁΩ≤?ÜÂ?Ôºöschema.sql -> functions.sql -> migration_void.sql -> void_functions.sql
-- ============================================================

-- ?∂Ë≤®?ÆÈ†≠ÔºöË?‰ΩúÂª¢??‰ΩúÂª¢?ÇÈ?
ALTER TABLE pmds_t ADD COLUMN IF NOT EXISTS pmdsvoidid  varchar(20);
ALTER TABLE pmds_t ADD COLUMN IF NOT EXISTS pmdsvoiddt  timestamptz;

-- ?∫Ë≤®?ÆÈ†≠ÔºöË?‰ΩúÂª¢??‰ΩúÂª¢?ÇÈ?(Â∞çÁ®±)
ALTER TABLE xmdk_t ADD COLUMN IF NOT EXISTS xmdkvoidid  varchar(20);
ALTER TABLE xmdk_t ADD COLUMN IF NOT EXISTS xmdkvoiddt  timestamptz;

-- ?â‰?Â∏≥Ê¨æ?ÆÈ†≠ÔºöÂ???demo ?àÁ≤æÁ∞°Ê?‰∫?statusÔºåÈÄôË£°Ë£ú‰?
ALTER TABLE apca_t ADD COLUMN IF NOT EXISTS apcastatus  varchar(10) DEFAULT '1';

-- ?âÊî∂Â∏≥Ê¨æ?ÆÈ†≠ÔºöÂ?‰∏äÔ?Ë£ú‰? status(Â∞çÁ®±)
ALTER TABLE xrca_t ADD COLUMN IF NOT EXISTS xrcastatus  varchar(10) DEFAULT '1';

-- ?∑Ë≤®Ë®ÇÂñÆ?≠Ô?Ë£ú‰?Âª¢ËÄ?‰ΩúÂª¢?ÇÈ?
ALTER TABLE xmda_t ADD COLUMN IF NOT EXISTS xmdavoidid  varchar(80);
ALTER TABLE xmda_t ADD COLUMN IF NOT EXISTS xmdavoiddt  timestamptz;

-- ?°Ë≥º?ÆÈ†≠ÔºöË?‰ΩúÂª¢??‰ΩúÂª¢?ÇÈ?(Â∞çÁ®±)
ALTER TABLE pmdl_t ADD COLUMN IF NOT EXISTS pmdlvoidid  varchar(80);
ALTER TABLE pmdl_t ADD COLUMN IF NOT EXISTS pmdlvoiddt  timestamptz;
-- ============================================================
-- void_functions.sql ???ñÊ?Á¢∫Ë?/‰ΩúÂª¢?üËÉΩ
-- ?®ÁΩ≤?ÜÂ?Ôºöschema.sql -> functions.sql -> migration_void.sql -> void_functions.sql
--
-- Ë®≠Ë??üÂ?Ôº?--   1. ‰∏çÂ?ÂØ¶È??™Èô§Ôºå‰?ÂæãÁî® status='9'(‰ΩúÂª¢) Ê®ôË?Ôºå‰??ôÁ®Ω?∏Ë?Ë∑?--   2. ?©È?ÊÆµÊ™¢?•Ô??àÊ??¥Âºµ?ÆÊ?‰∏ÄË°åÈÉΩÊ™¢Êü•?éÔ??®ÈÉ®?öÈ??çÁ?Ê≠?ü∑Ë°åÈ??üÔ?
--      ?øÂ??åÊâ£‰∏Ä?äÊ??ºÁèæ‰∏çËÉΩ?ñÊ???--   3. ?§Êñ∑?ØÂê¶?ñÊ??ÑÊ?‰ª∂ÊòØ?åÁèæ?âÂ∫´Â≠????∂Â??∞Â??∏È??çÔ?‰∏çÁâπ?•Â???--      ?†Ê?Â∫´Â?ËÆäÂ??ÑÂ????∫Ë≤®/Ë™øÊï¥/?∂‰?)ÔºåÊ∂µ?ãÁ??çÊõ¥ÂÆåÊï¥‰πüÊõ¥‰∏çÊ??âÊ?Ê¥?--   4. ?•Â??âÁ??âÊî∂/?â‰?Â∏≥Ê¨æÂ∑≤Ê??∂‰?Ê¨æÁ??ÑÔ?‰∏ÄÂæã‰??ÅË®±?ñÊ?Ôº?--      ?Ä?πËµ∞?ÄË≤??òË?Á≠âÊ≠£ÂºèÊ?Á®?-- ============================================================

-- ------------------------------------------------------------
-- 1. ?ñÊ?Á¢∫Ë??∂Ë≤®?ÆÔ?Â∞çÊ?ÔºöÊé°Ë≥?-> ?∂Ë≤® -> ?â‰? ?ôÊ?Á∑öÔ?
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_goods_receipt(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header  pmds_t%ROWTYPE;
  v_line    pmdt_t%ROWTYPE;
  v_ap      apca_t%ROWTYPE;
  v_current numeric;
  v_reca    reca_t%ROWTYPE;
  v_voided_count integer := 0;
BEGIN
  SELECT * INTO v_header FROM pmds_t WHERE pmdsent = p_ent AND pmdsdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: ?∂Ë≤®?Æ‰?Â≠òÂú® %', p_docno;
  END IF;
  IF v_header.pmdsstatus <> '1' THEN
    RAISE EXCEPTION 'DOC_NOT_CONFIRMED: ?™Ê?Â∑≤Á¢∫Ë™çÁ??∂Ë≤®?ÆÊ??ΩÂ?Ê∂??ÆÂ??Ä??%)', v_header.pmdsstatus;
  END IF;

  -- Ê™¢Êü•Â∞çÊ??â‰?Â∏≥Ê¨æ?ÆÊòØ?¶Â∑≤?â‰?Ê¨?  SELECT * INTO v_ap FROM apca_t WHERE apcaent = p_ent AND apca002 = p_docno FOR UPDATE;
  IF FOUND AND v_ap.apca004 > 0.0001 THEN
    RAISE EXCEPTION 'AP_ALREADY_PAID: Â∞çÊ??â‰?Â∏≥Ê¨æ??%)Â∑≤Ê?‰ªòÊ¨æÁ¥Ä??Â∑≤‰? %)ÔºåÁÑ°Ê≥ïÂ?Ê∂àÊî∂Ë≤®Ô?Ë´ãÊîπ?®ÈÄÄË≤®Ê?Á®?, v_ap.apcadocno, v_ap.apca004;
  END IF;

  -- Á¨¨‰?Ëº™Ô??êË?Ê™¢Êü•Â∫´Â??ØÂê¶Ë∂≥Â????(Ê≠§ÊâπË≤®Â??®Ê?Ë¢´Â??®È?)
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    SELECT inaj003 INTO v_current FROM inaj_t
    WHERE inajent = p_ent AND inaj001 = v_line.pmdt001 AND inaj002 = v_header.pmds004
    FOR UPDATE;

    IF v_current IS NULL OR v_current < v_line.pmdt003 - 0.0001 THEN
      RAISE EXCEPTION 'STOCK_ALREADY_CONSUMED: ?ÜÂ? % ?ÆÂ?Â∫´Â?(%)‰∏çË∂≥‰ª•Êâ£?ûÁï∂?ùÊî∂Ë≤®Êï∏??%)ÔºåÊ≠§?πË≤®Â∑≤Ë¢´?ïÁî®ÔºåÁÑ°Ê≥ïÁõ¥?•Â?Ê∂àÔ?Ë´ãÊîπ?®ÈÄÄË≤®Ê?Á®?,
        v_line.pmdt001, coalesce(v_current, 0), v_line.pmdt003;
    END IF;
  END LOOP;

  -- Á¨¨‰?Ëº™Ô??®ÈÉ®?öÈ?Ê™¢Êü•ÔºåÊ??üÊ≠£?∑Ë??ÑÂ?
  FOR v_line IN SELECT * FROM pmdt_t WHERE pmdtent = p_ent AND pmdtdocno = p_docno ORDER BY pmdtseq
  LOOP
    -- ?çÂ?Â∫´Â??∞Â?(???)
    PERFORM fn_stock_out(p_ent, v_line.pmdt001, v_header.pmds004, v_line.pmdt003, 'GR_VOID', p_docno, v_line.pmdtseq);

    -- ?æÂà∞Â∞çÊ??∏Èä∑Á¥Ä?ÑÔ?Ê®ôË?‰ΩúÂª¢Ôºå‰∏¶?ûÊ??°Ë≥º?ÆÂ∑≤?•Â∫´?∏È?
    SELECT * INTO v_reca FROM reca_t
    WHERE recaent = p_ent AND reca004 = 'GR' AND reca005 = p_docno AND reca006 = v_line.pmdtseq;

    IF FOUND THEN
      UPDATE reca_t SET reca012 = '9' WHERE recaent = p_ent AND recadocno = v_reca.recadocno;
      UPDATE pmdn_t SET pmdn005 = pmdn005 - v_reca.reca008
      WHERE pmdnent = p_ent AND pmdndocno = v_reca.reca002 AND pmdnseq = v_reca.reca003;
      v_voided_count := v_voided_count + 1;
    END IF;
  END LOOP;

  -- ‰ΩúÂª¢?∂Ë≤®??  UPDATE pmds_t SET pmdsstatus = '9', pmdsvoidid = p_user, pmdsvoiddt = now()
  WHERE pmdsent = p_ent AND pmdsdocno = p_docno;

  -- ‰∏Ä‰Ωµ‰?Âª¢Â??âÊ?‰ªòÂ∏≥Ê¨æÂñÆ(?çÈù¢Â∑≤Á¢∫Ë™çÊú™‰ªòÊ¨æÔºåÂèØÂÆâÂÖ®‰ΩúÂª¢)
  IF v_ap.apcadocno IS NOT NULL THEN
    UPDATE apca_t SET apcastatus = '9' WHERE apcaent = p_ent AND apcadocno = v_ap.apcadocno;
  END IF;

  RETURN jsonb_build_object(
    'docno', p_docno, 'status', 'voided',
    'reconciliationVoided', v_voided_count,
    'payableVoided', v_ap.apcadocno
  );
END;
$$;

-- ------------------------------------------------------------
-- 2. ?ñÊ?Á¢∫Ë??∫Ë≤®?ÆÔ?Â∞çÁ®±ÔºöÈä∑Ë≤?-> ?∫Ë≤® -> ?âÊî∂ ?ôÊ?Á∑öÔ?
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_shipment(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header  xmdk_t%ROWTYPE;
  v_line    xmdl_t%ROWTYPE;
  v_ar      xrca_t%ROWTYPE;
  v_reca    reca_t%ROWTYPE;
  v_voided_count integer := 0;
BEGIN
  SELECT * INTO v_header FROM xmdk_t WHERE xmdkent = p_ent AND xmdkdocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: ?∫Ë≤®?Æ‰?Â≠òÂú® %', p_docno;
  END IF;
  IF v_header.xmdkstatus <> '1' THEN
    RAISE EXCEPTION 'DOC_NOT_CONFIRMED: ?™Ê?Â∑≤Á¢∫Ë™çÁ??∫Ë≤®?ÆÊ??ΩÂ?Ê∂??ÆÂ??Ä??%)', v_header.xmdkstatus;
  END IF;

  -- ?∫Ë≤®?ÑÈ??üÊòØ?åÂ??ûÂ∫´Â≠ò„ÄçÔ?‰∏çÈ?Ë¶ÅÊ™¢?•Â∫´Â≠òÊòØ?¶Ë∂≥Â§??ôÈ?Ë∑üÊî∂Ë≤®Â?Ê∂à‰??åÔ?
  -- ?†Â∫´Â≠òÊ∞∏?†ÂèØ‰ª•Âü∑Ë°?Ôºå‰?Ë¶ÅÊ™¢?•Â??âÊ??∂Â∏≥Ê¨æÊòØ?¶Â∑≤?∂Ê¨æ
  SELECT * INTO v_ar FROM xrca_t WHERE xrcaent = p_ent AND xrca002 = p_docno FOR UPDATE;
  IF FOUND AND v_ar.xrca004 > 0.0001 THEN
    RAISE EXCEPTION 'AR_ALREADY_PAID: Â∞çÊ??âÊî∂Â∏≥Ê¨æ??%)Â∑≤Ê??∂Ê¨æÁ¥Ä??Â∑≤Êî∂ %)ÔºåÁÑ°Ê≥ïÂ?Ê∂àÂá∫Ë≤®Ô?Ë´ãÊîπ?®ÈÄÄË≤®Ê?Á®?, v_ar.xrcadocno, v_ar.xrca004;
  END IF;

  FOR v_line IN SELECT * FROM xmdl_t WHERE xmdlent = p_ent AND xmdldocno = p_docno ORDER BY xmdlseq
  LOOP
    -- ?çÂ?Â∫´Â??∞Â?(?†Â?)
    PERFORM fn_stock_in(p_ent, v_line.xmdl001, v_header.xmdk006, v_line.xmdl002, 'SH_VOID', p_docno, v_line.xmdlseq);

    -- ?æÂà∞Â∞çÊ??∏Èä∑Á¥Ä?ÑÔ?Ê®ôË?‰ΩúÂª¢Ôºå‰∏¶?ûÊ?Ë®ÇÂñÆÂ∑≤Âá∫Ë≤®Êï∏??    SELECT * INTO v_reca FROM reca_t
    WHERE recaent = p_ent AND reca004 = 'SH' AND reca005 = p_docno AND reca006 = v_line.xmdlseq;

    IF FOUND THEN
      UPDATE reca_t SET reca012 = '9' WHERE recaent = p_ent AND recadocno = v_reca.recadocno;
      UPDATE xmdc_t SET xmdc005 = xmdc005 - v_reca.reca008
      WHERE xmdcent = p_ent AND xmdcdocno = v_reca.reca002 AND xmdcseq = v_reca.reca003;
      v_voided_count := v_voided_count + 1;
    END IF;
  END LOOP;

  UPDATE xmdk_t SET xmdkstatus = '9', xmdkvoidid = p_user, xmdkvoiddt = now()
  WHERE xmdkent = p_ent AND xmdkdocno = p_docno;

  IF v_ar.xrcadocno IS NOT NULL THEN
    UPDATE xrca_t SET xrcastatus = '9' WHERE xrcaent = p_ent AND xrcadocno = v_ar.xrcadocno;
  END IF;

  RETURN jsonb_build_object(
    'docno', p_docno, 'status', 'voided',
    'reconciliationVoided', v_voided_count,
    'receivableVoided', v_ar.xrcadocno
  );
END;
$$;

-- ------------------------------------------------------------
-- 3. ?ñÊ?Á¢∫Ë??∑Ë≤®Ë®ÇÂñÆ
--    ?™Ê™¢?•Â?‰∏ãÊ?Ê≤íÊ??ÑÂú®?üÊ?‰∏??û‰?Âª??ÑÂá∫Ë≤®ÂñÆÂºïÁî®ÂÆÉÔ?
--    ‰∏çÊ??äÂ∫´Â≠òÈ???Ë®ÇÂñÆ?¨Ë∫´‰∏çÂΩ±?øÂ∫´Â≠òÔ??∫Ë≤®?çÂΩ±??
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_sales_order(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header xmda_t%ROWTYPE;
  v_active_count integer;
BEGIN
  SELECT * INTO v_header FROM xmda_t WHERE xmdaent = p_ent AND xmdadocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Ë®ÇÂñÆ‰∏çÂ???%', p_docno;
  END IF;
  IF v_header.xmdastatus = '9' THEN
    RAISE EXCEPTION 'ALREADY_VOIDED: Ê≠§Ë??ÆÂ∑≤Á∂ì‰?Âª¢È?‰∫?;
  END IF;

  SELECT count(*) INTO v_active_count FROM xmdk_t
  WHERE xmdkent = p_ent AND xmdk005 = p_docno AND xmdkstatus <> '9';

  IF v_active_count > 0 THEN
    RAISE EXCEPTION 'HAS_ACTIVE_SHIPMENT: Ê≠§Ë??ÆÂ?‰∏ãÈ???% ÂºµÁ??à‰∏≠?ÑÂá∫Ë≤®ÂñÆÔºåË??àÂ?Ê∂?‰ΩúÂª¢????∫Ë≤®?ÆÊ??ΩÂ?Ê∂àÊ≠§Ë®ÇÂñÆ', v_active_count;
  END IF;

  UPDATE xmda_t SET xmdastatus = '9', xmdavoidid = p_user, xmdavoiddt = now()
  WHERE xmdaent = p_ent AND xmdadocno = p_docno;

  RETURN jsonb_build_object('docno', p_docno, 'status', 'voided');
END;
$$;

-- ------------------------------------------------------------
-- 4. ?ñÊ?Á¢∫Ë??°Ë≥º??Â∞çÁ®±)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION void_purchase_order(p_ent integer, p_docno varchar, p_user varchar)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_header pmdl_t%ROWTYPE;
  v_active_count integer;
BEGIN
  SELECT * INTO v_header FROM pmdl_t WHERE pmdlent = p_ent AND pmdldocno = p_docno FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: ?°Ë≥º?Æ‰?Â≠òÂú® %', p_docno;
  END IF;
  IF v_header.pmdlstatus = '9' THEN
    RAISE EXCEPTION 'ALREADY_VOIDED: Ê≠§Êé°Ë≥ºÂñÆÂ∑≤Á?‰ΩúÂª¢?é‰?';
  END IF;

  SELECT count(*) INTO v_active_count FROM pmds_t
  WHERE pmdsent = p_ent AND pmds002 = p_docno AND pmdsstatus <> '9';

  IF v_active_count > 0 THEN
    RAISE EXCEPTION 'HAS_ACTIVE_RECEIPT: Ê≠§Êé°Ë≥ºÂñÆÂ∫ï‰??ÑÊ? % ÂºµÁ??à‰∏≠?ÑÊî∂Ë≤®ÂñÆÔºåË??àÂ?Ê∂?‰ΩúÂª¢????∂Ë≤®?ÆÊ??ΩÂ?Ê∂àÊ≠§?°Ë≥º??, v_active_count;
  END IF;

  UPDATE pmdl_t SET pmdlstatus = '9', pmdlvoidid = p_user, pmdlvoiddt = now()
  WHERE pmdlent = p_ent AND pmdldocno = p_docno;

  RETURN jsonb_build_object('docno', p_docno, 'status', 'voided');
END;
$$;

-- ------------------------------------------------------------
-- 5. Áµ¶Â?Á´ØÂ?Ë°®Áî®?Ñ„ÄåÊ??§‰?Âª¢„ÄçView
--    Antigravity ?ãÁôº?óË°®?´Èù¢?ÇÂª∫Ë≠∞Êü•?ô‰? View ?åÈ??üÂ?Ë°®Ô?
--    ?ôÊ®£‰ΩúÂª¢?ÑÂñÆ?öÂ∞±‰∏çÊ??∫Áèæ?®Áï´?¢‰?Ôºå‰??®Ê??ãÊü•Ë©¢ÈÉΩ?ãÂ???WHERE status<>'9'
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW xmda_active_v WITH (security_invoker = true) AS SELECT * FROM xmda_t WHERE xmdastatus <> '9';
CREATE OR REPLACE VIEW xmdk_active_v WITH (security_invoker = true) AS SELECT * FROM xmdk_t WHERE xmdkstatus <> '9';
CREATE OR REPLACE VIEW pmdl_active_v WITH (security_invoker = true) AS SELECT * FROM pmdl_t WHERE pmdlstatus <> '9';
CREATE OR REPLACE VIEW pmds_active_v WITH (security_invoker = true) AS SELECT * FROM pmds_t WHERE pmdsstatus <> '9';
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
