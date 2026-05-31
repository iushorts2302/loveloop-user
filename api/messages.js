import { q, send, DEMO_USER_ID } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const personaId = (req.query && req.query.persona) || 'P1';
    if (req.method === 'POST') {
      let body=''; await new Promise(r=>{req.on('data',c=>body+=c);req.on('end',r);});
      const { text } = JSON.parse(body || '{}');
      if (!text) return send(res,400,{error:'text required'});
      await q(`INSERT INTO messages(user_id,persona_id,sender,kind,body) VALUES(?,?,'user','text',?)`,
        [DEMO_USER_ID, personaId, text]);
      // 데모 응답(존중형). 실제로는 모델 응답 + 가드레일 필터.
      const reply = '그랬구나. 네 얘기 더 듣고 싶어. 천천히 말해줘 — 네가 편한 만큼만.';
      await q(`INSERT INTO messages(user_id,persona_id,sender,kind,body) VALUES(?,?,'ai','text',?)`,
        [DEMO_USER_ID, personaId, reply]);
      return send(res,200,{reply});
    }
    const rows = await q(
      `SELECT sender,kind,body,voice_seconds,created_at FROM messages
       WHERE user_id=? AND persona_id=? ORDER BY created_at`, [DEMO_USER_ID, personaId]);
    send(res, 200, { messages: rows });
  } catch (e) { send(res, 500, { error: e.message }); }
}
