#!/usr/bin/env pwsh

Write-Host "🚀 Windows 환경 설정을 시작합니다..." -ForegroundColor Green

# 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ 이 스크립트는 관리자 권한으로 실행해야 합니다." -ForegroundColor Red
    exit 1
}

# Chocolatey 패키지 관리자 설치 함수
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey를 설치합니다..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

        # PATH 환경 변수 새로고침
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

# 필수 도구 설치 함수
function Install-Requirements {
    Write-Host "📦 필수 도구 설치를 시작합니다..." -ForegroundColor Cyan

    $packages = @(
        @{Name = "nodejs"; Version = "22.11.0"; Command = "node"; VersionCheck = { node -v } },
        @{Name = "python3"; Version = "3.10"; Command = "python"; VersionCheck = { python --version } },
        @{Name = "postgresql14"; Version = "14.6"; Command = "psql"; VersionCheck = { psql --version } },
        @{Name = "nginx"; Command = "nginx"; ServiceName = "nginx" }
    )

    foreach ($package in $packages) {
        if (-not (Get-Command $package.Command -ErrorAction SilentlyContinue)) {
            Write-Host "$($package.Name)을(를) 설치합니다..." -ForegroundColor Yellow
            choco install $package.Name -y

            # PATH 환경 변수 새로고침
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }

        # 버전 확인 (버전이 지정된 패키지만)
        if ($package.Version) {
            $currentVersion = & $package.VersionCheck
            if ($currentVersion -notlike "*$($package.Version)*") {
                Write-Host "⚠️ $($package.Name) 버전이 $($package.Version)이(가) 아닙니다. 현재 버전: $currentVersion" -ForegroundColor Yellow
                Write-Host "버전을 업데이트합니다..." -ForegroundColor Yellow
                choco upgrade $package.Name -y
            }
        }
    }
}

# Client 앱 설치 (Next.js)
function Install-ClientApp {
    Write-Host "📦 Client 앱 설치 중..." -ForegroundColor Cyan
    Set-Location client

    yarn install --frozen-lockfile
    yarn build

    Set-Location ..
    Write-Host "✅ Client 앱 설치 완료!" -ForegroundColor Green
}

# API 앱 설치 (FastAPI)
function Install-ApiApp {
    Write-Host "📦 API 앱 설치 중..." -ForegroundColor Cyan
    Set-Location api

    # Python 가상환경 설정
    python -m venv venv
    .\venv\Scripts\Activate.ps1

    # 환경 변수 설정
    $env:PYTHONPATH = "/app"
    $env:PYTHONUNBUFFERED = "1"
    $env:PYTHONDONTWRITEBYTECODE = "1"

    # 의존성 설치
    pip install --no-cache-dir -r requirements.txt

    deactivate
    Set-Location ..
    Write-Host "✅ API 앱 설치 완료!" -ForegroundColor Green
}

# Monitor 앱 설치 (Node.js)
function Install-MonitorApp {
    Write-Host "📦 Monitor 앱 설치 중..." -ForegroundColor Cyan
    Set-Location monitor

    yarn install --frozen-lockfile
    yarn build

    Set-Location ..
    Write-Host "✅ Monitor 앱 설치 완료!" -ForegroundColor Green
}

# PostgreSQL DB 설정
function Setup-Database {
    Write-Host "🗄️ PostgreSQL 데이터베이스 설정 중..." -ForegroundColor Cyan

    # PostgreSQL 서비스 상태 확인
    $service = Get-Service postgresql* -ErrorAction SilentlyContinue
    if ($service.Status -ne 'Running') {
        Write-Host "PostgreSQL 서비스를 시작합니다..." -ForegroundColor Yellow
        Start-Service postgresql*
    }

    # 설정 파일 복사
    $pgConfigPath = "C:\Program Files\PostgreSQL\14\data"
    if (Test-Path "db\postgresql.conf") {
        Copy-Item "db\postgresql.conf" -Destination "$pgConfigPath\postgresql.conf" -Force
    }
    if (Test-Path "db\pg_hba.conf") {
        Copy-Item "db\pg_hba.conf" -Destination "$pgConfigPath\pg_hba.conf" -Force
    }

    # 환경 변수 설정
    [Environment]::SetEnvironmentVariable("POSTGRES_DB", "healthcheck", "User")
    [Environment]::SetEnvironmentVariable("POSTGRES_USER", "user", "User")
    [Environment]::SetEnvironmentVariable("POSTGRES_PASSWORD", "password", "User")

    # 초기화 스크립트 실행
    if (Test-Path "db\init.sql") {
        $env:PGPASSWORD = "password"
        psql -U user -d healthcheck -f db\init.sql
    }

    Write-Host "✅ 데이터베이스 설정 완료!" -ForegroundColor Green
}

# Nginx 설정
function Setup-Nginx {
    Write-Host "🌐 Nginx 설정 중..." -ForegroundColor Cyan

    $nginxPath = "C:\tools\nginx"
    if (Test-Path "proxy\nginx.conf") {
        Copy-Item "proxy\nginx.conf" -Destination "$nginxPath\conf\nginx.conf" -Force
        Copy-Item "proxy\conf.d\default.conf" -Destination "$nginxPath\conf\conf.d\default.conf" -Force

        # Nginx 서비스 재시작
        Restart-Service nginx -ErrorAction SilentlyContinue
    }

    Write-Host "✅ Nginx 설정 완료!" -ForegroundColor Green
}

# 메인 실행 부분
Install-Chocolatey
Install-Requirements

# 각 앱 설치 및 설정
Install-ClientApp
Install-ApiApp
Install-MonitorApp
Setup-Database
Setup-Nginx

Write-Host "🎉 모든 설치 및 설정이 완료되었습니다!" -ForegroundColor Green
Write-Host @"

📋 다음 단계를 확인해주세요:
1. 환경 변수 설정 확인
   - Client: PORT=3000
   - Monitor: PORT=3001
   - API: PORT=8000
   - DB: POSTGRES_DB=healthcheck, POSTGRES_USER=user, POSTGRES_PASSWORD=password

2. 서비스 상태 확인:
   - PostgreSQL: Get-Service postgresql*
   - Nginx: Get-Service nginx

3. API 서버 실행:
   cd api
   .\venv\Scripts\Activate.ps1
   python run.py

4. Monitor 서비스 실행:
   cd monitor
   yarn start

5. Client 앱 실행:
   cd client
   yarn start

6. 헬스체크 URL:
   - Client: http://localhost:3000/health
   - Monitor: http://localhost:3001/health
   - API: http://localhost:8000/health
   - Nginx: http://localhost/health

7. 문제 해결:
   - 서비스 수동 시작: Start-Service [postgresql*/nginx]
   - 서비스 재시작: Restart-Service [postgresql*/nginx]
   - 로그 확인:
     * PostgreSQL: C:\Program Files\PostgreSQL\14\data\log
     * Nginx: C:\tools\nginx\logs
     * API: api\logs
     * Monitor: monitor\logs

"@ -ForegroundColor Yellow
