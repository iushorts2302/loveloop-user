import { q, send } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const rows = await q(
      `SELECT id,name,initial,style_label,grad_css,hero_css,emoji,intro_line,about,tags
       FROM personas WHERE is_active=1 ORDER BY id`);
    send(res, 200, { personas: rows });
  } catch (e) { send(res, 500, { error: e.message }); }
}
