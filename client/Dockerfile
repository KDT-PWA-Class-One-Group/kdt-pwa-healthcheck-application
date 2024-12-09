FROM node:22.11.0-alpine

WORKDIR /app

# 패키지 파일 복사
COPY package.json yarn.lock ./

# 의존성 설치
RUN yarn install

# 소스 코드 복사
COPY . .

# Next.js 애플리케이션 빌드
RUN yarn build

# 환경 변수 설정
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# 포트 설정
EXPOSE 3000

# 프로덕션 모드로 실행
CMD ["yarn", "start"]
