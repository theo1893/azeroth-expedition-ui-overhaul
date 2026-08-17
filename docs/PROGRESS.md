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
| Core／pfUI | `P5` | AEUI `0.8.33`；pfUI 公共功能保留，Chat、Quest、Unit Frames、Map 等只通过精确 route 接管 | 实机验证模块隔离、旧 SavedVariables、配置页和禁用回退 |
| Chat | `P5` | runtime `1.22`；Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入、未读蜡封已接入；右框隐藏并恢复经典 provider 配色 | `/reload` 验证 Tab 四态／缩放、输入、频道颜色、链接和消息回收 |
| Quests | `P1–P6` | runtime `1.27`、Theme `1.10`；Quest Log 书体与目录已获实机确认；奖励槽和闭合火漆载体 `P5`；事务菜单未启用，Tracker 仍需重审区域 | 实机验证奖励槽与火漆；先用真实 tracker 区域重做简单预演 |
| Action Bars | `P2–P6` | Slot／Rail `P6`；Field Kit `2.8`、Focus `2.7`、Sidebar Group `1.0` 为 `P5`；所有角色 DDPS 统一 `TOPLEFT (650,-615)`；AutoBar 当前固定四列、自底向上 | 实机验证 DDPS 中央视野净空、`13` 格 `4/4/4/1`、主栏挂靠、姿态 `25 UI` 与相关 provider |
| Map | `P4–P5` | WorldMap 保持暂停；Minimap V2 圆形 mask、184 罗盘、动态插件工具带与 FarmMode 回退已接入并通过轻量检查 | 实机验证圆形裁剪、尺寸／缩放、四向插件入口、通知、显隐与 `/farm` 恢复 |
| Spellbook | `P4 / integration paused` | accepted `SB-A2-DONOR V1` source/runtime 保留；AEUI Spellbook adapter 与精确 ownership 暂停，客户端恢复 pfUI 技能书 | 依据 handoff 实机图核对四块 TGA 对位、层序、provider region 和动态控件净空，再恢复接入 |
| Talents | `P1 / paused` | 已对齐动态背景、4×8 节点、Rank、分支／箭头、Tab 与 Turtle Inspect 边界；不再与 Spellbook 共用模块进度 | 等用户明确恢复后制作独立预演 |
| Character | `P2 / active` | 原生 `384×512` PaperDoll 已对齐；无左上 icon 的 `CHAR-SIM-V2` 已接受；当前仍使用 pfUI 默认 skin | 授权首批静态基础层 production 合同 |
| Unit Frames | `P4–P5 / Player V5 active` | Bars／Raid／动态头像继续运行；Player V5 完整单图外壳已接入，Target／TargetTarget／Focus 新外壳仍暂停并回退 pfUI | 实机验证 Player `240×60` 配置对应的 `240×65` provider、UI Scale、层序与禁用回退 |

## 尚未启动

Combat HUD、DPS／Threat、Bags／Loot／Roll、Profession、Economy、Social 与
System 继续使用 pfUI 默认实现。启动时先完成真实对象对齐，不为规划
中的假组件提前生成资产或增加文档。
