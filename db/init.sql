-- UUID 확장 활성화
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
