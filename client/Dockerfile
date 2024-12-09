FROM --platform=$BUILDPLATFORM node:22.11.0-alpine AS builder

WORKDIR /app

# 패키지 파일 복사
COPY package.json yarn.lock ./

# 의존성 설치
RUN yarn install --frozen-lockfile

# 소스 코드 복사
COPY . .

# Next.js 애플리케이션 빌드
RUN yarn build

# 실행 스테이지
FROM --platform=$TARGETPLATFORM node:22.11.0-alpine

WORKDIR /app

# 빌드된 파일과 필요한 파일들만 복사
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# 환경 변수 설정
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NODE_ENV=production

# 포트 설정
EXPOSE 3000

# 프로덕션 모드로 실행
CMD ["yarn", "start"]
