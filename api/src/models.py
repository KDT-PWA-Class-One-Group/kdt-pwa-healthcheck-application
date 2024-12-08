from sqlalchemy import Column, Integer, String, Date, Text, TIMESTAMP, Numeric, UUID
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
import uuid

Base = declarative_base()

class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_name = Column(String(100), nullable=False)
    exam_date = Column(Date, nullable=False)
    exam_type = Column(String(50), nullable=False)
    result = Column(Text)
    height = Column(Numeric(5,2))
    weight = Column(Numeric(5,2))
    blood_pressure = Column(String(20))
    blood_sugar = Column(Integer)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now()) 