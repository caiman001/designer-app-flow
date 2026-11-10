# {App名} · 设计到生产流程

> 目标：设计稿、规范、代码三者一一对应，以后改一处设计，知道要改哪几个文件，改完能验证。
> 相关：[PRD.md](PRD.md)（做什么）· [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md)（长什么样、怎么动）· [IOS-ARCHITECTURE.md](IOS-ARCHITECTURE.md)（怎么实现）

## 一、每样东西只有一个"正本"

| 内容 | 正本 | 代码里对应 |
|---|---|---|
| 产品规则 | `docs/PRD.md` + `docs/DECISIONS.md` | — |
| 视觉稿（每屏长什么样） | [Design 画布]({画布链接}) | `ios/{App名}/Features/<屏>/` |
| 令牌（颜色、字号、间距、圆角、动效曲线） | `docs/DESIGN-SYSTEM.md` 令牌 + 动效两节 | `ios/{App名}Kit/Sources/DesignSystem/Tokens.swift`、`Motion.swift`（**名字和文档一致**） |
| 组件 | `docs/DESIGN-SYSTEM.md` 组件表（带代码文件名） | `ios/{App名}Kit/Sources/DesignSystem/Components/`；页面只组合组件，不自己拼样式 |
| 业务规则 | `docs/IOS-ARCHITECTURE.md` | `ios/{App名}Kit/Sources/Core/`（纯 Swift，不依赖界面，有单元测试） |
| 数据模型 | `docs/IOS-ARCHITECTURE.md` | `ios/{App名}/Data/`（`Models.swift` + `Schema.swift`，版本化） |
| 商店素材（截图、预览视频、商店文字） | `docs/APPSTORE-LISTING.md` | `design/store/` |

规则写成**数据 + 规则**：会变的名单、对照表放数据文件（漏了补一行），规则写成纯函数加测试；别把具体例子写死在代码分支里。

## 二、代码分层（只能从上往下依赖）

```
App 屏幕（Features）   只拼组件、接数据，不写颜色 / 字号 / 动画参数
   ↓
组件（DesignSystem）   只用令牌；每个组件带 #Preview
   ↓
令牌（Tokens / Motion）
Core（规则）            纯函数，swift test 可跑
```

两条硬规矩：
1. **屏幕里不出现色值、字号、spring 参数**。要新样式先加令牌或组件，再在屏幕里用。改一次令牌，全 App 一起变。
2. **规则不写在界面里**。计算、推断、解析都在 Core 里，界面只显示结果。改规则只动一个文件，跑测试验证。

## 三、一次改动怎么走

| 改什么 | 步骤 |
|---|---|
| 一个颜色 / 字号 / 间距 | DESIGN-SYSTEM.md 令牌表 → `Tokens.swift` 同名常量 → 组件预览 → 模拟器截图对照画布 |
| 一个组件的样子 | 画布对应位置 → DESIGN-SYSTEM.md 组件表 → `Components/<组件>.swift` → 它的 #Preview |
| 一段动效 | DESIGN-SYSTEM.md 动效表 → `Motion.swift` → 模拟器录屏，慢放检查（见第五节） |
| 一屏的布局 | 画布 → `Features/<屏>/<屏>Screen.swift` → 截图对照 |
| 一条业务规则 | PRD / 架构文档 → Core → 先改测试再改实现，`swift test` 通过 |
| 数据模型加字段 | 先冻结现行 Schema 版本 → 新版本 + 迁移一段 + 迁移测试（老库夹具要过）→ 备份格式带上新字段（可空）|

改完都更新对应文档，保证文档、画布和代码对得上。

## 四、验证

| 层 | 怎么验 | 命令 |
|---|---|---|
| 规则 | 单元测试（Swift Testing） | `cd ios/{App名}Kit && swift test` |
| 组件 | 每个组件的 #Preview | Xcode 或 Xcode MCP 渲染预览 |
| 屏幕 | 模拟器截图（演示数据 + 启动参数直达某屏），和画布并排对照 | skill `{app}-verify-ios` |
| 交互 | UI 测试走一遍，测试里自带截图 | `xcodebuild test` |
| 动效 | 模拟器录屏逐帧 + 真机手感（触感只有真机有） | `xcrun simctl io <模拟器> recordVideo` |
| 整体 | 真机走一遍核心路径：{写下核心路径} | — |

## 五、动效：单独一个阶段

画布只能画静态，弹簧、惯性和触感只能在原生里调，所以动效**在原生工程里设计**：
1. 先写规格：DESIGN-SYSTEM.md 动效一节列出每个关键时刻，以及它用哪条曲线、多长、配什么触感
2. 曲线做成令牌：`Motion.swift` 只有几条弹簧 + 几个时长，全 App 只用这几条，节奏才统一
3. 逐个时刻实现，每个时刻录一段模拟器视频给用户看，0.25 倍速检查有没有跳帧、穿帮
4. 用户在真机上试手感，按反馈调参数，只改 `Motion.swift`

关键时刻（就是产品本身的那几个动作）排在骨架里和功能一起做，不留到最后。

## 六、里程碑与完成标准

| 阶段 | 内容 | 完成标准 | 状态 |
|---|---|---|---|
| **M0 环境** | 工程跑通 | 模拟器里能打开空壳 App | |
| **M1 骨架** | 令牌 + 组件 + 主要屏静态 + 数据模型 + 核心规则 | 截图和画布对得上；`swift test` 全过；核心路径能走通 | |
| **M1.5 动效** | 动效一节全部时刻 | 每个时刻有录屏；真机手感用户认可 | |
| M2… | {产品功能} | | |
| **M5 上架** | 开发者账号、签名、无障碍、TestFlight、商店素材、提审 | 过审 | |

## 七、分支与提交

- 原生代码都在 `ios/`，在 `{默认分支}` 上开发，推到私有仓库 `origin` 备份；网站文件用 `scripts/publish-site.sh` 单独同步到公开仓库 `site`，源码永远不进公开仓库
- 每完成一屏或一组组件就提交一次（先问用户），提交说明写清对应画布的哪一屏、哪一版

## 八、在自己的 iPhone 上体验

日常走 **TestFlight**（`/{app}-release` 上传后手机上装，一个 build 管 90 天）。
需要插线直接装调试版时：Xcode → Settings → Accounts 登录开发者 Apple ID，iPhone 连 Mac、「信任此电脑」、打开「开发者模式」；用 `xcodebuild -allowProvisioningUpdates` + `xcrun devicectl` 装。**别频繁在用户手机上启动 App**，看界面优先用模拟器或 Xcode MCP 渲染预览。

## 九、代理与苹果服务

本机开着代理时，苹果签名服务器和模拟器下载会拒代理出口 IP。处理办法见 [LESSONS.md](../LESSONS.md)「环境」；**只加直连，不关代理、不改别的设置**。
