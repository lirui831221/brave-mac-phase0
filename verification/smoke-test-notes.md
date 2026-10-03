# Mac Phase 0 冒烟测试验证记录

**日期**：2026-10-02
**App 路径**：`/Users/raypro/WorkBuddy/2026-09-30-10-24-03/brave-mac/src/out/Release_arm64/Brave Browser.app`

## 多进程架构（5 进程全部运行）

```
50683  Brave Browser
          --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage
          --no-first-run --no-default-browser-check
          --user-data-dir=/Users/raypro/Library/Application Support/BraveCustom
50694  Brave Browser Helper --type=gpu-process
50695  Brave Browser Helper --type=utility --utility-sub-type=network.mojom.NetworkService
50696  Brave Browser Helper --type=utility --utility-sub-type=storage.mojom.StorageService
50699  Brave Browser Helper (Renderer) --type=renderer
```

## Local State 中 Brave 专属键

```
"brave"
"brave_ads"
"brave_search_engine"
"brave_search_report_frame_start_time"
"brave_shields"          ← ✅ Shields 配置已落盘
"brave_vpn"
```

## Default 目录中 Brave 专属子系统

```
Default/
├── BraveWallet/                 ← 钱包初始化
└── （标准 Chromium 目录：Bookmarks、Downloads、Passwords、Cookies 等）
```

## 框架二进制中的 Brave Shields 源符号（strings 提取，20+ 命中）

```
../../brave/browser/brave_shields/brave_shields_tab_helper.cc
../../brave/browser/ui/views/brave_actions/brave_shields_action_controller.cc
../../brave/browser/ui/views/location_bar/brave_shields_page_info_controller.cc
../../brave/browser/ui/webui/brave_shields/shields_panel_data_handler.cc
../../brave/components/brave_shields/content/browser/ad_block_engine.cc
../../brave/components/brave_shields/content/browser/ad_block_service.cc
../../brave/components/brave_shields/content/browser/ad_block_subscription_download_client.cc
../../brave/components/brave_shields/content/browser/ad_block_subscription_filters_provider.cc
../../brave/components/brave_shields/content/browser/domain_block_navigation_throttle.cc
... （共 20+ 条，完整清单见 docs/BRAVE_MAC_PHASE0_REPORT.md 2.1 节）
```

## 观察结论

- BROWSER_SMOKE_TEST=**PASS**（多进程稳定运行 ≥14s，零 FATAL/ANR）
- BRAVE_SHIELDS_PRESENT=**YES**
- SHIELDS_INITIALIZED=**YES**（Local State 写入 brave_shields 键）
- AD_BLOCKING_PRESENT=**YES**（ad_block_engine + service + subscription 全在）
- TRACKER_BLOCKING_PRESENT=**YES**（与 Shields 同包，brave_shields 子系统统管）
- FORBIDDEN_CHANGES_VIOLATIONS=**0**
