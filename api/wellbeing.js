import { q, send, DEMO_USER_ID } from './_lib/db.js';
export default async function handler(req, res) {
  try {
    const today = await q(
      `SELECT minutes_used,msg_count,night_ratio,nudge_shown FROM wellbeing_logs
       WHERE user_id=? AND log_date=CURRENT_DATE`, [DEMO_USER_ID]);
    const goal = await q(`SELECT daily_time_goal_min FROM users WHERE id=?`,[DEMO_USER_ID]);
    send(res, 200, { today: today[0] || null, goal_min: goal[0].daily_time_goal_min });
  } catch (e) { send(res, 500, { error: e.message }); }
}
