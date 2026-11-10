# {App名} · 原生实现方案

> 怎么实现：模块、数据、规则放哪、系统能力。和 [PRODUCTION.md](PRODUCTION.md) 的分层一致。

## 一、工程结构
```
ios/
  {App名}.xcodeproj
  {App名}/            App：Features/<屏>、Data/（Models + Schema + Store）、App/（入口、启动参数）、Resources/（PrivacyInfo、xcstrings）
  {App名}Kit/         Swift Package：Core（纯规则 + 测试）、DesignSystem（令牌、动效、组件）
  {App名}Tests/ · {App名}UITests/
  scripts/            ExportOptions.plist、截图 / 预览脚本
```

## 二、数据
- 存储：{SwiftData / …}；**版本化 Schema**（每发一版冻结一个 SchemaVn，迁移计划一段一段加，迁移测试用老库夹具）
- 打不开库时：不崩、不覆盖原文件（先重试、再兜底、实在不行内存库 + 提示）
- 备份格式：{JSON，带版本号；新字段可空；日期精度}

## 三、规则（Core）
| 规则 | 文件 | 测试 |
|---|---|---|

## 四、系统能力
（相机 / 通知 / 快捷指令 / 小组件 / iCloud——每个写清：要不要权限、联不联网、影响隐私标签和国区备案吗）

## 五、调试启动参数（只给出图 / 测试用）
| 参数 | 作用 | Debug / Release |
|---|---|---|
| `-resetDemo -demo` | 清库并放示例数据（虚构品牌） | |
| `-snapshot <屏>` | 直接进到某屏 | |
| `-empty` | 首次打开 | |
