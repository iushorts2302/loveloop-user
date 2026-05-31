import { q, send, DEMO_USER_ID } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const items = await q(
      `SELECT id,sku,name,deliverable,icon,price_krw,item_type FROM store_items
       WHERE is_active=1 ORDER BY price_krw`);
    const collection = await q(
      `SELECT item_type,count,status_label FROM user_collection WHERE user_id=?`, [DEMO_USER_ID]);
    const spent = await q(
      `SELECT COALESCE(SUM(amount_krw),0) AS spent_today FROM purchases
       WHERE user_id=? AND status='completed' AND DATE(created_at)=CURRENT_DATE`, [DEMO_USER_ID]);
    const cap = await q(`SELECT daily_spend_cap FROM users WHERE id=?`,[DEMO_USER_ID]);
    send(res, 200, { items, collection,
      spent_today: spent[0].spent_today, daily_cap: cap[0].daily_spend_cap });
  } catch (e) { send(res, 500, { error: e.message }); }
}
