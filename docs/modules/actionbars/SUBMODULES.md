# Action Bars 子模块定义

本文件定义动作条、姿态／宠物条，以及与战斗动作区相邻的消耗品和饰品栏。
美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见
[PROGRESS.md](PROGRESS.md)。本模块只接管明确列出的对象；未登记的 pfUI、
AutoBar、TrinketMenu 或 Blizzard 对象继续由原 provider 正常绘制和交互。

## pfUI 与客户端来源

| 文件／provider | 已证实对象与能力 | 项目处理 |
|---|---|---|
| [`modules/actionbar.lua`](../../../addon/pfUI/modules/actionbar.lua) | `pfActionBarMain`、Paging、Right、Vertical、Left、Top、四个 stance page、`pfActionBarStances`、`pfActionBarPet`；真实 Action Button、分页、冷却、快捷键、数量、范围／法力／装备／宠物自动施法状态 | 保留为唯一动作与状态 provider；只做逐对象视觉 adapter 和一次性可选布局预设 |
| [`modules/gryphons.lua`](../../../addon/pfUI/modules/gryphons.lua) | 左右端帽、纹理、尺寸、颜色、锚点与偏移 | 以后只在 `AB.ENDCAP.GRYPHON` 范围替换；窄栏或非横向布局可关闭 |
| [`modules/hunterbar.lua`](../../../addon/pfUI/modules/hunterbar.lua) | 猎人近战／远程页切换与滞回 | 行为不改写；视觉随对应真实动作页更新 |
| [`api/api.lua`](../../../addon/pfUI/api/api.lua) | `BarLayoutSize`、`BarLayout`、`UpdateMovable` | 作为尺寸公式、排列与自由拖动权威 |
| [`api/config.lua`](../../../addon/pfUI/api/config.lua) 与 [`modules/gui.lua`](../../../addon/pfUI/modules/gui.lua) | 每条 Bar 的启用、按钮数、图标尺寸、间距、行列、空槽、自动隐藏与战斗显示配置 | 保留并扩展外观入口，不强写用户 profile |

目标客户端还证实存在以下可选 provider；它们不是仓库依赖，也不复制其实现：

- AutoBar `1.31`：`AutoBarFrame`、`AutoBarFrameButton1..24`、真实背包物品、
  数量、冷却、分类弹出与拖动。
- TrinketMenu：`TrinketMenu_MainFrame`、`TrinketMenu_Trinket0`（装备槽
  `13`）、`TrinketMenu_Trinket1`（装备槽 `14`）、候选饰品菜单、冷却与自动
  排队。

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
| `AB.RAIL` | 每个已启用 `pfActionBar*` Frame | 自适应九宫格／短连接件；尺寸严格来自 provider 公式；不包含图标、文字或状态 |
| `AB.SLOT` | `pfActionButton1..N` 及对应多栏按钮 | 同几何普通／悬停／按下／激活／禁用底座；真实图标、快捷键、数量、宏名和冷却保持动态 |
| `AB.SLOT.STATE` | pfUI highlight、checked、equipped、unusable、range、OOM、cooldown | 独立 runtime 覆盖；不得将职业色、红／蓝状态或冷却烘焙进槽底 |
| `AB.ENDCAP.GRYPHON` | `pfGryphonLeft`、`pfGryphonRight` | 成对香草狮鹫端帽；仅装饰、不吃点击；水平主栏宽度不足或用户关闭时不显示 |
| `AB.STANCE` | Bar `11` 的真实形态按钮 | 较小但保持可读；不生成不存在的职业形态 |
| `AB.PET` | Bar `12` 的真实宠物按钮 | 保留攻击、跟随、停留、技能与自动施法反馈 |
| `AB.MOVER` | pfUI unlock／`UpdateMovable` | 每个 Bar 独立移动、缩放、重置；视觉不得持续改写 Parent、Point、Width 或 Height |

