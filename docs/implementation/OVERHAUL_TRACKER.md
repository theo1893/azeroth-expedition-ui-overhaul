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
| `P6-C` | P6 后已完成中间产物清理、文档收敛和最终复测；组件终态关闭 |
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

`P6` 之后必须先列出精确保留／删除清单并取得用户确认；清理该组件的
`generated/` 中间图、过时 prompt、实验工具／参考和重复过程叙述，复测全部
链接与 runtime 后，才可标记 `P6-C`。`P6-C` 行只链接最终 prompt、source、
manifest、runtime、实现和最小实机证据，下一步写“已关闭”。

## 当前总览

| 模块 | 当前结论 | 下一道门 |
|---|---|---|
| pfUI 基础 | 可安装维护分支已迁入 `addon/pfUI`；现代可见模块默认回退香草呈现，路由达到 `P5` | Turtle WoW 实机核对原生 Frame 未被隐藏，再逐模块替换 |
| 聊天 | V3 主框／Tab／输入／未读母版达到 `P4`；legacy 信息底栏已退役 | 复核五张 V3 exporter、UV 和 Lua，再做实机迁移 |
| 任务 | `QL-A1` 空卷宗透明源母版达到 `P4`；`QL-A2 V1`／`V2.1`／`V3` 均已退回；低频对称内页沟 `V3.1` 为未授权 `prompt-draft / P2`；Quest Log 与 NPC 对话已拆到真实交互粒度；追踪器仅保留 `P2` 视觉，外部 provider 兼容为 `P0` | 用户审查并授权 `QL-A2 V3.1` 提示词；NPC 对话等待独立视觉方向与实机几何；追踪器等待外部插件源码 |
| 地图 | 大地图／小地图视觉达到 `P2` | 清点 WorldMap 与 Minimap 按钮、遮罩、缩放、插件图标 |
| 角色 | 香草纸娃娃视觉达到 `P2` | 清点装备槽、Tab、旋转、属性、关闭按钮状态 |
| 其他 | `P0–P1` | 按表中顺序完成结构截图与组件合同 |

## 验证记录

