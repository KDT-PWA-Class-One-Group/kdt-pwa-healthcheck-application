FROM nginx:alpine

# 기본 nginx 설정 파일 복사
COPY nginx.conf /etc/nginx/nginx.conf

# 사용자 정의 설정 파일 복사
COPY conf.d/default.conf /etc/nginx/conf.d/

# 로그 디렉토리 생성
RUN mkdir -p /var/log/nginx

# 80 포트 노출
EXPOSE 80

# nginx 실행
CMD ["nginx", "-g", "daemon off;"]
