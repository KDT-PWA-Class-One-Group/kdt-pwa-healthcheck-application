#!/bin/bash

# 환경 변수 확인
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GITHUB_TOKEN 또는 GITHUB_USERNAME 환경 변수가 설정되지 않았습니다."
    exit 1
fi

# GitHub 패키지 레지스트리 로그인
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 변수 설정
ORG_NAME="kdt-pwa-class-one-group"
IMAGE_PREFIX="ghcr.io/${ORG_NAME}"
VERSION="latest"

# Client 이미지 빌드 및 푸시
echo "Building and pushing client image..."
docker build -t $IMAGE_PREFIX/healthcheck-client:$VERSION ./client
docker push $IMAGE_PREFIX/healthcheck-client:$VERSION

# API 이미지 빌드 및 푸시
echo "Building and pushing API image..."
docker build -t $IMAGE_PREFIX/healthcheck-api:$VERSION ./api
docker push $IMAGE_PREFIX/healthcheck-api:$VERSION

# DB 이미지 빌드 및 푸시
echo "Building and pushing DB image..."
docker build -t $IMAGE_PREFIX/healthcheck-db:$VERSION ./db
docker push $IMAGE_PREFIX/healthcheck-db:$VERSION

# Proxy 이미지 빌드 및 푸시
echo "Building and pushing proxy image..."
docker build -t $IMAGE_PREFIX/healthcheck-proxy:$VERSION ./proxy
docker push $IMAGE_PREFIX/healthcheck-proxy:$VERSION

echo "All images have been built and pushed successfully!" 