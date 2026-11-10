# designer-app-flow

**A production-tested workflow for building native iOS apps: the designer leads, Claude Code executes.**

[中文说明](README.zh.md)

With this workflow, a designer who doesn't write Swift took the native SwiftUI app [BeanDance](https://apps.apple.com/app/id6822132582) from zero to the App Store in one month, and has kept shipping updates since. designer-app-flow packages the reusable part as a Claude Code plugin: roles, a document system, QA practices and lessons learned. One command sets it up in a new project.

## Proven in production

As of November 2026.

| | |
|---|---|
| From new project to first App Store approval | 11 days |
| Versions released | 5 (1.0 → 1.0.4) |
| TestFlight builds | 21 in one month |
| Storefronts | 175, including mainland China (via Apple's ICP filing exemption) |
| Automated tests | 320 rule tests, 20+ UI test suites |
| Lessons learned | 150+, each one a symptom and what to do about it |

## What it solves

| Common problem | How this workflow handles it |
|---|---|
| AI writes fast, but a wrong direction means redoing everything | **Design first**: every UI change starts as 2–3 directions; code only after you pick one |
| Whoever builds it also checks it, and bugs reach real devices | **Two independent checks**: a reviewer who reads the code, plus a black-box tester who never sees it and walks real user paths in the simulator |
| Decisions live in chat history and are forgotten next session | **Principles → decisions → one roadmap**, with an append-only decision log |
| The AI decides on its own to upload, release or push | **You trigger anything external**: only you can run the release command; submissions, releases and pushes are confirmed every time |
| Features pile up and flows get longer | **One step fewer is one step better**: core tasks are counted in steps every version; a new design can't add steps |
| Signing, uploads, review and China's ICP rules are full of traps | **Release checklist + lessons learned**, covering both the ICP filing route and Apple's exemption |

## What's inside

- **6 project agents**: product (design + build), review (read-only), QA (black-box), marketing, archivist, feedback
- **3 skills**: iOS verification, release (user-only), marketing production
- **Document templates**: kickoff questionnaire, principles, decisions, roadmap, design-to-code process, App Store checklist, compliance log, localization glossary, changelog
- **QA practices**: state matrices (delete to zero, then add one), control combinations (keyboard + suggestion bar + date picker at once), accessibility audits, a core-task step count, and a real-device checklist with every TestFlight build
- **Lessons learned**: environment and proxies, signing and upload, simulator and UI tests, SwiftUI keyboards and sheets, data migration, App Review and compliance, multi-agent work, working with a human decision-maker

## How a feature ships

```
You have an idea → product agent drafts 2–3 directions → you pick one
→ product agent builds it and self-tests
→ reviewer (reads code) + tester (black-box) check in parallel; failures go back
→ you run /<app>-release → TestFlight, you try it on your phone
→ after you confirm, asc uploads assets and submits for review (each step asks you first)
→ after launch: feedback agent collects reviews, marketing agent plans posts, archivist records the story
```

Always your call: design direction, visuals, copy, commits, submissions, releases, and every account and payment.

## Tools

| Tool | What it's used for |
|---|---|
| [Claude Code](https://code.claude.com) (desktop app recommended) | The main session and 6 agents; the tester uses its iOS Simulator tool to tap and take screenshots |
| Apple's official Xcode plugin | Build, run tests, render previews; Apple's SwiftUI and accessibility skills; production crash and performance data |
| [asc](https://github.com/rorkai/App-Store-Connect-CLI) (third-party open-source App Store Connect CLI, MIT) | Upload builds, screenshots and store text; attach builds; submit; check review status; read reviews and TestFlight feedback; pull download stats. **Read-only by default**: every write is dry-run first and runs only after you confirm |

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

It copies `template/` into the folder, renames the agents (`myapp-product`, `/myapp-release`, …), checks your environment and tells you what to do next.

Without the plugin:

```bash
git clone https://github.com/caiman001/designer-app-flow.git
```

```bash
rsync -a ./designer-app-flow/template/ ~/my-app/ && cd ~/my-app && git init && sh scripts/init-starter.sh "My App" myapp
```

Also recommended: `/plugin install xcode@claude-plugins-official`.

## After setup

1. **Start a new session** so the new agents load
2. The main session walks you through `docs/KICKOFF.md`: what the product is → data, networking, accounts → devices, regions, languages, pricing → trademark, website, marketing. Answers go into the matching docs; no code until the first three groups are answered
3. The product agent drafts the first canvas; you pick a direction and the design system grows from it
4. Project skeleton: the app plus `<Name>Kit` (rules + design system), a versioned data model from day one, tests passing before review

Placeholders for accounts, repos and bundle IDs can wait until you get there; `init-starter.sh` lists them.

## Principles

Eight general principles: first principles, less but better, opinionated defaults, platform-native, motion with cause and restraint, inclusive, honest, design first. Your app's own character (calm, playful, motion style…) is decided at kickoff.

## Layout

| Path | Contents |
|---|---|
| `template/CLAUDE.md` | Entry point: hard rules and file map |
| `template/LESSONS.md` | Lessons learned; search here first when something breaks |
| `template/docs/` | Kickoff, principles, decisions, roadmap, production process, App Store checklist, compliance log, QA sources, feedback, product story |
| `template/.claude/agents/` | product · review · qa · marketing · archivist · feedback |
| `template/.claude/skills/` | verify-ios · release · promo |
| `template/scripts/` | init, website sync, memory backup, read-only mail, read-only download stats |
| `skills/new/` | `/designer-app-flow:new` |

## Requirements

macOS, Xcode and Claude Code. The desktop app is recommended because the tester uses its iOS Simulator tool. The templates and lessons are written in Chinese.

## Contributing

Issues and pull requests are welcome: new lessons, better QA practices, experience from other platforms.

## License

MIT
