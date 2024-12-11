#!/bin/bash

# 에러 처리 함수
handle_error() {
    echo "에러: $1"
    exit 1
}

# .env 파일 로드
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    handle_error ".env 파일이 없습니다."
fi

# 필수 환경 변수 확인
[ -z "$GITHUB_ORGANIZATION" ] && handle_error "GITHUB_ORGANIZATION이 설정되지 않았습니다."
[ -z "$GITHUB_TOKEN" ] && handle_error "GITHUB_TOKEN이 설정되지 않았습니다."
[ -z "$GITHUB_USERNAME" ] && handle_error "GITHUB_USERNAME이 설정되지 않았습니다."

# Git commit hash를 태그로 사용
export IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short HEAD)}
echo "빌드 태그: $IMAGE_TAG"

# GitHub Container Registry 로그인
echo "GitHub Container Registry 로그인 중..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || handle_error "GitHub 로그인 실패"

# 멀티 플랫폼 빌더 설정
echo "멀티 플랫폼 빌더 설정 중..."
docker buildx rm multiplatform-builder 2>/dev/null || true
docker buildx create --use --name multiplatform-builder || handle_error "빌더 생성 실패"
docker buildx inspect --bootstrap || handle_error "빌더 초기화 실패"

# 이미지 빌드 및 푸시
echo "이미지 빌드 및 푸시 시작..."
docker buildx bake -f docker-compose.yml --push || handle_error "빌드 및 푸시 실패"

echo "모든 이미지가 성공적으로 빌드되고 푸시되었습니다!"
echo "태그: $IMAGE_TAG"
echo "레지스트리: $DOCKER_REGISTRY/$GITHUB_ORGANIZATION"
