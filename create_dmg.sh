#!/bin/bash

# DMG 파일 생성 스크립트 (일반적인 DMG 설치 경험 제공)
set -e

APP_NAME="MacLanguageChager"
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

# 5. 임시 읽기-쓰기 DMG 생성 (레이아웃 설정을 위해)
DMG_FILE="${DMG_NAME}.dmg"
if [ -f "${DMG_FILE}" ]; then
    rm -f "${DMG_FILE}"
fi

TEMP_DMG="temp_${DMG_FILE}"
if [ -f "${TEMP_DMG}" ]; then
    rm -f "${TEMP_DMG}"
fi

echo "💿 DMG 파일 생성 중..."
hdiutil create -volname "${VOLUME_NAME}" -srcfolder "${DMG_DIR}" -ov -fs HFS+ -format UDRW "${TEMP_DMG}"

# 6. DMG 마운트
echo "💿 DMG 마운트 중..."
hdiutil attach -readwrite -noverify -noautoopen "${TEMP_DMG}" > /dev/null 2>&1

MOUNT_PATH="/Volumes/${VOLUME_NAME}"
if [ ! -d "${MOUNT_PATH}" ]; then
    echo "❌ 마운트 실패! 볼륨을 찾을 수 없습니다."
    exit 1
fi

echo "💿 DMG 마운트됨: ${MOUNT_PATH}"

# 잠시 대기 (마운트 완료 대기)
sleep 3

# 7. Finder 창 레이아웃 설정 (AppleScript 사용)
echo "🎨 Finder 창 레이아웃 설정 중..."
osascript <<EOF
tell application "Finder"
    try
        set diskPath to POSIX file "${MOUNT_PATH}" as alias
        open diskPath
        set targetWindow to container window of diskPath
        set current view of targetWindow to icon view
        set toolbar visible of targetWindow to false
        set statusbar visible of targetWindow to false
        set bounds of targetWindow to {400, 100, 920, 420}
        set opts to icon view options of targetWindow
        set icon size of opts to 72
        set arrangement of opts to not arranged
        
        try
            set position of item "${APP_BUNDLE}" of targetWindow to {160, 205}
        end try
        
        try
            set position of item "Applications" of targetWindow to {360, 205}
        end try
        
        update targetWindow without registering applications
        delay 2
        close targetWindow
    on error errMsg
        display notification "레이아웃 설정 실패: " & errMsg
    end try
end tell
EOF

# 8. DMG 언마운트
echo "💿 DMG 언마운트 중..."
hdiutil detach "${MOUNT_PATH}" -quiet

# 9. 읽기 전용 압축 DMG로 변환
echo "💿 읽기 전용 DMG로 변환 중..."
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_FILE}"

# 10. 임시 파일 정리
rm -f "${TEMP_DMG}"
rm -rf "${DMG_DIR}"

echo "✅ DMG 파일 생성 완료: ${DMG_FILE}"
echo ""
echo "💡 DMG를 열면 Finder 창이 자동으로 열리고, 앱을 Applications 폴더로 드래그하여 설치할 수 있습니다."

