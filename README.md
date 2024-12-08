# Health Check System

마이크로서비스 아키텍처 기반의 헬스 체크 시스템입니다.

## 시스템 구성

- **프론트엔드**: Next.js 기반 웹 클라이언트
- **백엔드**: Python 기반 REST API 서버
- **데이터베이스**: PostgreSQL
- **프록시**: Nginx (JSON 로깅 지원)

## 사전 요구사항

- Docker
- Docker Compose
- GitHub 계정 (이미지 다운로드용)

## 설치 및 실행 방법

1. GitHub 패키지 레지스트리 로그인:
```bash
export GITHUB_REPOSITORY="your-username/your-repo"
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

2. 환경 변수 설정:
```bash
export GITHUB_REPOSITORY="your-username/your-repo"
```

3. 서비스 실행:
```bash
docker-compose up -d
```

## 서비스 접속 정보

- 웹 클라이언트: http://localhost
- API 서버: http://localhost/api
- 데이터베이스: localhost:5432

## 로그 확인

JSON 형식의 로그는 다음 위치에서 확인할 수 있습니다:

- 일반 접근 로그: `/var/log/nginx/access.log`
- 클라이언트 접근 로그: `/var/log/nginx/client_access.log`
- API 접�� 로그: `/var/log/nginx/api_access.log`

로그 확인 명령어:
```bash
docker-compose logs proxy
```

## 개발 환경 설정

로컬 개발 환경에서 실행하려면 다음과 같이 설정합니다:

1. 레포지토리 클론:
```bash
git clone https://github.com/your-username/your-repo.git
```

2. 로컬 빌드 및 실행:
```bash
docker-compose -f docker-compose.dev.yml up --build
```

## 라이선스

MIT License
