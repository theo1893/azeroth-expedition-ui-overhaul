# Character 子模块定义

本文件定义按 `C` 打开的角色系统及相邻复用窗口，与仓库内 pfUI skin 对齐。
美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 来源

| 文件 | 已证实对象 | 项目处理 |
|---|---|---|
| [`skins/blizzard/character.lua`](../../../addon/pfUI/skins/blizzard/character.lua) | `CharacterFrame`、`PaperDollFrame`、装备槽、属性、抗性、Pet、Reputation、Skills、Honor／Arena 与底部 Tabs | 当前由 pfUI 正常加载；以后只在 Character 接管范围内按子模块换肤 |
| [`skins/blizzard/inspect.lua`](../../../addon/pfUI/skins/blizzard/inspect.lua) | `InspectFrame`、纸娃娃、装备槽、Honor／Arena／Turtle talent tabs | 复用角色组件，但保持只读语义 |
| [`skins/blizzard/dressup.lua`](../../../addon/pfUI/skins/blizzard/dressup.lua) | `DressUpFrame`、模型、旋转、Reset／Cancel | 复用外壳、按钮和模型背景 |

锁定结构参考只使用
[香草截图](../../../assets/references/香草60级角色面板_结构参考.webp)左侧的
`CharacterFrame`；右侧第三方装备列表不属于本模块基础对象。

## 原生几何基准

WoW `1.12.1` 原生 `CharacterFrame.xml`、`PaperDollFrame.xml` 与
`CharacterFrameTemplates.xml` 给出的基础边界为：

- `CharacterFrame`：`384×512`。
- `CharacterModelFrame`：`233×224 @ 65,78`。
- `CharacterAttributesFrame`：`230×78 @ 67,291`。
- 左右装备槽：`37×37`，首格 `y=74`，相邻格纵向间隔 `4px`。
- 主手／副手／远程：`37×37 @ x=122/164/206, y=385`。
- `CharacterAmmoSlot`：独立 `27×27`，位于远程槽右侧；它不是第四个底槽。
- `CharacterFrameTab1..5`：Character／Pet／Reputation／Skills／Honor；客户端
  根据职业与可用页动态隐藏和重排，因此普通角色可只显示四个。

## 角色主面板

| ID | 原生对象 | 状态／资产合同 |
|---|---|---|
| `CHAR.FRAME` | `CharacterFrame` | 紧凑近矩形可切片外壳；不含槽、文字或 Tabs |
| `CHAR.PORTRAIT` | `CharacterFramePortrait` | 明确隐藏；不生成肖像、种族／职业 icon 或空底座 |
| `CHAR.TITLE` | `CharacterNameText`、`CharacterLevelText`、可选 title dropdown | layout-only；短铭牌 |
| `CHAR.CLOSE` | `CharacterFrameCloseButton` | 普通／悬停／按下／禁用 |
| `CHAR.MODEL` | `CharacterModelFrame` | 原生 3D 模型；只生成安静背景与独立边框 |
| `CHAR.MODEL.ROTATE.LEFT` | `CharacterModelFrameRotateLeftButton` | 保留真实左旋转；四状态，小型 |
| `CHAR.MODEL.ROTATE.RIGHT` | `CharacterModelFrameRotateRightButton` | 保留真实右旋转；四状态，小型 |
| `CHAR.MODEL.HELM` | 客户端头盔显示开关待实机映射 | 未选／已选／悬停／禁用 |
| `CHAR.MODEL.CLOAK` | 客户端披风显示开关待实机映射 | 未选／已选／悬停／禁用 |

## 装备槽

`Character<SlotName>` 与对应 `IconTexture` 是真实 Button／图标绑定。基础集合
包括 Head、Neck、Shoulder、Back、Chest、Shirt、Tabard、Wrist、Hands、
Waist、Legs、Feet、Finger0／1、Trinket0／1、MainHand、SecondaryHand、
Ranged。

| ID | 对象 | 合同 |
|---|---|---|
| `CHAR.SLOT` | 每个 `Character<SlotName>` | 同几何实例；普通／悬停／按下／禁用 |
| `CHAR.SLOT.EMPTY` | 空槽纹理 | 每装备部位独立低对比压印 |
| `CHAR.SLOT.QUALITY` | 动态品质覆盖 | 低饱和窄内沿，不改变槽轮廓 |
| `CHAR.SLOT.DURABILITY` | adapter 状态覆盖 | 正常／低耐久／损坏 |
| `CHAR.SLOT.AMMO` | `CharacterAmmoSlot` | 独立小型槽、数量与冷却；不套用完整装备槽轮廓 |

