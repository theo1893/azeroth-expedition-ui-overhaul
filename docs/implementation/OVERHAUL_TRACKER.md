# UI 改造进度总表

## 维护规则

这是跨设备同步的唯一进度表。任何组件的结构、资产、提示词、runtime 文件或
验证状态发生变化时，必须在同一 Git 提交中更新本文件。

阶段定义：

| 阶段 | 含义 |
|---|---|
| `P0` | 尚未拆分 |
| `P1` | 已映射 pfUI／原生组件 |
| `P2` | 顶层美术与结构已锁定 |
| `P3` | 组件级生产提示词已确认 |
| `P4` | 透明源资产已确认 |
| `P5` | runtime 已接入并通过静态测试 |
| `P6` | Turtle WoW 实机验收通过 |
| `N/A` | 无视觉资产，仅复用功能 |

“整张视觉原型”只能使模块达到 `P2`。只有每个按钮、状态和可拉伸部件均已
映射，才允许进入 `P3`。

`P2 visual／P0 compat` 表示综合色感已锁定，但外部 provider 尚未取得，
不能据此生产资产或实现 runtime。

表中的 `—` 表示当前没有可登记的文件，不是路径占位符。已有文件必须写成
仓库内的直接链接，不使用“同上”；未来新增资产或提示词时应先补路径，再提升
阶段。

表中同时列有“组件族”和尚未展开的父级工作包。一个行若包含多个拥有独立
点击、状态或几何的对象，只能停留在 `P0–P2`，并且不能直接拥有生产提示词。
进入 `P3` 前必须增加稳定的子组件 ID 行，逐项记录状态与资产；只有几何和状态
完全相同的重复实例才允许共用同一资产或图集。

## 当前总览

| 模块 | 当前结论 | 下一道门 |
|---|---|---|
| pfUI 基础 | 可安装维护分支已迁入 `addon/pfUI`；现代可见模块默认回退香草呈现，路由达到 `P5` | Turtle WoW 实机核对原生 Frame 未被隐藏，再逐模块替换 |
| 聊天 | V3 主框／Tab／输入／未读母版达到 `P4`；legacy 信息底栏已退役 | 复核五张 V3 exporter、UV 和 Lua，再做实机迁移 |
| 任务 | `QL-A1` 空卷宗透明源母版达到 `P4`；追踪器仅保留 `P2` 视觉，外部 provider 兼容为 `P0` | 单独确认 `QL-A2` 可拉伸部件；追踪器等待外部插件源码 |
| 地图 | 大地图／小地图视觉达到 `P2` | 清点 WorldMap 与 Minimap 按钮、遮罩、缩放、插件图标 |
| 角色 | 香草纸娃娃视觉达到 `P2` | 清点装备槽、Tab、旋转、属性、关闭按钮状态 |
| 其他 | `P0–P1` | 按表中顺序完成结构截图与组件合同 |

## 验证记录

