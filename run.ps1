# 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ 에러: 이 스크립트는 관리자 권한으로 실행해야 합니다." -ForegroundColor Red
    exit 1
}

# 에러 처리 함수
function Handle-Error {
    param([string]$message)
    Write-Host "❌ 에러: $message" -ForegroundColor Red
    exit 1
}

# 상태 표시 함수
function Show-Status {
    param([string]$message)
    Write-Host "📌 $message" -ForegroundColor Cyan
}

# 성공 메시지 함수
function Show-Success {
    param([string]$message)
    Write-Host "✅ $message" -ForegroundColor Green
}

# 경고 메시지 함수
function Show-Warning {
    param([string]$message)
    Write-Host "⚠️ $message" -ForegroundColor Yellow
}

# WSL 설치 확인
if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    Handle-Error "WSL이 설치되어 있지 않습니다. WSL을 먼저 설치해주세요."
}

# Docker Desktop 실행 확인
if (!(Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Handle-Error "Docker Desktop이 실행되고 있지 않습니다. Docker Desktop을 실행해주세요."
}

# 환경 변수 파일 생성 함수
function Create-EnvFile {
    Show-Status "환경 변수 설정을 시작합니다..."
    
    # 기본 설정
    $POSTGRES_DB = "healthcheck"
    $POSTGRES_USER = "postgres"
    $POSTGRES_PASSWORD = "postgres"
    $POSTGRES_HOST_AUTH_METHOD = "trust"
    $DOCKER_REGISTRY = "ghcr.io"
    $IMAGE_TAG = "latest"
    
    # GitHub 정보 입력
    $GITHUB_USERNAME = Read-Host "GitHub 사용자명을 입력하세요"
    
    $secureString = Read-Host "GitHub Personal Access Token을 입력하세요" -AsSecureString
    $GITHUB_TOKEN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

    # GitHub Container Registry 로그인 시도
    Show-Status "GitHub Container Registry 로그인을 시도합니다..."
    $loginResult = wsl bash -c "echo '$GITHUB_TOKEN' | docker login ghcr.io -u '$GITHUB_USERNAME' --password-stdin"
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "GitHub 로그인에 실패했습니다. 인증 정보를 확인해주세요."
    }
    
    # .env 파일 생성
    $envContent = @"
# 데이터베이스 설정
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_AUTH_METHOD=$POSTGRES_HOST_AUTH_METHOD

# Docker 레지스트리 설정
DOCKER_REGISTRY=$DOCKER_REGISTRY
DOCKER_NAMESPACE=$GITHUB_USERNAME
IMAGE_TAG=$IMAGE_TAG

# GitHub 설정
GITHUB_USERNAME=$GITHUB_USERNAME
GITHUB_TOKEN=$GITHUB_TOKEN

# 플랫폼 설정
DOCKER_DEFAULT_PLATFORM=linux/amd64
TZ=Asia/Seoul
NODE_ENV=development
"@

    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Show-Success ".env 파일이 생성되었습니다."
}

# 로그 디렉토리 생성
function Create-LogDirectories {
    Show-Status "로그 디렉토리를 생성합니다..."
    New-Item -ItemType Directory -Force -Path "api/logs", "client/logs", "db/logs", "proxy/logs" | Out-Null
    Show-Success "로그 디렉토리가 생성되었습니다."
}

# 컨테이너 상태 확인 함수
function Check-ContainerHealth {
    param([string]$containerName)
    
    Show-Status "$containerName 컨테이너의 상태를 확인하는 중..."
    $maxAttempts = 30
    $attempt = 1
    
    while ($attempt -le $maxAttempts) {
        $containerStatus = wsl docker ps --filter "name=$containerName" --filter "health=healthy" --format "{{.Names}}"
        if ($containerStatus -like "*$containerName*") {
            Show-Success "$containerName 컨테이너가 정상적으로 실행되었습니다."
            return $true
        }
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
        $attempt++
    }
    
    Handle-Error "$containerName 컨테이너가 정상적으로 시작되지 않았습니다."
    return $false
}

# 데이터베이스 초기화 확인
function Check-DatabaseInit {
    Show-Status "데이터베이스 초기화 상태를 확인합니다..."
    $result = wsl docker exec healthcheck-db psql -U postgres -d healthcheck -c "SELECT 1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Show-Success "데이터베이스가 정상적으로 초기화되었습니다."
    } else {
        Handle-Error "데이터베이스 초기화에 실패했습니다."
    }
}

# 메인 실행 로직
try {
    # 환경 변수 파일 확인
    if (!(Test-Path ".env")) {
        Create-EnvFile
    } else {
        Show-Warning ".env 파일이 이미 존재합니다."
        $reset = Read-Host "환경 변수를 다시 설정하시겠습니까? (y/N)"
        if ($reset.ToLower() -eq "y") {
            Create-EnvFile
        }
    }

    # 로그 디렉토리 생성
    Create-LogDirectories

    # 이전 컨테이너 정리
    Show-Status "이전 컨테이너를 정리합니다..."
    wsl docker compose down -v --remove-orphans

    # 컨테이너 실행
    Show-Status "컨테이너를 시작합니다..."
    wsl docker compose up -d

    # 컨테이너 상태 확인
    Check-ContainerHealth "healthcheck-db"
    Check-ContainerHealth "healthcheck-api"
    Check-ContainerHealth "healthcheck-client"
    Check-ContainerHealth "healthcheck-proxy"

    # 데이터베이스 초기화 확인
    Check-DatabaseInit

    # 최종 상태 출력
    Show-Success "모든 서비스가 성공적으로 시작되었습니다!"
    Write-Host "`n📋 접속 정보:" -ForegroundColor Green
    Write-Host "- 웹 서비스: http://localhost" -ForegroundColor Cyan
    Write-Host "- API 서비스: http://localhost/api" -ForegroundColor Cyan
    Write-Host "- 헬스체크: http://localhost/health" -ForegroundColor Cyan

    # 유용한 명령어 안내
    Write-Host "`n📝 유용한 명령어:" -ForegroundColor Yellow
    Write-Host "- 전체 로그 확인: " -NoNewline; Write-Host "wsl docker compose logs" -ForegroundColor Cyan
    Write-Host "- 특정 서비스 로그 확인: " -NoNewline; Write-Host "wsl docker compose logs [서비스명]" -ForegroundColor Cyan
    Write-Host "- 컨테이너 재시작: " -NoNewline; Write-Host "wsl docker compose restart" -ForegroundColor Cyan
    Write-Host "- 환경 종료: " -NoNewline; Write-Host "wsl docker compose down" -ForegroundColor Cyan
    Write-Host "- 데이터베이스 접속: " -NoNewline; Write-Host "wsl docker exec -it healthcheck-db psql -U postgres -d healthcheck" -ForegroundColor Cyan

    # 개발 환경 설정 완료
    Show-Success "개발 환경 설정이 완료되었습니다. 즐거운 개발 되세요! 🚀"
} catch {
    Handle-Error $_.Exception.Message
} 