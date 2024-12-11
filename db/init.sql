-- 데이터베이스 생성은 이미 환경 변수로 처리됨
-- CREATE DATABASE healthcheck;
-- CREATE USER "user" WITH PASSWORD 'password';
-- GRANT ALL PRIVILEGES ON DATABASE healthcheck TO "user";

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 기본 테이블 생성
DROP TABLE IF EXISTS health_records;
CREATE TABLE health_records (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    check_date DATE NOT NULL DEFAULT CURRENT_DATE,
    health_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 업데이트 시 updated_at 자동 갱신을 위한 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
DROP TRIGGER IF EXISTS update_health_records_updated_at ON health_records;
CREATE TRIGGER update_health_records_updated_at
    BEFORE UPDATE ON health_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 샘플 데이터 추가
INSERT INTO health_records (user_name, health_status) VALUES
    ('김철수', '정상'),
    ('이영희', '재검진 필요'),
    ('박지민', '정상');

-- 추가 권한 부여
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CURRENT_USER;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO CURRENT_USER;
