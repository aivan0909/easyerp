const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('錯誤: 請在 .env 檔案中設定 SUPABASE_URL 與 SUPABASE_SERVICE_ROLE_KEY (或 SUPABASE_SERVICE_KEY)');
  process.exit(1);
}

// 建立 service_role client，以便繞過 RLS 來清理和初始化測試資料
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: { persistSession: false }
});

const ENT = 1;
const USER_ID = 'test-runner-user';

async function clearOldData() {
  console.log('正在清理舊測試資料...');

  // 1. 核銷/異動表
  await supabase.from('reca_t').delete().eq('recaent', ENT).like('reca002', '%-TEST-%');
  await supabase.from('inag_t').delete().eq('inagent', ENT).like('inag005', '%-TEST-%');
  
  // 2. 應收/應付帳款表
  await supabase.from('xrcb_t').delete().eq('xrcbent', ENT).like('xrcbdocno', 'AR-%');
  await supabase.from('xrca_t').delete().eq('xrcaent', ENT).like('xrca002', 'SH-TEST-%');
  await supabase.from('apcb_t').delete().eq('apcbent', ENT).like('apcbdocno', 'AP-%');
  await supabase.from('apca_t').delete().eq('apcaent', ENT).like('apca002', 'GR-TEST-%');

  // 3. 出貨單單身/單頭
  await supabase.from('xmdl_t').delete().eq('xmdlent', ENT).like('xmdldocno', 'SH-TEST-%');
  await supabase.from('xmdk_t').delete().eq('xmdkent', ENT).like('xmdkdocno', 'SH-TEST-%');

  // 4. 收貨單單身/單頭
  await supabase.from('pmdt_t').delete().eq('pmdtent', ENT).like('pmdtdocno', 'GR-TEST-%');
  await supabase.from('pmds_t').delete().eq('pmdsent', ENT).like('pmdsdocno', 'GR-TEST-%');

  // 5. 銷貨訂單單身/單頭
  await supabase.from('xmdc_t').delete().eq('xmdcent', ENT).like('xmdcdocno', 'SO-TEST-%');
  await supabase.from('xmda_t').delete().eq('xmdaent', ENT).like('xmdadocno', 'SO-TEST-%');

  // 6. 採購單單身/單頭
  await supabase.from('pmdn_t').delete().eq('pmdnent', ENT).like('pmdndocno', 'PO-TEST-%');
  await supabase.from('pmdl_t').delete().eq('pmdlent', ENT).like('pmdldocno', 'PO-TEST-%');

  // 7. 庫存彙總表
  await supabase.from('inaj_t').delete().eq('inajent', ENT).eq('inaj001', 'SKU-20114');

  // 8. 主檔資料
  await supabase.from('imaa_t').delete().eq('imaaent', ENT).eq('imaacode', 'SKU-20114');
  await supabase.from('cusa_t').delete().eq('cusaent', ENT).eq('cusacode', 'C001');
  await supabase.from('vnda_t').delete().eq('vndaent', ENT).eq('vndacode', 'V001');
  await supabase.from('inaa_t').delete().eq('inaaent', ENT).eq('inaacode', 'W001');

  console.log('舊資料清理完畢！');
}

async function initMasterData() {
  console.log('正在初始化主檔資料...');

  // 1. 商品
  await supabase.from('imaa_t').insert({
    imaaent: ENT, imaacode: 'SKU-20114', imaa001: '測試商品 A', imaa004: '片', imaa005: 8, imaa006: 10
  });

  // 2. 客戶
  await supabase.from('cusa_t').insert({
    cusaent: ENT, cusacode: 'C001', cusa001: '測試客戶'
  });

  // 3. 供應商
  await supabase.from('vnda_t').insert({
    vndaent: ENT, vndacode: 'V001', vnda001: '測試供應商'
  });

  // 4. 倉庫
  await supabase.from('inaa_t').insert({
    inaaent: ENT, inaacode: 'W001', inaa001: '主要倉庫'
  });

  // 5. 設定 SKU-20114 在 W001 的初始庫存為 100 片
  await supabase.from('inaj_t').insert({
    inajent: ENT, inaj001: 'SKU-20114', inaj002: 'W001', inaj003: 100, inaj004: 0, inaj005: 0
  });

  console.log('主檔資料初始化成功！初始庫存已設為 100 片。');
}

