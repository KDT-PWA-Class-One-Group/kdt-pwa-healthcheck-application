#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 에러 처리 함수
handle_error() {
    echo -e "${RED}❌ 에러: $1${NC}"
    exit 1
}

# 진행 상태 표시 함수
show_status() {
    echo -e "${BLUE}📌 $1${NC}"
}

# 성공 메시지 표시 함수
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 경고 메시지 표시 함수
show_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# OS 확인
case "$(uname -s)" in
    Linux*)
        if grep -q Microsoft /proc/version; then
            show_status "WSL 환경이 감지되었습니다."
        fi
        ;;
    Darwin*)
        show_status "macOS 환경이 감지되었습니다."
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        handle_error "Windows 환경에서는 WSL2를 사용해주세요. WSL2 설치 가이드: https://docs.microsoft.com/ko-kr/windows/wsl/install"
        ;;
    *)
        handle_error "지원되지 않는 운영체제입니다."
        ;;
esac

# Docker 실행 확인
if ! docker info > /dev/null 2>&1; then
    handle_error "Docker가 실행되고 있지 않습니다. Docker를 실행해주세요."
fi

# 환경 변수 파일 생성 함수
create_env_file() {
    show_status "환경 변수 설정을 시작합니다..."
    
    # 기본 설정
    POSTGRES_DB="healthcheck"
    POSTGRES_USER="postgres"
    POSTGRES_PASSWORD="postgres"
    POSTGRES_HOST_AUTH_METHOD="trust"
    DOCKER_REGISTRY="ghcr.io"
    IMAGE_TAG="latest"
    
    # GitHub 정보 입력
    echo -n "GitHub 사용자명을 입력하세요: "
    read GITHUB_USERNAME
    
    echo -n "GitHub Personal Access Token을 입력하세요 (입력 내용이 표시되지 않습니다): "
    read -s GITHUB_TOKEN
    echo

    # GitHub Container Registry 로그인 시도
    show_status "GitHub Container Registry 로그인을 시도합니다..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || {
        handle_error "GitHub 로그인에 실패했습니다. 인증 정보를 확인해주세요."
    }
    
    # .env 파일 생성
    cat > .env << EOL
# 데이터베이스 설정
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD}

# Docker 레지스트리 설정
DOCKER_REGISTRY=${DOCKER_REGISTRY}
DOCKER_NAMESPACE=${GITHUB_USERNAME}
IMAGE_TAG=${IMAGE_TAG}

# GitHub 설정
GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_TOKEN=${GITHUB_TOKEN}

# 플랫폼 설정
DOCKER_DEFAULT_PLATFORM=linux/amd64
TZ=Asia/Seoul
NODE_ENV=development
EOL
    
    show_success ".env 파일이 생성되었습니다."
}

# 로그 디렉토리 생성
create_log_directories() {
    show_status "로그 디렉토리를 생성합니다..."
    mkdir -p api/logs client/logs db/logs proxy/logs
    show_success "로그 디렉토리가 생성되었습니다."
}

# 컨테이너 상태 확인 함수
check_container_health() {
    local container_name=$1
    local max_attempts=30
    local attempt=1

    show_status "$container_name 컨테이너의 상태를 확인하는 중..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker ps --filter "name=$container_name" --filter "health=healthy" --format "{{.Names}}" | grep -q "$container_name"; then
            show_success "$container_name 컨테이너가 정상적으로 실행되었습니다."
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done

    handle_error "$container_name 컨테이너가 정상적으로 시작되지 않았습니다."
    return 1
}

# 데이터베이스 초기화 확인
check_database_init() {
    show_status "데이터베이스 초기화 상태를 확인합니다..."
    if docker exec healthcheck-db psql -U postgres -d healthcheck -c "SELECT 1" > /dev/null 2>&1; then
        show_success "데이터베이스가 정상적으로 초기화되었습니다."
    else
        handle_error "데이터베이스 초기화에 실패했습니다."
    fi
}

# 환경 변수 파일 확인
if [ ! -f .env ]; then
    create_env_file
else
    show_warning ".env 파일이 이미 존재합니다."
    echo -n "환경 변수를 다시 설정하시겠습니까? (y/N): "
    read RESET_ENV
    if [ "${RESET_ENV,,}" = "y" ]; then
        create_env_file
    fi
fi

# 로그 디렉토리 생성
create_log_directories

# 이전 컨테이너 정리
show_status "이전 컨테이너를 정리합니다..."
docker compose down -v --remove-orphans

# 컨테이너 실행
show_status "컨테이너를 시작합니다..."
docker compose up -d

# 컨테이너 상태 확인
check_container_health "healthcheck-db"
check_container_health "healthcheck-api"
check_container_health "healthcheck-client"
check_container_health "healthcheck-proxy"

# 데이터베이스 초기화 확인
check_database_init

# 최종 상태 출력
show_success "모든 서비스가 성공적으로 시작되었습니다!"
echo -e "${GREEN}📋 접속 정보:${NC}"
echo -e "- 웹 서비스: ${BLUE}http://localhost${NC}"
echo -e "- API 서비스: ${BLUE}http://localhost/api${NC}"
echo -e "- 헬스체크: ${BLUE}http://localhost/health${NC}"

# 유용한 명령어 안내
echo -e "\n${YELLOW}📝 유용한 명령어:${NC}"
echo -e "- 전체 로그 확인: ${BLUE}docker compose logs${NC}"
echo -e "- 특정 서비스 로그 확인: ${BLUE}docker compose logs [서비스명]${NC}"
echo -e "- 컨테이너 재시작: ${BLUE}docker compose restart${NC}"
echo -e "- 환경 종료: ${BLUE}docker compose down${NC}"
echo -e "- 데이터베이스 접속: ${BLUE}docker exec -it healthcheck-db psql -U postgres -d healthcheck${NC}"

# 개발 환경 설정 완료
show_success "개발 환경 설정이 완료되었습니다. 즐거운 개발 되세요! 🚀"