# Azeroth Expedition UI 项目入口

Codex 进入仓库后先读本文件。本文件同时承担项目级开发约束、文档索引和当前
状态快照；处理具体模块时，再按下方索引只读取该模块的四份长期文档与现存
`work/` 文件。

## 当前整体情况

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- 运行时由 `addon/pfUI/` 与 `addon/AzerothExpeditionUI/` 共同组成。
- pfUI 功能底座版本：`8.1.0`，来源提交
  `fbc8fb608b79adf32049543ec12fcc020e0acd69`；项目分支版本
  `8.1.0-aeui.3`，MIT 许可见 `addon/pfUI/LICENSE`。
- pfUI 提供数据、事件、交互、SavedVariables 与兼容能力；项目允许大规模
  重构视觉、布局和呈现连接，但不改写无关功能。
- 未完成最终替换的可见模块默认回退香草／Turtle WoW 原生 Frame；不得为了
  隐藏现代 pfUI 外观而破坏原生交互。

| 模块 | 当前状态 | 下一门禁 |
|---|---|---|
| pfUI／原生回退 | 路由与公共过渡材质 `P5`；模块 Initialize／Apply 已隔离失败，未实机 | Turtle WoW 全场景回归并确认单模块异常不会中断其他模块 |
| 聊天 | 核心 V3 runtime `1.7 / P5`；书本九宫格加入缺失／贴图剥离自愈；Chat Copy 与 URL Copy 均已暂缓；单一左框，右框隐藏 | Turtle WoW 重载后确认书本主体恢复，再验收核心批次 |
| 任务 | QL-A2 V4 书本主体保持；QL-B1 四态墨记继续运行，QL-B2 资产保留但隐藏。`pfQuest 7.0.1`／`pfQuest-turtle 7.0.2` 已完成源码审计。Quests runtime contract `1.8` 保留 Quest Log contract `1.7` 的 late-load／六控件兼容，并新增 pfQuest tracker 单块大纸面九宫格。用户已暂停 QT-B1 focus／tracked／complete 三件覆盖层（`1/5`），adapter 不挂载它们并隐藏现代半透明行矩形；QT-A2 其余工具美术仍为 provider fallback。QT-A1 当前为 `P5 runtime-exported-temporary / display-region-blocked`。`QS-A1` 共用漆章方向及 V2 Quest Log 外置锚点已确认；最终生产正文已按 `26px／32px` 可见蜡体与固定 Image 1／2 收紧，正式 ImageGen 仍为 `0/5` | 用户独立授权 `QS-A1 V1` 最终正文、固定输入、受限同循环 edit 与最多五次实际 ImageGen |
| 地图 | 大地图与小地图整体视觉 `P2` | 按真实 pfUI／Frame 对象完成组件合同 |
| 角色 | 香草同构整体视觉 `P2` | 实机测量并拆分装备槽、属性、页签与按钮 |
| 其他 UI | `P0–P1`，保持原生回退 | 逐模块建立四份长期文档 |

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
