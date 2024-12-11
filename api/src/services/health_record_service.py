from sqlalchemy.orm import Session
from sqlalchemy import select, text
from typing import List, Dict, Any
from datetime import datetime, date
from ..models import HealthRecord

class HealthRecordService:
    def __init__(self, db: Session):
        self.db = db

    def _model_to_dict(self, record: HealthRecord) -> Dict[str, Any]:
        """HealthRecord 모델을 딕셔너리로 변환합니다."""
        if record is None:
            return None
        return {
            "id": str(record.id),
            "user_name": record.patient_name,
            "health_status": record.result,
            "check_date": record.exam_date.isoformat() if isinstance(record.exam_date, (date, datetime)) else record.exam_date,
            "created_at": record.created_at.isoformat() if isinstance(record.created_at, datetime) else record.created_at
        }

    def get_records(self, skip: int = 0, limit: int = 100) -> List[Dict[str, Any]]:
        """건강검진 기록 목록을 조회합니다."""
        try:
            result = self.db.execute(text(
                """
                SELECT 
                    id,
                    patient_name,
                    result,
                    exam_date,
                    created_at
                FROM app.health_records 
                ORDER BY created_at DESC 
                LIMIT :limit OFFSET :skip
                """
            ), {"limit": limit, "skip": skip})
            
            records = []
            for row in result:
                record = self._model_to_dict(row)
                if record:
                    records.append(record)
            return records
        except Exception as e:
            print(f"Error in get_records: {str(e)}")
            raise

    def create_record(self, user_name: str, health_status: str) -> Dict[str, Any]:
        """새로운 건강검진 기록을 생성합니다."""
        try:
            result = self.db.execute(text(
                """
                INSERT INTO app.health_records (patient_name, exam_date, exam_type, result)
                VALUES (:patient_name, CURRENT_DATE, '정기검진', :result)
                RETURNING id, patient_name, result, exam_date, created_at
                """
            ), {"patient_name": user_name, "result": health_status})
            
            self.db.commit()
            return self._model_to_dict(result.fetchone())
        except Exception as e:
            self.db.rollback()
            print(f"Error in create_record: {str(e)}")
            raise

    def get_record_by_id(self, record_id: str) -> Dict[str, Any]:
        """ID로 특정 건강검진 기록을 조회합니다."""
        try:
            result = self.db.execute(text(
                """
                SELECT 
                    id,
                    patient_name,
                    result,
                    exam_date,
                    created_at
                FROM app.health_records 
                WHERE id = :id
                """
            ), {"id": record_id})
            
            return self._model_to_dict(result.fetchone())
        except Exception as e:
            print(f"Error in get_record_by_id: {str(e)}")
            raise 