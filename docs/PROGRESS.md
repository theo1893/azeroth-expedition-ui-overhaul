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
| Bagshui | `P1–P5` | runtime `1.3` 主框、工具栏、物品槽与底部袋位已接入，标题回退原生，品质及交互状态仍由 provider 更新；全角色默认，`/aeui bags` 回退 | 完整重启实机验证首版主框、搜索、编辑模式、离线库存与回退 |
| Tooltips | `P5` | runtime `1.0`；通用、链接、双比较、地图及可选 AtlasLoot 提示复用 Readout V1 的 1 UI 细边，单位生命条接入现有 2× 填充；独立 `/aeui tooltips` 回退 | 实机验证长文本、比较排列、单位颜色、地图、关闭按钮与禁用回退 |
| Core／pfUI | `P5` | AEUI `0.9.0`；pfUI 公共功能保留，Chat、Quest、Unit Frames、Map、Character 等只通过精确 route 接管；Gear Planner `1.2-zhCN` 接入 Character 与 Inspect 独立伴随会话并保留独立回退 | 实机验证模块隔离、旧 SavedVariables、两套伴随栏、配置页和禁用回退 |
| Chat | `P5` | runtime `1.22`；Full V1 主框、Dark V2 Tab／承托带、Dark V1 输入、未读蜡封已接入；右框隐藏并恢复经典 provider 配色 | `/reload` 验证 Tab 四态／缩放、输入、频道颜色、链接和消息回收 |
| Quests | `P1–P6` | runtime `1.28`、Theme `1.11`；已完成且挂载的书体、目录、奖励槽、火漆／闭合载体均为 2× runtime，逻辑几何不变；事务菜单未启用，Tracker 仍需重审区域 | 完整重启后实机验证双纹理书体接缝、奖励槽与火漆；再用真实 tracker 区域重做简单预演 |
| Action Bars | `P2–P6` | AEUI `0.9.0`；ReadoutArt `1.0 / P5` 玩家／目标施法与攻击细轨已接入2×媒体；Slot／Rail `P6`；Field Kit `3.0`、Supply `2.1`、Focus `3.5`、Sidebar Group `1.0`、Target Markers `2.4` 为 `P5`；AEUI Supply 以每角色固定槽位命名组保存有序精确 itemID 与固定主物品，组可移动或交换，主格左键只使用固定主物品，悬停／右键展开 AEUI 自有候选抽屉，候选左键只使用、右键只设主格；库存仅在 `0` 时红色提示，正库存统一正常显示且无左上告警数字；AutoBar 已从 AEUI 运行时与客户端活动 AddOns 移除，Supply 为左侧唯一补给栏，无配置或关闭时留空；Player／Target 保持 `240×48 / 0.8`、底锚点 `480 UI`、`23 UI / 每排 8` Aura 与 `73 UI` 间距；Aura 语义策略为 Player 仅技能书 Buff／全部 Debuff，敌对单位全部真实 Buff／自己施加与固定 `12` 项关键 Debuff 的并集，友方单位全部真实 Buff／Debuff，TargetTarget 与 Focus 同步按敌友套用；下方施法／Swing、Combat Deck 与所有角色 DDPS `TOPLEFT (650,-615)` 原位；标记方阵为骷髅优先 `4×2`，八个透明命中位共用既有 Consumable Kit 的缝制皮革九宫格并直读 `mark1..mark8`；空态使用中央大标记，占用态改用左下满亮小标记、顶部两行名字和右下血量；死亡目标只从 AEUI 方阵本地清空；ArchiTotem 相对旧居中位左移 `128 UI`，方阵留在既有位置，向下候选不再覆盖皮革 icon list；左侧 DDPS 坦克 Button 固定在 Combination 的真实 Frame 边界内并始终显示，provider 或装饰刷新异常时也保留基础可点击盾牌；provider API 就绪时左键指定、右键清除，未就绪时显示不可用态；右侧一键 Button 仅在 HDLRaidTools／SuperWoW provider 完整就绪时显示 | 实机验证 Supply 旧配置迁移、组位置／命名、固定主物品、候选点击与 CD、零库存显示、无配置／关闭空态、Action Bars 禁用回退及另一角色隔离；再验证四框敌友 Aura、标记、图腾、坦克／一键 Button、DDPS 中央视野和姿态 `25 UI` |
| Map | `P5` | runtime `7.6`；WorldMap 暂停；mask、V4 non-bottom 托盘与 V7 bottom 收纳袋为高分辨率 runtime；V3 罗盘／扣具／插槽因仅存 1× accepted source 登记明确例外且未伪放大；逻辑几何不变 | 完整重启后实机验证 mask、V4 九切片、V7 徽记压接、袋内净空、0／6／12／22／30、图标层序、缩放、显隐及回退 |
| Spellbook | `P4 / integration paused` | accepted `SB-A2-DONOR V1` source/runtime 保留；AEUI Spellbook adapter 与精确 ownership 暂停，客户端恢复 pfUI 技能书 | 依据 handoff 实机图核对四块 TGA 对位、层序、provider region 和动态控件净空，再恢复接入 |
| Talents | `P1 / paused` | 已对齐动态背景、4×8 节点、Rank、分支／箭头、Tab 与 Turtle Inspect 边界；不再与 Spellbook 共用模块进度 | 等用户明确恢复后制作独立预演 |
| Character | `P2–P5 / active` | runtime `2.1`；保留既有 2× PaperDoll 与 Gear Planner 伴随逻辑，补齐侧栏皮革、称号／属性下拉、分页控件与文字对齐；三切片纸页覆盖底部 gap | `/reload` 验证侧栏、下拉、折叠／滚动、PvP 与纸页底边；相邻装备提示／详情和 Character 禁用回退 |
| Gear Planner | `P5` | runtime `1.2-zhCN`；角色栏按钮复用深皮革工具签且双栏按真实 Provider 宽度判断；accepted `GEAR-MAIN-V1` 军需官案板与 `GEAR-SLOT-STATES-V1` 强／弱黄铜夹签、冷灰蓝修订缝带均为 2× runtime；AtlasLoot 仍持有查询、分页、来源和 Wishlist | 完整重启后实机验证角色栏按钮、默认双栏、三种槽位 sprite、保存状态与方案选中反馈，再回归案板层序、武器差值、AtlasLoot、方案 CRUD 与观察栏 |
| Unit Frames | `P5 / 细边框试用` | runtime `2.1`；玩家／目标／目标的目标／焦点复用 Raid A2 A／B／C／D 细边框，外扩 `2 UI`，厚外壳 route 暂停；团队、Bars、姓名板与动态头像保持原接入 | 实机比较四框细边框、精英龙饰和禁用回退，相邻检查团队边框 |
| Group Finder | `P5 / standalone MVP` | `0.1.1` 使用隐藏的 `AEGF1` 自定义频道同步完整招募目录及带收件人的申请／回执，面板直接显示团长、T/N/D、当前／目标职业、最低装等与装备竞争摘要；身份只取服务器频道事件，不依赖 LFT、预先组队或外部服务器 | 双客户端复核申请状态从“已发送”到“已收到”，再验证频道是否全服／跨阵营、频道隐藏、发布／同步／过期、最低装等拒绝、邀请／拒绝／停招及限流 |

## 尚未启动

Combat HUD、DPS／Threat、Bags／Loot／Roll、Profession、Economy、Social 与
System 继续使用 pfUI 默认实现。启动时先完成真实对象对齐，不为规划
中的假组件提前生成资产或增加文档。
