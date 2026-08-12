# Azeroth Expedition UI 项目入口

Codex 进入仓库后先读本文件。本文件同时承担项目级开发约束、文档索引和当前
状态快照；处理具体模块时，再按下方索引只读取该模块的四份长期文档与现存
`work/` 文件。

## 当前整体情况

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- 运行时由 `addon/pfUI/` 与 `addon/AzerothExpeditionUI/` 共同组成。
- pfUI 功能底座版本：`8.1.0`，来源提交
  `fbc8fb608b79adf32049543ec12fcc020e0acd69`；项目分支版本
  `8.1.0-aeui.5`，MIT 许可见 `addon/pfUI/LICENSE`。
- pfUI 提供数据、事件、交互、SavedVariables 与兼容能力；项目允许大规模
  重构视觉、布局和呈现连接，但不改写无关功能。
- pfUI 默认接管全部模块、Blizzard skins 与配置页面；AEUI 只接管显式登记的
  Chat、Quest Log、Unit Frame fill donor、Raid 成员外壳与动态头像呈现。后续
  改造模块 A 时，只允许修改或路由 pfUI 的模块 A，不得通过公共绘制入口、
  全局回退或配置强写影响其他模块。

| 模块 | 当前状态 | 下一门禁 |
|---|---|---|
| pfUI／作用域接管 | scoped ownership `P5`；Expedition contract v6 新增 `unitframes.dynamic-portraits` 精确 route；pfUI 公共绘制、全部未接管模块与配置页已恢复；模块 Initialize／Apply 已隔离失败，未实机 | Turtle WoW 验证 pfUI 全模块、Game Menu／`/pfui`、旧 SavedVariables 迁移及 Chat／Quest Log／Unit Frames 隔离，含动态头像关闭与局部回退 |
| 聊天 | 核心 runtime `1.22 / P5`。Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入与 V3 未读已在 addon 内接入；V3 Tab／承托带保留为 P6-C 前回退。Dark V2 固定 source `ChatTabs_Dark_V2_A.png` SHA `616f965b…a1e3c` 已确定性导出为 `ChatTabAtlasDarkV2.tga` SHA `3fb505fa…be0` 与 `ChatTabShelfDarkV2.tga` SHA `44c7f85c…fda`；只清理 source 的 `13` 个和 LANCZOS 新增的 `23` 个低 Alpha 绿边 RGB，Alpha 不变，最终绿溢色 `0`。最终真实排版覆盖 6 场景、violations `0`，fresh-checkout package `pass`、目标设备无需构建。v1.22 继续透传客户端／pfUI／ChatMOD 经典颜色；Chat Copy／URL Copy 暂缓，右框及左右聊天信息 Panel 隐藏，小地图 Panel 保留；本次 P4→P5 ImageGen `0`，原生产仍为 `5/5`，attempt 6 禁止 | 游戏设备可用时 `/reload`，确认 `chat-runtime=1.22`、四态 Tab、五 Tab 压缩、承托带、缩放／拖动、经典颜色及输入行为；通过前不得标记 P6 或清理回退／证据 |
| 任务 | 用户于 `2026-08-05` 实机确认 Quest Log 左右页 bug 与显示问题已修复；该活动范围保持 `P6 user-confirmed`。QS-B1 V7-A 为 `P5`。QL-D V3 五次循环耗尽后，用户明确“使用第4稿”：以一次性 aspect 例外接受 exact canonical SHA `816aeedd…47c5`，原 keyed aspect `2.76945`／technical `18/19` 仍保留。正式四态 atlas SHA `cda1ef21…cd56` 已由 Quests `1.27`／Theme `1.10` 接入既有奖励适配层；atlas 与 0／1／2／4／6 真实排版均和已审阅第4稿像素完全一致，display `5/5 pass`。当前 `P5 runtime-exported / addon-integrated`。真实 Button／Tooltip／动态图标／文字和几何未替换。七枚独立功能纹章仍未验收，菜单不响应，旧 Blizzard／pfQuest 按钮继续 fail-open；Tracker 与 NPC Quest／Gossip 不变 | Turtle WoW 验证 QL-D TGA 方向、四态、pressed `1px`、safe area、双列排版和长详情滚动；不得第六次生图。另验证闭合态火漆跨压与滚动裁切；七纹章与代理 parity 完成后才可启用事务菜单或隐藏旧按钮 |
| 动作条／随身栏 | `AB.SLOT.BASE.V1` 与 `AB.RAIL` 均为 `P6 / game-validated`，固定生产 `5/5` 且禁止 attempt 6；Field Kit 视觉 runtime-v1.5／bridge-v2.8、Combat Focus runtime-v2.6 与 Sidebar Group runtime-v1.0 为 `P5 / pending-game-validation`。AEUI `0.8.26` 的 `ACTION-BARS-CORE-SIM-V11` 保留既有单位框、Aura、三条计时栈、系统字体、DoiteDPS 安全带与四栏 `2×2 / 3×4` 几何。`2026-08-12` 的 `1337×542` 实机证据（SHA `7af6c0de…c014`）否决 v2.7／v2.5：AutoBar 仍按活动 display 的自由坐标渲染，姿态虽已放大却以旧 `BOTTOM (0,255)` 压进主栏。bridge-v2.8 按 `AutoBar.display` 表身份解析实际活动配置，并把 provider 原生 docking 指向与主栏相对绑定、和 handle 等效缩放的全局代理 Frame；自由坐标只作可逆回退。focus runtime-v2.6／profile v17 保存安全 fallback `BOTTOM (0,130)`，live 始终以 `TOP → pfActionBarMain.BOTTOM / gap 12 UI` 绑定；覆盖 bars `UpdateConfig`、姿态／宠物事件、宠物显隐及 unlock 关闭，并隐藏姿态独立 mover。MoveAnything 已审计且不是这两个对象的写入者。全部位图字节不变，ImageGen `0/0` | `/reload` 后先确认卷袋立即位于主动作栏左侧、姿态栏位于主栏下方且留 `12 UI`；再连续两次 `/aeui autobar apply`、开关配置页、移动主栏、切换姿态、召唤／解散宠物及开关 pfUI unlock，均不得跳位。`/aeui status` 应含 `fieldkit-contract=2.8`、`focus-layout-contract=2.6`、`autobar-anchor-basis=provider-dock`、`autobar-provider-dock=bound`、`focus-layout-stance-anchor=main-bottom`、`focus-layout-stance-gap=12`。继续复测既有系统字体、Aura、Boss Debuff、计时栈、单 mover、四栏可逆 unbind、popup／Queue／换装；回退时 `/aeui focuslayout restore` 后 `/reload` |
| 地图 | 大地图与小地图整体视觉 `P2` | 按真实 pfUI／Frame 对象完成组件合同 |
| 角色 | 香草同构整体视觉 `P2`；用户于 `2026-08-08` 要求暂停 overhaul，现有锁定图、Prompt 与 pfUI 默认 runtime 原样保留 | 暂停；待用户明确恢复后再实机测量并拆分装备槽、属性、页签与按钮 |
| 单位框 | 动态头像 runtime `1.2 / P5 / pending-game-validation` 已把 13 组 pfUI UnitFrame 与两套 Raid Marker tracker 头像统一关闭；原值持久备份，pfUI 重施配置时保持关闭，模块／route 禁用时精确恢复。`UF-PRIMARY-V4-CANDIDATE-V1 / P4 / source-accepted` exact Player／Target pixels、B1 与 Raid A2 P5 媒体均未改动，ImageGen `0/0` | Turtle WoW `/reload` 验证 Player／Target／Focus／Party／Raid／Pet／各级 Target／fallback 与两套 tracker 无动态头像，`/pfui` 应用后不重新启用，并开关 `/aeui unitframes` 验证恢复；另先建立 Combat Focus `240×60` 与 V4 `214×42` 兼容合同，再执行 V4 P5；Raid／B1 等待 P6 |
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
- [当前 QL-D 奖励槽工作文件](docs/modules/quests/work/QUEST.LOG.REWARDS.md)
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

