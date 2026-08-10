# Action Bars 子模块定义

本文件定义动作条、姿态／宠物条，以及与战斗动作区相邻的施法／攻击读数、
DoiteDPS、消耗品、饰品栏和萨满图腾管理卫星栏。
美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见
[PROGRESS.md](PROGRESS.md)。本模块只接管明确列出的对象；未登记的 pfUI、
AutoBar、TrinketMenu 或 Blizzard 对象继续由原 provider 正常绘制和交互。

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

目标客户端还证实存在以下可选 provider；它们不是仓库依赖，也不复制其实现：

- AutoBar `1.31`：`AutoBarFrame`、`AutoBarFrameButton1..24`、
  `AutoBarPopupFrame_Button1..12`、真实背包物品、数量、冷却、四向线性分类弹出
  与独立拖动把手。该插件已安装但在当前角色上禁用，项目不得自动启用。
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
| `AB.MOVER` | pfUI unlock／`UpdateMovable` | 每个 Bar 独立移动、缩放、重置；视觉不得持续改写 Parent、Point、Width 或 Height |

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
| `AB.FOCUS.UNITFRAME.PLAYER` | `pfUI.uf.player` | `240×60 UI / scale 0.68`；`BOTTOM (-190,500)`。Buff 在上方从左向右，Debuff 在下方从左向右；保留所有状态、点击与动态 Aura |
| `AB.FOCUS.UNITFRAME.TARGET` | `pfUI.uf.target` | `240×60 UI / scale 0.68`；`BOTTOM (190,500)`。Buff 在上方从右向左，Debuff 在下方从右向左；保留所有目标交互与动态 Aura |
| `AB.FOCUS.UNITFRAME.TARGETTARGET` | `pfUI.uf.targettarget` | `132×30 UI / scale 0.62`；live Frame 以 `LEFT → Target RIGHT +8 UI` 依附 Target。Buff 在上、Debuff 在下，均从右向左；Target 消失、移动或 unlock 后仍由 provider 显隐并在事件边界恢复依附，不建立维护循环 |
| `AB.FOCUS.CASTBAR.PLAYER` | `pfPlayerCastbar` | `180×16 UI / scale 0.72`；与 Swing、目标施法处于同一横排左列，而非玩家框下方。保留图标、法术名、计时与玩家延迟区 |
| `AB.FOCUS.CASTBAR.TARGET` | `pfTargetCastbar` | `180×16 UI / scale 0.72`；与玩家施法、Swing 处于同一横排右列。保留可打断／不可打断与目标施法信息 |
| `AB.FOCUS.CASTBAR.FOCUS` | 可选 `pfFocusCastbar` | 继续跟随 Focus Frame，默认不进入中央玩家／目标双框；对象不存在时无占位 |
| `AB.FOCUS.SWING.MELEE` | `pfSwingTimerMainhand`＋`pfSwingTimerOffhand` | 主手 `180×16 UI / scale 0.72`，位于三列横排中央；副手同尺寸并紧贴主手下方。文字、攻速与 Marker 动态 |
| `AB.FOCUS.SWING.RANGED` | `pfSwingTimerRanged` | 与主手同为 `180×16 UI / scale 0.72` 并复用中央列，不与近战双条组成第三条常驻栏；范围提示仍由 provider 管理 |
| `AB.DOITEDPS.TIMELINE` | 可选 `DoiteDPSMainFrame` 及子 Frame | 保留原生 `318×46 UI` 比例、独立拖动／锁定／显隐与蓝绿状态语义；comfort preset 写 point／x／y 与目标显示补偿 scale `0.82`，锁定态继续由 provider 关闭鼠标，以后可选低重量外缘 |
| `AB.TOTEM.ARCHITOTEM` | 可选 `ArchiTotemFrame`、四元素主 Button、元素候选、拖动球、AllTotems 与可选 Recall／PresetManager | 用户已接受 `ACTION-BARS-CORE-SIM-V4`。闭合真实可见 union 作为职业卫星栏置于 Combat Deck 下方；provider `scale=0.8` 时当前闭合脚印为 `212×32 UI`、Air 七层最大展开为 `212×224 UI`。`fieldKitBound=true` 时随 Bar 1，拖动松手回位，`unbind` 恢复首次自由锚点；显式 focus preset 才调用 provider 原生 API 请求向下展开，普通 refresh 只读取方向。施放、右键、hover、计时、锁定、方向、预设与 Tooltip 不接管；缺失、非萨满、隐藏或签名不匹配时无占位并 fail-open |

