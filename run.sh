#!/bin/bash

# 에러 처리 함수
handle_error() {
    echo "에러: $1"
    exit 1
}

# OS 확인
case "$(uname -s)" in
    Linux*)
        if grep -q Microsoft /proc/version; then
            echo "WSL 환경이 감지되었습니다."
        fi
        ;;
    Darwin*)
        echo "macOS 환경이 감지되었습니다."
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

# 필요한 디렉토리 생성
directories=(
    "./db/logs"
    "./api/logs"
    "./client/logs"
    "./proxy/logs"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "디렉토리 생성: $dir"
        mkdir -p "$dir" || handle_error "$dir 디렉토리 생성 실패"
    fi
done

# 환경 변수 파일 확인
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo ".env 파일이 없습니다. .env.example을 복사하여 생성합니다."
        cp .env.example .env || handle_error ".env 파일 생성 실패"
        echo "주의: .env 파일의 설정값을 적절히 수정해주세요."
    else
        handle_error ".env.example 파일이 없습니다."
    fi
fi

# GitHub Container Registry 로그인 확인
if ! docker info | grep -q "ghcr.io"; then
    echo "GitHub Container Registry 로그인이 필요합니다."
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "GitHub 토큰을 입력하세요:"
        read -s GITHUB_TOKEN
    fi
    if [ -z "$GITHUB_USERNAME" ]; then
        echo "GitHub 사용자명을 입력하세요:"
        read GITHUB_USERNAME
    fi
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || handle_error "GitHub 로그인 실패"
fi

# 시스템 아키텍처 확인 및 환경 변수 설정
export DOCKER_DEFAULT_PLATFORM="linux/$(uname -m)"
echo "시스템 아키텍처: $DOCKER_DEFAULT_PLATFORM"

# 컨테이너 실행
echo "컨테이너를 시작합니다..."
docker-compose pull || handle_error "이미지 다운로드 실패"
docker-compose up -d || handle_error "컨테이너 시작 실패"

echo "애플리케이션이 시작되었습니다."
echo "접속 주소: http://localhost:${PROXY_PORT:-80}"
echo "로그 확인: docker-compose logs -f" 