动作条／随身栏：

- [子模块与 pfUI／可选 provider 对齐](docs/modules/actionbars/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/actionbars/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/actionbars/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/actionbars/PROGRESS.md)
- [当前 AB.SLOT 基底 V1 工作文件](docs/modules/actionbars/work/ACTION.BARS.SLOT.V1.md)
- [当前 AB.RAIL V1 工作文件](docs/modules/actionbars/work/ACTION.BARS.RAIL.V1.md)
- [当前饰品／消耗品 Field Kit V1 工作文件](docs/modules/actionbars/work/ACTION.BARS.FIELDKIT.V1.md)
- [当前 Combat Focus／ArchiTotem 布局 V1 工作文件](docs/modules/actionbars/work/ACTION.BARS.FOCUS.V1.md)

单位框：

- [子模块与 pfUI 对齐](docs/modules/unitframes/SUBMODULES.md)
- [主模块美术基线 Prompt](docs/modules/unitframes/ART_BASELINE.md)
- [子模块美术基线 Prompt](docs/modules/unitframes/SUBMODULE_ART_BASELINES.md)
- [详细进度](docs/modules/unitframes/PROGRESS.md)
- [当前主单位框资源批次](docs/modules/unitframes/work/UNITFRAMES.CORE.md)
- [当前 Raid 团队框架批次](docs/modules/unitframes/work/UNITFRAMES.RAID.md)

