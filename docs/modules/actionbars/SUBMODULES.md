# Action Bars 子模块定义

本文件定义动作条、姿态／宠物条，以及与战斗动作区相邻的施法／攻击读数、
DoiteDPS、消耗品、饰品栏、萨满图腾管理卫星栏和标记方阵。
Combination 绑定态采用上层顶边对齐的补给／双排动作／饰品，下层左姿态、右紧凑
标记区；标记原生内容与点击不变，仅按主条有效缩放的 `80%` 展示。
`actionbars.architotem-art` 仅登记 ArchiTotemButton 的 Earth／Fire／Water 1–5、
Air 1–7、AllTotems、Recall、PresetManager 的槽位与图标排布。施法、排序、候选
显隐、冷却、图腾持续时间、拖动柄和预设窗口仍由 ArchiTotem 持有。
美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见
[PROGRESS.md](PROGRESS.md)。本模块只接管明确列出的对象；未登记的 pfUI、
TrinketMenu 或 Blizzard 对象继续由原 provider 正常绘制和交互。

## pfUI 与客户端来源

| 文件／provider | 已证实对象与能力 | 项目处理 |
|---|---|---|
| [`modules/actionbar.lua`](../../../addon/pfUI/modules/actionbar.lua) | `pfActionBarMain`、Paging、Right、Vertical、Left、Top、四个 stance page、`pfActionBarStances`、`pfActionBarPet`；真实 Action Button、分页、冷却、快捷键、数量、范围／法力／装备／宠物自动施法状态 | 保留为唯一动作与状态 provider；只做逐对象视觉 adapter 和一次性可选布局预设 |
| [`modules/gryphons.lua`](../../../addon/pfUI/modules/gryphons.lua) | 左右端帽、纹理、尺寸、颜色、锚点与偏移 | 以后只在 `AB.ENDCAP.GRYPHON` 范围替换；窄栏或非横向布局可关闭 |
| [`modules/hunterbar.lua`](../../../addon/pfUI/modules/hunterbar.lua) | 猎人近战／远程页切换与滞回 | 行为不改写；视觉随对应真实动作页更新 |
| [`modules/castbar.lua`](../../../addon/pfUI/modules/castbar.lua) | `pfPlayerCastbar`、`pfTargetCastbar`、可选 `pfFocusCastbar`；图标、进度、法术名、计时、延迟与独立 mover | 保留为唯一施法数据／交互 provider；本模块只提出战斗焦点邻接位置与以后独立授权的细 Rail 外观 |
| [`modules/swingtimer.lua`](../../../addon/pfUI/modules/swingtimer.lua) | `pfSwingTimerMainhand`、随主手锚定的 `pfSwingTimerOffhand`、独立 `pfSwingTimerRanged` 与可选 Range Indicator | 攻击识别、主副手／远程互斥、计时和 Marker 行为不改写；只做邻接布局与以后独立授权的细轨外观 |
| [`api/unitframes.lua`](../../../addon/pfUI/api/unitframes.lua) 与 [`modules/targettarget.lua`](../../../addon/pfUI/modules/targettarget.lua) | `pfUI.uf.player`、`pfUI.uf.target`、`pfUI.uf.targettarget`；状态、Aura、目标切换、右键与 mover | 保留为唯一单位数据／交互 provider；focus preset 只写当前 profile 的尺寸、Aura 方向和一次性游戏坐标。TargetTarget 依附 Target，独立 mover 仅在绑定态隐藏，不删除 movable 登记 |
| [`api/api.lua`](../../../addon/pfUI/api/api.lua) | `BarLayoutSize`、`BarLayout`、`UpdateMovable` | 作为尺寸公式、排列与自由拖动权威 |
| [`api/config.lua`](../../../addon/pfUI/api/config.lua) 与 [`modules/gui.lua`](../../../addon/pfUI/modules/gui.lua) | 每条 Bar 的启用、按钮数、图标尺寸、间距、行列、空槽、自动隐藏与战斗显示配置 | 保留并扩展外观入口，不强写用户 profile |
| Turtle WoW `mark1..mark8` unit token 与 `SetRaidTarget／GetRaidTargetIndex／TargetUnit` | 直接解析八种团队标记当前对应单位、名字、生死与血量，并执行原生设标／取消／选中 | 作为 `AB.MARKER.GRID` 的唯一数据与操作 provider；不复制 GRTT 通讯数据库，也不采用 Banana 的 `0.1s × 40` 团队目标扫描 |
| 可选 HDLRaidTools `0.9` 的 `HDLUI.SJQKAmark／markToUid` 与 SuperWoW 原始 GUID | 以当前未标记目标的精确刷怪 GUID 查找已登记怪群，并按表中顺序一次标记同组目标 | 作为 `AB.MARKER.BULK` 的唯一怪群数据库与执行 provider；AEUI 只增加入口、依赖／权限检查、反馈和原目标恢复，不复制或维护其大型 GUID 表 |

目标客户端还证实存在以下可选 provider；它们不是仓库依赖，也不复制其实现：

- TrinketMenu `3.3`：`TrinketMenu_MainFrame`、`TrinketMenu_Trinket0`（装备槽
  `13`）、`TrinketMenu_Trinket1`（装备槽 `14`）、`TrinketMenu_Menu1..30`、
  冷却与 `18×18 UI` 战斗排队 inset。该插件在当前角色上启用。
- DoiteDPS：`DoiteDPSMainFrame` `318×46 UI`、`DoiteDPSTimelineTrack`、
  `DoiteDPSReadySlot` `46 UI`、Forecast 图标 `34 UI` 与资源框 `178×22 UI`；
  插件自身保存位置、scale、锁定、战斗显隐、推荐、ETA、资源和冷却。
