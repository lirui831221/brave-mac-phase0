# Brave macOS Phase 0 — 官方原版编译验证 + 本地可启动 App

**目标**：基于官方 brave-core v1.98.0 + Chromium eb81d1e9a7da（155.0.8059.16）**零源码修改**，在本机（Apple Silicon arm64）构建 Brave macOS Release，产出可运行的 `Brave Browser.app`，并产出完整验证报告。

**状态**：✅ **BUILD=PASS / SMOKE_TEST=PASS / FORBIDDEN_CHANGES_VIOLATIONS=0**

---

## 一键使用（已生成 .app）

如果你只想用现成的：

1. 从 [Release v0.1.0-mac-phase0](../../releases/tag/v0.1.0-mac-phase0) 下载 `Brave-Browser-1.98.0-mac-arm64-phase0.zip`（287 MiB，SHA-256 `d6d54588785219d9e7f81cf53cdfe20a2b4ab89346f106ca89d67b3997a865f6`）
2. 解压拖入 `/Applications`
3. **首次启动必须**用终端运行（本地 adhoc 签名无 Apple Team ID 沙盒授权，`open -a` 会 FATAL）：

```bash
"/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage \
  --no-first-run --no-default-browser-check \
  --user-data-dir="$HOME/Library/Application Support/BraveCustom" &
```

> 也可以双击 `Brave Browser (Launch).app` 启动器（AppleScript 打包，见 `scripts/launcher-creation.sh`）。

---

## 快速复现（从源码）

### 环境要求

- macOS Apple Silicon（arm64），≥200 GiB 空闲
- Xcode 27.0 + Metal Toolchain 27A266a（`xcodebuild -downloadComponent MetalToolchain`，838.9 MB 独立组件）
- 完整 Xcode + `sudo xcodebuild -license accept`
- depot_tools（需要升 gclient sync 后）
- Node 24.19.0（fallback runtime）+ 真实 pnpm 11.28.2（**不能用 corepack shim，brave-core 的 object-form devEngines 它拒绝**）
- Chromium seed 1.4 GiB + tailscale 或本机直通网络

### 构建（概要，详见 `docs/BRAVE_MAC_PHASE0_REPORT.md`）

```bash
# 从本仓库
cd /path/to/your/brave-mac
# 需已有的目录结构：
#   src/                      — Chromium 源码（37 GiB, gclient sync 产物）
#   src/brave                 — brave-core @ android-custom-browser (26101b8dd)
#   src/brave/.env            — 4 个 dummy service keys
#   start-build.sh            — 沙盒外启动器（关键，WorkBuddy 沙盒会拦 devtools/符号链接）

bash start-build.sh    # 在 Terminal 里跑，不要再从 WorkBuddy 里跑（会触发 CODEBUDDY_BROKER_DENY）

# 完成后：
# src/out/Release_arm64/Brave Browser.app
```

### 复现关键 gotcha

- **WorkBuddy 沙盒**：在沙盒内跑 build 会触发 broker deny（pnpm store 符号链接 + devtools 硬链接全拦）。构建必须在 Terminal 跑 `start-build.sh`
- **Xcode 27 Metal 拆分**：`xcodebuild -downloadComponent MetalToolchain` 必须，否则 ANGLE Metal 着色器编译失败（“cannot execute tool 'metal'”）
- **启动需 --no-sandbox**：本地 adhoc 签名无 Apple Team ID → macOS sandbox entitlement 缺失 → GPU 沙盒 FATAL。本地构建 Chromium/Brave 的通用现象，非代码缺陷
- **corepack shim 拒绝 brave-core**：必须用 `npm i -g pnpm@11.28.2` 真实安装，直接调用 `pnpm.cjs`

### 冒烟验证（5 进程全活）

```bash
# 用 launcher 启动后
pgrep -lf "Brave Browser"
# 应看到 5 进程：主/GPU/Network/Storage/Renderer
# Local State 应含 brave_shields / brave_ads / brave_vpn / brave_search_engine
ls "$HOME/Library/Application Support/BraveCustom/Default/BraveWallet"  # BraveWallet 目录应存在
```

---

## 仓库结构

```
brave-mac-phase0/
├── README.md                         ← 本文件
├── docs/
│   └── BRAVE_MAC_PHASE0_REPORT.md    ← 完整验证报告
├── scripts/
│   ├── start-build.sh                ← 沙盒外构建启动器
│   ├── brave-mac-env.sh              ← 环境变量配置
│   └── launcher-creation.sh          ← AppleScript 启动器生成
└── verification/
    └── smoke-test-notes.md           ← 进程列表、Local State keys 等验证细节
```

## 关键产物

| 项 | 值 |
|---|---|
| App 大小 | 595 MiB（.app），287 MiB（zip） |
| 主可执行 SHA-256 | `90850f129d4f515d64c0abeb8705d5b8d68b3568cfef26c368e31c730bc2753a` |
| 框架二进制 SHA-256 | `65ed2cb88b74097593fe6edd41bf98846f2eda6ff95ad9c1a046637e7149d18a` |
| Version/Bundle ID | 1.98.0 / `com.brave.Browser` |
| 内核 | Chromium 155.0.8059.16（与 Android Phase 0 完全同基准） |
| 构建耗时 | 3h30m39s / 60331 步 / 0 FAILED |
| Brave Shields 代码符号 | 20+ brave_shields 源文件命中（ad_block_engine、service、subscription、domain_block 全在） |

## 相关仓库

| 仓库 | 用途 |
|------|------|
| [brave-core (fork)](https://github.com/lirui831221/brave-core) | brave-core 源码 fork（`android-custom-browser` 分支） |
| [brave-android-phase0](https://github.com/lirui831221/brave-android-phase0) | Android Debug 版 Phase 0 + APK release v0.1.0-phase0 |
