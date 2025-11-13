#!/bin/bash

# 빌드 스크립트
echo "Mac 언어 전환 앱 빌드 중..."

# Swift 패키지 빌드
swift build -c release

if [ $? -eq 0 ]; then
    echo "빌드 성공!"
    echo ""
    echo "실행하려면 다음 명령어를 사용하세요:"
    echo "swift run -c release"
else
    echo "빌드 실패!"
    exit 1
fi

