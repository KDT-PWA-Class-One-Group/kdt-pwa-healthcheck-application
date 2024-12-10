from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Dict, Any
from datetime import date, datetime

from . import models, schemas, database

# 데이터베이스 초기화
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="건강검진 API",
    description="건강검진 시스템을 위한 REST API",
    version="1.0.0"
)

# CORS 미들웨어 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 전역 예외 핸들러
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "message": exc.detail,
            "data": None
        }
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal Server Error",
            "data": None
        }
    )

# 헬스체크 엔드포인트
@app.get("/health")
def health_check():
    return {"status": "healthy"}

# 메트릭스 엔드포인트
@app.get("/metrics")
def get_metrics():
    return {
        "status": "ok",
        "timestamp": datetime.now().isoformat(),
        "database": {
            "status": "connected" if database.engine else "disconnected"
        }
    }

# 검진 기록 목록 조회
@app.get("/health-records", response_model=schemas.HealthRecordListResponse)
def read_health_records(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    try:
        records = db.query(models.HealthRecord).offset(skip).limit(limit).all()
        return {
            "success": True,
            "message": "검진 기록을 성공적으로 조회했습니다.",
            "data": records
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail="검진 기록 조회 중 오류가 발생했습니다."
        )

# 검진 기록 상세 조회
@app.get("/health-records/{record_id}", response_model=schemas.HealthRecordResponse)
def read_health_record(record_id: int, db: Session = Depends(database.get_db)):
    record = db.query(models.HealthRecord).filter(models.HealthRecord.id == record_id).first()
    if record is None:
        raise HTTPException(
            status_code=404,
            detail="해당 검진 기록을 찾을 수 없습니다."
        )
    return {
        "success": True,
        "message": "검진 기록을 성공적으로 조회했습니다.",
        "data": record
    }

# 검진 기록 성
@app.post("/health-records", response_model=schemas.HealthRecordResponse)
def create_health_record(
    record: schemas.HealthRecordCreate,
    db: Session = Depends(database.get_db)
):
    try:
        db_record = models.HealthRecord(**record.dict())
        db.add(db_record)
        db.commit()
        db.refresh(db_record)
        return {
            "success": True,
            "message": "검진 기록이 성공적으로 생성되었습니다.",
            "data": db_record
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="검진 기록 생성 중 오류가 발생했습니다."
        )

# 검진 기록 수정
@app.put("/health-records/{record_id}", response_model=schemas.HealthRecordResponse)
def update_health_record(
    record_id: int,
    record: schemas.HealthRecordCreate,
    db: Session = Depends(database.get_db)
):
    try:
        db_record = db.query(models.HealthRecord).filter(models.HealthRecord.id == record_id).first()
        if db_record is None:
            raise HTTPException(
                status_code=404,
                detail="해당 검진 기록을 찾을 수 없습니다."
            )

        for key, value in record.dict().items():
            setattr(db_record, key, value)

        db.commit()
        db.refresh(db_record)
        return {
            "success": True,
            "message": "검진 기록이 성공적으로 수정되었습니다.",
            "data": db_record
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="검진 기록 수정 중 오류가 발생했습니다."
        )

# 검진 기록 삭제
@app.delete("/health-records/{record_id}", response_model=schemas.ResponseBase[dict])
def delete_health_record(record_id: int, db: Session = Depends(database.get_db)):
    try:
        db_record = db.query(models.HealthRecord).filter(models.HealthRecord.id == record_id).first()
        if db_record is None:
            raise HTTPException(
                status_code=404,
                detail="해당 검진 기록을 찾을 수 없습니다."
            )

        db.delete(db_record)
        db.commit()
        return {
            "success": True,
            "message": "검진 기록이 성공적으로 삭제되었습니다.",
            "data": {"id": record_id}
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="검진 기록 삭제 중 오류가 발생했습니다."
        )