- ArchiTotem `1.7`：`ArchiTotemFrame`、四枚当前元素 Button、Earth／Fire／Water
  各最多 `5` 与 Air 最多 `7` 枚候选、独立 `20×20 UI` 拖动球、
  `ArchiTotemButton_AllTotems`、可选 Recall／PresetManager Button 及独立
  `350×450 UI` 预设管理框。该插件只在萨满角色按自身配置显示，并继续负责施放、
  右键跳过、悬停候选、冷却／倒计时、顺序、锁定、方向和预设。

## pfUI 十二条逻辑 Bar

| 逻辑号 | Frame／职责 | 基础能力 |
|---:|---|---|
| `1` | `pfActionBarMain`／主动作页 | 1–12 个按钮、分页、快捷键、战斗核心 |
| `2` | `pfActionBarPaging`／显式第二页 | 1–12 个按钮、独立移动或隐藏 |
| `3` | `pfActionBarRight` | 1–12 个按钮；常用 `6×2`／`4×3` |
| `4` | `pfActionBarVertical` | 1–12 个按钮；常用 `1×12`／`4×3` |
| `5` | `pfActionBarLeft` | 1–12 个按钮；常用 `6×2`／`4×3` |
| `6` | `pfActionBarTop`／副动作层 | 1–12 个按钮；可与主栏相邻 |
| `7–10` | `pfActionBarStanceBar1..4`／姿态分页动作页 | 不是额外固定可见按钮墙；随姿态切换真实 action page |
| `11` | `pfActionBarStances` | 最多 10 个真实姿态／形态 Button |
| `12` | `pfActionBarPet` | 最多 10 个真实宠物动作 Button 与自动施法状态 |

pfUI 的合法矩形布局由按钮数因数决定；12 格支持 `12×1`、`6×2`、`4×3`、
`3×4`、`2×6`、`1×12`。项目不得把视觉外壳限定为某一种行列。

## 动作条视觉对象

| ID | 真实对象 | 合同 |
|---|---|---|
| `AB.RAIL` | 每个已启用且 `background="1"` 的 `pfActionBar*` 的 `bar.backdrop`；满足 pfUI 原条件时 Bar 1／6 改用 `bar1.mergedBackdrop` | 单一 normal 态自适应九宫格；独立背景在 Bar Frame 四周各外扩 border，合并背景只画整体外围且无内部中缝；尺寸严格来自 provider 公式；随父 Frame 拖动／缩放／显隐，不接收鼠标，不包含格线、图标、文字或状态 |
| `AB.SLOT` | Bar `1–10` 的 `pfActionBar<BarName>Button1..12` 及其逐按钮 `backdrop` | 单一普通／空槽基底；贴合 provider 的 `icon_size + 2×border` 外框，真实图标、快捷键、数量、宏名和冷却保持动态 |
| `AB.SLOT.STATE` | `f.highlight`、`f.active`、`f.equipped`、`f.icon` 顶点色、`f.cd` 与按键动画 | 悬停和按键按下复用 highlight／动画，当前技能使用 active；装备、不可用、range、OOM 与 cooldown 独立动态。不得虚构 disabled Button cell 或把职业色、红／蓝／绿状态烘焙进基底 |
| `AB.ENDCAP.GRYPHON` | `pfGryphonLeft`、`pfGryphonRight` | 成对香草狮鹫端帽；仅装饰、不吃点击；水平主栏宽度不足或用户关闭时不显示 |
| `AB.STANCE` | Bar `11` 的真实形态按钮 | 较小但保持可读；不生成不存在的职业形态 |
| `AB.PET` | Bar `12` 的真实宠物按钮 | 保留攻击、跟随、停留、技能与自动施法反馈 |
| `AB.MOVER` | pfUI unlock／`UpdateMovable` | 默认每个 Bar 独立移动、缩放、重置；`AB.SIDEBARS.GROUP` 绑定态只扩展 Bar 2 mover 覆盖四栏 union，并在同一 unlock／UpdateConfig 事件边界同步 scale／相对锚。不得删除任何 movable 登记，也不得用 `OnUpdate` 持续改写 Parent、Point、Width 或 Height |

`AB.SLOT.BASE.V1` 的已接受母版为
[ActionSlotBase_Master_v1.png](../../../assets/source/actionbars/ab-slot/ActionSlotBase_Master_v1.png)，
source manifest 为
[AB-SLOT-BASE-V1_SourceManifest_v1.json](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_SourceManifest_v1.json)。
P5 runtime manifest 为
[AB-SLOT-BASE-V1_RuntimeManifest_v1.json](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_RuntimeManifest_v1.json)，
客户端只加载
[ActionSlotBaseV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionSlotBaseV1.tga)
与 [ActionBars.lua](../../../addon/AzerothExpeditionUI/Modules/ActionBars.lua)。adapter
feature-detect `pfUI.bars[1..10][1..12]`，把单一 full-UV `ARTWORK` 子纹理挂在
每个既有 `button.backdrop` 上；不加载 `1024²` source，不创建新 Button，也不
覆盖原 backdrop。媒体缺失、对象缺失或 `/aeui actionbars` 关闭时，pfUI 原生
backdrop 继续 fail-open。Bar `11／12` 明确排除；图标、文字、冷却、状态覆盖、
Button 脚本、命中区、分页、拖放、位置、尺寸和 SavedVariables 仍完全归 pfUI。

