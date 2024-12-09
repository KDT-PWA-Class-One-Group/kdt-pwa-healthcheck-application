#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 macOS 환경 설정을 시작합니다...${NC}"

# sudo 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  일부 설치 과정에서 관리자 권한이 필요할 수 있습니다.${NC}"
fi

# Homebrew 설치 함수
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew를 설치합니다...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Homebrew PATH 설정
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

# 필수 도구 설치 함수
install_requirements() {
    echo -e "${CYAN}📦 필수 도구 설치를 시작합니다...${NC}"

    # 패키지 목록과 버전
    declare -A packages=(
        ["node@22.11.0"]="node:22.11.0"
        ["python@3.10"]="Python:3.10"
        ["postgresql@14"]="postgres:14.6"
        ["nginx"]=""
    )

    # Homebrew 업데이트
    brew update

    # 각 패키지 설치 및 버전 확인
    for package in "${!packages[@]}"; do
        if [[ ${packages[$package]} != "" ]]; then
            version=${packages[$package]#*:}
            name=${packages[$package]%:*}

            echo -e "${CYAN}$package 설치/확인 중...${NC}"

            if ! command -v $name &> /dev/null; then
                brew install $package
            else
                current_version=$($name --version | head -n 1)
                if [[ $current_version != *"$version"* ]]; then
                    echo -e "${YELLOW}⚠️ $name 버전이 $version이(가) 아닙니다. 현재 버전: $current_version${NC}"
                    brew upgrade $package
                fi
            fi
        else
            brew install $package
        fi
    done
}

# Client 앱 설치 (Next.js)
install_client_app() {
    echo -e "${CYAN}📦 Client 앱 설치 중...${NC}"
    cd client

    yarn install --frozen-lockfile
    yarn build

    cd ..
    echo -e "${GREEN}✅ Client 앱 설치 완료!${NC}"
}

# API 앱 설치 (FastAPI)
install_api_app() {
    echo -e "${CYAN}📦 API 앱 설치 중...${NC}"
    cd api

    # Python 가상환경 설정
    python3 -m venv venv
    source venv/bin/activate

    # 환경 변수 설정
    export PYTHONPATH="/app"
    export PYTHONUNBUFFERED="1"
    export PYTHONDONTWRITEBYTECODE="1"

    # 의존성 설치
    pip install --no-cache-dir -r requirements.txt

    deactivate
    cd ..
    echo -e "${GREEN}✅ API 앱 설치 완료!${NC}"
}

# Monitor 앱 설치 (Node.js)
install_monitor_app() {
    echo -e "${CYAN}📦 Monitor 앱 설치 중...${NC}"
    cd monitor

    yarn install --frozen-lockfile
    yarn build

    cd ..
    echo -e "${GREEN}✅ Monitor 앱 설치 완료!${NC}"
}

# PostgreSQL DB 설정
setup_database() {
    echo -e "${CYAN}🗄️ PostgreSQL 데이터베이스 설정 중...${NC}"

    # PostgreSQL 서비스 상태 확인 및 시작
    if ! brew services list | grep postgresql@14 | grep started &> /dev/null; then
        echo -e "${YELLOW}PostgreSQL 서비스를 시작합니다...${NC}"
        brew services start postgresql@14
    fi

    # 설정 파일 복사
    pg_config_path=$(brew --prefix)/var/postgresql@14
    if [ -f "db/postgresql.conf" ]; then
        cp db/postgresql.conf "$pg_config_path/postgresql.conf"
    fi
    if [ -f "db/pg_hba.conf" ]; then
        cp db/pg_hba.conf "$pg_config_path/pg_hba.conf"
    fi

    # 환경 변수 설정
    echo "export POSTGRES_DB=healthcheck" >> ~/.zshrc
    echo "export POSTGRES_USER=user" >> ~/.zshrc
    echo "export POSTGRES_PASSWORD=password" >> ~/.zshrc

    # 현재 세션에도 적용
    export POSTGRES_DB=healthcheck
    export POSTGRES_USER=user
    export POSTGRES_PASSWORD=password

    # 초기화 스크립트 실행
    if [ -f "db/init.sql" ]; then
        PGPASSWORD=password psql -U user -d healthcheck -f db/init.sql
    fi

    echo -e "${GREEN}✅ 데이터베이스 설정 완료!${NC}"
}

# Nginx 설정
setup_nginx() {
    echo -e "${CYAN}🌐 Nginx 설정 중...${NC}"

    nginx_conf_path=$(brew --prefix)/etc/nginx
    if [ -f "proxy/nginx.conf" ]; then
        cp proxy/nginx.conf "$nginx_conf_path/nginx.conf"
        mkdir -p "$nginx_conf_path/conf.d"
        cp proxy/conf.d/default.conf "$nginx_conf_path/conf.d/default.conf"

        # Nginx 서비스 재시작
        brew services restart nginx
    fi

    echo -e "${GREEN}✅ Nginx 설정 완료!${NC}"
}

# 메인 실행 부분
install_homebrew
install_requirements

# 각 앱 설치 및 설정
install_client_app
install_api_app
install_monitor_app
setup_database
setup_nginx

echo -e "${GREEN}🎉 모든 설치 및 설정이 완료되었습니다!${NC}"
echo -e "${YELLOW}
📋 다음 단계를 확인해주세요:
1. 환경 변수 설정 확인
   - Client: PORT=3000
   - Monitor: PORT=3001
   - API: PORT=8000
   - DB: POSTGRES_DB=healthcheck, POSTGRES_USER=user, POSTGRES_PASSWORD=password

2. 서비스 상태 확인:
   - PostgreSQL: brew services list | grep postgresql
   - Nginx: brew services list | grep nginx

3. API 서버 실행:
   cd api
   source venv/bin/activate
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
   - 서비스 수동 시작: brew services start [postgresql@14/nginx]
   - 서비스 재시작: brew services restart [postgresql@14/nginx]
   - 로그 확인:
     * PostgreSQL: $(brew --prefix)/var/log/postgresql@14.log
     * Nginx: $(brew --prefix)/var/log/nginx/
     * API: api/logs
     * Monitor: monitor/logs
${NC}"
