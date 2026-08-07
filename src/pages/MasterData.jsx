import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { Package, User, Truck, Home, Plus, Edit2, CheckCircle, AlertCircle } from 'lucide-react';

export default function MasterData({ userDetails }) {
  const [activeTab, setActiveTab] = useState('items'); // items, customers, vendors, warehouses
  const [items, setItems] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [vendors, setVendors] = useState([]);
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  // 彈窗控制
  const [showModal, setShowModal] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);

  // 表單資料狀態 (共用同一個表單狀態以簡化程式碼，內部分欄位)
  const [formData, setFormData] = useState({
    // 商品欄位
    imaacode: '', imaa001: '', imaa002: '', imaa003: '預設分類', imaa004: '片', imaa005: 0, imaa006: 0, imaa007: 0,
    // 客戶/供應商欄位
    code: '', name: '', taxId: '', contact: '', phone: '', address: '', paymentTerms: '30天月結',
    // 倉庫欄位
    inaacode: '', inaa001: '', inaastatus: '1'
  });

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    fetchData();
  }, [ent, isAdmin, activeTab]);

  async function fetchData() {
    setLoading(true);
    setErrorMsg('');
    try {
      if (activeTab === 'items') {
        let q = supabase.from('imaa_t').select('*').order('imaacode');
        if (!isAdmin) q = q.eq('imaaent', ent);
        const { data } = await q;
        setItems(data || []);
      } else if (activeTab === 'customers') {
        let q = supabase.from('cusa_t').select('*').order('cusacode');
        if (!isAdmin) q = q.eq('cusaent', ent);
        const { data } = await q;
        setCustomers(data || []);
      } else if (activeTab === 'vendors') {
        let q = supabase.from('vnda_t').select('*').order('vndacode');
        if (!isAdmin) q = q.eq('vndaent', ent);
        const { data } = await q;
        setVendors(data || []);
      } else if (activeTab === 'warehouses') {
        let q = supabase.from('inaa_t').select('*').order('inaacode');
        if (!isAdmin) q = q.eq('inaaent', ent);
        const { data } = await q;
        setWarehouses(data || []);
      }
    } catch (err) {
      setErrorMsg('載入資料失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  function openCreateModal() {
    setIsEditMode(false);
    setFormData({
      imaacode: '', imaa001: '', imaa002: '', imaa003: '常規', imaa004: '片', imaa005: 0, imaa006: 0, imaa007: 0,
      code: '', name: '', taxId: '', contact: '', phone: '', address: '', paymentTerms: '月結30天',
      inaacode: '', inaa001: '', inaastatus: '1'
    });
    setShowModal(true);
  }

  function openEditModal(record) {
    setIsEditMode(true);
    setErrorMsg('');
    setSuccessMsg('');
    if (activeTab === 'items') {
      setFormData({
        imaacode: record.imaacode,
        imaa001: record.imaa001 || '',
        imaa002: record.imaa002 || '',
        imaa003: record.imaa003 || '常規',
        imaa004: record.imaa004 || '片',
        imaa005: parseFloat(record.imaa005 || 0),
        imaa006: parseFloat(record.imaa006 || 0),
        imaa007: parseFloat(record.imaa007 || 0)
      });
    } else if (activeTab === 'customers') {
      setFormData({
        code: record.cusacode,
        name: record.cusa001 || '',
        taxId: record.cusa002 || '',
        contact: record.cusa003 || '',
        phone: record.cusa004 || '',
        address: record.cusa005 || '',
        paymentTerms: record.cusa006 || '月結30天'
      });
    } else if (activeTab === 'vendors') {
      setFormData({
        code: record.vndacode,
        name: record.vnda001 || '',
        taxId: record.vnda002 || '',
        contact: record.vnda003 || '',
        phone: record.vnda004 || '',
        address: record.vnda005 || '',
        paymentTerms: record.vnda006 || '月結30天'
      });
    } else if (activeTab === 'warehouses') {
      setFormData({
        inaacode: record.inaacode,
        inaa001: record.inaa001 || '',
        inaastatus: record.inaastatus || '1'
      });
    }
    setShowModal(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setErrorMsg('');
    setSuccessMsg('');
    setLoading(true);

    try {
      if (activeTab === 'items') {
        if (isEditMode) {
          // 更新商品
          const { error } = await supabase.from('imaa_t')
            .update({
              imaa001: formData.imaa001,
              imaa002: formData.imaa002,
              imaa003: formData.imaa003,
              imaa004: formData.imaa004,
              imaa005: formData.imaa005,
              imaa006: formData.imaa006,
              imaa007: formData.imaa007
            })
            .match({ imaaent: ent, imaacode: formData.imaacode });
          if (error) throw error;
          setSuccessMsg(`商品 ${formData.imaa001} 更新成功！`);
        } else {
          // 新增商品
          const { error } = await supabase.from('imaa_t').insert({
            imaaent: ent,
            imaacode: formData.imaacode.trim(),
            imaa001: formData.imaa001,
            imaa002: formData.imaa002,
            imaa003: formData.imaa003,
            imaa004: formData.imaa004,
            imaa005: formData.imaa005,
            imaa006: formData.imaa006,
            imaa007: formData.imaa007
          });
          if (error) throw error;
          setSuccessMsg(`商品 ${formData.imaa001} 建立成功！`);
        }
      } else if (activeTab === 'customers') {
        if (isEditMode) {
          // 更新客戶
          const { error } = await supabase.from('cusa_t')
            .update({
              cusa001: formData.name,
              cusa002: formData.taxId,
              cusa003: formData.contact,
              cusa004: formData.phone,
              cusa005: formData.address,
              cusa006: formData.paymentTerms
            })
            .match({ cusaent: ent, cusacode: formData.code });
          if (error) throw error;
          setSuccessMsg(`客戶 ${formData.name} 更新成功！`);
        } else {
          // 新增客戶
          const { error } = await supabase.from('cusa_t').insert({
            cusaent: ent,
            cusacode: formData.code.trim(),
            cusa001: formData.name,
            cusa002: formData.taxId,
            cusa003: formData.contact,
            cusa004: formData.phone,
            cusa005: formData.address,
            cusa006: formData.paymentTerms
          });
          if (error) throw error;
          setSuccessMsg(`客戶 ${formData.name} 建立成功！`);
        }
      } else if (activeTab === 'vendors') {
        if (isEditMode) {
          // 更新供應商
          const { error } = await supabase.from('vnda_t')
            .update({
              vnda001: formData.name,
              vnda002: formData.taxId,
              vnda003: formData.contact,
              vnda004: formData.phone,
              vnda005: formData.address,
              vnda006: formData.paymentTerms
            })
            .match({ vndaent: ent, vndacode: formData.code });
          if (error) throw error;
          setSuccessMsg(`供應商 ${formData.name} 更新成功！`);
        } else {
          // 新增供應商
          const { error } = await supabase.from('vnda_t').insert({
            vndaent: ent,
            vndacode: formData.code.trim(),
            vnda001: formData.name,
            vnda002: formData.taxId,
            vnda003: formData.contact,
            vnda004: formData.phone,
            vnda005: formData.address,
            vnda006: formData.paymentTerms
          });
          if (error) throw error;
          setSuccessMsg(`供應商 ${formData.name} 建立成功！`);
        }
      } else if (activeTab === 'warehouses') {
        if (isEditMode) {
          // 更新倉庫
          const { error } = await supabase.from('inaa_t')
            .update({
              inaa001: formData.inaa001,
              inaastatus: formData.inaastatus
            })
            .match({ inaaent: ent, inaacode: formData.inaacode });
          if (error) throw error;
          setSuccessMsg(`倉庫 ${formData.inaa001} 更新成功！`);
        } else {
          // 新增倉庫 - 檢查代碼是否重複
          const { data: existing } = await supabase.from('inaa_t')
            .select('inaacode')
            .match({ inaaent: ent, inaacode: formData.inaacode.trim() })
            .maybeSingle();
          if (existing) {
            throw new Error('倉庫代碼已存在，請使用其他代碼！');
          }

          const { error } = await supabase.from('inaa_t').insert({
            inaaent: ent,
            inaacode: formData.inaacode.trim(),
            inaa001: formData.inaa001,
            inaastatus: '1'
          });
          if (error) throw error;
          setSuccessMsg(`倉庫 ${formData.inaa001} 建立成功！`);
        }
      }

      setShowModal(false);
      fetchData();
    } catch (err) {
      setErrorMsg('儲存資料失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>基本資料維護</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>設定與編輯企業運作所需的基本商品、客戶以及供應商主檔。</p>
      </div>

      {/* 提示訊息 */}
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
          onClick={() => { setActiveTab('items'); setSuccessMsg(''); setErrorMsg(''); }}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'items' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'items' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Package size={16} /> <span>商品檔案</span>
        </button>
        <button
          onClick={() => { setActiveTab('customers'); setSuccessMsg(''); setErrorMsg(''); }}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'customers' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'customers' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <User size={16} /> <span>客戶檔案</span>
        </button>
        <button
          onClick={() => { setActiveTab('vendors'); setSuccessMsg(''); setErrorMsg(''); }}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'vendors' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'vendors' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Truck size={16} /> <span>供應商檔案</span>
        </button>
        <button
          onClick={() => { setActiveTab('warehouses'); setSuccessMsg(''); setErrorMsg(''); }}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'warehouses' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'warehouses' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Home size={16} /> <span>倉庫檔案</span>
        </button>
      </div>

      {/* 內容區塊 */}
      <div className="glass-panel" style={{ padding: '20px', minHeight: '350px' }}>
        
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <h3 style={{ fontSize: '16px', fontWeight: 600 }}>
            {activeTab === 'items' && '商品列表'}
            {activeTab === 'customers' && '客戶列表'}
            {activeTab === 'vendors' && '供應商列表'}
            {activeTab === 'warehouses' && '倉庫列表'}
          </h3>
          <button className="btn-primary" onClick={openCreateModal} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
            <Plus size={16} /> <span>新增資料</span>
          </button>
        </div>

        {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
          <div style={{ overflowX: 'auto' }}>
            
            {/* ==================== 1. 商品列表 ==================== */}
            {activeTab === 'items' && (
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                    <th style={{ padding: '12px 8px' }}>商品編號</th>
                    <th style={{ padding: '12px 8px' }}>品名規格</th>
                    <th style={{ padding: '12px 8px' }}>參考售價</th>
                    <th style={{ padding: '12px 8px' }}>參考成本</th>
                    <th style={{ padding: '12px 8px' }}>安全庫存</th>
                    <th style={{ padding: '12px 8px', width: '80px' }}>操作</th>
                  </tr>
                </thead>
                <tbody>
                  {items.length === 0 ? (
                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-secondary)' }}>暫無商品資料</td></tr>
                  ) : (
                    items.map(item => (
                      <tr key={item.imaacode} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '12px 8px', fontWeight: 600 }}>{item.imaacode}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <div style={{ fontWeight: 500 }}>{item.imaa001}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>規格: {item.imaa002 || '無'} | 分類: {item.imaa003}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>${parseFloat(item.imaa006 || 0).toLocaleString()}</td>
                        <td style={{ padding: '12px 8px' }}>${parseFloat(item.imaa005 || 0).toLocaleString()}</td>
                        <td style={{ padding: '12px 8px' }}>{parseFloat(item.imaa007 || 0).toLocaleString()} {item.imaa004}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <button onClick={() => openEditModal(item)} style={{ background: 'transparent', color: 'var(--color-primary)', padding: '6px' }}><Edit2 size={16} /></button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            )}

            {/* ==================== 2. 客戶列表 ==================== */}
            {activeTab === 'customers' && (
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                    <th style={{ padding: '12px 8px' }}>客戶編號</th>
                    <th style={{ padding: '12px 8px' }}>客戶名稱</th>
                    <th style={{ padding: '12px 8px' }}>統一編號</th>
                    <th style={{ padding: '12px 8px' }}>聯絡資訊</th>
                    <th style={{ padding: '12px 8px' }}>付款條件</th>
                    <th style={{ padding: '12px 8px', width: '80px' }}>操作</th>
                  </tr>
                </thead>
                <tbody>
                  {customers.length === 0 ? (
                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-secondary)' }}>暫無客戶資料</td></tr>
                  ) : (
                    customers.map(cust => (
                      <tr key={cust.cusacode} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '12px 8px', fontWeight: 600 }}>{cust.cusacode}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <div style={{ fontWeight: 500 }}>{cust.cusa001}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>{cust.cusa005}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>{cust.cusa002 || '-'}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <div>聯絡人: {cust.cusa003 || '-'}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>電話: {cust.cusa004 || '-'}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>{cust.cusa006}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <button onClick={() => openEditModal(cust)} style={{ background: 'transparent', color: 'var(--color-primary)', padding: '6px' }}><Edit2 size={16} /></button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            )}

            {/* ==================== 3. 供應商列表 ==================== */}
            {activeTab === 'vendors' && (
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                    <th style={{ padding: '12px 8px' }}>供應商編號</th>
                    <th style={{ padding: '12px 8px' }}>供應商名稱</th>
                    <th style={{ padding: '12px 8px' }}>統一編號</th>
                    <th style={{ padding: '12px 8px' }}>聯絡資訊</th>
                    <th style={{ padding: '12px 8px' }}>付款條件</th>
                    <th style={{ padding: '12px 8px', width: '80px' }}>操作</th>
                  </tr>
                </thead>
                <tbody>
                  {vendors.length === 0 ? (
                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-secondary)' }}>暫無供應商資料</td></tr>
                  ) : (
                    vendors.map(vend => (
                      <tr key={vend.vndacode} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '12px 8px', fontWeight: 600 }}>{vend.vndacode}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <div style={{ fontWeight: 500 }}>{vend.vnda001}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>{vend.vnda005}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>{vend.vnda002 || '-'}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <div>聯絡人: {vend.vnda003 || '-'}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>電話: {vend.vnda004 || '-'}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>{vend.vnda006}</td>
                        <td style={{ padding: '12px 8px' }}>
                          <button onClick={() => openEditModal(vend)} style={{ background: 'transparent', color: 'var(--color-primary)', padding: '6px' }}><Edit2 size={16} /></button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            )}

            {/* ==================== 4. 倉庫列表 ==================== */}
            {activeTab === 'warehouses' && (
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                    <th style={{ padding: '12px 8px' }}>倉庫代碼</th>
                    <th style={{ padding: '12px 8px' }}>倉庫名稱</th>
                    <th style={{ padding: '12px 8px' }}>狀態</th>
                    <th style={{ padding: '12px 8px', width: '80px' }}>操作</th>
                  </tr>
                </thead>
                <tbody>
                  {warehouses.length === 0 ? (
                    <tr><td colSpan="4" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-secondary)' }}>暫無倉庫資料</td></tr>
                  ) : (
                    warehouses.map(wh => (
                      <tr key={wh.inaacode} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '12px 8px', fontWeight: 600 }}>{wh.inaacode}</td>
                        <td style={{ padding: '12px 8px' }}>{wh.inaa001}</td>
                        <td style={{ padding: '12px 8px' }}>
                          {wh.inaastatus === '1' ? (
                            <span style={{ color: '#10b981', background: 'rgba(16, 185, 129, 0.1)', padding: '2px 6px', borderRadius: '4px', fontSize: '12px' }}>啟用</span>
                          ) : (
                            <span style={{ color: 'var(--text-secondary)', background: 'rgba(255,255,255,0.05)', padding: '2px 6px', borderRadius: '4px', fontSize: '12px' }}>停用</span>
                          )}
                        </td>
                        <td style={{ padding: '12px 8px' }}>
                          <button onClick={() => openEditModal(wh)} style={{ background: 'transparent', color: 'var(--color-primary)', padding: '6px' }}><Edit2 size={16} /></button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            )}

          </div>
        )}

      </div>

      {/* 新增/編輯視窗 (Modal) */}
      {showModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '450px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>
              {isEditMode ? '編輯' : '建立'}
              {activeTab === 'items' && '商品檔案'}
              {activeTab === 'customers' && '客戶檔案'}
              {activeTab === 'vendors' && '供應商檔案'}
            </h3>

            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              {/* ==================== 商品表單 ==================== */}
              {activeTab === 'items' && (
                <>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>商品編號</label>
                    <input type="text" required disabled={isEditMode} placeholder="如: SKU-1001" value={formData.imaacode} onChange={e => setFormData({ ...formData, imaacode: e.target.value })} />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>商品名稱</label>
                    <input type="text" required value={formData.imaa001} onChange={e => setFormData({ ...formData, imaa001: e.target.value })} />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>規格</label>
                    <input type="text" placeholder="如: 100mm * 200mm" value={formData.imaa002} onChange={e => setFormData({ ...formData, imaa002: e.target.value })} />
                  </div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>分類</label>
                      <input type="text" value={formData.imaa003} onChange={e => setFormData({ ...formData, imaa003: e.target.value })} />
                    </div>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>單位</label>
                      <input type="text" value={formData.imaa004} onChange={e => setFormData({ ...formData, imaa004: e.target.value })} />
                    </div>
                  </div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px' }}>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>售價</label>
                      <input type="number" required min="0" value={formData.imaa006} onChange={e => setFormData({ ...formData, imaa006: parseFloat(e.target.value) })} />
                    </div>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>成本</label>
                      <input type="number" required min="0" value={formData.imaa005} onChange={e => setFormData({ ...formData, imaa005: parseFloat(e.target.value) })} />
                    </div>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>安全庫存</label>
                      <input type="number" required min="0" value={formData.imaa007} onChange={e => setFormData({ ...formData, imaa007: parseFloat(e.target.value) })} />
                    </div>
                  </div>
                </>
              )}

              {/* ==================== 客戶/供應商表單 ==================== */}
              {(activeTab === 'customers' || activeTab === 'vendors') && (
                <>
                  <div>
                     <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>編號</label>
                     <input type="text" required disabled={isEditMode} placeholder="如: C001" value={formData.code} onChange={e => setFormData({ ...formData, code: e.target.value })} />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>名稱</label>
                    <input type="text" required value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} />
                  </div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>統一編號</label>
                      <input type="text" value={formData.taxId} onChange={e => setFormData({ ...formData, taxId: e.target.value })} />
                    </div>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>付款條件</label>
                      <input type="text" value={formData.paymentTerms} onChange={e => setFormData({ ...formData, paymentTerms: e.target.value })} />
                    </div>
                  </div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: '10px' }}>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>聯絡人</label>
                      <input type="text" value={formData.contact} onChange={e => setFormData({ ...formData, contact: e.target.value })} />
                    </div>
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>電話</label>
                      <input type="text" value={formData.phone} onChange={e => setFormData({ ...formData, phone: e.target.value })} />
                    </div>
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>地址</label>
                    <input type="text" value={formData.address} onChange={e => setFormData({ ...formData, address: e.target.value })} />
                  </div>
                </>
              )}

              {/* ==================== 倉庫表單 ==================== */}
              {activeTab === 'warehouses' && (
                <>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>倉庫代碼</label>
                    <input type="text" required disabled={isEditMode} placeholder="如: WH01" value={formData.inaacode} onChange={e => setFormData({ ...formData, inaacode: e.target.value })} />
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>倉庫名稱</label>
                    <input type="text" required value={formData.inaa001} onChange={e => setFormData({ ...formData, inaa001: e.target.value })} />
                  </div>
                  {isEditMode && (
                    <div>
                      <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>倉庫狀態</label>
                      <select value={formData.inaastatus} onChange={e => setFormData({ ...formData, inaastatus: e.target.value })}>
                        <option value="1">啟用</option>
                        <option value="0">停用</option>
                      </select>
                    </div>
                  )}
                </>
              )}

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '12px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>儲存</button>
              </div>

            </form>
          </div>
        </div>
      )}

    </div>
  );
}
