# 프로젝트 설정 가이드

## 목차
1. [사전 요구사항](#사전-요구사항)
2. [운영체제별 설정](#운영체제별-설정)
3. [프로젝트 실행](#프로젝트-실행)
4. [문제 해결](#문제-해결)

## 사전 요구사항

### 공통 요구사항
- Git
- Docker Desktop
- GitHub 계정 및 Personal Access Token (패키지 읽기 권한 필요)

### 운영체제별 요구사항
- Windows: WSL2
- macOS: Rosetta 2 (M1/M2 칩셋)
- Linux: Docker 그룹 권한

## 운영체제별 설정

### Windows 사용자
1. WSL2 설치:
   ```powershell
   wsl --install
   ```

2. Docker Desktop 설정:
   - WSL2 기반 엔진 사용 설정
   - 리소스 할당:
     - CPU: 최소 2코어
     - 메모리: 최소 4GB
     - 스왑: 최소 1GB

### macOS 사용자
1. M1/M2 칩셋 사용자:
   ```bash
   softwareupdate --install-rosetta
   ```

2. Docker Desktop 설정:
   - 리소스 할당:
     - CPU: 최소 2코어
     - 메모리: 최소 4GB
     - 스왑: 최소 1GB

### Linux 사용자
1. Docker 그룹 설정:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

## 프로���트 실행

1. 레포지토리 클론:
   ```bash
   git clone [repository-url]
   cd [repository-name]
   ```

2. 환경 변수 설정:
   ```bash
   cp .env.example .env
   # .env 파일을 적절히 수정
   ```

3. 실행:
   ```bash
   chmod +x run.sh
   ./run.sh
   ```

## 문제 해결

### 볼륨 권한 문제
```bash
# 로그 디렉토리 권한 수정
sudo chown -R $(id -u):$(id -g) ./*/logs
```

### 네트워크 문제
```bash
# 네트워크 초기화
docker-compose down
docker network prune
./run.sh
```

### 컨테이너 로그 확인
```bash
# 전체 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f [service-name]
```

### 캐시 초기화
```bash
# Docker 캐시 정리
docker system prune -a
```

### Windows 특정 문제
1. CRLF 문제:
   ```bash
   # Git 설정
   git config --global core.autocrlf input
   ```

2. 경로 문제:
   - WSL2 내부에서 프로젝트 클론
   - Windows 경로 사용 시 `/` 사용

### M1/M2 Mac 특정 문제
1. 아키텍처 호환성:
   ```bash
   # 강제로 amd64 플랫폼 사용
   export DOCKER_DEFAULT_PLATFORM=linux/amd64
   ```

## 지원 및 문의
문제가 발생하면 GitHub Issues에 보고해주세요. 