import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { TrendingUp, FileText, ArrowRight, Percent, DollarSign, Package } from 'lucide-react';

export default function ProfitReport({ userDetails }) {
  const [reportData, setReportData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  // 彙總指標
  const [totals, setTotals] = useState({
    revenue: 0,
    cogs: 0,
    profit: 0,
    avgMargin: 0
  });

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    fetchReport();
  }, [ent, isAdmin]);

  async function fetchReport() {
    setLoading(true);
    setErrorMsg('');
    try {
      let q = supabase.from('profit_report_v').select('*').order('ship_date', { ascending: false });
      if (!isAdmin) {
        q = q.eq('ent', ent);
      }
      const { data, error } = await q;
      if (error) throw error;

      setReportData(data || []);

      // 計算彙總
      const rev = (data || []).reduce((sum, r) => sum + parseFloat(r.revenue || 0), 0);
      const cost = (data || []).reduce((sum, r) => sum + parseFloat(r.cogs || 0), 0);
      const prof = rev - cost;
      const margin = rev > 0 ? (prof / rev) * 100 : 0;

      setTotals({
        revenue: rev,
        cogs: cost,
        profit: prof,
        avgMargin: margin
      });
    } catch (err) {
      setErrorMsg('加載毛利報表失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>毛利分析報表</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>
          分析每筆出貨單明細的營收、落地銷貨成本與毛利毛利率績效。
        </p>
      </div>

      {errorMsg && (
        <div style={{ background: 'rgba(239, 68, 68, 0.1)', border: '1px solid #ef4444', color: '#ef4444', padding: '12px 16px', borderRadius: '8px', fontSize: '14px' }}>
          {errorMsg}
        </div>
      )}

      {/* 總結卡片 */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '16px' }}>
        <div className="glass-panel" style={{ padding: '16px' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>總銷售營收</div>
          <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--text-primary)', marginTop: '4px' }}>
            ${totals.revenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </div>
        </div>
        <div className="glass-panel" style={{ padding: '16px' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>總銷貨成本 (COGS)</div>
          <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--text-secondary)', marginTop: '4px' }}>
            ${totals.cogs.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </div>
        </div>
        <div className="glass-panel" style={{ padding: '16px', borderLeft: '4px solid var(--color-primary)' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>總毛利金額</div>
          <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--color-primary)', marginTop: '4px' }}>
            ${totals.profit.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </div>
        </div>
        <div className="glass-panel" style={{ padding: '16px' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>平均毛利率</div>
          <div style={{ fontSize: '18px', fontWeight: 700, color: '#10b981', marginTop: '4px', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <TrendingUp size={16} />
            {totals.avgMargin.toFixed(1)}%
          </div>
        </div>
      </div>

      {/* 報表清單 */}
      <div className="glass-panel" style={{ padding: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <h3 style={{ fontSize: '16px', fontWeight: 600 }}>銷售毛利明細清單</h3>
          <button className="btn-secondary" onClick={fetchReport} style={{ padding: '6px 12px', fontSize: '13px' }}>
            重新整理
          </button>
        </div>

        {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>數據加載中...</div> : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                  <th style={{ padding: '12px 8px' }}>出貨單號 / 日期</th>
                  <th style={{ padding: '12px 8px' }}>品名規格</th>
                  <th style={{ padding: '12px 8px' }}>出貨數量</th>
                  <th style={{ padding: '12px 8px' }}>銷售營收</th>
                  <th style={{ padding: '12px 8px' }}>出貨成本</th>
                  <th style={{ padding: '12px 8px' }}>銷售毛利</th>
                  <th style={{ padding: '12px 8px' }}>毛利率</th>
                </tr>
              </thead>
              <tbody>
                {reportData.length === 0 ? (
                  <tr>
                    <td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                      暫無毛利明細記錄
                    </td>
                  </tr>
                ) : (
                  reportData.map((row, idx) => {
                    const margin = parseFloat(row.margin_pct);
                    const isPositive = margin >= 0;
                    return (
                      <tr key={`${row.shipment_no}-${row.line_seq}-${idx}`} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '12px 8px' }}>
                          <div style={{ fontWeight: 600 }}>{row.shipment_no}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>{row.ship_date}</div>
                        </td>
                        <td style={{ padding: '12px 8px' }}>
                          <div style={{ fontWeight: 600 }}>{row.item_name || row.item_code}</div>
                          {row.item_spec && (
                            <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                              規格: {row.item_spec}
                            </div>
                          )}
                        </td>
                        <td style={{ padding: '12px 8px' }}>{parseFloat(row.qty).toLocaleString()} 片</td>
                        <td style={{ padding: '12px 8px' }}>${parseFloat(row.revenue || 0).toLocaleString()}</td>
                        <td style={{ padding: '12px 8px', color: 'var(--text-secondary)' }}>${parseFloat(row.cogs || 0).toLocaleString()}</td>
                        <td style={{ padding: '12px 8px', color: row.gross_profit >= 0 ? 'var(--color-primary)' : '#ef4444', fontWeight: 'bold' }}>
                          ${parseFloat(row.gross_profit || 0).toLocaleString(undefined, { minimumFractionDigits: 2 })}
                        </td>
                        <td style={{ padding: '12px 8px' }}>
                          <span style={{ 
                            padding: '4px 8px', 
                            borderRadius: '6px', 
                            fontSize: '12px', 
                            fontWeight: 600,
                            background: isPositive ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)', 
                            color: isPositive ? '#10b981' : '#ef4444' 
                          }}>
                            {isPositive ? '+' : ''}{margin.toFixed(1)}%
                          </span>
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
    </div>
  );
}
