FROM --platform=$BUILDPLATFORM python:3.10-slim-bullseye AS builder

WORKDIR /app

# 빌드 시 필요한 최소한의 시스템 패키지만 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 실행 스테이지
FROM --platform=$TARGETPLATFORM python:3.10-slim-bullseye

WORKDIR /app

# 런타임에 필요한 최소한의 패키지만 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# 빌드된 패키지 복사
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# 소스 코드 복사
COPY . .

# Python 설정
ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 비루트 사용자 설정
RUN useradd -m -r -u 1001 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["python", "run.py"]
