import { q, send, DEMO_USER_ID } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    if (req.method === 'DELETE') {
      const id = req.query && req.query.id;
      if (id === 'all') {
        await q(`UPDATE memories SET deleted_at=NOW() WHERE user_id=? AND deleted_at IS NULL`,[DEMO_USER_ID]);
      } else {
        await q(`UPDATE memories SET deleted_at=NOW() WHERE id=? AND user_id=?`,[id, DEMO_USER_ID]);
      }
      return send(res,200,{ok:true});
    }
    const rows = await q(
      `SELECT id,label,tag,value FROM memories
       WHERE user_id=? AND consented=1 AND deleted_at IS NULL ORDER BY created_at`, [DEMO_USER_ID]);
    send(res, 200, { memories: rows });
  } catch (e) { send(res, 500, { error: e.message }); }
}
