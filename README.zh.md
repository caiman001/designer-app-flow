# designer-app-flow · 设计师的 App 流程

[English](README.md)

一个设计师（不写 Swift）用 Claude Code 把原生 iOS App [**BeanDance**](https://apps.apple.com/app/id6822132582) 从零做到上架 App Store（含中国区）时跑出来的整套流程，去掉了那个 App 的设计风格、品牌和产品规则，只留能复用的：
- **分工**：主会话（和你沟通、你拍板）+ 6 个项目 agent（产品设计开发 / 看代码的验收 / 黑盒试用员 / 宣发 / 档案 / 反馈）+ 只有你能触发的发版命令
- **文档体系**：原则 → 决定（永远不做 · 待定 · 决定日志）→ 唯一的待办清单；开工询问项、正本对照、上架清单、国区备案、台账
- **验收**：先第一性原则、再美观、再功能；核心任务数步数；状态矩阵、控件组合、无障碍审查；每次 TestFlight 附真机清单
- **踩过的坑**：`LESSONS.md` 一百多条，按环境 / 签名上传 / 模拟器与测试 / SwiftUI 与键盘 / 数据迁移 / 审核合规（含国区 ICP）/ 画布 / 多 agent / 和用户协作分组，每条一句现象 + 一句做法
- 配合苹果官方 Xcode 插件用（agent 写 SwiftUI、查无障碍时先查苹果的技能）

> 文档是中文写的。需要 macOS + Xcode + Claude Code（推荐桌面版，试用员要用它的 iOS 模拟器工具）。

## 一、装

**作为插件装（推荐）**：在 Claude Code 里

```
/plugin marketplace add caiman001/designer-app-flow
```

```
/plugin install designer-app-flow@designer-app-flow
```

然后在一个**空的新文件夹**里打开 Claude Code，输入：

```
/designer-app-flow:new "App 显示名" 英文小写短名
```

它会把 `template/` 铺进当前文件夹、换好名字、检查环境，再告诉你下一步。

**不用插件**：

```bash
git clone https://github.com/caiman001/designer-app-flow.git
```

```bash
rsync -a ./designer-app-flow/template/ ~/<新项目>/ && cd ~/<新项目> && git init && sh scripts/init-starter.sh "App 显示名" 英文小写短名
```

推荐同时装苹果官方 Xcode 插件：`/plugin install xcode@claude-plugins-official`。

## 二、替换占位

`init-starter.sh`（插件会帮你跑）把全部文件里的 `{App名}` `{app}` `{开工日期}` 换掉；agent / skill 改名成 `<短名>-product`、`/<短名>-release` 这样；最后列出还要手填的占位。剩下的占位不急，**到哪一步填哪一个**：

| 占位 | 什么时候填 | 在哪 |
|---|---|---|
| `{一句话…}` `{北极星}` `{核心那件事}` | 第一周定方向时 | CLAUDE.md、PRINCIPLES、PRD |
| `{最低版本}` | 建 Xcode 工程时 | CLAUDE.md、APPSTORE |
| `{GitHub 用户名}` `{私有仓库}` `{公开仓库}` `{默认分支}` `{网站地址}` | 建两个仓库时 | CLAUDE.md、SYSTEM、publish-site.sh |
| `{Bundle ID}` `{Team ID}` `{App ID}` `{VENDOR}` | 开发者账号下来、ASC 建 App 后 | APPSTORE、feedback/README、app-stats.py |
| `{画布链接}` | 第一次发布画布后 | CLAUDE.md、PRODUCTION |
| 模拟器 UDID、机型 | 第一次跑验证时 | skill verify-ios |
| `{待补}`（PRINCIPLES 每条「在 xx」） | 第一批决定定下后 | PRINCIPLES |

查还剩哪些：`grep -rnoE '\{[^{}$"]{1,30}\}' --include='*.md' .`

然后**开一个新会话**（新建的 agent 要新会话才调得到）。

## 三、第一周先做什么

1. **主会话按 [docs/KICKOFF.md](template/docs/KICKOFF.md) 逐条问你**：A 产品是什么（北极星、永远不做、气质要不要写成原则）→ B 数据、联网、账号、第三方 SDK、权限 → C 设备、地区、语言、收费 → D 商标、网站、宣发。答案写进 PRINCIPLES / DECISIONS / PRD / LEGAL，A–C 问完才写第一行代码
2. **B 组最关键**：它决定隐私标签、隐私政策，以及**国区走正常 ICP 备案还是苹果备案豁免**（只有完全离线才能豁免，见 LEGAL「国区」）；语言定了就按这个 App 自己的词开 `docs/i18n-glossary.md`
3. **账号和事务先跑起来**（你办，档案 agent 记 LEGAL / COSTS）：开发者账号（注册要几天，先办）；想好 Bundle ID 并确认没被占；商标近似查询；建私有 + 公开两个仓库、公开仓库开 Pages、放隐私政策
4. **环境检查**（主会话）：`DEVELOPER_DIR` 指对 Xcode；代理直连规则还在（LESSONS「环境」第一条）；`asc` 能只读登录；建专用模拟器
5. **画布出第一版**（产品 agent）：核心那一屏 2–3 个方向 → 你定 → 设计系统（令牌、组件）跟着长出来
6. **建工程骨架**（产品 agent）：`ios/` 下 App + `<名>Kit`（Core 规则 + DesignSystem）；数据模型从第一天就版本化（SchemaV1）；调试启动参数 `-resetDemo -demo -snapshot <屏>` 先定好；`swift test` 跑通 → 验收 agent 走一遍
7. **ROADMAP 第一版**：上面没做完的每件一行

## 四、平时怎么用

直接跟主会话说事。流程：你提想法 → 产品 agent 出画布方向 → **你定** → 产品写代码自测 → 验收（看代码）+ 试用员（黑盒点模拟器）同时复查 → **你说发版** `/<短名>-release` → TestFlight 真机看 → **你同意**送审。细节在 `docs/SYSTEM.md`。

永远由你拍板：画布方向、视觉、文案、commit / push、送审、发布、所有账号和付款。

## 五、文件清单（`template/` 里）

| 文件 | 用途 |
|---|---|
| `CLAUDE.md` | 入口：硬约束 + 文件地图（每个新会话自动读） |
| `LESSONS.md` | 踩坑清单，遇到报错先搜这里 |
| `docs/SYSTEM.md` | 分工、文件放哪、怎么用 |
| `docs/KICKOFF.md` | 开工询问项（主会话开工时逐条问你） |
| `docs/qa/task-steps.md` · `docs/research/qa-practices.md` | 核心任务步数表；验收做法和苹果 / Anthropic 官方依据 |
| `docs/PRINCIPLES.md` | 七条通用原则（例子待补；气质类原则按 App 设定再加） |
| `docs/i18n-glossary.md` | 多语言用词表空壳 + 通用写法规则（词按这个 App 来） |
| `docs/DECISIONS.md` | 决定空壳 + 沿用的流程类决定 |
| `docs/ROADMAP.md` | 唯一待办清单（分节空壳） |
| `docs/PRD.md` · `DESIGN-SYSTEM.md` · `IOS-ARCHITECTURE.md` | 产品 / 设计系统 / 实现方案空壳 |
| `docs/PRODUCTION.md` | 正本对照、代码分层、改动流程、验证、里程碑 |
| `docs/APPSTORE.md` | 上架清单、打包上传命令、版本更新流程（asc） |
| `docs/CHANGELOG.md` | 版本日志格式 |
| `docs/business/` | LEGAL（含国区 ICP 两条路）、COSTS、METRICS |
| `docs/feedback/` | 反馈入口 + 台账 |
| `docs/story/` | 产品介绍、AI 构建全过程、里程碑流水 |
| `marketing/` | 宣发总规划 + 每期模板 |
| `.claude/agents/` | product · review · qa · marketing · archivist · feedback |
| `.claude/skills/` | verify-ios · release（只能你触发）· promo |
| `scripts/` | init-starter（初始化，用完可删）、publish-site、backup-memory、feedback-mail、app-stats |
| `.gitignore` | 挡住构建产物、asc 凭证、成片、子目录误建的 agent 记忆 |

## 六、哪些是固执己见的

这套流程有明确立场，用之前知道一下，不合适就改 DECISIONS：
- **先画布后代码**：任何界面改动先出 2–3 个方向给你定，截图不能当设计稿（画布用的是 claude.ai 的 Design 画布 / Artifact，换成 Figma 也行）
- **你拍板，AI 不替你定**：commit、push、上传、送审、发布、回评价都每次问你；发版命令只有你能触发
- **只加字段不改语义**、**隐私政策路径不改**、**源码和网站分两个仓库**
- 平台原生优先、包容和诚实是默认原则；气质类原则开工时按你的 App 再加

## 七、更新

新项目里攒下的通用坑、流程改进，隔一阵挑出来并回这里（去掉新产品的专有内容）。欢迎提 issue 和 PR。

## 许可

MIT
