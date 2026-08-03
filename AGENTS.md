# Azeroth Expedition UI 项目入口

Codex 进入仓库后先读本文件。本文件同时承担项目级开发约束、文档索引和当前
状态快照；处理具体模块时，再按下方索引只读取该模块的四份长期文档与现存
`work/` 文件。

## 当前整体情况

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- 运行时由 `addon/pfUI/` 与 `addon/AzerothExpeditionUI/` 共同组成。
- pfUI 功能底座版本：`8.1.0`，来源提交
  `fbc8fb608b79adf32049543ec12fcc020e0acd69`；项目分支版本
  `8.1.0-aeui.4`，MIT 许可见 `addon/pfUI/LICENSE`。
- pfUI 提供数据、事件、交互、SavedVariables 与兼容能力；项目允许大规模
  重构视觉、布局和呈现连接，但不改写无关功能。
- pfUI 默认接管全部模块、Blizzard skins 与配置页面；AEUI 只接管显式登记的
  Chat 与 Quest Log。后续改造模块 A 时，只允许修改或路由 pfUI 的模块 A，
  不得通过公共绘制入口、全局回退或配置强写影响其他模块。

| 模块 | 当前状态 | 下一门禁 |
|---|---|---|
| pfUI／作用域接管 | scoped ownership `P5`；pfUI 公共绘制、全部未接管模块与配置页已恢复；模块 Initialize／Apply 已隔离失败，未实机 | Turtle WoW 验证 pfUI 全模块、Game Menu／`/pfui`、旧 SavedVariables 迁移及 Chat／Quest Log 隔离 |
| 聊天 | Full V1 runtime `1.19 / P5` 保持；正式仍复用 V3 Tab／输入／未读。`CHAT.INPUT.DARK.V1` 已实际生成 `2/5`，流程错误 `4`。attempt 2 移除了缝线、皮革卷和长导线，保留薄页叠与右侧纸角；共享 Alpha、真实 `380×25/480×25` 排版及五场景 display-region 再次通过。但整段中心仍是重复卷曲压纹，纸面继续偏压花皮革，focus 还有连续橙金上缘，因此内部未通过。完整 `.r2` 只保留当前两态轮廓、薄页叠、纸角和暗色顺序，使用紧邻 attempt 2 作为 Image 4 edit；runtime 改动仍为 `0`。Chat Copy／URL Copy 暂缓；右框及左右聊天信息 Panel 隐藏，小地图 Panel 保留 | 提交 `.r2` 后执行 attempt 3，重点复核低频纸纤维和非连续 focus 高光；内部通过后交用户接受。游戏设备可用时再 `/reload` 验证核心 r1.19 |
| 任务 | QL-A2 V4 书本主体保持；Quests `1.16`／Quest Visual Theme `1.5` 将左页恢复为 18 个 `246 × 18px` 活动行，全部任务／完成／地下城文字统一为 `12px` 霞鹜文楷、无描边和 shadow；行末追踪圈及左右页 scrollbar chrome 隐藏，两个真实 ScrollFrame 保留并支持滚轮。Quest Log 与 Tracker 共用一套高对比深墨难度色；任务类型使用深紫墨，完成／失败使用独立深绿／深红，模板拆分 FontString 与标题后的内联色码均由 adapter 归一化。Tracker 仍整批提交主题、宽度及 `16px` 底部安全区，左侧 `button.icon` 隐藏且旧统一字体保留。QL-B2 资产保留但隐藏；QT-A1 仍为 `P5 runtime-exported-temporary / display-region-blocked`，旧七工具按钮可见可用 | Turtle WoW `/reload` 验证左页深墨对比、五档难度辨识和任务类型不再荧黄，并比较同一任务在日志／Tracker 的颜色；再连续接受／放弃任务验证批次稳定 |
| 地图 | 大地图与小地图整体视觉 `P2` | 按真实 pfUI／Frame 对象完成组件合同 |
| 角色 | 香草同构整体视觉 `P2` | 实机测量并拆分装备槽、属性、页签与按钮 |
| 其他 UI | `P0–P2`，保持 pfUI 默认实现 | 逐模块建立四份长期文档，并仅登记目标模块的接管路由 |

