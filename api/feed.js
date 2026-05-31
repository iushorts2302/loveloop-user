import { q, send } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const rows = await q(
      `SELECT f.id,f.category,f.title,f.body,f.emoji,f.photo_css,f.hearts,f.cta_type,
              s.name AS item_name,s.deliverable,s.price_krw
       FROM feed_posts f LEFT JOIN store_items s ON s.id=f.store_item_id
       ORDER BY f.published_at DESC`);
    send(res, 200, { feed: rows });
  } catch (e) { send(res, 500, { error: e.message }); }
}
