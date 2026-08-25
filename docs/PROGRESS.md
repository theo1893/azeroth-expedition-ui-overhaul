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
| Core／pfUI | `P5` | AEUI `0.9.0`；pfUI 公共功能保留，Chat、Quest、Unit Frames、Map、Character 等只通过精确 route 接管；Gear Planner `1.0-zhCN` 接入 Character 与 Inspect 独立伴随会话并保留独立回退 | 实机验证模块隔离、旧 SavedVariables、两套伴随栏、配置页和禁用回退 |
| Chat | `P5` | runtime `1.22`；Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入、未读蜡封已接入；右框隐藏并恢复经典 provider 配色 | `/reload` 验证 Tab 四态／缩放、输入、频道颜色、链接和消息回收 |
| Quests | `P1–P6` | runtime `1.28`、Theme `1.11`；已完成且挂载的书体、目录、奖励槽、火漆／闭合载体均为 2× runtime，逻辑几何不变；事务菜单未启用，Tracker 仍需重审区域 | 完整重启后实机验证双纹理书体接缝、奖励槽与火漆；再用真实 tracker 区域重做简单预演 |
| Action Bars | `P2–P6` | AEUI `0.9.0`；Slot／Rail `P6`；Field Kit `2.9`、Focus `3.5`、Sidebar Group `1.0`、Target Markers `2.3` 为 `P5`；Player／Target 保持 `240×48 / 0.8`、底锚点 `480 UI`、`23 UI / 每排 8` Aura 与 `73 UI` 间距；Aura 语义策略为 Player 仅技能书 Buff／全部 Debuff，敌对单位全部真实 Buff／自己施加与固定 `12` 项关键 Debuff 的并集，友方单位自己施加的 Buff／全部 Debuff，TargetTarget 与 Focus 同步按敌友套用；下方施法／Swing、Combat Deck 与所有角色 DDPS `TOPLEFT (650,-615)` 原位；AutoBar 固定四列、自底向上；标记方阵为骷髅优先 `4×2`，八个透明命中位共用既有 Consumable Kit 的缝制皮革九宫格并直读 `mark1..mark8`；空态使用中央大标记，占用态改用左下满亮小标记、顶部两行名字和右下血量；死亡目标只从 AEUI 方阵本地清空；ArchiTotem 相对旧居中位左移 `128 UI`，方阵留在既有位置，向下候选不再覆盖皮革 icon list；左侧 DDPS 坦克 Button 固定在 Combination 的真实 Frame 边界内并始终显示，provider 或装饰刷新异常时也保留基础可点击盾牌；provider API 就绪时左键指定、右键清除，未就绪时显示不可用态；右侧一键 Button 仅在 HDLRaidTools／SuperWoW provider 完整就绪时显示 | 实机验证四框敌友 Aura 过滤、重载后友方 Buff 归属、Action Bars 禁用回退及另一角色 v5 默认迁移；再验证标记、图腾、坦克／一键 Button、职业栏、popup、DDPS 中央视野、`13` 格 `4/4/4/1` 和姿态 `25 UI` |
| Map | `P5` | runtime `7.6`；WorldMap 暂停；mask、V4 non-bottom 托盘与 V7 bottom 收纳袋为高分辨率 runtime；V3 罗盘／扣具／插槽因仅存 1× accepted source 登记明确例外且未伪放大；逻辑几何不变 | 完整重启后实机验证 mask、V4 九切片、V7 徽记压接、袋内净空、0／6／12／22／30、图标层序、缩放、显隐及回退 |
| Spellbook | `P4 / integration paused` | accepted `SB-A2-DONOR V1` source/runtime 保留；AEUI Spellbook adapter 与精确 ownership 暂停，客户端恢复 pfUI 技能书 | 依据 handoff 实机图核对四块 TGA 对位、层序、provider region 和动态控件净空，再恢复接入 |
| Talents | `P1 / paused` | 已对齐动态背景、4×8 节点、Rank、分支／箭头、Tab 与 Turtle Inspect 边界；不再与 Spellbook 共用模块进度 | 等用户明确恢复后制作独立预演 |
| Character | `P2–P5 / active` | runtime `2.0`；外壳、PaperDoll 组件、装备槽、Tabs、Ammo 与分页档案页保持 2× runtime；Gear Planner `1.0-zhCN` 提供 Character 三视图、`984 UI` 配装合同、当前／配装／变化属性对比与 Inspect“装／属／比／存”独立会话，不改 Provider Parent、尺寸或数据 | 实机复核既有 PaperDoll／分页组件，再验证配装净空、即时属性对比、角色与观察伴随栏及禁用回退 |
| Gear Planner | `P5` | runtime `1.0-zhCN`；accepted `GEAR-MAIN-V1` 军需官折叠案板已按外壳、填充、标题／铰链、顶部控件、槽位和属性纸导出为 2× runtime；`560×555` 伴随配装把 19 槽与“当前／配装／变化”同屏，不烘焙动态内容；AtlasLoot 仍持有查询、分页、来源和 Wishlist | 完整重启后实机验证案板层序／缩放，19 槽与统计纸接缝，琥珀／冷蓝状态，再回归武器差值、AtlasLoot、方案 CRUD 与角色／观察伴随栏 |
| Unit Frames | `P4–P5 / Player V5 + nameplate cue active` | runtime `1.9`；Bars、Raid A2、Player V5 与 `NP-TARGET-CUE-V1` 均从 accepted source 导出为 2× runtime；姓名板指针复用 pfUI 目标状态，团队标记不再随血条隐藏；Target／TargetTarget／Focus 新外壳仍暂停并回退 pfUI | 完整重启后实机验证团战目标指针、隐藏血条＋团队标记堆叠、禁用回退，并相邻回归 Bars、40 人 Raid 与 Player V5 |

## 尚未启动

Combat HUD、DPS／Threat、Bags／Loot／Roll、Profession、Economy、Social 与
System 继续使用 pfUI 默认实现。启动时先完成真实对象对齐，不为规划
中的假组件提前生成资产或增加文档。
