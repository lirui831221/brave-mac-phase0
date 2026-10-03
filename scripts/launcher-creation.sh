#!/bin/bash
# 生成 AppleScript 启动器 .app：双击即可用 --no-sandbox 正确参数启动 Brave
# 用法：在 Terminal 运行本脚本
set -e

BRAVE_APP="/Applications/Brave Browser.app"
LAUNCHER_APP="/Applications/Brave Browser (Launch).app"
USER_DIR="$HOME/Library/Application Support/BraveCustom"

mkdir -p /tmp/brave-launcher-build

cat > /tmp/brave-launcher-build/launch.scpt << EOF
do shell script "\"$BRAVE_APP/Contents/MacOS/Brave Browser\" --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage --no-first-run --no-default-browser-check --user-data-dir=\"$USER_DIR\" > /dev/null 2>&1 &"
EOF

osacompile -o "$LAUNCHER_APP" /tmp/brave-launcher-build/launch.scpt

# 复制真实 Brave 图标（applet.icns 是 AppleScript 启动器的图标字段）
cp "$BRAVE_APP/Contents/Resources/app.icns" "$LAUNCHER_APP/Contents/Resources/applet.icns"

# 补充 plist 字段（osacompile 默认缺这些）
/usr/libexec/PlistBuddy -c "Set :CFBundleName \"Brave Browser\"" "$LAUNCHER_APP/Contents/Info.plist" || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.brave.browser.custom.launcher" "$LAUNCHER_APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.98.0" "$LAUNCHER_APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 198" "$LAUNCHER_APP/Contents/Info.plist" 2>/dev/null || true

# adhoc 重签名
codesign --force --deep --sign - "$LAUNCHER_APP"

echo "✅ 启动器已生成：$LAUNCHER_APP"
echo "✅ 可直接双击或拖入 Launchpad 使用"
