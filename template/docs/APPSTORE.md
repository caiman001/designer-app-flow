# {App名} 上架 App Store 流程

> 工程：`ios/{App名}.xcodeproj`（App）+ `ios/{App名}Kit`（规则与设计系统）。编译统一加 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`。
> 商店文案、截图、地区、审核备注的正本在 `APPSTORE-LISTING.md`（上架前建）；这份只管工程配置、清单和流程。
> 现状：{日期} {阶段}

## 一、工程配置（在 App Store Connect 建 App 之前定死）

| 项 | 值 |
|---|---|
| Bundle ID | `{Bundle ID}`（**先在开发者网站确认没被占**：免费 Personal Team 用过的 ID 付费账号用不了，建了 ASC 记录后改不了） |
| Team | `{Team ID}`（个人 / 公司付费账号） |
| App ID（ASC 里的数字） | `{App ID}` |
| 版本 | `MARKETING_VERSION` 1.0 · `CURRENT_PROJECT_VERSION` 1（每次上传 build 号 +1，所有 target 一起改） |
| 系统 / 设备 | iOS {最低版本}+，{仅 iPhone / 含 iPad}，{仅竖屏？}（不支持 iPad 就免交 iPad 截图） |
| 分类 | {分类} |
| 图标 | `Assets.xcassets/AppIcon` 1024 |
| 权限文案 | {每个权限一句话说清拿来干嘛；多语言放 InfoPlist.xcstrings} |
| 出口合规 | 没用非豁免加密就设 `ITSAppUsesNonExemptEncryption = NO`（上传后不用答加密问卷） |
| 隐私清单 | `Resources/PrivacyInfo.xcprivacy`：用到需声明理由的 API（UserDefaults、磁盘空间、文件时间戳、开机时间…）都要写，缺了上传报 ITMS-91053 |
| 隐私政策 | `privacy.html` → {网站地址}privacy.html（**不能改路径**） |

## 二、清单

### A. 账号（本人操作）
- [ ] developer.apple.com 注册 **Apple Developer Program**（个人约 ¥688/年）。中国大陆个人走 Apple Developer App 实名（身份证 + 人脸）最快；用哪个 Apple ID 注册就决定账号地区，想清楚再注册
- [ ] 审核通过后 Xcode → Settings → Accounts 刷新，确认 Team 不再是「Personal Team」
- [ ] App Store Connect → 我的 App → 新建：名称、主语言、Bundle ID、SKU
- [ ] 协议、税务和银行：免费 App 只需同意《免费 App 协议》；有内购 / 付费要签付费协议 + 税务 + 银行
- [ ] asc 密钥（用户自己在 ASC 生成、自己 `asc auth login`）：一把「App 管理」（上传、送审）+ 一把「销售」只读（看下载量）；两把别混，登记新密钥会抢默认，登记完切回

### B. 工程（账号通过后由 Claude 做）
- [ ] `DEVELOPMENT_TEAM` 换成付费 Team
- [ ] Release Archive → 上传 → TestFlight 内部测试
- [ ] 隐私清单、权限文案、出口合规（见第一节）

### C. 商店素材
- [ ] 截图：6.9 寸 1320×2868 + 6.3 寸 1206×2622（每种语言），PNG 无透明。**不出现真实品牌**；样机只用 Apple Design Resources 官方机身（授权见 LEGAL）
- [ ] 名称、副标题（≤30 字）、描述、关键词（≤100 字符）、推广文本
- [ ] 隐私政策 URL、技术支持 URL（用网站，不用源码仓库地址）
- [ ] App 隐私问卷（营养标签）：和 PrivacyInfo、隐私政策三处说法一致
- [ ] 年龄分级问卷
- [ ] 辅助功能营养标签：只勾真做到的
- [ ] 欧盟 DSA 交易者声明：免费、无内购可填「非交易者」；有内购 / 付费 = 交易者，地址电话会公开
- [ ] 销售地区：中国大陆要 ICP 备案号或苹果的备案豁免（见 LEGAL；没有就先不勾）

### D. 提审
- [ ] TestFlight 真机自测核心路径：{写下}
- [ ] 审核备注：要不要登录（要就给演示账号）、特殊功能怎么触发、数据在哪处理
- [ ] 风险点：4.2 最低功能、5.1.1 权限文案说清用途、2.5.19 调试启动参数别进 Release 行为

## 三、打包上传（命令）

```
cd ios && export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project {App名}.xcodeproj -scheme {App名} -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/archive/{App名}.xcarchive -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath build/archive/{App名}.xcarchive -exportOptionsPlist scripts/ExportOptions.plist \
  -exportPath build/export -allowProvisioningUpdates      # ExportOptions：method app-store-connect、destination upload、teamID {Team ID}
