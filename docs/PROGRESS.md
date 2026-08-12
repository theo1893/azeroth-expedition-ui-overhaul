# Overhaul 模块整体进度

这是主模块阶段、当前结论和下一门禁的唯一全局进度表。组件与资产细节只写在
对应模块的 `PROGRESS.md`；生产过程只写在该模块现存的 `work/` 文件。

## 阶段

| 阶段 | 含义 |
|---|---|
| `P0` | 尚未取得可靠对象或 provider |
| `P1` | 已对齐 pfUI／原生对象 |
| `P2` | 主模块视觉与结构基线已锁定 |
| `P3` | 组件生产 Prompt 已授权并形成候选 |
| `P4` | 用户确认透明源资产 |
| `P5` | runtime 接入并通过静态测试 |
| `P6` | Turtle WoW 实机验收通过 |
| `P6-C` | 最终产物保留；整模块验收范围已冻结，`generated/<module>/`、全部模块 `work/` 与经审计的 legacy 中间数据均已清理并通过关闭校验 |

## 当前模块

| 主模块 | pfUI／原生边界 | 阶段 | 当前结论 | 下一门禁 |
|---|---|---:|---|---|
| Core／pfUI | `api/expedition.lua`、`pfUI.lua`、作用域接管路由 | `P5` | pfUI `8.1.0-aeui.5` 已恢复公共绘制、原始默认值、全部未接管模块／skins 与配置入口；Expedition contract v6 只让渡 Chat 辅助模块、Quest Log skin、Unit Frame 两张 fill donor、Raid 成员外壳与 `unitframes.dynamic-portraits` 精确呈现 route；旧全局回退 SavedVariables 一次迁移；swingtimer 已按攻速／玩家光环变化等比例重标活动主副手区间，修正乱舞首击与末击的攻速错位，尚待实机 | 实机覆盖 Game Menu／`/pfui`、全模块加载、旧 SavedVariables、单模块失败隔离、第三方兼容、Unit Frames 动态头像关闭／局部回退，以及乱舞触发／耗尽时的首末击计时 |
| Chat | `modules/chat.lua` + AEUI Chat adapter | 核心 `P5` / r1.22；Tab 替换 `P5` | Full V1 主框九宫格、右框回收、Dark V2 四态 Tab／承托带、Dark V1 输入及 V3 未读已在 addon 内接入；V3 Tab／承托带保留为回退。Dark V2 固定 source SHA `616f965b…a1e3c` 确定性导出为 atlas `3fb505fa…be0` 与 shelf `44c7f85c…fda`；RGB-only 清理 source `13`＋LANCZOS `23` 个低 Alpha 绿边像素，Alpha 不变，最终绿溢色 `0`。六个最终真实排版场景、display-region 和 fresh-checkout package 均通过；目标设备无需构建。v1.22 保持经典 provider 配色 | 游戏设备可用时 `/reload`，验证 `chat-runtime=1.22`、四态／五 Tab 压缩、承托带、缩放、输入与经典颜色；通过前保持 P5 |
| Quests | `questlog.lua`、`gossipquest.lua`、`questitem.lua`、`pfQuest`／`pfQuest-turtle` + AEUI Quests adapter | `P1–P6`；QS-B1 V7-A `P5`；QL-D V3 attempt 4 `P5` | Quest runtime `1.27`／Theme `1.10`。QL-D 五次循环仍按 `5/5` 耗尽；用户随后明确“使用第4稿”，接受 keyed aspect `2.76945` 的一次性选稿例外，原 technical `18/19` 不重写。exact source SHA `816aeedd…47c5` 与四态 atlas SHA `cda1ef21…cd56` 已受 manifest 管理并接入 addon；正式 atlas／真实排版与已审阅 attempt 4 像素完全一致，display `5/5 pass`。真实 Button、Tooltip、动态图标／名称和双列几何不变。闭合载体根、火漆与旧功能按钮继续 fail-open；Tracker 与 NPC Quest／Gossip 不变 | Turtle WoW 验证 QL-D TGA 方向、四态、pressed `1px` 联动、safe area、0／1／2／4／6 排版及长详情滚动；同时验证闭合态火漆物理接触与滚动裁切。七纹章 parity 前不启用事务菜单；不得第六次生图 |
| Action Bars／Field Kit | `actionbar.lua`、`castbar.lua`、`swingtimer.lua`、pfUI Player／Target／TargetTarget + 可选 AutoBar／TrinketMenu／DoiteDPS／ArchiTotem 的 scoped 视觉与一次性游戏坐标布局 | `P2–P6`；`AB.SLOT.BASE.V1` 与 `AB.RAIL.V1` 均为 `P6 / game-validated`；Field Kit 视觉 runtime-v1.5／bridge-v2.8、Combat Focus runtime-v2.6 与 Sidebar Group runtime-v1.0 为 `P5 / pending-game-validation`；v1.4／v1.5 `game-geometry-failed` | AEUI `0.8.26`／`ACTION-BARS-CORE-SIM-V11` 保留既有单位框、Aura、计时栈、系统字体、DoiteDPS 与四栏组合。最新 `1337×542` 实机证据否决 v2.7／v2.5：AutoBar 仍显示活动 display 自由坐标，放大的姿态栏仍被旧绝对 `BOTTOM (0,255)` 压入主栏。bridge-v2.8 以活动 `AutoBar.display` 表身份为权威，并通过主栏相对全局代理 Frame 让每次 provider `SetupVisual` 原生落到同一位置。focus runtime-v2.6／profile v17 使用 `BOTTOM (0,130)` 安全 fallback，live 以 `TOP → 主栏 BOTTOM / 12 UI` 绑定，覆盖 bars 重建、姿态／宠物事件、宠物显隐及 unlock 关闭；姿态独立 mover 隐藏。MoveAnything 无相关条目。全部位图字节不变，无外部生成 | `/reload` 后验证卷袋在主栏左侧、姿态在主栏下方 `12 UI`；连续 apply、配置开关、主栏移动、姿态切换、宠物显隐和 unlock 开关均不跳位。状态应含 `fieldkit-contract=2.8`、`focus-layout-contract=2.6`、`autobar-provider-dock=bound`、`focus-layout-stance-anchor=main-bottom`、`focus-layout-stance-gap=12`；继续复测系统字体、Aura、Boss Debuff、计时栈、单 mover、四栏可逆 unbind、popup／Queue／换装；回退：`/aeui focuslayout restore` 后 `/reload` |
| Map | `map.lua`、`minimap.lua`、`addonbuttons.lua` 等 | `P2` | 羊皮地图卷与黄铜罗盘已锁定 | 实机对象审计和组件级合同 |
| Character | `character.lua`、`inspect.lua`、`dressup.lua` | `P2 / paused` | 香草同构角色面板已锁定；用户于 `2026-08-08` 暂停 overhaul，现有资产、Prompt 与 pfUI 默认 runtime 原样保留 | 待用户明确恢复后再做实机几何与装备槽／属性／页签拆分 |
| Unit Frames | `api/unitframes.lua`、`modules/raid.lua`、`raidmarkers.lua`、`marktracking.lua`、主／紧凑单位入口 | 动态头像 runtime `1.2 / P5`；Player／Target V4 `P4 source-accepted`；V3 A／B `P3 / 5/5 exhausted` 历史；B1 `P5`；Raid A2 `P5 source/runtime/addon / 5/5`；紧凑 A2 paused | 13 组 pfUI UnitFrame `portrait` 与两套 Raid Marker tracker 头像已统一关闭；原值由 AEUI 持久备份，pfUI 重施配置时保持关闭，模块／route 禁用时精确回退。角色／观察／试衣间 3D 预览不在该合同内。用户接受的 `UF-PRIMARY-V4-CANDIDATE-V1` exact pixels、B1 与 Raid A2 媒体均未改动；V4 因 Combat Focus `240×60` 与固定 `214×42` 合同不兼容继续停在 P4。runtime／repository／既有资产合同和 fresh-checkout package 均通过，无外部生成 | Turtle WoW `/reload` 验证全部单位框和两套 tracker 无动态头像、`/pfui` 应用后不回退，并开关 `/aeui unitframes` 验证原值／布局恢复；另先建立 V4／Combat Focus 兼容合同，再独立执行 Player／Target P5。Raid／B1 等待 P6 |

