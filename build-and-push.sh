#!/bin/bash

# 환경 변수 확인
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GITHUB_TOKEN 또는 GITHUB_USERNAME 환경 변수가 설정되지 않았습니다."
    exit 1
fi

# GitHub 패키지 레지스트리 로그인
docker login ghcr.io -u $GITHUB_USERNAME -p $GITHUB_TOKEN

# 변수 설정
IMAGE_PREFIX="ghcr.io/$GITHUB_USERNAME"
VERSION="latest"

# Client 이미지 빌드 및 푸시
docker build -t $IMAGE_PREFIX/healthcheck-client:$VERSION ./client
docker push $IMAGE_PREFIX/healthcheck-client:$VERSION

# API 이미지 빌드 및 푸시
docker build -t $IMAGE_PREFIX/healthcheck-api:$VERSION ./api
docker push $IMAGE_PREFIX/healthcheck-api:$VERSION

# DB 이미지 빌드 및 푸시
docker build -t $IMAGE_PREFIX/healthcheck-db:$VERSION ./db
docker push $IMAGE_PREFIX/healthcheck-db:$VERSION

# Proxy 이미지 빌드 및 푸시
docker build -t $IMAGE_PREFIX/healthcheck-proxy:$VERSION ./proxy
docker push $IMAGE_PREFIX/healthcheck-proxy:$VERSION 