全量模块状态以 [docs/PROGRESS.md](docs/PROGRESS.md) 为准。

## 唯一文档结构与索引

长期项目文档只允许以下类型：

```text
docs/
  GLOBAL_ART_BASELINE.md
  PROGRESS.md
  modules/<module>/
    SUBMODULES.md
    ART_BASELINE.md
    SUBMODULE_ART_BASELINES.md
    PROGRESS.md
    work/                         # 仅未完成组件可存在
```

全局：

- [全局美术基线 Prompt](docs/GLOBAL_ART_BASELINE.md)
- [模块整体进度](docs/PROGRESS.md)

聊天：

- [子模块与 pfUI 对齐](docs/modules/chat/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/chat/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/chat/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/chat/PROGRESS.md)
- [当前核心 V3 工作文件](docs/modules/chat/work/CHAT.CORE.V3.md)
- [已暂缓的 Chat Copy V1.3 工作文件](docs/modules/chat/work/CHAT.COPY.V1.md)
- [已暂缓的 URL Copy V1 工作文件](docs/modules/chat/work/CHAT.URLCOPY.V1.md)

任务：

- [子模块与 pfUI 对齐](docs/modules/quests/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/quests/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/quests/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/quests/PROGRESS.md)
- [当前 QL-A2 工作文件](docs/modules/quests/work/QUEST.LOG.GUTTER.md)
- [当前 QL-B0 左页 V2 工作文件](docs/modules/quests/work/QUEST.LOG.LEFTPAGE.md)
- [当前 QL-B1 目录墨记工作文件](docs/modules/quests/work/QUEST.LOG.DIRECTORY.md)
- [当前 QL-B2 选择书签工作文件](docs/modules/quests/work/QUEST.LOG.SELECTION.md)
- [当前 QL-B3 类型／计时／状态章工作文件](docs/modules/quests/work/QUEST.LOG.STATUS.md)
- [当前 pfQuest Tracker 核心工作文件](docs/modules/quests/work/QUEST.TRACKER.CORE.md)
- [当前 Quest Log／Tracker 共用漆章工作文件](docs/modules/quests/work/QUEST.SEALS.md)

地图：

- [子模块与 pfUI 对齐](docs/modules/map/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/map/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/map/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/map/PROGRESS.md)

角色：

- [子模块与 pfUI 对齐](docs/modules/character/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/character/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/character/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/character/PROGRESS.md)

`NOTICE.md`、第三方 `SOURCE.md`、许可证、JSON manifest 和 Skill
references 是法律、来源或机器契约，不属于项目说明文档，不在上表重复维护。
`README.md` 只介绍项目，不承载开发规则、资产状态或工作流。

## 文档职责

- `GLOBAL_ART_BASELINE.md`：唯一跨模块美术 Prompt；包含时代语言、材料、
  配色、字体、反模式和组件级转译原则。
- `PROGRESS.md`：只记录各主模块的阶段、当前结论和下一门禁。
- `SUBMODULES.md`：该主模块所有真实子模块、pfUI 文件、原生 Frame、逻辑
  ID、状态与功能所有权；不写生产过程。
- `ART_BASELINE.md`：该主模块唯一美术基线 Prompt，必须显式继承全局 Prompt。
- `SUBMODULE_ART_BASELINES.md`：每个真实子模块的稳定 Prompt 条款，必须继承
  主模块 Prompt，不能记录逐次失败流水。
- `PROGRESS.md`：该主模块的资产、代码、测试、阶段和下一步唯一详细事实。
- `work/*.md`：尚未完成组件的当前合同、当前可执行 Prompt、尝试摘要与审查
  记录。组件达到 `P6-C` 后必须删除；历史由 Git 保存。

