# Health Check Application

## 프로젝트 개요

이 프로젝트는 시스템과 서비스의 상태를 실시간으로 모니터링하고 건강 검진 기록을 관리하는 PWA(Progressive Web Application) 애플리케이션입니다. 마이크로서비스 아키텍처를 기반으로 하여 각 서비스의 독립적인 확장과 유지보수가 가능하도록 설계되었습니다.

## 주요 기능

### 1. 시스템 모니터링
- 실시간 시스템 상태 모니터링
  - CPU 사용량 (코어별 사용률, 로드 애버리지)
  - 메모리 사용량 분석
    - RSS (Resident Set Size): 실제 물리 메모리 사용량
    - Heap Total: V8 엔진의 총 힙 메모리 할당량
    - Heap Used: 실제 사용 중인 힙 메모리량
  - 시스템 업타임 및 성능 메트릭
- 서비스 헬스체크
  - 각 마이크로서비스 상태 실시간 모니터링
  - 응답 시간 측정 (TTFB, 총 응답 시간)
  - 상태 메시지 및 에러 로깅
  - 서비스 의존성 체크

### 2. 건강 검진 기록 관리
- 사용자별 건강 검진 기록 등록/조회
  - RESTful API 기반 CRUD 작업
  - 실시간 데이터 동기화 (WebSocket)
- 검진 데이터 관리
  - 환자 정보 (암호화 저장)
  - 검진 일자 및 이력 관리
  - 검진 유형 분류 시스템
  - 신체 측정 데이터
    - 신체 계측: 키, 체중, BMI 자동 계산
    - 활력 징후: 혈압, 맥박, 체온
    - 혈액 검사: 혈당, 콜레스테롤 등
- 데이터 분석 및 시각화
  - 시계열 기반 건강 지표 트렌드 분석
  - 맞춤형 리포트 생성

## 기술 스택

### Frontend
- Next.js 13+ (App Router)
  - React Server Components
  - Streaming SSR
  - Route Handlers
- TypeScript (정적 타입 시스템)
- Tailwind CSS (JIT 컴파일러)
- PWA 최적화
  - Service Workers
  - Offline 지원
  - Push Notifications
  - App Manifest

### Backend
- FastAPI (Python 3.9+)
  - 비동기 처리 (async/await)
  - OpenAPI (Swagger) 자동 문서화
  - 타입 힌트 기반 검증
- SQLAlchemy ORM
  - 비동기 세션 관리
  - 마이그레이션 (Alembic)
- PostgreSQL 15
  - JSONB 컬럼 활용
  - 인덱스 최적화
  - 파티셔닝 전략
- Docker 컨테이너화
  - 멀티스테이지 빌드
  - 레이어 최적화

### 인프라
- Nginx Reverse Proxy
  - SSL/TLS 종단
  - 로드 밸런싱
  - 캐시 전략
- Docker Compose
  - 서비스 오케스트레이션
  - 볼륨 관리
  - 네트워크 격리
- 헬스체크 시스템
  - 메트릭 수집 (Prometheus)
  - 시각화 (Grafana)
- 로깅 시스템
  - 구조화된 로깅 (JSON)
  - 로그 집계 (ELK Stack)
  - 로그 회전 정책

## 시스템 아키텍처

```
                                   [로드 밸런서]
                                        |
                                   [Nginx Proxy]
                                        |
        +----------------+-------------+-------------+
        |               |             |             |
[Next.js Client]  [FastAPI Server]  [Auth]    [Monitoring]
        |               |             |             |
        +----------------+-------------+-------------+
                                |
                          [PostgreSQL]
                                |
                        [백업 & 복제]
```

### 데이터 흐름
1. 클라이언트에서 API 요청 발생
   - JWT 기반 인증
   - Rate Limiting 적용
2. Nginx가 요청을 적절한 서비스로 라우팅
   - SSL 종단
   - 요청 캐싱
3. API 서버에서 요청 처리 및 데이터베이스 작업 수행
   - Connection Pooling
   - 트랜잭션 관리
