# 文档与实现同步工作流

本工作流用于防止说明散落、状态重复和 addon 包含非运行时文档。开始任何
设计、资产或代码修改前，从 [文档中心](README.md) 找到对应权威文件。

## 存放规则

1. 项目说明统一放在 `docs/`，并登记到 `docs/README.md`。
2. `addon/` 只包含客户端运行文件、媒体和必须随包分发的许可证；禁止新增
   `*.md`。
3. 可执行图像提示词放在 `prompts/<module>/`，不复制进模块说明；tracker
   直接链接具体版本。
4. 生成结果、源资产和参考图分别进入 `generated/`、`assets/source/` 和
   `assets/references/`；资产目录不再放 README，清单写入 `docs/`。
5. 第三方许可证、固定来源和校验凭据可与第三方文件共存；项目层面的解释放在
   `docs/legal/`。
6. 代码局部实现细节写注释；只有需要跨文件、跨设备或跨会话理解的内容才进入
   文档。
7. 项目专属 Codex 工作流放在 `.codex/skills/`；固定模型执行器与资产生命
   周期编排分开维护，不把 Skill 说明复制到 `docs/`。
8. 根目录 `AGENTS.md` 只保存跨模块、长期稳定的执行约束和权威文件路由；
   模块版本、阶段、候选、否决记录和下一步必须留在对应规范、prompt 与
   tracker。

## 变更类型与权威文档

| 变更 | 必须更新 | 条件性更新 |
|---|---|---|
| pfUI 上游导入或 fork 修改 | `pfui/PFUI_UPSTREAM_SNAPSHOT.md` 或 `pfui/PFUI_FORK.md`；`implementation/OVERHAUL_TRACKER.md` | `ARCHITECTURE.md`、`SESSION_DECISIONS.md` |
| 加载顺序、依赖、模块路由或回退 | `ARCHITECTURE.md`；`implementation/OVERHAUL_TRACKER.md` | `runtime/AEUI_ADDON.md`、`pfui/PFUI_FORK.md` |
| 用户确认／否决整体视觉 | `DESIGN_STATUS.md`；对应 `modules/<module>/` 规范 | `ART_DIRECTION.md`、`SESSION_DECISIONS.md` |
| 组件拆分、状态或交互几何变化 | 对应 `implementation/*_COMPONENT_SPEC.md`；`implementation/OVERHAUL_TRACKER.md` | `implementation/IMPLEMENTATION_ROADMAP.md` |
| 生图／修图提示词变化 | `prompts/<module>/<version>.md`；`implementation/OVERHAUL_TRACKER.md` | 对应模块规范 |
| 资产生成／审查工作流变化 | `ASSET_PIPELINE.md`；对应 `.codex/skills/` | `SESSION_DECISIONS.md`、`AGENTS.md` |
| 源资产确认、切片或 runtime 媒体变化 | 对应 source／media 清单；组件合同；`implementation/OVERHAUL_TRACKER.md` | `ASSET_PIPELINE.md`、`repository/TOOLS.md` |
| `P6 → P6-C` 组件终态收口 | 最终 source／runtime manifest；组件合同；`implementation/OVERHAUL_TRACKER.md`；独立清理提交 | 模块规范、`SESSION_DECISIONS.md`、`repository/ASSETS.md`、`repository/PROMPTS.md` |
| 字体、许可证或第三方材料变化 | `legal/` 对应清单；`NOTICE.md`；校验凭据 | `implementation/FONT_SYSTEM.md` |
| Turtle WoW 实机验证 | `implementation/OVERHAUL_TRACKER.md` 的验证记录和阶段 | 发现偏差时更新实现说明、模块规范或决策记录 |
| 新增、移动或删除文档 | `docs/README.md` | `AGENTS.md`、根 `README.md` |

表中的相对路径均以 `docs/` 为根。

## 单次变更流程

1. 从 `docs/README.md` 确认唯一权威文档和当前 tracker 状态。
2. 资产生命周期变更先加载
   [项目级编排 Skill](../.codex/skills/run-aeui-asset-workflow/SKILL.md)；再读取
   相关模块规范、组件合同、runtime／pfUI 说明和原始提示词。
3. 修改代码或资产；不要先在 addon 目录新增临时说明。
4. 在同一提交更新 tracker，以及上表要求的权威文档。
5. 若新增文档，在 `docs/README.md` 写明唯一职责和更新时机。
6. 运行仓库契约、Markdown 链接、Lua 语法和相关 smoke test。
7. 只有目标客户端实机通过后，才把组件从 `P5` 提升到 `P6`。
8. `P6` 后按资产工作流生成精确保留／删除清单；用户确认、清理中间产物并
   复测后，使用独立提交提升为 `P6-C`。

## 去重与生命周期

- `OVERHAUL_TRACKER.md` 是进度、文件来源和验证阶段的唯一事实来源；其他文档
  只解释规则和设计，不维护第二份进度表。
- `DESIGN_STATUS.md` 只记录方案是否被确认或弃用；详细视觉要求留在模块规范。
- `SESSION_DECISIONS.md` 只保留会影响未来工作的决策，不当作逐次操作日志。
- `PFUI_FORK.md` 只记录相对上游的维护差异；上游原文放在归档，不混入项目
  当前说明。
- `AGENTS.md` 只声明代理必须始终遵守的全局规则，不复制聊天、任务或其他
  模块的当前状态；代理按其中的路由读取对应权威文件。
- `P6-C` 收口时删除当前树中的过程性冗余，Git 历史承担历史追溯；最终树只
  保留维护、再生、运行和验收仍必需的文件。
- 文档失去唯一职责时，应合并到权威文件并删除旧文件，不能留下“已弃用”
  空壳。

## 提交前检查

- `addon/` 下没有 `*.md`。
- `docs/README.md` 能导航到每一份项目说明。
- 所有相对链接有效。
- 新组件在 tracker 中有稳定 ID、资产、提示词、runtime 和下一步。
- 资产状态没有把“生成完成”“内部审查”“用户接受”“runtime 接入”混为一项。
- `AGENTS.md` 没有新增任何模块当前版本、阶段、候选或下一步。
- `P6-C` 组件没有残留 raw、失败候选、预演、临时 atlas、过时 prompt 或
  重复过程叙述，且没有删除共享依赖。
- 代码行为、TOC 版本、runtime 媒体清单与文档描述一致。
- 实机未验证的内容没有标记为 `P6`。
