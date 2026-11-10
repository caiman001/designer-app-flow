---
name: {app}-release
description: 发一个新 build 到 TestFlight（改 build 号、打包、上传、记版本日志）。只在用户输入 /{app}-release 时运行。
disable-model-invocation: true
---

# {App名} 发版

只有用户输入 `/{app}-release` 才跑（上传不可撤回）。**账号、密码、提交审核都由用户决定**，这里只做到上传 TestFlight 为止；送审走 `docs/APPSTORE.md` 第四节，每步单独问。

## 0. 先确认（任何一条不满足就停下问用户）
- 验收 agent `{app}-review` 和试用员 `{app}-qa` 对这次改动都给了「通过」（没有就先派它们跑，可以同时跑）；它「留着没修的」已写进 ROADMAP 并告诉用户
- `ios/` 下的改动用户已经同意提交；`git status` 里没有不该进包的东西
- 当前 build 号：`grep CURRENT_PROJECT_VERSION ios/{App名}.xcodeproj/project.pbxproj`
- 这个版本号是不是已经上架了（版本列车关闭）→ 是就要升 `MARKETING_VERSION`，先问用户

## 1. 验证
按 skill `{app}-verify-ios` 全部走一遍（测试 + 模拟器 Release + 核心路径截图）；Release 构建 0 警告。

## 2. 改 build 号
`CURRENT_PROJECT_VERSION` +1（**所有 target 一起改**，含扩展 / 小组件）；发新版本（不是新 build）时才改 `MARKETING_VERSION`，先问用户。

## 3. 打包上传（docs/APPSTORE.md 第三节）
```
cd ios && export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project {App名}.xcodeproj -scheme {App名} -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/archive/{App名}.xcarchive -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath build/archive/{App名}.xcarchive -exportOptionsPlist scripts/ExportOptions.plist \
  -exportPath build/export -allowProvisioningUpdates
```
- 失败先看 `LESSONS.md`「环境」「构建签名上传」；不许关代理、不许改用户的网络设置
- 上传成功的标志：输出里 `Upload succeeded` / `EXPORT SUCCEEDED`
- 报 403 `FORBIDDEN_ERROR.ROLE_NOT_VALID`：改走 APPSTORE 第三节「备用」（导出本地 IPA → `asc builds upload`）
- 报 ITMS-91053：隐私清单缺了某个 API 的理由，补 `PrivacyInfo.xcprivacy` 再传

## 4. 记录
- `docs/CHANGELOG.md`：「未发版」一节改成 `版本 (build) · 日期 时间 上传 TestFlight`，写怎么传的、验收结论、依据的画板 / 决定、已知问题、**真机要试**（skill `{app}-verify-ios` 第 6 节的清单）
- `docs/ROADMAP.md`：「真机要看的」加这个 build 要用户试的点
- 问用户后 commit 到 `{默认分支}`，再 `git push origin {默认分支}`（私有仓库备份）；**不推 `site`**（公开仓库只放网站）
- 提醒用户：TestFlight 处理完（约 10–30 分钟）后在手机上装；要送审的话按 APPSTORE 第四节，每步先问

## 5. 汇报
build 号、上传结果、CHANGELOG 摘要、**真机要试清单**（逐条、用户能看懂的话）、需要用户做的下一步。
