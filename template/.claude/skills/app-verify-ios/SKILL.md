---
name: {app}-verify-ios
description: 验证 {App名} 原生 iOS 改动（ios/ 下的 SwiftUI）。改完 Swift 代码、交给验收前、发版前使用：跑规则测试、模拟器 Release 构建、用演示数据截核心路径的图、对照画布和原则自查。
---

# {App名} iOS 验证

改动越小，走的步骤越少；但**发版前全部走一遍**。动了转场 / 面板 / 动效时，第 5 节「慢动作 + 逐帧」必跑。截图永远只用来核对，不能当设计稿。坑见 `LESSONS.md`「测试与模拟器」。

## 1. 规则测试（必跑）
```
cd ios/{App名}Kit && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
记下通过 / 失败数。失败就停，先报告。

## 2. 构建（模拟器 Release）
```
cd ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project {App名}.xcodeproj -scheme {App名} \
  -configuration Release -destination 'platform=iOS Simulator,id=<模拟器 UDID>' -derivedDataPath <scratchpad>/dd build
```
- 模拟器：主力 {机型}（{UDID}，{pt 尺寸}）；抽查大屏 {机型} 和小屏 {机型}。**自己建的专用机**（`xcrun simctl create`），别用别的会话正在用的；用完 `simctl delete`
- **不要在用户的真机上 launch**（只有用户要求才 `devicectl install`）
- 查「零警告」用全新 derivedData（增量构建 0 个编译不算数）
- 签名、网络（苹果服务）出错先看 LESSONS「环境」；不许关代理

## 2b. 测试计划 + 无障碍审查（发版前必跑；有 `ios/Audit.xctestplan` 之后）
```
cd ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project {App名}.xcodeproj -scheme {App名} \
  -testPlan Audit -destination 'platform=iOS Simulator,id=<模拟器>' -derivedDataPath <scratchpad>/audit \
  -resultBundlePath <scratchpad>/audit-<日期时间>.xcresult -collect-test-diagnostics on-failure
```
- 测试计划每种界面语言一套配置，开 Address Sanitizer + Main Thread Checker；状态矩阵、控件组合、`performAccessibilityAudit` 都在里面。scheme 用了测试计划后 Testables 不再生效，要配一个默认计划
- 新加 / 改过的 UI 测试单独 `-only-testing:<类/方法> -run-tests-until-failure`（太久就 `-test-iterations 10`）
- 结果包名带日期时间（同名已存在会直接 EXIT 64）；看附件 `xcrun xcresulttool export attachments --path x.xcresult --output-path <目录>`
- 每步卡 60 秒「App animations complete notification not received」：见 LESSONS「测试与模拟器」
- 整组 UI 测试很慢（几十分钟）：放后台跑，输出写文件

## 2c. 试用员（黑盒，发版前必跑）
派 agent `{app}-qa`：不给 diff，只说这版大概改了哪块；它在模拟器上像用户一样走核心任务 + 状态矩阵 + 控件组合，数步数。和 `{app}-review` 的结论一起看，两个都过才算验收通过。

## 3. 演示数据截图（核心路径）
状态栏统一 9:41、满电不充电：
```
xcrun simctl status_bar <id> override --time 9:41 --batteryState charged --batteryLevel 100
```
启动参数（在 `ios/{App名}/App/` 里定义，约定见 IOS-ARCHITECTURE 第五节）：
- `-resetDemo -demo`：示例数据（虚构品牌）
- `-snapshot <屏>`：直接进到对应页
- `-empty`：首次打开
- 切语言：`-AppleLanguages "(en)"`

截图：`xcrun simctl io <id> screenshot <路径>`，存 scratchpad，不进仓库。
核心路径至少：{第一次打开 → 核心那件事 → 结果 → 次要页面}。
交互后的画面：UI 测试里 `XCUIScreen.main.screenshot()` 写到 `TEST_RUNNER_<APP>_SHOTS` 指定的 Mac 路径。

## 4. 对照自查
- 和画布对应画板并排看：布局、间距、字号、颜色
- 对照 `docs/PRINCIPLES.md` + `docs/DECISIONS.md`：「永远不做」有没有出现
- 无障碍：
  - 动态字体：`xcrun simctl ui <id> content_size accessibility-extra-extra-extra-large`（看完改回 `large`）；同一屏不同字号逐像素比，查封顶、撑宽、截字
  - 粗体 / 增强对比度 / 减弱动态：`xcrun simctl spawn <id> defaults write com.apple.Accessibility EnhancedTextLegibilityEnabled|DarkenSystemColors|ReduceMotionEnabled -bool true`，重启 App 生效，用完关掉
  - VoiceOver 标签：读 UI 测试的 `debugDescription` 或代码
- 权限：只在用到时请求

## 5. 转场 / 动效：慢动作 + 逐帧（改了动效、面板、sheet、转场时必跑；验收必跑）
模拟器 60fps 下「先出来再变高度」这类二段动作看不出，真机很明显。每个改到的打开 / 关闭都要：
1. **录屏 + 逐帧**：`xcrun simctl io <id> recordVideo --codec h264 <路径>` 边录边用 UI 测试点；`ffmpeg -fps_mode passthrough` 抽全部帧（别用 fps=60 重采样，会丢只闪一帧的画面），逐帧量面板顶边：**一路单调到位，不许停在一个高度后再变到另一个高度**（系统弹簧几 pt 的回落可以）
2. **慢动作**：命令行没有慢动画开关，把录屏放慢 4 倍看：`ffmpeg -i in.mp4 -vf "setpts=4*PTS" -an slow.mp4`
3. **组合**：语言 × 字号 large / xxLarge × 数据多 / 少
4. **卡顿**：Instruments「Animation Hitches」只能真机录（用户同意后）；没录就写进「需要真机测」
5. 报告里放修前 / 修后逐帧对比图；触感只有真机能试，写进「需要真机试」

## 6. 真机清单（每次传 TestFlight 都给用户）
模拟器测不到的写成一张短清单：这一版改了什么 → 真机上点哪几处、看什么（相机对焦、触感、真机性能 / 发热、权限弹窗、通知）。写进 CHANGELOG 那一节的「真机要试」和 ROADMAP「真机要看」。真机闪退：用户同意后读 TestFlight 崩溃反馈（`asc` 只读，或 Xcode Organizer / Xcode 插件 `GetTopCrashIssues`）。

## 汇报格式
- 结论：通过 / 有问题
- 跑了什么（命令 + 结果数字）
- 问题：严重 / 一般 / 建议，带 `文件:行号`
- 没查的、需要真机或用户看的
