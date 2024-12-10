-- 데이터베이스 생성
CREATE DATABASE healthcheck;

-- 사용자 생성 및 권한 부여
CREATE USER "user" WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE healthcheck TO "user";

-- healthcheck 데이터베이스로 전환
\c healthcheck

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 기본 스키마 생성
CREATE SCHEMA IF NOT EXISTS app;

-- 기본 테이블 생성
CREATE TABLE IF NOT EXISTS app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
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
CREATE TRIGGER update_health_records_updated_at
    BEFORE UPDATE ON health_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 샘플 데이터 삽입
INSERT INTO health_records (patient_name, exam_date, exam_type, result, height, weight, blood_pressure, blood_sugar)
VALUES
    ('홍길동', '2023-12-01', '정기검진', '정상', 175.5, 70.2, '120/80', 95),
    ('김철수', '2023-12-02', '특별검진', '요주의', 168.3, 75.8, '130/85', 110),
    ('이영희', '2023-12-03', '정기검진', '정상', 162.1, 55.4, '115/75', 88);