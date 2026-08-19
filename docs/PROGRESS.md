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
| Core／pfUI | `P5` | AEUI `0.8.36`；pfUI 公共功能保留，Chat、Quest、Unit Frames、Map、Character 等只通过精确 route 接管 | 实机验证模块隔离、旧 SavedVariables、配置页和禁用回退 |
| Chat | `P5` | runtime `1.22`；Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入、未读蜡封已接入；右框隐藏并恢复经典 provider 配色 | `/reload` 验证 Tab 四态／缩放、输入、频道颜色、链接和消息回收 |
| Quests | `P1–P6` | runtime `1.27`、Theme `1.10`；Quest Log 书体与目录已获实机确认；奖励槽和闭合火漆载体 `P5`；事务菜单未启用，Tracker 仍需重审区域 | 实机验证奖励槽与火漆；先用真实 tracker 区域重做简单预演 |
| Action Bars | `P2–P6` | AEUI `0.8.36`；Slot／Rail `P6`；Field Kit `2.9`、Focus `2.7`、Sidebar Group `1.0`、Target Markers `2.0` 为 `P5`；所有角色 DDPS 统一 `TOPLEFT (650,-615)`；AutoBar 固定四列、自底向上；标记方阵为骷髅优先 `4×2`，八个透明命中位共用既有 Consumable Kit 的缝制皮革九宫格并直读 `mark1..mark8`；空态使用中央大标记，占用态改用左下满亮小标记、顶部两行名字和右下血量；死亡目标只从 AEUI 方阵本地清空；整体位于 `BACKGROUND`，低于 ArchiTotem 展开候选；一键 Button 仅在 HDLRaidTools／SuperWoW provider 完整就绪时显示 | 实机验证长名字下的标记身份、死亡目标本地清空、图腾候选展开后的显示／点选、一键 Button 条件显隐与怪群设标、职业栏停靠，再复查 popup、DDPS 中央视野、`13` 格 `4/4/4/1` 和姿态 `25 UI` |
| Map | `P5` | runtime `4.0`；WorldMap 保持暂停；Minimap V3 罗盘／信息托架／圆形 mask／状态插槽／锁扣与 V4 四向九切片工具卷已接入；独立 connector 已退出运行时，锁扣直接压住工具卷，真实插件图标与行为仍由 provider 持有 | 实机验证直接搭接、0／多插件安全区、四向展开、通知、缩放、显隐与 FarmMode 恢复 |
| Spellbook | `P4 / integration paused` | accepted `SB-A2-DONOR V1` source/runtime 保留；AEUI Spellbook adapter 与精确 ownership 暂停，客户端恢复 pfUI 技能书 | 依据 handoff 实机图核对四块 TGA 对位、层序、provider region 和动态控件净空，再恢复接入 |
| Talents | `P1 / paused` | 已对齐动态背景、4×8 节点、Rank、分支／箭头、Tab 与 Turtle Inspect 边界；不再与 Spellbook 共用模块进度 | 等用户明确恢复后制作独立预演 |
| Character | `P2–P5 / active` | runtime `1.9`；外壳、模型底、属性纸、抗性槽、E1／E2-A 装备槽、F1 Tabs 与 E3 Ammo 均由 accepted source 导出为 2× runtime；原生 UI 几何、点击及动态内容不变 | 实机复核清晰度、属性纸／文字、装备槽、Tabs、Ammo 动态图标／数量／冷却、缩放及禁用回退；稳定后做 E2-B 或 E4 空槽 |
| Unit Frames | `P4–P5 / Player V5 active` | Bars／Raid／动态头像继续运行；Player V5 完整单图外壳已接入，Target／TargetTarget／Focus 新外壳仍暂停并回退 pfUI | 实机验证 Player `240×60` 配置对应的 `240×65` provider、UI Scale、层序与禁用回退 |

## 尚未启动

Combat HUD、DPS／Threat、Bags／Loot／Roll、Profession、Economy、Social 与
System 继续使用 pfUI 默认实现。启动时先完成真实对象对齐，不为规划
中的假组件提前生成资产或增加文档。
