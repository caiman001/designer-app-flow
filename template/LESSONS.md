# 踩过的坑

> 一个原生 SwiftUI App（iOS 26–27、Xcode 27）从零到上架（含中国区）积累的经验。每条：**现象** → **做法**。
> 新项目遇到新坑接着往对应组里加一行（agent 记忆里通用的那些，主会话定期并进来）。报错先在这里搜关键词。

## 一、环境

- 苹果官方 Xcode 插件（`xcode@claude-plugins-official`）链接本机 Xcode 自带的那份，Xcode 升级它跟着升 → 装在 user 级一次就行；它的 `RunProject` / `DeviceInteraction*` 会装到连着的 iPhone 上跑，agent 的 tools 名单里别开；第一次用要 `XcodeOpenWorkspace`，用户在 Xcode 弹窗点允许
- 在系统终端里装插件，`claude` 不在 PATH → 用 `~/.local/bin/claude`；装带命令的插件要在终端交互确认
- 本机代理（全局模式 + TUN + fake-ip）开着时，真机装机报「开发者磁盘镜像挂载失败（TatsuError）」、`xcodebuild -downloadPlatform` / 模拟器运行环境下载报 authentication failed 或 401 / 403 → 苹果签名服务器拒代理出口 IP。**只加直连，别关代理、别改模式和节点**：DNS 的 fake-ip-filter 加 `+.apple.com`、`+.cdn-apple.com`；TUN 加 `route-exclude-address: 17.0.0.0/8`（苹果自有 IP 段）；重启代理客户端生效。中国区苹果服务器直连可用
- 绕代理测连通 → `curl --interface en0` + 阿里 DNS DoH（`https://223.5.5.5/resolve`）拿真实 IP
- `xcode-select` 指着 CommandLineTools，`xcodebuild` / `swift test` 用错工具链 → 每条命令前加 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`（装了多个 Xcode 时写清用哪个）
- macOS 没有 `timeout` 命令；Claude 的前台 `sleep` 会被拦 → 等后台任务用小脚本循环查输出文件里的结束标记
- 只有 `/usr/bin/python3`（版本 < 3.12）：f-string 的 `{}` 里不能有反斜杠 → 先把带引号的片段算成变量再拼；numpy / PIL 装在用户 site-packages，别加 `-I`
- 很长的中文 Python 脚本偶尔报「Non-UTF-8 code starting with \xef」→ `python3 -c "exec(open(文件, encoding='utf-8').read())"`
- scratchpad 根目录有别人放的 `inspect.py` 之类，顶掉标准库让 PIL 导入失败 → Python 一律在 scratchpad 的子目录里跑
- zsh heredoc 里的 `$0` 会被展开 → 用 `<<'EOF'`
- Bash 每次的 cwd 会重置回仓库根目录 → 重定向一律写绝对路径，否则文件写进仓库
- 主会话的自动记忆在本机、不进 git、不跟账号走 → 定期 `scripts/backup-memory.sh` 备份进仓库；对话记录保留期可在 `~/.claude/settings.json` 的 `cleanupPeriodDays` 调长
- 「看邮件」能力做过却忘了 → 写进 CLAUDE.md「常用工作流」，别只放在某个文档深处；邮件最新一封很旧时先让「邮件」App 收一次信

## 二、构建、签名、上传

- 免费 Personal Team 用过的 Bundle ID，付费账号用不了 → 付费账号下来、在 ASC 建 App 之前先定死 Bundle ID（必要时加后缀）
- 付费账号刚通过，Xcode 里还是 Personal Team → Xcode → Settings → Accounts 刷新 / 加对的 Apple ID，再改 `DEVELOPMENT_TEAM`
- Xcode 直传 TestFlight 报 403 `FORBIDDEN_ERROR.ROLE_NOT_VALID` → ExportOptions 的 destination 换 `export` 导出本地 IPA，再 `asc builds upload`（App 管理密钥，不靠 Xcode 登录）。常见原因：协议待账户持有人同意、Xcode 账号登录过期
- 上传报 ITMS-91053 → 隐私清单缺了需声明理由的 API；查漏：`nm -u <Release>.app/<可执行文件> | grep -iE 'VolumeAvailableCapacity|systemUptime|ModificationDate'` 对 `PrivacyInfo.xcprivacy`
- 版本已上架后再传同版本号被拒 → 版本列车关闭了，升 `MARKETING_VERSION`；build 号所有 target 一起 +1
- 「零警告」看着过了其实是增量空跑 → 用全新 derivedData 构建再数警告
- iOS 17 起弃用的 API（如 `UITraitCollection(traitsFrom:)`）在 Release 出警告 → 换新 API（`modifyingTraits`）并复测行为不变
- 旧 derivedData 里资源包缺 `Assets.car`，所有令牌颜色变透明、UI 测试乱挂 → 先看截图有没有颜色，没有就换新的 `-derivedDataPath`
- `xcodebuild` 不同步 `.xcstrings`（只有 Xcode IDE 会）→ 查漏用编译产物里的 `*.stringsdata` 对 catalog 的 key
- asc（第三方 App Store Connect CLI）：默认带 `ASC_READ_ONLY=1`，改动先 `--dry-run`；作者的 skill 包别装（第三方审计报过钥匙串风险）；`.asc/`、`*.p8` 进 `.gitignore`
- asc 两把密钥：App 管理密钥拉不了销售报告（forbidden）→ 另建「销售」密钥只读看数据；登记新密钥会抢默认，登记完 `asc auth switch` 切回
- 商店分析（曝光 / 留存）要开 ONGOING 报告请求，苹果要管理员密钥 → 不为此建管理员密钥，改用 `asc web analytics`（用户自己登录输验证码）
- asc 截图上传高峰期频繁 500 / 超时，`--replace` 并发会乱序缺张 → `--concurrency 1` 一组一组传，`asc screenshots list` 对 MD5，缺的单张补，别整组反复 replace
- `asc review submit` 超时 → 用 `--version-id` + `--build-id` + `ASC_TIMEOUT=300s`
- `asc validate` 报「没有可售地区」（暂停销售中）苹果照样收审 → 不用为此先开地区
- 发布 / 改地区这类命令被自动模式安全检查拦 → 用户在对话里明确同意后再重试，别绕

## 三、测试与模拟器

- 常用模拟器别的会话 / 宣发录屏也在用，被人点到会出现「面板自己开合」→ 验收、迁移实测、截图各自 `simctl create` 一台专用机，用完 `simctl delete`；关键结论换一台没人看的机子复测
- `xcodebuild test` 跑完会把专用模拟器关掉，之后截图报 405「Shutdown」→ 先 `simctl boot` + `simctl bootstatus -b`
- `xcodebuild test` 打出 TEST SUCCEEDED 后挂十几分钟不退出；多台模拟器并行时结果行只在最后打出 → 按截图数 / 测试数判断跑完再 kill 自己那个进程
- 6 台模拟器并行会卡死一台 → 3–4 台一组
- 新机型模拟器只能建在特定运行时上（如只有 iOS 27.0）→ 建不了就换同尺寸机型
- 机型逻辑分辨率 HIG 不再列表 → 读 `/Library/Developer/CoreSimulator/Profiles/DeviceTypes/<机型>.simdevicetype/Contents/Resources/capabilities.plist`
- `simctl install` 覆盖安装后数据容器路径变了 → 装完重新 `simctl get_app_container ... data`
- `simctl launch` 参数值以「-」开头会被当成新参数名 → 值换个写法
- 调试启动参数包在 `#if DEBUG` 里，Release 包不认 → 验收要用的参数另做 Debug 包装到专用机；Release 只留出图必需的几个
- `simctl io recordVideo` 是可变帧率、只在画面变化时出帧 → 抽帧用 `ffmpeg -fps_mode passthrough`（`fps=60` 重采样会丢只闪一帧的画面）；查「有没有动」用每秒截图逐像素比
- 模拟器没有命令行慢动画：启动参数、全局 defaults 的 `UIAnimationDragCoefficient`、给窗口设 `layer.speed` 都放不慢 sheet / zoom 转场 → 录屏 `setpts=4*PTS` 放慢 + 逐帧量
- Instruments「Animation Hitches」模拟器报 not supported → 只能真机录（用户同意）
- 「闪一下」类问题 XCUITest 轮询抓不到（每次查询等 App 空闲）→ 边录屏边跑测试，裁出那一条逐帧量像素
- 模拟器无障碍开关 `simctl ui` 只有字号 → 粗体 / 增强对比度 / 减弱动态用 `simctl spawn <id> defaults write com.apple.Accessibility EnhancedTextLegibilityEnabled|DarkenSystemColors|ReduceMotionEnabled -bool true`，重启 App 生效
- 系统颜色（`quaternaryLabel` 等）在增强对比度下会变深 → 要求「两处看起来一样」的颜色在增强对比度下再取一次像素
- 新模拟器第一次弹键盘盖一张「滑动输入」提示 → UI 测试先点掉
- UI 测试：键盘弹着时「点外面」会点到键盘；中文键盘 `swipeDown` 收不起来 → `typeText("…\n")` 回车收键盘
- UI 测试往有值的输入框 `typeText` 是接在后面（光标可能在最前）→ 聚焦时整段选中，或断言别按尾部拼
- 系统弹窗带输入框时，打完字键盘弹起、弹窗上挪，马上点「好」会点空 → 先等 1 秒再点 `app.alerts.buttons[…]`
- 小屏上 `app.swipeUp()` 会把面板关掉 → 用 `app.scrollViews.firstMatch.swipeUp()`
- XCUITest 能「看到」opacity 0 + accessibilityHidden 的按钮 → 看不见时别放进视图树（if + 同高占位）
- iOS 的 XCUIElement 没有 `increment()`（只有 macOS 有）→ 拖动控件用 `press(forDuration:thenDragTo:)`；按住拖这类手势 simctl 做不了，用 UI 测试
- UI 测试按英文文字找元素，`.textCase(.uppercase)` 的字读屏 label 也是大写 → 谓词用 `[c]`
- Swift 6 探针测试里 `.map(\.label)` 编不过（main actor）→ `.map { $0.label }`，类加 `@MainActor`
- 测试不幂等：存文件的测试同一天第二次跑，系统弹「替换现有项目」就挂 → 文件名带随机后缀或先清
- UI 测试出截图：环境变量用 `TEST_RUNNER_` 前缀传进 runner，runner 直接把截图写到 Mac 路径
- 「App animations complete notification not received」每步卡 60 秒，整组测试慢到跑不完 → 两种原因：①带 `selection:` 的 TextField 失焦时选区还指着旧字串、提交又改了字，系统收键盘的选区动画收不了尾；②键盘开着且上方有 SwiftUI 键盘工具条（`ToolbarItemGroup(.keyboard)`）时打开系统 Menu，菜单开着期间系统动画一直在跑。定位：卡住时 `sample <pid> 4`，主线程只有系统动画、没有 App 帧 = 系统的
- `app.keyboards.firstMatch.exists` 收起后还是 true（框挪到屏幕外）；`isHittable` 不管键盘窗口，被键盘 / 候选条盖着的行也报 true → 「键盘在不在」按框判断（minY < 窗口底），「被不被挡」自己比 frame
- `waitForExistence` 一秒才查一次，量「几秒内」的中间态时先等元素再截图就晚了 → 点完马上截图，再拿元素 frame 去量那张图
- 英文下按 label 找元素，同名的底栏 tab 先匹配上 → 同名元素取 frame 最大的那个，或给控件加 identifier
- 无障碍审查 hitRegion 量的是真能点到的区域：`frame(44)` 没加 `contentShape` 也报太小 → 包一层、padding 垫到 44 + `contentShape`、外面负 padding 收回排版
- 加了测试计划后 scheme 里原来的 Testables 不再用 → 配一个默认计划；配置里的 environmentVariableEntries 传给测试进程
- 同一个模拟器 `shutdown / boot` 之后软键盘不出来了（被当成接了硬件键盘）→ 要键盘的测试换新建的模拟器
- `-resultBundlePath` 同名已存在直接 EXIT 64 → 结果包名带日期时间；scratchpad 里旧会话留下的目录也会撞名
- `recordVideo` 偶尔整段漏几秒帧 → 关键动作录两次；按相邻帧间隔 >30ms 过滤，漏帧那一帧的大位移不算数
- 动效「偶尔跳一下」只看到一次就当回归 → 同一条录 10 遍以上，新代码 / 关掉新代码 / 上一版三组都数次数，上一版也有就是老问题
- 修闪退的回归测试没证明能抓到 → `git archive` 出改之前的代码，拷新测试进去跑，应该挂
- 系统评分弹窗（`requestReview`）在 XCUITest 里不是 alert，是 App 读屏树里 identifier "star" 的按钮 + 「Not Now」；文字跟手机系统语言、不跟 `-AppleLanguages`；星星是系统蓝，画布照实画
- 模拟器点按工具（Claude 桌面版 `mcp__Claude_Code_iOS_Simulator__control`）：第一次用某台机要用户在面板点同意；**每次调用都带 `device`**，不带会截到别的模拟器；截图比点按慢约 1 秒，点完连截两次再判断；`text` 只能打 ASCII，中文要切拼音键盘；打完字立刻点按钮可能丢后半段字
- 一次完整黑盒试用（核心任务 + 删到 0 + 换语言字号）约 2 小时；整组 UI 测试几十分钟 → 都放后台，发版前留出时间
- 「谁把整张表撑宽」→ 读 `debugDescription` 里同一行的 frame x / 宽对比，比看图准；隔离法：副本里给可疑行加开关各跑一次
- 同一屏不同字号 / 修前修后对比 → numpy 逐行差（阈值 30），全零才算没动；底部 home 条每张都差，忽略
- 截屏、读 App 偏好：`simctl get_app_container <id> <bundle> data` + `plutil -p Library/Preferences/<bundle>.plist`（只读）
- 从备份恢复要选文件 → 把文件放进模拟器「文件」App 本地存储目录（`get_app_container <id> com.apple.DocumentsApp groups` 下的 File Provider Storage），选择器直接列出来

