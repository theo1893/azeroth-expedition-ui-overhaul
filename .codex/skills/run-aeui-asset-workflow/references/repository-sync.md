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

若结论改变跨模块视觉基线，再更新 `ART_DIRECTION.md` 或
`SESSION_DECISIONS.md`；不要把逐次操作流水复制到这些文件。

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

## 回退

- 候选失败：保留记录，创建新版本；不删除现有已接受 source。
- runtime 失败：回退到该模块之前的安全 runtime 或香草 Frame；不改变
  非视觉功能、SavedVariables 或数据行为。
- 外部 provider 未知：停在 `P0–P2`，保留视觉方向但不生产假资产或空 adapter。
