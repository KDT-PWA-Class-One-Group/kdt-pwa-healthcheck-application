# Health Check System

마이크로서비스 아키텍처 기반의 헬스 체크 시스템입니다.

## 프로젝트 개요

이 프로젝트는 마이크로서비스의 상태를 실시간으로 모니터링하고 관리하는 시스템입니다.

### 주요 기능
- 서비스 상태 실시간 모니터링
- 상태 이력 관리 및 통계
- 알림 설정 및 관리
- 대시보드를 통한 시각화
- 장애 발생 시 자동 알림

## 애플리케이션 구조

### 클라이언트 애플리케이션 (/client)
- **기술 스택**:
  - Next.js 14.x
  - TypeScript
  - TailwindCSS
  - ESLint
- **주요 기능**:
  - 실시간 대시보드 UI
  - 서비스 상태 모니터링 인터페이스
  - 반응형 웹 디자인
  - 실시간 데이터 시각화
  - 사용자 인증 및 권한 관리
  - 알림 설정 인터페이스

### API 서버 (/api)
- **기술 스택**:
  - FastAPI
  - SQLAlchemy
  - Pydantic
  - Python 3.10
- **주요 기능**:
  - RESTful API 엔드포인트
  - 실시간 상태 체크
  - 데이터베이스 CRUD 작업
  - JWT 기반 인증
  - 로깅 및 모니터링
  - 알림 시스템 통합

### 모니터링 서비스 (/monitor)
- **기술 스택**:
  - Node.js
  - TypeScript
  - Winston (로깅)
- **주요 기능**:
  - 실시간 서비스 상태 모니터링
  - 로그 수집 및 분석
  - 메트릭 데이터 수집
  - 알림 트리거 관리
  - 성능 모니터링
  - 장애 감지 및 보고

### 프록시 서버 (/proxy)
- **기술 스택**:
  - Nginx 1.25.x
- **주요 기능**:
  - 로드 밸런싱
  - SSL/TLS 종단점
  - 캐시 관리
  - 접근 제어
  - JSON 로깅
  - 보안 헤더 관리

### 데이터베이스 (/db)
- **기술 스택**:
  - PostgreSQL 15.x
- **주요 기능**:
  - 서비스 상태 데이터 저장
  - 사용자 정보 관리
  - 알림 설정 저장
  - 모니터링 이력 관리
  - 성능 메트릭 저장
  - 감사 로그 저장

## 개발 환경 설정

### 사전 요구사항
- Docker 24.x 이상
- Docker Compose v2.x 이상
- GitHub 계정 (이미지 다운로드용)
- Node.js 18.x 이상 (로컬 개발 시)
- Python 3.10 이상 (로컬 개발 시)

### 초기 설정

1. 저장소 클론:
```bash
git clone [repository-url]
cd healthcheck-system
```

2. 환경 변수 설정:
```bash
cp .env.example .env
# .env 파일을 적절히 수정
```

3. 네트워크 생성:
```bash
docker network create healthcheck-frontend
docker network create healthcheck-backend
```

### 서비스 실행

#### Docker Compose 사용
```bash
# 전체 서비스 실행
docker-compose up -d

# 특정 서비스만 실행
docker-compose up -d [service-name]
```

#### 로컬 개발 환경
1. 프론트엔드:
```bash
cd frontend
npm install
npm run dev
```

2. 백엔드:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

## 서비스 접속 정보

### 프로덕션 환경
- **웹 클라이언트**: http://localhost
- **API 서버**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **데이터베이스**:
  - 호스트: localhost:5432
  - 데이터베이스: healthcheck
  - 사용자: user
  - 비밀번호: password

### 개발 환경
- **웹 클라이언트**: http://localhost:3000
- **API 서버**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs

## 모니터링 및 관리

### 상태 확인
```bash
# 전체 서비스 상태
docker-compose ps

# 개별 서비스 상태
docker-compose ps [service-name]
```

### 헬스체크 엔드포인트
- **API**: http://localhost:8000/health
- **클라이언트**: http://localhost:3000/health
- **프록시**: http://localhost/health

### 로그 관리
```bash
# 전체 로그 확인
docker-compose logs

# 특정 서비스 로그
docker-compose logs [service-name]

# 실시간 로그 확인
docker-compose logs -f [service-name]
```

## 문제 해결 가이드

### 일반적인 문제

1. 컨테이너 시작 실패
```bash
# 로그 확인
docker-compose logs [service-name]

# 컨테이너 재시작
docker-compose restart [service-name]
```

2. 네트워크 문제
```bash
# 네트워크 초기화
docker-compose down
docker network prune
docker network create healthcheck-frontend
docker network create healthcheck-backend
docker-compose up -d
```

3. 데이터베이스 연결 오류
```bash
# DB 컨테이너 재시작
docker-compose restart db

# DB 로그 확인
docker-compose logs db
```

### 성능 최���화
- 주기적인 로그 정리
- 데이터베이스 인덱스 관리
- 캐시 설정 최적화

## 배포 프로세스

1. 이미지 빌드:
```bash
docker-compose build
```

2. 서비스 배포:
```bash
docker-compose up -d
```

3. 마이그레이션 실행:
```bash
docker-compose exec api alembic upgrade head
```

## 기여 방법

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 라이선스

MIT License

## 팀 정보

- 프로젝트 관리자: [이름]
- 프론트엔드 개발: [이름]
- 백엔드 개발: [이름]
- DevOps: [이름]

## 문의

- 이슈 트래커: GitHub Issues
- 이메일: [이메일 주소]
