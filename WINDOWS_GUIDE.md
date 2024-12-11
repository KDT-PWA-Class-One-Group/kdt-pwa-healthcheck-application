# Windows 환경 설정 및 개발 가이드

## 목차
1. [사전 준비](#사전-준비)
2. [WSL2 설치](#wsl2-설치)
3. [Docker Desktop 설치](#docker-desktop-설치)
4. [VS Code 설치 및 설정](#vs-code-설치-및-설정)
5. [프로젝트 실행](#프로젝트-실행)
6. [개발 환경 설정](#개발-환경-설정)
7. [문제 해결](#문제-해결)

## 사전 준비

### 시스템 요구사항
- Windows 10 Pro/Enterprise/Education (21H2 이상) 또는 Windows 11
- 최소 8GB RAM (16GB 권장)
- CPU의 가상화 기능 활성화 (BIOS/UEFI 설정)

### BIOS/UEFI에서 가상화 활성화
1. PC를 재시작하고 BIOS/UEFI 설정 진입
   - 일반적으로 F2, F12, Del 키 사용
2. 가상화 옵션 활성화
   - Intel CPU: "Intel Virtualization Technology" 또는 "Intel VT-x"
   - AMD CPU: "SVM Mode" 또는 "AMD-V"

## WSL2 설치

1. PowerShell을 관리자 권한으로 실행

2. WSL2 설치 명령어 실행:
   ```powershell
   wsl --install
   ```

3. PC 재시작

4. Ubuntu 설치 (Microsoft Store에서):
   - Microsoft Store 실행
   - "Ubuntu" 검색 및 설치
   - Ubuntu 실행 및 초�� 설정

## Docker Desktop 설치

1. [Docker Desktop 다운로드](https://www.docker.com/products/docker-desktop)

2. 설치 프로그램 실행
   - "Use WSL 2 instead of Hyper-V" 옵션 선택

3. Docker Desktop 설정
   ```
   Settings > Resources > WSL Integration
   - Ubuntu 활성화
   - Apply & Restart
   ```

4. 리소스 할당
   ```
   Settings > Resources
   - CPU: 4 이상
   - Memory: 8GB 이상
   - Swap: 2GB 이상
   ```

## VS Code 설치 및 설정

1. [VS Code 다운로드 및 설치](https://code.visualstudio.com/)

2. 필수 확장 프로그램 설치:
   - Remote Development
   - Docker
   - WSL

3. WSL 연결 설정:
   - `Ctrl + Shift + P` > "WSL: New Window" 선택
   - Ubuntu 환경에서 VS Code 실행됨

## 프로젝트 실행

1. GitHub 인증 설정:
   ```bash
   # Ubuntu 터미널에서
   echo "ghp_your_token" | docker login ghcr.io -u your-username --password-stdin
   ```

2. 프로젝트 클론:
   ```bash
   cd ~
   git clone [repository-url]
   cd [repository-name]
   ```

3. 환경 변수 설정:
   ```bash
   cp .env.example .env
   # .env 파일 수정
   ```

4. 컨테이너 실행:
   ```bash
   chmod +x run.sh
   ./run.sh
   ```

## 개발 환경 설정

### VS Code와 컨테이너 연결

1. VS Code에서 Docker 확장 사용:
   - `Ctrl + Shift + P` > "Remote-Containers: Attach to Running Container"
   - 개발하고자 하는 컨테이너 선택

2. 작업 디렉토리 설정:
   ```bash
   cd /app  # 또는 프로젝트의 작업 디렉토리
   code .
   ```

### 로컬 파일 동기화

1. 볼륨 마운트 확인:
   ```bash
   docker-compose ps
   docker-compose config
   ```

2. 소스 코드 수정:
   - VS Code에서 직접 수정
   - 변경 사항 자동 동기화

### 디버깅 설정

1. VS Code 디버깅 설정 파일 생성:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "type": "node",
         "request": "attach",
         "name": "Attach to API",
         "port": 9229,
         "restart": true,
         "remoteRoot": "/app"
       }
     ]
   }
   ```

## 문제 해결

### 일반적인 문제

1. WSL2 메모리 문제:
   ```bash
   # %UserProfile%\.wslconfig 파일 생성
   [wsl2]
   memory=8GB
   swap=2GB
   ```

2. 권한 문제:
   ```bash
   sudo chown -R $USER:$USER .
   ```

3. 포트 충돌:
   ```bash
   netstat -ano | findstr "80"
   taskkill /PID [프로세스ID] /F
   ```

### Docker 관련 문제

1. 이미지 pull 실패:
   ```bash
   docker logout
   docker login ghcr.io
   docker pull [이미지명]
   ```

2. 볼륨 마운트 실패:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

### VS Code 연결 문제

1. WSL 재시작:
   ```powershell
   wsl --shutdown
   wsl
   ```

2. Docker 재시작:
   - Docker Desktop 종료
   - 작업 관리자에서 관련 프로세스 종료
   - Docker Desktop 재시작

## 유용한 명령어

```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f [서비스명]

# 컨테이너 재시작
docker-compose restart [서비스명]

# 전체 초기화
docker-compose down
./run.sh
```

## 지원 및 문의

문제가 발생하면 다음 채널을 통해 문의해주세요:
1. GitHub Issues
2. 팀 채팅방
3. 이메일: [담당자 이메일] 