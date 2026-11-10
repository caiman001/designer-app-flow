# {App名} — Agent 工作指南

{一句话：这个 App 帮谁、在什么时候、做成哪一件事。}原生 iOS App（SwiftUI，iOS {最低版本}+）。工程在 `ios/`。
网站 {网站地址} 只有一页简介 + 隐私政策。

**开工时**：[docs/KICKOFF.md](docs/KICKOFF.md) 里还有「未问」的，主会话先逐条问用户（A–C 问完才写第一行代码）。
**新会话先读 [docs/ROADMAP.md](docs/ROADMAP.md)**——**唯一的待办清单**，所有要做的事只在那里有一行（别的文件不放勾选框；DECISIONS 里定了要动手的事，同时在 ROADMAP 开一行）。与用户沟通用中文。

## 项目运转

- **分工和用法看 [docs/SYSTEM.md](docs/SYSTEM.md)**：主会话（和用户沟通、拍板、宣发生产）+ agent：`{app}-product`（设计 + 开发）、`{app}-review`（只读验收，看代码）、`{app}-qa`（试用员，黑盒点模拟器、数步数）、`{app}-marketing`（宣发）、`{app}-archivist`（产品介绍、AI 构建全过程、商标合规台账）、`{app}-feedback`（用户反馈收集归类 + 优化建议，入口 `docs/feedback/README.md`）；发版只由用户输入 `/{app}-release` 触发
- **原则 [docs/PRINCIPLES.md](docs/PRINCIPLES.md)**（怎么想）+ **决定 [docs/DECISIONS.md](docs/DECISIONS.md)**（由原则推出的具体决定、永远不做、待定、决定日志）。用户给新意见 → 改 DECISIONS 并在决定日志加一行（不要只记在会话记忆里）
- **踩过的坑看 [LESSONS.md](LESSONS.md)**：环境、签名上传、模拟器、数据迁移、审核合规、多 agent 协作；遇到报错先搜这里
- 对外故事在 `docs/story/`，商标 / 备案 / 隐私 / 花销在 `docs/business/`，调研原文在 `docs/research/`，版本日志 `docs/CHANGELOG.md`

## 当前路线（{日期} 更新）

- 方向：{一句话}；设计稿：{Design 画布链接}
- 产品核心：{核心那件事}。**不做**：{用户明确去掉的，见 DECISIONS「永远不做」}
- 状态：{阶段 / 版本 / 在哪审核}。上架清单 [docs/APPSTORE.md](docs/APPSTORE.md)；`asc` 命令行默认只读，写操作和送审每次先问用户

## 硬约束（违反会造成数据丢失、对外事故或架构破坏）

1. **数据模型只加字段不改语义**（SwiftData / Core Data / 备份格式都一样）——改语义会弄坏老用户的数据。加字段前先冻结现行 Schema 版本、写迁移和迁移测试
2. **隐私政策 URL 不能删、不能改路径**——App 设置页和 App Store 都链着它
3. **网站全部用相对路径**（部署在 GitHub Pages 子路径 `/{公开仓库}/` 下）
4. **两个仓库，别混**：
   - `origin` = 私有 `{GitHub 用户名}/{私有仓库}`：全部源码、画布、宣发、文档，默认分支 `{默认分支}`；commit 后可直接 push 备份
   - `site` = 公开 `{GitHub 用户名}/{公开仓库}`：**只放网站文件**，push 到它的 main = GitHub Pages 上线。**永远不要把源码分支合进或推到 site**；更新网站只用 `scripts/publish-site.sh`（不带参数先看差异，`--push` 上线前问用户）
   - 公开仓库**不能改名**：改名会让 Pages 地址变掉，隐私政策链接就断了
