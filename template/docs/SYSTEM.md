# {App名} · 项目运转系统

> 谁负责什么、文件放哪、原则怎么更新、平时怎么用。新会话先读 CLAUDE.md，再读这份。
> 依据：Claude Code 官方 subagent 文档（code.claude.com/docs/en/sub-agents）+ 一个已上架 App 的实际流程。

## 一、分工：主会话 + 6 个 agent + 1 个发版流程

| 角色 | 负责 | 不做 | 形式 |
|---|---|---|---|
| **主会话**（和你对话的那个） | 听你说、分派、汇总；所有要你拍板的事（画布方向、审美、文案、提交）；宣发视频和封面生产 | 大块执行 | — |
| **产品**（设计 + 开发）`{app}-product` | 画布出 2–3 个方向 → 你定 → 写 SwiftUI → 规则测试、截图自查 → 更新 ROADMAP / CHANGELOG | 自己验收、commit / push、发版 | agent，能改文件 |
| **验收** `{app}-review` | 独立复查产品的改动（看代码）：先第一性原则、再美观、再功能；对照设计系统、无障碍、合规；顺着改动找受影响的状态转换；跑测试计划和截图，每条附证据；给「通过 / 要改」清单 | 改代码 | agent，只读 + 跑测试 |
| **试用员** `{app}-qa` | 黑盒：不看代码和 diff，像用户一样在模拟器上走核心任务、状态矩阵（删到 0 等）、控件组合（键盘 / 候选条 / 日期同时出现）、各语言和大字号，数每个任务的步数（和 `docs/qa/task-steps.md` 比）；给「能发 / 不能发」 | 改文件、真机 | agent，只读 + 点模拟器 |
| **宣发** `{app}-marketing` | 数据、日历、文案润色、tag、复盘 | 视频和图片生产（主会话按 `{app}-promo` 做） | agent，只写 marketing/ |
| **反馈** `{app}-feedback` | 从 App Store 评价、TestFlight、GitHub Issues、邮件、社媒评论、全网提及收集反馈 → 去重归类进 `docs/feedback/log.md` → 对照原则给 Top 3 优化建议 → 起草回复 | 发回复、改 App、改决定 | agent，只写 docs/feedback |
| **档案** `{app}-archivist` | 产品介绍、「我如何用 AI 做这个产品」全过程、里程碑流水、商标和合规台账、花销 | 产品决定、法律判断 | agent，只写 docs/story、docs/business |
| **发版流程** `/{app}-release` | 改 build 号 → 打包 → 上传 TestFlight → 对照上架清单 → 记版本日志 | 账号、密码、提交审核 | skill，**只有你输入才会跑** |

为什么这样分：
- 设计和开发是一条链（画布 → Swift，同一套令牌），拆开只多一道交接
- 做的人不验自己的活：验收是干净上下文、只读，只看改动和原则（官方推荐的 implementer + reviewer）
- 验收分两个：看代码的 review 容易只盯着改动；试用员不看代码、只按用户路径走，专抓状态转换和控件组合。模拟器测不到的（相机、触感、性能）每次 TestFlight 附真机清单。依据见 `docs/research/qa-practices.md`
- 上传这类有副作用、不可撤回的流程，做成只能由用户触发的 skill（`disable-model-invocation: true`），不让 AI 自己决定什么时候跑
- agent 不能中途问你：需要你定的，统一写在它的报告「待用户定」里，由主会话来问

## 二、原则：一个活文档，不写死在 agent 里

