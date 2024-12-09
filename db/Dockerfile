FROM postgres:14.6

WORKDIR /docker-entrypoint-initdb.d

# 초기화 스크립트 복사
COPY ["./init.sql", "/docker-entrypoint-initdb.d/"]

# 설정 파일 복사
COPY ["./postgresql.conf", "/etc/postgresql/postgresql.conf"]
COPY ["./pg_hba.conf", "/etc/postgresql/pg_hba.conf"]

# 환경 변수 설정
ENV POSTGRES_DB=healthcheck \
    POSTGRES_USER=user \
    POSTGRES_PASSWORD=password \
    POSTGRES_HOST_AUTH_METHOD=trust

# 아키텍처별 성능 최적화 설정
ENV POSTGRES_SHARED_BUFFERS=256MB \
    POSTGRES_EFFECTIVE_CACHE_SIZE=768MB \
    POSTGRES_MAINTENANCE_WORK_MEM=64MB \
    POSTGRES_WORK_MEM=4MB \
    POSTGRES_MAX_WORKER_PROCESSES=4 \
    POSTGRES_MAX_PARALLEL_WORKERS=4 \
    POSTGRES_MAX_PARALLEL_WORKERS_PER_GATHER=2

# 포트 설정
EXPOSE 5432

# 설정 파일 사용
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hba_file=/etc/postgresql/pg_hba.conf"]
