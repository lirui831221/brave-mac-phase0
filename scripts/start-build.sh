#!/bin/bash
# Brave macOS Release 编译启动器（脱离 WorkBuddy 沙箱运行）
# 用法：bash /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/start-build.sh
# 之后可随时查看进度：tail -f /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/build.log

BRAVE_DIR=/Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/src/brave
export PATH=/Users/raypro/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:$PATH
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

cd "$BRAVE_DIR" || exit 1

# 清掉上次失败的 hardlink 残留（devtools override 目标）
find /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/src/third_party/devtools-frontend -name "*.patch.ts" -delete 2>/dev/null

echo "[$(date '+%H:%M:%S')] 编译启动，日志: /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/build.log"
node build/commands/scripts/build.ts Release > /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/build.log 2>&1
echo "[$(date '+%H:%M:%S')] 编译结束，退出码 $?"
