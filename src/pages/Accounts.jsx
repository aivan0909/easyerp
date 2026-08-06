import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import { Users, Shield, Plus, CheckCircle, AlertCircle, Key } from 'lucide-react';

export default function Accounts({ userDetails }) {
  const [activeTab, setActiveTab] = useState('users'); // users, roles
  const [usersList, setUsersList] = useState([]);
  const [rolesList, setRolesList] = useState([]);
  const [rolePermissions, setRolePermissions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  // 新增帳號表單
  const [showAddModal, setShowAddModal] = useState(false);
  const [newAccount, setNewAccount] = useState({
    email: '',
    password: '',
    name: '',
    role: 'STAFF',
    enterprise: userDetails.ooagent
  });

  const ent = userDetails.ooagent;
  const isAdmin = userDetails.isAdmin;

  useEffect(() => {
    if (isAdmin) {
      fetchData();
    }
  }, [ent, isAdmin, activeTab]);

  async function fetchData() {
    setLoading(true);
    setErrorMsg('');
    try {
      if (activeTab === 'users') {
        // 1. 取得使用者列表 (ooag_t)
        const { data: usersData, error: uErr } = await supabase.from('ooag_t').select('*');
        if (uErr) throw uErr;

        // 2. 取得所有角色資訊 (rola_t) 以整合是否為管理員
        const { data: rolesData, error: rErr } = await supabase.from('rola_t').select('*');
        if (rErr) throw rErr;

        const integrated = (usersData || []).map(u => {
          const roleMeta = (rolesData || []).find(r => r.rolacode === u.ooag003 && r.rolaent === u.ooagent);
          return {
            ...u,
            roleName: roleMeta ? roleMeta.rola001 : u.ooag003,
            isRoleAdmin: roleMeta ? roleMeta.rola002 === '1' : false
          };
        });
        setUsersList(integrated);
      } else if (activeTab === 'roles') {
        // 1. 取得角色頭 (rola_t)
        const { data: rolesData, error: rErr } = await supabase.from('rola_t').select('*');
        if (rErr) throw rErr;
        setRolesList(rolesData || []);

        // 2. 取得權限明細 (rolb_t)
        const { data: permData, error: pErr } = await supabase.from('rolb_t').select('*');
        if (pErr) throw pErr;
        setRolePermissions(permData || []);
      }
    } catch (err) {
      setErrorMsg('載入權限資料失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateAccount(e) {
    e.preventDefault();
    if (!newAccount.email || !newAccount.password || !newAccount.name) return alert('請填寫完整帳號資訊');

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      // 呼叫 Edge Function
      const { data, error } = await supabase.functions.invoke('admin-create-user', {
        body: {
          email: newAccount.email.trim(),
          password: newAccount.password,
          name: newAccount.name.trim(),
          roleCode: newAccount.role
        }
      });

      if (error) throw error;
      if (data && data.error) throw new Error(data.error);

      setSuccessMsg(`帳號 ${newAccount.name} 建立成功！`);
      setShowAddModal(false);
      setNewAccount({ email: '', password: '', name: '', role: 'STAFF', enterprise: ent });
      fetchData();
    } catch (err) {
      setErrorMsg('建立帳號失敗: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  if (!isAdmin) {
    return (
      <div style={{ padding: '40px', textAlign: 'center', color: '#ef4444' }}>
        <AlertCircle size={48} style={{ margin: '0 auto 16px' }} />
        <h3 style={{ fontSize: '18px', fontWeight: 600 }}>權限不足</h3>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '8px' }}>此模組僅限「系統管理員 (rola002='1')」存取。</p>
      </div>
    );
  }

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: 600 }}>帳號與角色權限</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>系統管理員專屬功能：管理企業成員帳號，以及檢視與編輯角色權限矩陣。</p>
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

      {/* Tab */}
      <div className="glass-panel" style={{ display: 'flex', padding: '4px', gap: '4px' }}>
        <button
          onClick={() => setActiveTab('users')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'users' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'users' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Users size={16} /> <span>使用者帳號管理</span>
        </button>
        <button
          onClick={() => setActiveTab('roles')}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', padding: '10px', fontSize: '14px', background: activeTab === 'roles' ? 'var(--bg-tertiary)' : 'transparent', color: activeTab === 'roles' ? 'var(--color-primary)' : 'var(--text-secondary)' }}
        >
          <Shield size={16} /> <span>角色權限矩陣</span>
        </button>
      </div>

      {/* 主體區塊 */}
      <div className="glass-panel" style={{ padding: '20px', minHeight: '300px' }}>
        
        {/* ==================== 1. 使用者管理 ==================== */}
        {activeTab === 'users' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600 }}>使用者清單</h3>
              <button className="btn-primary" onClick={() => setShowAddModal(true)} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 12px', fontSize: '13px' }}>
                <Plus size={16} /> <span>新增成員</span>
              </button>
            </div>

            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px', textAlign: 'left' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                      <th style={{ padding: '12px 8px' }}>姓名 / Email</th>
                      <th style={{ padding: '12px 8px' }}>企業編號</th>
                      <th style={{ padding: '12px 8px' }}>角色代碼</th>
                      <th style={{ padding: '12px 8px' }}>主題偏好</th>
                      <th style={{ padding: '12px 8px' }}>權限類型</th>
                    </tr>
                  </thead>
                  <tbody>
                    {usersList.length === 0 ? (
                      <tr>
                        <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>暫無成員帳號</td>
                      </tr>
                    ) : (
                      usersList.map(u => (
                        <tr key={u.ooagcode} style={{ borderBottom: '1px solid var(--border-color)' }}>
                          <td style={{ padding: '12px 8px' }}>
                            <div style={{ fontWeight: 600 }}>{u.ooag001}</div>
                            {u.ooag006 && (
                              <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                                {u.ooag006}
                              </div>
                            )}
                            <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>ID: {u.ooagcode}</div>
                          </td>
                          <td style={{ padding: '12px 8px' }}>企業 {u.ooagent}</td>
                          <td style={{ padding: '12px 8px' }}>{u.ooag003}</td>
                          <td style={{ padding: '12px 8px' }}>{u.ooag004}</td>
                          <td style={{ padding: '12px 8px' }}>
                            {u.isRoleAdmin ? (
                              <span style={{ color: 'var(--color-primary)', fontWeight: 'bold', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                <Shield size={14} /> 管理員
                              </span>
                            ) : (
                              <span style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>一般成員</span>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* ==================== 2. 角色權限矩陣 ==================== */}
        {activeTab === 'roles' && (
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>權限分配明細</h3>
            {loading ? <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>載入中...</div> : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                {rolesList.map(role => {
                  const perms = rolePermissions.filter(p => p.rolbcode === role.rolacode && p.rolbent === role.rolaent);
                  return (
                    <div key={role.rolacode} className="glass-panel" style={{ padding: '16px', border: '1px solid var(--border-color)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                        <div style={{ fontWeight: 600, fontSize: '15px' }}>
                          角色: {role.rola001} ({role.rolacode})
                        </div>
                        <span style={{ fontSize: '12px', color: role.rola002 === '1' ? 'var(--color-primary)' : 'var(--text-secondary)', fontWeight: 'bold' }}>
                          {role.rola002 === '1' ? '管理員權限' : '一般權限'}
                        </span>
                      </div>

                      {/* 權限列表 */}
                      <div style={{ overflowX: 'auto' }}>
                        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                          <thead>
                            <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)' }}>
                              <th style={{ padding: '8px', textAlign: 'left' }}>功能模組</th>
                              <th style={{ padding: '8px', textAlign: 'center' }}>可檢視</th>
                              <th style={{ padding: '8px', textAlign: 'center' }}>可編輯</th>
                              <th style={{ padding: '8px', textAlign: 'center' }}>可刪除</th>
                              <th style={{ padding: '8px', textAlign: 'center' }}>可審核</th>
                            </tr>
                          </thead>
                          <tbody>
                            {perms.length === 0 ? (
                              <tr>
                                <td colSpan="5" style={{ padding: '8px', textAlign: 'center', color: 'var(--text-secondary)' }}>無明細設定 (管理員預設擁有所有權限)</td>
                              </tr>
                            ) : (
                              perms.map(p => (
                                <tr key={p.rolbseq} style={{ borderBottom: '1px solid var(--border-color)' }}>
                                  <td style={{ padding: '8px', fontWeight: 500 }}>{p.rolb001}</td>
                                  <td style={{ padding: '8px', textAlign: 'center', color: p.rolb002 === '1' ? 'var(--color-primary)' : 'var(--text-secondary)' }}>{p.rolb002 === '1' ? '✓' : '-'}</td>
                                  <td style={{ padding: '8px', textAlign: 'center', color: p.rolb003 === '1' ? 'var(--color-primary)' : 'var(--text-secondary)' }}>{p.rolb003 === '1' ? '✓' : '-'}</td>
                                  <td style={{ padding: '8px', textAlign: 'center', color: p.rolb004 === '1' ? 'var(--color-primary)' : 'var(--text-secondary)' }}>{p.rolb004 === '1' ? '✓' : '-'}</td>
                                  <td style={{ padding: '8px', textAlign: 'center', color: p.rolb005 === '1' ? 'var(--color-primary)' : 'var(--text-secondary)' }}>{p.rolb005 === '1' ? '✓' : '-'}</td>
                                </tr>
                              ))
                            )}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

      </div>

      {/* Modal - 新增帳號 */}
      {showAddModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: '16px' }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '400px', padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 600 }}>新增企業成員帳號</h3>

            <form onSubmit={handleCreateAccount} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  登入 Email (使用者帳號)
                </label>
                <input
                  type="email"
                  required
                  placeholder="new@example.com"
                  value={newAccount.email}
                  onChange={(e) => setNewAccount({ ...newAccount, email: e.target.value })}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>密碼</label>
                <input
                  type="password"
                  required
                  minLength={6}
                  placeholder="設定登入密碼"
                  value={newAccount.password}
                  onChange={(e) => setNewAccount({ ...newAccount, password: e.target.value })}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>姓名</label>
                <input
                  type="text"
                  required
                  placeholder="輸入成員姓名"
                  value={newAccount.name}
                  onChange={(e) => setNewAccount({ ...newAccount, name: e.target.value })}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>企業編號</label>
                <input
                  type="number"
                  required
                  value={newAccount.enterprise}
                  onChange={(e) => setNewAccount({ ...newAccount, enterprise: e.target.value })}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>角色分配</label>
                <select
                  value={newAccount.role}
                  onChange={(e) => setNewAccount({ ...newAccount, role: e.target.value })}
                >
                  <option value="ADMIN">系統管理員 (ADMIN)</option>
                  <option value="STAFF">一般職員 (STAFF)</option>
                </select>
              </div>

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '12px' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowAddModal(false)} style={{ padding: '8px 16px' }}>取消</button>
                <button type="submit" className="btn-primary" style={{ padding: '8px 16px' }}>確認建立</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
