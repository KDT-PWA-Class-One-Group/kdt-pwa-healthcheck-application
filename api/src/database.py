from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os
import time

# 데이터베이스 URL 설정
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://user:password@db:5432/healthcheck"
)

def wait_for_db(max_retries=5, retry_interval=5):
    for retry in range(max_retries):
        try:
            engine = create_engine(
                DATABASE_URL,
                pool_pre_ping=True,
                pool_recycle=3600,
                connect_args={"connect_timeout": 5}
            )
            # 연결 테스트
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
                print(f"데이터베이스 연결 성공 (시도 {retry + 1}/{max_retries})")
                return engine
        except Exception as e:
            if retry < max_retries - 1:
                print(f"데이터베이스 연결 실패 (시도 {retry + 1}/{max_retries}): {str(e)}")
                time.sleep(retry_interval)
            else:
                raise Exception(f"데이터베이스 연결 실패: {str(e)}")

# 엔진 생성
engine = wait_for_db()

# 세션 팩토리 생성
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 데이터베이스 세션 의존성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