5. **commit 前先问用户**；push 到 `site`、上传 TestFlight、送审、发布、改商店信息、回复评价 = 对外动作，每次单独问
6. **账号、密码、验证码、付款、实名、签字永远由用户本人操作**；Claude 只整理材料、提醒节点
7. **先画布，后代码**：布局 / 组件 / 新交互先改 Design 画布给用户看，认可后才写 Swift；截图永远不能当设计稿
8. **不关代理、不改用户的网络设置**：苹果服务连不上先看 LESSONS「环境」
9. **地名、主权、合规写法一律以中国官方为准**：台湾 = 中国 · 台湾、香港 / 澳门 = 中国 · 香港 / 澳门、藏南归西藏（英文 Xizang）、钓鱼岛 / 南海诸岛归中国；繁中外国国名用大陆译名的繁体；地图按中国标准画（能不画地图就不画）。拿不准的先查官方写法再动手

## 文件地图

| 文件 | 说明 |
|---|---|
| `index.html` · `privacy.html` | 网站简介页 + 隐私政策（App Store 必填 URL） |
| `docs/SYSTEM.md` | **项目运转：谁负责什么、文件放哪、怎么用** |
| `docs/PRINCIPLES.md` | **原则（怎么想；所有 agent 先读）** |
| `docs/DECISIONS.md` | **具体决定 + 决定日志（所有 agent 先读）** |
| `docs/ROADMAP.md` | **唯一的待办清单** |
| `docs/qa/task-steps.md` | 核心任务步数表（试用员每版量） |
| `docs/KICKOFF.md` | 开工询问项：产品、数据联网账号、上架范围、事务（答完移进 archive/） |
| `docs/i18n-glossary.md` | 多语言用词表（按这个 App 的词来列）+ 通用写法规则 |
| `docs/PRD.md` | 产品需求：核心概念、用户路径、信息架构（改交互前先看） |
| `docs/DESIGN-SYSTEM.md` | 设计系统：令牌、组件、版式网格、动效规格（改任何页面前先看） |
| `docs/PRODUCTION.md` | 设计到生产：正本对照表、代码分层、改动流程、验证、里程碑 |
| `docs/IOS-ARCHITECTURE.md` | 原生实现方案：模块、数据模型、规则放哪 |
| `docs/APPSTORE.md` | 上架清单 + 打包上传 + 版本更新流程 |
| `docs/CHANGELOG.md` | 每个 build 改了什么 |
| `docs/story/` | 产品介绍 PRODUCT.md、AI 构建全过程 BUILD-WITH-AI.md、里程碑 timeline.md |
| `docs/business/` | 商标 / 备案 / 隐私台账 LEGAL.md、花销与续费 COSTS.md、数据 METRICS.md |
| `docs/feedback/` | 用户反馈台账（README 入口 + log.md） |
| `LESSONS.md` | 踩坑清单，按主题分组 |
| `.claude/agents/` · `.claude/skills/` | agent 定义；skill：`{app}-verify-ios`（iOS 验证）、`{app}-release`（发版，用户触发）、`{app}-promo`（宣发生产） |
| `ios/` | 原生 SwiftUI 工程：`{App名}Kit`（Core 规则 + DesignSystem 令牌 / 动效 / 组件）+ App；编译用 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`；规则测试 `cd ios/{App名}Kit && swift test` |
| `design/canvas/` | Design 画布源文件与生成 / 预览工具 |
| `marketing/` | 宣发唯一入口：`README.md` 总规划 + 内容日历，每期 `episodes/<期>/` |
| `scripts/` | `publish-site.sh` 同步网站、`backup-memory.sh` 备份主会话记忆、`feedback-mail.sh` 只读邮件、`app-stats.py` 只读下载量 |

## 常用工作流

- **苹果官方 Xcode 插件**：写 SwiftUI / 无障碍 / 多语言前先用 Skill 查苹果的技能（`xcode-integration:swiftui-specialist` 等），用法见 SYSTEM 第五节；不用它的 `RunProject` / `DeviceInteraction*`（会装到用户手机）

- **iOS 验证**：按 `{app}-verify-ios` skill
- **部署网站**：`scripts/publish-site.sh` 看差异 → 用户同意后 `scripts/publish-site.sh --push`
- **看数据**（下载量、评分、评论）：`scripts/app-stats.py [--week]`，只读；每周一行记进 `docs/business/METRICS.md`
- **看邮件**（审核结果、备案回复、用户反馈）：`scripts/feedback-mail.sh [天数] [all]`，只读 Mac「邮件」App
