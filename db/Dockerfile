FROM postgres:14.6

WORKDIR /docker-entrypoint-initdb.d

# 초기화 스크립트 복사
COPY /init/init.sql .

# 설정 파일 복사 (PostgreSQL이 시작될 때 자동으로 로드됨)
COPY postgresql.conf /var/lib/postgresql/data/
COPY pg_hba.conf /var/lib/postgresql/data/

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

# 권한 설정을 위한 스크립트 추가
USER postgres

# 설정 파일 사용
CMD ["postgres"]
