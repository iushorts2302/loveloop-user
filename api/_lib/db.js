// api/_lib/db.js
// DB 자격증명은 환경변수에서만 읽는다. 평문 하드코딩 절대 금지.
// Vercel > Project > Settings > Environment Variables 에 설정:
//   DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, DB_CA_CERT(선택)
import mysql from 'mysql2/promise';

let pool;
export function getPool() {
  if (!pool) {
    const {
      DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, DB_CA_CERT,
    } = process.env;
    if (!DB_HOST || !DB_USER || !DB_PASSWORD || !DB_NAME) {
      throw new Error('DB env vars missing. Set them in Vercel Environment Variables.');
    }
    pool = mysql.createPool({
      host: DB_HOST,
      port: DB_PORT ? Number(DB_PORT) : 3306,
      user: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME,
      charset: 'utf8mb4',
      waitForConnections: true,
      connectionLimit: 5,
      // Aiven 은 TLS 필수. CA 인증서를 넣으면 검증, 없으면 최소 TLS.
      ssl: DB_CA_CERT ? { ca: DB_CA_CERT } : { rejectUnauthorized: false },
    });
  }
  return pool;
}

export async function q(sql, params = []) {
  const [rows] = await getPool().execute(sql, params);
  return rows;
}

// 데모: 단일 사용자 컨텍스트. 실제로는 인증 세션에서 user_id 도출.
export const DEMO_USER_ID = 1;

export function send(res, status, data) {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.statusCode = status;
  res.end(JSON.stringify(data));
}
