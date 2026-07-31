# 仓库同步与文档生命周期

本文件是项目资产工作流落到仓库的详细规则。普通项目文档不复制这些流程。

## 固定位置

| 内容 | 位置 | Git |
|---|---|---:|
| 全局美术 Prompt | `docs/GLOBAL_ART_BASELINE.md` | tracked |
| 主模块总览 | `docs/PROGRESS.md` | tracked |
| 真实子模块合同 | `docs/modules/<module>/SUBMODULES.md` | tracked |
| 主模块美术 Prompt | `docs/modules/<module>/ART_BASELINE.md` | tracked |
| 子模块稳定 Prompt | `docs/modules/<module>/SUBMODULE_ART_BASELINES.md` | tracked |
| 主模块详细状态 | `docs/modules/<module>/PROGRESS.md` | tracked |
| 未完成组件当前工作 | `docs/modules/<module>/work/<component>.md` | tracked until `P6-C` |
| 综合色感／结构锁定图 | `assets/locked/<module>/` | tracked |
| 结构／故障参考 | `assets/references/<module>/` | tracked only while required |
| 用户接受的透明母版 | `assets/source/<module>/<component>/` | tracked |
| 生成前模拟、raw、失败稿、透明候选、候选真实排版预演 | `generated/<module>/...` | ignored |
| 运行时媒体 | `addon/AzerothExpeditionUI/Media/<Module>/` | tracked |

`addon/` 只承载运行时文件与必须随包分发的许可证，不加入 Markdown。
仓库根 `README.md` 只介绍项目。文档索引与当前总体快照只放 `AGENTS.md`。

## 四份长期模块文档

一个主模块启动时必须同时建立：

1. `SUBMODULES.md`：严格对齐 pfUI／Blizzard／provider 的全部真实对象。
2. `ART_BASELINE.md`：继承全局 Prompt 的主模块唯一美术 Prompt。
3. `SUBMODULE_ART_BASELINES.md`：每个已定义子模块的稳定 Prompt 条款。
4. `PROGRESS.md`：资产、代码、测试、阶段与下一门禁。

不得新增路线图、决策日志、审计报告、媒体清单、文档索引或独立
`prompts/` 树。法律、第三方 `SOURCE.md`、许可证、JSON manifest 与 Skill
references 不属于项目说明文档。

## 单一组件 work

同一未完成组件或紧密耦合批次只保留一个 work 文件。它同时包含：

- 当前版本与子状态；
- 锁定图与 Prompt provenance；
- 真实组件合同；
- 生成前本地几何模拟的规格、脚本命令、输出证据、用户结论与文字化的可见
  方向；
- 自包含生产正文的紧凑完整性预检；
- 当前可执行正文；
- 执行与审查记录；
- 紧凑尝试摘要；
- 下一门禁。

首次生产执行前先提交用户授权的 work，使精确生产正文进入 Git 历史。本地
模拟可在提交前确定性渲染，但必须在展示时把版本规格、脚本命令、输出 SHA 与
内审结论写回同一 work。自主修复循环中，每次失败后在同一文件补齐执行／审查
记录和下一份完整 `.rN` 修复正文，并在下一次调用前提交。不要为模拟版本、
V1、V2、V3、每次 attempt、review、audit、preview 或 revised prompt 分别
建立永久 Markdown。

## 生成前模拟同步

- 正式资产生成前必须先产生一个可供用户确认的模拟实例图。它沿用真实 Frame
  比例、当前 accepted/runtime 邻接 UI、代表性对象数量与信息密度，但可以
  简化 Alpha、接缝、切片、独立状态和微纹理。
- 模拟规格、目标场景、真实对象数量、状态分布、简单几何与平面配色角色必须
  写入同一组件 work。使用本地确定性脚本直接渲染，不需要逐版本执行授权。
- 每个模拟版本的实际 ImageGen 固定为 `0/0`；不得上传参考图或启动 provider，
  也没有独立生图预算。本地脚本错误只作为普通渲染错误记录。
- 模拟输出固定写入
  `generated/<module>/<batch>/simulation/<version>/`，并记录 specification、
  脚本命令、Python 解释器、路径、SHA、ImageGen `0/0`、本地错误和内部可读性
  结论；不得 commit 图片本身。
- 用户确认具体模拟版本后，把可见布局、材质层级、轮廓、配色、视觉重量、
  整合关系与交互状态观感写回 work 的生产正文，再请求独立的正式生产授权。
- 模拟确认只接受方向，不接受像素。模拟图不得复制到 `assets/source/`，
  不得裁切、切片、导出为 runtime，也不得作为正式资产的 edit/reference
  输入。可见方向实质变化时必须创建并重新确认新的模拟版本。

## 五次自主修复同步

- 一个用户明确授权的执行正文最多产生固定 ImageGen `5` 次实际生图／修图，
  含首次。多段独立执行正文必须在授权前分别列出预算和最坏实际生图数。
- 每次实际生图使用独立的 ignored attempt 路径，例如
  `generated/<module>/<batch>/<version>/attempt-01/`；不得覆盖前次 raw、
  candidate、Alpha 中间图或重组预演。
- 第 1 次使用已提交的授权正文。第 2–5 次只能使用同一修复边界内的完整
  `.rN` 正文；提交中同时保存前次失败记录和下次执行正文。
- work 的循环表必须记录实际生图序号、正文／commit、session／result、
  输出 SHA、第一失败门禁、保留区域、edit／regenerate 决定和结论。