## 消耗品卷袋

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.CONSUMABLE.RACK` | 已加载并自行显示的 `AutoBarFrame`＋`AutoBarFrameButton1..24` | 推荐一次性满容量 `4×6 / 24 Button / 36 UI / gap 3 UI`，同时支持 `1–24` 个真实 Button 与合法行列。推荐按钮簇外壳为 `165×243 UI`。因 `alignButtons` 可把子 Button 放到 `AutoBarFrame` 边界外，装饰 Frame 必须在配置变化时读取真实可见 Button 边界。`fieldKitBound=true` 时强绑定在主动作条左侧，外壳右缘距主栏左缘 `12 UI`、底边对齐；拖动 provider 松手后立即回到组合位，不再独立脱离。`unbind` 后恢复捕获的自由位置与原拖动。不得用维护循环持续重写位置／尺寸，也不得自动启用 provider |
| `AB.CONSUMABLE.GROUP` | 推荐 profile 的连续槽段 `1–8／9–16／17–24` 与两条底层分隔带 | 连续槽段继续提供应急／增益／工具的语义组织，但不创建或显示三段文字；卷袋材质、分隔和物品排列自身承担区分。分隔带只占两组之间既有 `3 UI` gap，不接收鼠标。任一配置不匹配即隐藏分隔并退回单一自适应外壳，不能给用户自定义类别套用错误分组 |
| `AB.CONSUMABLE.POCKET` | `AutoBarFrameButton1..24` | 显示 provider 选出的真实物品图标、数量、冷却、可用性和 Tooltip；槽底不含物品图标、名称或类别。V1 不创建自有 fallback Button |
| `AB.CONSUMABLE.POPUP` | `AutoBarPopupFrame_Button1..12` | 精确匹配推荐 `24 Button / 4×6 / profile` 时改用外置抽屉：`1–6` 个候选为单列，`7–12` 个候选为列优先双列且最多六行；整组位于卷袋外，不遮挡主格。`AUTO` 在强绑定态固定向左、自由态按屏幕剩余空间选择左右；`LEFT／RIGHT` 可强制方向，`NATIVE` 或任一 profile 签名不匹配时完整恢复 provider 原生四向线性布局。外置态在卷袋与抽屉间创建透明、可接收鼠标、直接隶属 `AutoBarPopupFrame` 且覆盖卷袋全高的 `10 UI` 悬停通道；XML Frame `OnLeave` 只在此态延后，关闭仍由 AutoBar 原 `PopupMouseover` 负责。因前往外侧抽屉可能穿过其他主格，`fieldkit-contract=1.8` 延续 `0.30s` 意图停留：进入通道或候选前离开不同主格即保留原抽屉；持续停留才调用捕获的 AutoBar 原方法切换／关闭。相同主格、NATIVE、签名不匹配、AEUI 关闭、非鼠标调用或 provider 调度 API 缺失全部立即委托原方法；不使用逐帧循环。候选顺序、图标、数量、冷却、点击、Tooltip、Shift 条件与 Button script 仍归 AutoBar；不得把 XML 初始 `72×72 UI` Frame 当作实际弹出边界，不复制分类表或重挂 `PickupContainerItem` |

推荐 profile 使用 AutoBar 现有类别 ID 组成三个八格槽段：`应急` 放生命／职业
资源／双恢复／绷带／解毒／行动／机动；`增益` 放战斗药剂／守护药剂／元素
防护／卷轴／食物／饮料／增益食物／合剂手动；`工具` 放武器强化／职业用品／
炉石／坐骑／工程／钓鱼／战场事件／任务物品。职业资源和职业用品按
`AutoBarProfile.<CLASS>` 选取，不相关类别不写入。已审计的 AutoBar `1.31`
没有独立 `FLASK` 类别；但每个主槽原生允许最多 `16` 个类别字符串或数字 item
ID，配置页也能把背包物品拖入槽位。因此“合剂手动”只接受用户通过 AutoBar
配置拖入的真实合剂 item ID，不凭名称猜测。此 profile 只在用户主动应用时写入一次，
AutoBar 的真实类别、物品顺序和用户后续配置始终优先；缺失／禁用时 V1 不显示。
以后若建立 AEUI 钉选 fallback，必须另立功能合同。

用户于 `2026-08-09` 接受 `AB.CONSUMABLE.KIT.V1` 第 1 稿。P4 source 为
[ActionConsumableKit_Master_v1.png](../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)
（SHA-256 `623f29c5…a2419`），[manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json)
固定四格映射：A→`AB.CONSUMABLE.POCKET` 主口袋，B→`AB.CONSUMABLE.POPUP`
薄候选口袋，C→`AB.CONSUMABLE.RACK／GROUP` filled 自适应卷袋外壳，D→popup
连接带／group 分隔带。该 `1024²` 母版不由客户端直接加载；确定性 P5 exporter
把每格完整物件等比缩放并打包为
[ActionConsumableKitV1.tga](../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga)
（`512² RGBA`，文件 SHA `c48f6292…320e`、像素 SHA `658f826f…e30d`），合同见
[runtime manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json)。
adapter 在现有 `24+12` Button 下分别取 A／B，C 以 `6 UI` 九宫格跟随真实可见
Button 边界，D 用于分组 gap，并在外置 popup 抽屉靠卷袋一侧形成竖向 spine。它只
读取 profile 以决定语义分隔与抽屉真伪，不自动启用 AutoBar、不在普通刷新中应用 profile
或写入 provider SavedVariables。`fieldkit-contract=1.8` 完整延续 v1.5，把每个 A／B 口袋放入
以真实 Button 为父、FrameLevel 比
Button 低 `1` 的独立非交互装饰 Frame，避免与 ActionButtonTemplate 的动态图标
共用 `BACKGROUND` 层。用户可显式执行 `/aeui autobar apply`，只为当前角色一次性
写入已确认的 `4×6`／24 类 profile，并在 AEUI SavedVariables 中保存应用前副本；
`/aeui autobar restore` 恢复该副本，`/aeui autobar open` 只打开 AutoBar 原配置页。
`/aeui autobar popup auto|left|right|native` 控制抽屉策略。组合状态只写入 AEUI
自己的 `fieldKitBound`；`/aeui fieldkit bind|unbind|home|status` 分别负责强绑定、
释放、恢复已确认的中心中下位置与查询。旧 `consumableDocked／trinketDocked` 只为
SavedVariables 兼容同步，不再表示两侧可独立脱离。这些命令不自动启用 provider，
不改 AutoBar profile 或 TrinketMenu 功能配置。

## 饰品双槽

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.TRINKET.DOCK` | 可选 `TrinketMenu_MainFrame`；缺失时不显示占位栏 | 水平严格 `92×52 UI`、垂直严格 `52×92 UI`；两枚 `36×36 UI` 真实已装备饰品，主栏 scale／方向与 resize 继续归 provider；实际图标、快捷键、冷却与 Tooltip 动态。强绑定态位于主动作条右侧、左缘距主栏右缘 `8 UI`、底边对齐，provider 拖动松手后回位；`unbind` 才恢复独立位置。当前“大奶黑牛”按最初方案一次性设为水平双槽，但 adapter 不持续覆盖方向或 Queue／换装配置 |
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
真实饰品图标、冷却和 Queue 始终位于其上。强绑定把 Bar 6、消耗品卷袋和饰品双槽
都直接锚到 Bar 1；pfUI unlock 只保留 Bar 1 作为组合移动根，移动时其余部分因相对
锚点自然跟随。重排只发生在初始化、provider 布局完成、显式命令和拖动结束，不建立
`OnUpdate` 维护循环。

