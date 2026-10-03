#!/bin/bash
# Brave macOS 构建环境
# 用法：source /Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/brave-mac-env.sh

export NODE24=/Users/raypro/.cache/codex-runtimes/codex-primary-runtime/dependencies/node
export PATH="$NODE24/bin:$PATH"
export REAL_PNPM="$NODE24/lib/node_modules/pnpm/bin/pnpm.cjs"
export PNPM_STORE=/Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/.pnpm-store
export BRAVE_MAC_DIR=/Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac

# pnpm 别名（真 pnpm，绕过 corepack shim 对 devEngines 对象格式的不兼容）
pnpm() { "$REAL_PNPM" --store-dir "$PNPM_STORE" "$@"; }
