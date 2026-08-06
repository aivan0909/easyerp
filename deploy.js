const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
require('dotenv').config();

async function main() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const dbPassword = process.env.SUPABASE_DB_PASSWORD;

  if (!supabaseUrl) {
    console.error('錯誤: 請在 .env 檔案中設定 SUPABASE_URL');
    process.exit(1);
  }

  if (!dbPassword) {
    console.error('錯誤: 請在 .env 檔案中設定 SUPABASE_DB_PASSWORD，或在執行時提供環境變數。');
    console.log('\n--- 提示 ---');
    console.log('您也可以在 Supabase 專案的 SQL Editor 內直接貼上以下檔案執行：');
    console.log('1. schema.sql');
    console.log('2. functions.sql');
    console.log('3. rls.sql');
    process.exit(1);
  }

  // 從 SUPABASE_URL 中解析出 project_ref (例如 wiigzcteucvnpkgrmiyw)
  const match = supabaseUrl.match(/https:\/\/(.*)\.supabase\.co/);
  if (!match) {
    console.error('錯誤: 無法從 SUPABASE_URL 解析專案 Ref');
    process.exit(1);
  }
  const projectRef = match[1];

  // 由於本地端 IPv4 限制，使用託管 Pooler 主機，並將使用者名稱設為 postgres.[projectRef]
  const poolerHost = 'aws-0-ap-southeast-1.pooler.supabase.com';
  const connectionString = `postgres://postgres.${projectRef}:${dbPassword}@${poolerHost}:6543/postgres`;
  console.log(`正在連線到 Supabase 資料庫 Pooler (主機: ${poolerHost}, 專案 Ref: ${projectRef})...`);

  const client = new Client({
    connectionString,
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    await client.connect();
    console.log('連線成功！開始部署 SQL 腳本...');

    // 1. 執行 schema.sql
    console.log('正在執行 schema.sql...');
    let schemaSql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    // 動態加上 IF NOT EXISTS，以避免表/索引已存在時發生錯誤
    schemaSql = schemaSql.replace(/CREATE TABLE\s+/gi, 'CREATE TABLE IF NOT EXISTS ');
    schemaSql = schemaSql.replace(/CREATE INDEX\s+/gi, 'CREATE INDEX IF NOT EXISTS ');
    await client.query(schemaSql);
    console.log('schema.sql 執行成功！');

    // 2. 執行 functions.sql
    console.log('正在執行 functions.sql...');
    const functionsSql = fs.readFileSync(path.join(__dirname, 'functions.sql'), 'utf8');
    await client.query(functionsSql);
    console.log('functions.sql 執行成功！');

    // 3. 執行 rls.sql
    console.log('正在執行 rls.sql...');
    let rlsSql = fs.readFileSync(path.join(__dirname, 'rls.sql'), 'utf8');
    // 動態加上 DROP POLICY IF EXISTS 以免重複執行時報錯
    rlsSql = rlsSql.replace(/CREATE POLICY (\w+) ON (\w+)/gi, 'DROP POLICY IF EXISTS $1 ON $2;\nCREATE POLICY $1 ON $2');
    await client.query(rlsSql);
    console.log('rls.sql 執行成功！');

    console.log('\n部署完成！所有表、索引、預存程序與 RLS 政策已成功部署至 Supabase。');
  } catch (err) {
    console.error('部署過程中發生錯誤:', err.message);
    if (err.detail) console.error('詳細資訊:', err.detail);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
