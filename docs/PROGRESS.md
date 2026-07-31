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
| Core／pfUI | `api/expedition.lua`、`pfUI.lua`、原生回退路由 | `P5` | 现代可见模块默认回退原生；非视觉功能保留；Initialize／Apply 按模块 `pcall` 隔离并单次报告异常 | 实机覆盖原生 Frame、SavedVariables、单模块失败隔离与第三方兼容 |
| Chat | `modules/chat.lua` + AEUI Chat adapter | `P5` V3 / r1.7 | 单一左侧旧书、四状态 Tab、双状态输入与未读已接入；右框隐藏且消息回收；书本九宫格在缺失、隐藏或贴图被剥离时自愈；两项 Copy 辅助功能暂缓 | `/reload` 验证书本主体恢复，再执行核心批次实机验收 |
| Quests | `questlog.lua`、`gossipquest.lua`、`questitem.lua`、`pfQuest`／`pfQuest-turtle` + AEUI Quests adapter | `P1–P5` | Quest Log 主体保持 QL-A2 V4；pfQuest tracker 临时纸面仍为 `display-region-blocked`。QS-A1 V1.r4 已按用户授权完成透明 source、四态 atlas 与 Quest Log／Tracker 无鼠标漆章接入；三种 Tracker 宽度和顶缘 clamp 静态检查通过。旧七按钮继续可见可用 | Turtle WoW 同时启用 pfQuest／pfQuest-turtle，验证两处锚点、TGA 方向、顶缘限位、旧按钮层序／交互与 UI scale |
| Map | `map.lua`、`minimap.lua`、`addonbuttons.lua` 等 | `P2` | 羊皮地图卷与黄铜罗盘已锁定 | 实机对象审计和组件级合同 |
| Character | `character.lua`、`inspect.lua`、`dressup.lua` | `P2` | 香草同构角色面板已锁定 | 实机几何与装备槽／属性／页签拆分 |

## 尚未启动长期模块包

这些模块继续使用香草／Turtle WoW 原生呈现。启动其中任一模块时，先建立
`SUBMODULES.md`、`ART_BASELINE.md`、`SUBMODULE_ART_BASELINES.md` 和
`PROGRESS.md`，再进入资产生产。

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
  QL-A2 V4 任务日志固定书体与安全区、QL-B0 23 行 V1 fallback、QL-B1
  四态目录墨记，以及 Quests `1.9`（QL-C 子合同 `1.7`）的 pfQuest 后加载
  布局兼容。QS-A1 共用漆章以 Quest Log `28px`、Tracker `34px` 无鼠标
  Texture 接入；Tracker 顶缘 clamp 增加 `18px`，旧七按钮继续可见可用。QL-B2 三态
  选择书签资产保留但 runtime 隐藏；QL-B0 V2 内框、地区条与任务条底板路线
  均已撤销。pfQuest tracker 使用临时大纸面 runtime，保留 provider 的全部
  动态内容与交互；当前因展示区域失败等待无边界 direct-paper 方向确认。
- 原生回退：动作条、导航、单位／团队、战斗 HUD、背包／拾取以及全部未完成
  Blizzard skins；Quest Log 尚未完成的目录、滚动条、按钮与奖励状态继续
  使用真实原生控件。
- 保留行为：自动售卖／修理、任务物品 Tooltip、售价、装备比较、宏、社交、
  Turtle WoW／SuperWoW 兼容。
- 维护工具：`/pfui`、unlock、share 使用不透明公共过渡材质。

本表不记录逐次生成、审查或失败历史。主模块阶段变化时，同一提交同步本表和
`AGENTS.md` 顶部快照。
