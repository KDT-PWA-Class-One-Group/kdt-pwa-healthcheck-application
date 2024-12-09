FROM nginx:1.25

# Node.js 설치
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

# 파일 복사
COPY . .

# Nginx 설정 복사
RUN cp nginx.conf /etc/nginx/nginx.conf \
    && cp conf.d/default.conf /etc/nginx/conf.d/default.conf \
    && mkdir -p /etc/nginx/conf.d/health \
    && cp health-check.js /etc/nginx/conf.d/health/ \
    && cp health-check.json /etc/nginx/conf.d/health/

# 권한 설정
RUN chown -R nginx:nginx /etc/nginx/conf.d/health \
    && chmod 644 /etc/nginx/conf.d/health/health-check.json \
    && chmod 755 /etc/nginx/conf.d/health/health-check.js

# 시작 스크립트 생성
RUN echo '#!/bin/sh\ncd /etc/nginx/conf.d/health && node health-check.js &\nnginx -g "daemon off;"' > /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
