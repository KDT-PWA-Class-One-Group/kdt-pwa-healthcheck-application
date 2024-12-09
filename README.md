# Health Check System

마이크로서비스 아키텍처 기반의 헬스 체크 시스템입니다.

## 시스템 구성

- **프론트엔드**: Next.js 기반 웹 클라이언트
- **백엔드**: Python (FastAPI) 기반 REST API 서버
- **데이터베이스**: PostgreSQL
- **프록시**: Nginx (JSON 로깅 지원)

## 기술 스택

- **프론트엔드**: Next.js
- **백엔드**:
  - Python 3.10
  - FastAPI 0.115.x
  - SQLAlchemy 2.0.x
  - Pydantic 2.5.x
- **데이터베이스**: PostgreSQL
- **프록시**: Nginx

## 사전 요구사항

- Docker
- Docker Compose v2 이상
- GitHub 계정 (이미지 다운로드용)

## 설치 및 실행 방법

1. 네트워크 생성:
```bash
docker network create healthcheck-frontend
docker network create healthcheck-backend
```

2. 서비스 실행:
```bash
docker-compose up -d
```

## 서비스 접속 정보

- 웹 클라이언트: http://localhost
- API 서버: http://localhost:8000
- API 문서: http://localhost:8000/docs
- 데이터베이스: localhost:5432
  - DB명: healthcheck
  - 사용자: user
  - 비밀번호: password

## 상태 확인

각 서비스의 상태는 다음 명령어로 확인할 수 있습니다:
```bash
docker-compose ps
```

헬스체크 엔드포인트:
- API 서버: http://localhost:8000/health
- 클라이언트: http://localhost:3000/health
- 프록시: http://localhost/health

## 로그 확인

각 서비스의 로그는 다음 명령어로 확인할 수 있습니다:
```bash
# 전체 로그
docker-compose logs

# 특정 서비스 로그
docker-compose logs [service_name]  # api, client, db, proxy
```

## 개발 환경 설정

로컬 개발 환경에서 실행하려면 다음과 같이 설정합니다:

1. API 서비스 빌드 및 실행:
```bash
docker-compose build api
docker-compose up -d
```

2. 변경사항 확인:
```bash
docker-compose logs -f api
```

## 문제 해결

1. 네트워크 오류 발생 시:
```bash
docker-compose down
docker network prune
docker network create healthcheck-frontend
docker network create healthcheck-backend
docker-compose up -d
```

2. 컨테이너 재시작:
```bash
docker-compose restart [service_name]
```

## 라이선스

MIT License
