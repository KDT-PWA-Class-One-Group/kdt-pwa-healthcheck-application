FROM python:3.10-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY . .

# Python 경로에 현재 디렉토리 추가
ENV PYTHONPATH=/app

# 포트 설정
EXPOSE 8000

# 실행
CMD ["python", "run.py"]
