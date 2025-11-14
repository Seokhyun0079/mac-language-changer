#!/bin/bash

# PKG 파일 생성 스크립트 (pkgbuild 사용)
set -e

APP_NAME="LanguageChanger"
APP_BUNDLE="${APP_NAME}.app"
PKG_NAME="${APP_NAME}.pkg"

echo "📦 PKG 파일 생성 중..."

# 1. 앱 번들 생성 (create_app.sh 실행)
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "앱 번들이 없습니다. 먼저 앱 번들을 생성합니다..."
    ./create_app.sh
fi

# 2. 컴포넌트 패키지 생성
COMPONENT_PKG="component.pkg"
echo "🔨 컴포넌트 패키지 생성 중..."

pkgbuild \
    --root . \
    --identifier "com.maclanguagechange.${APP_NAME}" \
    --version "1.0.0" \
    --install-location "/Applications" \
    --component "${APP_BUNDLE}" \
    "${COMPONENT_PKG}"

# 3. 배포 패키지 생성 (선택사항 - 제품 빌드용)
if command -v productbuild &> /dev/null; then
    echo "📦 배포 패키지 생성 중..."
    productbuild \
        --package "${COMPONENT_PKG}" \
        "${PKG_NAME}"
    
    rm -f "${COMPONENT_PKG}"
    echo "✅ PKG 파일 생성 완료: ${PKG_NAME}"
else
    echo "⚠️  productbuild를 찾을 수 없습니다. 컴포넌트 패키지만 생성했습니다: ${COMPONENT_PKG}"
fi