## 强绑定战斗甲板与显式释放

- `战斗甲板`：Bar 1 为屏幕中下部居中 `12×1` 主栏；Bar 6 为其上方 `12×1`
  副栏；姿态／宠物条独立位于上缘；满容量消耗品卷袋以 `4×6` 竖向置于左侧，
  饰品双槽在右。目标设备 V3 沿用主栏物理 `y=827`、Button 约 `39 px`、底边
  净空 `210 px`；卷袋主体为物理 `[531,673,665,870]`，与聊天框右缘净空
  `5 px`、与玩家框左缘净空 `16 px`。该 V3 reference 只保留构图历史；runtime-v1.7
  已按游戏坐标收紧停靠并由 bridge-v1.8 移除三枚文字标签。
- `唯一移动根`：绑定态只移动 Bar 1；Bar 6 以 `BOTTOM → Bar 1 TOP` 组成无漂移
  `12×2`，消耗品卷袋与饰品双槽分别以 `12／8 UI` 间距锚到左右；检测到的
  ArchiTotem 以真实可见 union 居中锚在主栏下方并把垂直空隙收为 `39 UI`。`unbind` 恢复 Bar 6 与三种
  provider 的捕获位置；`home` 在 pfUI tier 8 下把 Bar 1 直接重置为游戏坐标
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
- `战斗视线邻接`：Player／Target／TargetTarget 继续由 pfUI UnitFrame provider 所有；
  AEUI `0.8.14` 的 runtime-v1.7 preset 仅一次性把 Player／Target 置于游戏坐标
  `BOTTOM (-190,500)／(190,500)`，设为 `240×60 / 0.68`；TargetTarget 设为
  `132×30 / 0.62`，live Frame 依附 Target 右侧 `8 UI`。Player Aura 上 Buff／下
  Debuff 均左起；Target 与 TargetTarget 上 Buff／下 Debuff 均右起。adapter 不重画，
  不在维护循环中持续改位置。
