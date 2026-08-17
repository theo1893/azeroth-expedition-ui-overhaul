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

| ID | 原生对象 | 合同 |
|---|---|---|
| `CHAR.STATS.LEFT` | `CharacterAttributesFrame` 左列、对应 `PlayerStatFrame*DropDown` | 羊皮文字区；名称左对齐、数值右对齐；每个下拉独立 |
| `CHAR.STATS.RIGHT` | `CharacterAttributesFrame` 右列、`CharacterResistanceFrame`、对应 `PlayerStatFrame*DropDown` | 羊皮文字区；名称左对齐、数值右对齐；每个下拉独立 |
| `CHAR.RESISTANCE` | `MagicResFrame1..N` | 图标动态；槽底独立 |
| `CHAR.TABS` | `CharacterFrameTab1..5` | 角色／宠物／声望／技能／PVP；按可用页动态显示；普通／悬停／选中／禁用 |
| `CHAR.REPUTATION` | `ReputationFrame`、`ReputationBarN`、ScrollBar、详情复选框 | 列表、状态条、滚动条分别拆分 |
| `CHAR.SKILLS` | `SkillFrame`、`SkillTypeLabelN`、`SkillRankFrameN`、两 ScrollFrame | 展开、列表、进度条、Unlearn 分别拆分 |
| `CHAR.HONOR` | `HonorFrame`／`PVPFrame`、progress bar、Tabs | 独立战斗状态条与列表 |
| `CHAR.ARENA` | `ArenaFrame`、team frames、points bar、Tabs | Turtle WoW 存在时 feature-detect |

## 相邻复用窗口

| ID | 原生对象 | 合同 |
|---|---|---|
| `CHAR.PET` | `PetPaperDollFrame`、`PetModelFrame`、属性、抗性、经验条 | 复用外壳／槽／状态条，保留宠物数据 |
| `CHAR.INSPECT` | `InspectFrame`、`InspectPaperDollFrame`、`InspectModelFrame`、Tabs | 复用只读槽与外壳；不创建可装备语义 |
| `CHAR.DRESSUP` | `DressUpFrame`、`DressUpModel`、Reset／Cancel | 复用模型背景、外壳和按钮 |

## 功能不变量

- 中央原生 3D 模型、装备图标、属性文字、品质、耐久和交互保持动态。
- 点击装备槽、旋转、隐藏头盔／披风、切换 Tabs、声望／技能操作不改写。
- 第三方附页只能作为可收起 adapter，默认不改变主窗口轮廓。
- 对象缺失时局部回退 pfUI／原生；Character adapter 不得改变其他 pfUI skin。
