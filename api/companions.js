import { q, send, DEMO_USER_ID } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const rows = await q(
      `SELECT c.persona_id,c.days_together,c.last_message,c.last_time_label,
              p.name,p.initial,p.style_label,p.grad_css
       FROM companions c JOIN personas p ON p.id=c.persona_id
       WHERE c.user_id=? ORDER BY c.days_together DESC`, [DEMO_USER_ID]);
    send(res, 200, { companions: rows });
  } catch (e) { send(res, 500, { error: e.message }); }
}