- **`docs/PRINCIPLES.md` 只放原则**（怎么想、怎么判断，长期不变）；**`docs/DECISIONS.md` 放由原则推出的具体决定**（做什么不做什么、视觉、动效、文案、永远不做、待定、决定日志）。agent 每次开工先读两份；你给新意见 → 主会话改 DECISIONS（加一条决定日志）→ 所有 agent 下次自动用新的
- DECISIONS 结构：产品 P → 交互与动效 M → 视觉与材质 V → 文案 C → 平台与合规 A → **永远不做** → 待定的张力 → 决定日志（只追加、不删，只标「被取代」）
- 每条决定：规则 / 为什么 / ✓✗ 例子 / 依据（原则几）/ 用户定的日期
- **复查时点**：每年 WWDC 后、每个 iOS .1 版本（一年两次），档案 agent 提醒、产品 agent 起草更新、你确认
- **待办只有一个来源：`docs/ROADMAP.md`**（快照形式，单一源）。DECISIONS 里定了要动手的事，**同一次改动**就在 ROADMAP 开一行（写「DECISIONS 日期」）；反馈、验收、宣发、事务里冒出来的待办也开在 ROADMAP。别的文件写为什么 / 细节 / 台账，不放 `- [ ]`。做完在 ROADMAP 删掉，记进 CHANGELOG / 台账 / timeline
  - 为什么：只记在 DECISIONS、没开待办的事容易漏做
- **讨论不等于拍板**：用户抛出想法（「我感觉…」「是不是更好？」）是在讨论，写进 DECISIONS「待定」，方向稿里摆出我们自己的判断和对照；只有明确说「定了 / 就这样 / 开始做」才进决定日志。派 agent 时写「讨论用方向稿」而不是「用户已定」
- **验收「留着没修的」必须让用户知道**：主会话汇报验收时，「一般 / 建议」里不修的单独列给用户，同时写进 ROADMAP
  - 为什么：只记在 agent 记忆里的问题，用户看不到
- DESIGN-SYSTEM.md 管「怎么做」（令牌、组件）；PRINCIPLES 管「怎么想」；DECISIONS 管「做不做、定成什么样」

## 三、文件留存

```
CLAUDE.md                    硬规则 + 文件地图（入口）
LESSONS.md                   踩坑清单（新坑接着往里加）
docs/
  SYSTEM.md                  这份：分工、怎么用
  PRINCIPLES.md              原则
  DECISIONS.md               具体决定 + 决定日志
  ROADMAP.md                 唯一的待办清单
  PRD.md / DESIGN-SYSTEM.md / PRODUCTION.md / IOS-ARCHITECTURE.md
  CHANGELOG.md               每个 build 改了什么（发版流程写）
  APPSTORE.md                上架清单 + 版本更新流程
  APPSTORE-LISTING.md        商店信息正本（文案、截图、地区、审核备注）——上架前建
  KICKOFF.md                 开工询问项（主会话开工时逐条问用户，答完移进 archive/）
  i18n-glossary.md           多语言用词表（按这个 App 的词来列）
  archive/                   旧版 ROADMAP 等存档
  feedback/                  反馈台账（README 入口 + log.md，反馈 agent 写）
  story/                     对外的故事（档案 agent 写）
    PRODUCT.md               产品介绍：一句话、三个亮点、截图、FAQ，中英
    BUILD-WITH-AI.md         「我如何用 AI 做这个产品」：时间线、方法、关键决定和被否方案、数字
    timeline.md              原始流水：每个里程碑一行（日期、做了什么、证据）
  business/                  事务
    LEGAL.md                 商标、App 备案、隐私、上架声明的台账 + 简报
    COSTS.md                 账号、域名、服务器、官费的花销和续费日
    METRICS.md               每周下载 / 评分 / 评论
  research/                  调研原文
marketing/                   宣发（入口 README.md）
design/                      画布、渲染、宣发生产脚本、商店素材
ios/                         原生 App 工程
index.html · privacy.html    网站：一页简介 + 隐私政策
```

## 四、平时怎么用

**直接跟主会话说事，不用点名。** 主会话判断交给谁、在后台跑、做完汇总给你。想指定也行：「让验收看一下」「/{app}-release」。

一个功能从想法到上线：
1. 你提想法 → 2. 产品 agent 出画布方向 → 3. **你在画布上定** → 4. 产品 agent 写代码、自测 → 5. 验收 agent（看代码）和试用员（黑盒点模拟器）同时复查，有问题打回产品 → 6. **你说发版** → `/{app}-release` 上传 TestFlight → 7. 你真机看 → 8. **提交审核**：你在 App Store Connect 点；或你同意后，主会话用 asc 上传素材、送审（每步先问你，流程见 APPSTORE.md「版本更新流程」）→ 9. 档案 agent 记 CHANGELOG、timeline，宣发 agent 排内容