`AB.RAIL.V1` 的已接受 normal 态九宫格母版为
[ActionRail_Master_v1.png](../../../assets/source/actionbars/ab-rail/ActionRail_Master_v1.png)，
source manifest 为
[AB-RAIL-V1_SourceManifest_v1.json](../../../assets/source/actionbars/ab-rail/AB-RAIL-V1_SourceManifest_v1.json)。
P5 runtime manifest 为
[AB-RAIL-V1_RuntimeManifest_v1.json](../../../assets/source/actionbars/ab-rail/AB-RAIL-V1_RuntimeManifest_v1.json)，
客户端只加载
[ActionRailV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionRailV1.tga)
与同一 [ActionBars.lua](../../../addon/AzerothExpeditionUI/Modules/ActionBars.lua)。
exporter 把 `[160,160,864,864)` 的完整 `704²` crop 等比缩小一次为 `176²`，
置于 `256²` power-of-two atlas 的 `[40,40,216,216)`；runtime 九宫格边界为
`40／72／184／216`，UV 为 `0.15625／0.28125／0.71875／0.84375`，端宽固定
`6 UI`。adapter 在 Bar `1–12` 现有 `bar.backdrop` 上各挂九枚 `OVERLAY` 纹理；
满足 pfUI 原条件时，Bar `1／6` 的两个独立背景由 provider 隐藏，只显示
`bar1.mergedBackdrop.backdrop` 上的一块外围 Rail。所有纹理随父 Frame 显隐、
移动与缩放，不接收鼠标，也不在维护循环改写 provider 几何。媒体／对象缺失或
`/aeui actionbars` 关闭时，未删除的 pfUI 原生 backdrop 继续 fail-open；Button、
状态、分页、拖放与 SavedVariables 均不变。

## 战斗焦点邻接对象

这些对象加入同一推荐布局，但逻辑所有权不转移给动作条 adapter。AEUI `0.8.9`
提供 `/aeui focuslayout apply` 一次性位置 preset，以及显式
`/aeui focuslayout comfort` 舒适缩放＋位置 preset；任何视觉接管仍须以后按对象
独立授权并 feature-detect，失败时保留 provider 原样。

| ID | provider／真实对象 | 合同 |
|---|---|---|
| `AB.FOCUS.UNITFRAME.PLAYER` | `pfUI.uf.player` | 保持 `240×48 UI / scale 0.8` 与 `BOTTOM (-160,480)`；`23 UI` Buff 在上、Debuff 在下，从左向右且每排 `8` 枚。Buff 仅保留当前技能书同名光环，Debuff 全部保留；先扫描全部 `32` 槽再压缩，不改变 Tooltip、冷却、取消 Buff 与 provider Button |
| `AB.FOCUS.UNITFRAME.TARGET` | `pfUI.uf.target` | 保持 `240×48 UI / scale 0.8` 与 `BOTTOM (105,480)`；Aura 从右向左且每排 `8` 枚。敌对目标保留全部真实 Buff，Debuff 为自己施加与固定关键表的并集；关键表仅含精灵之火、精灵之火（野性）、破甲攻击、破甲、雷霆一击、挫志怒吼及虚弱／鲁莽／元素／暗影／语言／疲劳诅咒。友方目标保留全部真实 Buff／Debuff。与 Player 间距、目标交互和动态 Aura 仍归 provider |
| `AB.FOCUS.UNITFRAME.TARGETTARGET` | `pfUI.uf.targettarget` | 保持 `240×60 UI / scale 0.68`、`LEFT → Target RIGHT +8 UI` 与右向左每排 `8` 枚 Aura；每次刷新按当前敌友关系复用 Target 语义策略，显隐、移动和 unlock 仍归 provider |
| `AB.FOCUS.UNITFRAME.FOCUS` | `pfUI.uf.focus` | 不接管既有几何或外观，只按 Focus 当前敌友关系复用 Target 语义策略；GUID 与 Buff 归属继续由 Nampower／pfUI 提供。对象、Nampower 或归属 API 缺失时不创建占位并 fail-open |
| `AB.FOCUS.NAMEPLATE.AURA` | `pfUI.nameplates` 的既有 `nameplate.debuffs[1..16]` | “聚焦光环显示”开启时向姓名板共享 Target 敌友策略：先扫描 `32` 个 Debuff 源槽并压缩符合项，再用剩余格显示符合项的真实 Buff；关闭配置、Action Bars route 禁用或策略 API 缺失时恢复 pfUI 原前 `16` 个 Debuff 逻辑。Frame、布局、计时和显隐仍归姓名板 provider |
| `AB.FOCUS.CASTBAR.PLAYER` | `pfPlayerCastbar` | `260×12 UI / scale 1.0`；`BOTTOM (0,316)`，位于统一中心轴的第一排。保留图标、法术名、计时与玩家延迟区 |
| `AB.FOCUS.CASTBAR.TARGET` | `pfTargetCastbar` | `260×12 UI / scale 1.0`；`BOTTOM (0,300)`，位于统一中心轴的第二排。保留可打断／不可打断与目标施法信息 |
| `AB.FOCUS.CASTBAR.FOCUS` | 可选 `pfFocusCastbar` | 继续跟随 Focus Frame，默认不进入中央玩家／目标双框；对象不存在时无占位 |
| `AB.FOCUS.SWING.MELEE` | `pfSwingTimerMainhand`＋`pfSwingTimerOffhand` | 主手 `260×12 UI / scale 1.0`，`BOTTOM (0,284)`，位于统一中心轴的第三排；副手同尺寸并以 `2 UI` 间距紧贴主手下方。文字、攻速与 Marker 动态 |
| `AB.FOCUS.SWING.RANGED` | `pfSwingTimerRanged` | 与主手同为 `260×12 UI / scale 1.0` 并复用第三排，不与近战双条组成另一条常驻栏；范围提示仍由 provider 管理 |
| `AB.DOITEDPS.TIMELINE` | 可选 `DoiteDPSMainFrame` 及子 Frame | 保留原生 `318×46 UI` 根与 `178×22 UI` 资源排、独立锁定／显隐与蓝绿状态语义；所有角色的运行时锚点统一为 `TOPLEFT (650,-615)`，只同步锚点／坐标并保留各角色 scale 与其他 DDPS 配置；comfort preset 仍以 `0.82` 作为目标显示补偿，锁定态继续由 provider 关闭鼠标 |
| `AB.TOTEM.ARCHITOTEM` | 可选 `ArchiTotemFrame`、四元素主 Button、元素候选、拖动球、AllTotems 与可选 Recall／PresetManager | 用户已接受 `ACTION-BARS-CORE-SIM-V4`。闭合真实可见 union 作为职业卫星栏置于 Combat Deck 下方，并相对旧居中位整体左移 `128 UI`；provider `scale=0.8` 时当前闭合脚印为 `212×32 UI`、Air 七层最大展开为 `212×224 UI`，四个元素的向下候选列均停在 Target Markers 皮革 icon list 左侧。`fieldKitBound=true` 时随 Bar 1，拖动松手回位，`unbind` 恢复首次自由锚点；显式 focus preset 才调用 provider 原生 API 请求向下展开，普通 refresh 只读取方向。施放、右键、hover、计时、锁定、方向、预设与 Tooltip 不接管；缺失、非萨满、隐藏或签名不匹配时无占位并 fail-open |