| 日期 | 范围 | 结果 | 证据／限制 |
|---|---|---|---|
| `2026-07-29` | `QL-A1` 空卷宗源母版 | 离线技术检查与用户视觉复审通过；达到 `P4` | 固定 `imagegen-0-143-0` 生成会话 `019fac35-620b-78d3-8b46-2e1f02105f74`；[`QuestLogBookShell_Master_v1.png`](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 为 `1514 × 1039` RGBA，透明／半透明／不透明像素为 `241402／5650／1325994`，可见绿色残留 `0`；[`manifest`](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json) 锁定 SHA-256 与来源。无文字、任务行、按钮、滚动条或奖励槽。接近等宽的物理双页已经接受，`42%／58%` 继续作为 runtime 左／右阅读安全区目标；整张源图不得进入 runtime |
| `2026-07-29` | 任务模块范围收敛 | 通过静态检查 | [`QUEST_COMPONENT_SPEC.md`](QUEST_COMPONENT_SPEC.md) 保留 Quest Log 对象合同和 questitem 行为；原生 QuestWatch provider 假设已撤销，外部追踪插件待后续审计；`QL-A1` 已确认，下一道门为单独确认 `QL-A2` |
| `2026-07-29` | 文档信息架构 | 通过静态测试 | 项目说明集中到 `docs/`；`addon/` 无 Markdown；文档中心逐项索引且相对链接通过仓库契约测试 |
| `2026-07-29` | 仓库结构 | 通过 | Markdown 相对链接、Git whitespace、runtime 媒体引用均通过静态检查 |
| `2026-07-29` | 聊天 0.4.1 legacy | 通过静态测试 | [`chat_module_smoke.lua`](../../tests/chat_module_smoke.lua) 验证旧书、Tab、输入、legacy panel 隐藏与 native-first 状态诊断；不等于目标客户端实机 |
| `2026-07-29` | 聊天 V3 源资产 | 通过离线验证 | 三张母版尺寸与 RGBA Alpha 通过；[`build_chat_v3_layout_preview.py`](../../tools/build_chat_v3_layout_preview.py) 和 [`build_chat_v3_runtime_assets.py`](../../tools/build_chat_v3_runtime_assets.py) 在临时目录成功运行；runtime 仍未接入 |
| `2026-07-29` | 字体文件 | 校验通过 | [`MANIFEST.sha256`](../../third-party/fonts/MANIFEST.sha256) 三项匹配；Turtle WoW 字体加载仍待实机 |
| `2026-07-29` | pfUI 维护分支与视觉合同 | 通过静态测试 | [`pfui_expedition_contract_test.lua`](../../tests/pfui_expedition_contract_test.lua) 验证非透明材质配置、香草状态条、成对狮鹫、legacy panel 退役及非视觉配置保持；尚未实机 |
| `2026-07-29` | pfUI 香草回退路由 | 通过静态测试 | 动作条、导航、单位框、战斗 HUD、背包／拾取、system surfaces 与全部 Blizzard skin 按组跳过；聊天和非呈现功能保留；`turtle-wow.lua` 不再误隐藏原生团队框；尚未实机 |
| `2026-07-29` | 聊天无信息底栏资源链 | 通过离线验证 | V3 exporter 只产出五张图集，legacy builder 只产出六张资源；普通／聚焦预演无三联 panel；Pillow 12.0.0 smoke 通过 |

## 运行时路由矩阵

本表记录“当前测试包会实际加载什么”，不提升下方组件的最终美术阶段。原生
回退表示组件仍需后续重绘，不是已经完成 overhaul。

| 路由组 | 当前 pfUI 模块 | 当前结果 | 保留边界 |
|---|---|---|---|
| `action_bars` | `actionbar`、`gryphons`、`hunterbar`、`hoverbind` | 不加载 pfUI 呈现；显示原生动作条与双头狮鹫 | 原生按钮、快捷键、姿态和宠物条 |
| `chat` | `chat` | 加载，供 `AzerothExpeditionUI` 旧书 adapter 使用 | 聊天事件、停靠、输入、历史、Tab 点击 |
| `chat_auxiliary` | `whisperproxy`、`chatcopy`、`bubbles` | 暂不加载未换肤的附属呈现 | 原生聊天气泡；附属功能待组件化后恢复 |
| `navigation` | `minimap`、`tracking`、`farmmode`、`addonbuttons`、`map*` | 不加载 pfUI 呈现；显示原生地图／小地图 | 原生地图内容、缩放、追踪与插件按钮 |
| `unit_frames` | `player`、`target`、`focus`、`targettarget*`、`pet*`、`group`、`raid`、`mouseover`、`uf_tukui` | 不加载 pfUI 呈现；显示原生／Turtle WoW 单位与团队框 | Turtle WoW 兼容模块继续加载，但不得隐藏原生团队框 |
| `combat_hud` | `castbar`、计时器、Buff、Totem、姓名板、经验条等 | 不加载 pfUI 呈现；使用客户端原生组件 | pfUI 战斗数据库与平台兼容继续可供未来模块复用 |
| `inventory_and_loot` | `bags`、`itemclick`、`unusable`、`cooldown`、`loot`、`roll` | 不加载 pfUI 呈现；显示原生背包／拾取／Roll | 原生物品操作；自动售卖、修理、售价与任务物品功能另行保留 |
| `system_surfaces` | `skin`、`tooltip`、`panel`、`addons`、`firstrun`、`thirdparty*`、`bgscore`、`easteregg`、`afkcam`、`addoncompat` | 不加载未重绘可见层；全部 Blizzard skin 也跳过 | `/pfui`、`unlock`、`share` 作为维护工具保留并走非透明公共材质 |
| `behavior` | `autoshift`、`autovendor`、`questitem`、`sellvalue`、`eqcompare`、`socialmod`、`macrotweak`、`turtle-wow`、`superwow` 等 | 正常加载 | 不因视觉回退改写对应数据、事件或用户开关 |

## 组件级改造表

| ID | 游戏内组件 | pfUI／原生基础 | 方式 | 阶段 | 源资产／视觉基准 | 原始生产提示词 | runtime／验证 | 下一步 |
|---|---|---|---|---|---|---|---|---|
| `CORE.PFUI.FORK` | 可独立安装的 pfUI 功能底座 | pfUI `8.1.0` | fork | `P5` | [上游基线](../pfui/PFUI_UPSTREAM_SNAPSHOT.md) | N/A | [维护分支清单](../pfui/PFUI_FORK.md)；静态测试 | Turtle WoW 加载、SavedVariables 与第三方兼容回归 |
| `CORE.NATIVE.FALLBACK` | 未完成组件的香草／Turtle WoW 原生呈现路由 | `pfUI:LoadModule`／`LoadSkin` | adapter | `P5` | 客户端原生 Frame；无仓库位图 | N/A（加载路由，不生产资产） | [expedition.lua](../../addon/pfUI/api/expedition.lua)、[pfUI.lua](../../addon/pfUI/pfUI.lua)、[turtle-wow.lua](../../addon/pfUI/modules/turtle-wow.lua)；静态测试 | 实机验证动作条、团队、背包、拾取、地图和所有系统窗口 |
| `CORE.SURFACE` | 大型窗口、紧凑框体、边缘与阴影公共基线 | `pfUI.api.CreateBackdrop` | refactor | `P5` compatibility baseline | [统一美术方向](../ART_DIRECTION.md)；香草内置 Dialog／Tooltip 材质 | N/A（使用客户端内置材质） | [expedition.lua](../../addon/pfUI/api/expedition.lua)、[api.lua](../../addon/pfUI/api/api.lua)；当前用于维护工具与显式 opt-in 模块 | 主城／副本／团本逐窗口实机审计；最终资产仍按组件拆分 |
| `CORE.STATUS` | 血量、能量、施法及其他状态条过渡材质 | pfUI status texture 配置 | adapter | `P5` compatibility baseline | 香草内置 `UI-StatusBar` | N/A（使用客户端内置材质） | [expedition.lua](../../addon/pfUI/api/expedition.lua)；默认香草回退时不接管原生状态条 | 为单位框、团队、施法条分别建立端帽／背景／填充合同 |
| `CORE.MEDIA` | 媒体注册与回退 | `pfUI.api`、插件路径 | extension | `P1` | [字体媒体](../runtime/FONT_MEDIA.md) | — | [Bootstrap.lua](../../addon/AzerothExpeditionUI/Core/Bootstrap.lua) | 建立 MediaRegistry 和缺失回退 |
| `CORE.9SLICE` | 九宫格容器 | Vanilla Texture API | extension | `P1` | [聊天组件合同](CHAT_COMPONENT_SPEC.md) | — | [Chat.lua](../../addon/AzerothExpeditionUI/Modules/Chat.lua) 内部实现 | 抽成共用组件并锁 UV manifest |
| `CORE.3SLICE` | 三段式按钮／Tab／输入条 | Vanilla Texture API | extension | `P1` | [V3 Tab 母版](../../assets/source/chat/v3/ChatTabs_Master_v3.png)；[V3 控件母版](../../assets/source/chat/v3/ChatControls_Master_v3.png) | [V3 原始提示词](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md) | 尚未共用 | 建立端帽／中央段工厂 |
| `CORE.BUTTON` | 普通／悬停／按下／禁用按钮 | pfUI widgets | refactor | `P1` | [美术方向](../ART_DIRECTION.md) | 待按组件编写 | — | 定义统一状态合同 |
| `CORE.TAB` | 普通／悬停／选中／禁用 Tab | pfUI／Blizzard Tab | refactor | `P1` | 聊天 V3 Tab | 待按模块编写 | — | 定义统一点击几何 |
| `CORE.SCROLL` | 轨道、滑块、上下按钮 | pfUI skins | refactor | `P1` | — | — | — | 建立首个真实模块样例 |
| `CORE.ICON` | 图标槽、品质边、冷却、计数 | pfUI actionbar／bags | refactor | `P1` | — | — | — | 与动作条、背包共同定义 |
| `CORE.FONT` | 标题／正文／战斗字体 | pfUI font paths | adapter | `P4` | [字体文件](../runtime/FONT_MEDIA.md) | N/A | 未接入 | Turtle WoW 加载与内存测试 |
| `CHAT.FRAME` | 旧书主框九宫格 | `pfUI.chat.left` | adapter | `P4` V3／`P5` legacy | [V3 主框](../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)；[锁定基准](../../assets/locked/chat/聊天框视觉基准_v1.png) | [V3 原始提示词](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md) | `Chat.lua` 加载旧 `ChatBookFrame.tga`；smoke 已有 | 导出 V3 atlas，更新 UV 后实机验收 |
| `CHAT.TABS` | Tab 承托带；普通／悬停／选中／禁用 | `ChatFrameNTab`、`panelTop` | adapter | `P4` V3／`P5` legacy | [V3 Tab 母版](../../assets/source/chat/v3/ChatTabs_Master_v3.png) | [V3 原始提示词](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md) | 旧资源只接入三状态 | 接入统一 atlas；确认禁用状态来源 |
| `CHAT.UNREAD` | 未读蜡封／布结 | `ChatFrameNTabFlash` | adapter | `P4` V3／`P5` legacy | [V3 控件母版](../../assets/source/chat/v3/ChatControls_Master_v3.png) | [V3 原始提示词](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md) | 旧 `ChatWaxSeal.tga` 已接入 | 用 V3 未读切片替换 |
| `CHAT.INPUT` | 输入条普通／聚焦 | `pfUI.chat.editbox`、`ChatFrameEditBox` | adapter | `P4` V3／`P5` legacy | [V3 控件母版](../../assets/source/chat/v3/ChatControls_Master_v3.png) | [V3 provenance](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md)；[V4 修订约束](../../prompts/chat/聊天框模块化资源_修订约束_v4.md) | 旧资源未区分聚焦 | 接入两状态 atlas，不改变正文高度 |
| `CHAT.LEGACY.PANEL` | 公会／背包空间／耐久／好友／延迟／时钟／金币等旧信息底栏 | `pfUI.panel.left/right/minimap` | unmount | `P5` | 无 runtime 美术；widget 代码保留 | [V4 移除约束](../../prompts/chat/聊天框模块化资源_修订约束_v4.md) | 默认路由不加载 `panel`；[Chat.lua](../../addon/AzerothExpeditionUI/Modules/Chat.lua) 仍提供二次隐藏；smoke | 实机确认聊天与小地图下方均无常驻 panel |
| `CHAT.TEXT` | 正文安全区与排版 | `ChatFrameN` | adapter | `P5` | 无美术资产 | N/A | `380×236`／16 行预演 | 实机验证 UI Scale 与长中文 |
| `CHAT.SCROLL` | 滚轮、复制、滚动控制 | pfUI chat／chatcopy | skin | `P1` | — | — | 未换肤 | 先确认实际显示 Frame |
| `CHAT.WHISPER` | whisper proxy／独立密语入口 | pfUI whisperproxy | replacement candidate | `P5` route／`P0` final | — | — | 未换肤的可见入口默认不加载 | 映射输入、目标、关闭和转发状态后再恢复 |
| `QUEST.LOG.SHELL` | 双页卷宗封皮、包角与外围页叠 | `QuestLogFrame` | adapter | `P4` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A1 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md) | [QL-A1 manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)；尚无 runtime | 整图不得作为背景；`QL-A2` 与实机测量后再定义切片 |
| `QUEST.LOG.LIST.PAPER` | 左页目录连续纸面 | `QuestLogListScrollFrame` 外围呈现层 | adapter | `P4` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A1 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md)；[QL-A2 后续 draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [QL-A1 manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)；尚无 runtime | 接近等宽的物理页已接受；runtime 左页阅读区目标为 `42%`；`QL-A2` 不自动执行 |
| `QUEST.LOG.DETAIL.PAPER` | 右页正文连续纸面 | `QuestLogDetailScrollFrame` | adapter | `P4` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A1 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md)；[QL-A2 后续 draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [QL-A1 manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)；尚无 runtime | runtime 右页阅读区目标为 `58%`；切片与安全区等待 `QL-A2` 和实机测量 |
| `QUEST.LOG.SPINE` | 中央书脊、缝线与底部连接 | `QuestLogFrame` 中央非交互呈现层 | adapter | `P4` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A1 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md)；[QL-A2 后续 draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [QL-A1 manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)；尚无 runtime | 保持已接受结构；`QL-A2` 与实机测量后定义三段式切片 |
| `QUEST.LOG.TITLE` | 卷宗标题与任务计数安全区 | `QuestLogTitleText`、`QuestLogQuestCount`／`QuestLogCount` | adapter | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 字体与文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 实机测量中文标题、任务计数和书脊避让 |
| `QUEST.LOG.LIST.ROW` | 地区标题／任务条目的普通、悬停、选中、禁用覆盖 | `QuestLogTitle1..QUESTS_DISPLAYED` | adapter | `P2` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不生成独立卡片 | 确认提示词后生成同几何四状态 |
| `QUEST.LOG.LIST.CHECK` | 任务追踪状态墨圈／墨勾 | `QuestLogTitleNCheck` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 实机确认可见条件与原生点击关系 |
| `QUEST.LOG.SELECTION` | 当前任务暗酒红织物书签 | 当前 `QuestLogTitleN` 的 adapter Texture | adapter | `P2` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成普通／悬停／选中同轮廓状态 |
| `QUEST.LOG.TYPE.BADGE` | 普通／精英／地下城／团队／限时压印 | `GetQuestLogTitle` 可靠 tag | adapter | `P2` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；只使用客户端可判定类型 | 实机记录 Turtle WoW tag 返回值后裁减图集 |
| `QUEST.LOG.STATE.SEAL` | 任务完成／失败蜡封 | 任务行状态 overlay | adapter | `P2` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成完整与破裂蜡封，验证小尺寸 |
| `QUEST.LOG.LIST.SCROLL` | 左页目录滚动条 | `QuestLogListScrollFrameScrollBar` | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 轨道、滑块、上下按钮分别生成四状态 |
| `QUEST.LOG.DETAIL.SCROLL` | 右页正文滚动条 | `QuestLogDetailScrollFrameScrollBar` | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 与左页复用同几何资产，独立绑定对象 |
| `QUEST.LOG.DETAIL.DIVIDER` | 叙事／目标／奖励短墨线 | 右页 adapter Texture | adapter | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-D production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成左端／平铺中段／右端 |
| `QUEST.LOG.REWARD.SLOT` | 奖励物品槽及选中覆盖 | `QuestLogItem1..MAX_NUM_ITEMS` | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-D production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；图标／数量／名称保持动态 | 生成槽底、悬停、选中、禁用四状态 |
| `QUEST.LOG.TRACK` | 追踪／取消追踪控件 | `QuestLogTrack`、`QuestLogTrackTracking` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 实机确认状态对象后生成墨圈／墨勾 |
| `QUEST.LOG.CLOSE` | 黄铜书扣式关闭 | `QuestLogFrameCloseButton` | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成普通／悬停／按下／禁用 |
| `QUEST.LOG.ACTION.ABANDON` | 放弃任务按钮 | `QuestLogFrameAbandonButton` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；与其他操作按钮共享同几何资产 | 实机验证确认弹窗与禁用状态 |
| `QUEST.LOG.ACTION.SHARE` | 共享任务按钮 | `QuestFramePushQuestButton`；需 feature-detect | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；与其他操作按钮共享同几何资产 | 实机确认 Turtle WoW 对象名与不可共享状态 |
| `QUEST.LOG.ACTION.EXIT` | 底部关闭／退出按钮 | `QuestFrameExitButton`／`QuestLogFrameCancelButton` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；与其他操作按钮共享同几何资产 | 实机选择真实对象，不重复创建关闭行为 |
| `QUEST.LOG.DETAIL.TOGGLE` | 左／右折页式详情收起 | pfUI skin 才创建的 `QuestLogFrameExpandButton` | optional extension | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不是首轮硬依赖 | 实机后决定是否重建 pfUI UI 增强 |
| `QUEST.LOG.LEVELS` | 显示任务等级复选框 | pfUI skin 才创建的 `QuestLogFrameLevelsCheckButton` | optional extension | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-C2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；非视觉配置不得改写 | 实机后决定是否重建并兼容 pfQuest 配置 |
| `QUEST.TRACKER.HEADER` | 行军便笺顶部皮带与双铆钉 | 外部 provider 顶层容器待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；无 provider／runtime／源资产 | 取得外部插件源码后映射安全区并重写提示词 |
| `QUEST.TRACKER.EMBLEM` | 羽毛笔与指南针徽记 | 外部 provider 标题区与鼠标命中范围待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；禁止提前生成 | 先确认装饰不会遮挡外部插件交互 |
| `QUEST.TRACKER.PAPER` | 可纵向扩展纸面和左右叠页边 | 外部 provider 内容容器与尺寸更新待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；禁止提前生成 | 映射 provider 高度计算后重新定义切片 |
| `QUEST.TRACKER.BOTTOM` | 自然撕裂底边与后方叠页 | 外部 provider 底部锚点待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；禁止提前生成 | 映射实际宽度与伸缩规则后重写批次 |
| `QUEST.TRACKER.ENTRY` | 任务标题和目标动态排版 | 外部 provider 任务组／行对象待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；未证明点击对象或状态 | 取得对象树与更新生命周期；不伪造行交互 |
| `QUEST.TRACKER.COLLAPSE` | 便笺收起／展开拉环 | 外部 provider 真实 Button 待识别 | future extension | `P1 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；未知是否存在此能力 | 仅在 provider 已有收起交互时保留该组件 |
| `QUEST.TRACKER.OBJECTIVE` | 未完成墨圈／已完成墨勾 | 外部 provider 目标行与完成状态待识别 | future adapter | `P2 visual／P0 compat` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；状态数据未知 | 依据 provider 数据合同重写状态映射 |
| `QUEST.TRACKER.FOCUS` | 当前重点任务页边织物标记 | 外部 provider 重点任务语义待识别 | future adapter | `P2 visual／P0 compat` | [追踪基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；状态数据未知 | 仅在 provider 有 focus 语义时接入 |
| `QUEST.TRACKER.SEAL` | 整项完成／失败小蜡封 | 外部 provider 完成／失败状态待识别 | future adapter | `P2 visual／P0 compat` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；状态数据未知 | 依据 provider 可判定状态裁减资产 |
| `QUEST.TRACKER.TIMER` | 限时任务沙漏与警告 | 外部 provider 计时对象与阈值待识别 | future adapter | `P1 visual／P0 compat` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [deferred compatibility draft](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；计时能力未知 | 取得事件、对象和阈值后再决定是否保留 |
| `QUEST.DIALOG.FRAME` | NPC 任务／Gossip 外框 | `QuestFrame`、`GossipFrame` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | — | [任务组件合同](QUEST_COMPONENT_SPEC.md)；本波次保持原生 | 后续建立“NPC 委托文书”视觉合同 |
| `QUEST.DIALOG.PANELS` | Greeting／Detail／Progress／Reward 正文区 | 对应 panels 与 ScrollFrames | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | — | [任务组件合同](QUEST_COMPONENT_SPEC.md)；本波次保持原生 | 清点材料背景、滚动条和文字安全区 |
| `QUEST.DIALOG.ACTIONS` | 接受／拒绝／继续／完成／取消 | Quest／Gossip action buttons | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | — | [任务组件合同](QUEST_COMPONENT_SPEC.md)；本波次保持原生 | 每个按钮映射后再决定共用几何 |
| `QUEST.DIALOG.REWARD` | NPC 对话奖励与需求物品槽 | `QuestProgressItemN`、`QuestDetailItemN`、`QuestRewardItemN` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | — | [任务组件合同](QUEST_COMPONENT_SPEC.md)；本波次保持原生 | 以后与 `QUEST.LOG.REWARD.SLOT` 比较复用 |
| `QUEST.ITEM.TOOLTIP` | 任务物品所属任务与数量提示 | `modules/questitem.lua` | behavior reuse | `N/A` | 无视觉资产 | N/A | [questitem.lua](../../addon/pfUI/modules/questitem.lua)；保留扫描、缓存与 Tooltip 行为 | 仅做功能回归，不纳入任务快捷按钮 |
| `QUEST.ITEM.QUICKBUTTON` | 任务物品快捷使用入口 | 当前无可靠基础对象 | future extension | `P0` | — | — | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不得归因给 `questitem.lua` | 用户需要后再确定数据与交互模型 |
| `MAP.WORLD.FRAME` | 羊皮卷大地图外框 | `WorldMapFrame`、`modules/map.lua` | replacement | `P2` | [大地图基准](../../assets/locked/map/大地图羊皮卷_视觉基准_v1.png) | [锁定视觉提示词](../../prompts/map/大地图羊皮卷_锁定提示词_v1.md) | — | 拆分卷杆、端帽、标题、图例、尺 |
| `MAP.WORLD.CONTENT` | 原始地图内容与标记安全区 | WorldMap detail frames | adapter | `P2` | [大地图基准](../../assets/locked/map/大地图羊皮卷_视觉基准_v1.png) | [锁定视觉提示词](../../prompts/map/大地图羊皮卷_锁定提示词_v1.md) | — | 保留原始地图图层，记录裁切边界 |
| `MAP.WORLD.NAV` | 区域导航、缩放、图例、关闭 | WorldMap buttons | refactor | `P1` | [地图模块规范](../modules/map/地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md) | — | — | 每个按钮独立状态资产 |
| `MAP.MINI.MASK` | 圆形地图遮罩与有效直径 | `modules/minimap.lua` | adapter | `P2` | [小地图基准](../../assets/locked/map/小地图黄铜罗盘_视觉基准_v1.png) | [锁定视觉提示词](../../prompts/map/小地图黄铜罗盘_锁定提示词_v1.md) | — | 验证中心直径不低于 70% |
| `MAP.MINI.COMPASS` | 双层黄铜罗盘、北针、方位 | Minimap frame | replacement | `P2` | [小地图基准](../../assets/locked/map/小地图黄铜罗盘_视觉基准_v1.png) | [锁定视觉提示词](../../prompts/map/小地图黄铜罗盘_锁定提示词_v1.md) | — | 拆分静态环、北针和方位文字 |
| `MAP.MINI.CONTROLS` | 缩放、追踪、时间、坐标 | minimap／tracking | refactor | `P1` | [地图模块规范](../modules/map/地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md) | — | — | 清点按钮及悬停／按下状态 |
| `MAP.MINI.ADDONS` | 插件图标挂载与溢出 | `addonbuttons.lua` | adapter | `P2` | [承载评估](../audits/小地图插件图标承载评估_v1.md) | — | — | 设计非永久槽环的运行时布局 |
| `CHAR.FRAME` | 香草同构主框 | `skins/blizzard/character.lua` | replacement | `P2` | [V3 基准](../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png) | [锁定视觉提示词](../../prompts/character/角色属性面板_锁定生成稿_v3.md) | — | 记录 CharacterFrame 精确几何 |
| `CHAR.MODEL` | 3D 纸娃娃、旋转、头盔／披风开关 | PaperDollFrame | adapter | `P2` | [香草结构参考](../../assets/references/香草60级角色面板_结构参考.webp) | [锁定视觉提示词](../../prompts/character/角色属性面板_锁定生成稿_v3.md) | — | 保留模型与原交互 |
| `CHAR.SLOTS` | 左右装备槽与底部三槽 | PaperDoll item buttons | refactor | `P2` | [V3 基准](../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png) | — | — | 定义空槽、品质、耐久、悬停 |
| `CHAR.STATS` | 双列属性与下拉分类 | PaperDoll stats | refactor | `P2` | [角色模块规范](../modules/character/角色属性模块视觉规范_香草同构角色面板_v1.md) | — | — | 先确认 Turtle WoW 扩展字段 |
| `CHAR.TABS` | 角色／声望／技能／PVP | CharacterFrame tabs | refactor | `P2` | [V3 基准](../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png) | — | — | 每个 Tab 共用状态画布 |
| `CHAR.INSPECT` | 查看与试衣 | `inspect.lua`、`dressup.lua` | skin | `P1` | [角色模块规范](../modules/character/角色属性模块视觉规范_香草同构角色面板_v1.md) | — | — | 复用角色组件库 |
| `HUD.ACTION.MAIN` | 主动作条与双头狮鹫 | 原生 `MainMenuBar`；pfUI `actionbar.lua`、`gryphons.lua` 待重构 | native fallback／replacement final | `P5` route／`P1` final | [美术方向](../ART_DIRECTION.md)；客户端原生双头狮鹫 | N/A route；最终提示词待写 | `CORE.NATIVE.FALLBACK` 保留原生动作条；pfUI 现代条不加载 | 实机校验原生按钮、翻页、姿态和双狮鹫，再按真实按钮拆分最终动作条 |
| `HUD.ACTION.EXTRA` | 多动作条、姿态、宠物、背包、微菜单 | actionbar／pet | refactor | `P1` | — | — | — | 按真实 Button 分组拆分 |
| `HUD.ACTION.STATE` | 可用、悬停、按下、冷却、缺资源、超距 | actionbar／cooldown／unusable | refactor | `P1` | — | — | pfUI 功能复用 | 先定义统一 IconSlot |
| `HUD.UNIT.PLAYER` | 玩家头像、血量、资源、状态 | player／unitframes API | replacement | `P1` | — | — | — | 获取香草与 pfUI 玩家框对照截图 |
| `HUD.UNIT.TARGET` | 目标、精英、稀有、PvP、仇恨 | target／unitframes API | replacement | `P1` | — | — | — | 获取香草与 pfUI 目标框对照截图 |
| `HUD.UNIT.SECONDARY` | 宠物、焦点、目标的目标、多级目标 | pet／focus／targettarget* | refactor | `P1` | — | — | — | 共用简化单位框架 |
| `HUD.PARTY` | 五人小队成员、职责、驱散、距离 | group／unitframes API | replacement | `P1` | — | — | — | 先锁定五人副本场景 |
| `HUD.RAID` | 四十人团队、分组、减益、距离 | raid／unitframes API | replacement | `P1` | — | — | — | 信息优先，成员格不做复杂装饰 |
| `HUD.CAST` | 玩家／目标／焦点施法条 | castbar | refactor | `P1` | — | — | — | 拆分槽、填充、端帽、不可打断 |
| `HUD.AURAS` | Buff、Debuff、BuffWatch、Totem | buff／buffwatch／totems | refactor | `P1` | — | — | — | 定义增益、负面、驱散、倒计时 |
| `HUD.NAMEPLATE` | 姓名、血量、施法、仇恨、精英 | nameplates／nampower／unitxp | replacement | `P1` | — | — | — | 保持远距离轻量 |
| `HUD.TIMERS` | 连击、摆动、能量刻度、镜像计时 | combopoints／swingtimer／energytick／mirrortimers | refactor | `P1` | — | — | — | 统一战斗刻度组件 |
| `HUD.XP` | 经验、休息、声望进度 | xpbar | refactor | `P1` | — | — | — | 保留香草进度语义 |
| `METER.DAMAGE` | DPS、治疗、承伤、驱散、死亡 | pfUI 无原生 meter | extension | `P0` | [美术方向](../ART_DIRECTION.md)（战地账簿） | — | — | 确定数据源与插件兼容目标 |
| `METER.THREAT` | 目标仇恨列表、阈值、坦克状态 | pfUI 无原生 meter | extension | `P0` | [美术方向](../ART_DIRECTION.md)（指挥刻度） | — | — | 确定 Turtle WoW 威胁 API |
| `CONSUME.GRID` | 药剂、食物、卷轴、油、材料槽 | buff／cooldown 可复用 | extension | `P0` | [美术方向](../ART_DIRECTION.md)（炼金卷袋） | — | — | 确定清单与预设数据模型 |
| `CONSUME.STATE` | 充足、偏低、缺失、冷却、增益将尽 | item count／buff | extension | `P0` | — | — | — | 定义状态优先级与阈值 |
| `BAG.FRAME` | 背包、钥匙、银行、袋栏 | `bags.lua` | replacement | `P1` | — | — | — | 清点容器与搜索／分类能力 |
| `BAG.SLOT` | 物品槽、品质、锁定、新物品、计数 | bags／itemclick | refactor | `P1` | — | — | — | 复用 CORE.ICON |
| `LOOT.FRAME` | 拾取窗口、物品行、金币 | `loot.lua` | replacement | `P1` | — | — | — | 按实际按钮拆分 |
| `LOOT.ROLL` | 需求、贪婪、放弃、倒计时 | `roll.lua` | refactor | `P1` | — | — | — | 三按钮必须独立状态资产 |
| `BOOK.SPELL` | 法术书、页签、翻页 | `spellbook.lua` | replacement | `P1` | — | — | — | 先采集香草结构，再锁定魔法典籍方向 |
| `BOOK.TALENT` | 天赋树、节点、连线、重置 | `talents.lua` | replacement | `P1` | — | — | — | 不生成整张树背景，先清点节点 |
| `BOOK.PROFESSION` | 专业列表、配方、材料、制作按钮 | `professions.lua` | replacement | `P1` | — | — | — | 清点排序、过滤和制作状态 |
| `ECON.MERCHANT` | 商人列表、购买、修理、回购 | `merchant.lua` | skin | `P1` | — | — | — | 建立共用列表行与金币组件，再锁定商会账簿方向 |
| `ECON.AUCTION` | 搜索、筛选、列表、竞价、一口价 | `auction.lua` | refactor | `P1` | — | — | — | 信息密度优先 |
| `ECON.MAIL` | 收件箱、信纸、附件、发送 | `mail.lua` | refactor | `P1` | — | — | — | 按信件与附件槽拆分 |
| `ECON.TRADE` | 双方物品槽、金币、接受状态 | `trade.lua` | refactor | `P1` | — | — | — | 不可逆操作不得只靠颜色 |
| `SOCIAL.FRIENDS` | 好友、公会、忽略、玩家列表 | friends／socialmod | skin | `P1` | — | — | — | 复用大型列表组件 |
| `SOCIAL.GROUP` | LFG／LFT／招募 | lfg／lft | skin | `P1` | — | — | — | Turtle WoW 实机核对 |
| `SYSTEM.TOOLTIP` | 物品、法术、单位、比较 Tooltip | tooltip／tooltips／eqcompare | refactor | `P1` | — | — | — | 先锁定小字号可读的香草式 Tooltip |
| `SYSTEM.POPUP` | 确认、危险、输入、准备确认 | popup_dialogs／readycheck | refactor | `P1` | — | — | — | 按操作风险定义按钮状态 |
| `SYSTEM.MENU` | 游戏菜单、设置、下拉、滑杆、复选 | gui／game_menu／options-* | replacement | `P1` | — | — | — | 建立公共控件后实现 |
| `SYSTEM.BATTLEFIELD` | 战场地图、计分、队列状态 | battlefield*／bgscore | skin | `P1` | — | — | — | PvP 场景后处理 |
| `SYSTEM.MISC` | 宏、按键、帮助、旅店、训练、宠物栏、Tabard、Taxi、Turtle 商店 | 对应 `skins/blizzard/*.lua` | skin | `P1` | — | — | — | 按使用频率分批 |
| `SYSTEM.ALERT` | 首领警报、战斗提示 | pfUI 无完整实现 | extension | `P0` | — | — | — | 确定事件／第三方插件来源，再锁定战争号令方向 |

## pfUI 功能覆盖

以下 pfUI 文件默认复用功能，不单独生成美术；若未来出现可见 Frame，再拆成
独立组件行：

- 配置与编辑：`gui`、`unlock`、`hoverbind`、`firstrun`、`share`、
  `pixelperfect`、`hdgraphic`、`updatenotify`。
- 自动化与数据：`autoshift`、`autovendor`、`sellvalue`、`itemclick`、
  `questitem`、`combatlogfix`、`feigndeath`、`farmmode`、`screenshot`。
- 兼容与平台：`thirdparty*`、`addoncompat`、`turtle-wow`、`superwow`、
  `custom`、`gm`。
- 社交与辅助：`whisperproxy`、`chatcopy`、`bubbles`、`friends`、
  `socialmod`、`addons`、`addonbuttons`。
- 其他功能：`tracking`、`mapcolors`、`mapreveal`、`marktracking`、
  `hunterbar`、`pettarget`、`unusable`、`infight`、`afkcam`、
  `easteregg`。

其中任何文件一旦成为视觉改造目标，必须新增组件行，不能只在本列表中改状态。
