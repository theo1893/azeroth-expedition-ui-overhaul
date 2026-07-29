# Azeroth Expedition UI 仓库约束

## 项目边界

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- `addon/pfUI/` 与 `addon/AzerothExpeditionUI/` 共同构成可测试运行时：
  前者是 pfUI 功能底座的项目维护分支，后者承载模块级替换与项目媒体。
- pfUI 是功能、数据和生命周期底座。允许在本插件内大规模重构其视觉层、
  布局层和呈现组件；不要求局限于简单换肤。
- `addon/pfUI/` 可以修改 UI、布局和与呈现直接相关的连接逻辑；不得借视觉
  重构之名改写自动售卖、物品操作、聊天事件、战斗数据、社交或兼容行为。
- 没有达到组件级 runtime 门槛的 pfUI 可见替换模块默认在加载前回退到
  香草／Turtle WoW 原生 Frame；不得为了隐藏现代界面而删除模块源码、改写
  非视觉 SavedVariables 或破坏原生交互。
- 上游版本与项目差异记录在 `docs/pfui/PFUI_UPSTREAM_SNAPSHOT.md` 和
  `docs/pfui/PFUI_FORK.md`。
- 复制或实质改写 pfUI 代码时，记录上游文件、提交和修改原因，并保留 MIT
  版权与许可声明。
- 每个模块必须能够独立启用、禁用并回退；局部兼容失败不能阻止整个插件加载。

架构边界见 `docs/ARCHITECTURE.md`。

## 文档位置与工作流

- `docs/README.md` 是项目文档的唯一入口，列出每份文档的职责。
- `docs/WORKFLOW.md` 规定不同变更必须同步更新哪些权威文件。
- `addon/` 只承载运行时代码、媒体与随包分发所必需的许可证，禁止新增
  `*.md`。
- 版本化生图提示词保留在 `prompts/`；第三方 `SOURCE.md`、许可证和校验凭据
  与对应文件共同保存。它们是生产输入／来源证据，不是散落的项目说明。
- 新增、移动或删除文档时，必须在同一提交更新 `docs/README.md`。

## 权威文件

发生冲突时，按以下优先级裁决：

1. `assets/locked/<module>/` 中用户确认的视觉基准。
2. `docs/modules/<module>/` 中对应模块规范。
3. `docs/ART_DIRECTION.md` 的跨模块规则。
4. `docs/implementation/<MODULE>_COMPONENT_SPEC.md` 中的组件与几何合同。
5. `assets/source/<module>/` 中已确认的透明母版。
6. `assets/references/` 中明确标注用途的结构或故障参考。

组件状态、资产来源、原始提示词和 runtime 路径以
`docs/implementation/OVERHAUL_TRACKER.md` 为唯一进度事实来源。任何状态变化
必须在同一 Git 提交中更新 tracker。

## 模块信息路由

`AGENTS.md` 只保存跨模块、长期稳定且代理必须始终遵守的约束，不记录单个模块
的当前版本、阶段、候选资产、否决历史、实现波次或下一步。

处理具体模块前，按职责读取：

| 信息 | 权威位置 |
|---|---|
| 当前阶段、资产、提示词、runtime 与下一步 | `docs/implementation/OVERHAUL_TRACKER.md` |
| 模块视觉语言与已锁定／弃用方向 | `docs/modules/<module>/`、`docs/DESIGN_STATUS.md` |
| 真实对象、状态、交互、几何与 provider 边界 | `docs/implementation/<MODULE>_COMPONENT_SPEC.md` |
| 当前 runtime 接入、媒体映射与 pfUI fork 差异 | `docs/runtime/`、`docs/pfui/` |
| 可执行正文、执行记录与失败 provenance | `prompts/<module>/` |
| 跨模块美术和长期决策 | `docs/ART_DIRECTION.md`、`docs/SESSION_DECISIONS.md` |

找不到对应权威文件时，按 `docs/WORKFLOW.md` 建立或补充文档；不得把临时模块
事实回填到本文件。

## 组件级资产

- 资产粒度必须与游戏内逻辑对象一致。
- 每个 Button、Tab、输入框、滚动条、状态条和图标槽都要分别定义对象、状态、
  点击几何、文字安全区和可拉伸区。
- 可以把多个逻辑资产打包到同一物理图集，但必须提供 manifest／UV 映射。
- 不得把真实按钮、状态、动态文字、图标、滚动条或固定槽位烘焙进整张背景。
- 生成前先完成 pfUI／原生 Frame 映射；找不到稳定对象时，不制作“看起来像”
  的假控件。
- 运行时 TGA 使用 32 位 RGBA、2 的幂画布，并给 UV 留出防渗色边距。
- 可再生预览、色键 raw、失败稿和调试图放在被 Git 忽略的 `generated/`，
  不进入 `assets/source/`。

完整流程见 `docs/ASSET_PIPELINE.md`。

## 资产工作流与固定执行器

处理组件资产的准备、生成、审查、修订、接受、退回、源资产晋级、runtime
导出或实机验收时，必须完整读取并使用：

```text
.codex/skills/run-aeui-asset-workflow/SKILL.md
```

所有实际位图生成和修图必须继续委托：

```text
.codex/skills/imagegen-0-143-0/SKILL.md
```

其固定实现为 `@openai/codex@0.143.0`；禁止改用会话内建 imagegen 或未确认
模型。详细步骤、状态机、提示词原文规则、Alpha 处理和仓库同步只在上述 Skill
与 `docs/ASSET_PIPELINE.md` 维护，本文件不复制第二份流程。

全局硬门禁仍然适用：

- “提示词已授权”“已生图”“内部审查通过”“用户接受”和“runtime 接入”是
  不同状态。
- 用户未明确接受具体候选时，不得写入 `assets/source/`。
- 没有真实 Frame／provider、crop／UV、状态映射和静态测试时，不得晋级
  `P5`。
- 没有 Turtle WoW `1.18.1` 实机证据时，不得晋级 `P6`。
- `P6` 后必须按工作流生成精确保留／删除清单；用户确认、清理和复测完成后
  才能标记 `P6-C`。不得提前或宽泛删除共享资产与过程材料。

## 运行时实现约束

- 不覆盖原生／上游事件分发、物品链接、战斗日志或其他数据行为入口。
- Hook 后不得在维护循环中持续改写 Parent、Point、Width 或 Height。
- 组件纹理缺失、pfUI 对象不存在或版本不匹配时，应局部降级并给出诊断。
- 只创建当前实现确实需要的代码和资源，不建立空壳模块。
- 修改后至少运行静态资源检查、脚本检查和已有 smoke test；只有目标客户端
  实机通过后才能标记 `P6`。
- 修改 pfUI 模块路由时必须同步测试 `IsModuleEnabled`／`IsSkinEnabled`，
  并确认被保留的非视觉功能与原生回退 Frame 没有被误关闭；具体模块回归项写
  入对应组件、runtime 或 pfUI 文档。