```

备用（Xcode 这条报 403 `FORBIDDEN_ERROR.ROLE_NOT_VALID` 时）：ExportOptions 的 destination 换成 `export` 导出本地 IPA，再用 asc（App 管理密钥，不靠 Xcode 登录）上传：
```
sed 's#<string>upload</string>#<string>export</string>#' scripts/ExportOptions.plist > "$TMPDIR/ExportLocal.plist"
xcodebuild -exportArchive -archivePath build/archive/{App名}.xcarchive -exportOptionsPlist "$TMPDIR/ExportLocal.plist" -exportPath build/export -allowProvisioningUpdates
ASC_READ_ONLY= asc builds upload --app {App ID} --ipa build/export/{App名}.ipa --verify-timeout 120s
```
（Xcode 403 常见原因：开发者协议待账户持有人同意，或 Xcode 账号登录过期。）

## 四、版本更新流程

每步先 `--dry-run` / 只读看一遍，**用户同意后**主会话再执行；送审 = 对外发布，单独问。

1. **上传 build**：`/{app}-release`（build 号 +1 → 打包 → TestFlight）
2. **新建版本**（没有 dry-run，直接写入）：`asc versions create --app {App ID} --version <新版本> --platform IOS --copyright "© <年> <名字>" --release-type MANUAL --copy-metadata-from <上一版> --exclude-fields whatsNew`；要过审自动发布再 `asc versions update --version-id <ID> --release-type AFTER_APPROVAL`
3. **商店文字**：改 APPSTORE-LISTING → 生成 asc 用的 metadata 目录 → `ASC_READ_ONLY=1 asc metadata plan ... --dir <目录>` 看差异 → `asc metadata apply ... --confirm`
4. **截图**：每个语言 × 尺寸 `asc screenshots upload --app {App ID} --version <版本> --locale <L> --path <目录> --device-type IPHONE_67|IPHONE_61 --replace --confirm --concurrency 1`（先 `--dry-run`；`--concurrency 1` 才能保证顺序；苹果慢时会超时，用 `asc screenshots list` 对 MD5 查漏，缺的单张补传，别整组反复 replace）
5. **预览视频**（可选）：`asc video-previews upload ... --replace --confirm` → `set-poster-frame`（返回的时间码可能是旧的，用 list 复查）
6. **挂 build**：`asc versions attach-build --app {App ID} --version <新版本> --build-number <号>`
7. **送审**：先 `ASC_READ_ONLY=1 asc validate --app {App ID} --version <新版本> --platform IOS`，再 `asc review submit ... --confirm`（超时多时用 `--version-id` + `--build-id` + `ASC_TIMEOUT=300s`）；`asc review status --app {App ID}` 看状态；之后看邮件（`scripts/feedback-mail.sh`）
8. **过审后**：手动发布的 `asc versions release`（先问）；改销售地区 `asc pricing availability edit`（先问）

## 五、注意

- 隐私政策不能删或改路径（App 设置页和商店都链着它）
- 每次上传 TestFlight 前 `CURRENT_PROJECT_VERSION` +1；版本已上架（版本列车关闭）后再传必须升 `MARKETING_VERSION`
- 只传 TestFlight 给自己真机测、不送审，是常态：CHANGELOG 标「不送审」
