import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { FileText, ArrowDownLeft, CreditCard, Plus, CheckCircle, AlertCircle, Trash2 } from 'lucide-react';

export default function Purchases({ userDetails }) {
  const [activeTab, setActiveTab] = useState('orders'); // orders, receipts, payables
  const [orders, setOrders] = useState([]);
  const [receipts, setReceipts] = useState([]);
  const [payables, setPayables] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  // 主檔資料
  const [vendors, setVendors] = useState([]);
  const [items, setItems] = useState([]);
  const [warehouses, setWarehouses] = useState([]);

  // 表單控制
  const [showOrderModal, setShowOrderModal] = useState(false);
  const [newOrder, setNewOrder] = useState({ vendor: '', items: [{ code: '', qty: 1, price: 0 }] });

  const [showReceiptModal, setShowReceiptModal] = useState(false);
  const [newReceipt, setNewReceipt] = useState({ vendor: '', sourceOrder: '', warehouse: '', items: [] });

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    fetchData();
    fetchMasterData();
  }, [ent, isAdmin, activeTab]);

  async function fetchData() {
    setLoading(true);
    setErrorMsg('');
    try {
      if (activeTab === 'orders') {
        let q = supabase.from('pmdl_active_v').select('*').order('pmdldocdt', { ascending: false });
        if (!isAdmin) q = q.eq('pmdlent', ent);
        const { data: purchaseOrders } = await q;

        // 明細
        const ordersWithLines = await Promise.all((purchaseOrders || []).map(async (order) => {
          let lineQ = supabase.from('pmdn_t').select('*').eq('pmdndocno', order.pmdldocno);
          if (!isAdmin) lineQ = lineQ.eq('pmdnent', ent);
          const { data: lines } = await lineQ;
          return { ...order, lines: lines || [] };
        }));
        setOrders(ordersWithLines);
      } else if (activeTab === 'receipts') {
        let q = supabase.from('pmds_active_v').select('*').order('pmdsdocdt', { ascending: false });
        if (!isAdmin) q = q.eq('pmdsent', ent);
        const { data: grList } = await q;

        // 明細
        const grWithLines = await Promise.all((grList || []).map(async (gr) => {
          let lineQ = supabase.from('pmdt_t').select('*').eq('pmdtdocno', gr.pmdsdocno);
          if (!isAdmin) lineQ = lineQ.eq('pmdtent', ent);
          const { data: lines } = await lineQ;
          return { ...gr, lines: lines || [] };
        }));
        setReceipts(grWithLines);
      } else if (activeTab === 'payables') {
        let q = supabase.from('apca_t').select('*').order('apcadocdt', { ascending: false });
        if (!isAdmin) q = q.eq('apcaent', ent);
        const { data: apList } = await q;
        setPayables(apList || []);
      }
    } catch (err) {
      setErrorMsg('載入資料失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  async function fetchMasterData() {
    try {
      let vendQ = supabase.from('vnda_t').select('vndacode, vnda001').eq('vndastatus', '1');
      let itemQ = supabase.from('imaa_t').select('imaacode, imaa001, imaa005').eq('imaastatus', '1');
      let whQ = supabase.from('inaa_t').select('inaacode, inaa001').eq('inaastatus', '1');

      if (!isAdmin) {
        vendQ = vendQ.eq('vndaent', ent);
        itemQ = itemQ.eq('imaaent', ent);
        whQ = whQ.eq('inaaent', ent);
      }

      const { data: vList } = await vendQ;
      const { data: iList } = await itemQ;
      const { data: wList } = await whQ;

      setVendors(vList || []);
      setItems(iList || []);
      setWarehouses(wList || []);
    } catch (err) {
      console.error('載入主檔資料失敗:', err);
    }
  }

  // --- 新增採購單 ---
  function handleAddOrderLine() {
    setNewOrder({
      ...newOrder,
      items: [...newOrder.items, { code: '', qty: 1, price: 0 }]
    });
  }

  function handleRemoveOrderLine(index) {
    const updated = [...newOrder.items];
    updated.splice(index, 1);
    setNewOrder({ ...newOrder, items: updated });
  }

  function handleOrderLineChange(index, field, val) {
    const updated = [...newOrder.items];
    updated[index][field] = val;
    if (field === 'code') {
      const selectedItem = items.find(i => i.imaacode === val);
      if (selectedItem) {
        updated[index]['price'] = parseFloat(selectedItem.imaa005 || 0); // 採購採用參考成本價
      }
    }
    setNewOrder({ ...newOrder, items: updated });
  }

  async function handleSubmitOrder(e) {
    e.preventDefault();
    if (!newOrder.vendor) return alert('請選擇供應商');

    setErrorMsg('');
    setSuccessMsg('');

    try {
      const docNo = 'PO-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + Math.floor(1000 + Math.random() * 9000);

      // 1. 插入單頭 (一步到位直接審核)
      const { error: headErr } = await supabase.from('pmdl_t').insert({
        pmdlent: ent,
        pmdldocno: docNo,
        pmdl004: newOrder.vendor,
        pmdlstatus: '1', // 直接確認
        pmdlcnfid: userDetails.ooagcode,
        pmdlcnfdt: new Date().toISOString()
      });
      if (headErr) throw headErr;

      // 2. 插入單身
      const lines = newOrder.items.map((item, idx) => ({
        pmdnent: ent,
        pmdndocno: docNo,
        pmdnseq: idx + 1,
        pmdn001: item.code,
        pmdn002: parseFloat(item.qty),
        pmdn003: parseFloat(item.price),
        pmdn004: parseFloat(item.qty) * parseFloat(item.price)
      }));

      const { error: lineErr } = await supabase.from('pmdn_t').insert(lines);
      if (lineErr) throw lineErr;

      setSuccessMsg(`採購單 ${docNo} 建立成功！`);
      setShowOrderModal(false);
      setNewOrder({ vendor: '', items: [{ code: '', qty: 1, price: 0 }] });
      fetchData();
    } catch (err) {
      setErrorMsg('建立採購單失敗: ' + err.message);
    }
  }

  // --- 新增收貨單 ---
  async function handleSourceOrderSelect(orderNo) {
    const selected = orders.find(o => o.pmdldocno === orderNo);
    if (!selected) return;

    // 載入未入庫明細
    const grItems = selected.lines
      .filter(line => (parseFloat(line.pmdn002) - parseFloat(line.pmdn005)) > 0)
      .map(line => ({
        code: line.pmdn001,
        qty: parseFloat(line.pmdn002) - parseFloat(line.pmdn005),
        price: parseFloat(line.pmdn003),
        sourceSeq: line.pmdnseq
      }));

    setNewReceipt({
      ...newReceipt,
      sourceOrder: orderNo,
      vendor: selected.pmdl004,
      items: grItems
    });
  }

  async function handleSubmitReceipt(e) {
    e.preventDefault();
    if (!newReceipt.sourceOrder || !newReceipt.warehouse) return alert('請完整填寫收貨資訊');

    setErrorMsg('');
    setSuccessMsg('');

    try {
      const docNo = 'GR-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + Math.floor(1000 + Math.random() * 9000);

      // 1. 插入單頭
      const { error: headErr } = await supabase.from('pmds_t').insert({
        pmdsent: ent,
        pmdsdocno: docNo,
        pmds002: newReceipt.sourceOrder,
        pmds003: newReceipt.vendor,
        pmds004: newReceipt.warehouse,
        pmdsstatus: '0'
      });
      if (headErr) throw headErr;

      // 2. 插入單身 (收貨數量與合格數量在此測試中設為相同)
      const lines = newReceipt.items.map((item, idx) => ({
        pmdtent: ent,
        pmdtdocno: docNo,
        pmdtseq: idx + 1,
        pmdt001: item.code,
        pmdt002: parseFloat(item.qty),
        pmdt003: parseFloat(item.qty), // 驗收合格數量
        pmdt004: parseFloat(item.price),
        pmdt005: parseFloat(item.qty) * parseFloat(item.price),
        pmdt006: item.sourceSeq
      }));

      const { error: lineErr } = await supabase.from('pmdt_t').insert(lines);
      if (lineErr) throw lineErr;

      setSuccessMsg(`收貨單 ${docNo} 建立成功！`);
      setShowReceiptModal(false);
      setNewReceipt({ vendor: '', sourceOrder: '', warehouse: '', items: [] });
      fetchData();
    } catch (err) {
      setErrorMsg('建立收貨單失敗: ' + err.message);
    }
  }

  // --- 核心 RPC: 確認收貨 ---
  async function handleConfirmReceipt(docNo) {
    if (!window.confirm(`確定要確認收貨單 ${docNo} 嗎？這將會增加庫存並自動產生應付帳款。`)) return;

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      const { data, error } = await supabase.rpc('confirm_goods_receipt', {
        p_ent: ent,
        p_docno: docNo,
        p_user: userDetails.ooagcode
      });

      if (error) {
        const code = error.message.split(':')[0];
        if (code === 'QTY_EXCEED_SOURCE') {
          setErrorMsg('收貨失敗 ❌: 收貨數量超過採購單所訂購的剩餘量！' + error.message.split(':')[1]);
        } else {
          setErrorMsg('確認收貨失敗: ' + error.message);
        }
      } else {
        setSuccessMsg(`收貨單 ${docNo} 確認成功！已產生應付帳款單號: ${data.payableDocNo}，應付金額: $${data.payableAmount}`);
        fetchData();
      }
    } catch (err) {
      setErrorMsg('連線異常: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  // --- 核心 RPC: 取消收貨 (作廢) ---
  async function handleVoidReceipt(docNo) {
    if (!window.confirm(`確定要取消收貨單 ${docNo} 嗎？此操作將會還原收貨時增加的庫存、作廢對應的應付帳款，且無法復原。`)) return;

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      const { data, error } = await supabase.rpc('void_goods_receipt', {
        p_ent: ent,
        p_docno: docNo,
        p_user: userDetails.ooagcode
      });

      if (error) {
        let friendlyMsg = error.message;
        if (error.message.includes('STOCK_ALREADY_CONSUMED') || error.message.includes('AP_ALREADY_PAID')) {
          friendlyMsg = '此單無法直接取消，請聯繫管理員走退貨流程';
        } else if (error.message.includes('DOC_NOT_CONFIRMED')) {
          friendlyMsg = '此單尚未確認或已作廢';
        }
        setErrorMsg('取消收貨失敗: ' + friendlyMsg);
      } else {
        setSuccessMsg(`收貨單 ${docNo} 已成功作廢！`);
        fetchData();
      }
    } catch (err) {
      setErrorMsg('連線異常: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  // --- 核心 RPC: 取消採購單 (作廢) ---
  async function handleVoidOrder(docNo) {
    if (!window.confirm(`確定要取消採購單 ${docNo} 嗎？此操作將會作廢採購單，且無法復原。`)) return;

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      const { data, error } = await supabase.rpc('void_purchase_order', {
        p_ent: ent,
        p_docno: docNo,
        p_user: userDetails.ooagcode
      });

      if (error) {
        let friendlyMsg = error.message;
        if (error.message.includes('HAS_ACTIVE_RECEIPT')) {
          friendlyMsg = '此單底下還有生效中的收貨單，請先取消那些單據';
        } else if (error.message.includes('ALREADY_VOIDED')) {
          friendlyMsg = '此單已作廢';
        }
        setErrorMsg('取消採購單失敗: ' + friendlyMsg);
      } else {
        setSuccessMsg(`採購單 ${docNo} 已成功作廢！`);
        fetchData();
      }
    } catch (err) {
      setErrorMsg('連線異常: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>採購與應付帳款</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>管理供應商採購流程、收貨加庫存、以及應付帳款的生成與核銷對帳。</p>
      </div>

      {/* 訊息提示 */}
      {successMsg && (
        <div style={{ background: 'rgba(16, 185, 129, 0.1)', border: '1px solid #10b981', color: '#10b981', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px' }}>
          <CheckCircle size={16} /> <span>{successMsg}</span>
        </div>
      )}
      {errorMsg && (
        <div style={{ background: 'rgba(239, 68, 68, 0.1)', border: '1px solid #ef4444', color: '#ef4444', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px' }}>
          <AlertCircle size={16} /> <span>{errorMsg}</span>
        </div>
      )}

      {/* Tab 切換器 */}
      <div className="glass-panel" style={{ display: 'flex', padding: '4px', gap: '4px' }}>
        <button
          onClick={() => setActiveTab('orders')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'orders' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'orders' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <FileText size={16} /> <span>1. 採購單</span>
        </button>
        <button
          onClick={() => setActiveTab('receipts')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'receipts' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'receipts' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <ArrowDownLeft size={16} /> <span>2. 收貨入庫</span>
        </button>
        <button
          onClick={() => setActiveTab('payables')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'payables' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'payables' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <CreditCard size={16} /> <span>3. 應付帳款</span>
        </button>
      </div>

      {/* 主體區塊 */}
      <div className="glass-panel" style={{ padding: '20px', minHeight: '300px' }}>

        {/* ==================== 1. 採購單頁 ==================== */}
        {activeTab === 'orders' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600 }}>採購單列表</h3>
              <button className="btn-primary" onClick={() => setShowOrderModal(true)} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
                <Plus size={16} /> <span>新增採購單</span>
              </button>
            </div>

            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {orders.length === 0 ? <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '40px' }}>暫無採購單</div> : (
                  orders.map(order => (
                    <div key={order.pmdldocno} className="glass-panel" style={{ padding: '16px', border: '1px solid var(--border-color)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: '15px' }}>{order.pmdldocno}</div>
                          <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            日期: {order.pmdldocdt} | 供應商: {order.pmdl004}
                          </div>
                        </div>
                        <span className={`badge ${order.pmdlstatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                          {order.pmdlstatus === '1' ? '已審核' : '草稿'}
                        </span>
                      </div>

                      {/* 採購明細 */}
                      <div style={{ background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px', fontSize: '13px' }}>
                        {order.lines.map(line => (
                          <div key={line.pmdnseq} style={{ display: 'flex', justifyContent: 'space-between', padding: '4px 0' }}>
                            <span>{line.pmdn001} (採購: {line.pmdn002} 片 | 已入庫: {line.pmdn005} 片)</span>
                            <span style={{ fontWeight: 600 }}>${parseFloat(line.pmdn004).toLocaleString()}</span>
                          </div>
                        ))}
                      </div>

                      {/* 按鈕區域 */}
                      {order.pmdlstatus === '1' && (
                        <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                          <button
                            onClick={() => handleVoidOrder(order.pmdldocno)}
                            style={{ border: '1px solid #ef4444', color: '#ef4444', background: 'transparent', padding: '8px 16px', fontSize: '13px', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}
                          >
                            取消確認
                          </button>
                        </div>
                      )}
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        )}

        {/* ==================== 2. 收貨單頁 ==================== */}
        {activeTab === 'receipts' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600 }}>收貨單列表</h3>
              <button className="btn-primary" onClick={() => setShowReceiptModal(true)} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
                <Plus size={16} /> <span>新增收貨單</span>
              </button>
            </div>

            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {receipts.length === 0 ? <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '40px' }}>暫無收貨記錄</div> : (
                  receipts.map(gr => {
                    const isVoided = gr.pmdsstatus === '9';
                    return (
                      <div 
                        key={gr.pmdsdocno} 
                        className="glass-panel" 
                        style={{ 
                          padding: '16px', 
                          border: '1px solid var(--border-color)', 
                          display: 'flex', 
                          flexDirection: 'column', 
                          gap: '12px',
                          opacity: isVoided ? 0.6 : 1,
                          background: isVoided ? 'rgba(128,128,128,0.05)' : 'var(--bg-panel)'
                        }}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                          <div style={{ textDecoration: isVoided ? 'line-through' : 'none' }}>
                            <div style={{ fontWeight: 600, fontSize: '15px' }}>{gr.pmdsdocno}</div>
                            <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                              日期: {gr.pmdsdocdt} | 來源單: {gr.pmds002} | 倉庫: {gr.pmds004}
                            </div>
                          </div>
                          <span className={`badge ${isVoided ? 'badge-voided' : gr.pmdsstatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                            {isVoided ? '已作廢' : gr.pmdsstatus === '1' ? '已入庫' : '未入庫'}
                          </span>
                        </div>

                        {/* 明細 */}
                        <div style={{ background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px', fontSize: '13px', textDecoration: isVoided ? 'line-through' : 'none' }}>
                          {gr.lines.map(line => (
                            <div key={line.pmdtseq} style={{ display: 'flex', justifyContent: 'space-between', padding: '4px 0' }}>
                              <span>{line.pmdt001} (驗收合格: {line.pmdt003} 片)</span>
                              <span style={{ fontWeight: 600 }}>${parseFloat(line.pmdt005).toLocaleString()}</span>
                            </div>
                          ))}
                        </div>

                        {/* 按鈕區域 */}
                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                          {/* 確認收貨按鈕 */}
                          {gr.pmdsstatus === '0' && (
                            <button
                              onClick={() => handleConfirmReceipt(gr.pmdsdocno)}
                              style={{ background: 'var(--color-primary)', color: '#fff', padding: '8px 16px', fontSize: '13px', borderRadius: '8px', fontWeight: 600 }}
                            >
                              確認收貨 (RPC)
                            </button>
                          )}
                          
                          {/* 取消收貨按鈕 */}
                          {gr.pmdsstatus === '1' && (
                            <button
                              onClick={() => handleVoidReceipt(gr.pmdsdocno)}
                              style={{ border: '1px solid #ef4444', color: '#ef4444', background: 'transparent', padding: '8px 16px', fontSize: '13px', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}
                            >
                              取消收貨
                            </button>
                          )}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            )}
          </div>
        )}

        {/* ==================== 3. 應付帳款頁 ==================== */}
        {activeTab === 'payables' && (
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>應付帳款清單</h3>
            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                      <th style={{ padding: '12px 8px' }}>帳款單號</th>
                      <th style={{ padding: '12px 8px' }}>來源收貨單</th>
                      <th style={{ padding: '12px 8px' }}>供應商</th>
                      <th style={{ padding: '12px 8px' }}>應付總額</th>
                      <th style={{ padding: '12px 8px' }}>已付金額</th>
                    </tr>
                  </thead>
                  <tbody>
                    {payables.length === 0 ? (
                      <tr>
                        <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>暫無應付記錄</td>
                      </tr>
                    ) : (
                      payables.map(ap => {
                        const isVoided = ap.apcastatus === '9';
                        return (
                          <tr key={ap.apcadocno} style={{ borderBottom: '1px solid var(--border-color)', opacity: isVoided ? 0.5 : 1, textDecoration: isVoided ? 'line-through' : 'none', color: isVoided ? 'var(--text-secondary)' : 'inherit' }}>
                            <td style={{ padding: '12px 8px', fontWeight: 600 }}>
                              {ap.apcadocno} {isVoided && <span style={{ fontSize: '11px', color: '#ef4444', textDecoration: 'none', display: 'inline-block' }}>(已作廢)</span>}
                            </td>
                            <td style={{ padding: '12px 8px' }}>{ap.apca002}</td>
                            <td style={{ padding: '12px 8px' }}>{ap.apca001}</td>
                            <td style={{ padding: '12px 8px', color: isVoided ? 'var(--text-secondary)' : '#ef4444', fontWeight: 'bold' }}>${parseFloat(ap.apca003).toLocaleString(undefined, { minimumFractionDigits: 2 })}</td>
                            <td style={{ padding: '12px 8px' }}>${parseFloat(ap.apca004 || 0).toLocaleString(undefined, { minimumFractionDigits: 2 })}</td>
                          </tr>
                        );
                      })
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

      </div>

      {/* Modal - 新增採購單 */}
      {showOrderModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyBehavior: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '500px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px', maxHeight: '90vh', overflowY: 'auto' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>建立採購單</h3>

            <form onSubmit={handleSubmitOrder} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>選擇供應商</label>
                <select required value={newOrder.vendor} onChange={(e) => setNewOrder({ ...newOrder, vendor: e.target.value })}>
                  <option value="">-- 請選擇供應商 --</option>
                  {vendors.map(v => <option key={v.vndacode} value={v.vndacode}>{v.vnda001} ({v.vndacode})</option>)}
                </select>
              </div>

              <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px' }}>
                <div style={{ display: 'flex', justifyBehavior: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                  <span style={{ fontSize: '14px', fontWeight: 600 }}>採購品項</span>
                  <button type="button" className="btn-secondary" onClick={handleAddOrderLine} style={{ padding: '4px 8px', fontSize: '12px' }}>+ 新增商品</button>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  {newOrder.items.map((line, idx) => (
                    <div key={idx} style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                      <select style={{ flex: 2 }} required value={line.code} onChange={(e) => handleOrderLineChange(idx, 'code', e.target.value)}>
                        <option value="">-- 商品 --</option>
                        {items.map(i => <option key={i.imaacode} value={i.imaacode}>{i.imaa001}</option>)}
                      </select>
                      <input style={{ flex: 1 }} type="number" required min="1" placeholder="數量" value={line.qty} onChange={(e) => handleOrderLineChange(idx, 'qty', e.target.value)} />
                      <input style={{ flex: 1.2 }} type="number" required placeholder="單價" value={line.price} onChange={(e) => handleOrderLineChange(idx, 'price', e.target.value)} />
                      {newOrder.items.length > 1 && (
                        <button type="button" onClick={() => handleRemoveOrderLine(idx)} style={{ background: 'transparent', color: '#ef4444', padding: '4px' }}><Trash2 size={16} /></button>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              <div style={{ display: 'flex', gap: '12px', justifyBehavior: 'flex-end', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowOrderModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>提交</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal - 新增收貨單 */}
      {showReceiptModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyBehavior: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '500px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px', maxHeight: '90vh', overflowY: 'auto' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>建立收貨單</h3>

            <form onSubmit={handleSubmitReceipt} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>來源採購單</label>
                <select required value={newReceipt.sourceOrder} onChange={(e) => handleSourceOrderSelect(e.target.value)}>
                  <option value="">-- 請選擇來源採購單 --</option>
                  {orders.filter(o => o.pmdlstatus === '1').map(o => <option key={o.pmdldocno} value={o.pmdldocno}>{o.pmdldocno} (供應商: {o.pmdl004})</option>)}
                </select>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>收貨入庫倉庫</label>
                <select required value={newReceipt.warehouse} onChange={(e) => setNewReceipt({ ...newReceipt, warehouse: e.target.value })}>
                  <option value="">-- 請選擇倉庫 --</option>
                  {warehouses.map(w => <option key={w.inaacode} value={w.inaacode}>{w.inaa001} ({w.inaacode})</option>)}
                </select>
              </div>

              {newReceipt.items.length > 0 && (
                <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px' }}>
                  <span style={{ fontSize: '14px', fontWeight: 600, display: 'block', marginBottom: '10px' }}>預計收貨品項</span>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px', background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px' }}>
                    {newReceipt.items.map((line, idx) => (
                      <div key={idx} style={{ display: 'flex', justifyBehavior: 'space-between' }}>
                        <span>{line.code}</span>
                        <span>數量: {line.qty} 片</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div style={{ display: 'flex', gap: '12px', justifyBehavior: 'flex-end', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowReceiptModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>提交</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
