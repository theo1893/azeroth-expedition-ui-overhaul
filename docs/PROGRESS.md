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
| `P6-C` | 最终产物保留，模块 `work/` 与中间产物已清理 |

## 当前模块

| 主模块 | pfUI／原生边界 | 阶段 | 当前结论 | 下一门禁 |
|---|---|---:|---|---|
| Core／pfUI | `api/expedition.lua`、`pfUI.lua`、作用域接管路由 | `P5` | pfUI `8.1.0-aeui.4` 已恢复公共绘制、原始默认值、全部未接管模块／skins 与配置入口；仅 Chat 辅助模块和 Quest Log skin 显式让渡；旧全局回退 SavedVariables 一次迁移 | 实机覆盖 Game Menu／`/pfui`、全模块加载、旧 SavedVariables、单模块失败隔离与第三方兼容 |
| Chat | `modules/chat.lua` + AEUI Chat adapter | 核心 `P5` / r1.21 | Full V1 主框九宫格、右框回收、V3 Tab／未读保持；`CHAT.INPUT.DARK.V1.r3 attempt 4` 已从固定 source 确定性导出为 `ChatInputDarkV1.tga`，normal／focus 共同 Alpha、三段 UV、`380/480 × 25px` 真实排版和五场景 display-region 均通过。v1.21 移除 AEUI 基础／内嵌颜色重写及 pfUI／ChatMOD 输出 wrapper，恢复客户端与 provider 的经典配色；EditBox 行为不变，旧 V3 输入保留为回退 | 游戏设备可用时 `/reload` 验证 `chat-runtime=1.21`、`chat-color=classic-provider`、书框、输入交互、经典频道／职业／物品／插件色、Tab、缩放与右框消息回收 |
| Quests | `questlog.lua`、`gossipquest.lua`、`questitem.lua`、`pfQuest`／`pfQuest-turtle` + AEUI Quests adapter | `P1–P5` | Quest Log 主体保持 QL-A2 V4；Quests `1.17`／Theme `1.6` 将 18 行任务文字恢复为 `pfUI.font_default` 的 `12px OUTLINE`，并按最底动态对象重算右页 ScrollChild；奖励双列槽收敛为 `108px`／名称 `64px`。旧悬空锚点、V1 书框皮签与 V2 硬质二段封签均不再作为方向；V3 单张书页夹层火漆封签＋连续七项事务签处于 `P2 simulation-reviewed`，未接入也未隐藏原 Button。pfQuest tracker 临时纸面仍 `display-region-blocked` | 用户先确认／退回 `QUEST-LOG-SEAL-ACTIONS-SIM-V3`；实机再验证字体字重、长正文与 0／1／2／4／6 奖励、pfQuest 后加载、滚动范围和原按钮 fail-open |
| Map | `map.lua`、`minimap.lua`、`addonbuttons.lua` 等 | `P2` | 羊皮地图卷与黄铜罗盘已锁定 | 实机对象审计和组件级合同 |
| Character | `character.lua`、`inspect.lua`、`dressup.lua` | `P2` | 香草同构角色面板已锁定 | 实机几何与装备槽／属性／页签拆分 |

## 尚未启动长期模块包

这些模块继续使用 pfUI 默认实现与呈现。启动其中任一模块时，先建立
`SUBMODULES.md`、`ART_BASELINE.md`、`SUBMODULE_ART_BASELINES.md` 和
`PROGRESS.md`，再只为目标模块登记接管路由并进入资产生产。

| 计划模块 | pfUI 入口 | 当前阶段 | 方向／下一步 |
|---|---|---:|---|
| Action Bars | `actionbar.lua`、`gryphons.lua`、`pet.lua`、`hunterbar.lua` | `P1` | 保留双头狮鹫与经典技能格，先测真实按钮状态 |
| Unit／Party／Raid | `player.lua`、`target.lua`、`group.lua`、`raid.lua` 等 | `P1` | 从香草头像框开始，团队以可读性优先 |
| Combat HUD | `castbar.lua`、`buff*.lua`、`nameplates.lua`、计时模块 | `P1` | 分开状态条、端帽、图标槽与警告 |
| DPS／Threat | pfUI 无完整 meter | `P0` | 先确定数据源与 Turtle WoW API |
| Consumables | `buff.lua`、`cooldown.lua` 可复用 | `P0` | 先确定消耗品数据模型与阈值 |
| Bags／Loot／Roll | `bags.lua`、`loot.lua`、`roll.lua` | `P1` | 物品槽与需求／贪婪／放弃按钮分别拆分 |
| Spell／Talent／Profession | 对应 Blizzard skins | `P1` | 保留香草书本／树节点结构，先审计真实对象 |
| Economy | `merchant.lua`、`auction.lua`、`mail.lua`、`trade.lua` | `P1` | 列表、金币、附件与不可逆操作优先 |
| Social | `friends.lua`、`socialmod.lua`、`lfg.lua`、`lft.lua` | `P1` | 复用高密度列表组件 |
| System | `tooltip.lua`、`gui.lua`、`popup_dialogs.lua`、其余 skins | `P1` | 先建立公共按钮、Tab、滚动条与 Tooltip |

## 当前运行时路由

- 项目接管：pfUI `chat` 行为与 AEUI V3 单一左侧战地旧书视觉；AEUI
  QL-A2 V4 任务日志固定书体与安全区、QL-B0 18 行可读目录、QL-B1
  地区箭头，以及 Quests `1.17`（QL-C 子合同 `1.7`）的 pfQuest 后加载
  布局兼容。QS-A1 共用漆章仍以 Quest Log `28px`、Tracker `34px` 无鼠标
  Texture 接入，但 Quest Log 旧悬空位置已标为待替换；新侧边承载／事务菜单
  只完成本地模拟。Tracker 顶缘 clamp 增加 `18px`，旧七按钮继续可见可用。QL-B2 三态
  选择书签资产保留但 runtime 隐藏；QL-B0 V2 内框、地区条与任务条底板路线
  均已撤销。pfQuest tracker 使用临时大纸面 runtime，保留 provider 的全部
  动态内容与交互；当前因展示区域失败等待无边界 direct-paper 方向确认。
- pfUI 默认所有权：动作条、导航、单位／团队、战斗 HUD、背包／拾取、系统
  skin、Game Menu 与 `/pfui` 配置页全部正常加载；Quest Log 之外的 Blizzard
  skin 不再被 AEUI 全局停用。
- 作用域接管：Chat 保留 pfUI `chat` 作为 provider，仅暂时让渡
  `chatcopy`／`whisperproxy`／`bubbles`；Quests 只让渡 `Quest Log` skin。
  未来模块 A 只能增加模块 A 的精确条目，不得恢复类别式全局回退。
- Chat 视觉例外：pfUI `panel` provider 与配置保持加载，仅隐藏贴附左右聊天框
  的两条信息 Panel；小地图 Panel 与其他 pfUI Panel 功能不受影响。
- 保留行为：自动售卖／修理、任务物品 Tooltip、售价、装备比较、宏、社交、
  Turtle WoW／SuperWoW 兼容。
- 维护工具：Game Menu 的 pfUI Config、`/pfui`、unlock 与 share 恢复 pfUI
  原始绘制与配置行为。

本表不记录逐次生成、审查或失败历史。主模块阶段变化时，同一提交同步本表和
`AGENTS.md` 顶部快照。
