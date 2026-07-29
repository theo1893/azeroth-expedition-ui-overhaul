# Prompt 存储与版本规则

所有可执行生图／修图提示词按模块保存在 `prompts/`，并由
[OVERHAUL_TRACKER.md](../implementation/OVERHAUL_TRACKER.md) 直接引用。

## 类型

- `prototype-only`：只用于锁定整体验证图和综合色感，不能直接导出运行时资源。
- `production-draft`：已经映射到明确组件 ID、对象数量和状态，但仍待用户
  确认；不得执行，也不能使组件进入 `P3`。
- `deferred-compatibility-draft`：只保留已锁定视觉方向与预拆分思路；实际
  provider、对象或交互合同尚未取得，因此不是可执行提示词。必须先完成外部
  插件映射并重写为 `production-draft`，不能直接生图或提升阶段。
- `production`：用户已确认、可以按指定执行块原样提交的组件级生产提示词。
- `provenance`：已经执行过、用于说明当前源资产来源的原始提示词；不得无版本
  覆盖。

## 执行要求

1. 使用 `.codex/skills/run-aeui-asset-workflow/SKILL.md` 编排完整生命周期，
   实际生图／修图只使用 `.codex/skills/imagegen-0-143-0/SKILL.md`。
2. 先依据项目基线把需求重写进版本化提示词文件。
3. 用户确认后，将文件中的最终提示词正文原样交给 `$imagegen`。
4. 记录固定执行器会话、结果、内部失败和执行器实际报告的 revised prompt；
   已执行正文不得原地覆盖。
5. 结果只写入被 Git 忽略的 `generated/`。
6. 候选先通过物件身份、物理结构、透视、图层、装配和技术审查；技术指标不
   等于综合色觉通过。
7. 用户明确确认具体透明母版后才进入 `assets/source/`。
8. 每次执行、退回、确认和路径变化同时更新 overhaul tracker。

## `P6-C` 收口

活跃生产期间保留每个已执行和被拒版本，禁止覆盖历史正文。组件达到 `P6` 后，
先把最终执行正文、实际 revised prompt、必要会话／结果 ID、输入职责和校验值
收敛到最终 provenance prompt 与 manifest。

用户确认精确清理清单后，可从当前树删除已被上述最终 provenance 概括的
`production-draft`、rejected／superseded prompt 和逐次审查记录；Git 历史
继续承担完整追溯。最终树只保留能解释 accepted source 和 runtime 的最终提示
词，不保留重复版本流水。