- 没有候选图且没有 provider 生成证据的目录、权限、CLI、递归、传输、上传、
  连接或落盘错误进入独立流程错误表，不占实际生图次数；记录错误证据与
  针对性修复后，以同一已提交正文重试。同一错误修复一次后仍重复则暂停诊断，
  不得无限重试。
- 中间失败只更新 work；模块 `PROGRESS.md` 在内部通过、第五次耗尽或出现
  需要新授权的边界阻塞时再同步，避免复制五份流水。
- 内部通过只达到 `candidate-reviewed / P3`。第五次仍失败才达到
  `candidate-rejected / repair-budget-exhausted`。两种情况都不得自动创建
  tracked source、manifest 或 runtime。

## 按操作同步

| 操作 | 必须同步 | 禁止 |
|---|---|---|
| `prepare` | 组件 work、自包含正文完整性预检；必要时 `SUBMODULES.md` 与模块进度 | 写 raw、source 或 runtime |
| `simulate` | 本地几何规格、可复现脚本命令、ImageGen `0/0`、work 执行证据、内部检查与用户方向结论 | 调用 ImageGen／上传参考图；把模拟当 source/runtime/生产输入；未确认模拟就进入生产 |
| `generate` | 已提交的授权正文／`.rN` 修复正文；work 实际生图与流程错误记录 | 超过五次实际生图；commit raw／失败图／预演 |
| `review` | 每次尝试的 work 审查证据；循环终态同步模块进度 | 用像素指标替代视觉结论 |
| `revise` | 同一 work 的尝试表、完整 `.rN` 正文与边界复核 | 丢失旧版本 Git 证据；用修复名义改变合同 |
| `reject` | work 的版本、原因、日期、主体；模块进度 | 创建 source 或 runtime |
| `accept` | source、manifest、work、子模块基线、模块进度 | 把完整原型直接当 runtime |
| `export` | exporter、UV/crop manifest、runtime、Lua/XML、tests、模块进度 | 自由重绘确定性导出结果 |
| `game-validate` | 模块进度的场景、版本、交互与结论 | 无实机证据标 `P6` |
| `close` | 精确保留／删除清单；四份长期文档与 manifest；清理提交 | `P6` 前清理或宽泛删除 |

主模块阶段变化时，同一提交同步 `docs/PROGRESS.md` 与 `AGENTS.md` 顶部快照。
只有跨模块美术基线真正改变时才更新 `docs/GLOBAL_ART_BASELINE.md`。

## `P6-C` 终态收口

`P6` 表示游戏内完全验收，`P6-C` 表示仓库完成收口。收口清单临时写在现有
work 中并交给用户确认，不创建新的 closure 文档。

保留：

- 最终稳定美术条款，凝结到 `SUBMODULE_ART_BASELINES.md`。
- 最终对象、状态、几何、UV 与回退，凝结到 `SUBMODULES.md` 和 manifest。
- 用户接受的 source、manifest、deterministic exporter、runtime、实现与 tests。
- 模块 `PROGRESS.md` 中最小的 P6 证据、最终路径、关闭日期和 `P6-C`。
- 仍被其他组件引用的锁定图、共享资产、工具、许可证和用户原始文件。

删除：

- 该组件 `generated/` 下的生成前模拟、raw、失败图、透明中间图、contact
  sheet、候选真实排版预演、debug 输出与临时 atlas。
- 该组件的 work 文件。
- 已被最终实现取代且仅服务该组件的实验脚本、故障参考与预演。
- 长期文档中重复的尝试流水、过期下一步和过程叙述。

删除 tracked 文件时使用明确路径，完整历史由 Git 保存。删除 ignored 输出时
只操作已验证的组件目录，优先移入废纸篓。不得对 `generated/<module>/`、
`assets/`、`docs/modules/` 或仓库根执行宽泛递归删除。

收口后该组件只出现在四份长期模块文档、最终 manifest、runtime、实现与
tests 中；`work/` 不保留空占位文件。

## Source manifest 最低字段

- schema/version；
- module、component/batch、accepted version；
- source path、width、height、mode、SHA-256；
- Alpha／色键检查；
- 固定执行器版本、会话和结果 ID；
- 锁定图、主模块／子模块 Prompt 路径与参考职责；
- 用户接受日期；
- 逻辑对象和状态映射；
- 禁止 runtime 用法；
- exporter／crop／UV 合同状态。

## 提交与同步

1. 开始前检查工作树并保留无关修改。
2. 本地模拟渲染后把 specification、命令、路径、SHA 和内审写入同一 work。
   每次生产实际生图前提交当前完整执行正文；无候选流程错误仍写入同一 work，
   修复后以同一正文重试；循环内候选失败只更新同一 work，循环终态再同步
   模块进度、manifest 或实现。
3. 确认 `generated/` 仍被忽略。
4. 先检测当前 OS，再运行 `git diff --check`、文档拓扑／链接测试、相关合同
   测试与 Lua smoke。macOS 必须使用 `conda run -n py312 python` 执行所有
   Python 脚本与 Skill validator，不得静默回退到系统 `python3`；Linux 使用
   活跃项目环境的 `python3`，Windows PowerShell 优先 `py -3`，否则使用活跃
   项目环境的 `python`。记录实际 `sys.executable` 与版本。
5. 提交信息指出模块、批次和状态变化。
6. 明确报告仅本机、已提交或已推送；除非用户要求，不自动 push。
7. `P6-C` 使用独立清理提交，便于审阅与恢复。

## 回退

- 候选失败：记录到 work，创建新版本；不动已接受 source。
- runtime 失败：回退到该模块之前的安全 runtime 或原生 Frame；不改
  SavedVariables、数据或非视觉功能。
- provider 未知：停在 `P0–P2`；不生产假资产或空 adapter。
