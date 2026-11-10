# designer-app-flow

**一套经过真实上架验证的原生 iOS App 开发流程：设计师主导，Claude Code 执行。**

[English](README.md)

用这套流程，一位不写 Swift 的设计师在一个月内把原生 SwiftUI App [BeanDance](https://apps.apple.com/app/id6822132582) 从零做到了 App Store，并持续迭代。designer-app-flow 把其中可复用的部分整理成 Claude Code 插件：分工、文档体系、验收方法和踩坑经验。一条命令就能用在你的新项目里。

## 实战验证

数据截至 2026-11。

| | |
|---|---|
| 从建工程到首版过审 | 11 天 |
| 已发布版本 | 5 个（1.0 → 1.0.4） |
| TestFlight 构建 | 一个月 21 个 |
| 上架地区 | 175 个，含中国大陆（通过苹果 ICP 备案豁免） |
| 自动化测试 | 320 条规则测试、二十多组 UI 测试 |
| 踩坑记录 | 150 多条，每条一句现象 + 一句做法 |

## 解决什么问题

| 常见问题 | 这套流程的做法 |
|---|---|
| AI 写得快，但方向不对就要整段返工 | **设计先行**：任何界面改动先出 2–3 个方向，你定了再写代码 |
| 做的人自己验自己，问题漏到真机 | **双重验收**：看代码的验收 + 不看代码、在模拟器上按用户路径走的试用员 |
| 决定散在聊天记录里，下次会话就忘 | **原则 → 决定 → 唯一待办**，决定日志只追加 |
| AI 自己决定上传、发布、推送 | **对外动作由你触发**：发版命令只有你能运行；送审、发布、推送每次都先确认 |
| 功能越加越多，操作越来越绕 | **少一步是一步**：核心任务每版都数步数，新设计不能比上一版多 |
| 签名、上传、审核、国区备案处处是坑 | **上架清单 + 踩坑清单**，含中国大陆 ICP 备案和苹果豁免两条路 |

## 包含什么

- **6 个项目 agent**：产品（设计 + 开发）、验收（只读）、试用员（黑盒）、宣发、档案、反馈
- **3 个 skill**：iOS 验证、发版（只能你触发）、宣发生产
- **文档模板**：开工询问项、原则、决定、待办、设计到生产流程、上架清单、合规台账、多语言用词表、版本日志
- **验收方法**：状态矩阵（删到 0 再加一条）、控件组合（键盘、候选条、日期选择器同时出现）、无障碍审查、核心任务步数表，每次 TestFlight 附真机清单
- **踩坑清单**：环境与代理、签名上传、模拟器与 UI 测试、SwiftUI 键盘与面板、数据迁移、审核合规、多 agent 协作、人机协作

## 一个功能怎么上线

```
你提想法 → 产品 agent 出 2–3 个方向 → 你定
→ 产品 agent 写代码、自测
→ 验收（看代码）+ 试用员（黑盒）同时复查，不过就打回
→ 你输入 /<app>-release → 传 TestFlight，你真机试
→ 你确认后，用 asc 上传素材、送审（每一步都先问你）
→ 上线后，反馈 agent 收评价，宣发 agent 排内容，档案 agent 记过程
```

始终由你决定的：设计方向、视觉、文案、提交、送审、发布，以及所有账号和付款。

## 用到的工具

| 工具 | 用来做什么 |
|---|---|
| [Claude Code](https://code.claude.com)（推荐桌面版） | 主会话和 6 个 agent；试用员用它的 iOS 模拟器工具点按、截图 |
| 苹果官方 Xcode 插件 | 编译、跑测试、渲染预览；苹果写的 SwiftUI 和无障碍技能；读线上崩溃和性能数据 |
| [asc](https://github.com/rorkai/App-Store-Connect-CLI)（第三方开源 App Store Connect 命令行，MIT） | 上传 build、上传截图和商店文字、挂 build、送审、看审核状态、读评价和 TestFlight 反馈、拉下载数据。**默认只读**，所有写操作先预演，你确认后才执行 |

## 安装

作为 Claude Code 插件：

```
/plugin marketplace add caiman001/designer-app-flow
```

```
/plugin install designer-app-flow@designer-app-flow
```

然后在一个**空文件夹**里打开 Claude Code，输入：

```
/designer-app-flow:new "App 显示名" 英文小写短名
```

它会把 `template/` 铺进当前文件夹，把 agent 改名成 `<短名>-product`、`/<短名>-release` 这样，再检查环境、告诉你下一步。

不用插件：

```bash
git clone https://github.com/caiman001/designer-app-flow.git
```

```bash
rsync -a ./designer-app-flow/template/ ~/<新项目>/ && cd ~/<新项目> && git init && sh scripts/init-starter.sh "App 显示名" 英文小写短名
```

推荐同时装苹果官方 Xcode 插件：`/plugin install xcode@claude-plugins-official`。

## 开工之后

1. **开一个新会话**，新建的 agent 才会出现
2. 主会话按 `docs/KICKOFF.md` 逐条问你：产品是什么 → 数据、联网、账号 → 设备、地区、语言、收费 → 商标、网站、宣发。答案写进对应文档，前三组问完才开始写代码
3. 产品 agent 出第一版画布，你定方向，设计系统跟着长出来
4. 建工程骨架：App + `<名>Kit`（规则 + 设计系统），数据模型从第一天就版本化，跑通测试后交给验收

账号、仓库、Bundle ID 这些占位不用一次填完，到哪一步填哪一个，`init-starter.sh` 跑完会列出来。

## 设计原则

八条通用原则：第一性原则、少但更好、有主见、平台原生、动效有因果且克制、包容、诚实、设计先行。这个 App 自己的气质（安静、好玩、动效风格……）开工时再定。

## 目录

| 路径 | 内容 |
|---|---|
| `template/CLAUDE.md` | 入口：硬约束 + 文件地图 |
| `template/LESSONS.md` | 踩坑清单，遇到报错先搜这里 |
| `template/docs/` | 开工询问、原则、决定、待办、生产流程、上架清单、合规台账、验收依据、反馈、产品故事 |
| `template/.claude/agents/` | product · review · qa · marketing · archivist · feedback |
| `template/.claude/skills/` | verify-ios · release · promo |
| `template/scripts/` | 初始化、同步网站、备份记忆、只读邮件、只读下载数据 |
| `skills/new/` | `/designer-app-flow:new` |

## 前提

macOS + Xcode + Claude Code。推荐用桌面版：试用员要用它的 iOS 模拟器工具。文档是中文。

## 参与

欢迎提 issue 和 PR：新的坑、更好的验收办法、别的平台的经验都可以。

## 许可

MIT
