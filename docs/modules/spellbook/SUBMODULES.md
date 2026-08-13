# Spellbook 子模块定义

本文件只定义技能书同原生 Blizzard／pfUI 对象的边界。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。目标为
Turtle WoW `1.18.1`／Interface `11200`；不改变法术、翻页、Tooltip、冷却、
宠物自动施法或 SavedVariables 行为。

## 已证实来源与结构

| 文件／provider | 已证实职责 | 项目处理 |
|---|---|---|
| [`skins/blizzard/spellbook.lua`](../../../addon/pfUI/skins/blizzard/spellbook.lua) | Strip 原生技能书纹理，建立半透明规则 backdrop，并重排法术、书类 Tab、技能系 Tab、翻页和关闭 | 撤销现代透明方框和规则 Button skin；保留真实对象与行为 |
| Blizzard 1.12.1 `SpellBookFrame.xml` | 384×512 主框、每页 12 个法术、3 个书类 Tab、最多 8 个技能系 Tab、翻页和宠物自动施法状态 | 香草结构权威；Turtle 缺失对象必须 feature-detect |

原生 `SpellBookFrame` 为 384×512 竖向面板，法术区是两列、每列六行。视觉可以
表现为一本正面打开的私人法术秘典，但不能改成现代纵向列表、横向大书或新的
信息架构。

## 真实组件

| ID | 原生对象 | 合同 |
|---|---|---|
| `SB.FRAME` | `SpellBookFrame` | 非交互主外壳；保留移动／命中区；不得烘焙法术、文字、Tab、翻页或关闭 |
| `SB.PAGE.FIELD` | 主框内法术阅读区 | 安静的旧羊皮页场；两列内容安全区连续，纹理不得压过文字和图标 |
| `SB.EMBLEM` | 原生 `Spellbook-Icon` 58×58 Texture | 当前合同固定隐藏；主外壳不烘焙职业／技能书图标，除非用户以后明确重开该组件 |
| `SB.SPELL` | `SpellButton1..12` | 37×37 独立图标按钮；图标、名称、等级、冷却、Checked、Highlight、Tooltip 与点击动态；两列×六行，约 51px 行距 |
| `SB.AUTOCAST` | `SpellButton*AutoCastable` 与宠物法术状态 | 独立动态覆盖；不得进入按钮底图；保留开关与闪烁语义 |
| `SB.BOOK.TAB` | `SpellBookFrameTabButton1..3` | 独立普通／悬停／按下／选中／禁用状态；真实文字动态 |
| `SB.SKILL.TAB` | `SpellBookSkillLineTab1..MAX_SKILLLINE_TABS` | 最多 8 个右侧技能系入口；动态图标、Checked、Highlight 与 Flash 分层；缺失对象不留空槽 |
| `SB.PAGE.PREV` | `SpellBookPrevPageButton` | 独立四态翻页 Button；保留禁用逻辑 |
| `SB.PAGE.NEXT` | `SpellBookNextPageButton` | 独立四态翻页 Button；保留禁用逻辑 |
| `SB.PAGE.TEXT` | `SpellBookPageText` | 动态页码，layout-only，不烘焙数字 |
| `SB.TITLE` | `SpellBookTitleText` | 动态标题，layout-only |
| `SB.CLOSE` | `SpellBookCloseButton` | 独立四态关闭 Button |

## 几何、层序与缩放

- 首列从约 `x=34`、第二列从约 `x=191` 开始；六行从约 `y=85` 开始，纵向
  节距约 `51`。外壳不得侵入图标、名称、等级、底部翻页或右侧技能系 Tab。
- 左上 `x=10..68, y=8..66` 保持安静的封皮净空，原生 `SB.EMBLEM` 固定隐藏；
  右上关闭、右侧技能系和底部书类 Tab／翻页均为独立对象；主外壳不得烘焙
  对应徽记或假槽。
- 静态页场位于最底层；法术图标、冷却、自动施法、文字与交互状态在其上。
- 书类 Tab、技能系 Tab、翻页和关闭必须保留独立点击对象与状态纹理。
- 当前 384×512 外壳按 Blizzard 原生四块纹理无损重组；整体只允许等比缩放，
  不得各向异性拉伸完整手绘候选。
- 运行时读取真实对象尺寸；unsupported provider 或模块禁用时回退 pfUI／
  Blizzard，不改变技能书功能。