## 尚未启动长期模块包

这些模块继续使用 pfUI 默认实现与呈现。启动其中任一模块时，先建立
`SUBMODULES.md`、`ART_BASELINE.md`、`SUBMODULE_ART_BASELINES.md` 和
`PROGRESS.md`，再只为目标模块登记接管路由并进入资产生产。

| 计划模块 | pfUI 入口 | 当前阶段 | 方向／下一步 |
|---|---|---:|---|
| Combat HUD | `castbar.lua`、`buff*.lua`、`nameplates.lua`、计时模块 | `P1` | 分开状态条、端帽、图标槽与警告 |
| DPS／Threat | pfUI 无完整 meter | `P0` | 先确定数据源与 Turtle WoW API |
| Bags／Loot／Roll | `bags.lua`、`loot.lua`、`roll.lua` | `P1` | 物品槽与需求／贪婪／放弃按钮分别拆分 |
| Spell／Talent／Profession | 对应 Blizzard skins | `P1` | 保留香草书本／树节点结构，先审计真实对象 |
| Economy | `merchant.lua`、`auction.lua`、`mail.lua`、`trade.lua` | `P1` | 列表、金币、附件与不可逆操作优先 |
| Social | `friends.lua`、`socialmod.lua`、`lfg.lua`、`lft.lua` | `P1` | 复用高密度列表组件 |
| System | `tooltip.lua`、`gui.lua`、`popup_dialogs.lua`、其余 skins | `P1` | 先建立公共按钮、Tab、滚动条与 Tooltip |

