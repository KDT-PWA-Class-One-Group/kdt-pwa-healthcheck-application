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

# GitHub 인증 정보 입력 함수
function Get-GitHubCredentials {
    Show-Status "GitHub 인증 정보 설정"
    $script:GITHUB_USERNAME = Read-Host "GitHub 사용자명을 입력하세요"
    $secureString = Read-Host "GitHub Personal Access Token을 입력하세요" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    $script:GITHUB_TOKEN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # 환경 변수로 설정
    [Environment]::SetEnvironmentVariable('GITHUB_USERNAME', $script:GITHUB_USERNAME)
    [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', $script:GITHUB_TOKEN)
}

# WSL 설치 확인
if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    Handle-Error "WSL이 설치되어 있지 않습니다. WSL을 먼저 설치해주세요."
}

# Docker Desktop 실행 확인
if (!(Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Handle-Error "Docker Desktop이 실행되고 있지 않습니다. Docker Desktop을 실행해주세요."
}

# Git 설치 확인
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Handle-Error "Git이 설치되어 있지 않습니다."
}

# Git 저장소 확인
if (!(Test-Path .git)) {
    Handle-Error "현재 디렉토리가 Git 저장소가 아닙니다."
}

# .env 파일 확인 및 로드
if (!(Test-Path .env)) {
    Handle-Error ".env 파일이 없습니다. 먼저 run.ps1을 실행하여 환경을 설정해주세요."
}

# 환경 변수 로드
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# 환경 변수 설정 및 확인
$env:DOCKER_REGISTRY = if ($env:DOCKER_REGISTRY) { $env:DOCKER_REGISTRY } else { "ghcr.io" }
$env:DOCKER_NAMESPACE = if ($env:DOCKER_NAMESPACE) { $env:DOCKER_NAMESPACE } else { $env:GITHUB_ORGANIZATION }
$env:IMAGE_TAG = if ($env:IMAGE_TAG) { $env:IMAGE_TAG } else { git rev-parse --short HEAD }

# 레지스트리 유형에 따른 처리
switch ($env:DOCKER_REGISTRY) {
    "ghcr.io" {
        # GitHub 인증 정보가 없으면 입력 요청
        if ([string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or [string]::IsNullOrEmpty($env:GITHUB_USERNAME)) {
            Show-Warning "GitHub 인증 정보가 설정되어 있지 않습니다."
            Get-GitHubCredentials
        }
        else {
            Show-Status "기존 GitHub 인증 정보를 사용합니다."
            $reset = Read-Host "새로운 인증 정보를 입력하시겠습니까? (y/N)"
            if ($reset.ToLower() -eq "y") {
                Get-GitHubCredentials
            }
        }
        
        Show-Status "GitHub Container Registry 로그인 중..."
        $loginResult = wsl bash -c "echo '$env:GITHUB_TOKEN' | docker login ghcr.io -u '$env:GITHUB_USERNAME' --password-stdin"
        if ($LASTEXITCODE -ne 0) { Handle-Error "GitHub 로그인 실패" }
        
        # GitHub 사용 시 네임스페이스 설정
        if ($env:GITHUB_ORGANIZATION) {
            $env:DOCKER_NAMESPACE = $env:GITHUB_ORGANIZATION
        }
        else {
            $env:DOCKER_NAMESPACE = $env:GITHUB_USERNAME
        }
    }
    "localhost" {
        Show-Status "로컬 레지스트리 사용 중..."
    }
    default {
        Show-Status "레지스트리 $env:DOCKER_REGISTRY 사용 중..."
    }
}

Show-Status "빌드 태그: $env:IMAGE_TAG"

# 플랫폼 설정
$PLATFORM = if ($env:DOCKER_DEFAULT_PLATFORM) { $env:DOCKER_DEFAULT_PLATFORM } else { "linux/amd64" }
Show-Status "빌드 플랫폼: $PLATFORM"

# 멀티 플랫폼 빌더 설정
Show-Status "멀티 플랫폼 빌더 설정 중..."
wsl docker buildx rm multiplatform-builder 2>/dev/null
wsl docker buildx create --use --name multiplatform-builder
if ($LASTEXITCODE -ne 0) { Handle-Error "빌더 생성 실패" }

wsl docker buildx inspect --bootstrap
if ($LASTEXITCODE -ne 0) { Handle-Error "빌더 초기화 실패" }

# 이미지 빌드 및 푸시
Show-Status "이미지 빌드 및 푸시 시작..."
wsl docker buildx bake -f docker-compose.yml --push --set "*.platform=$PLATFORM"
if ($LASTEXITCODE -ne 0) { Handle-Error "빌드 및 푸시 실패" }

Show-Success "모든 이미지가 성공적으로 빌드되고 푸시되었습니다!"
Write-Host "`n📋 빌드 정보:" -ForegroundColor Green
Write-Host "- 태그: $env:IMAGE_TAG" -ForegroundColor Cyan
Write-Host "- 레지스트리: $env:DOCKER_REGISTRY/$env:DOCKER_NAMESPACE" -ForegroundColor Cyan
Write-Host "- 플랫폼: $PLATFORM" -ForegroundColor Cyan

# 이미지 목록 출력
Write-Host "`n📦 푸시된 이미지:" -ForegroundColor Yellow
Write-Host "- $env:DOCKER_REGISTRY/$env:DOCKER_NAMESPACE/healthcheck-db:$env:IMAGE_TAG" -ForegroundColor Cyan
Write-Host "- $env:DOCKER_REGISTRY/$env:DOCKER_NAMESPACE/healthcheck-api:$env:IMAGE_TAG" -ForegroundColor Cyan
Write-Host "- $env:DOCKER_REGISTRY/$env:DOCKER_NAMESPACE/healthcheck-client:$env:IMAGE_TAG" -ForegroundColor Cyan
Write-Host "- $env:DOCKER_REGISTRY/$env:DOCKER_NAMESPACE/healthcheck-proxy:$env:IMAGE_TAG" -ForegroundColor Cyan

# 새로운 인증 정보를 .env 파일에 저장할지 묻기
if ($env:DOCKER_REGISTRY -eq "ghcr.io") {
    $saveAuth = Read-Host "GitHub 인증 정보를 .env 파일에 저장하시겠습니까? (y/N)"
    if ($saveAuth.ToLower() -eq "y") {
        # 기존 인증 정보 제거
        $envContent = Get-Content .env | Where-Object { !$_.StartsWith("GITHUB_USERNAME=") -and !$_.StartsWith("GITHUB_TOKEN=") }
        $envContent | Set-Content .env
        
        # 새 인증 정보 추가
        Add-Content .env "GITHUB_USERNAME=$env:GITHUB_USERNAME"
        Add-Content .env "GITHUB_TOKEN=$env:GITHUB_TOKEN"
        Show-Success "GitHub 인증 정보가 .env 파일에 저장되었습니다."
    }
} 