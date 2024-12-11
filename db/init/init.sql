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

-- health_records 테이블 생성
CREATE TABLE IF NOT EXISTS app.health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_name VARCHAR(255) NOT NULL,
    exam_date DATE NOT NULL,
    exam_type VARCHAR(50) NOT NULL,
    result TEXT,
    height NUMERIC(5,2),
    weight NUMERIC(5,2),
    blood_pressure VARCHAR(20),
    blood_sugar INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- updated_at 자동 갱신을 위한 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- users 테이블 트리거
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- health_records 테이블 트리거
CREATE TRIGGER update_health_records_updated_at
    BEFORE UPDATE ON app.health_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 개발 테스트용 샘플 데이터 (users)
INSERT INTO app.users (username, email, password_hash)
VALUES ('testuser', 'test@example.com', 'test123')
ON CONFLICT (username) DO NOTHING;

-- 개발 테스트용 샘플 데이터 (health_records)
INSERT INTO app.health_records (patient_name, exam_date, exam_type, result, height, weight, blood_pressure, blood_sugar)
VALUES 
    ('홍길동', '2023-12-01', '정기검진', '정상', 175.5, 70.2, '120/80', 95),
    ('김철수', '2023-12-02', '특별검진', '요주의', 168.3, 75.8, '130/85', 110),
    ('이영희', '2023-12-03', '정기검진', '정상', 162.1, 55.4, '115/75', 88)
ON CONFLICT DO NOTHING;

-- 사용자 권한 설정
GRANT ALL PRIVILEGES ON SCHEMA app TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO CURRENT_USER;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO CURRENT_USER;
