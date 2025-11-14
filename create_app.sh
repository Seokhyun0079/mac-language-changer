#!/bin/bash

# .app 번들 생성 스크립트
set -e

APP_NAME="MacLanguageChager"
APP_IDENTIFIER="com.maclanguageschager.maclanguagechager"
APP_BUNDLE="${APP_NAME}.app"
APP_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${APP_DIR}/MacOS"
RESOURCES_DIR="${APP_DIR}/Resources"

echo "🚀 ${APP_NAME} 앱 번들 생성 중..."

# 1. 릴리즈 빌드
echo "📦 릴리즈 빌드 중..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ 빌드 실패!"
    exit 1
fi

# 2. 기존 앱 번들 제거
if [ -d "${APP_BUNDLE}" ]; then
    echo "🗑️  기존 앱 번들 제거 중..."
    rm -rf "${APP_BUNDLE}"
fi

# 3. 앱 번들 디렉토리 구조 생성
echo "📁 앱 번들 구조 생성 중..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 4. 실행 파일 복사
echo "📋 실행 파일 복사 중..."
EXECUTABLE_PATH=".build/release/MacLanguageChager"
if [ -f "${EXECUTABLE_PATH}" ]; then
    cp "${EXECUTABLE_PATH}" "${MACOS_DIR}/${APP_NAME}"
    chmod +x "${MACOS_DIR}/${APP_NAME}"
else
    echo "❌ 실행 파일을 찾을 수 없습니다: ${EXECUTABLE_PATH}"
    exit 1
fi

# 5. Info.plist 생성
echo "📄 Info.plist 생성 중..."
cat > "${APP_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>ko</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${APP_IDENTIFIER}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 6. PkgInfo 생성
echo "📦 PkgInfo 생성 중..."
echo "APPL????" > "${APP_DIR}/PkgInfo"

echo "✅ 앱 번들 생성 완료: ${APP_BUNDLE}"
echo ""
echo "앱을 실행하려면:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "앱을 Applications 폴더로 복사하려면:"
echo "  cp -r ${APP_BUNDLE} /Applications/"

