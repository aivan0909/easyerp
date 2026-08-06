import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { Package, History, AlertTriangle, ArrowUpRight, ArrowDownLeft } from 'lucide-react';

export default function Stock({ userDetails }) {
  const [activeTab, setActiveTab] = useState('summary'); // summary, ledger
  const [stockSummary, setStockSummary] = useState([]);
  const [ledger, setLedger] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    fetchData();
  }, [ent, isAdmin, activeTab]);

  async function fetchData() {
    setLoading(true);
    setErrorMsg('');
    try {
      if (activeTab === 'summary') {
        // 1. 取得庫存彙總 (inaj_t)
        let q = supabase.from('inaj_t').select('*');
        if (!isAdmin) q = q.eq('inajent', ent);
        const { data: stockData } = await q;

        // 2. 取得商品資訊 (安全庫存與名稱)
        let itemQ = supabase.from('imaa_t').select('imaacode, imaa001, imaa004, imaa007');
        if (!isAdmin) itemQ = itemQ.eq('imaaent', ent);
        const { data: itemData } = await itemQ;

        // 3. 組合數據
        const formatted = (stockData || []).map(stock => {
          const meta = (itemData || []).find(i => i.imaacode === stock.inaj001);
          return {
            ...stock,
            itemName: meta ? meta.imaa001 : '未知商品',
            unit: meta ? meta.imaa004 : '片',
            safetyQty: meta ? parseFloat(meta.imaa007 || 0) : 0
          };
        });
        setStockSummary(formatted);
      } else if (activeTab === 'ledger') {
        // 取得庫存異動明細 (inag_t)
        let q = supabase.from('inag_t').select('*').order('inagdocdt', { ascending: false });
        if (!isAdmin) q = q.eq('inagent', ent);
        const { data: ledgerData } = await q;
        setLedger(ledgerData || []);
      }
    } catch (err) {
      setErrorMsg('載入庫存數據失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>庫存查詢</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>即時監控倉庫存量、安全庫存警報，以及追蹤庫存出入庫異動軌跡。</p>
      </div>

      {errorMsg && (
        <div style={{ background: 'rgba(239, 68, 68, 0.1)', border: '1px solid #ef4444', color: '#ef4444', padding: '12px 16px', borderRadius: '8px', fontSize: '14px' }}>
          {errorMsg}
        </div>
      )}

      {/* Tab 切換器 */}
      <div className="glass-panel" style={{ display: 'flex', padding: '4px', gap: '4px' }}>
        <button
          onClick={() => setActiveTab('summary')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'summary' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'summary' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Package size={16} /> <span>即時庫存彙總</span>
        </button>
        <button
          onClick={() => setActiveTab('ledger')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'ledger' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'ledger' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <History size={16} /> <span>異動明細分類帳</span>
        </button>
      </div>

      {/* 主體區塊 */}
      <div className="glass-panel" style={{ padding: '20px', minHeight: '300px' }}>
        
        {/* ==================== 1. 即時庫存彙總 ==================== */}
        {activeTab === 'summary' && (
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>庫存現有量</h3>
            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                      <th style={{ padding: '12px 8px' }}>商品編號</th>
                      <th style={{ padding: '12px 8px' }}>商品名稱</th>
                      <th style={{ padding: '12px 8px' }}>倉庫</th>
                      <th style={{ padding: '12px 8px' }}>現有庫存</th>
                      <th style={{ padding: '12px 8px' }}>安全庫存量</th>
                      <th style={{ padding: '12px 8px' }}>狀態</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stockSummary.length === 0 ? (
                      <tr>
                        <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>無庫存數據</td>
                      </tr>
                    ) : (
                      stockSummary.map((st, idx) => {
                        const isLow = parseFloat(st.inaj003) < st.safetyQty;
                        return (
                          <tr key={idx} style={{ borderBottom: '1px solid var(--border-color)' }}>
                            <td style={{ padding: '12px 8px', fontWeight: 600 }}>{st.inaj001}</td>
                            <td style={{ padding: '12px 8px' }}>{st.itemName}</td>
                            <td style={{ padding: '12px 8px' }}>{st.inaj002}</td>
                            <td style={{ padding: '12px 8px', fontWeight: 600, color: isLow ? '#ef4444' : 'var(--text-primary)' }}>
                              {parseFloat(st.inaj003).toLocaleString()} {st.unit}
                            </td>
                            <td style={{ padding: '12px 8px' }}>{st.safetyQty.toLocaleString()} {st.unit}</td>
                            <td style={{ padding: '12px 8px' }}>
                              {isLow ? (
                                <span style={{ color: '#ef4444', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', fontWeight: 500 }}>
                                  <AlertTriangle size={14} /> 偏低
                                </span>
                              ) : (
                                <span style={{ color: '#10b981', fontSize: '12px', fontWeight: 500 }}>正常</span>
                              )}
                            </td>
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

        {/* ==================== 2. 異動明細分類帳 ==================== */}
        {activeTab === 'ledger' && (
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>庫存進出軌跡</h3>
            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {ledger.length === 0 ? <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '40px' }}>暫無異動記錄</div> : (
                  ledger.map(lg => {
                    const isPlus = lg.inag007 === '+';
                    return (
                      <div key={lg.inagdocno} className="glass-panel" style={{ padding: '12px 16px', border: '1px solid var(--border-color)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                          <div style={{ background: isPlus ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)', color: isPlus ? '#10b981' : '#ef4444', padding: '8px', borderRadius: '50%' }}>
                            {isPlus ? <ArrowDownLeft size={16} /> : <ArrowUpRight size={16} />}
                          </div>
                          <div>
                            <div style={{ fontSize: '14px', fontWeight: 600 }}>{lg.inag001} ({lg.inag002} 倉)</div>
                            <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                              類型: {lg.inag003} | 來源單: {lg.inag005} (序號: {lg.inag006})
                            </div>
                          </div>
                        </div>
                        <div style={{ textAlign: 'right' }}>
                          <div style={{ fontSize: '15px', fontWeight: 700, color: isPlus ? '#10b981' : '#ef4444' }}>
                            {lg.inag007}{parseFloat(lg.inag008).toLocaleString()}
                          </div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                            結餘: {parseFloat(lg.inag009).toLocaleString()}
                          </div>
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            )}
          </div>
        )}

      </div>
    </div>
  );
}
