# {App名} · 原则

> **原则 = 怎么想、怎么判断**：长期不变，换一个产品也成立。
> 由原则推出来的**具体决定**（做什么不做什么、颜色、文案规则、尺寸…）在 [DECISIONS.md](DECISIONS.md)；具体怎么做（令牌、组件、动效参数）在 [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md)。
> 所有 agent 开工先读这份和 DECISIONS.md。原则很少改；改了在 DECISIONS.md 的决定日志记一行。
> 复查时点：每年 WWDC 后、每个 iOS .1 版本（一年两次）。调研原文放 `research/`。
>
> **怎么填**：每条下面的「在 {App名}」先空着，等第一批决定定下来再补 1–3 个真实例子；「推出」写 DECISIONS 编号。
> 这七条是换任何产品都成立的思考框架。气质类的原则（安静、有温度、好玩、动效风格…）跟着 App 的设定来，开工时问用户，定了再加在后面（编号接着往下排）。

---

## 北极星

**{一句话：用户真正要的那件事。}**
用户真正要的事：*{用户的原话或最朴素的说法}。* 下面每条原则都是为了它。

---

## 一 · 第一性原则

从用户**每次真正反复要做的事**出发重新推，不从参考 App、竞品或功能清单出发。
- **在 {App名}**：{待补}
- **检验**：去掉这个东西，用户那件事还能完成吗？它在服务那件事，还是在服务「看起来功能完整」？
- **推出**：DECISIONS {编号}

## 二 · 少，但更好

好的设计是尽可能少的设计（Dieter Rams）。做减法，每页只有一个焦点。
- **在 {App名}**：{待补}
- **检验**：拿掉它，页面变差了吗？没有就拿掉。极简不等于删光——每页要留一个一眼能读出的表达。
- 来源：[Rams 好设计十原则](https://vitsoe.com/us/about/good-design)、[HIG 设计原则 · Simplicity](https://developer.apple.com/design/human-interface-guidelines/design-principles)（「简单不是极简」）

## 三 · 有主见

替用户做决定，能推出来的就不问（Linear Method）。
- **在 {App名}**：{待补}
- **检验**：这个选项能由 App 推出来吗？能就不问。推出来的值用户随时能改，改错了能回去。
- 来源：[HIG 设计原则 · Agency](https://developer.apple.com/design/human-interface-guidelines/design-principles)、[Linear Method](https://linear.app/method/introduction)

## 四 · 平台原生

用苹果的控件、材质、手势和习惯，遵循 HIG 的**层级、和谐、一致**；有成熟方案就用，不手搓。品牌只出现在值得的地方。
- **在 {App名}**：{待补：哪几处允许定制，其余全用系统的}
- **检验**：苹果有现成的吗？用户在别的 App 里学会的，在这里还成立吗？
- 来源：[Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)（Familiarity、Branding）

## 五 · 包容

每个人都能用：读屏、大字体、减弱动态、色弱、不同语言。
- **在 {App名}**：{待补}
- **检验**：打开 VoiceOver、语音控制、最大字体、减弱动态效果、降低透明度、增强对比度、粗体文本，各走一遍核心路径。信息不只靠颜色区分。
- 来源：[HIG 设计原则 · Flexibility](https://developer.apple.com/design/human-interface-guidelines/design-principles)、[Apple 辅助功能](https://developer.apple.com/accessibility/)、App Store 辅助功能营养标签

## 六 · 诚实

对用户诚实：数据是用户的；权限用到时才要；不装精确、不编造、不用操纵人的手段。
- **在 {App名}**：{待补：数据存哪、权限什么时候要、AI 结果怎么标}
- **检验**：如果用户知道背后怎么做的，会不舒服吗？
- **推出**：合规台账 [business/LEGAL.md](business/LEGAL.md)
- 来源：[HIG 设计原则 · Responsibility](https://developer.apple.com/design/human-interface-guidelines/design-principles)、Rams「好的设计是诚实的」；审核指南 5.1.1、《个人信息保护法》

## 七 · 设计先行

先想清楚、画出来、给人看，再做。
- **在 {App名}**：任何布局 / 组件 / 新交互先上 Design 画布，用户认可后才写代码；宣发先做分镜再生产；截图永远不能当设计稿。
- **检验**：这一步之前，用户看过它的样子吗？
- 「直接做」= 不用再问要不要做，**不是**跳过规划
