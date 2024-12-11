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

# 상태 표시 함수
show_status() {
    echo -e "${BLUE}📌 $1${NC}"
}

# 성공 메시지 함수
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 경고 메시지 함수
show_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Docker 실행 확인
if ! docker info > /dev/null 2>&1; then
    handle_error "Docker가 실행되고 있지 않습니다. Docker를 실행해주세요."
fi

# .env 파일 로드
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    handle_error ".env 파일이 없습니다."
fi

# Git이 설치되어 있는지 확인
if ! command -v git &> /dev/null; then
    handle_error "Git이 설치되어 있지 않습니다."
fi

# Git 저장소인지 확인
if [ ! -d .git ]; then
    handle_error "현재 디렉토리가 Git 저장소가 아닙니다."
fi

# 필수 환경 변수 확인 및 설정
GITHUB_ORGANIZATION="kdt-pwa-class-one-group"  # 고정된 organization 값

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${YELLOW}GitHub 사용자 이름을 입력하세요:${NC}"
    read GITHUB_USERNAME
    if [ -z "$GITHUB_USERNAME" ]; then
        handle_error "GitHub 사용자 이름은 필수입니다."
    fi
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}GitHub 토큰을 입력하세요:${NC}"
    read -s GITHUB_TOKEN  # -s 옵션으로 입력 값이 화면에 표시되지 않음
    echo  # 새 줄 추가
    if [ -z "$GITHUB_TOKEN" ]; then
        handle_error "GitHub 토큰은 필수입니다."
    fi
fi

# 환경 변수 설정
export DOCKER_REGISTRY="ghcr.io"
export DOCKER_NAMESPACE="$GITHUB_ORGANIZATION"
export IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short HEAD)}

show_status "빌드 설정:"
echo -e "- Organization: ${BLUE}$GITHUB_ORGANIZATION${NC}"
echo -e "- 레지스트리: ${BLUE}$DOCKER_REGISTRY${NC}"
echo -e "- 네임스페이스: ${BLUE}$DOCKER_NAMESPACE${NC}"
echo -e "- 태그: ${BLUE}$IMAGE_TAG${NC}"

# GitHub Container Registry 로그인
show_status "GitHub Container Registry 로그인 중..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || handle_error "GitHub 로그인 실패"

# 플랫폼 설정
PLATFORM=${DOCKER_DEFAULT_PLATFORM:-"linux/amd64"}
show_status "빌드 플랫폼: $PLATFORM"

# 멀티 플랫폼 빌더 설정
show_status "멀티 플랫폼 빌더 설정 중..."
docker buildx rm multiplatform-builder 2>/dev/null || true
docker buildx create --use --name multiplatform-builder || handle_error "빌더 생성 실패"
docker buildx inspect --bootstrap || handle_error "빌더 초기화 실패"

# 이미지 빌드 및 푸시
show_status "이미지 빌드 및 푸시 시작..."
docker buildx bake -f docker-compose.yml --push --set "*.platform=$PLATFORM" || handle_error "빌드 및 푸시 실패"

show_success "모든 이미지가 성공적으로 빌드되고 푸시되었습니다!"
echo -e "${GREEN}📋 빌드 정보:${NC}"
echo -e "- Organization: ${BLUE}$GITHUB_ORGANIZATION${NC}"
echo -e "- 태그: ${BLUE}$IMAGE_TAG${NC}"
echo -e "- 레지스트리: ${BLUE}$DOCKER_REGISTRY/$DOCKER_NAMESPACE${NC}"
echo -e "- 플랫폼: ${BLUE}$PLATFORM${NC}"

# 이미지 목록 출력
echo -e "\n${YELLOW}📦 푸시된 이미지:${NC}"
echo -e "- ${BLUE}$DOCKER_REGISTRY/$DOCKER_NAMESPACE/healthcheck-db:$IMAGE_TAG${NC}"
echo -e "- ${BLUE}$DOCKER_REGISTRY/$DOCKER_NAMESPACE/healthcheck-api:$IMAGE_TAG${NC}"
echo -e "- ${BLUE}$DOCKER_REGISTRY/$DOCKER_NAMESPACE/healthcheck-client:$IMAGE_TAG${NC}"
echo -e "- ${BLUE}$DOCKER_REGISTRY/$DOCKER_NAMESPACE/healthcheck-proxy:$IMAGE_TAG${NC}"

show_success "이미지 빌드 및 푸시가 완료되었습니다!"
echo -e "\n${YELLOW}📝 다음 단계:${NC}"
echo -e "1. GitHub Packages에서 이미지 확인: ${BLUE}https://github.com/orgs/$GITHUB_ORGANIZATION/packages${NC}"
echo -e "2. 이미지 접근 권한 설정 확인"
echo -e "3. README 업데이트 (필요한 경우)"
