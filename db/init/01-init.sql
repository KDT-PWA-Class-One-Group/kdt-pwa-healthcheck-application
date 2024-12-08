-- 테장 모듈 설치
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 건강검진 기록 테이블 생성
CREATE TABLE IF NOT EXISTS health_records (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
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

-- 업데이트 트리거 함수 생성
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 업데이트 트리거 설정
CREATE TRIGGER update_health_records_updated_at
    BEFORE UPDATE ON health_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 테스트 데이터 삽입
INSERT INTO health_records (patient_name, exam_date, exam_type, result)
VALUES 
    ('홍길동', '2024-01-01', '기본검진', '정상'),
    ('김철수', '2024-01-02', '혈액검사', '추가검사 필요'); 