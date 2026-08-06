const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
require('dotenv').config();

async function main() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const dbPassword = process.env.SUPABASE_DB_PASSWORD;

  if (!supabaseUrl || !dbPassword) {
    console.error('錯誤: 請在 .env 檔案中設定 SUPABASE_URL 與 SUPABASE_DB_PASSWORD');
    process.exit(1);
  }

  const match = supabaseUrl.match(/https:\/\/(.*)\.supabase\.co/);
  if (!match) {
    console.error('錯誤: 無法解析專案 Ref');
    process.exit(1);
  }
  const projectRef = match[1];

  const poolerHost = 'aws-0-ap-southeast-1.pooler.supabase.com';
  const connectionString = `postgres://postgres.${projectRef}:${dbPassword}@${poolerHost}:6543/postgres`;
  console.log(`正在連線到 Supabase 資料庫 Pooler 以寫入種子資料...`);

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('連線成功！正在執行 seed.sql...');

    const seedSql = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf8');
    await client.query(seedSql);

    console.log('seed.sql 執行成功！預設角色與第一個系統管理員帳號已建立。');
  } catch (err) {
    console.error('執行種子資料時發生錯誤:', err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
