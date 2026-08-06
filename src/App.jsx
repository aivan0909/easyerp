import React, { useState, useEffect } from 'react';
import { supabase } from './supabase';
import Dashboard from './pages/Dashboard';
import Sales from './pages/Sales';
import Purchases from './pages/Purchases';
import Stock from './pages/Stock';
import Accounts from './pages/Accounts';
import MasterData from './pages/MasterData';
import { LayoutDashboard, ShoppingBag, Truck, Package, Users, Settings, LogOut, Palette, Menu, X, Database } from 'lucide-react';

export default function App() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [userDetails, setUserDetails] = useState(null);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [theme, setTheme] = useState('obsidian'); // obsidian, aurora, ocean, amber
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // 登入表單
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState('');

  // 註冊模式切換
  const [isSignUp, setIsSignUp] = useState(false);

  useEffect(() => {
    // 監聽登入狀態
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) {
        loadUserDetails(session.user);
      } else {
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) {
        loadUserDetails(session.user);
      } else {
        setUserDetails(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  // 套用主題 class 到 body
  useEffect(() => {
    document.body.className = '';
    document.body.classList.add(`theme-${theme}`);
  }, [theme]);

  // 載入與初始化資料庫使用者檔案 (ooag_t)
  async function loadUserDetails(user) {
    try {
      // 1. 查詢 ooag_t 是否已有該使用者
      const { data, error } = await supabase
        .from('ooag_t')
        .select('*')
        .eq('ooagcode', user.id)
        .single();

      if (error && error.code === 'PGRST116') {
        // PGRST116 代表沒有資料，自動為其新增基本檔案
        console.log('在 ooag_t 中未找到使用者檔案，正在為其建立...');
        
        const defaultName = user.email.split('@')[0];
        
        // 預設建立為 STAFF (一般職員)，管理員帳號已在 seed.sql 中建立
        const newUserProfile = {
          ooagent: 1,
          ooagcode: user.id,
          ooag001: defaultName,
          ooag003: 'STAFF',
          ooag004: 'obsidian',
          ooagstatus: '1'
        };

        const { error: insErr } = await supabase.from('ooag_t').insert(newUserProfile);
        if (insErr) throw insErr;

        setUserDetails({ ...newUserProfile, isAdmin: false });
        setTheme('obsidian');
      } else if (data) {
        // 2. 取得使用者的管理員屬性 (對應 rola_t)
        const { data: roleData } = await supabase
          .from('rola_t')
          .select('rola002')
          .eq('rolaent', data.ooagent)
          .eq('rolacode', data.ooag003)
          .single();

        const isAdminUser = roleData ? roleData.rola002 === '1' : false;
        
        setUserDetails({
          ...data,
          isAdmin: isAdminUser
        });

        // 套用儲存的主題偏好
        if (data.ooag004) {
          setTheme(data.ooag004);
        }
      }
    } catch (err) {
      console.error('載入使用者偏好失敗:', err.message);
    } finally {
      setLoading(false);
    }
  }

  // 變更主題偏好並更新至資料庫
  async function handleThemeChange(newTheme) {
    setTheme(newTheme);
    if (userDetails) {
      try {
        await supabase
          .from('ooag_t')
          .update({ ooag004: newTheme })
          .eq('ooagent', userDetails.ooagent)
          .eq('ooagcode', userDetails.ooagcode);
        
        setUserDetails({ ...userDetails, ooag004: newTheme });
      } catch (err) {
        console.error('更新主題偏好失敗:', err);
      }
    }
  }

  // 處理認證 - 登入/註冊
  async function handleAuth(e) {
    e.preventDefault();
    setAuthLoading(true);
    setAuthError('');

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        alert('註冊成功！請直接登入。');
        setIsSignUp(false);
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      }
    } catch (err) {
      setAuthError(err.message);
    } finally {
      setAuthLoading(false);
    }
  }

  async function handleSignOut() {
    if (window.confirm('確定要登出系統嗎？')) {
      await supabase.auth.signOut();
      setActiveTab('dashboard');
    }
  }

  // 載入畫面
  if (loading) {
    return (
      <div style={{ display: 'flex', flexFlow: 'column', height: '100vh', alignItems: 'center', justifyContent: 'center', background: '#0b0f19', color: '#f3f4f6', gap: '16px' }}>
        <div style={{ width: '40px', height: '40px', border: '4px solid #10b981', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
        <div style={{ fontSize: '15px', color: '#9ca3af' }}>正在載入 ERP 系統系統設定...</div>
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    );
  }

  // ==================== 未登入頁面 (Login) ====================
  if (!session) {
    return (
      <div style={{ display: 'flex', minHeight: '100vh', alignItems: 'center', justifyContent: 'center', background: 'radial-gradient(circle at top right, rgba(16, 185, 129, 0.1), transparent 40%), radial-gradient(circle at bottom left, rgba(139, 92, 246, 0.1), transparent 40%), #0b0f19', padding: '16px' }}>
        <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '400px', padding: '32px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
          
          {/* Logo */}
          <div style={{ textAlign: 'center' }}>
            <span style={{ fontSize: '48px' }}>📦</span>
            <h1 style={{ fontSize: '24px', fontWeight: 700, letterSpacing: '-0.5px', marginTop: '12px' }}>Easy ERP</h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '13px', marginTop: '6px' }}>手機優先行動化企業資源規劃系統</p>
          </div>

          {/* 表單 */}
          <form onSubmit={handleAuth} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '12px', color: '#9ca3af', marginBottom: '6px' }}>Email 帳號</label>
              <input type="email" required placeholder="name@company.com" value={email} onChange={e => setEmail(e.target.value)} />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '12px', color: '#9ca3af', marginBottom: '6px' }}>密碼</label>
              <input type="password" required placeholder="••••••••" value={password} onChange={e => setPassword(e.target.value)} />
            </div>

            {authError && (
              <div style={{ background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', fontSize: '13px', padding: '10px', borderRadius: '6px', border: '1px solid rgba(239,68,68,0.2)' }}>
                {authError}
              </div>
            )}

            <button type="submit" disabled={authLoading} className="btn-primary" style={{ padding: '12px', fontSize: '15px', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {authLoading ? '請稍後...' : (isSignUp ? '註冊成員帳號' : '安全登入')}
            </button>
          </form>

          {/* 切換註冊/登入 */}
          <div style={{ textAlign: 'center', fontSize: '13px', color: '#9ca3af' }}>
            {isSignUp ? (
              <span>已有帳號？ <button type="button" onClick={() => { setIsSignUp(false); setAuthError(''); }} style={{ background: 'transparent', color: '#10b981', fontWeight: 600 }}>立即登入</button></span>
            ) : (
              <span>沒有帳號？ <button type="button" onClick={() => { setIsSignUp(true); setAuthError(''); }} style={{ background: 'transparent', color: '#10b981', fontWeight: 600 }}>註冊新帳號</button></span>
            )}
          </div>

          {/* 測試資訊防呆 */}
          <div style={{ borderTop: '1px solid rgba(255,255,255,0.06)', paddingTop: '16px', fontSize: '12px', color: '#6b7280', display: 'flex', flexDirection: 'column', gap: '4px' }}>
            <span style={{ fontWeight: 600, color: '#9ca3af' }}>💡 測試登入指南:</span>
            <span>如果您是第一次使用，可點選「註冊新帳號」註冊您的 Email 並登入，系統將會自動初始化您的企業配置，並賦予您系統管理員權限！</span>
          </div>

        </div>
      </div>
    );
  }

  // ==================== 登入後的 ERP 主頁面 ====================
  return (
    <div style={{ display: 'flex', minHeight: '100vh', flexDirection: 'column' }}>
      
      {/* 樣式定義: 支援 RWD 的大綱版型與動畫 */}
      <style>{`
        .app-layout {
          display: flex;
          flex: 1;
        }
        .sidebar {
          width: 240px;
          background: var(--bg-secondary);
          border-right: 1px solid var(--border-color);
          display: flex;
          flex-direction: column;
          padding: 20px;
          gap: 8px;
        }
        .main-content {
          flex: 1;
          padding: 24px;
          overflow-y: auto;
          padding-bottom: 80px; /* 手機端避開底欄 */
        }
        .topbar {
          height: 60px;
          background: var(--bg-secondary);
          border-bottom: 1px solid var(--border-color);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0 24px;
          position: sticky;
          top: 0;
          z-index: 10;
        }
        .bottom-nav {
          display: none;
          position: fixed;
          bottom: 0;
          left: 0;
          right: 0;
          height: 60px;
          background: var(--glass-bg);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border-top: 1px solid var(--glass-border);
          justify-content: space-around;
          align-items: center;
          z-index: 20;
        }
        .nav-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 4px;
          background: transparent;
          color: var(--text-secondary);
          font-size: 11px;
          padding: 6px 12px;
        }
        .nav-item.active {
          color: var(--color-primary);
        }

        /* RWD 規則：手機優先 */
        @media (max-width: 768px) {
          .sidebar {
            display: none;
          }
          .bottom-nav {
            display: flex;
          }
          .main-content {
            padding: 16px;
            padding-bottom: 80px;
          }
          .topbar {
            padding: 0 16px;
          }
        }
      `}</style>

      {/* Topbar */}
      <header className="topbar">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ fontSize: '24px' }}>📦</span>
          <span style={{ fontWeight: 700, fontSize: '18px', color: 'var(--text-primary)' }}>Easy ERP</span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          {/* 主題切換器 */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'var(--bg-tertiary)', padding: '4px 8px', borderRadius: '8px', border: '1px solid var(--border-color)' }}>
            <Palette size={14} style={{ color: 'var(--text-secondary)' }} />
            <select
              value={theme}
              onChange={e => handleThemeChange(e.target.value)}
              style={{ background: 'transparent', border: 'none', padding: 0, fontSize: '12px', width: 'auto', fontWeight: 600, color: 'var(--text-primary)' }}
            >
              <option value="obsidian">曜石暗</option>
              <option value="aurora">極光綠</option>
              <option value="ocean">深海藍</option>
              <option value="amber">暖陽沙</option>
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <span style={{ fontSize: '13px', color: 'var(--text-secondary)', display: 'inline-block' }}>
              Hi, <strong style={{ color: 'var(--text-primary)' }}>{userDetails?.ooag001}</strong>
            </span>
            {userDetails?.isAdmin && (
              <button 
                onClick={() => setActiveTab('accounts')} 
                style={{ background: 'transparent', color: activeTab === 'accounts' ? 'var(--color-primary)' : 'var(--text-secondary)', padding: '6px' }} 
                title="帳號管理"
              >
                <Users size={18} />
              </button>
            )}
            <button onClick={handleSignOut} style={{ background: 'transparent', color: '#ef4444', padding: '6px' }} title="登出">
              <LogOut size={18} />
            </button>
          </div>
        </div>
      </header>

      <div className="app-layout">
        {/* Sidebar (僅在 Desktop 顯示) */}
        <aside className="sidebar">
          <button
            onClick={() => setActiveTab('dashboard')}
            className={`nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}
            style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'dashboard' ? 'var(--bg-tertiary)' : 'transparent' }}
          >
            <LayoutDashboard size={18} /> <span style={{ fontWeight: activeTab === 'dashboard' ? 600 : 400 }}>首頁儀表板</span>
          </button>
          
          <button
            onClick={() => setActiveTab('sales')}
            className={`nav-item ${activeTab === 'sales' ? 'active' : ''}`}
            style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'sales' ? 'var(--bg-tertiary)' : 'transparent' }}
          >
            <ShoppingBag size={18} /> <span style={{ fontWeight: activeTab === 'sales' ? 600 : 400 }}>銷貨與應收</span>
          </button>

          <button
            onClick={() => setActiveTab('purchases')}
            className={`nav-item ${activeTab === 'purchases' ? 'active' : ''}`}
            style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'purchases' ? 'var(--bg-tertiary)' : 'transparent' }}
          >
            <Truck size={18} /> <span style={{ fontWeight: activeTab === 'purchases' ? 600 : 400 }}>採購與應付</span>
          </button>

          <button
            onClick={() => setActiveTab('stock')}
            className={`nav-item ${activeTab === 'stock' ? 'active' : ''}`}
            style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'stock' ? 'var(--bg-tertiary)' : 'transparent' }}
          >
            <Package size={18} /> <span style={{ fontWeight: activeTab === 'stock' ? 600 : 400 }}>庫存查詢</span>
          </button>

          <button
            onClick={() => setActiveTab('masterdata')}
            className={`nav-item ${activeTab === 'masterdata' ? 'active' : ''}`}
            style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'masterdata' ? 'var(--bg-tertiary)' : 'transparent' }}
          >
            <Database size={18} /> <span style={{ fontWeight: activeTab === 'masterdata' ? 600 : 400 }}>基本資料</span>
          </button>

          {userDetails?.isAdmin && (
            <button
              onClick={() => setActiveTab('accounts')}
              className={`nav-item ${activeTab === 'accounts' ? 'active' : ''}`}
              style={{ width: '100%', display: 'flex', flexDirection: 'row', gap: '12px', alignItems: 'center', padding: '12px', borderRadius: '8px', fontSize: '14px', background: activeTab === 'accounts' ? 'var(--bg-tertiary)' : 'transparent' }}
            >
              <Users size={18} /> <span style={{ fontWeight: activeTab === 'accounts' ? 600 : 400 }}>帳號管理</span>
            </button>
          )}
        </aside>

        {/* Main Content Area */}
        <main className="main-content">
          {activeTab === 'dashboard' && <Dashboard userDetails={userDetails} />}
          {activeTab === 'sales' && <Sales userDetails={userDetails} />}
          {activeTab === 'purchases' && <Purchases userDetails={userDetails} />}
          {activeTab === 'stock' && <Stock userDetails={userDetails} />}
          {activeTab === 'masterdata' && <MasterData userDetails={userDetails} />}
          {activeTab === 'accounts' && <Accounts userDetails={userDetails} />}
        </main>
      </div>

      {/* Bottom Nav Bar (手機端底部固定導覽，固定 5 個高頻主要入口) */}
      <nav className="bottom-nav">
        <button onClick={() => setActiveTab('dashboard')} className={`nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}>
          <LayoutDashboard size={20} />
          <span>儀表板</span>
        </button>
        <button onClick={() => setActiveTab('sales')} className={`nav-item ${activeTab === 'sales' ? 'active' : ''}`}>
          <ShoppingBag size={20} />
          <span>銷貨</span>
        </button>
        <button onClick={() => setActiveTab('purchases')} className={`nav-item ${activeTab === 'purchases' ? 'active' : ''}`}>
          <Truck size={20} />
          <span>採購</span>
        </button>
        <button onClick={() => setActiveTab('stock')} className={`nav-item ${activeTab === 'stock' ? 'active' : ''}`}>
          <Package size={20} />
          <span>庫存</span>
        </button>
        <button onClick={() => setActiveTab('masterdata')} className={`nav-item ${activeTab === 'masterdata' ? 'active' : ''}`}>
          <Database size={20} />
          <span>基本資料</span>
        </button>
      </nav>

    </div>
  );
}
