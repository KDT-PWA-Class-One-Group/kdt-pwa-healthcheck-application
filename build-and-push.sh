#!/bin/bash

# 환경 변수 설정
export GITHUB_ORGANIZATION="your-org-name"  # GitHub 조직 이름으로 변경
export IMAGE_TAG=$(git rev-parse --short HEAD)  # Git commit hash를 태그로 사용
export DOCKER_DEFAULT_PLATFORM="linux/amd64,linux/arm64"  # 멀티 플랫폼 빌드

# GitHub Container Registry 로그인
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 멀티 플랫폼 빌더 설정
docker buildx create --use --name multiplatform-builder

# 이미지 빌드 및 푸시
docker-compose build --push
