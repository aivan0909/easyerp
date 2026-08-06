# ERP 系統 — Supabase 部署說明

已在本機 PostgreSQL 16 完整測試通過（含成功案例與庫存不足的 rollback 案例），可以直接部署到 Supabase。

## 檔案說明

| 檔案 | 說明 |
|---|---|
| `schema.sql` | 22 張表的完整建表語法 + 索引設計 |
| `functions.sql` | 6 支函式，涵蓋銷貨線與採購線(見下表) |

## functions.sql 內含函式清單

| 函式 | 說明 |
|---|---|
| `fn_next_docno(prefix)` | 單號產生器(資料庫序號表,多人同時呼叫不會重複) |
| `fn_record_reconciliation(...)` | 核銷服務(多型,同時支援 SO/PO 兩種來源單據類型) |
| `fn_stock_out(...)` | 庫存出庫(銷貨用,檢查是否足夠) |
| `fn_stock_in(...)` | 庫存入庫(採購用,對稱於 fn_stock_out) |
| `confirm_shipment(ent, docno, user)` | **核心動作**：確認出貨 → 扣庫存 + 核銷回訂單 + 產生應收單 |
| `confirm_goods_receipt(ent, docno, user)` | **核心動作**：確認收貨 → 加庫存 + 核銷回採購單 + 產生應付單(對稱於上者) |

## 已完整測試的情境(本機 PostgreSQL 16)

| 情境 | 結果 |
|---|---|
| 確認出貨成功 | 庫存扣帳、核銷寫入(狀態=完成)、訂單已出貨量回寫、應收單自動產生 |
| 確認出貨-庫存不足 | 正確拋出 `STOCK_INSUFFICIENT`，庫存/核銷/出貨單狀態完全沒被異動 |
| 確認收貨成功 | 庫存加帳、核銷寫入、採購單已入庫量回寫、應付單自動產生 |
| 確認收貨-超收(收貨量超過採購單訂購量) | 正確拋出 `QTY_EXCEED_SOURCE`，即使庫存已經先加了 80 片，仍完全回滾，沒有留下 130 片的錯誤庫存或多餘的應付單 |

## 部署步驟

1. 到 [supabase.com](https://supabase.com) 建立新專案
2. 左側選單 **SQL Editor** → 新增查詢
3. 貼上 `schema.sql` 內容 → Run
4. 再貼上 `functions.sql` 內容 → Run
5. 完成，Supabase 會自動幫這些表產生 REST API，`confirm_shipment` 這類函式也能直接被前端呼叫(稱為 RPC)

## 前端呼叫方式(以 supabase-js 為例)

```js
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// 建立訂單(標準 CRUD,直接用 Supabase 內建 REST API 即可)
const { data: order } = await supabase.from('xmda_t').insert({
  xmdaent: 1, xmdadocno: 'SO-0003', xmda004: 'C001', xmda002: '林業務'
}).select()

// 確認出貨 —— 呼叫 RPC，交易邏輯在資料庫內完成，前端不用自己處理 rollback
const { data, error } = await supabase.rpc('confirm_shipment', {
  p_ent: 1,
  p_docno: 'SH-0001',
  p_user: (await supabase.auth.getUser()).data.user.id
})

if (error) {
  // error.message 格式為 "CODE: 說明文字"，例如 "STOCK_INSUFFICIENT: 商品 SKU-20114 庫存不足..."
  const code = error.message.split(':')[0]
  if (code === 'STOCK_INSUFFICIENT') {
    // 前端跳庫存不足提示
  }
} else {
  console.log('應收單已產生:', data.receivableDocNo, data.receivableAmount)
}
```

**重點**：像「確認出貨」這種會動到多張表的操作，前端**只呼叫一次 RPC**，不要自己分別呼叫 `.from('inag_t').insert()`、`.from('xrca_t').insert()`...等多支個別 API 拼湊，那樣沒有交易保護，任何一步網路中斷或失敗就會產生半套資料。

```js
// 確認收貨 —— 採購線對稱範例
const { data, error } = await supabase.rpc('confirm_goods_receipt', {
  p_ent: 1,
  p_docno: 'GR-0001',
  p_user: (await supabase.auth.getUser()).data.user.id
})
if (!error) {
  console.log('應付單已產生:', data.payableDocNo, data.payableAmount)
}
```

## 建議請 Antigravity 接手的部分

1. **Row Level Security (RLS) 政策** — 每張表要依 `rola_t`/`rolb_t` 權限設計加上 RLS，這部分因為牽涉到 Supabase Auth 的細節設定，建議讓 Antigravity 依照專案實際的 Auth 設定調整
2. **前端 RWD 介面**，呼叫上面這些 RPC 與標準 REST API，畫面稿可參考先前提供的 `erp-full-flow-themed.html`
3. 銷貨/採購訂單建立、確認等**單純 CRUD 動作**，可直接用 Supabase 內建 REST API(`.from('xmda_t').insert()`)，不需要額外寫函式；只有「確認出貨/確認收貨」這種跨多表的複合動作才需要呼叫 RPC

## 與先前 Node.js PoC 版本的差異

| 項目 | Node.js PoC | Supabase 版本 |
|---|---|---|
| 交易邊界 | App 層 `db.transaction()` | 資料庫函式本身(更安全，不受網路中斷影響) |
| 併發鎖定 | 沒做(demo用) | `FOR UPDATE` 鎖定關鍵行，避免多人同時搶庫存 |
| 單號產生 | 記憶體計數器(重啟歸零) | 資料庫序號表，多人同時呼叫也不會重複 |
| 認證 | 無 | 對應 Supabase Auth |
