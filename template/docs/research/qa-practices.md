# 验收做法与依据

> 只看代码的验收常漏三类问题：①删到 0 条闪退（状态转换边界）②键盘上方候选条出现时日期选择器被挡（控件组合）③相机近距对焦（只能真机）。下面是苹果和 Anthropic 的官方做法，以及对应采用的做法。
> 标记：【官】= Apple / Anthropic 官方文档、WWDC、Xcode SDK 头文件；【三】= 第三方 / 行业做法。复查时点同原则（WWDC 后、iOS .1）。

## 一、苹果官方
- **自动无障碍审查【官】**：`XCUIApplication().performAccessibilityAudit(for:_:)`（iOS 17 起）。只查当前屏幕，每到一个状态调一次；有问题测试直接失败；第二个参数是过滤闭包，返回 true = 已知问题放过（写明原因）。查对比度、元素可发现、点按区（hitRegion）、描述、动态字体截断等
- **测试计划 Test Plans【官】**：一份计划多套配置（语言、地区、ASan / TSan / UBSan / Main Thread Checker）。sanitizer 在测试计划里设。xcodebuild：`-testPlan`、`-only-test-configuration`、`-test-iterations N`、`-run-tests-until-failure`
- **近两年新能力【官】**：Xcode 里录 UI 测试生成代码；`XCTHitchMetric` 测卡顿；Xcode 27 `XCUIDevice.voiceOverService`（UI 测试里开 VoiceOver、读朗读文字）。Swift Testing 管单元测试，UI 自动化留在 XCTest
- **真机崩溃和反馈【官】**：Xcode Organizer 的 Crashes / Feedback；App Store Connect API `betaFeedbackCrashSubmissions`、`betaFeedbackScreenshotSubmissions`
- **Xcode 官方 Claude 插件【官】**：工具（编译、跑测试、渲染预览、查文档、线上崩溃 / 性能）+ 苹果写的技能（SwiftUI、无障碍、xctrace、翻译）
- **规范【官】**：HIG Entering data（能从系统拿的别让人填；能选不让打字；给默认值）· Modality（模态短、不套娃、关了会丢数据才确认）· Virtual keyboards（键盘上方的自定义控件用键盘布局参考定位）· Accessibility（控件 44×44 pt）· App Review 2.1(a)（会崩的包直接拒）

## 二、Anthropic / Claude 官方
- Claude Code 最佳实践【官】：给 Claude 能自己跑的检查（测试、构建、对设计稿截图）；**要证据**（命令 + 输出 / 截图），不接受「全部通过」；用没见过代码的子 agent 独立复查
- 桌面版 iOS 模拟器工具【官】：装、启动、点、滑、截图；**不能控制真机**

## 三、行业做法【三】
- 随机乱点（Monkey）：XCUITest 里随机点 / 滑，固定随机种子复现
- 操作成本：KLM（按键 / 指向 / 思考相加）、NN/g interaction cost → 核心任务数「点按 + 打字 + 换屏 + 停顿」
- 状态矩阵：每类数据 0 / 1 / 多 / 满，双向转换（空 → 1 → 多 → 删到 1 → 0 → 再加）

## 四、采用的
| 做法 | 打哪类问题 | 谁做 |
|---|---|---|
| 试用员 agent（黑盒、点模拟器、数步数） | ①② + 操作成本 | `{app}-qa` |
| 验收按「第一性原则 → 美观 → 功能」、要证据、顺着改动找状态转换 | ① | `{app}-review` |
| 状态矩阵 UI 测试 + 控件组合断言（`isHittable` + 截图） | ①② | `{app}-product` 补测试 |
| 测试计划 `Audit.xctestplan`（每种语言 × ASan + 主线程检查）+ 每个状态 `performAccessibilityAudit` | 截断 / 点按区 / 对比度 / 崩溃 | 发版前 |
| 核心任务步数表 `docs/qa/task-steps.md` | 操作成本 | 试用员量、主会话填 |
| 每次 TestFlight 附真机清单 | ③ | 发版 skill |
| 不采用：每轮对话结束都强制跑整组 UI 测试 | — | 太慢；发版前由 skill 跑 |

## 来源
- https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app
- https://developer.apple.com/videos/play/wwdc2023/10035/
- https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early
- https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode
- https://developer.apple.com/documentation/appstoreconnectapi/beta-feedback-crash-submissions
- https://developer.apple.com/design/human-interface-guidelines/（entering-data · modality · virtual-keyboards · accessibility）
- https://developer.apple.com/app-store/review/guidelines/
- https://code.claude.com/docs/en/best-practices
- https://code.claude.com/docs/en/desktop-ios-simulator
- https://www.nngroup.com/articles/interaction-cost-definition/
- https://en.wikipedia.org/wiki/Keystroke-level_model