## 标记方阵

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.MARKER.GRID` | `AzerothExpeditionUIMarkerGrid` 与八个 AEUI Button；数据来自 `mark1..mark8` | 固定 `4×2`，每格为透明 `48×48 UI` 命中位、间距 `3 UI`，八格下方共用一块外扩 `6 UI` 的缝制皮革九宫格；顺序为骷髅／叉／方块／月亮／三角／菱形／圆／星。八个位置始终稳定：未使用格在中央显示 `30×30 UI` 原生团队标记；已有存活目标时切换为左下 `15×15 UI` 满亮标记与轻微暗影，顶部显示两行真实名字，超长名字从 `10 UI` 降至 `9 UI`，右下显示血量百分比，底部为 `3 UI` 窄血条；死亡目标直接按本地空态绘制。标记身份与文字不再互相覆盖。整个方阵固定为 `BACKGROUND` strata，低于 ArchiTotem 的 `LOW` 主 Frame，作为未知 provider scale 下的防御性回退；正常绑定布局不再依赖重叠区抢占鼠标。ArchiTotem 可见时沿用其闭合主行的垂直锚点，但以 `128 UI` 反向水平补偿保持既有 Combat Deck 位置，使四元素候选列与皮革 icon list 横向分离；否则若真实姿态／宠物栏位于主栏下方则接在该栏下方；再否则直接占用主栏下方预留的职业卫星位置。没有独立 mover，不以 `OnUpdate` 改写任何 Frame 几何 |
| `AB.MARKER.TANK` | 方阵左侧 `AzerothExpeditionUIDDPSTankButton`；可选 provider 为 DDPS 的 `SetTankAssistFromUnit`／`ClearTankAssist` | `48×48 UI` 盾牌 Button 复用 accepted 图集 B 薄皮口袋；左键把当前队伍／团队玩家交给 DDPS 设为协助坦克，右键清除。状态色与 Tooltip 只读取 DDPS 的公开状态 API；目标切换、手动敌对目标优先级、SavedVariables 和输出循环继续完全由 DDPS 持有。Button 是方阵 Frame 真实宽度内固定的左槽，Action Bars／Markers 启用时始终显示；DDPS 尚未加载或版本过旧时保留红色不可用态并只给出反馈，装饰或状态刷新异常时降级为基础盾牌而不再隐藏。它复用方阵锚点链且没有独立 mover；Combat Deck／Combination 随 Bar 1 移动时整体跟随 |
| `AB.MARKER.CELL` | 对应 `markN` unit token 与原生团队标记 API | 左键只选中当前已解析的标记目标；右键只把当前目标设为该标记，同标记再次右键取消；`Shift+右键` 清除该标记，这些显式操作在团队中仍遵守队长／团长／助理权限。已标记目标死亡时只把 AEUI 本地格退回空态并从活动计数移除，不调用 `SetRaidTarget`、不要求权限，也不修改世界中或其他插件看到的真实团队标记；标记重新解析为存活目标时再次显示。名字、血量和选中态由事件刷新，并仅以 `0.50s` 数据轮询补偿标记目标进入范围却不触发事件的情况；不扫描 `raid1..40 target`，不广播插件消息，不接管 GRTT／Banana 的 Frame 或 SavedVariables |
| `AB.MARKER.BULK` | 方阵右侧独立 `48×48 UI`“一键标记”Button；可选 provider 为 HDLRaidTools／SuperWoW | 左键以当前未标记目标触发 `HDLUI.SJQKAmark()`；调用前验证 provider、原始 GUID、登记怪群与团队标记权限，调用后以原始 GUID 恢复目标并报告怪群编号／登记数量。只有 `SUPERWOW_VERSION`、`HDLUI.SJQKAmark` 与 `HDLUI.markToUid` 全部就绪时才把 Button 纳入模块真实宽度并显示；任一依赖缺失或 Button 异常时隐藏并收回右侧占位，手动八格保持居中可用；不复制 `markToUid`、不猜测未登记怪群、不自动启用外部插件 |

`TargetMarkers runtime 2.3` 位于
[TargetMarkers.lua](../../../addon/AzerothExpeditionUI/Modules/TargetMarkers.lua)，
复用 accepted [ActionConsumableKitV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga)
的 C 九宫格作为八格共用的连续皮革底板，并用 B 薄皮口袋承载 Frame 边界内的
固定左侧 DDPS 坦克 Button 与右侧条件式一键 Button；
不修改图集像素、UV 或 Supply 的既有用法，也不新增媒体。八个真实 Button 不再
各画独立方框。`/aeui markers
on|off|toggle|status` 只写 AEUI 的 `markersEnabled`；关闭整个 Action Bars route 时
方阵同步隐藏。`markN` 暂时无目标或超出 token 可解析范围时对应格退回空态；原生
API 缺失或调用失败不会阻止其他 Action Bars 组件加载。DDPS 只作为左侧坦克
Button 的可选功能 provider；接口缺失时 Button 保持可见的不可用态。
HDLRaidTools／SuperWoW 只作为右侧一键 Button 的可选 provider；外部
GRTT／Banana 若仍启用则保持独立，AEUI
不自动关闭或改写任何外部插件。

## AEUI 补给栏

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.SUPPLY.RACK` | AEUI 自有 `AzerothExpeditionUISupplyFrame`＋最多 `24` 个命名补给组 Button | `supplies-contract=2.1`；每组独立占用 `1–24` 的固定位置并保存稳定顺序的最多 `12` 个精确 itemID 与一个显式 `primaryItemId`，空位置不会在重载时被压紧。主格左键只使用固定主物品，缺货时不自动切换；右键或悬停 `0.30s` 展开 AEUI 自有抽屉。候选左键只使用且不改变主格，右键只设主格且不消耗。每次背包事件单次扫描 Bag `0–4`，主格与候选数量固定在右下角：`0` 为红色并暗化图标，正库存为白色。Button 为 `36 UI / gap 3 UI`、最多 `4×6`、自底向上，复用 accepted A 口袋与 C 九宫格；候选复用 B 口袋与 D 连接带，`1–6` 单列、`7–12` 双列且最多六行。绑定时位于主栏左侧，解绑时保留自由位置并允许 `Shift+拖动`；只在弹层意图／关闭待处理时短暂启用计时 Frame |
| `AB.SUPPLY.CONFIG` | `AzerothExpeditionUISupplyManager` 与 `AzerothExpeditionUIDB.actionbars.supplyProfiles[角色名 - 服务器]` | `/aeui supplies` 打开每角色管理面板；左侧 `24` 个固定位置均可创建／选择组，右键目标格可移动或交换，前移／后移也可进入空位。右侧管理组名、最多 `12` 个成员、显式主物品与稳定顺序。只接受真实背包拖入；同组重复 itemID 只定位不复制，同一 itemID 可独立加入多个组，保存前先清空光标让物品回包。配置不保存物品名称、图标、库存、冷却或 bag／slot；旧 `minimum` 仅为数据兼容保留且不再读取，旧单物品槽原位迁移，旧 `target` 丢弃。支持 `on|off|toggle|remove|status|selfcheck` |
| `AB.SUPPLY.ROUTE` | Action Bars 总 route、`suppliesEnabled` 与 `fieldKitBound` | Supply 是主栏左侧唯一补给实现。没有有效组或显式关闭时左侧补给位为空，不加载或回退到外部消耗品栏；关闭 Action Bars 总 route 时 Supply 隐藏。Field Kit `3.0` 只编排 Supply、TrinketMenu、姿态／宠物条与 ArchiTotem |