## 当前运行时路由

- 项目接管：pfUI `chat` 行为与 AEUI V3 单一左侧战地旧书视觉；AEUI
  QL-A2 V4 任务日志固定书体与安全区、QL-B0 18 行可读目录、QL-B1
  地区箭头，以及 Quests `1.27`（QL-C 子合同 `1.7`）的 pfQuest 后加载
  布局兼容。Quest Log 的 QS-A1 `32px` 火漆与 QS-B1 V7-A 闭合 `28px` 载体根部
  共同挂在详情 ScrollChild，随内容滚动并由真实 viewport 裁切；Tracker 顶部
  QS-A1 仍为 `34px` 无鼠标 Texture。七纹章未验收，事务菜单保持 inactive，
  旧七按钮继续可见可用。Tracker 顶缘 clamp 增加 `18px`。QL-B2 三态
  选择书签资产保留但 runtime 隐藏；QL-B0 V2 内框、地区条与任务条底板路线
  均已撤销。pfQuest tracker 使用临时大纸面 runtime，保留 provider 的全部
  动态内容与交互；当前因展示区域失败等待无边界 direct-paper 方向确认。
- Unit Frames 接管 `UF.BAR.HEALTH.FILL`、`UF.BAR.POWER.FILL`，作用于 Player、
  Target、TargetTarget、Focus 与 Raid；另只为 `pfRaid1..40` 接管
  `UF.RAID.MEMBER.SHELL.A-D`，并以 `UF.PORTRAIT.DISABLE` 关闭全部 13 组 pfUI
  UnitFrame 与两套 Raid Marker tracker 头像。Frame 构造、颜色、数值、裁切、
  事件、点击和所有未登记对象继续由 pfUI 提供；模块禁用时恢复原头像配置与
  provider 布局，Raid 高度失配时局部回退。
- pfUI 默认所有权：动作条、导航、单位／团队、战斗 HUD、背包／拾取、系统
  skin、Game Menu 与 `/pfui` 配置页全部正常加载；Quest Log 之外的 Blizzard
  skin 不再被 AEUI 全局停用。
- 作用域接管：Chat 保留 pfUI `chat` 作为 provider，仅暂时让渡
  `chatcopy`／`whisperproxy`／`bubbles`；Quests 只让渡 `Quest Log` skin。
  Unit Frames 让渡 `unitframes.health-fill`／`unitframes.power-fill`，以及精确的
  `unitframes.raid-shell`／`unitframes.raid-health-fill`／
  `unitframes.raid-power-fill`／`unitframes.dynamic-portraits` component。
  未来模块 A 只能增加模块 A 的精确条目，不得恢复类别式全局回退。
- Chat 视觉例外：pfUI `panel` provider 与配置保持加载，仅隐藏贴附左右聊天框
  的两条信息 Panel；小地图 Panel 与其他 pfUI Panel 功能不受影响。
- 保留行为：自动售卖／修理、任务物品 Tooltip、售价、装备比较、宏、社交、
  Turtle WoW／SuperWoW 兼容。
- 维护工具：Game Menu 的 pfUI Config、`/pfui`、unlock 与 share 恢复 pfUI
  原始绘制与配置行为。

本表不记录逐次生成、审查或失败历史。主模块阶段变化时，同一提交同步本表和
`AGENTS.md` 顶部快照。
