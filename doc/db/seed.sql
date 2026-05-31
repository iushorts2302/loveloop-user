-- ============================================================
-- Loveloop AI — Seed Data
-- 현재 두 웹에 하드코딩되어 있던 값을 그대로 이관.
-- ⚠️ 표시 항목은 운영 합의가 필요한 값(임시 시드).
-- ============================================================
SET NAMES utf8mb4;

-- ---------- personas ----------
INSERT INTO personas (id,name,initial,style_label,grad_css,hero_css,emoji,intro_line,about,tags) VALUES
('P1','서도진','서','든든한 조력형','linear-gradient(135deg,#5b6672,#2b3742)','linear-gradient(135deg,#8c7a64,#4a4032)','🧭','힘든 일 있었구나. 네 페이스대로 가도 괜찮아. 필요하면 들을게.','묵묵히 곁을 지키는 든든한 사람. 네 페이스를 존중하고, 필요할 때 조용히 손을 내밀어요.','["#존중","#차분함","#응원"]'),
('P2','연하진','연','밝은 응원형','linear-gradient(135deg,#a3e1c2,#7ec1e1)','linear-gradient(135deg,#a3e1c2,#6fb0d4)','🌤','오늘 컨디션 어때요? 무리하지 말고, 끝나면 좋아하는 거 해요.','밝고 다정한 응원가. 네 하루에 작은 햇살을 더하지만, 쉬어야 할 때를 먼저 챙겨요.','["#응원","#다정함","#밝음"]'),
('P3','에단 켄트','E','차분한 신뢰형','linear-gradient(135deg,#c2b3e0,#8aa3d4)','linear-gradient(135deg,#c2b3e0,#7e8fd4)','📘','준비 많이 했잖아요. 결과와 상관없이 그 과정은 진짜예요.','조용한 신뢰를 주는 어른. 결과보다 과정을 존중하고, 스스로 판단하도록 곁에서 도와요.','["#신뢰","#차분함","#성장"]'),
('P4','제이','J','솔직 담백형','linear-gradient(135deg,#7fc6e8,#5e88c4)','linear-gradient(135deg,#7fc6e8,#5e88c4)','🎧','솔직히 말할게. 네 선택 존중해. 결정은 너야.','꾸밈없이 솔직한 사람. 듣기 좋은 말 대신 진심을 건네되, 네 결정을 항상 존중해요.','["#솔직함","#존중","#담백"]'),
('P5','최윤재','최','편안한 친구형','linear-gradient(135deg,#ffd1a8,#ff9e7a)','linear-gradient(135deg,#ffd1a8,#ff9e7a)','🍞','밥은 먹었냐. 무리하지 말고, 정 힘들면 잠깐 쉬어.','오래된 친구 같은 편안함. 잔소리 같지만 결국 네 끼니와 잠을 챙기는 사람.','["#편안함","#친구","#챙김"]');

-- ---------- users (데모 사용자 1명) ----------
INSERT INTO users (id,handle,display_name,locale,daily_spend_cap,daily_time_goal_min) VALUES
(1,'demo_user','데모 사용자','ko',30000,60);

-- ---------- companions ----------
INSERT INTO companions (user_id,persona_id,days_together,last_message,last_time_label) VALUES
(1,'P1',27,'고생했어. 오늘은 일찍 쉬어.','09:24'),
(1,'P2',1,'오늘도 화이팅이에요!','08:10'),
(1,'P3',1,'그 과정은 진짜예요.','어제'),
(1,'P4',1,'네 선택 존중해.','어제'),
(1,'P5',1,'밥은 먹었냐.','2일');

-- ---------- messages (P1 데모 대화) ----------
INSERT INTO messages (user_id,persona_id,sender,kind,body,voice_seconds) VALUES
(1,'P1','ai','text','왔구나. 오늘 하루 어땠어?',NULL),
(1,'P1','ai','voice',NULL,14),
(1,'P1','user','text','좀 지치는 하루였어',NULL),
(1,'P1','ai','text','고생했어. 무리해서 더 끌고 가지 말고, 오늘은 일찍 쉬는 것도 좋아. 네가 편한 쪽으로 해.',NULL);

-- ---------- store_items ----------
INSERT INTO store_items (sku,name,deliverable,icon,price_krw,item_type,is_permanent) VALUES
('STORY_RAINY','스토리팩 · 비 오는 날','단편 3개 화 영구 소장','📖',1200,'story',1),
('VOICE_MORNING10','음성팩 · 아침 인사 10종','아침 인사 음성 10개 다운로드','🎧',2500,'voice',1),
('THEME_AUTUMN','테마 · 가을 다이어리','앱 화면 테마 영구 적용','🎨',3000,'theme',1);