| 日期 | 范围 | 结果 | 证据／限制 |
|---|---|---|---|
| `2026-07-29` | 资产工作流与 `QL-A2 V3.1` 美术继承审计 | 工作流门禁已补齐；V3.1 为 `prompt-draft / P2`，尚未授权或生图 | [资产流程](../ASSET_PIPELINE.md) 与 [项目 Skill](../../.codex/skills/run-aeui-asset-workflow/SKILL.md) 现在强制解析锁定图对应的原始 prompt provenance、记录必须继承／组件级转译／明确排除／冲突裁决，并禁止派生 source 倒置视觉权威。[V3.1 draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) 以[任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)及其[原始提示词](../../prompts/quests/任务模块_视觉原型提示词_v1.md)为最高视觉权威；聊天旧书只负责共享材质精度，QL-A1 source 只负责结构。下一门禁是用户看过执行正文后明确授权 `QL-A2 V3.1` |
| `2026-07-29` | `QL-A2 V3` 对称内页沟八对象候选 | 固定版本生成后被内部结构审查退回；保持 `P3 candidate-rejected`，无 source／runtime | [V3 production 与退回记录](../../prompts/quests/任务详情对称内页沟结构部件_生产提示词_QL-A2_v3.md)。执行前曾把“进入下一步”解释为授权；流程审计认定这不满足版本明确授权门禁。V3 还遗漏了锁定基准原始提示词，并把派生 QL-A1 source 错置为最高视觉权威。固定执行会话 `019fad38-517b-7ca1-82af-853b0ddc68f2`，结果 `ig_0e8d8bb14f37caff016a69c8e4f918819186e21dd3df807ff2`。子进程因只读沙箱返回 `Operation not permitted`，从固定缓存原样恢复 raw。raw 为 `1536 × 1024` RGB，SHA-256 `44e3cf1b01625b4c9e810229a6d33a9bcf381bb9bc0dc9feda06384034c0a0cc`；确定性 Alpha 候选为 `1536 × 1024` RGBA，SHA-256 `97908ab5a32ee3b3ee37763d4b28dbb6dac4199a52c7424255805dc011271178`，透明／半透明／不透明像素 `674973／32176／865715`，可见绿色残留 `0`。八对象与横向针脚数量合同通过，但 `UNDERLAY` 是高对比完整织纹竖条，左右内折是独立实心纸条，3／5／7 针脚在正确层序下全部消失，上下收口像横向把手，正文仍有满页细碎压花。raw、候选与三张预演均只在被忽略的 `generated/quests/QL-A2/v3/` |
| `2026-07-29` | `QL-A2 V3` 对称内页沟合同与 NPC 对话对象拆分 | 静态合同完成；V3 保持 `prompt-draft / P2`，未生成；NPC 对话保持原生 | [V3 production draft](../../prompts/quests/任务详情对称内页沟结构部件_生产提示词_QL-A2_v3.md) 固定 `676 × 440` 参考几何、绝对中心 `x=338`、物理页宽差约 `≤1%`、离散横向针脚站、内折遮住端点及正文中央约 `70%` 低频纸面。V2／V2.1 不作为新输入。[`QUEST_COMPONENT_SPEC.md`](QUEST_COMPONENT_SPEC.md) 已把 Quest Log 地区展开、追踪标记、选择、左右滚动子件与 NPC 的两套外壳、五个面板、二十个滚动绑定、八个操作按钮及四类物品／奖励对象逐项登记；无 source／runtime |
| `2026-07-29` | `QL-A2 V2.1` 用户复审 | 候选退回；不得进入 tracked source 或 runtime | [V2 production](../../prompts/quests/任务详情内页沟结构部件_生产提示词_QL-A2_v2.md) 与 [V2.1 执行／退回记录](../../prompts/quests/任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md) 保留 provenance。技术检查曾通过，但语义／物理门禁失败：装订针脚未稳定对齐书本绝对中心线，针脚两端与纸页交界突兀，正文纸面高频纹理过密。保留近等宽双页、内部视角、凹陷页沟、厚重外壳与暖色材料方向；下一版改为沿 `x=338` 离散重复的单个横向针脚站，由左右内折在高层遮住端点 |
| `2026-07-29` | `QL-A2 V2.1` 内页沟八对象候选 | 固定版本生成、透明处理与正确层序重组曾通过技术门禁；后续用户视觉复审退回 | 首轮 V2 会话 `019fac8b-35c1-7060-a65a-324c185b2eeb` 因缝线仍带皮革底板、两个收口未横向分离而内部退回；最终固定会话 `019fac8e-bae8-73f2-af89-674e925b0068`，结果 `ig_0bda33a80800f83f016a699ddd6dbc8191a674cb8b33717482`。本地 `generated/quests/QL-A2/v2/QL-A2_v2.png` 为 `1536 × 1024` RGBA，SHA-256 `c4f3b41c8108776ddeb69cd092627e605fe2bfa41c28822f491a151cd327a461`；透明／半透明／不透明像素 `745186／57546／770132`，可见绿色残留 `0`。八组为近等宽左右纸面、凹陷页沟、左右内折、无底板缝线周期、顶部收口和底部收口。离线重组层序为页沟／装订在下、双页在上、内折最后覆盖；`42%／58%` 仅为 runtime 文字安全区。raw、透明候选和预演均在被忽略的 `generated/`，无 tracked source／runtime |
| `2026-07-29` | `QL-A2 V1` 可拉伸结构部件候选 | 用户视觉复审未通过；正式退回 | [V1 退回提示词](../../prompts/quests/任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md)；固定 `imagegen-0-143-0` 会话 `019fac4a-c73e-71c1-a6bd-a94a86627b3e`。本地候选曾通过尺寸、Alpha 与五连通区技术检查，但这些检查没有证明书籍解剖正确。外置封脊朝向错误，上下结构压死翻页空间，书脊与纸页不在同一透视／图层，且误把 `42.1%／57.9%` 用作物理页面宽度；`140 × 60` 周期假定作废。V1 只保留失败记录，无 tracked source／runtime |
| `2026-07-29` | `QL-A1` 空卷宗源母版 | 离线技术检查与用户视觉复审通过；达到 `P4` | 固定 `imagegen-0-143-0` 生成会话 `019fac35-620b-78d3-8b46-2e1f02105f74`；[`QuestLogBookShell_Master_v1.png`](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 为 `1514 × 1039` RGBA，透明／半透明／不透明像素为 `241402／5650／1325994`，可见绿色残留 `0`；[`manifest`](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json) 锁定 SHA-256 与来源。无文字、任务行、按钮、滚动条或奖励槽。接近等宽的物理双页已经接受，`42%／58%` 继续作为 runtime 左／右阅读安全区目标；整张源图不得进入 runtime |
| `2026-07-29` | 任务模块范围收敛 | 通过静态检查 | [`QUEST_COMPONENT_SPEC.md`](QUEST_COMPONENT_SPEC.md) 保留 Quest Log、NPC 任务对话和 questitem 行为边界；原生 QuestWatch provider 假设已撤销，外部追踪插件待后续审计；`QL-A1` 已确认，`QL-A2 V1`／`V2.1`／`V3` 已退回，`V3.1` 等待提示词授权 |
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
| `QUEST.LOG.SHELL` | 双页卷宗封皮、包角与外围页叠 | `QuestLogFrame` | adapter | `P4 QL-A1` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A1 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md) | [QL-A1 manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)；尚无 runtime | 整图不得作为背景；V3.1 结构通过和实机测量后才定义切片 |
| `QUEST.LOG.LIST.PAPER` | 左页目录连续纸面 | `QuestLogListScrollFrame` 外围呈现层 | adapter | `P4 QL-A1／P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 已内部退回；V3.1 未生成，无 tracked source／runtime | 用户审查 V3.1 提示词；正文中央 `80%` 低频，左文字安全区目标 `42%` |
| `QUEST.LOG.DETAIL.PAPER` | 右页正文连续纸面 | `QuestLogDetailScrollFrame` | adapter | `P4 QL-A1／P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 已内部退回；V3.1 未生成，无 tracked source／runtime | 用户审查 V3.1 提示词；正文中央 `80%` 低频，右文字安全区目标 `58%` |
| `QUEST.LOG.SPINE` | 中央页沟与装订结构父级包 | `QuestLogFrame` 中央非交互呈现层 | logical package | `P2 parent` | [QL-A1 源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | N/A（父级不对应单一资产；见六个 `GUTTER.*` 子组件） | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不得绑定一张外置封脊图 | 只作为兼容名称；runtime 必须组合下列六个子组件 |
| `QUEST.LOG.GUTTER.UNDERLAY` | 凹陷内部页沟底层 | `QuestLogFrame` 中央非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 完整织纹竖条已退回；V3.1 要求透明羽化、低对比、无编织网格 | 用户明确授权 V3.1 后才生成；实机高度后定义纵向周期 |
| `QUEST.LOG.GUTTER.LEFT_FOLD` | 左页内折过渡与针脚端点遮罩 | 左页内缘非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 实心纸条已退回；V3.1 只能是大部分透明的单侧曲面遮罩 | 用户审查透明渐隐、共同透视与接触融合 |
| `QUEST.LOG.GUTTER.RIGHT_FOLD` | 右页内折过渡与针脚端点遮罩 | 右页内缘非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 实心纸条已退回；V3.1 只能是大部分透明的镜像曲面遮罩 | 用户审查透明渐隐、共同透视与接触融合 |
| `QUEST.LOG.GUTTER.STITCH` | 单个可离散重复的横向装订针脚站 | 页沟中央非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 在正确层序下完全消失；V3.1 禁止端部圆结，中央短段必须可见 | 生成后用 3／5／7 站重组检查可见性与共线 |
| `QUEST.LOG.GUTTER.TOP` | 顶部小型装订收口 | 页沟顶端非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 横向把手形态已退回；V3.1 必须是紧凑半藏线结 | 与 `x=338` 对齐；不得扩展成 U 形、横梁或杆件 |
| `QUEST.LOG.GUTTER.BOTTOM` | 底部小型装订收口 | 页沟底端非交互 Texture | adapter | `P2 QL-A2 V3.1 draft` | [任务详情锁定基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)；[QL-A1 结构次级参考](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) | [QL-A2 V3.1 production draft](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md) | V3 横向把手形态已退回；V3.1 必须是非复制的紧凑半藏线结 | 与 `x=338` 对齐；不得扩展成 U 形、横梁或杆件 |
| `QUEST.LOG.TITLE` | 卷宗标题与任务计数安全区 | `QuestLogTitleText`、`QuestLogQuestCount`／`QuestLogCount` | adapter | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 字体与文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 实机测量中文标题、任务计数和书脊避让 |
| `QUEST.LOG.REGION.TOGGLE` | 单个地区展开／收起墨箭头 | `QuestLogTitleN` 且 `isHeader=true` 的展开图标区域 | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不改变整行命中区 | 实机确认展开／收起纹理、缩进和八状态 |
| `QUEST.LOG.LIST.ROW` | 地区标题／任务条目整行点击覆盖 | `QuestLogTitle1..QUESTS_DISPLAYED` | adapter | `P2` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；普通／悬停／按下／禁用；不持有书签 | 确认提示词后生成同几何四状态 |
| `QUEST.LOG.LIST.CHECK` | 已追踪状态墨圈／墨勾 | `QuestLogTitleNCheck` | skin | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不是任务选择 Button，不新增命中区 | 实机确认未追踪／已追踪可见条件 |
| `QUEST.LOG.SELECTION` | 当前任务暗酒红织物书签 | 当前 `QuestLogTitleN` 的 adapter Texture | adapter | `P2` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-B1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成普通／悬停／选中同轮廓状态 |
| `QUEST.LOG.TYPE.BADGE` | 普通／精英／地下城／团队／限时压印 | `GetQuestLogTitle` 可靠 tag | adapter | `P2` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；只使用客户端可判定类型 | 实机记录 Turtle WoW tag 返回值后裁减图集 |
| `QUEST.LOG.STATE.SEAL` | 任务完成／失败蜡封 | 任务行状态 overlay | adapter | `P2` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | [QL-B2 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成完整与破裂蜡封，验证小尺寸 |
| `QUEST.LOG.LIST.SCROLL.TRACK` | 左页滚动轨道 | `QuestLogListScrollFrameScrollBar` 轨道 | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；非交互三段纵向结构 | 实机测量轨道长度与可平铺中段 |
| `QUEST.LOG.LIST.SCROLL.THUMB` | 左页滚动滑块 | `QuestLogListScrollFrameScrollBar` ThumbTexture | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；普通／悬停／按下／禁用 | 实机确认拖动命中和最小高度 |
| `QUEST.LOG.LIST.SCROLL.UP` | 左页向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；四状态 | 实机确认精确全局名和禁用状态 |
| `QUEST.LOG.LIST.SCROLL.DOWN` | 左页向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；四状态 | 实机确认精确全局名和禁用状态 |
| `QUEST.LOG.DETAIL.SCROLL.TRACK` | 右页滚动轨道 | `QuestLogDetailScrollFrameScrollBar` 轨道 | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；可与左页共用物理图集但独立绑定 | 实机测量轨道长度与可平铺中段 |
| `QUEST.LOG.DETAIL.SCROLL.THUMB` | 右页滚动滑块 | `QuestLogDetailScrollFrameScrollBar` ThumbTexture | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；普通／悬停／按下／禁用 | 实机确认拖动命中和最小高度 |
| `QUEST.LOG.DETAIL.SCROLL.UP` | 右页向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；四状态 | 实机确认精确全局名和禁用状态 |
| `QUEST.LOG.DETAIL.SCROLL.DOWN` | 右页向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-C1 production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；四状态 | 实机确认精确全局名和禁用状态 |
| `QUEST.LOG.DETAIL.TITLE` | 右页任务标题安全区 | `QuestLogDetailScrollChildFrame` 标题 FontString；需 feature-detect | layout | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不生成文字资产 | 实机映射精确对象与中文换行 |
| `QUEST.LOG.DETAIL.DESCRIPTION` | 右页任务叙述安全区 | Detail ScrollChild 叙述 FontString 集 | layout | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不生成背景卡片 | 实机映射文本对象和最大长度 |
| `QUEST.LOG.DETAIL.OBJECTIVES` | 右页任务目标安全区 | Detail ScrollChild 目标 FontString 集 | layout | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不烘焙勾选或数字 | 实机映射目标对象和多行高度 |
| `QUEST.LOG.DETAIL.REWARD_TEXT` | 右页奖励文字安全区 | Detail ScrollChild 奖励 FontString 集 | layout | `P1` | [任务模块规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | N/A（runtime 文字） | [任务组件合同](QUEST_COMPONENT_SPEC.md)；不烘焙金币、经验或名称 | 实机按客户端实际字段裁减 |
| `QUEST.LOG.DETAIL.DIVIDER` | 叙事／目标／奖励短墨线 | 右页 adapter Texture | adapter | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-D production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md) | 生成左端／平铺中段／右端 |
| `QUEST.LOG.REWARD.SLOT` | 日志中的只读奖励物品槽 | `QuestLogItem1..MAX_NUM_ITEMS` | skin | `P1` | [详情基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | [QL-D production draft](../../prompts/quests/任务详情组件资产_生产提示词_v2.md) | [任务组件合同](QUEST_COMPONENT_SPEC.md)；图标／数量／名称动态；无 selected 状态 | 生成普通／悬停／按下／禁用；奖励选择只属于 NPC 对话 |
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
| `QUEST.DIALOG.QUEST.SHELL` | NPC 任务对话外壳 | `QuestFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；无 source／runtime | 锁定“NPC 委托文书”视觉与实机几何后写 `QD-A` prompt |
| `QUEST.DIALOG.GOSSIP.SHELL` | NPC Gossip 对话外壳 | `GossipFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；无 source／runtime | 与任务外壳比较几何后决定物理资产复用 |
| `QUEST.DIALOG.QUEST.PORTRAIT` | 任务 NPC 动态肖像框 | `QuestFramePortrait` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 保留客户端动态肖像；pfUI 现代换肤的隐藏行为不继承 | 视觉方向中明确肖像框与标题关系 |
| `QUEST.DIALOG.GOSSIP.PORTRAIT` | Gossip NPC 动态肖像框 | `GossipFramePortrait` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 保留客户端动态肖像；无 source／runtime | 视觉方向中明确肖像框与标题关系 |
| `QUEST.DIALOG.QUEST.NPC_NAME` | 任务 NPC 名称安全区 | `QuestFrameNpcNameText` | layout | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | N/A（runtime 文字） | 原生回退；不得烘焙 NPC 名称 | 实机测试长中文名与肖像避让 |
| `QUEST.DIALOG.GOSSIP.NPC_NAME` | Gossip NPC 名称安全区 | `GossipFrameNpcNameText` | layout | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | N/A（runtime 文字） | 原生回退；不得烘焙 NPC 名称 | 实机测试长中文名与肖像避让 |
| `QUEST.DIALOG.QUEST.CLOSE` | 任务对话关闭按钮 | `QuestFrameCloseButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；逻辑 Button 已映射 | `QD-A` 独立生成普通／悬停／按下／禁用 |
| `QUEST.DIALOG.GOSSIP.CLOSE` | Gossip 关闭按钮 | `GossipFrameCloseButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；逻辑 Button 已映射 | `QD-A` 独立生成普通／悬停／按下／禁用 |
| `QUEST.DIALOG.QUEST.GREETING.PANEL` | 任务开场与可交任务正文面板 | `QuestGreetingPanel`／`QuestGreetingScrollFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；动态内容 | 实机清点材质、文字安全区和条目对象 |
| `QUEST.DIALOG.GOSSIP.GREETING.PANEL` | Gossip 开场与选项正文面板 | `GossipGreetingPanel`／`GossipGreetingScrollFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；动态内容 | 实机清点材质、文字安全区和条目对象 |
| `QUEST.DIALOG.QUEST.DETAIL.PANEL` | 新任务详情正文面板 | `QuestDetailPanel`／`QuestDetailScrollFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；标题、叙述、目标与奖励动态 | 实机测量 Detail 全状态 |
| `QUEST.DIALOG.QUEST.PROGRESS.PANEL` | 进行中任务进度正文面板 | `QuestProgressPanel`／`QuestProgressScrollFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；进度与所需物品动态 | 实机测量 Progress 全状态 |
| `QUEST.DIALOG.QUEST.REWARD.PANEL` | 交付与奖励正文面板 | `QuestRewardPanel`／`QuestRewardScrollFrame` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；奖励动态 | 实机覆盖无奖励、固定奖励和多选一 |
| `QUEST.DIALOG.QUEST.GREETING.SCROLL.TRACK` | 任务 Greeting 滚动轨道 | `QuestGreetingScrollFrameScrollBar` 轨道 | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；可与其他面板共享物理 atlas | 实机测量后定义三段纵向结构 |
| `QUEST.DIALOG.QUEST.GREETING.SCROLL.THUMB` | 任务 Greeting 滑块 | 对应 ThumbTexture | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑绑定 | 实机确认拖动与四状态 |
| `QUEST.DIALOG.QUEST.GREETING.SCROLL.UP` | 任务 Greeting 向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.GREETING.SCROLL.DOWN` | 任务 Greeting 向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.TRACK` | Gossip Greeting 滚动轨道 | `GossipGreetingScrollFrameScrollBar` 轨道 | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；可共享物理 atlas | 实机测量后定义三段纵向结构 |
| `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.THUMB` | Gossip Greeting 滑块 | 对应 ThumbTexture | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑绑定 | 实机确认拖动与四状态 |
| `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.UP` | Gossip Greeting 向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.DOWN` | Gossip Greeting 向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.DETAIL.SCROLL.TRACK` | Quest Detail 滚动轨道 | `QuestDetailScrollFrameScrollBar` 轨道 | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；可共享物理 atlas | 实机测量后定义三段纵向结构 |
| `QUEST.DIALOG.QUEST.DETAIL.SCROLL.THUMB` | Quest Detail 滑块 | 对应 ThumbTexture | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑绑定 | 实机确认拖动与四状态 |
| `QUEST.DIALOG.QUEST.DETAIL.SCROLL.UP` | Quest Detail 向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.DETAIL.SCROLL.DOWN` | Quest Detail 向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.TRACK` | Quest Progress 滚动轨道 | `QuestProgressScrollFrameScrollBar` 轨道 | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；可共享物理 atlas | 实机测量后定义三段纵向结构 |
| `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.THUMB` | Quest Progress 滑块 | 对应 ThumbTexture | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑绑定 | 实机确认拖动与四状态 |
| `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.UP` | Quest Progress 向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.DOWN` | Quest Progress 向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.REWARD.SCROLL.TRACK` | Quest Reward 滚动轨道 | `QuestRewardScrollFrameScrollBar` 轨道 | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；可共享物理 atlas | 实机测量后定义三段纵向结构 |
| `QUEST.DIALOG.QUEST.REWARD.SCROLL.THUMB` | Quest Reward 滑块 | 对应 ThumbTexture | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑绑定 | 实机确认拖动与四状态 |
| `QUEST.DIALOG.QUEST.REWARD.SCROLL.UP` | Quest Reward 向上按钮 | 对应 ScrollUpButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.REWARD.SCROLL.DOWN` | Quest Reward 向下按钮 | 对应 ScrollDownButton；需 feature-detect | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；独立逻辑 Button | 实机确认全局名与四状态 |
| `QUEST.DIALOG.QUEST.GREETING.ENTRY` | 任务 Greeting 动态条目 | 精确全局对象待 FrameXML／`/fstack` | future skin | `P0 geometry` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；不得伪造任务选框或按钮 | 取得真实对象、状态和命中区 |
| `QUEST.DIALOG.GOSSIP.GREETING.ENTRY` | Gossip Greeting 动态选项 | 精确全局对象待 FrameXML／`/fstack` | future skin | `P0 geometry` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；不得伪造交互 | 取得真实对象、状态和命中区 |
| `QUEST.DIALOG.ACTION.QUEST_GREETING_GOODBYE` | 任务 Greeting 告别按钮 | `QuestFrameGreetingGoodbyeButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生点击逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.GOSSIP_GREETING_GOODBYE` | Gossip Greeting 告别按钮 | `GossipFrameGreetingGoodbyeButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生点击逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.DECLINE` | 拒绝任务按钮 | `QuestFrameDeclineButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生拒绝逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.ACCEPT` | 接受任务按钮 | `QuestFrameAcceptButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生接受逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.GOODBYE` | 任务进度告别按钮 | `QuestFrameGoodbyeButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生关闭逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.COMPLETE` | 继续到奖励／完成阶段按钮 | `QuestFrameCompleteButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生流程不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.CANCEL` | 取消奖励交付按钮 | `QuestFrameCancelButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生流程不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ACTION.COMPLETE_QUEST` | 确认完成任务按钮 | `QuestFrameCompleteQuestButton` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；原生完成逻辑不改 | `QD-C` 生成四状态 |
| `QUEST.DIALOG.ITEM.PROGRESS` | 进行中任务所需物品槽 | `QuestProgressItem1..6` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；Icon／Count／Name 动态 | `QD-D` 生成槽底四状态 |
| `QUEST.DIALOG.ITEM.DETAIL` | 接受前奖励／需求预览槽 | `QuestDetailItem1..6` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；Icon／Count／Name 动态 | `QD-D` 生成槽底四状态 |
| `QUEST.DIALOG.ITEM.REWARD.SLOT` | 交付时可选／固定奖励槽 | `QuestRewardItem1..6` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；Icon／Count／Name 动态 | `QD-D` 生成槽底四状态 |
| `QUEST.DIALOG.ITEM.REWARD.SELECTION` | 当前奖励选择覆盖 | `QuestRewardItemHighlight`；只绑定 `this.type == "choice"` | skin | `P1 contract-draft` | [任务组件合同](QUEST_COMPONENT_SPEC.md) | — | 原生回退；唯一拥有 selected 语义的奖励对象 | `QD-D` 生成未选／已选／已选悬停 |
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