主手、副手、远程／圣物保持底部三个槽位；不得增加第四底槽。

## 属性与 Tabs

`character.controls` 精确接管下列展示对象：称号与左右属性下拉的 pfUI backdrop、
这些下拉打开时的 DropDownList Backdrop／MenuBackdrop、ReputationHeader／
SkillTypeLabel／CollapseAll 的折叠图标、两列表 ScrollBar 的轨道／滑块／箭头底材、
ReputationBar／SkillRankFrame／Honor progress／Arena points／Skill detail 状态条、
HonorFrameTab／ArenaFrameTab、声望详情外框及已有关闭／Unlearn 按钮底材。
HonorFrameProgressBar／ArenaFramePointsBar 与 ArenaTeam1..5／ArenaFrameTeam1..5
只隐藏 pfUI 附加 backdrop／border／shadow，以共用纸页承托动态内容；不隐藏
真实进度条、队伍框体或其交互，禁用时恢复附加底框原 Alpha。
真实文字与数值保持动态，名称与数值只调整对齐。Character 伴随状态下另接管
StatCompareSelfFrame／S_ItemTip_InspectFrame 的外底材、等级框与装备部位签；
不改变第三方的 Parent、尺寸、数据和交互，离开角色 PaperDoll 恢复原材质。
资产复用 Gear Planner FrameAtlas／LeatherFill／ControlsAtlas 的现有 2× 像素，
滑块取 ControlsAtlas 的扣具 `x=50..88,y=5..34`，状态条复用 UnitFrameHealthFillV1。

| ID | 原生对象 | 合同 |
|---|---|---|
| `CHAR.STATS.LEFT` | `CharacterAttributesFrame` 左列、对应 `PlayerStatFrame*DropDown` | 羊皮文字区；名称左对齐、数值右对齐；每个下拉独立 |
| `CHAR.STATS.RIGHT` | `CharacterAttributesFrame` 右列、`CharacterResistanceFrame`、对应 `PlayerStatFrame*DropDown` | 羊皮文字区；名称左对齐、数值右对齐；每个下拉独立 |
| `CHAR.RESISTANCE` | `MagicResFrame1..N` | 图标动态；槽底独立 |
| `CHAR.TABS` | `CharacterFrameTab1..5` | 角色／宠物／声望／技能／PVP；按可用页动态显示；普通／悬停／选中／禁用 |
| `CHAR.SECONDARY.LEAF` | `ReputationFrame`、`SkillFrame`、`HonorFrame`／`PVPFrame`、存在时的 `ArenaFrame` | 各 provider 共用一张内页底材；每页独立挂载并随原生页面显隐；不得烘焙列表、文字、状态条、按钮或滚动条 |
| `CHAR.REPUTATION` | `ReputationFrame`、`ReputationBarN`、ScrollBar、详情复选框 | 列表、状态条、滚动条分别拆分 |
| `CHAR.SKILLS` | `SkillFrame`、`SkillTypeLabelN`、`SkillRankFrameN`、两 ScrollFrame | 展开、列表、进度条、Unlearn 分别拆分 |
| `CHAR.HONOR` | `HonorFrame`／`PVPFrame`、progress bar、Tabs | 独立战斗状态条与列表 |
| `CHAR.ARENA` | `ArenaFrame`、team frames、points bar、Tabs | Turtle WoW 存在时 feature-detect |

## 角色伴随栏

角色伴随栏由 Gear Planner runtime `0.8-zhCN` 实现，但其宿主边界登记在 Character：
它只在 `CharacterFrame / PaperDollFrame` 的 `384×512` 几何可用且 Character 模块
启用时出现，不成为新的 Character Tab。