## 四、SwiftUI / iOS 26–27 实现

- Swift Testing 里 `let (_, x) = makeContainer()` 把 ModelContainer 放掉，之后碰模型就崩、xcodebuild 反复重启 → 容器放进测试 struct 的属性里
- 会变短的数组写 `ForEach(xs.indices, id: \.self) { xs[i] }`：删到变短时 SwiftUI 先拿旧下标刷新一次已经没了的那格，越界闪退（删到 0 才暴露）→ 把 Identifiable 的值直接交给子视图
- `.sheet(item:)` 闭包里读的 @State，如果 body 本身没读它，值变了 body 不重算，点开时闭包拿到旧值 → 让 body 读一下它，或把值放进 item 里
- `onGeometryChange` 的变换闭包捕获了 @State，状态变了几何没变也会重算 → 在变换里直接算成 Bool，只在真假变化时写状态
- SwiftUI 的键盘安全区是「扣掉容器底（home 条 34）之后」的量：视图忽略了 `.container` 安全区时，键盘让位就少 34 → 键盘在时补回窗口底安全区（直接读 keyWindow.safeAreaInsets.bottom，别靠量 inset 推）
- 键盘工具条（`ToolbarItemGroup(.keyboard)`）聚焦后才挂上，SwiftUI 只在聚焦那一刻滚一次，之后键盘顶再升不会再滚 → 输入框被工具条 / 候选条盖住；聚焦后自己再核一次露没露
- 键盘让位挂在 didShow 上 = 键盘到位后停一下再跳 → 用 willChangeFrame，下一帧再量，按键盘同一条曲线和时长推
- 系统 `Menu` 是 UIKit 按钮：点它不让输入框失焦，键盘留着、菜单压在键盘后面（最后一项点不到）→ 菜单内容的 `onAppear` 里收键盘；数字键盘开着时开菜单键盘会先闪成字母键盘 0.1 秒，是系统的
- 纸面板键盘开着时点普通 Button 弹 `.popover`，键盘不收，日历被挤到屏幕顶 → 用系统 compact DatePicker（会自己收键盘）或先收键盘
- `.safeAreaBar` 页头有字时系统画硬边（更亮的实底 + 细线），没字是软边 → 画布照实画
- body 链上 onChange 太多，编译器报「unable to type-check in reasonable time」→ 合并成一个布尔量再 onChange
- 系统评分弹窗时机：在「用户刚做成一件事」之后、提示淡出后再停一下才请求；等待中用户一动（换页、开面板）就作废；调试版默认不请求，加启动参数强制
- SwiftData `PersistentIdentifier` JSON 存盘再解码后 `==` 相等但 `hashValue` 不同 → 别放进字典 / Set 冷启动查，按 `==` 挨个找或用自己的稳定 key
- 嵌套类型叫 `Group` / `Section` 会遮住 SwiftUI 的同名类型；状态变量叫 `error` 会被 `catch` 里隐含的 `error` 遮住 → 换名字
- `if / else if` 换视图时被换下的那支按**新状态**重画再淡出（闪出不该出现的字）→ 会频繁切换的提示行几句叠在 ZStack 里只切 opacity
- 面板高度「适配内容」必须**打开前**就知道：先按 .large 开再改 detent = 先长出来再缩 → 来源页隐藏排一遍同一个内容视图量高度，present 时 detent 就是定值
- `.presentationSizing(.fitted)` 在 iPhone 上不管高度 → 用自定义 `.height` detent
- iOS 26 起不到全高的 sheet 是整块缩小显示（约 0.96），排版宽仍是屏宽 → 别拿 `frame(in: .global)` 当排版宽
- 自定义 `.height(h)` detent 不含底部安全区 → 要「内容下留 N」就从 detent 里扣掉 `safeAreaInsets.bottom`
- 根上的 `.dynamicTypeSize(上限)` 管不到 sheet / fullScreenCover → 每个面板 / 全屏盖层各封一次，grep `.sheet(` 逐个对
- iOS 26 滚动边缘效果只在内容滚到系统栏下面才有 → 自绘页头改 `.safeAreaBar(edge: .top)` + `.scrollEdgeEffectStyle(.soft, for: .top)`
- iOS 26 系统 alert 按钮加 `.keyboardShortcut(.defaultAction)` 会被染成 App tint；`.submitLabel(.done)` 回车键是系统蓝 → 不想要这两种颜色就别用
- iOS 26/27 的 confirmationDialog 是从来源视图弹出的气泡，不是居中卡片 → 画布画系统控件前先截一张真的
- 给系统 Menu 的 label 加大点按区：frame 44 再负 padding 收回没用（UIKit 按钮只认收回后的框）→ 让 label 真 44 高、由外层 Layout 不把多出来的高度算进行高
- 菜单的值变宽时，开着的系统菜单会跟着左右滑 → 菜单锚点用固定宽度的整块
- PhotosPicker(selection:) 的 label 闭包在 iOS 27 SDK 里不是主线程隔离 → 普通 Button + `.photosPicker(isPresented:selection:)`
- 同一个视图上同时挂 `.sheet` 和 `.fileImporter`，文件面板弹不出 → fileImporter 挂到子视图上
- 换 presentationController 的代理：`pc.delegate` 是 weak，放在会先消失的控制器里会被释放、连系统原代理一起丢 → `objc_setAssociatedObject` 挂到 pc 上；代理里的 weak 属性要 `nonisolated(unsafe)` 否则 Release 有并发警告
- 「下拉先收键盘」：`presentationControllerDidAttemptToDismiss` 回调时键盘已被收掉 → 挂一个只看不抢的 pan 手势，在 .began 记键盘开没开
- overlay 里条件出现的角标 `.alignmentGuide` 不生效 → 零尺寸锚点 `.frame(width: 0, height: 0, alignment: …)`
- 拿 `ViewThatFits` / `lineLimit(1)` 的标题当占位会矮约 7pt → 占位用固定字样 `Text("Hg")` 同字体；`minimumScaleFactor` 不缩字距，缩字号时字距按比例放
- 数字输入框初值带千位分隔（1000 → 「1,000」再读回成 1）→ 数字转文本不带分隔，按 en / zh / de 各测
- String Catalog 复数变体要求字里带数字；一句两个参数又要分单复数 → 英文用 substitutions，不在整句上 variations.plural
- 用 Python 改 `.xcstrings` → `json.dumps(d, ensure_ascii=False, indent=2)` + 按 key 排序，和 Xcode 格式一致（换分隔符会改出几千行 diff）
- 组件只收普通 String 时 SwiftUI 不翻译 → 组件文字参数用 `LocalizedStringResource`，用户数据传 `.verbatim(name)`
- 回落英文 = 工程 `developmentRegion` 改 en（Info.plist 里手写无效）；String Catalog 源语言是中文时中文表每条要写全
- 手机只有一种首选语言时，系统设置里本 App 没有「语言」项 → 先提示去「语言与地区」加一种
- 改了通知文案的 key → 旧 key 留着，老版本排好的通知送达时还要按旧 key 翻
- 系统 contextMenu 不给 preview 时透明底 PNG 浮起没有底板 → 要底板就自定义 preview