async function testScenario1() {
  console.log('\n--- 情境 1: 確認出貨成功 (扣庫存 30, 核銷, 產生應收) ---');

  // 建立訂單 SO-TEST-0001
  await supabase.from('xmda_t').insert({
    xmdaent: ENT, xmdadocno: 'SO-TEST-0001', xmda004: 'C001', xmda002: '測試人員', xmdastatus: '1'
  });
  await supabase.from('xmdc_t').insert({
    xmdcent: ENT, xmdcdocno: 'SO-TEST-0001', xmdcseq: 1, xmdc001: 'SKU-20114', xmdc002: 30, xmdc003: 10, xmdc004: 300
  });

  // 建立出貨單 SH-TEST-0001
  await supabase.from('xmdk_t').insert({
    xmdkent: ENT, xmdkdocno: 'SH-TEST-0001', xmdk004: 'C001', xmdk005: 'SO-TEST-0001', xmdk006: 'W001', xmdkstatus: '0'
  });
  await supabase.from('xmdl_t').insert({
    xmdlent: ENT, xmdldocno: 'SH-TEST-0001', xmdlseq: 1, xmdl001: 'SKU-20114', xmdl002: 30, xmdl003: 10, xmdl004: 300, xmdl005: 1
  });

  // 執行 RPC confirm_shipment
  console.log('正在呼叫 confirm_shipment RPC...');
  const { data, error } = await supabase.rpc('confirm_shipment', {
    p_ent: ENT,
    p_docno: 'SH-TEST-0001',
    p_user: USER_ID
  });

  if (error) {
    throw new Error(`情境 1 失敗: ${error.message}`);
  }

  console.log('RPC 傳回結果:', data);

  // 驗證庫存是否扣除
  const { data: stock } = await supabase.from('inaj_t').select('inaj003').eq('inajent', ENT).eq('inaj001', 'SKU-20114').eq('inaj002', 'W001').single();
  console.log(`驗證庫存剩餘量 (應為 70): ${stock.inaj003}`);
  if (parseFloat(stock.inaj003) !== 70) throw new Error('庫存扣除數量不正確');

  // 驗證銷貨訂單已出貨數量
  const { data: orderLine } = await supabase.from('xmdc_t').select('xmdc005').eq('xmdcent', ENT).eq('xmdcdocno', 'SO-TEST-0001').eq('xmdcseq', 1).single();
  console.log(`驗證訂單已出貨數量 (應為 30): ${orderLine.xmdc005}`);
  if (parseFloat(orderLine.xmdc005) !== 30) throw new Error('訂單已出貨數量回寫不正確');

  // 驗證應收單是否存在
  const { data: ar } = await supabase.from('xrca_t').select('xrcadocno, xrca003').eq('xrcaent', ENT).eq('xrca002', 'SH-TEST-0001').single();
  console.log(`驗證應收單已產生，單號: ${ar.xrcadocno}, 金額 (應為 300): ${ar.xrca003}`);
  if (parseFloat(ar.xrca003) !== 300) throw new Error('應收單金額不正確');

  console.log('✅ 情境 1 驗證通過！');
}

