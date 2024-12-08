FROM postgres:14.6

# 설정 파일 복사
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# 초기화 스크립트 복사
COPY init.sql /docker-entrypoint-initdb.d/

# 환경 변수 설정
ENV POSTGRES_DB=healthcheck
ENV POSTGRES_USER=user
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_HOST_AUTH_METHOD=trust

# 포트 설정
EXPOSE 5432

# 설정 파일 사용
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hba_file=/etc/postgresql/pg_hba.conf"]