## 五、数据迁移

- 数据模型改语义会弄坏老用户数据 → 只加字段（可空），不改不删；改名用新字段
- SwiftData 加字段 → 先冻结现行版本：把 Models 里所有类（含关系和反向关系）原样抄进 `SchemaVn` 的嵌套类；迁移计划 schemas / stages 各加一项；Current 指新版本；迁移测试用 `Schema(versionedSchema: 旧版.self)` 先造库再按计划开
- 没发版的 Schema 版本中途又改字段，装过中间版的模拟器 / 真机被认成「更新版本写的库」打不开 → 没发版的版本一次定完；开发时删模拟器容器里的 store 文件重建
- SwiftData 库元数据里没有版本号 → 认版本用 `NSManagedObjectModel.makeManagedObjectModel(for:)` 的 `entityVersionHashesByName` 和库里 `NSStoreModelVersionHashes` 比
- 迁移走没走兜底看不出 → 兜底分支打一行日志，升级启动时 `log stream --predicate 'subsystem == "<bundle>"'` 看
- 升级实测 → 专用机装旧 Release 包写数据 → `sqlite3 -readonly` 存一份行 → 装新 Release 启动 → 再 dump 比 diff；可以在旧库里直接改字段造老写法
- 打不开库时不能崩、不能覆盖 → 先重试、再兜底、读不了就内存库 + 提示，原文件不动
- 恢复备份要一次事务（关 autosave、最后 save、出错 rollback）→ 否则自动保存会存下一半
- 「补标记」类迁移每次启动都跑，会把恢复到一半当成走完 → 记迁移版本号，只跑一次
- 备份日期 ISO8601 只到秒 → 比先后、排序并列都要想到同一秒（加第二排序键）
- 备份格式加字段 → 新字段可空、旧备份读成 nil，版本号能不升就不升

