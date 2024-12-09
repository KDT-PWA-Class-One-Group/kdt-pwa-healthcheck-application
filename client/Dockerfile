FROM --platform=$BUILDPLATFORM node:22.11.0-alpine AS builder

WORKDIR /app

# 빌드에 필요한 시스템 패키지만 설치
RUN apk add --no-cache libc6-compat

# 패키지 파일 복사 및 의존성 설치 최적화
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# 소스 코드 복사 및 빌드
COPY . .
ENV NEXT_TELEMETRY_DISABLED 1
RUN yarn build && \
    rm -rf node_modules && \
    yarn install --frozen-lockfile --production=true && \
    yarn cache clean

# 실행 스테이지 - 최소한의 구성만 포함
FROM --platform=$TARGETPLATFORM node:22.11.0-alpine AS runner

WORKDIR /app

# 필요한 환경 변수 설정
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# 보안을 위한 비루트 사용자 설정
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs && \
    chmod 755 /app

# 필요한 파일만 복사
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# 사용자 전환
USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
