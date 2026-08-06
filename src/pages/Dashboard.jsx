import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { DollarSign, Package, AlertTriangle, TrendingUp, ShoppingBag, Truck } from 'lucide-react';

export default function Dashboard({ userDetails }) {
  const [metrics, setMetrics] = useState({
    receivables: 0,
    payables: 0,
    totalStock: 0,
    warnings: 0
  });
  const [recentSales, setRecentSales] = useState([]);
  const [recentPurchases, setRecentPurchases] = useState([]);
  const [loading, setLoading] = useState(true);

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    fetchDashboardData();
  }, [ent, isAdmin]);

  async function fetchDashboardData() {
    setLoading(true);
    try {
      // 1. 計算應收帳款總額
      let receivablesQuery = supabase.from('xrca_t').select('xrca003');
      if (!isAdmin) receivablesQuery = receivablesQuery.eq('xrcaent', ent);
      const { data: receivablesData } = await receivablesQuery;
      const receivablesTotal = (receivablesData || []).reduce((sum, item) => sum + parseFloat(item.xrca003 || 0), 0);

      // 2. 計算應付帳款總額
      let payablesQuery = supabase.from('apca_t').select('apca003');
      if (!isAdmin) payablesQuery = payablesQuery.eq('apcaent', ent);
      const { data: payablesData } = await payablesQuery;
      const payablesTotal = (payablesData || []).reduce((sum, item) => sum + parseFloat(item.apca003 || 0), 0);

      // 3. 計算現有庫存與安全警報
      let stockQuery = supabase.from('inaj_t').select('inaj003, inaj001');
      if (!isAdmin) stockQuery = stockQuery.eq('inajent', ent);
      const { data: stockData } = await stockQuery;
      
      const stockTotal = (stockData || []).reduce((sum, item) => sum + parseFloat(item.inaj003 || 0), 0);

      // 取得商品的安全庫存量來計算警告數
      let itemQuery = supabase.from('imaa_t').select('imaacode, imaa007');
      if (!isAdmin) itemQuery = itemQuery.eq('imaaent', ent);
      const { data: itemData } = await itemQuery;
      
      let warnCount = 0;
      if (stockData && itemData) {
        stockData.forEach(stockItem => {
          const itemMeta = itemData.find(i => i.imaacode === stockItem.inaj001);
          if (itemMeta && parseFloat(stockItem.inaj003) < parseFloat(itemMeta.imaa007 || 0)) {
            warnCount++;
          }
        });
      }

      setMetrics({
        receivables: receivablesTotal,
        payables: payablesTotal,
        totalStock: stockTotal,
        warnings: warnCount
      });

      // 4. 取得最近 5 筆銷貨訂單
      let salesQuery = supabase.from('xmda_t').select('*').order('xmdadocdt', { ascending: false }).limit(5);
      if (!isAdmin) salesQuery = salesQuery.eq('xmdaent', ent);
      const { data: sales } = await salesQuery;
      setRecentSales(sales || []);

      // 5. 取得最近 5 筆採購單
      let purchasesQuery = supabase.from('pmdl_t').select('*').order('pmdldocdt', { ascending: false }).limit(5);
      if (!isAdmin) purchasesQuery = purchasesQuery.eq('pmdlent', ent);
      const { data: purchases } = await purchasesQuery;
      setRecentPurchases(purchases || []);

    } catch (err) {
      console.error('載入儀表板數據失敗:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return <div style={{ display: 'flex', justifyContent: 'center', padding: '100px', fontSize: '16px', color: 'var(--text-secondary)' }}>正在載入儀表板數據...</div>;
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600, color: 'var(--text-primary)' }}>首頁儀表板</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>
          目前企業: 企業編號 {ent} {isAdmin && <span style={{ color: 'var(--color-primary)', fontWeight: 'bold' }}>(系統管理員)</span>}
        </p>
      </div>

      {/* 數據卡片區域 */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
        
        {/* 卡片 1 - 應收 */}
        <div className="glass-panel glow-hover" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ background: 'rgba(59, 130, 246, 0.1)', padding: '12px', borderRadius: '12px', color: '#3b82f6' }}>
            <DollarSign size={24} />
          </div>
          <div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>應收帳款總額</div>
            <div style={{ fontSize: '20px', fontWeight: 700, marginTop: '4px' }}>${metrics.receivables.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
          </div>
        </div>

        {/* 卡片 2 - 應付 */}
        <div className="glass-panel glow-hover" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ background: 'rgba(217, 119, 6, 0.1)', padding: '12px', borderRadius: '12px', color: '#d97706' }}>
            <DollarSign size={24} />
          </div>
          <div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>應付帳款總額</div>
            <div style={{ fontSize: '20px', fontWeight: 700, marginTop: '4px' }}>${metrics.payables.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
          </div>
        </div>

        {/* 卡片 3 - 總庫存 */}
        <div className="glass-panel glow-hover" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ background: 'rgba(16, 185, 129, 0.1)', padding: '12px', borderRadius: '12px', color: '#10b981' }}>
            <Package size={24} />
          </div>
          <div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>現有總庫存量</div>
            <div style={{ fontSize: '20px', fontWeight: 700, marginTop: '4px' }}>{metrics.totalStock.toLocaleString()} 片</div>
          </div>
        </div>

        {/* 卡片 4 - 警報 */}
        <div className="glass-panel glow-hover" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ background: metrics.warnings > 0 ? 'rgba(239, 68, 68, 0.1)' : 'rgba(156, 163, 175, 0.1)', padding: '12px', borderRadius: '12px', color: metrics.warnings > 0 ? '#ef4444' : 'var(--text-secondary)' }}>
            <AlertTriangle size={24} />
          </div>
          <div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>低於安全庫存商品</div>
            <div style={{ fontSize: '20px', fontWeight: 700, marginTop: '4px', color: metrics.warnings > 0 ? '#ef4444' : 'var(--text-primary)' }}>{metrics.warnings} 筆</div>
          </div>
        </div>

      </div>

      {/* 區塊 2：最近活動 */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
        
        {/* 最近銷貨訂單 */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyBehavior: 'space-between', marginBottom: '16px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <ShoppingBag size={18} style={{ color: 'var(--color-primary)' }} /> 最近銷貨訂單
            </h3>
          </div>
          {recentSales.length === 0 ? (
            <div style={{ color: 'var(--text-secondary)', fontSize: '14px', textAlign: 'center', padding: '24px' }}>暫無訂單記錄</div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {recentSales.map(order => (
                <div key={order.xmdadocno} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '12px', borderBottom: '1px solid var(--border-color)' }}>
                  <div>
                    <div style={{ fontWeight: 500, fontSize: '14px' }}>{order.xmdadocno}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>客戶: {order.xmda004} | 業務: {order.xmda002}</div>
                  </div>
                  <div>
                    <span className={`badge ${order.xmdastatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                      {order.xmdastatus === '1' ? '已確認' : '草稿'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* 最近採購單 */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyBehavior: 'space-between', marginBottom: '16px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Truck size={18} style={{ color: 'var(--color-accent)' }} /> 最近採購單
            </h3>
          </div>
          {recentPurchases.length === 0 ? (
            <div style={{ color: 'var(--text-secondary)', fontSize: '14px', textAlign: 'center', padding: '24px' }}>暫無採購記錄</div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {recentPurchases.map(order => (
                <div key={order.pmdldocno} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '12px', borderBottom: '1px solid var(--border-color)' }}>
                  <div>
                    <div style={{ fontWeight: 500, fontSize: '14px' }}>{order.pmdldocno}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>供應商: {order.pmdl004} | 日期: {order.pmdldocdt}</div>
                  </div>
                  <div>
                    <span className={`badge ${order.pmdlstatus === '1' ? 'badge-confirmed' : 'badge-draft'}`}>
                      {order.pmdlstatus === '1' ? '已確認' : '草稿'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

      </div>
    </div>
  );
}
