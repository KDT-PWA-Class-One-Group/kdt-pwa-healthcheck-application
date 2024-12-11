# 헬스체크 애플리케이션 실행 가이드

## 필수 요구사항

- Docker 및 Docker Compose가 설치되어 있어야 합니다.
- Git이 설치되어 있어야 합니다.
- GitHub 계정 및 Personal Access Token이 필요합니다.
- Windows 사용자의 경우:
  - WSL2가 설치되어 있어야 합니다.
  - Docker Desktop이 실행 중이어야 합니다.

## 프로젝트 실행 방법

### Windows 사용자

1. PowerShell을 관리자 권한으로 실행합니다.

2. 프로젝트 디렉토리로 이동한 후, 다음 명령어를 실행합니다:
```powershell
.\run.ps1
```

### Linux/macOS 사용자

터미널에서 다음 명령어를 실행합니다:
```bash
chmod +x ./run.sh
./run.sh
```

## 실행 과정

스크립트는 자동으로 다음 작업을 수행합니다:

1. **환경 검사**
   - 필수 프로그램 설치 확인 (Docker, Git, WSL2)
   - Docker 실행 상태 확인

2. **환경 설정**
   - GitHub 인증 정보 입력
   - 환경 변수 설정 (.env 파일 생성)
   - 로그 디렉토리 생성

3. **컨테이너 관리**
   - 이전 컨테이너 정리
   - 새 컨테이너 실행
   - 컨테이너 상태 확인

4. **상태 확인**
   - 데이터베이스 초기화 확인
   - 서비스 헬스체크
   - 접속 정보 표시

## 접속 정보

실행이 완료되면 다음 주소로 접속할 수 있습니다:
- 웹 서비스: `http://localhost`
- API 서비스: `http://localhost/api`
- 헬스체크: `http://localhost/health`

## 유용한 명령어

### Windows PowerShell

```powershell
# 전체 로그 확인
wsl docker compose logs

# 특정 서비스 로그 확인
wsl docker compose logs [서비스명]

# 컨테이너 재시작
wsl docker compose restart

# 환경 종료
wsl docker compose down

# 데이터베이스 접속
wsl docker exec -it healthcheck-db psql -U postgres -d healthcheck
```

### Linux/macOS

```bash
# 전체 로그 확인
docker compose logs

# 특정 서비스 로그 확인
docker compose logs [서비스명]

# 컨테이너 재시작
docker compose restart

# 환경 종료
docker compose down

# 데이터베이스 접속
docker exec -it healthcheck-db psql -U postgres -d healthcheck
```

## 주의사항

1. **M1/M2 Mac 사용자**
   - 기본적으로 `linux/amd64` 플랫폼으로 설정되어 있습니다.
   - 필요한 경우 `.env` 파일에서 `DOCKER_DEFAULT_PLATFORM=linux/arm64`로 변경하실 수 있습니다.

2. **리소스 요구사항**
   - 최소 메모리: 2GB
   - 최소 CPU: 2 코어

3. **보안**
   - GitHub Personal Access Token은 안전하게 관리해주세요.
   - 토큰 노출 시 즉시 재발급이 필요합니다.

## 문제 해결

문제가 발생할 경우:

1. Docker Desktop이 실행 중인지 확인
2. WSL2(Windows의 경우)가 정상적으로 실행 중인지 확인
3. 로그 확인으로 구체적인 오류 메시지 확인
4. 필요한 경우 전체 환경을 초기화:
   ```bash
   docker compose down -v --remove-orphans
   ``` 