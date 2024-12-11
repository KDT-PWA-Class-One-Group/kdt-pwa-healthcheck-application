from sqlalchemy import Column, String, Date, TIMESTAMP, UUID, Text, Numeric, Integer, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
import uuid

# 스키마를 포함한 메타데이터 생성
metadata = MetaData(schema='app')
Base = declarative_base(metadata=metadata)

class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    patient_name = Column(String(255), nullable=False)
    exam_date = Column(Date, nullable=False)
    exam_type = Column(String(50), nullable=False)
    result = Column(Text)
    height = Column(Numeric(5,2))
    weight = Column(Numeric(5,2))
    blood_pressure = Column(String(20))
    blood_sugar = Column(Integer)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now()) 