## 六、上架审核与合规（含国区 ICP）

- 隐私政策 URL 被 App 设置页和商店同时链着 → 路径定了永远不改；公开仓库改名会让 Pages 地址变掉
- 免费 GitHub 账号的 Pages 必须公开仓库 → 源码放私有仓库，网站单独一个公开仓库，只用同步脚本推网站文件
- 没填欧盟 DSA 交易者声明不让在欧盟上架 → 免费无内购填「非交易者」；加内购就变交易者，地址电话公开（可用个体户地址）
- 国区要 ICP 备案号，不填勾不了中国大陆（ICP_NUMBER_MISSING）→ 完全离线（无网络请求、无第三方 SDK、不开 iCloud、隐私政策跳 Safari）的 App 可申请苹果的备案豁免：开发者网站「联系我们 → 分发」申请 → 苹果回信要签字声明 → 用户签字回信 → 批了就能勾，一般几天。以后接任何联网要重新评估
- 国区地名、主权、地图按中国官方标准；App 里有世界地图风险高，可能要整版重做 → 最省事是不画陆地国界
- 过审后「手动发布」可以和宣发对齐；想先下架用 `asc remove-from-sale`，恢复前存一份地区清单
- 加急审核可以申请 → 只给真紧急的修复用
- 审核 2.5.19：调试用启动参数如果能在 Release 里改变行为，有被问的风险 → 收进只给出图用的编译配置
- 商店截图不能出现真实品牌；样机只用 Apple Design Resources 官方机身（Xcode 模拟器机身授权不含宣传）；中文标题别用苹方（换开源字体）；AI 生图里的中文小字常乱码 → 字写死后再合成
- 营养标签、PrivacyInfo、隐私政策三处说法不一致会被问 → 改一处同时改三处
- 辅助功能营养标签只勾真做到的（比如动态字体有封顶就别勾「更大字体」）

