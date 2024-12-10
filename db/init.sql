-- 데이터베이스가 없는 경우에만 생성
SELECT 'CREATE DATABASE healthcheck'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'healthcheck')\gexec

\c healthcheck;

-- 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 건강 체크 테이블 생성
CREATE TABLE IF NOT EXISTS health_checks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    check_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 기본 사용자 추가
INSERT INTO users (username, email) 
VALUES ('test_user', 'test@example.com')
ON CONFLICT DO NOTHING;