| ID | 对象 | 合同 |
|---|---|---|
| `CHAR.COMPANION.CONTROLLER` | CharacterFrame／PaperDollFrame 的 AEUI 子控制器 | 只监听父级显隐和分页切换；不再包装 CharacterFrame 的 OnShow／OnHide |
| `CHAR.COMPANION.RAIL` | `AzerothExpeditionUICharacterCompanionRail` | 角色页右侧 `28 UI` 窄栏；按 Provider 可用性显示“装／属／配”，宽屏可显示“双” |
| `CHAR.COMPANION.CURRENT` | `S_ItemTip_InspectFrame` | 当前装备互斥视图；Provider 持有内容、动态宽度、更新与交互 |
| `CHAR.COMPANION.STATS` | `StatCompareSelfFrame` | 装备属性互斥视图；Provider 持有扫描、动态尺寸、拖动与 SavedVariables |
| `CHAR.COMPANION.PLAN` | `AzerothExpeditionUIGearPlannerFrame` | 配装方案互斥视图；伴随模式 `560×555`，19 槽与“当前／配装／变化”属性对比同屏；Provider 不受支持时独立回退 |

## 观察伴随栏

观察伴随栏与角色伴随栏是两个独立会话；它只在 `InspectFrame`／
`InspectPaperDollFrame` 的 `384×512` 几何可用时出现，不把可编辑配装器挂到只读
观察页。

| ID | 对象 | 合同 |
|---|---|---|
| `CHAR.INSPECT.COMPANION.CONTROLLER` | InspectFrame／InspectPaperDollFrame 的 AEUI 子控制器 | 监听宿主、分页、`INSPECT_READY` 与 Provider 完成更新；不包装 InspectFrame 脚本 |
| `CHAR.INSPECT.COMPANION.RAIL` | `AzerothExpeditionUIInspectCompanionRail` | 观察页右侧 `28 UI` 窄栏；按 Provider、数据与实际净空显示“装／属／比／存” |
| `CHAR.INSPECT.COMPANION.GEAR` | `S_ItemTip_InspectFrame` | “装”只显示观察目标装备，隐藏双方 StatCompare |
| `CHAR.INSPECT.COMPANION.STATS` | `StatCompareTargetFrame` | “属”只显示目标属性，隐藏 S_ItemTip 与自身属性 |
| `CHAR.INSPECT.COMPANION.COMPARE` | `StatCompareTargetFrame`、`StatCompareSelfFrame` | 显式“比”且左右净空足够时目标在右、自身在左；不再同时显示 S_ItemTip |
| `CHAR.INSPECT.COMPANION.SAVE` | “存” Button、InspectFrame.unit 装备快照 | 数据就绪后新建观察参考方案；不改目标装备、不覆盖已有方案、不在 Inspect 内打开完整配装器 |

## 相邻复用窗口

| ID | 原生对象 | 合同 |
|---|---|---|
| `CHAR.PET` | `PetPaperDollFrame`、`PetModelFrame`、属性、抗性、经验条 | 复用外壳／槽／状态条，保留宠物数据 |
| `CHAR.INSPECT` | `InspectFrame`、`InspectPaperDollFrame`、`InspectModelFrame`、Tabs | 复用只读槽与外壳；观察伴随栏只协调第三方附页，不创建可装备语义 |
| `CHAR.DRESSUP` | `DressUpFrame`、`DressUpModel`、Reset／Cancel | 复用模型背景、外壳和按钮 |

## 功能不变量

- 中央原生 3D 模型、装备图标、属性文字、品质、耐久和交互保持动态。
- 点击装备槽、旋转、隐藏头盔／披风、切换 Tabs、声望／技能操作不改写。
- 第三方附页只能作为可收起 adapter，默认不改变主窗口轮廓；伴随栏不 Reparent、
  缩放或改写 Provider 数据，只在真实显示事件后一次性锚定并协调显隐。
- 配装伴随视图的水平合同为 `384 + 8 + (28 + 4 + 560) = 984 UI`，Gear 内部
  装备与属性固定同屏；只有第三方当前装备视图在有效宽度至少 `1060 UI` 且实际
  左右净空足够时，才允许左 StatCompare 与右侧 S_ItemTip 并存。
- S_ItemTip／StatCompare 缺失时省略对应入口；Character 禁用、对象缺失或几何
  不受支持时不显示伴随栏，由 Gear Planner 自己回退独立窗口。
- 观察默认只允许一个右侧 Provider；双方属性只在用户显式选择“比”且实际空间
  足够时并排。观察数据未就绪时不显示“存”，非 PaperDoll 分页不保留附页。
- 对象缺失时局部回退 pfUI／原生；Character adapter 不得改变其他 pfUI skin。
