# Action Bars 子模块定义

本文件定义动作条、姿态／宠物条，以及与战斗动作区相邻的施法／攻击读数、
DoiteDPS、消耗品和饰品栏。
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
source 为 `1024×1024 RGBA`，完整可见物件位于 `[160,160,864,864)`；其
`704×704` crop 的冻结九宫格边界为 `0／128／576／704`。该资产当前只达到
`source-accepted / P4`，尚未导出 runtime atlas、冻结 UV 或接入 addon；客户端
仍使用 pfUI 原生 `bar.backdrop`／`mergedBackdrop`。后续 export 必须继续沿用
本表的真实对象、Bar 1／6 合并条件、父 Frame 显隐／移动／缩放和 fail-open，
不得把 source 直接加载进游戏或改写任何 Button／SavedVariables。

## 战斗焦点邻接对象

这些对象加入同一推荐布局，但逻辑所有权不转移给动作条 adapter；任何视觉接管
都必须以后按对象独立授权并 feature-detect，失败时保留 provider 原样。

| ID | provider／真实对象 | 合同 |
|---|---|---|
| `AB.FOCUS.CASTBAR.PLAYER` | `pfPlayerCastbar` | 推荐紧贴玩家框下方并继承其宽度；保留法术图标、名称、计时与玩家延迟区；独立可移动 |
| `AB.FOCUS.CASTBAR.TARGET` | `pfTargetCastbar` | 推荐紧贴目标框下方并继承其宽度；保留可打断／不可打断与目标施法信息；独立可移动 |
| `AB.FOCUS.CASTBAR.FOCUS` | 可选 `pfFocusCastbar` | 继续跟随 Focus Frame，默认不进入中央玩家／目标双框；对象不存在时无占位 |
| `AB.FOCUS.SWING.MELEE` | `pfSwingTimerMainhand`＋`pfSwingTimerOffhand` | `200×12 UI` 双细轨居中上下排列；副手仍跟随主手；文字、攻速与 Marker 动态 |
| `AB.FOCUS.SWING.RANGED` | `pfSwingTimerRanged` | 复用同一中心计时层，不与近战双条组成第三条常驻栏；范围提示仍由 provider 管理 |
| `AB.DOITEDPS.TIMELINE` | 可选 `DoiteDPSMainFrame` 及子 Frame | 保留原生 `318×46 UI` 比例、独立拖动／缩放／锁定／显隐与蓝绿状态语义；只允许一次性位置 preset 和以后可选的低重量外缘 |

## 消耗品卷袋

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.CONSUMABLE.RACK` | 已加载并自行显示的 `AutoBarFrame`＋`AutoBarFrameButton1..24` | 推荐一次性满容量 `4×6 / 24 Button / 36 UI / gap 3 UI`，同时支持 `1–24` 个真实 Button 与合法行列。推荐按钮簇外壳为 `165×243 UI`。因 `alignButtons` 可把子 Button 放到 `AutoBarFrame` 边界外，装饰 Frame 必须在配置变化时读取真实可见 Button 边界；不得持续重写位置／尺寸，也不得启用当前禁用的 provider |
| `AB.CONSUMABLE.GROUP` | 推荐 profile 的连续槽段 `1–8／9–16／17–24`；三个非交互标题 Frame／FontString 与两条底层分隔带 | 只在 Button 数、`4×6` 行列与分组 profile 签名全部匹配时显示“应急／增益／工具”；每组两行八格。标题位于命中盒外，分隔带只占两组之间既有 `3 UI` gap，不接收鼠标。任一配置不匹配即隐藏标题／分隔，退回单一自适应外壳，不能给用户自定义类别贴错标签 |
| `AB.CONSUMABLE.POCKET` | `AutoBarFrameButton1..24` | 显示 provider 选出的真实物品图标、数量、冷却、可用性和 Tooltip；槽底不含物品图标、名称或类别。V1 不创建自有 fallback Button |
| `AB.CONSUMABLE.POPUP` | `AutoBarPopupFrame_Button1..12` | 复用每个真实候选 Button 的薄口袋与 `3 UI` 短连接带，支持上下左右线性增长；不得把 XML 初始 `72×72 UI` Frame 当作实际弹出边界，不复制分类表或重挂 `PickupContainerItem` |

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

## 饰品双槽

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.TRINKET.DOCK` | 优先 `TrinketMenu_MainFrame`；缺失时绑定装备槽 `13`／`14` | 水平严格 `92×52 UI`、垂直严格 `52×92 UI`；两枚 `36×36 UI` 真实已装备饰品，主栏 scale／方向／拖动与 resize 继续归 provider；实际图标、快捷键、冷却与 Tooltip 动态 |
| `AB.TRINKET.SLOT13` | `TrinketMenu_Trinket0`／`UseInventoryItem(13)` | 顶部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.SLOT14` | `TrinketMenu_Trinket1`／`UseInventoryItem(14)` | 底部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.MENU` | `TrinketMenu_MenuFrame`＋`TrinketMenu_Menu1..30` | 零候选隐藏；Button `36×36 UI`、步距 `40 UI`。VERTICAL 为 `12+列数×40` 乘 `12+ceil(数量/列数)×40`，HORIZONTAL 转置；支持自动 `1–5` 列或用户 `1–30` 列、菜单独立 scale／方向／拖动、八种停靠组合与战斗 Queue。只换肤并 fail-open |

