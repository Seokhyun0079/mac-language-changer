#!/bin/bash

# DMG 파일 생성 스크립트
set -e

APP_NAME="LanguageChanger"
APP_BUNDLE="${APP_NAME}.app"
DMG_NAME="${APP_NAME}"
VOLUME_NAME="${APP_NAME}"

echo "📦 DMG 파일 생성 중..."

# 1. 앱 번들 생성 (create_app.sh 실행)
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "앱 번들이 없습니다. 먼저 앱 번들을 생성합니다..."
    ./create_app.sh
fi

# 2. DMG 디렉토리 생성
DMG_DIR="dmg_temp"
if [ -d "${DMG_DIR}" ]; then
    rm -rf "${DMG_DIR}"
fi
mkdir -p "${DMG_DIR}"

# 3. 앱 복사
cp -r "${APP_BUNDLE}" "${DMG_DIR}/"

# 4. Applications 링크 생성
ln -s /Applications "${DMG_DIR}/Applications"

# 5. DMG 파일 생성
DMG_FILE="${DMG_NAME}.dmg"
if [ -f "${DMG_FILE}" ]; then
    rm -f "${DMG_FILE}"
fi

echo "💿 DMG 파일 생성 중..."
hdiutil create -volname "${VOLUME_NAME}" -srcfolder "${DMG_DIR}" -ov -format UDZO "${DMG_FILE}"

# 6. 임시 디렉토리 정리
rm -rf "${DMG_DIR}"

echo "✅ DMG 파일 생성 완료: ${DMG_FILE}"