async function testScenario2() {
  console.log('\n--- 情境 2: 確認出貨-庫存不足 (出貨 200, 應 Rollback) ---');

  // 建立訂單 SO-TEST-0002
  await supabase.from('xmda_t').insert({
    xmdaent: ENT, xmdadocno: 'SO-TEST-0002', xmda004: 'C001', xmda002: '測試人員', xmdastatus: '1'
  });
  await supabase.from('xmdc_t').insert({
    xmdcent: ENT, xmdcdocno: 'SO-TEST-0002', xmdcseq: 1, xmdc001: 'SKU-20114', xmdc002: 200, xmdc003: 10, xmdc004: 2000
  });

  // 建立出貨單 SH-TEST-0002
  await supabase.from('xmdk_t').insert({
    xmdkent: ENT, xmdkdocno: 'SH-TEST-0002', xmdk004: 'C001', xmdk005: 'SO-TEST-0002', xmdk006: 'W001', xmdkstatus: '0'
  });
  await supabase.from('xmdl_t').insert({
    xmdlent: ENT, xmdldocno: 'SH-TEST-0002', xmdlseq: 1, xmdl001: 'SKU-20114', xmdl002: 200, xmdl003: 10, xmdl004: 2000, xmdl005: 1
  });

  // 執行 RPC confirm_shipment，預期拋出 STOCK_INSUFFICIENT 錯誤
  console.log('正在呼叫 confirm_shipment RPC (出貨量 200)...');
  const { data, error } = await supabase.rpc('confirm_shipment', {
    p_ent: ENT,
    p_docno: 'SH-TEST-0002',
    p_user: USER_ID
  });

  if (error) {
    console.log(`攔截到預期中的錯誤: ${error.message}`);
    if (error.message.includes('STOCK_INSUFFICIENT')) {
      console.log('符合庫存不足錯誤類型！');
    } else {
      throw new Error(`拋出了非預期的錯誤: ${error.message}`);
    }
  } else {
    throw new Error('情境 2 失敗: 庫存不足卻出貨成功，沒有正常 Rollback！');
  }

  // 驗證庫存是否維持 70
  const { data: stock } = await supabase.from('inaj_t').select('inaj003').eq('inajent', ENT).eq('inaj001', 'SKU-20114').eq('inaj002', 'W001').single();
  console.log(`驗證庫存量是否依然為 70: ${stock.inaj003}`);
  if (parseFloat(stock.inaj003) !== 70) throw new Error('庫存受影響，沒有正確 Rollback');

  // 驗證出貨單狀態是否依然為 '0' (草稿)
  const { data: sh } = await supabase.from('xmdk_t').select('xmdkstatus').eq('xmdkent', ENT).eq('xmdkdocno', 'SH-TEST-0002').single();
  console.log(`驗證出貨單狀態 (應為 0): ${sh.xmdkstatus}`);
  if (sh.xmdkstatus !== '0') throw new Error('出貨單狀態被更改，沒有正確 Rollback');

  console.log('✅ 情境 2 驗證通過！');
}

async function testScenario3() {
  console.log('\n--- 情境 3: 確認收貨成功 (加庫存 50, 核銷, 產生應付) ---');

  // 建立採購單 PO-TEST-0001
  await supabase.from('pmdl_t').insert({
    pmdlent: ENT, pmdldocno: 'PO-TEST-0001', pmdl004: 'V001', pmdlstatus: '1'
  });
  await supabase.from('pmdn_t').insert({
    pmdnent: ENT, pmdndocno: 'PO-TEST-0001', pmdnseq: 1, pmdn001: 'SKU-20114', pmdn002: 50, pmdn003: 8, pmdn004: 400
  });

  // 建立收貨單 GR-TEST-0001
  await supabase.from('pmds_t').insert({
    pmdsent: ENT, pmdsdocno: 'GR-TEST-0001', pmds002: 'PO-TEST-0001', pmds003: 'V001', pmds004: 'W001', pmdsstatus: '0'
  });
  await supabase.from('pmdt_t').insert({
    pmdtent: ENT, pmdtdocno: 'GR-TEST-0001', pmdtseq: 1, pmdt001: 'SKU-20114', pmdt002: 50, pmdt003: 50, pmdt004: 8, pmdt005: 400, pmdt006: 1
  });

  // 執行 RPC confirm_goods_receipt
  console.log('正在呼叫 confirm_goods_receipt RPC...');
  const { data, error } = await supabase.rpc('confirm_goods_receipt', {
    p_ent: ENT,
    p_docno: 'GR-TEST-0001',
    p_user: USER_ID
  });

  if (error) {
    throw new Error(`情境 3 失敗: ${error.message}`);
  }

  console.log('RPC 傳回結果:', data);

  // 驗證庫存是否增加 (70 + 50 = 120)
  const { data: stock } = await supabase.from('inaj_t').select('inaj003').eq('inajent', ENT).eq('inaj001', 'SKU-20114').eq('inaj002', 'W001').single();
  console.log(`驗證庫存剩餘量 (應為 120): ${stock.inaj003}`);
  if (parseFloat(stock.inaj003) !== 120) throw new Error('庫存增加數量不正確');

  // 驗證採購單已入庫數量
  const { data: poLine } = await supabase.from('pmdn_t').select('pmdn005').eq('pmdnent', ENT).eq('pmdndocno', 'PO-TEST-0001').eq('pmdnseq', 1).single();
  console.log(`驗證採購已入庫數量 (應為 50): ${poLine.pmdn005}`);
  if (parseFloat(poLine.pmdn005) !== 50) throw new Error('採購單入庫數量回寫不正確');

  // 驗證應付單是否存在
  const { data: ap } = await supabase.from('apca_t').select('apcadocno, apca003').eq('apcaent', ENT).eq('apca002', 'GR-TEST-0001').single();
  console.log(`驗證應付單已產生，單號: ${ap.apcadocno}, 金額 (應為 400): ${ap.apca003}`);
  if (parseFloat(ap.apca003) !== 400) throw new Error('應付單金額不正確');

  console.log('✅ 情境 3 驗證通過！');
}

