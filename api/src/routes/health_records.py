from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from ..database import get_db
from ..schemas import (
    HealthRecordCreate,
    HealthRecordResponse,
    HealthRecordListResponse
)
from ..services.health_record_service import HealthRecordService

router = APIRouter(
    prefix="/health-records",
    tags=["health-records"]
)

@router.get("", response_model=HealthRecordListResponse)
async def get_health_records(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """건강검진 기록 목록을 조회합니다."""
    try:
        service = HealthRecordService(db)
        records = service.get_records(skip=skip, limit=limit)
        return {
            "success": True,
            "message": "검진 기록을 성공적으로 조회했습니다.",
            "data": records
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"검진 기록 조회 중 오류가 발생했습니다: {str(e)}"
        )

@router.post("", response_model=HealthRecordResponse)
async def create_health_record(
    record: HealthRecordCreate,
    db: Session = Depends(get_db)
):
    """새로운 건강검진 기록을 생성합니다."""
    try:
        service = HealthRecordService(db)
        created_record = service.create_record(
            user_name=record.user_name,
            health_status=record.health_status
        )
        return {
            "success": True,
            "message": "검진 기록이 성공적으로 생성되었습니다.",
            "data": created_record
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"검진 기록 생성 중 오류가 발생했습니다: {str(e)}"
        )

@router.get("/{record_id}", response_model=HealthRecordResponse)
async def get_health_record(
    record_id: int,
    db: Session = Depends(get_db)
):
    """특정 ID의 건강검진 기록을 조회합니다."""
    try:
        service = HealthRecordService(db)
        record = service.get_record_by_id(record_id)
        if not record:
            raise HTTPException(
                status_code=404,
                detail="해당 ID의 검진 기록을 찾을 수 없습니다."
            )
        return {
            "success": True,
            "message": "검진 기록을 성공적으로 조회했습니다.",
            "data": record
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"검진 기록 조회 중 오류가 발생했습니다: {str(e)}"
        ) 