## 七、画布与预览

- 先写代码再截图当设计稿，方向不对整段返工 → 任何布局 / 组件 / 新交互 / 宣发分镜先上画布；「直接做 / 一次性做完」= 授权走完整流程，不是跳过画布
- 方案画板里的手机页面另画了简化版，用户以为「设计变了」→ 从正本画板复用真实 DOM（无头 Chrome `--dump-dom` 拍正本再拼）
- 画布里探索方向和定稿并排，越堆越乱 → 定了就删没选的，改了就替换原画板，不留「v2」；布局由一个脚本统一管（分页面、每排一个标题）
- 画系统控件凭印象画，和真机对不上 → 先在模拟器截一张真的
- 生成器一跑会重写好几张画板 → 跑前 `cp -R` 到 scratchpad，跑完逐个 `cmp`，只该变的变了才算对
- 无头 Chrome 带 `--virtual-time-budget` 截图时 CSS transition 卡住、元素画不出来 → 注入 `*{transition:none!important}` 再截
- 往画板脚本里加代码重名（已有的 `const`）→ 整张画板白屏，加之前先查重名
- 普通空格替换匹配不到 → 原文里可能是不换行空格 U+00A0
- 本地预览服务器可能给的是旧缓存 → 文字以源文件 grep 为准；验收只读时别用会往仓库写缓存的预览脚本，直接无头 Chrome 渲到 scratchpad
- 画布几何和真机差几 pt（sheet 缩放、卡片圆角）→ 按真机实测校准一次，把差值写进设计系统
- 用户说「大概这样」却没看到图 → 主动提醒图没收到

