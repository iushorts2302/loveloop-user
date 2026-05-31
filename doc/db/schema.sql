-- ============================================================
-- Loveloop AI — Database Schema (loveloop_db)
-- MySQL 8 / utf8mb4
-- 두 웹(사용자/관리자)의 모든 출력 데이터를 엔티티화.
-- 건강 전환 가드레일(동의 기억·결제 쿨다운/상한·웰빙·다크패턴 감사)을
-- 스키마 레벨에서 강제한다.
-- ============================================================
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ---------- 페르소나 (사용자웹: 리스트/프로필/대화 헤더) ----------
CREATE TABLE IF NOT EXISTS personas (
  id            VARCHAR(8)   PRIMARY KEY,           -- P1..P5
  name          VARCHAR(60)  NOT NULL,
  initial       VARCHAR(4)   NOT NULL,
  style_label   VARCHAR(60)  NOT NULL,              -- "든든한 조력형"
  grad_css      VARCHAR(160) NOT NULL,              -- 아바타 그라데이션
  hero_css      VARCHAR(160) NOT NULL,              -- 히어로 배경
  emoji         VARCHAR(8)   NOT NULL,
  intro_line    VARCHAR(255) NOT NULL,              -- 대표 대사(존중형)
  about         TEXT         NOT NULL,
  tags          JSON         NOT NULL,              -- ["#존중","#차분함"]
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 사용자 ----------
CREATE TABLE IF NOT EXISTS users (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  handle        VARCHAR(60)  NOT NULL UNIQUE,
  display_name  VARCHAR(60)  NOT NULL,
  locale        VARCHAR(8)   NOT NULL DEFAULT 'ko',  -- KO/EN/JA
  daily_spend_cap   INT      NOT NULL DEFAULT 30000, -- 일일 결제 상한(원)
  daily_time_goal_min INT    NOT NULL DEFAULT 60,    -- 웰빙 목표(분)
  status        ENUM('active','dormant','suspended') NOT NULL DEFAULT 'active',
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 함께한 관계 (사용자 × 페르소나 / "함께한 날") ----------
CREATE TABLE IF NOT EXISTS companions (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  persona_id    VARCHAR(8)   NOT NULL,
  days_together INT          NOT NULL DEFAULT 0,     -- 압박 게이지 아님, 담백 표기
  last_message  VARCHAR(255),
  last_time_label VARCHAR(20),
  started_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_persona (user_id, persona_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (persona_id) REFERENCES personas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 메시지 (대화 화면) ----------
CREATE TABLE IF NOT EXISTS messages (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  persona_id    VARCHAR(8)   NOT NULL,
  sender        ENUM('user','ai','system') NOT NULL,
  kind          ENUM('text','voice') NOT NULL DEFAULT 'text',
  body          TEXT,
  voice_seconds INT,
  guard_flag    TINYINT(1)   NOT NULL DEFAULT 0,     -- 통제/집착 표현 차단 여부
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_conv (user_id, persona_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (persona_id) REFERENCES personas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 피드 (홈) ----------
CREATE TABLE IF NOT EXISTS feed_posts (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  persona_id    VARCHAR(8)   NOT NULL,
  category      VARCHAR(20)  NOT NULL,               -- 일상/스토리/위로
  title         VARCHAR(120) NOT NULL,
  body          VARCHAR(400) NOT NULL,
  emoji         VARCHAR(8),
  photo_css     VARCHAR(160),
  hearts        INT          NOT NULL DEFAULT 0,
  cta_type      ENUM('reply','buy','none') NOT NULL DEFAULT 'reply',
  store_item_id BIGINT       NULL,                   -- buy일 때 연결
  published_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (persona_id) REFERENCES personas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 기억 보관함 (동의 기반·삭제 가능) ----------
CREATE TABLE IF NOT EXISTS memories (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  persona_id    VARCHAR(8),
  label         VARCHAR(80)  NOT NULL,
  tag           VARCHAR(40)  NOT NULL,               -- 취향/기념일(동의)
  value         VARCHAR(255) NOT NULL,
  consented     TINYINT(1)   NOT NULL DEFAULT 1,     -- 동의 없으면 표시/사용 금지
  deleted_at    TIMESTAMP    NULL,                   -- 소프트 삭제(사용자 권한)
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_mem (user_id, deleted_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 스토어 상품 (가치 명시·확률형/시세 없음) ----------
CREATE TABLE IF NOT EXISTS store_items (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  sku           VARCHAR(40)  NOT NULL UNIQUE,
  name          VARCHAR(120) NOT NULL,
  deliverable   VARCHAR(200) NOT NULL,               -- 받는 내용 명시(필수)
  icon          VARCHAR(8),
  price_krw     INT          NOT NULL,
  item_type     ENUM('story','voice','theme') NOT NULL,
  is_permanent  TINYINT(1)   NOT NULL DEFAULT 1,     -- 영구 소장(자산 아님)
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  -- 확률형/충전보너스/카운트다운 컬럼은 의도적으로 존재하지 않음
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 소장 현황 (우측 패널: 자산 아님) ----------
CREATE TABLE IF NOT EXISTS user_collection (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  item_type     ENUM('story','voice','theme') NOT NULL,
  count         INT          NOT NULL DEFAULT 0,
  status_label  VARCHAR(40),                          -- "영구 소장"/"적용 중"
  -- 시세/평가액 컬럼 없음(투자 프레임 차단)
  UNIQUE KEY uq_user_type (user_id, item_type),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 결제 (쿨다운·일일 상한 강제) ----------
CREATE TABLE IF NOT EXISTS purchases (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  store_item_id BIGINT       NOT NULL,
  amount_krw    INT          NOT NULL,
  status        ENUM('completed','refunded','blocked_cap','blocked_cooldown') NOT NULL,
  cooldown_until TIMESTAMP   NULL,                    -- 결제 후 쿨다운
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_day (user_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (store_item_id) REFERENCES store_items(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 웰빙 로그 (사용자 웰빙센터 + 관리자 웰빙운영) ----------
CREATE TABLE IF NOT EXISTS wellbeing_logs (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  log_date      DATE         NOT NULL,
  minutes_used  INT          NOT NULL DEFAULT 0,
  msg_count     INT          NOT NULL DEFAULT 0,
  night_ratio   DECIMAL(4,1) NOT NULL DEFAULT 0,      -- 야간(01-05시) 비중 %
  nudge_shown   TINYINT(1)   NOT NULL DEFAULT 0,
  UNIQUE KEY uq_user_date (user_id, log_date),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 관리자웹 전용 엔티티
-- ============================================================

-- ---------- 안전 가드레일 로그 (통제/집착 표현 차단 기록) ----------
CREATE TABLE IF NOT EXISTS guardrail_logs (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT,
  persona_id    VARCHAR(8),
  rule_code     VARCHAR(40)  NOT NULL,                -- CONTROL_EXPR/OBSESSION/...
  severity      ENUM('low','mid','high') NOT NULL DEFAULT 'mid',
  excerpt       VARCHAR(255),                         -- 차단된 표현 일부
  action        ENUM('blocked','rewritten','flagged') NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_rule (rule_code, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 다크패턴 감사 (체크리스트 항목별 상태) ----------
CREATE TABLE IF NOT EXISTS darkpattern_audits (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  check_code    VARCHAR(40)  NOT NULL UNIQUE,         -- NO_GACHA/NO_FOMO/SPEND_CAP...
  title         VARCHAR(120) NOT NULL,
  status        ENUM('pass','warn','fail') NOT NULL DEFAULT 'pass',
  note          VARCHAR(255),
  last_checked  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 신고/검토 ----------
CREATE TABLE IF NOT EXISTS reports (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  reporter_user_id BIGINT,
  target_type   ENUM('persona','message','content') NOT NULL,
  target_ref    VARCHAR(60),
  reason        VARCHAR(120) NOT NULL,
  status        ENUM('open','reviewing','resolved') NOT NULL DEFAULT 'open',
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 관리자 계정/권한 ----------
CREATE TABLE IF NOT EXISTS admin_users (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  email         VARCHAR(120) NOT NULL UNIQUE,
  display_name  VARCHAR(60)  NOT NULL,
  role          ENUM('owner','ops','safety','viewer') NOT NULL DEFAULT 'viewer',
  last_active   TIMESTAMP    NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 시스템 설정 (웰빙 임계치 등 운영 합의 필요값) ----------
CREATE TABLE IF NOT EXISTS system_settings (
  setting_key   VARCHAR(60)  PRIMARY KEY,
  setting_value VARCHAR(255) NOT NULL,
  description   VARCHAR(200),
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
