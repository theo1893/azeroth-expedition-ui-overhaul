# 仓库同步规则

本文件只说明工作流 Skill 如何落到仓库。权威制度仍是 `docs/WORKFLOW.md`、
`docs/ASSET_PIPELINE.md` 和 `docs/implementation/OVERHAUL_TRACKER.md`。

## 文件职责

| 内容 | 位置 | Git |
|---|---|---:|
| 综合色感／结构锁定图 | `assets/locked/<module>/` | tracked |
| 香草、pfUI、故障和结构参考 | `assets/references/<module>/` | tracked |
| 用户接受的透明母版 | `assets/source/<module>/<component>/` | tracked |
| raw、失败稿、透明候选、预演 | `generated/<module>/...` | ignored |
| 可执行且版本化的提示词 | `prompts/<module>/` | tracked |
| 运行时媒体 | `addon/AzerothExpeditionUI/Media/<Module>/` | tracked |
| 组件合同 | `docs/implementation/*_COMPONENT_SPEC.md` | tracked |
| 唯一进度事实 | `docs/implementation/OVERHAUL_TRACKER.md` | tracked |

`addon/` 只承载运行时文件与必须随包分发的许可证，不加入工作说明或 Markdown。

## 按操作同步

| 操作 | 必须同步 | 禁止 |
|---|---|---|
| `prepare` | 版本化提示词；组件合同；必要时 tracker | 写入 `generated/`、source 或 runtime |
| `generate` | 提示词执行记录；tracker 的会话／候选状态 | commit raw、失败稿或预演 |
| `review` | 提示词或 tracker 中的可复现证据与结论 | 用技术指标代替视觉结论 |
| `revise` | 新提示词版本；旧版本失败记录；tracker | 覆盖已执行正文 |
| `reject` | 版本、原因、日期、否决主体；tracker | 创建 source 或 runtime |
| `accept` | 透明母版；source manifest；提示词；组件合同；tracker | 把整张原型直接当 runtime |
| `export` | exporter；crop/UV manifest；runtime 媒体；Lua/XML；文档；tracker | 自由重绘可确定性导出结果 |
| `game-validate` | tracker 的场景、交互、版本和结论 | 无实机证据标 `P6` |
| `close` | 最终保留／删除清单；精简规范与 tracker；清理提交 | `P6` 前清理、宽泛路径删除或删除共享依赖 |

若结论改变跨模块视觉基线，再更新 `ART_DIRECTION.md` 或
`SESSION_DECISIONS.md`；不要把逐次操作流水复制到这些文件。

## `P6-C` 终态收口

`P6` 表示游戏内完全验收；`P6-C` 表示仓库已完成收口。收口前先形成精确清单，
逐项验证所有引用方，并让用户确认。清单本身是执行前审阅材料，不新增永久的
组件说明文档；执行结果压缩写入 tracker。

### 保留

- 最终执行／provenance 提示词，以及 source／runtime manifest 要求的必要
  会话、结果 ID、输入职责和校验值。
- 用户接受的透明 source、source manifest、最终 deterministic exporter、
  runtime 媒体、UV／crop manifest、Lua/XML 和测试。
- 最终组件合同、必要的模块视觉规则、最小 P6 实机证据和 tracker 终态行。
- 仍被其他组件引用的公共资产、工具、锁定基准、第三方来源、许可证和用户
  原始文件。

### 清理

- `generated/<module>/<component-or-batch>/` 内的 raw、失败候选、透明中间图、
  contact sheet、重组预演、debug 输出和临时 atlas。
- 已被最终 provenance 概括的 rejected／superseded prompt、执行尝试明细和
  临时审查记录。
- 只服务于该组件且已被最终 exporter 取代的实验脚本、故障参考和验收预演。
- 模块规范、组件合同、路线图、决策记录与 tracker 中重复的版本流水、过期
  下一步和过程叙述。

删除 tracked 文件时使用明确文件路径并保留 Git 历史；删除 ignored 本地输出
时只操作已验证的组件目录，优先使用可恢复的移入废纸篓方式。不得对
`generated/<module>/`、`assets/`、`prompts/` 或仓库根执行宽泛递归删除。

收口完成后，tracker 只保留最终 prompt/source/runtime、P6 证据、关闭日期和
`P6-C` 状态；没有“下一步”。所有 Markdown 链接、manifest 路径、exporter、
Lua/XML 和相关测试必须通过。

## Source manifest 最低字段

- schema/version；
- module、component/batch、accepted prompt version；
- source path、width、height、mode、SHA-256；
- Alpha／色键检查；
- 固定执行器版本、会话和结果 ID；
- 输入参考的仓库路径与职责；
- 用户接受日期；
- 逻辑对象和状态映射；
- 禁止的 runtime 用法；
- 预期 exporter／crop 合同是否仍待定。

## 提交与同步

1. 开始前检查工作树，保留用户的无关修改。
2. 每次状态变化把提示词、tracker、规范和 manifest 放在同一提交。
3. 提交前确认 `git status --ignored` 中 raw／预演仍被忽略。
4. 运行 `git diff --check`、仓库契约测试、Markdown 链接测试，以及受影响的
   exporter/Lua smoke test。
5. 提交信息指出模块、批次和状态变化，例如
   `assets: reject QL-A2 v1 candidate`。
6. 明确报告“仅本机生成”“已提交”“已同步到正式工作树”或“已推送”。除非
   用户要求，不自动 push。
7. `P6-C` 使用独立提交，例如 `chore: close QUEST.LOG.SHELL artifacts`，让
   删除范围可单独审阅和恢复。

## 回退

- 候选失败：保留记录，创建新版本；不删除现有已接受 source。
- runtime 失败：回退到该模块之前的安全 runtime 或香草 Frame；不改变
  非视觉功能、SavedVariables 或数据行为。
- 外部 provider 未知：停在 `P0–P2`，保留视觉方向但不生产假资产或空 adapter。