新增主模块时一次性建立四份长期文档，并把索引与状态同时写入本文件和全局
进度。不得新增第二套路线图、决策日志、审计报告、媒体清单或独立 Prompt
目录。

## 开发边界

- `addon/` 只承载运行时代码、媒体和分发必需许可证，不放 Markdown。
- `addon/pfUI/` 可修改公共绘制入口、布局与呈现连接；自动售卖、物品操作、
  聊天事件、战斗数据、社交与平台兼容等非视觉行为保持不变。
- `addon/AzerothExpeditionUI/` 承载项目 adapter、replacement、extension
  和媒体；只在真实模块需要时创建文件，不建立空壳。
- 运行时所有权采用白名单：未登记对象一律由 pfUI 正常加载。改造模块 A 时，
  只允许把模块 A 的具体 pfUI module／skin 加入接管清单；不得按“未完成”、
  “现代外观”或模块类别批量停用其他 pfUI 组件。
- pfUI 公共 `CreateBackdrop`、默认 profile、Game Menu 与 `gui` 不得承载
  模块专属视觉。Chat／Quest 等视觉只在各自 pfUI 文件或 AEUI adapter 内
  接入；若必须修改公共 API，必须证明对未接管模块的输出完全不变。
- 每个模块必须可独立启用、禁用和回退。对象缺失或媒体失败时局部回退原生，
  不能阻止整个插件加载。
- Hook 后不得在维护循环中持续改写 Parent、Point、Width 或 Height。
- 上游 pfUI 初始测试基线包含本机已有的 `pfUI.lua` 与 `libs/libtotem.lua`
  修改；嵌套 `.git` 未纳入。后续实质改写必须保留 MIT 版权和来源。

## 视觉与组件权威

发生冲突时按以下顺序裁决：

1. `assets/locked/<module>/` 中用户锁定的图，以及对应模块
   `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md` 中的 Prompt。
2. `docs/GLOBAL_ART_BASELINE.md`。
3. 模块 `SUBMODULES.md` 对真实对象、几何、状态、层序和禁止烘焙的合同。
4. `assets/source/<module>/` 中用户接受的透明母版及 manifest。
5. `assets/references/` 中明确声明用途的结构参考。

锁定图与 Prompt 共同定义物件身份、轮廓、材料关系、配色、笔触、光照、
磨损和反模式。组件合同负责把完整原型过滤成可运行对象，但不能改写其美术
DNA。派生 source 只能承担声明过的结构或材料职责，不能反向成为最高视觉
权威。

资产粒度必须与游戏逻辑对象一致。每个 Button、Tab、输入框、滚动条、状态条、
图标槽和独立交互状态都要单独定义；允许共用物理图集，但必须有 manifest／UV。
不得把动态文字、图标、状态或真实按钮烘焙进整张背景。找不到稳定的 pfUI、
Blizzard 或外部 provider 对象时，不生产“看起来像”的假控件。

## 工作流入口

所有组件资产的准备、生成、审查、修订、接受、导出、实机验证和完成后清理，
必须使用：

```text
.codex/skills/run-aeui-asset-workflow/SKILL.md
```

所有位图生成与修图必须继续委托：

```text
.codex/skills/imagegen-0-143-0/SKILL.md
```

固定执行实现为 `@openai/codex@0.143.0`；禁止改用会话内建 imagegen。
详细状态机、授权门禁、审查顺序、版本处理、仓库同步与 `P6-C` 清理规则只在
Skill 中维护，本文件不复制流程。

任何代码或资产变更都要更新目标模块 `PROGRESS.md`；主模块阶段变化时再同步
全局 `docs/PROGRESS.md` 与本文件顶部快照。提交前运行受影响测试与
`git diff --check`。除非用户要求，不自动 push。
