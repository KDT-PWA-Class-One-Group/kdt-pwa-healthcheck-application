FROM nginx:alpine

# nginx 설정 파일 복사
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/default.conf /etc/nginx/conf.d/

# 헬스체크 페이지 생성
RUN echo "OK" > /usr/share/nginx/html/health

# 로그 디렉토리 생성 및 권한 설정
RUN mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    # nginx 캐시 디렉토리 생성 및 권한 설정
    mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    # 기본 nginx 사용자로 전환
    # 보안 강화를 위한 추가 설정
    rm -rf /var/cache/apk/* && \
    # 헬스체크 파일 권한 설정
    chown -R nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --quiet --tries=1 --spider http://localhost:80/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