## 八、多 agent 协作

- 新建的 agent 文件当前会话调不到 → 开新会话；在那之前用通用 agent 读 `.claude/agents/<名>.md` 按角色代跑
- agent 不能中途问用户 → 要用户定的写进报告「待用户定」，主会话来问；画布方向由主会话发布给用户看
- 验收 agent「留着没修的」只在它自己的记忆里，用户从来不知道 → 主会话汇报时单独列，并写进 ROADMAP
- 一个已定的功能只记在 DECISIONS、没开待办，1.0 漏做 → 定了要动手的事，同一次改动在 ROADMAP 开一行
- 验收时开发 agent 还在改同一批文件 → 先 rsync 快照到 scratchpad 再编；收尾时 `git status` 行数 + 关键文件修改时间对一遍，晚于构建时间的重跑
- 两个会写代码的 agent 同时改同一个文件会互相覆盖（工具不拦）→ 同一批文件一次只派一个写手；要并行就各开 worktree，或按文件切开
- worktree 从 HEAD 开，看不到未提交的改动 → 开 worktree 之前先确认要的改动已提交
- agent 在子目录里跑时会在那里新建 `.claude/agent-memory` → `.gitignore` 挡住子目录里的，发现了并回根目录
- 子 agent 往 scratchpad 写报告文件可能被拦 → 报告直接写在最终回复里，截图照样放 scratchpad
- 验收自己也会出错（相对路径重定向写进了仓库根目录）→ 只读 agent 收尾 `git status --short | wc -l` 和开工时对一下
- 断网时一组 UI 测试跑了 80 多分钟（最后通过）→ 测试突然变慢先查网络，别先怀疑代码
- 会话 / 网络断了，agent 的上下文跟着没了，只剩磁盘上的东西 → 长任务把进度（跑到哪、测试数、截图目录）随手写进报告或 ROADMAP 一行；续跑时先 `git status` + 读 ROADMAP + 看 scratchpad 里的产物，接着做，别从头再来；长命令放后台、输出写文件
- 多个 agent 共用 scratchpad，截图文件名撞了 → 每个 agent 用自己的子目录，按时间戳认图
- 别的会话占着常用模拟器录宣发 → 各自建专用模拟器（见「测试与模拟器」）

