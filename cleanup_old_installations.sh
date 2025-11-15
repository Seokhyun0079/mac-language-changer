#!/bin/bash

# 이전 설치 파일 정리 스크립트
echo "🧹 이전 설치 파일 정리 중..."

# 1. LaunchAgent 정리
echo ""
echo "📋 LaunchAgents 파일 확인:"
ls -la ~/Library/LaunchAgents/ | grep -i "language\|mac-language" || echo "  (없음)"

# 이전 LaunchAgent 파일 삭제
OLD_LAUNCH_AGENTS=(
    "~/Library/LaunchAgents/com.maclanguagechange.languagechanger.plist"
    "~/Library/LaunchAgents/com.maclanguageschager.app.plist"
)

for agent in "${OLD_LAUNCH_AGENTS[@]}"; do
    expanded_path="${agent/#\~/$HOME}"
    if [ -f "$expanded_path" ]; then
        label=$(basename "$expanded_path" .plist)ㅠ
        echo ""
        echo "🛑 LaunchAgent 언로드 중: $label"
        launchctl unload "$expanded_path" 2>/dev/null || echo "  (이미 언로드됨 또는 오류)"
        
        echo "🗑️  LaunchAgent 파일 삭제 중: $expanded_path"
        rm -f "$expanded_path"
        echo "  ✅ 삭제 완료"
    fi
done

# 2. Preferences 파일 정리 (선택사항)
echo ""
echo "📋 Preferences 파일 확인:"
if [ -f ~/Library/Preferences/mac-language-change.plist ]; then
    echo "  이전 설정 파일 발견: mac-language-change.plist"
    read -p "  삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f ~/Library/Preferences/mac-language-change.plist
        echo "  ✅ 삭제 완료"
    fi
fi

# 3. Applications 폴더 확인
echo ""
echo "📋 Applications 폴더 확인:"
if [ -d /Applications/mac-language-change.app ] || [ -d /Applications/MacLanguageChager.app ]; then
    echo "  발견된 앱:"
    [ -d /Applications/mac-language-change.app ] && echo "    - mac-language-change.app"
    [ -d /Applications/MacLanguageChager.app ] && echo "    - MacLanguageChager.app"
    read -p "  삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        [ -d /Applications/mac-language-change.app ] && sudo rm -rf /Applications/mac-language-change.app && echo "  ✅ mac-language-change.app 삭제 완료"
        [ -d /Applications/MacLanguageChager.app ] && sudo rm -rf /Applications/MacLanguageChager.app && echo "  ✅ MacLanguageChager.app 삭제 완료"
    fi
else
    echo "  (Applications 폴더에 관련 앱 없음)"
fi

# 4. LaunchAgent 목록 다시 확인
echo ""
echo "📋 정리 후 LaunchAgents 상태:"
ls -la ~/Library/LaunchAgents/ | grep -i "language\|mac-language" || echo "  ✅ 관련 LaunchAgent 파일 없음"

echo ""
echo "✅ 정리 완료!"
echo ""
echo "💡 시스템 설정의 'Background Activity'에서 항목이 사라지지 않으면:"
echo "   1. 시스템 설정을 완전히 종료했다가 다시 열어보세요"
echo "   2. 또는 맥을 재시작해보세요"

