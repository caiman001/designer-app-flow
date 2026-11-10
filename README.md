# designer-app-flow

**A designer's workflow for shipping a native iOS app with Claude Code.**

[中文说明](README.zh.md)

I'm a designer, not a Swift engineer. I used Claude Code to take [**BeanDance**](https://apps.apple.com/app/id6822132582), a native SwiftUI app, from zero to the App Store, including the China storefront. This repo is the workflow that came out of it, with that app's visual style, brand and product rules taken out. What's left is the part you can reuse:

- **A small team of project agents**: the main session talks to you and you make every call; six agents do the work: **product** (canvas first, then SwiftUI), **review** (read-only, reads the code), **QA** (black-box: never reads the code, taps through the simulator like a user and counts steps), **marketing**, **archivist** (story, trademark and compliance log) and **feedback** (collects reviews and comments, drafts replies, never sends them).
- **Release only when you say so**: `/<app>-release` is a user-only command. Uploads, submissions, pushes and replies are always confirmed with you first.
- **A document system that doesn't rot**: principles → decisions (with "never do", "open questions" and an append-only decision log) → a single roadmap. A kickoff questionnaire asks about data, networking, accounts, devices, regions, languages and pricing before the first line of code.
- **QA that catches what code review misses**: first principles, then aesthetics, then features. Core tasks are measured in steps. It runs state matrices (delete down to 0, then add one), control combinations (keyboard + suggestion bar + date picker), accessibility audits, and a real-device checklist for every TestFlight build.
- **150+ lessons learned**, each one a symptom plus what to do: proxies breaking Apple signing, Xcode 403 uploads, simulator quirks, SwiftUI keyboard and sheet traps, SwiftData migrations, App Store review, **China ICP filing and Apple's ICP exemption**, multi-agent pitfalls, and working with a human who makes the decisions.
- Built to work with **Apple's official Xcode plugin for Claude**: agents check Apple's SwiftUI and accessibility skills before writing code.

> The templates and lessons are written in **Chinese**. You need macOS, Xcode and Claude Code. The desktop app is recommended, because the QA agent uses its iOS Simulator tool.

## Install

As a Claude Code plugin:

```
/plugin marketplace add caiman001/designer-app-flow
```

```
/plugin install designer-app-flow@designer-app-flow
```

Then open Claude Code in an **empty folder** and run:

```
/designer-app-flow:new "My App" myapp
```

It copies `template/` into the folder and renames the agents (`myapp-product`, `/myapp-release`, …). It then checks your environment and tells you what to do next: start a new session, and the main session walks you through `docs/KICKOFF.md`.

Without the plugin:

```bash
git clone https://github.com/caiman001/designer-app-flow.git
```

```bash
rsync -a ./designer-app-flow/template/ ~/my-app/ && cd ~/my-app && git init && sh scripts/init-starter.sh "My App" myapp
```

Also recommended: `/plugin install xcode@claude-plugins-official`.

## What's in `template/`

| Path | What it is |
|---|---|
| `CLAUDE.md` | Entry point: hard rules and file map |
| `LESSONS.md` | Lessons learned, grouped by topic |
| `docs/KICKOFF.md` | Kickoff questionnaire the main session asks you |
| `docs/SYSTEM.md` | Who does what, where files go, how a feature ships |
| `docs/PRINCIPLES.md` · `DECISIONS.md` · `ROADMAP.md` | Principles → decisions → the one to-do list |
| `docs/PRODUCTION.md` · `IOS-ARCHITECTURE.md` · `DESIGN-SYSTEM.md` · `PRD.md` | Design-to-code mapping, layering, verification, milestones |
| `docs/APPSTORE.md` · `business/LEGAL.md` | App Store checklist, upload and release commands, China ICP paths, privacy and licensing log |
| `docs/qa/` · `docs/research/qa-practices.md` | Step-count table; QA practices with Apple and Anthropic sources |
| `docs/feedback/` · `docs/story/` · `marketing/` | Feedback log, product story, marketing plan |
| `.claude/agents/` | product · review · qa · marketing · archivist · feedback |
| `.claude/skills/` | verify-ios · release (user-only) · promo |
| `scripts/` | init, publish website, back up memory, read mail (read-only), App Store stats (read-only) |

## Opinions baked in

This workflow has opinions. Change `DECISIONS.md` if they don't fit.

- **Design before code**: every UI change starts as 2–3 directions on a canvas for you to pick. Screenshots never count as designs.
- **You decide, the AI doesn't**: commits, pushes, uploads, submissions and releases are confirmed every time.
- **Data models only gain fields**, the privacy-policy URL never moves, and source and website live in separate repos.

## License

MIT