## 九、和用户协作

- 主会话替用户定了素材细节（截图里某个字段留空），被用户推翻 → 素材、文案、审美上拿不准的一律问，不按「规则推得出来」自作主张
- 文档里有一条「零依赖」规则，用户从没提过，挡住了好用的库 → 遇到约束先分清是用户的硬需求还是之前 agent 写进去的二手规则，告诉用户这条规则从哪来
- 大的视觉改动做到能跑，用户一试就不喜欢，整条路线放弃 → 先做能点的预览给用户亲手试，点头后才进主线
- 用户说「别频繁在我手机上打开 App」→ 看界面用模拟器 / 预览渲染；真机只 install 不 launch
- 对外动作（发布、送审、push 网站、回评价）用户同意一次不等于以后都同意 → 每次单独问
- 新意见只记在会话记忆里，下个会话就丢了 → 改 DECISIONS + 决定日志，记忆里只留指针
- 把用户的「我感觉…」「是不是更好？」当成拍板，写进决定日志、派给 agent 照做 → 讨论中的进「待定」，方向稿里摆出自己的判断和对照方案；明确说「定了」才记
- 规则 / 识别类问题看一个错例补一条 if，越补越乱 → 先找业界标准做法和平台自带能力，用通用特征 + 打分 + 「拿不准就不填」的门槛；词库按权威来源成批补；评测分调优集和留出集，错例按类型归桶
- 只靠「看代码的验收」，真机测出删到 0 闪退、候选条挡住日期选择器 → 加一个不看代码、只按用户路径点模拟器的试用员，专走状态转换和控件组合；模拟器测不到的每次附真机清单
- 宣发「更新内容」图写成「读不全：…」这类冒号标签、「现在识别有多准」这种设问、「测了一遍」的测试口气，被说 AI 味 → 产品更新口气：上行用户碰到的问题（反馈台账里找原话），下行改了什么；数字只是结果，对外别把开发中两个版本的对比写成「比上一版」
