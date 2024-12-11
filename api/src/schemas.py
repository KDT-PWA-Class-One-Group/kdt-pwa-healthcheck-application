from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional, Generic, TypeVar, List

T = TypeVar('T')

class HealthRecordBase(BaseModel):
    user_name: str
    health_status: str

class HealthRecordCreate(HealthRecordBase):
    pass

class HealthRecord(HealthRecordBase):
    id: int
    check_date: date
    created_at: datetime

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            date: lambda v: v.isoformat()
        }

class ResponseBase(BaseModel, Generic[T]):
    success: bool
    message: str
    data: Optional[T]

class HealthRecordResponse(ResponseBase[HealthRecord]):
    pass

class HealthRecordListResponse(ResponseBase[List[HealthRecord]]):
    pass
