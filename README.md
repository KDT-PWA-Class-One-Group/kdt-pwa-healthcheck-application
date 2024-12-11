# Health Check Application

## 시작하기

### 운영체제별 설정 가이드

- [Windows 사용자 가이드](WINDOWS_GUIDE.md)
- [일반 설정 가이드](SETUP.md)

## 개발 환경 설정

1. 사전 요구사항
   - Docker Desktop
   - Git
   - GitHub 계정 및 액세스 토큰

2. 환경 설정
   ```bash
   # 레포지토리 클론
   git clone [repository-url]
   cd [repository-name]

   # 환경 변수 설정
   cp .env.example .env
   # .env 파일 수정

   # 실행
   chmod +x run.sh
   ./run.sh
   ```

## 주요 기능

- 헬스체크 모니터링
- 실시간 상태 확인
- 알림 설정
- 대시보드 제공

## 아키텍처

- Frontend: Next.js
- Backend: Node.js
- Database: PostgreSQL
- Proxy: Nginx

## 컨테이너 구조

- Client (Next.js)
- API (Node.js)
- Database (PostgreSQL)
- Proxy (Nginx)

## 개발 가이드

자세한 개발 가이드는 다음 문서들을 참조하세요:
- [Windows 개발 환경 설정](WINDOWS_GUIDE.md)
- [API 문서](./docs/API.md)
- [데이터베이스 스키마](./docs/DATABASE.md)

## 문제 해결

- [Windows 문제 해결 가이드](WINDOWS_GUIDE.md#문제-해결)
- [일반 문제 해결 가이드](SETUP.md#문제-해결)

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
