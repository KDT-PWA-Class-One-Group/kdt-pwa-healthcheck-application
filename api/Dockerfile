FROM --platform=$BUILDPLATFORM python:3.10-slim AS builder

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 실행 스테이지
FROM --platform=$TARGETPLATFORM python:3.10-slim

WORKDIR /app

# 런타임 의존성만 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# 빌드된 패키지 복사
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# 소스 코드 복사
COPY . .

# Python 경로에 현재 디렉토리 추가
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# 포트 설정
EXPOSE 8000

# 실행
CMD ["python", "run.py"]
