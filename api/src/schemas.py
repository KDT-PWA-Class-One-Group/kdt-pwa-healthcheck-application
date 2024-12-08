from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional, Generic, TypeVar, List
from uuid import UUID

T = TypeVar('T')

class HealthRecordBase(BaseModel):
    exam_date: date
    patient_name: str
    exam_type: str
    result: Optional[str]
    height: Optional[float]
    weight: Optional[float]
    blood_pressure: Optional[str]
    blood_sugar: Optional[int]

class HealthRecordCreate(HealthRecordBase):
    pass

class HealthRecord(HealthRecordBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ResponseBase(BaseModel, Generic[T]):
    success: bool
    message: str
    data: Optional[T]

class HealthRecordResponse(ResponseBase[HealthRecord]):
    pass

class HealthRecordListResponse(ResponseBase[List[HealthRecord]]):
    pass

class HealthCheckResponse(ResponseBase[dict]):
    pass
