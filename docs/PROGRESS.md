# Overhaul 模块整体进度

本文件只记录模块当前阶段和下一门禁。实现历史由 Git 保存，组件细节见模块
`PROGRESS.md`。

## 阶段

| 阶段 | 含义 |
|---|---|
| `P0` | 尚未确认 provider／对象 |
| `P1` | 已对齐真实对象与功能所有权 |
| `P2` | 结构和美术方向已确认 |
| `P3` | 正在生产或审查候选 |
| `P4` | 用户接受 source 像素 |
| `P5` | runtime 已接入并通过静态包装检查 |
| `P6` | Turtle WoW 实机验收通过 |

## 当前模块

| 模块 | 阶段 | 当前结论 | 下一门禁 |
|---|---:|---|---|
| Core／pfUI | `P5` | AEUI `0.8.31`；pfUI 公共功能保留，Chat、Quest、Unit Frames、Spellbook 等只通过精确 route 接管 | 实机验证模块隔离、旧 SavedVariables、配置页和禁用回退 |
| Chat | `P5` | runtime `1.22`；Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入、未读蜡封已接入；右框隐藏并恢复经典 provider 配色 | `/reload` 验证 Tab 四态／缩放、输入、频道颜色、链接和消息回收 |
| Quests | `P1–P6` | runtime `1.27`、Theme `1.10`；Quest Log 书体与目录已获实机确认；奖励槽和闭合火漆载体 `P5`；事务菜单未启用，Tracker 仍需重审区域 | 实机验证奖励槽与火漆；先用真实 tracker 区域重做简单预演 |
| Action Bars | `P2–P6` | Slot／Rail `P6`；Field Kit `2.8`、Focus `2.5`、Sidebar Group `1.0` 为 `P5`；AutoBar 当前固定四列、自底向上 | 实机验证 `13` 格 `4/4/4/1`、主栏挂靠、姿态 `25 UI` 与相关 provider |
| Map | `P2–P5` | runtime `1.0`；World attempt 1 与 Mini attempt 2 已提升并接入非交互羊皮卷／罗盘外壳；动态地图、pfQuest、真实控件及 Farm mode 保持 provider 所有权 | 实机验证缩放、层级、动态文字、相邻控件、Farm mode 与 `/aeui map` 回退 |
| Spellbook | `P5` | runtime `1.0`；`SB-A2-DONOR V1` source/runtime 与四块原生 TGA 已接入；pfUI 现代 backdrop 关闭，原生动态控件保留，左上图标隐藏 | 实机验证对位、缩放、动态层序、图标隐藏和 `/aeui spellbook` 回退 |
| Character | `P2 / paused` | 香草同构角色面板方向保留，当前使用 pfUI 默认 skin | 等用户明确恢复 |
| Unit Frames | `P5` | runtime `1.5`；头像关闭、Health／Power、Raid A2、Player／Target V4、TargetTarget A2 与 Focus A2 均已接入；Focus 使用材料 donor＋Python 精确造壳 | 实机验证四类主／次级外壳的九切片、状态层序、Aura／施法条净空及禁用回退 |

## 尚未启动

Combat HUD、DPS／Threat、Bags／Loot／Roll、Talent／Profession、Economy、Social 与
System 继续使用 pfUI 默认实现。启动时先完成真实对象对齐，不为规划
中的假组件提前生成资产或增加文档。
