# Talents 子模块定义

本文件只定义天赋树同 Blizzard／pfUI／Turtle 对象的边界。当前模块暂停，技能书
工作不得修改这些对象。

## 真实组件

| ID | 原生对象 | 合同 |
|---|---|---|
| `TL.FRAME` | `TalentFrame`；兼容 `PlayerTalentFrame` | 384×512 非交互外壳；保持原面板行为 |
| `TL.BACKGROUND` | 四块 `TalentFrameBackground*` | 320×384 动态职业／专精画面；不得静态替换 |
| `TL.VIEWPORT` | `TalentFrameScrollFrame／ScrollChildFrame` | 296×332 真实滚动与裁切 |
| `TL.NODE` | `TalentFrameTalent1..20` | 37×37 动态节点；4 列×8 阶、63px 节距；图标、Rank、Tooltip 与点击动态 |
| `TL.RANK` | `TalentFrameTalent*RankBorder／Rank` | 独立动态 Rank 与原绿色／金色／灰色语义 |
| `TL.BRANCH` | `TalentFrameBranch1..30` | 32×32 动态分支；满足／不满足先决条件分态 |
| `TL.ARROW` | `TalentFrameArrow1..30` | 32×32 动态方向箭头 |
| `TL.TAB` | `TalentFrameTab1..5` | 按真实数量显示，通常 3 个；动态专精名 |
| `TL.POINTS` | `TalentFrameSpentPoints／TalentPointsText` | 动态文字与数值 |
| `TL.PORTRAIT／TITLE／SCROLLBAR／CLOSE` | 对应原生对象 | 分别保留动态内容与交互，不并入静态背景 |
| `TL.INSPECT` | Turtle `TWTalentFrame` | 独立 Inspect provider；玩家天赋完成后再兼容 |

仓库只有 `SpecialTalentUI` 配置开关，没有 provider 源码；获得真实对象前不为它
生成资产。层序固定为动态背景之上绘制分支／箭头、节点、Rank、文字与 Tooltip。