4. 결과를 클라이언트에 반환
   - 응답 압축
   - ETags 활용

## 설치 및 실행

### 사전 요구사항
- Docker Desktop (버전 20.10+)
- Git (버전 2.30+)
- GitHub 계정 및 액세스 토큰 (repo, packages 권한 필요)
- 최소 시스템 사양:
  - CPU: 2코어 이상
  - RAM: 4GB 이상
  - 저장공간: 10GB 이상

### 환경 설정
```bash
# 레포지토리 클론
git clone [repository-url]
cd [repository-name]

# 환경 변수 설정
cp .env.example .env
# .env 파일 수정 (데이터베이스 자격증명, API 키 등)

# 실행
chmod +x run.sh
./run.sh
```

### 접속 정보
- 웹 서비스: http://localhost (HTTPS 권장)
- API 서비스: http://localhost/api
- 헬스체크: http://localhost/health
- Swagger 문서: http://localhost/api/docs
- 메트릭: http://localhost/metrics

## 확장성 및 스케일링

### 수평적 확장
- 각 서비스(API, Client, DB)는 독립적으로 스케일 가능
  - 상태 비저장 (Stateless) 설계
  - 세션 관리: Redis 클러스터
- Docker Compose를 통한 손쉬운 서비스 확장
  - 레플리카 세트 구성
  - 롤링 업데이트
- 로드 밸런싱 지원
  - Round Robin
  - Least Connections
  - IP Hash

### 수직적 확장
- 컨테이너별 리소스 제한 및 할당
  - CPU 쿼터
  - 메모리 제한
  - 스왑 설정
- 데이터베이스 성능 최적화
  - 인덱스 전략
  - 쿼리 최적화
  - 파티셔닝
- 캐싱 시스템
  - Redis 캐시
  - CDN 활용
  - 브라우저 캐시 정책

## 모니터링 및 로깅

### 시스템 모니터링
- 실시간 리소스 사용량 추적
  - CPU, 메모리, 디스크 I/O
  - 네트워크 트래픽
  - 컨테이너 상태
- 서비스 상태 모니터링
  - 엔드포인트 가용성
  - 에러율
  - 사용자 세션
- 응답 시간 측정
  - Apdex 스코어
  - 페이지 로드 타임
  - API 레이턴시

### 로깅 시스템
- 각 서비스별 독립적인 로그 관리
  - 구조화된 JSON 로깅
  - 상관관계 ID 추적
  - 로그 레벨 필터링
- 로그 레벨별 구분
  - ERROR: 시스템 오류
  - WARN: 잠재적 문제
  - INFO: 주요 이벤트
  - DEBUG: 상세 정보
- 로그 파일 관리
  - 로그 회전
  - 압축 보관
  - 보존 기간 설정

## 보안

- CORS 설정
  - 허용된 오리진 제한
  - 메서드 및 헤더 제어
  - 자격증명 정책
- API 인증/인가
  - JWT 기반 인증
  - Role 기반 접근 제어
  - Rate Limiting
- 데이터베이스 보안
  - 암호화 저장 (AES-256)
  - 접근 제어 (RBAC)
  - 감사 로깅
- 환경 변수 관리
  - 비밀 정보 분리
  - 환경별 설정
  - 암호화된 시크릿

## 문제 해결

자세한 실행 방법과 문제 해결 가이드는 [실행 가이드](RUN_GUIDE.md)를 참조하세요.

### 주요 문제 해결 단계:
1. Docker Desktop 실행 상태 확인
   - 서비스 상태
   - 리소스 사용량
   - 로그 확인
2. WSL2(Windows의 경우) 정상 실행 확인
   - 커널 버전
   - 메모리 할당
   - 네트워크 연결
3. 로그 분석
   - 에러 메시지 확인
   - 스택 트레이스 분석
   - 메트릭 검토
4. 환경 초기화
   ```bash
   # 전체 환경 초기화
   docker compose down -v --remove-orphans
   
   # 볼륨 정리
   docker volume prune
   
   # 이미지 재빌드
   docker compose build --no-cache
   ```

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