TrinketMenu 已经接管 `UseInventoryItem`、背包更新、装备更新与排队时，AEUI 不再
安装竞争性全局 hook。没有 TrinketMenu 时，V1 fallback 只绑定两个已装备槽的
使用反馈，不复制候选菜单或 Queue，也不尝试换装；以后若新增非战斗换装入口，
必须另立功能合同。

## 推荐布局而非强制布局

- `战斗甲板`：Bar 1 为屏幕中下部居中 `12×1` 主栏；Bar 6 为其上方 `12×1`
  副栏；姿态／宠物条独立位于上缘；满容量消耗品卷袋以 `4×6` 竖向置于左侧，
  饰品双槽在右。目标设备 V3 沿用主栏物理 `y=827`、Button 约 `39 px`、底边
  净空 `210 px`；卷袋主体为物理 `[531,673,665,870]`，与聊天框右缘净空
  `5 px`、与玩家框左缘净空 `16 px`，三枚标题皮签均在聊天框 `y=824` 上缘前结束。
- `战斗视线邻接`：Player／Target 继续由 pfUI UnitFrame provider 所有；推荐
  preset 仅一次性把两者置于同一基线并收拢到目标设备 `80 px` 内缘间距，
  不由 Action Bars adapter 重画、重挂 Parent 或在维护循环中持续改位置。
- `战斗信息纵栈`：目标设备物理顺序为 DoiteDPS `y=514–551`、近战攻击计时
  `570–593`、双方外肩 Aura `612–631`、Player／Target `639–700`、双施法条
  `708–728`、姿态 `y=744`、副栏 `y=783`、主栏 `y=827`。远程攻击计时复用
  近战计时层；Focus 施法条跟随 Focus Frame，不加入中央双框。
- `紧凑战斗`：主／副栏可改为 `6×2`；自适应 Rail 重新切片，狮鹫端帽缩小或
  隐藏，逻辑按钮数与分页不变。
- `自由侧栏`：Bar 3／4／5 可保持 `4×3`、`6×2` 或竖排并独立移动；不因采用
  推荐预设而失去现有布局。
- 预设只在用户明确点击应用时写入一次。默认读取并尊重现有 profile、位置、
  scale、按钮数、行列、自动隐藏和空槽设置；V3 继续默认关闭狮鹫，unlock 时
  仍可为足够宽的水平主栏单独开启。DoiteDPS 的锁定／战斗显隐／Forecast／资源／
  冷却选项不由此 preset 改写。

## 功能不变量

- 技能、宏、物品、宠物动作、分页、姿态、快捷键、数量、冷却、范围、法力、
  装备态、拖放、Tooltip 与右键语义继续由真实 provider 负责。
- 施法识别、延迟、可打断状态、主／副手／远程攻击识别、DoiteDPS 推荐／ETA／
  资源／冷却继续由各自 provider 负责；本模块不复制算法或制造假读数。
- Bar 1、用户标记的战斗核心 Bar、消耗品核心口袋和两枚饰品在战斗中不得因
  mouseover 延迟而消失；非核心辅助栏才可选择脱战淡出。
- 自动隐藏只能改变可见性／Alpha，不在维护循环中搬动或改尺寸。
- 可选 provider 缺失、版本不匹配或 adapter 出错时，局部恢复其原始视觉与
  功能；不得阻止 pfUI 或 AEUI 其余模块加载。
- 不把技能图标、物品图标、文字、数字、键位、冷却、职业状态或真实按钮烘焙
  进背景资产。