`NOTICE.md`、第三方 `SOURCE.md`、许可证、JSON manifest 和 Skill
references 是法律、来源或机器契约，不属于项目说明文档，不在上表重复维护。
`README.md` 只介绍项目，不承载开发规则、资产状态或工作流。

`generated/` 是 ignored 本地中间区，不承担跨设备同步。只有下一门禁依赖同一
份像素时，才临时提交 `handoff/<module>/<component>/` 的最小检查点；其状态、
角色、大小、发布／恢复和清理规则只由资产工作流 Skill 定义。它不是文档树、
视觉权威、source 或 addon runtime，只能存在于短期协作分支，不能进入默认
分支历史。

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

用户明确验收一个冻结的整模块 P6 范围后，必须按 Skill 立即完成模块终局
收口：清空整个 `generated/<module>/`（tracked 与 ignored 均含）、
`handoff/<module>/`、全部该模块 `work/`，以及经审计属于该模块的 legacy
中间路径；只保留四份长期文档、最终 source／manifest、可直接安装的 addon
runtime／实现／tests、许可证／共享依赖和最小 P6 实机证据，并通过
`validate_module_closure.py` 后标记
`P6-C / module-closed`。整模块验收即为已验证模块专属中间数据的清理授权；
共享或归属不明路径不得删除。详细步骤只在 Skill 中维护。

新增主模块时一次性建立四份长期文档，并把索引与状态同时写入本文件和全局
进度。不得新增第二套路线图、决策日志、审计报告、媒体清单或独立 Prompt
目录。

## 开发边界

- 默认直接在 `main` 分支开发、提交并同步远端；不得自行创建或继续使用长期
  功能分支。只有用户明确要求隔离分支时才例外，结束后仍须按用户指示合回
  `main`。
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
- 任何 `P5` 导出都必须在当前开发设备完成 `addon/` 内的媒体、adapter、
  pfUI scoped bridge 与 TOC／bootstrap 接入，并通过 Skill 的 fresh-checkout
  addon package 门禁；另一台设备不得再生成资产、运行 exporter、应用补丁或
  修改代码，只需拉取并安装对应 addon 目录。
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

所有组件资产的准备、生成、审查、修订、接受、导出、实机验证、组件收口和
整模块验收后的中间数据清理，必须使用：

```text
.codex/skills/run-aeui-asset-workflow/SKILL.md
```

所有位图生成与修图必须继续委托：

```text
.codex/skills/imagegen-0-143-0/SKILL.md
```

固定执行实现为 `@openai/codex@0.143.0`；禁止改用会话内建 imagegen。
详细状态机、授权门禁、审查顺序、版本处理、跨设备 handoff、仓库同步与
`P6-C` 清理规则只在 Skill 中维护，本文件不复制流程。

任何代码或资产变更都要更新目标模块 `PROGRESS.md`；主模块阶段变化时再同步
全局 `docs/PROGRESS.md` 与本文件顶部快照。提交前运行受影响测试与
`git diff --check`。除非用户要求，不自动 push。
