import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { FileText, Truck, Receipt, Plus, CheckCircle, AlertCircle, Trash2 } from 'lucide-react';

export default function Sales({ userDetails }) {
  const [activeTab, setActiveTab] = useState('orders'); // orders, shipments, receivables
  const [orders, setOrders] = useState([]);
  const [shipments, setShipments] = useState([]);
  const [receivables, setReceivables] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  // 下拉選單用主檔
  const [customers, setCustomers] = useState([]);
  const [items, setItems] = useState([]);
  const [warehouses, setWarehouses] = useState([]);

  // 表單控制
  const [showOrderModal, setShowOrderModal] = useState(false);
  const [newOrder, setNewOrder] = useState({ customer: '', salesperson: '林業務', items: [{ code: '', qty: 1, price: 0 }] });

  const [showShipmentModal, setShowShipmentModal] = useState(false);
  const [newShipment, setNewShipment] = useState({ customer: '', sourceOrder: '', warehouse: '', items: [] });

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
        let q = supabase.from('xmda_t').select('*').order('xmdadocdt', { ascending: false });
        if (!isAdmin) q = q.eq('xmdaent', ent);
        const { data: salesOrders } = await q;

        // 加載明細
        const ordersWithLines = await Promise.all((salesOrders || []).map(async (order) => {
          let lineQ = supabase.from('xmdc_t').select('*').eq('xmdcdocno', order.xmdadocno);
          if (!isAdmin) lineQ = lineQ.eq('xmdcent', ent);
          const { data: lines } = await lineQ;
          return { ...order, lines: lines || [] };
        }));
        setOrders(ordersWithLines);
      } else if (activeTab === 'shipments') {
        let q = supabase.from('xmdk_t').select('*').order('xmdkdocdt', { ascending: false });
        if (!isAdmin) q = q.eq('xmdkent', ent);
        const { data: shList } = await q;

        // 加載出貨明細
        const shWithLines = await Promise.all((shList || []).map(async (sh) => {
          let lineQ = supabase.from('xmdl_t').select('*').eq('xmdldocno', sh.xmdkdocno);
          if (!isAdmin) lineQ = lineQ.eq('xmdlent', ent);
          const { data: lines } = await lineQ;
          return { ...sh, lines: lines || [] };
        }));
        setShipments(shWithLines);
      } else if (activeTab === 'receivables') {
        let q = supabase.from('xrca_t').select('*').order('xrcadocdt', { ascending: false });
        if (!isAdmin) q = q.eq('xrcaent', ent);
        const { data: rcList } = await q;
        setReceivables(rcList || []);
      }
    } catch (err) {
      setErrorMsg('載入資料失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  async function fetchMasterData() {
    try {
      let custQ = supabase.from('cusa_t').select('cusacode, cusa001').eq('cusastatus', '1');
      let itemQ = supabase.from('imaa_t').select('imaacode, imaa001, imaa006').eq('imaastatus', '1');
      let whQ = supabase.from('inaa_t').select('inaacode, inaa001').eq('inaastatus', '1');

      if (!isAdmin) {
        custQ = custQ.eq('cusaent', ent);
        itemQ = itemQ.eq('imaaent', ent);
        whQ = whQ.eq('inaaent', ent);
      }

      const { data: cList } = await custQ;
      const { data: iList } = await itemQ;
      const { data: wList } = await whQ;

      setCustomers(cList || []);
      setItems(iList || []);
      setWarehouses(wList || []);
    } catch (err) {
      console.error('載入主檔資料失敗:', err);
    }
  }

  // --- 銷貨訂單新增 ---
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
        updated[index]['price'] = parseFloat(selectedItem.imaa006 || 0);
      }
    }
    setNewOrder({ ...newOrder, items: updated });
  }

  async function handleSubmitOrder(e) {
    e.preventDefault();
    if (!newOrder.customer) return alert('請選擇客戶');
    
    setErrorMsg('');
    setSuccessMsg('');
    
    try {
      // 1. 生成訂單單號
      const docNo = 'SO-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + Math.floor(1000 + Math.random() * 9000);
      
      // 2. 插入單頭 (一步到位直接確認)
      const { error: headErr } = await supabase.from('xmda_t').insert({
        xmdaent: ent,
        xmdadocno: docNo,
        xmda002: newOrder.salesperson,
        xmda004: newOrder.customer,
        xmdastatus: '1', // 直接確認
        xmdacnfid: userDetails.ooagcode,
        xmdacnfdt: new Date().toISOString()
      });

      if (headErr) throw headErr;

      // 3. 插入單身
      const lines = newOrder.items.map((item, idx) => ({
        xmdcent: ent,
        xmdcdocno: docNo,
        xmdcseq: idx + 1,
        xmdc001: item.code,
        xmdc002: parseFloat(item.qty),
        xmdc003: parseFloat(item.price),
        xmdc004: parseFloat(item.qty) * parseFloat(item.price)
      }));

      const { error: lineErr } = await supabase.from('xmdc_t').insert(lines);
      if (lineErr) throw lineErr;

      setSuccessMsg(`銷貨訂單 ${docNo} 建立成功！`);
      setShowOrderModal(false);
      setNewOrder({ customer: '', salesperson: '林業務', items: [{ code: '', qty: 1, price: 0 }] });
      fetchData();
    } catch (err) {
      setErrorMsg('建立訂單失敗: ' + err.message);
    }
  }

  // --- 出貨單新增 ---
  async function handleSourceOrderSelect(orderNo) {
    const selected = orders.find(o => o.xmdadocno === orderNo);
    if (!selected) return;

    // 將訂單中未出貨完畢的明細載入出貨單
    const shItems = selected.lines
      .filter(line => (parseFloat(line.xmdc002) - parseFloat(line.xmdc005)) > 0)
      .map(line => ({
        code: line.xmdc001,
        qty: parseFloat(line.xmdc002) - parseFloat(line.xmdc005), // 剩餘未出貨量
        price: parseFloat(line.xmdc003),
        sourceSeq: line.xmdcseq
      }));

    setNewShipment({
      ...newShipment,
      sourceOrder: orderNo,
      customer: selected.xmda004,
      items: shItems
    });
  }

  async function handleSubmitShipment(e) {
    e.preventDefault();
    if (!newShipment.sourceOrder || !newShipment.warehouse) return alert('請填寫完整出貨資訊');

    setErrorMsg('');
    setSuccessMsg('');

    try {
      const docNo = 'SH-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + Math.floor(1000 + Math.random() * 9000);

      // 1. 插入出貨單頭
      const { error: headErr } = await supabase.from('xmdk_t').insert({
        xmdkent: ent,
        xmdkdocno: docNo,
        xmdk004: newShipment.customer,
        xmdk005: newShipment.sourceOrder,
        xmdk006: newShipment.warehouse,
        xmdkstatus: '0'
      });
      if (headErr) throw headErr;

      // 2. 插入出貨單身
      const lines = newShipment.items.map((item, idx) => ({
        xmdlent: ent,
        xmdldocno: docNo,
        xmdlseq: idx + 1,
        xmdl001: item.code,
        xmdl002: parseFloat(item.qty),
        xmdl003: parseFloat(item.price),
        xmdl004: parseFloat(item.qty) * parseFloat(item.price),
        xmdl005: item.sourceSeq
      }));

      const { error: lineErr } = await supabase.from('xmdl_t').insert(lines);
      if (lineErr) throw lineErr;

      setSuccessMsg(`出貨單 ${docNo} 建立成功！`);
      setShowShipmentModal(false);
      setNewShipment({ customer: '', sourceOrder: '', warehouse: '', items: [] });
      fetchData();
    } catch (err) {
      setErrorMsg('建立出貨單失敗: ' + err.message);
    }
  }

  // --- 核心 RPC: 確認出貨 ---
  async function handleConfirmShipment(docNo) {
    if (!window.confirm(`確定要確認出貨單 ${docNo} 嗎？這將會扣減庫存並產生應收帳款。`)) return;

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      const { data, error } = await supabase.rpc('confirm_shipment', {
        p_ent: ent,
        p_docno: docNo,
        p_user: userDetails.ooagcode
      });

      if (error) {
        // 解析並呈現易懂的錯誤代碼
        const code = error.message.split(':')[0];
        if (code === 'STOCK_INSUFFICIENT') {
          setErrorMsg('出貨失敗 ❌: 庫存量不足！' + error.message.split(':')[1]);
        } else {
          setErrorMsg('確認出貨失敗: ' + error.message);
        }
      } else {
        setSuccessMsg(`出貨單 ${docNo} 確認成功！已產生應收帳款單號: ${data.receivableDocNo}，應收總金額: $${data.receivableAmount}`);
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
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>銷貨與應收帳款</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>管理企業銷貨訂單、出貨單扣庫存與核銷，以及自動化應收帳款追蹤。</p>
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
          <FileText size={16} /> <span>1. 銷貨訂單</span>
        </button>
        <button
          onClick={() => setActiveTab('shipments')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'shipments' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'shipments' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Truck size={16} /> <span>2. 出貨單</span>
        </button>
        <button
          onClick={() => setActiveTab('receivables')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'receivables' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'receivables' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Receipt size={16} /> <span>3. 應收帳款</span>
        </button>
      </div>

      {/* 主體區塊 */}
      <div className="glass-panel" style={{ padding: '20px', minHeight: '300px' }}>
        
        {/* ==================== 1. 銷貨訂單頁 ==================== */}
        {activeTab === 'orders' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600 }}>訂單列表</h3>
              <button className="btn-primary" onClick={() => setShowOrderModal(true)} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
                <Plus size={16} /> <span>新增訂單</span>
              </button>
            </div>

            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>正在載入訂單...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {orders.length === 0 ? <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '40px' }}>暫無銷貨訂單</div> : (
                  orders.map(order => (
                    <div key={order.xmdadocno} className="glass-panel" style={{ padding: '16px', border: '1px solid var(--border-color)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: '15px' }}>{order.xmdadocno}</div>
                          <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            日期: {order.xmdadocdt} | 客戶: {order.xmda004} | 業務: {order.xmda002}
                          </div>
                        </div>
                        <span className={`badge ${order.xmdastatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                          {order.xmdastatus === '1' ? '已確認' : '草稿'}
                        </span>
                      </div>
                      
                      {/* 明細清單 */}
                      <div style={{ background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px', fontSize: '13px' }}>
                        {order.lines.map(line => (
                          <div key={line.xmdcseq} style={{ display: 'flex', justifyContent: 'space-between', padding: '4px 0' }}>
                            <span>{line.xmdc001} (訂購: {line.xmdc002} 片 | 已出貨: {line.xmdc005} 片)</span>
                            <span style={{ fontWeight: 600 }}>${parseFloat(line.xmdc004).toLocaleString()}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        )}

        {/* ==================== 2. 出貨單頁 ==================== */}
        {activeTab === 'shipments' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600 }}>出貨單列表</h3>
              <button className="btn-primary" onClick={() => setShowShipmentModal(true)} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
                <Plus size={16} /> <span>新增出貨單</span>
              </button>
            </div>

            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>正在處理...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {shipments.length === 0 ? <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '40px' }}>暫無出貨單記錄</div> : (
                  shipments.map(sh => (
                    <div key={sh.xmdkdocno} className="glass-panel" style={{ padding: '16px', border: '1px solid var(--border-color)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: '15px' }}>{sh.xmdkdocno}</div>
                          <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            日期: {sh.xmdkdocdt} | 來源單: {sh.xmdk005} | 倉庫: {sh.xmdk006}
                          </div>
                        </div>
                        <span className={`badge ${sh.xmdkstatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                          {sh.xmdkstatus === '1' ? '已出貨' : '未出貨'}
                        </span>
                      </div>

                      {/* 出貨明細 */}
                      <div style={{ background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px', fontSize: '13px' }}>
                        {sh.lines.map(line => (
                          <div key={line.xmdlseq} style={{ display: 'flex', justifyContent: 'space-between', padding: '4px 0' }}>
                            <span>{line.xmdl001} (出貨量: {line.xmdl002} 片)</span>
                            <span style={{ fontWeight: 600 }}>${parseFloat(line.xmdl004).toLocaleString()}</span>
                          </div>
                        ))}
                      </div>

                      {/* 確認出貨按鈕 (核心動作) */}
                      {sh.xmdkstatus === '0' && (
                        <button
                          onClick={() => handleConfirmShipment(sh.xmdkdocno)}
                          style={{ alignSelf: 'flex-end', background: 'var(--color-primary)', color: '#fff', padding: '8px 16px', fontSize: '13px', borderRadius: '8px', fontWeight: 600 }}
                        >
                          確認出貨 (RPC)
                        </button>
                      )}
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        )}

        {/* ==================== 3. 應收帳款頁 ==================== */}
        {activeTab === 'receivables' && (
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>應收帳款清單</h3>
            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                      <th style={{ padding: '12px 8px' }}>帳款單號</th>
                      <th style={{ padding: '12px 8px' }}>來源出貨單</th>
                      <th style={{ padding: '12px 8px' }}>客戶</th>
                      <th style={{ padding: '12px 8px' }}>應收總額</th>
                      <th style={{ padding: '12px 8px' }}>已收金額</th>
                    </tr>
                  </thead>
                  <tbody>
                    {receivables.length === 0 ? (
                      <tr>
                        <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>暫無帳款記錄</td>
                      </tr>
                    ) : (
                      receivables.map(rc => (
                        <tr key={rc.xrcadocno} style={{ borderBottom: '1px solid var(--border-color)' }}>
                          <td style={{ padding: '12px 8px', fontWeight: 600 }}>{rc.xrcadocno}</td>
                          <td style={{ padding: '12px 8px' }}>{rc.xrca002}</td>
                          <td style={{ padding: '12px 8px' }}>{rc.xrca001}</td>
                          <td style={{ padding: '12px 8px', color: 'var(--color-primary)', fontWeight: 'bold' }}>${parseFloat(rc.xrca003).toLocaleString(undefined, { minimumFractionDigits: 2 })}</td>
                          <td style={{ padding: '12px 8px' }}>${parseFloat(rc.xrca004 || 0).toLocaleString(undefined, { minimumFractionDigits: 2 })}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

      </div>

      {/* Modal - 新增訂單 */}
      {showOrderModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '500px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px', maxHeight: '90vh', overflowY: 'auto' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>建立銷貨訂單</h3>
            
            <form onSubmit={handleSubmitOrder} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>選擇客戶</label>
                <select required value={newOrder.customer} onChange={(e) => setNewOrder({ ...newOrder, customer: e.target.value })}>
                  <option value="">-- 請選擇客戶 --</option>
                  {customers.map(c => <option key={c.cusacode} value={c.cusacode}>{c.cusa001} ({c.cusacode})</option>)}
                </select>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>業務人員</label>
                <input type="text" required value={newOrder.salesperson} onChange={(e) => setNewOrder({ ...newOrder, salesperson: e.target.value })} />
              </div>

              <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                  <span style={{ fontSize: '14px', fontWeight: 600 }}>商品明細</span>
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

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowOrderModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>提交</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal - 新增出貨單 */}
      {showShipmentModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '500px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px', maxHeight: '90vh', overflowY: 'auto' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>建立出貨單</h3>

            <form onSubmit={handleSubmitShipment} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>來源銷貨訂單</label>
                <select required value={newShipment.sourceOrder} onChange={(e) => handleSourceOrderSelect(e.target.value)}>
                  <option value="">-- 請選擇來源訂單 --</option>
                  {orders.filter(o => o.xmdastatus === '1').map(o => <option key={o.xmdadocno} value={o.xmdadocno}>{o.xmdadocno} (客戶: {o.xmda004})</option>)}
                </select>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>出貨倉庫</label>
                <select required value={newShipment.warehouse} onChange={(e) => setNewShipment({ ...newShipment, warehouse: e.target.value })}>
                  <option value="">-- 請選擇倉庫 --</option>
                  {warehouses.map(w => <option key={w.inaacode} value={w.inaacode}>{w.inaa001} ({w.inaacode})</option>)}
                </select>
              </div>

              {newShipment.items.length > 0 && (
                <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px' }}>
                  <span style={{ fontSize: '14px', fontWeight: 600, display: 'block', marginBottom: '10px' }}>將要出貨的商品 (自動從來源單帶入)</span>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px', background: 'rgba(0,0,0,0.1)', padding: '10px', borderRadius: '8px' }}>
                    {newShipment.items.map((line, idx) => (
                      <div key={idx} style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <span>{line.code}</span>
                        <span>數量: {line.qty} 片</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowShipmentModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>提交</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