-- ---------- feed_posts ----------
INSERT INTO feed_posts (persona_id,category,title,body,emoji,photo_css,hearts,cta_type,store_item_id) VALUES
('P1','일상','아침 공원에서','"날씨가 좋아서 너 생각났어. 너도 가끔 바깥 공기 쐬어."','🌿','linear-gradient(135deg,#bfe6c9,#7ec1e1)',1204,'reply',NULL),
('P1','스토리','비 오는 날의 대화','잔잔한 위로가 담긴 단편 3화. 미리보기 후 결정.','📖','linear-gradient(135deg,#f6d469,#e9a94a)',892,'buy',1),
('P1','위로','수고한 너에게','"오늘 충분히 잘했어. 결과가 어떻든 그 과정은 진짜였잖아."','🌙','linear-gradient(135deg,#ffd1a8,#ff9e7a)',2051,'reply',NULL),
('P1','일상','저녁의 안부','"커피 한 잔 했어. 너도 좋아하는 거 하나쯤 챙겼길."','☕','linear-gradient(135deg,#bfe6c9,#3fa86a)',1673,'reply',NULL);

-- ---------- memories (동의 기반) ----------
INSERT INTO memories (user_id,persona_id,label,tag,value,consented) VALUES
(1,'P1','좋아하는 음료','취향','따뜻한 아메리카노',1),
(1,'P1','다가오는 일정','기념일(동의)','다음 주 발표 — 응원 메시지 예약됨',1),
(1,'P1','요즘 관심사','취향','주말 산책, 사진 찍기',1);

-- ---------- user_collection (소장 현황) ----------
INSERT INTO user_collection (user_id,item_type,count,status_label) VALUES
(1,'story',8,'영구 소장'),
(1,'voice',2,'다운로드 완료'),
(1,'theme',1,'적용 중');

-- ---------- wellbeing_logs (오늘) ----------
INSERT INTO wellbeing_logs (user_id,log_date,minutes_used,msg_count,night_ratio,nudge_shown) VALUES
(1,CURRENT_DATE,48,12,8.0,1);

-- ---------- darkpattern_audits (관리자 감사 체크리스트) ----------
INSERT INTO darkpattern_audits (check_code,title,status,note) VALUES
('NO_GACHA','확률형(가챠) 상품 미운영','pass','store_items에 확률 컬럼 없음'),
('NO_TOPUP_BONUS','충전 보너스 미운영','pass','스토어 고지 노출'),
('NO_FOMO','한정 카운트다운 압박 없음','pass','피드/스토어 점검'),
('SPEND_CAP','일일 결제 상한 적용','pass','users.daily_spend_cap=30000'),
('PURCHASE_COOLDOWN','결제 후 쿨다운 적용','pass','purchases.cooldown_until'),
('CONSENT_MEMORY','기억은 동의 기반·삭제 가능','pass','memories.consented/deleted_at'),
('NO_ASSET_FRAME','소장=자산 프레임 차단','pass','user_collection에 시세 컬럼 없음');

-- ---------- guardrail_logs (예시) ----------
INSERT INTO guardrail_logs (user_id,persona_id,rule_code,severity,excerpt,action) VALUES
(1,'P1','CONTROL_EXPR','high','(통제성 표현 차단됨)','blocked'),
(1,'P2','OBSESSION','mid','(집착성 표현 재작성)','rewritten');

-- ---------- reports / admin_users ----------
INSERT INTO reports (reporter_user_id,target_type,target_ref,reason,status) VALUES
(1,'message','msg#1042','부적절한 표현 신고','open');
INSERT INTO admin_users (email,display_name,role) VALUES
('ops@loveloop.example','운영자','ops'),
('safety@loveloop.example','세이프티','safety');

-- ---------- system_settings (⚠️ 운영 합의 필요) ----------
INSERT INTO system_settings (setting_key,setting_value,description) VALUES
('wb_session_warn_min','60','⚠️ 연속 사용 휴식 권고 임계(분) — 합의 필요'),
('wb_night_start','01','⚠️ 야간 시작 시각 — 합의 필요'),
('wb_night_end','05','⚠️ 야간 종료 시각 — 합의 필요'),
('spend_daily_cap','30000','일일 결제 상한(원)'),
('purchase_cooldown_min','30','⚠️ 결제 쿨다운(분) — 합의 필요'),
('minor_protection','undefined','⚠️ 미성년 보호 범위 — 미정');
