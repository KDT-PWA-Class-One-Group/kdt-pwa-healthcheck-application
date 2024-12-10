FROM node:22.11.0-alpine

WORKDIR /app

# 시스템 의존성 설치
RUN apk add --no-cache curl

# 앱 의존성 설치
COPY package*.json ./
RUN yarn install --frozen-lockfile

# 소스 코드 복사
COPY . .

# 로그 디렉토리 생성
RUN mkdir -p /app/logs

# 로그 디렉토리 비루트 사용자로 소유자 변경
RUN chown node:node /app/logs

# TypeScript 빌드
RUN yarn build

# 비루트 사용자 설정
USER node

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

CMD ["yarn", "start"]
