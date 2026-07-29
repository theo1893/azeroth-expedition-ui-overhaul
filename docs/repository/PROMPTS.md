# Prompt 存储与版本规则

所有可执行生图／修图提示词按模块保存在 `prompts/`，并由
[OVERHAUL_TRACKER.md](../implementation/OVERHAUL_TRACKER.md) 直接引用。

## 类型

- `prototype-only`：只用于锁定整体验证图和综合色感，不能直接导出运行时资源。
- `production`：已经映射到明确组件 ID、对象数量、状态和尺寸的生产提示词。
- `provenance`：已经执行过、用于说明当前源资产来源的原始提示词；不得无版本
  覆盖。

## 执行要求

1. 使用 `.codex/skills/imagegen-0-143-0/SKILL.md`。
2. 先依据项目基线把需求重写进版本化提示词文件。
3. 用户确认后，将文件中的最终提示词正文原样交给 `$imagegen`。
4. 结果只写入被 Git 忽略的 `generated/`。
5. 用户确认透明母版后才进入 `assets/source/`。
6. 每次执行、确认和路径变化同时更新 overhaul tracker。
