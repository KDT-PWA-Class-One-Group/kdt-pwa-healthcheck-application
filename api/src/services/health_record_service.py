from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Dict, Any
from datetime import datetime, date

class HealthRecordService:
    def __init__(self, db: Session):
        self.db = db

    def _row_to_dict(self, row) -> Dict[str, Any]:
        """SQLAlchemy Row를 딕셔너리로 변환합니다."""
        if row is None:
            return None
        return {
            "id": row.id,
            "user_name": row.user_name,
            "health_status": row.health_status,
            "check_date": row.check_date.isoformat() if isinstance(row.check_date, (date, datetime)) else row.check_date,
            "created_at": row.created_at.isoformat() if isinstance(row.created_at, datetime) else row.created_at
        }

    def get_records(self, skip: int = 0, limit: int = 100) -> List[Dict[str, Any]]:
        """건강검진 기록 목록을 조회합니다."""
        try:
            result = self.db.execute(text(
                """
                SELECT 
                    id,
                    user_name,
                    health_status,
                    check_date,
                    created_at
                FROM health_records 
                ORDER BY created_at DESC 
                LIMIT :limit OFFSET :skip
                """
            ), {"limit": limit, "skip": skip})
            
            records = []
            for row in result:
                record = self._row_to_dict(row)
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
                INSERT INTO health_records (user_name, health_status)
                VALUES (:user_name, :health_status)
                RETURNING id, user_name, health_status, check_date, created_at
                """
            ), {"user_name": user_name, "health_status": health_status})
            
            self.db.commit()
            return self._row_to_dict(result.fetchone())
        except Exception as e:
            self.db.rollback()
            print(f"Error in create_record: {str(e)}")
            raise

    def get_record_by_id(self, record_id: int) -> Dict[str, Any]:
        """ID로 특정 건강검진 기록을 조회합니다."""
        try:
            result = self.db.execute(text(
                """
                SELECT 
                    id,
                    user_name,
                    health_status,
                    check_date,
                    created_at
                FROM health_records 
                WHERE id = :id
                """
            ), {"id": record_id})
            
            return self._row_to_dict(result.fetchone())
        except Exception as e:
            print(f"Error in get_record_by_id: {str(e)}")
            raise 