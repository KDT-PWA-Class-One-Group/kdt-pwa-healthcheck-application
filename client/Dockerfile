FROM --platform=$BUILDPLATFORM node:18-alpine AS builder

WORKDIR /app

# 빌드에 필요한 시스템 패키지만 설치
RUN apk add --no-cache libc6-compat

# 패키지 파일 복사 및 의존성 설치 최적화
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# 소스 코드 복사 및 빌드
COPY . .
ENV NEXT_TELEMETRY_DISABLED 1

# Next.js 프로덕션 빌드
RUN yarn build

# 실행 스테이지
FROM --platform=$TARGETPLATFORM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# wget 설치
RUN apk add --no-cache wget

# 필요한 파일만 복사
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/server ./.next/server
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/package.json ./

# 실행 권한 설정
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs && \
    chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

# Next.js 서버 실행 (프로덕션 모드)
CMD ["node", "server.js"]