用户于 `2026-08-09` 接受 `AB.CONSUMABLE.KIT.V1` 第 1 稿。P4 source 为
[ActionConsumableKit_Master_v1.png](../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)
（SHA-256 `623f29c5…a2419`），[manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json)
固定 A 主口袋、B 候选口袋、C 自适应卷袋外壳与 D 连接带。确定性 exporter
将其打包为
[ActionConsumableKitV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga)
（`512² RGBA`，文件 SHA `c48f6292…320e`、像素 SHA `658f826f…e30d`），合同见
[runtime manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json)。
该 accepted 图集继续由 Supply 与 Target Markers 共用，不因旧外部 provider 移除而改动像素或 UV。
`/aeui fieldkit bind|unbind|home|status` 分别负责绑定、释放、恢复 Combat Deck
位置与查询，只写 AEUI 自己的 `fieldKitBound`。

## 饰品双槽

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.TRINKET.DOCK` | 可选 `TrinketMenu_MainFrame`；缺失时不显示占位栏 | 水平严格 `92×52 UI`、垂直严格 `52×92 UI`；两枚 `36×36 UI` 真实已装备饰品，主栏 scale／方向与 resize 继续归 provider；实际图标、快捷键、冷却与 Tooltip 动态。强绑定态位于主动作条右侧、左缘距主栏右缘 `8 UI`，底边与消耗品组共同落在主栏底边下 `20 UI`；provider 拖动松手后回位，`unbind` 才恢复独立位置。当前“大奶黑牛”按最初方案一次性设为水平双槽，但 adapter 不持续覆盖方向或 Queue／换装配置 |
| `AB.TRINKET.SLOT13` | `TrinketMenu_Trinket0`／`UseInventoryItem(13)` | 顶部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.SLOT14` | `TrinketMenu_Trinket1`／`UseInventoryItem(14)` | 底部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.MENU` | `TrinketMenu_MenuFrame`＋`TrinketMenu_Menu1..30` | 零候选隐藏；Button `36×36 UI`、步距 `40 UI`。VERTICAL 为 `12+列数×40` 乘 `12+ceil(数量/列数)×40`，HORIZONTAL 转置；支持自动 `1–5` 列或用户 `1–30` 列、菜单独立 scale／方向／拖动、八种停靠组合与战斗 Queue。只换肤并 fail-open |

TrinketMenu 已经接管 `UseInventoryItem`、背包更新、装备更新与排队时，AEUI 不装
竞争性的物品／换装全局 hook，只在 `OrientWindows`／`BuildMenu` 完成后刷新装饰。
没有 TrinketMenu 时 V1 不创建 Button 或占位栏；以后若新增原生装备槽 fallback
或非战斗换装入口，必须另立功能合同。

用户于 `2026-08-09` 接受 `AB.TRINKET.KIT.V1` 第 4 稿。P4 source 为
[ActionTrinketKit_Master_v1.png](../../../assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png)
（SHA-256 `82dd2260…c012`），[manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_SourceManifest_v1.json)
固定四格映射：A→两枚 `AB.TRINKET.DOCK` 已装备护套，B→候选 Button 薄插页，
C→`AB.TRINKET.MENU` filled 自适应九宫格，D→双护套短连接扣。母版只包含四个
normal 静态底面；图标、冷却、Queue、文字、命中区、拖动、scale、方向、停靠与
换装仍归 TrinketMenu。确定性 P5 exporter 把完整四格物件打包为
[ActionTrinketKitV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionTrinketKitV1.tga)
（`512² RGBA`，文件 SHA `3614d9a8…f455`、像素 SHA `0961d750…aef`），合同见
[runtime manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json)。
adapter 在既有两槽／30 候选 Button 下挂 A／B，C 以 `6 UI` 九宫格跟随菜单 Frame，
D 以横／竖三段连接两槽；关闭 AEUI 视觉时恢复原 NormalTexture 与原生 backdrop，
不替代 TrinketMenu 原有位置持久化或任何换装／Queue 行为。`fieldkit-contract=1.8`
同样把两槽与候选的 A／B 纹理放进低于真实 Button `1` 级的独立非交互装饰 Frame，
真实饰品图标、冷却和 Queue 始终位于其上。强绑定把 Bar 6、Supply 卷袋和饰品双槽
都直接锚到 Bar 1；pfUI unlock 只保留 Bar 1 作为组合移动根，移动时其余部分因相对
锚点自然跟随。重排只发生在初始化、provider 布局完成、显式命令和拖动结束，不建立
`OnUpdate` 维护循环。

## 强绑定战斗甲板与显式释放

- `战斗甲板`：Bar 1 为屏幕中下部居中 `12×1` 主栏；Bar 6 为其上方 `12×1`
  副栏；姿态／宠物条独立位于上缘；AEUI Supply 以最大 `4×6` 竖向置于左侧，
  饰品双槽在右。目标设备 V3 沿用主栏物理 `y=827`、Button 约 `39 px`、底边
  净空 `210 px`；卷袋主体为物理 `[531,673,665,870]`，与聊天框右缘净空
  `5 px`、与玩家框左缘净空 `16 px`。该 V3 reference 只保留构图历史；
  `fieldkit-contract=3.0` 直接把 Supply 与饰品底边共同放在主栏下 `20 UI`，
  Supply 的固定槽位与自由位置不改变这组绑定几何。
- `唯一移动根`：绑定态只移动 Bar 1；Bar 6 以 `BOTTOM → Bar 1 TOP` 组成无漂移
  `12×2`，Supply 与饰品双槽分别以 `12／8 UI` 间距锚到左右；检测到的
  ArchiTotem 以真实可见 union 锚在主栏下方、相对旧居中位左移 `128 UI`，垂直空隙仍为
  `39 UI`；Target Markers 反向补偿同一水平距离并留在原位。`unbind` 恢复 Bar 6、
  Supply、TrinketMenu 与 ArchiTotem 的自由位置；`home` 在 pfUI tier 8 下把 Bar 1 直接重置为游戏坐标
  `BOTTOM (0,175)` 并重新绑定。
- `pfUI unlock` 生命周期：Bar 6 始终保留在 `pfUI.movables`，不得在解锁开关期间
  动态删除／恢复登记。进入解锁后先让 pfUI 为它创建 `drag`，绑定态再只隐藏该
  独立 mover；`unbind` 时重新显示。`pfUI.bars:UpdateConfig()` 完成后在同一事件边界
  重施 Bar 6 → Bar 1 相对锚，退出解锁再确认一次。TargetTarget 同样保留 movable
  登记；focus layout 激活时，pfUI 创建其 drag 后才隐藏独立 mover，并在退出 unlock
  时重施 TargetTarget → Target 依附锚；两者都不建立 `OnUpdate` 维护循环。
- `focus-layout-contract=1.4` 曾在“大奶黑牛”实机把 `UIParent:GetWidth／Height`
  与 provider effective scale 混合，错误写入主栏 `y=149`、Player／Target
  `x=54／502, y=362` 等错位坐标；该签名现为 `game-geometry-failed`，不得作为
  合法布局复用。runtime-v1.5 又把物理 `GetScreenWidth／Height`、provider scale、
  探针与回读混入 SetPoint 换算，实机写入主栏 `x=325,y=246`、Player／Target
  `x=222／820,y=637`，同样判定 `game-geometry-failed`。runtime-v1.6 直接写
  Turtle WoW 游戏坐标，不做任何屏幕投影；TrinketMenu 仍为
  `HORIZONTAL / scale=1.0`，Field Kit v1.7 强绑定和 ArchiTotem 下置不变；v1.7
  只修复 unlock mover 登记／drag 生命周期。
- `战斗视线邻接`：Player／Target／TargetTarget／Focus 继续由 pfUI UnitFrame provider 所有；
  focus runtime-v3.5 保持 Player／Target 游戏坐标
  `BOTTOM (-160,480)／(105,480)`，两框设为 `240×48 / 0.8`，在完整框体之间
  保留 `73 UI`；TargetTarget 保持 `240×60 / 0.68`，fallback 为
  `BOTTOM (393,570)`，live Frame 以
  `LEFT → Target RIGHT +8 UI` 中线
  依附。三框仅本地启用客户端 `STANDARD_TEXT_FONT / OUTLINE / 18 UI` font，并直接
  写入六个 health／power FontString（Player 另含 top-center），在 provider
  `UpdateConfig` 后置钩子中重施；Aura 均为 `23 UI`，
  Player 上 Buff／下 Debuff 从完整框架左缘向右展开，Target 与 TargetTarget 从
  右缘向左展开。
  当前 `default_border=3` 且 `force_blizz=0`，故按 pfUI 真实 `size + 7` 步距，
  Player／Target 每排 `8` 枚实际占 `233 UI`，连同 Aura backdrop 匹配
  `240 UI` 框宽；TargetTarget 同样每排 `8` 枚。Aura 策略先扫描 `32` 个来源槽再
  压缩：Player 为技能书 Buff／全部 Debuff；敌对单位为全部真实 Buff／自己施加或
  固定 `12` 项关键 Debuff；友方单位为全部真实 Buff／Debuff，Focus 只接入策略而不改几何。
  姓名板在 pfUI 配置的“聚焦光环显示”开启时复用同一 Target 敌友策略，并优先
  保留 Debuff；关闭该项即恢复原有全部 Debuff 路径。
  四个 offset 明确置零；Action Bars 关闭或 provider 缺失时恢复 pfUI 原显示。
  adapter 不重画，不在维护循环中持续改位置。`focus-unit-default-v5` 按
  `角色名 - 服务器` 保存独立版本和应用前备份；每个启用 AEUI Action Bars 的
  角色首次加载时只应用一次这三个单位框的尺寸、Aura、字体和坐标，后续刷新
  不覆盖手调结果。
- `战斗信息纵栈`：玩家施法、目标施法、Swing 主手／ranged 统一为
  `260×12 / 1.0`，全部使用 `x=0`，依次落在 `BOTTOM y=316／300／284`；副手
  同尺寸以 `2 UI` 间距紧贴主手下方。姿态置于 `BOTTOM (0,255)` 并使用 local scale
  `1.0`，相对旧 `0.72` 线性放大 `38.9%`；
  DoiteDPS 时间线与资源两排作为整体置于 `TOPLEFT (650,-615)`，保持原纵向安全带
  并相对 runtime-v2.5 整体左移 `200 UI`；Focus
  施法条继续跟随 Focus Frame。所有数值均为 Turtle WoW 游戏坐标，不读取或回算
  屏幕像素、UIParent 尺寸或 provider effective scale。
- `紧凑战斗`：主／副栏可改为 `6×2`；自适应 Rail 重新切片，狮鹫端帽缩小或
  隐藏，逻辑按钮数与分页不变。
- `右侧四栏组合`：用户已确认 V11 方案。`AB.SIDEBARS.GROUP runtime-v1.0` 把
  `bar2 Paging／bar4 Vertical／bar5 Left／bar3 Right` 映射为阅读顺序的 `2×2`
  四块，每块 `3×4`、总体 `6×8`，初始 scale `1.2`、组间距 `6 UI`；接受的 fallback
  坐标依次为 `RIGHT (-133,-68)／(-35,-68)／(-133,-196)／(-35,-196)`。仅
  “大奶黑牛 - Basin of Stars”完整匹配原 `1×12` 四列签名时自动迁移；状态按角色／
  服务器隔离。绑定态只显示覆盖 union 的 Bar 2 group mover，滚轮缩放和拖动在事件
  边界同步四框；Bar 4／5／3 movable 登记保留但隐藏，避免 `drag=nil`。动作内容、
  按键、分页、显隐、脱战淡出、冷却和命中仍逐栏独立；`/aeui sidebars unbind`
  精确恢复绑定前 formfactor／icon／spacing／scale／position，绑定期间的内容配置保留。
- `透明度与命中`：玩家／目标状态、双方施法、攻击计时、DoiteDPS 与技能 CD
  使用 provider 原生 Alpha，不做整组淡出；只允许非核心辅助栏按用户设置脱战
  淡出。Rail、连接片、卷袋、护套和标题等装饰层全部鼠标穿透，DoiteDPS 锁定态
  沿用 provider 的根 Frame 鼠标穿透；不增加覆盖中央视野的大型透明 Frame。
- `舒适缩放`：目标设备保持客户端 `1920×1080`，不由本模块修改分辨率；用户
  显式执行 `comfort` 时只把当前 pfUI profile 设为
  `Tiny PixelPerfect / tier 8 / 0.71111111111111`。Combat Focus 另用 local
  scale：Player／Target `0.8`、TargetTarget `0.68`、施法／Swing `1.0`、姿态 `1.0`、
  DoiteDPS `0.82`。不把
  `UIParent:GetWidth／Height` 或 `GetScreenWidth／Height` 当作 SetPoint 根；一次性
  `game-native-v1` 坐标签名按角色保存。强绑定甲板关系保持原样。普通刷新不改
  pfUI scale；三个单位框使用上述每角色一次性默认，旧 copied profile 的精确
  签名迁移只保留为兼容路径。
- `home` 预设只在用户明确执行时写入一次。默认读取并尊重现有 profile、主栏位置、
  scale、按钮数、行列、自动隐藏和空槽设置；V3 继续默认关闭狮鹫，unlock 时
  仍可为足够宽的水平主栏单独开启。DoiteDPS 的锁定／战斗显隐／Forecast／资源／
  冷却选项不由此 preset 改写；DoiteDPS 的 local scale 在 comfort preset 中
  明确收敛为 `0.82`，其启用／锁定／显隐与推荐逻辑不变。首次应用前保存相关
  pfUI／DoiteDPS／ArchiTotem 配置；`/aeui focuslayout restore` 恢复 DDPS 的 scale
  与其他 provider 配置，但其位置仍按全角色合同统一为 `TOPLEFT (650,-615)`，
  完成后提示 reload。
- `ACTION-BARS-CORE-SIM-V11` 以“大奶黑牛”的实机截图完成确定性本地审查；AEUI
  focus runtime-v3.5 保留 V11 Combat Deck、读条与 DoiteDPS 纵向安全区，把所有角色的
  DDPS 整组统一到 `TOPLEFT (650,-615)` 清出中央视野，并保留各角色 scale、
  功能配置与三框 FontString
  刷新修复，并按战士实机反馈把真实 `bar11.icon_size` 提为 `25 UI`、local scale
  提为 `1.0`。exact v17–v20 签名在 `/reload` 一次迁移为 v21；Player／Target 恢复为
  `240×48 / y=480 / 每排 8 Aura`，为 `32` 枚 Debuff 预留四排净空，TargetTarget
  同样保持 `8` 枚一排，下方三条读条与 Combat Deck 坐标不移动；同一单位框合同按角色首次加载自动
  应用并保存独立回退备份；
  DDPS 坐标按用户要求统一，其余手调坐标保持不动。
  用户已确认右侧四栏 `2×2 / 3×4`
  方案，现由独立 `sidebar-group-contract=1.0` 接入，不修改任何位图。
- `ACTION-BARS-CORE-SIM-V10` 以“大奶黑牛”的上一轮实机问题截图完成确定性本地审查；
  AEUI `0.8.18`／focus runtime-v2.1／Field Kit bridge-v2.0 保留 tier 8、Combat Deck、
  accepted art 与 provider 行为，只把单位族整体上移、Aura 收为真实八枚满行的
  `23 UI`，并把消耗品／饰品底边共同下移 `20 UI`；TargetTarget `0.68`、计时栈
  `1.0` 与姿态 `0.72` 不变。仅未被手动调整的 exact v7／v8／v9／v10／v11 签名，
  在 `/reload` 时一次性迁移为 v12；显式
  focus preset 才写入固定游戏坐标并请求 provider 方向，普通
  refresh 只在模块 Apply／unlock 事件边界恢复既有相对锚，不持续维护几何。

## 功能不变量

- 技能、宏、物品、宠物动作、分页、姿态、快捷键、数量、冷却、范围、法力、
  装备态、拖放、Tooltip 与右键语义继续由真实 provider 负责。
- 施法识别、延迟、可打断状态、主／副手／远程攻击识别、DoiteDPS 推荐／ETA／
  资源／冷却继续由各自 provider 负责；本模块不复制算法或制造假读数。
- ArchiTotem 的图腾施放、右键跳过、候选顺序、hover 展开、倒计时、锁定、方向、
  Recall、预设和 Tooltip 继续由 ArchiTotem 负责；本模块不得复制图腾数据库或
  创建替代 Button。
- Bar 1、用户标记的战斗核心 Bar、消耗品核心口袋和两枚饰品在战斗中不得因
  mouseover 延迟而消失；非核心辅助栏才可选择脱战淡出。
- 自动隐藏只能改变可见性／Alpha，不在维护循环中搬动或改尺寸。
- 可选 provider 缺失、版本不匹配或 adapter 出错时，局部恢复其原始视觉与
  功能；不得阻止 pfUI 或 AEUI 其余模块加载。
- 不把技能图标、物品图标、文字、数字、键位、冷却、职业状态或真实按钮烘焙
  进背景资产。

## TargetTarget／Focus Aura 显示同步

`pfUI_config.unitframes.ttarget` 与 `focus` 的 Buff／Debuff 锚点、尺寸、每排数量、
偏移、数量上限、过滤模式及名单、selfdebuff 跟随 `target`；图标尺寸按有效
缩放比换算以匹配屏幕大小，每排数量按实际宽度和 pfUI 边框间距限制在 Target
列数以内。只调整 Aura 配置，
不接管两框位置与大小。原字段按角色保存在
`AzerothExpeditionUIDB.actionbars.secondaryAuraBackups`，禁用时恢复。
筛选继续共用 `FocusAuraPolicy`；真实 Aura、图标、层数、冷却与 Tooltip 由 pfUI 提供。

## ReadoutArt 细轨 V1

`actionbars.readout-art` 对应 `pfUI.castbar.player/target/focus.bar` 及独立 `icon`，
`pfUI.swingtimer.mainhand/offhand` 和 `ranged.left/right/warn`。完整外壳按
`4/254/4 × 1/12/1` 九切片，外扩1 UI，四角固定，锚点跟随 provider 的真实大小。
图标、动态文字、延迟区、引导进度、近战填充和远程分区／警告／Marker 全部归 pfUI；
AEUI 只换填充材质、静态外缘与空槽底，隐藏原 backdrop/shadow。禁用恢复原材质
及显隐，不接管其他第三方施法条。没有新增几何维护循环。

`actionbars.doite-art` 只接管 `DoiteDPS.UI` 公开的 readySlot、currentIcon、
currentGhost、forecastIcons、resourceRoot、resourceIcons、tankAssistBadge 外缘，
以及 track 下的静态窄轨。复用 Readout V1；动态图标、状态颜色、文字、轨迹、
预测和执行继续由 DoiteDPS 持有。禁用 Action Bars 恢复原生 backdrop 与最新状态色，
DoiteDPS 缺失时跳过。当前槽装饰锚到 currentIcon，readySlot 的逻辑几何保持原样。

`actionbars.doiteauras-art` 对应 DoiteAuras 已登记 spells 的 `DoiteIcon_<key>`
图标外缘，排除 `type=Bar` 与配置窗口。通过公开 GetIconFrame／边框刷新入口
接入新建图标和重建边框；位置、尺寸、分组、图标、特效及文字全部归 provider。
禁用 Action Bars 恢复 provider 边框，缺失 DoiteAuras 时跳过。
