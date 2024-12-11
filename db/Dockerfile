FROM postgres:14.6

WORKDIR /docker-entrypoint-initdb.d

# 설정 파일 복사
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# 로그 디렉토리 설정
RUN mkdir -p /var/log/postgresql && \
    chown -R postgres:postgres /var/log/postgresql && \
    chmod 777 /var/log/postgresql

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
