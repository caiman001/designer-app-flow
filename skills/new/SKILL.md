---
name: new
description: 在当前文件夹铺开一个新 iOS App 项目的起步包（CLAUDE.md、6 个项目 agent、验证 / 发版 / 宣发 skill、原则 → 决定 → 待办文档、上架和国区备案清单、踩坑清单），然后按开工询问项问用户。只在用户输入 /designer-app-flow:new 时运行。
argument-hint: "<App 显示名> <英文小写短名>"
disable-model-invocation: true
---

# 新建 App 项目

用户的参数：`$ARGUMENTS`（第一个是 App 显示名，可以带空格要加引号；第二个是英文小写短名，用作 agent 前缀，如 `lumen` → `lumen-product`、`/lumen-release`）。

用用户的语言和他沟通；起步包的文档是中文写的。

## 1. 先确认
- 没给参数、或少一个：问用户要 App 显示名和英文小写短名（小写字母、数字、连字符，字母开头）
- 当前文件夹里已经有 `CLAUDE.md`、`docs/` 或 `.claude/agents/`：**停下问用户**，不要覆盖已有项目。最好在一个空的新文件夹里跑
- 告诉用户要往当前文件夹写入约 50 个文件，用户同意再继续

## 2. 铺文件
```bash
rsync -a --ignore-existing "${CLAUDE_PLUGIN_ROOT}/template/" ./
sh scripts/init-starter.sh "<App 显示名>" <短名>
```
`init-starter.sh` 会把 `{App名}` `{app}` `{开工日期}` 换掉、把 agent / skill 改成 `<短名>-*`，最后列出还要手填的占位（账号、仓库下来后再填）。跑完可以删掉它。

不是 git 仓库的话，问用户要不要 `git init`（只本地，不建远程）。

## 3. 检查环境（只读，有问题告诉用户，别替他改）
- `xcode-select -p` / `/Applications/Xcode.app` 在不在；编译命令都带 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- 苹果官方 Xcode 插件装了没有（`xcode@claude-plugins-official`）；没装就告诉用户在 Claude Code 里装，agent 会用到它的 SwiftUI / 无障碍技能
- 第三方 `asc`（App Store Connect 命令行）有没有：上架时才需要，现在只提一句
- 本机开着代理时苹果服务会连不上：见 `LESSONS.md`「环境」第一组，只提醒，**不改网络设置**

## 4. 交给用户
用三五行告诉用户：
1. 文件铺好了（列几个最重要的：`CLAUDE.md`、`docs/KICKOFF.md`、`docs/ROADMAP.md`、`LESSONS.md`、`.claude/agents/`）
2. **要开一个新会话**，新建的 agent 才会出现
3. 新会话里主会话会按 `docs/KICKOFF.md` 一条条问：产品是什么 → 数据、联网、账号 → 设备、地区、语言、收费 → 商标、网站、宣发；A–C 问完才写第一行代码
4. 发版命令 `/<短名>-release` 只有用户自己输入才会跑

用户想现在就开始问也可以：直接从 `docs/KICKOFF.md` 的 A1 开始，每次问一两条，答案写进它指的文件，问完的标「已答 → 去处」。