- `战斗信息横排`：玩家施法、Swing 主手／ranged、目标施法统一为
  `180×16 / 0.72`，分别落在 `BOTTOM (-196,430)／(0,430)／(196,430)`；副手同尺寸
  紧贴主手下方。三列位于单位框与动作甲板之间，不再挂在单位框下缘，也不互相
  重叠。姿态置于 `BOTTOM (0,255)`，DoiteDPS 置于 `TOPLEFT (1012,-780)`；Focus
  施法条继续跟随 Focus Frame。所有数值均为 Turtle WoW 游戏坐标，不读取或回算
  屏幕像素、UIParent 尺寸或 provider effective scale。
- `紧凑战斗`：主／副栏可改为 `6×2`；自适应 Rail 重新切片，狮鹫端帽缩小或
  隐藏，逻辑按钮数与分页不变。
- `自由侧栏`：Bar 3／4／5 可保持 `4×3`、`6×2` 或竖排并独立移动；不因采用
  推荐预设而失去现有布局。
- `透明度与命中`：玩家／目标状态、双方施法、攻击计时、DoiteDPS 与技能 CD
  使用 provider 原生 Alpha，不做整组淡出；只允许非核心辅助栏按用户设置脱战
  淡出。Rail、连接片、卷袋、护套和标题等装饰层全部鼠标穿透，DoiteDPS 锁定态
  沿用 provider 的根 Frame 鼠标穿透；不增加覆盖中央视野的大型透明 Frame。
- `舒适缩放`：目标设备保持客户端 `1920×1080`，不由本模块修改分辨率；用户
  显式执行 `comfort` 时只把当前 pfUI profile 设为
  `Tiny PixelPerfect / tier 8 / 0.71111111111111`。Combat Focus 另用 local
  scale：Player／Target `0.68`、TargetTarget `0.62`、施法／Swing `0.72`、
  姿态／DoiteDPS `0.82`。不把
  `UIParent:GetWidth／Height` 或 `GetScreenWidth／Height` 当作 SetPoint 根；一次性
  `game-native-v1` 坐标签名只属于当前角色。强绑定甲板关系保持原样。普通刷新不改 pfUI scale；
  其他角色不自动应用。
- `home` 预设只在用户明确执行时写入一次。默认读取并尊重现有 profile、主栏位置、
  scale、按钮数、行列、自动隐藏和空槽设置；V3 继续默认关闭狮鹫，unlock 时
  仍可为足够宽的水平主栏单独开启。DoiteDPS 的锁定／战斗显隐／Forecast／资源／
  冷却选项不由此 preset 改写；DoiteDPS 的 local scale 在 comfort preset 中
  明确收敛为 `0.82`，其启用／锁定／显隐与推荐逻辑不变。首次应用前保存相关
  pfUI／DoiteDPS／ArchiTotem 配置；`/aeui focuslayout restore` 恢复后提示 reload。
- `ACTION-BARS-CORE-SIM-V6` 对用户最新九项布局要求完成确定性本地审查；AEUI
  `0.8.14`／focus runtime-v1.7／Field Kit bridge-v1.8 保留 tier 8、Combat Deck、
  accepted art 与 provider 行为，只修订游戏坐标、单位／读数尺寸、Aura 方向、
  TargetTarget 依附和无文字分组。仅未被手动调整的 exact v7 游戏坐标 profile 在 `/reload` 时一次性
  迁移为 v8；显式 focus preset 才写入固定游戏坐标并请求 provider 方向，普通
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