async function testScenario4() {
  console.log('\n--- 情境 4: 確認收貨-超收 (收貨 60 遠超採購 50, 應 Rollback) ---');

  // 建立採購單 PO-TEST-0002
  await supabase.from('pmdl_t').insert({
    pmdlent: ENT, pmdldocno: 'PO-TEST-0002', pmdl004: 'V001', pmdlstatus: '1'
  });
  await supabase.from('pmdn_t').insert({
    pmdnent: ENT, pmdndocno: 'PO-TEST-0002', pmdnseq: 1, pmdn001: 'SKU-20114', pmdn002: 50, pmdn003: 8, pmdn004: 400
  });

  // 建立收貨單 GR-TEST-0002
  await supabase.from('pmds_t').insert({
    pmdsent: ENT, pmdsdocno: 'GR-TEST-0002', pmds002: 'PO-TEST-0002', pmds003: 'V001', pmds004: 'W001', pmdsstatus: '0'
  });
  await supabase.from('pmdt_t').insert({
    pmdtent: ENT, pmdtdocno: 'GR-TEST-0002', pmdtseq: 1, pmdt001: 'SKU-20114', pmdt002: 60, pmdt003: 60, pmdt004: 8, pmdt005: 480, pmdt006: 1
  });

  // 執行 RPC confirm_goods_receipt，預期拋出 QTY_EXCEED_SOURCE 錯誤
  console.log('正在呼叫 confirm_goods_receipt RPC (收貨量 60)...');
  const { data, error } = await supabase.rpc('confirm_goods_receipt', {
    p_ent: ENT,
    p_docno: 'GR-TEST-0002',
    p_user: USER_ID
  });

  if (error) {
    console.log(`攔截到預期中的錯誤: ${error.message}`);
    if (error.message.includes('QTY_EXCEED_SOURCE')) {
      console.log('符合收貨量超收錯誤類型！');
    } else {
      throw new Error(`拋出了非預期的錯誤: ${error.message}`);
    }
  } else {
    throw new Error('情境 4 失敗: 收貨超量卻收貨成功，沒有正常 Rollback！');
  }

  // 驗證庫存是否維持 120
  const { data: stock } = await supabase.from('inaj_t').select('inaj003').eq('inajent', ENT).eq('inaj001', 'SKU-20114').eq('inaj002', 'W001').single();
  console.log(`驗證庫存量是否依然為 120: ${stock.inaj003}`);
  if (parseFloat(stock.inaj003) !== 120) throw new Error('庫存受影響，沒有正確 Rollback');

  // 驗證收貨單狀態是否依然為 '0' (草稿)
  const { data: gr } = await supabase.from('pmds_t').select('pmdsstatus').eq('pmdsent', ENT).eq('pmdsdocno', 'GR-TEST-0002').single();
  console.log(`驗證收貨單狀態 (應為 0): ${gr.pmdsstatus}`);
  if (gr.pmdsstatus !== '0') throw new Error('收貨單狀態被更改，沒有正確 Rollback');

  console.log('✅ 情境 4 驗證通過！');
}

async function run() {
  try {
    await clearOldData();
    await initMasterData();

    await testScenario1();
    await testScenario2();
    await testScenario3();
    await testScenario4();

    console.log('\n=======================================');
    console.log('🎉 恭喜！所有情境測試全部通過且與預期結果一致！');
    console.log('=======================================');
  } catch (err) {
    console.error('\n❌ 測試執行失敗:', err.message);
    process.exit(1);
  }
}

run();
