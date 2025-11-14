#!/bin/bash

# Swift 코드 포맷팅 스크립트
set -e

echo "🔧 Swift 코드 포맷팅 중..."

# SwiftFormat 설치 확인
if ! command -v swiftformat &> /dev/null; then
    echo "⚠️  SwiftFormat이 설치되어 있지 않습니다."
    echo ""
    echo "설치 방법:"
    echo "  brew install swiftformat"
    echo ""
    echo "또는 Swift Package Manager로:"
    echo "  mint install nicklockwood/SwiftFormat"
    exit 1
fi

# SwiftFormat 실행
swiftformat --config .swiftformat Sources/

echo "✅ 포맷팅 완료!"