其他：
- 能并行：产品修 bug 的同时，宣发记数据、档案整理故事；**两个会写代码的 agent 不同时改同一批文件**（见 LESSONS「多 agent 协作」）
- 档案 agent 每个里程碑后补 timeline；你说「整理一下 AI 构建的故事」它就更新 BUILD-WITH-AI.md
- 你永远拍板的：画布方向、视觉细节、文案、commit / push、提交审核、所有账号和付款

## 五、技术细节（给 Claude）

- agent 文件在 `.claude/agents/`，正文只写角色、流程、汇报格式；规则引用 docs，不复制
- 产品：`tools: Read, Edit, Write, Grep, Glob, Bash`；`memory: project`（积累踩坑经验）；`skills: {app}-verify-ios`；worktree 隔离按需用（worktree 从 HEAD 开，看不到未提交的改动，开之前先确认要的改动已提交）
- 验收：`tools: Read, Grep, Glob, Bash, Skill` + Xcode 插件只读类工具（只跑测试和截图，不改文件）；比产品用更强的模型（`model: opus`）
- 试用员：`tools: Read, Grep, Glob, Bash, Skill` + Claude 桌面版的模拟器工具 `mcp__Claude_Code_iOS_Simulator__control`；`model: opus`
- **苹果官方 Xcode 插件**（`xcode@claude-plugins-official`，user 级装一次，链接本机 Xcode 自带的那份，Xcode 升级它跟着升；技能全名带前缀 `xcode-integration:`）：
  - 工具（MCP `plugin:xcode-integration:xcode`，底层是 `xcrun mcpbridge`）：产品、验收按名单开了查文档 `DocumentationSearch`、渲染预览、编译 / 跑测试 / 编译日志、字符串表、线上崩溃和性能（`GetTopCrashIssues` / `GetTopFieldPerformanceIssues`，Organizer 里真实用户的数据）。**不开** `RunProject` / `DeviceInteraction*`（会装到用户手机上跑）和改工程设置、加权限的那几个；第一次用要 `XcodeOpenWorkspace`，用户在 Xcode 弹窗点允许
  - 技能（苹果写的，`Skill` 调用）：写 SwiftUI 先查 `swiftui-specialist` / `swiftui-whats-new-27`（键盘、菜单、滚动这类系统行为以它为准）；无障碍看 `accessibility-voiceover-specialist` / `-dynamic-type-specialist` / `-sufficient-contrast-specialist`；卡顿看 `xctrace`；多语言看 `translation-coordinator`；改测试看 `modernize-tests`。试用员只开 `Skill`（看无障碍判断标准，不看代码）
- 档案：只写 docs/story、docs/business
- 宣发 / 反馈：`memory: project`
- 发版：skill，`disable-model-invocation: true`
- iOS 验证流程写成 skill（`{app}-verify-ios`）：swift test、模拟器跑核心路径截图，产品自查和验收都用

## 六、用户定的

| 日期 | 定了什么 |
|---|---|
| {日期} | 采用本流程（本文件）；设计风格、品牌、产品规则按本 App 重新定 |

## 七、已知限制

- 新建的 agent 文件要**开新会话**才会出现在可调用列表里；在那之前，主会话用通用 agent 读 `.claude/agents/<名>.md` 按角色代跑
- agent 不能中途问用户：要用户定的写进报告「待用户定」，主会话来问
- agent 的专属记忆在 `.claude/agent-memory/<名>/`（随仓库保存；agent 在子目录里跑时可能在别处新建 `.claude/agent-memory`，发现了就并回根目录，`.gitignore` 已挡住子目录里的）
- 主会话的自动记忆在本机 `~/.claude/projects/<项目路径>/memory/`，不进 git、不跟账号走：`scripts/backup-memory.sh` 备份到 `docs/memory/`（换电脑 / 换账号时拷回去）
- 仓库：私有 `{私有仓库}`（remote `origin`，全部源码和文档）+ 公开 `{公开仓库}`（remote `site`，只有网站）；网站更新用 `scripts/publish-site.sh`
