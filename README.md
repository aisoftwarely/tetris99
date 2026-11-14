# 俄罗斯方块（单机版）

自己玩的 iPhone 俄罗斯方块，视觉和音效参考《Tetris 99》的风格，玩法是 **纯单机经典马拉松**：没有 CPU、没有攻击、不用联网，专注消行刷分。

- 标准 10×22 场地、7-bag 随机、SRS 旋转 + 踢墙、Hold、幽灵块、锁定延迟、T-Spin 判定
- 计分：消 1 / 2 / 3 / 4 行 = 100 / 300 / 500 / 800 × 等级；T-Spin 单 / 双 / 三 = 800 / 1200 / 1600 × 等级
- Combo、B2B（连续四行或 T-Spin）、Perfect Clear（全消）都有额外加分
- 每消 10 行升 1 级，下落速度逐级加快；最高分记录在本机
- 全部音效和背景音乐用 Web Audio 实时合成，不含任天堂的音频素材，无版权问题；静音开关打开时 iOS 版仍会出声（可在游戏内点 ♪ 关闭）
- iOS 切后台、来电或音频被打断后，会自动恢复音频会话和 AudioContext
- 触屏操作 + 键盘操作

## 为什么在云端编译

- iPhone 是 iOS 27，编译需要 Xcode 27；而 Xcode 27 只支持 Apple 芯片 Mac，并要求 macOS Tahoe 26.6+。
- 本地机器是 Intel 黑苹果（Sequoia 15.8），无法运行 Xcode 27，也无法给 iOS 27 设备安装。
- 所以：网页版游戏跑在 WKWebView 里，GitHub Actions 的 `xcode-27` 运行器输出未签名 IPA，再用 Sideloadly 用免费 Apple ID 签名安装。

## 本地试玩

```bash
python3 -m http.server 8899
```

浏览器打开 http://localhost:8899/web/index.html 。电脑上可以用方向键移动/软降，Z / X 旋转，空格瞬降，C 暂存，P 暂停。

## 构建

推送到 `main` 或手动触发 **Actions → Build IPA → Run workflow**。

成功后：

- Actions 里可下载 `Tetris99-ipa` 工件；
- Releases 里有一条 `build-N`，附件就是 `Tetris99.ipa`，可用命令直接下载：

```bash
curl -L -o Tetris99.ipa \
  https://github.com/aisoftwarely/tetris99/releases/download/build-<N>/Tetris99.ipa
```

## 安装（首次，需要一个免费 Apple ID）

1. 从 https://sideloadly.io 下载 macOS 版，拖进「应用程序」，右键 → 打开（绕过 Gatekeeper）。
2. 数据线连接 iPhone，手机上点「信任」。
3. 把 `Tetris99.ipa` 拖进 Sideloadly，输入 Apple ID 邮箱和密码，按提示输入双重认证验证码，点 **Start**。
4. 手机上：
   - 设置 → 通用 → VPN 与设备管理 → 信任对应的开发者证书；
   - 设置 → 隐私与安全性 → 开发者模式 → 打开，重启手机。
5. 打开「俄罗斯方块」。

## 自动续签（免费证书 7 天有效）

1. Finder 里选中 iPhone → 勾选「通过 Wi-Fi 同步」（只需在数据线连接时设置一次）。
2. Sideloadly 主窗口底部、**Start 按钮左边那个圆形箭头按钮**就是 AutoRefresh 开关，点成高亮；
   悬停提示应为 `AutoRefresh [enabled]: ... before 7 days will pass`。
3. 首次开启会询问 `Do you want to enable daemon auto-start?`，选 **Yes**。
   之后 `sideloadly-daemon` 常驻，并在 `~/Library/LaunchAgents/io.sideloadly.daemon.plist` 注册开机自启。
4. 之后只要 Mac 每周内醒着、和手机连过同一个 Wi-Fi，就会自动续签。
5. 万一过期：重新拖一次 IPA 安装即可，最高名次记录会保留在本机。

## 已知限制

- 免费 Apple ID 最多同时签 3 个 App，证书 7 天。你目前已有「再来一杯」和「睡个好觉」，加上这个正好 3 个；如果 Sideloadly 报数量超限，需要先删掉一个旧 App 再签。
- 游戏数据只存本机，不上传、不联网。
- 仅竖屏。

## 目录

```
web/index.html                    完整游戏（单文件，可直接浏览器打开）
Tetris99/App/Tetris99App.swift    WKWebView 原生壳、音频会话
Tetris99/Resources/index.html     构建时从 web/ 同步进去的游戏文件
Tetris99/Resources/Assets.xcassets 图标与启动背景色
project.yml                       XcodeGen 工程配置
tools/make_icon.swift             生成 1024 App 图标
tools/sync_web.sh                 同步 web/index.html 到 App 资源
.github/workflows/build-ipa.yml   云端构建
```
