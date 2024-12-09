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

# Docker Buildx 설정
docker buildx create --use
docker buildx inspect --bootstrap

# Client 이미지 빌드 및 푸시
echo "Building and pushing client image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_PREFIX/healthcheck-client:$VERSION \
  --push \
  ./client

# API 이미지 빌드 및 푸시
echo "Building and pushing API image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_PREFIX/healthcheck-api:$VERSION \
  --push \
  ./api

# DB 이미지 빌드 및 푸시
echo "Building and pushing DB image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_PREFIX/healthcheck-db:$VERSION \
  --push \
  ./db

# Proxy 이미지 빌드 및 푸시
echo "Building and pushing proxy image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_PREFIX/healthcheck-proxy:$VERSION \
  --push \
  ./proxy

# Monitor 이미지 빌드 및 푸시
echo "Building and pushing monitor image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_PREFIX/healthcheck-monitor:$VERSION \
  --push \
  ./monitor

echo "모든 이미지가 성공적으로 빌드되고 푸시되었습니다!"