## 消耗品卷袋

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.CONSUMABLE.RACK` | 优先 `AutoBarFrame`；缺失时为 AEUI feature-detect fallback | 推荐 `5×2` 十个语义口袋，实际支持 `1–24` 个 provider Button 与合法行列；可独立拖动／缩放／显隐 |
| `AB.CONSUMABLE.POCKET` | `AutoBarFrameButtonN` 或 fallback 真实物品 Button | 显示 provider 选出的真实物品图标、数量、冷却、可用性和 Tooltip；槽底不含物品图标或名称 |
| `AB.CONSUMABLE.POPUP` | AutoBar 分类弹出；fallback 钉选面板 | AutoBar 存在时只换肤、不复制分类表或重挂 `PickupContainerItem`；fallback 只允许用户钉选明确 item／已验证 family |

推荐十类是战斗布局预设，不是硬编码物品分类：治疗、资源、复原／应急、绷带、
食物、饮料、战斗药剂、防护药剂、合剂／抗性、职业或工程工具。AutoBar 的真实
类别与用户配置优先；AEUI fallback 不凭名称猜测未知消耗品。

## 饰品双槽

| ID | provider／对象 | 合同 |
|---|---|---|
| `AB.TRINKET.DOCK` | 优先 `TrinketMenu_MainFrame`；缺失时绑定装备槽 `13`／`14` | 两枚真实已装备饰品，水平或垂直；实际图标、快捷键、冷却与 Tooltip 动态 |
| `AB.TRINKET.SLOT13` | `TrinketMenu_Trinket0`／`UseInventoryItem(13)` | 顶部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.SLOT14` | `TrinketMenu_Trinket1`／`UseInventoryItem(14)` | 底部饰品槽；点击使用，不生成固定饰品 |
| `AB.TRINKET.MENU` | TrinketMenu 候选菜单或以后独立合同 | 现阶段保留 provider 原菜单并 fail-open；换装视觉需另行测量候选数量、方向与战斗限制 |

TrinketMenu 已经接管 `UseInventoryItem`、背包更新、装备更新与排队时，AEUI 不再
安装竞争性全局 hook。没有 TrinketMenu 时，fallback 的换装入口只能在非战斗
状态使用；战斗中保留两个已装备饰品的使用反馈，不尝试换装。

## 推荐布局而非强制布局

- `战斗甲板`：Bar 1 为底部居中 `12×1` 主栏；Bar 6 为其上方 `12×1` 副栏；
  姿态／宠物条独立位于上缘；消耗品卷袋在左，饰品双槽在右。
- `紧凑战斗`：主／副栏可改为 `6×2`；自适应 Rail 重新切片，狮鹫端帽缩小或
  隐藏，逻辑按钮数与分页不变。
- `自由侧栏`：Bar 3／4／5 可保持 `4×3`、`6×2` 或竖排并独立移动；不因采用
  推荐预设而失去现有布局。
- 预设只在用户明确点击应用时写入一次。默认读取并尊重现有 profile、位置、
  scale、按钮数、行列、自动隐藏和空槽设置。

## 功能不变量

- 技能、宏、物品、宠物动作、分页、姿态、快捷键、数量、冷却、范围、法力、
  装备态、拖放、Tooltip 与右键语义继续由真实 provider 负责。
- Bar 1、用户标记的战斗核心 Bar、消耗品核心口袋和两枚饰品在战斗中不得因
  mouseover 延迟而消失；非核心辅助栏才可选择脱战淡出。
- 自动隐藏只能改变可见性／Alpha，不在维护循环中搬动或改尺寸。
- 可选 provider 缺失、版本不匹配或 adapter 出错时，局部恢复其原始视觉与
  功能；不得阻止 pfUI 或 AEUI 其余模块加载。
- 不把技能图标、物品图标、文字、数字、键位、冷却、职业状态或真实按钮烘焙
  进背景资产。
