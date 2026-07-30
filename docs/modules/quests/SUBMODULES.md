# Quests 子模块定义

本文件是任务模块唯一的真实对象合同，严格对齐当前仓库内 pfUI 与原生
Frame。美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见
[PROGRESS.md](PROGRESS.md)。

## 来源与所有权

| 来源 | 已证实职责 | 项目边界 |
|---|---|---|
| [`skins/blizzard/questlog.lua`](../../../addon/pfUI/skins/blizzard/questlog.lua) | `QuestLogFrame` 双栏几何、列表／详情 ScrollFrame、日志按钮、奖励槽、pfUI 等级与详情收起增强 | 保留原生数据与事件；新 adapter 不加载现代 backdrop |
| [`Modules/Quests.lua`](../../../addon/AzerothExpeditionUI/Modules/Quests.lua) | QL-A2 V4 固定 SHELL、阅读安全区、原生装饰隐藏与真实详情切换 Button | 只接管静态外壳和布局；不替代任务数据、原按钮脚本、动态内容或 SavedVariables |
| [`skins/blizzard/gossipquest.lua`](../../../addon/pfUI/skins/blizzard/gossipquest.lua) | `QuestFrame`、`GossipFrame`、五个内容面板、滚动条、八个操作按钮、奖励高亮 | 当前原生回退；只保留对象合同 |
| [`modules/questitem.lua`](../../../addon/pfUI/modules/questitem.lua) | 任务物品 Tooltip 的任务归属、扫描与数量 | 原样保留；不是快捷使用按钮 |
| 外部任务追踪插件 | 游戏页面任务追踪 | provider 未提供，禁止假设 `QuestWatchFrame` |

当前资产波次只包含按 `L` 打开的 `QuestLogFrame`。NPC 对话和外部 tracker
没有获准生产资产。

## Quest Log 顶层

| ID | 真实对象 | 状态／资产合同 |
|---|---|---|
| `QUEST.LOG.SHELL` | `QuestLogFrame` | `676 × 464` 固定非交互空卷宗背景；不拉伸，不包含任何动态内容或交互状态 |
| `QUEST.LOG.TITLE` | `QuestLogTitleText` | layout-only 动态文字 |
| `QUEST.LOG.COUNT` | `QuestLogQuestCount`；兼容 `QuestLogCount` | layout-only，可有独立小墨印分隔 |
| `QUEST.LOG.CLOSE` | `QuestLogFrameCloseButton` | 普通／悬停／按下／禁用 |
| `QUEST.LOG.EMPTY` | `EmptyQuestLogFrame`、`QuestLogNoQuestsText` | 安静纸面，不生成空状态卡片 |

支持 `closed`、`empty`、`list-only`、`dual-page` 与 `selected`。离线参考为
`676 × 464 UI px`，物理中心线 `x=338`；左右物理纸页近 1:1，可见宽度差
不超过约 `1%`。左 `42%`／右 `58%` 只属于文字列，不改变纸页宽度。
`list-only` 只隐藏右页动态内容，完整书体保持 `676 × 464`，不得缩成
`340px` 半本书。

## Quest Log 纸页与中央装订

`QUEST.LOG.SPINE` 只作为父级兼容名，不能绑定一张外置封脊。

QL-A2 V4 将下列固定、无交互结构收敛为 `QUEST.LOG.SHELL` 的静态子区域。
这些逻辑 ID 继续用于安全区、层序和 provenance，不再分别对应可加载 Texture。

| ID | 运行时层／对象 | V4 资产所有权 |
|---|---|---|
| `QUEST.LOG.LIST.PAPER` | `QuestLogListScrollFrame` 的左页阅读安全区 | 使用 SHELL 已接受左纸页；无独立位图 |
| `QUEST.LOG.DETAIL.PAPER` | `QuestLogDetailScrollFrame` 的右页阅读安全区 | 使用 SHELL 已接受右纸页；无独立位图 |
| `QUEST.LOG.GUTTER.UNDERLAY` | SHELL 中央凹陷子区域 | 无独立 Texture |
| `QUEST.LOG.GUTTER.LEFT_FOLD` | SHELL 左纸页既有内缘 | 无独立 Texture |
| `QUEST.LOG.GUTTER.RIGHT_FOLD` | SHELL 右纸页既有内缘 | 无独立 Texture |
| `QUEST.LOG.GUTTER.STITCH` | SHELL 中央既有离散装订回路 | 固定尺寸，不重复、不拉伸 |
| `QUEST.LOG.GUTTER.TOP` | 装订在顶部页叠下自然结束 | 无外露装饰结、无独立资产 |
| `QUEST.LOG.GUTTER.BOTTOM` | 装订在底部页叠下自然结束 | 无外露装饰结、无独立资产 |

固定层序：`QUEST.LOG.SHELL` 静态背景 → 列表／详情／奖励与全部真实 Button、
Texture、FontString。禁止在 SHELL 上烘焙任务行、滚动状态、选择状态、
奖励槽、操作按钮、页码、书签或动态文字。

## Quest Log 左页目录

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.REGION.TOGGLE` | `QuestLogTitleN` 且 `isHeader=true` 的图标区 | 展开／收起覆盖，不新增命中区 |
| `QUEST.LOG.LIST.ROW` | `QuestLogTitle1..23`；`7..23` 继承 `QuestLogTitleButtonTemplate` 创建 | 普通／悬停／按下／禁用；layout／字体状态，不生成完整行卡片 |
| `QUEST.LOG.LIST.CHECK` | `QuestLogTitleNCheck` | 未追踪／已追踪；不是选择 Button |
| `QUEST.LOG.SELECTION` | 当前选中的非地区 `QuestLogTitleN` | 一枚基础织物书签；选中／选中悬停／选中按下为三个确定性 runtime 状态 |
| `QUEST.LOG.TYPE.BADGE` | `GetQuestLogTitle` 的可靠 `questTag` | `normal` 无资产；Elite／Dungeon／Raid／PvP 小压印；未知 tag 不猜测 |
| `QUEST.LOG.TIMER.BADGE` | `GetQuestTimers()` 与 `GetQuestIndexForTimer()` | timed 沙漏压印；API 缺失时不显示 |
| `QUEST.LOG.STATE.SEAL` | `GetQuestLogTitle` 的 `isComplete` | `+1` complete／`-1` failed；nil 不显示 |

整条 `QuestLogTitleN` 才是选择命中对象。名称、等级、任务数量与勾选均动态
绘制。地区展开状态来自同一条目的 `isHeader`／`isCollapsed`；追踪状态来自
绝对任务索引的 `IsQuestWatched`；选择状态来自 `GetQuestLogSelection()`。
不得通过解析本地化任务名或显示文字推断状态。

`QUEST.LOG.SELECTION` 不拥有鼠标：任何时刻最多只显示在一条可见、非地区的
当前任务行。它使用 `24 × 14 UI px` 可见书签装在 `32 × 16 UI px` 透明
Texture 内，从行局部 `x=-8..15` 探入；任务文字从 `x>=18` 开始。覆盖位于
shell 之上、任务 FontString 与 QL-B1／B3 状态之下。无选择、选择不可见、
API／媒体缺失或选择指向地区 header 时隐藏并保留原生选择反馈。

pfUI 的功能合同保留 `QUESTS_DISPLAYED = 23`，而 QL-A2 左页安全区只有
`246 × 324 UI px`。QL-B0 的离线目标几何为 `23` 条
`224 × 15 UI px` 行、`14px` 纵向步进，总占高 `323px`；右侧 `22px`
预留给滚动条和间距。它只压缩视觉行距，不减少可见行数、不替换原生脚本，
并必须在 Turtle WoW 中验证文字基线、重叠命中和滚动偏移。

QL-B 的生产边界：

- `QL-B1`：`REGION.TOGGLE` 与 `LIST.CHECK` 四枚墨记；V1.r3 透明 source
  已接受。runtime 只允许按 manifest 固定四格裁切、等比缩放并居中，
  不得修改任务行交互或状态来源。
- `QL-B2`：`SELECTION` 只生成一枚暗酒红织物基础书签；selected／
  selected-hover／selected-pressed 由同一 Alpha 确定性导出为三格，
  pressed 只在原行 Button 上产生 `1 UI px` 视觉压入，不新增命中区。
  用户已接受 QL-B2 V1.r4 的 bbox-fit source 合同例外；固定 source 为
  [`QuestLogSelectionBookmark_Master_v1.png`](../../../assets/source/quests/ql-b2/QuestLogSelectionBookmark_Master_v1.png)，
  SHA-256
  `4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa`。
  该例外只允许把第五次候选的可见 Alpha bbox 单次等比缩入中心安全盒、
  固定清理低 Alpha 绿色边缘并清零全透明 RGB；不允许重画、拉伸、旋转、
  镜像或改变物件身份。P5 runtime 为
  `QuestLogSelectionBookmarkV1.tga`：`128 × 16`、四个
  `32 × 16` cell，顺序为 selected／selected-hover／
  selected-pressed／全透明保留格；每格可见 content 为 `24 × 14`，
  三态 Alpha 逐像素相同。
- `QL-B3`：四类可靠 `TYPE.BADGE`、独立 `TIMER.BADGE` 与两类
  `STATE.SEAL`。
- `LIST.ROW` 自身只承担布局、字体色和真实点击，不持有位图行卡。

QL-B0／B1／B2 runtime 已接入
`addon/AzerothExpeditionUI/Modules/Quests.lua`：atlas 为
`QuestLogDirectoryMarksV1.tga`，四个 `16 × 16` cell 的内部 content box
分别以 `12 × 12` 箭头和 `10 × 10` 墨圈显示。覆盖 Texture 不接收鼠标；
原 `QuestLogTitleN` Button、脚本、滚动、选择和追踪数据均保持。字体仅按
模块基线把主标题设为 Noto Serif SC、任务行设为霞鹜文楷，仍需实机加载
与 1px 行重叠命中验证。QL-B2 另以 `BORDER` Texture 挂载完整
`32 × 16` atlas cell，锚点 `x=-12`；hover／pressed 只在保留原脚本后
刷新 UV，pressed 仅把锚点改为 `y=-1`。API 缺失、无可见选择或 header
被选中时隐藏覆盖。

## Quest Log 滚动与控制

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.LIST.SCROLL.TRACK` | `QuestLogListScrollFrameScrollBar` 轨道 | 上端／可平铺中段／下端 |
| `QUEST.LOG.LIST.SCROLL.THUMB` | 对应 ThumbTexture | 普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.SCROLL.UP` | 对应 ScrollUpButton，需 feature-detect | 四状态 Button |
| `QUEST.LOG.LIST.SCROLL.DOWN` | 对应 ScrollDownButton，需 feature-detect | 四状态 Button |
| `QUEST.LOG.COLLAPSE.ALL` | `QuestLogCollapseAllButton` | 独立 Button；展开／收起方向与普通／悬停／按下／禁用状态均需保留 |

## Quest Log 右页与操作

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.DETAIL.SCROLL.TRACK` | `QuestLogDetailScrollFrameScrollBar` 轨道 | 上／中／下 |
| `QUEST.LOG.DETAIL.SCROLL.THUMB` | 对应 ThumbTexture | 四状态 |
| `QUEST.LOG.DETAIL.SCROLL.UP` | 对应 ScrollUpButton，需 feature-detect | 四状态 |
| `QUEST.LOG.DETAIL.SCROLL.DOWN` | 对应 ScrollDownButton，需 feature-detect | 四状态 |
| `QUEST.LOG.DETAIL.TITLE` | ScrollChild 标题 FontString，需实机确认名 | layout-only |
| `QUEST.LOG.DETAIL.DESCRIPTION` | 叙述 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.OBJECTIVES` | 目标 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.REWARD_TEXT` | 奖励文字 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.DIVIDER` | adapter 非交互 Texture | 可横向三段式短墨线 |
| `QUEST.LOG.REWARD.SLOT` | `QuestLogItem1..MAX_NUM_ITEMS` | 普通／悬停／按下／禁用；图标动态，无 selected |
| `QUEST.LOG.TRACK` | `QuestLogTrack`、`QuestLogTrackTracking` | 未追踪／已追踪／禁用 |
| `QUEST.LOG.ACTION.ABANDON` | `QuestLogFrameAbandonButton` | 四状态，文字动态 |
| `QUEST.LOG.ACTION.SHARE` | `QuestFramePushQuestButton`；兼容名需探测 | 四状态 |
| `QUEST.LOG.ACTION.EXIT` | `QuestFrameExitButton`；兼容 `QuestLogFrameCancelButton` | 四状态 |
| `QUEST.LOG.DETAIL.TOGGLE` | pfUI `QuestLogFrameExpandButton`；可选重建 | 左／右，各四状态 |
| `QUEST.LOG.LEVELS` | pfUI `QuestLogFrameLevelsCheckButton`；可选重建 | 未选／已选／悬停／禁用 |

## 外部 Quest Tracker（暂停）

以下 ID 只是已锁定视觉的未来逻辑，不证明 provider 已存在：

`QUEST.TRACKER.HEADER`、`QUEST.TRACKER.EMBLEM`、`QUEST.TRACKER.PAPER`、
`QUEST.TRACKER.BOTTOM`、`QUEST.TRACKER.COLLAPSE`、
`QUEST.TRACKER.ENTRY`、`QUEST.TRACKER.OBJECTIVE`、
`QUEST.TRACKER.FOCUS`、`QUEST.TRACKER.SEAL`、`QUEST.TRACKER.TIMER`。

恢复前必须取得插件名称、版本、加载顺序、SavedVariables、顶层 Frame、任务
组、目标行、标题、计时器、点击对象、刷新入口、状态来源、拖动／缩放／收起
能力和真实几何。此前对 `QuestWatchFrame`、`QuestWatchLineN`、
`QuestWatch_Update` 与 `QuestTimerFrame` 的假设全部作废。

## NPC Quest／Gossip（已映射，未锁美术）

外壳与标题：

| ID | 原生对象 |
|---|---|
| `QUEST.DIALOG.QUEST.SHELL`／`QUEST.DIALOG.GOSSIP.SHELL` | `QuestFrame`／`GossipFrame` |
| `QUEST.DIALOG.QUEST.PORTRAIT`／`QUEST.DIALOG.GOSSIP.PORTRAIT` | `QuestFramePortrait`／`GossipFramePortrait` |
| `QUEST.DIALOG.QUEST.NPC_NAME`／`QUEST.DIALOG.GOSSIP.NPC_NAME` | 对应 `NpcNameText` |
| `QUEST.DIALOG.QUEST.CLOSE`／`QUEST.DIALOG.GOSSIP.CLOSE` | 对应 CloseButton |

五个内容面板：

`QUEST.DIALOG.QUEST.GREETING.PANEL`、`QUEST.DIALOG.GOSSIP.GREETING.PANEL`、
`QUEST.DIALOG.QUEST.DETAIL.PANEL`、`QUEST.DIALOG.QUEST.PROGRESS.PANEL`、
`QUEST.DIALOG.QUEST.REWARD.PANEL`，
分别绑定 `QuestGreetingScrollFrame`、`GossipGreetingScrollFrame`、
`QuestDetailScrollFrame`、`QuestProgressScrollFrame`、
`QuestRewardScrollFrame`。

每个面板都保留四个独立逻辑绑定；下列 ID 均为完整稳定 ID，不得把一行
合并成单张滚动条图片：

| 面板 | 轨道 | 滑块 | 向上 | 向下 |
|---|---|---|---|---|
| Quest Greeting | `QUEST.DIALOG.QUEST.GREETING.SCROLL.TRACK` | `QUEST.DIALOG.QUEST.GREETING.SCROLL.THUMB` | `QUEST.DIALOG.QUEST.GREETING.SCROLL.UP` | `QUEST.DIALOG.QUEST.GREETING.SCROLL.DOWN` |
| Gossip Greeting | `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.TRACK` | `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.THUMB` | `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.UP` | `QUEST.DIALOG.GOSSIP.GREETING.SCROLL.DOWN` |
| Quest Detail | `QUEST.DIALOG.QUEST.DETAIL.SCROLL.TRACK` | `QUEST.DIALOG.QUEST.DETAIL.SCROLL.THUMB` | `QUEST.DIALOG.QUEST.DETAIL.SCROLL.UP` | `QUEST.DIALOG.QUEST.DETAIL.SCROLL.DOWN` |
| Quest Progress | `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.TRACK` | `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.THUMB` | `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.UP` | `QUEST.DIALOG.QUEST.PROGRESS.SCROLL.DOWN` |
| Quest Reward | `QUEST.DIALOG.QUEST.REWARD.SCROLL.TRACK` | `QUEST.DIALOG.QUEST.REWARD.SCROLL.THUMB` | `QUEST.DIALOG.QUEST.REWARD.SCROLL.UP` | `QUEST.DIALOG.QUEST.REWARD.SCROLL.DOWN` |

Greeting 动态项仅登记
`QUEST.DIALOG.QUEST.GREETING.ENTRY` 与
`QUEST.DIALOG.GOSSIP.GREETING.ENTRY`，均为 `P0 geometry`；不得伪造
任务选框。

八个真实操作 Button：

| ID | 原生 Button |
|---|---|
| `QUEST.DIALOG.ACTION.QUEST_GREETING_GOODBYE` | `QuestFrameGreetingGoodbyeButton` |
| `QUEST.DIALOG.ACTION.GOSSIP_GREETING_GOODBYE` | `GossipFrameGreetingGoodbyeButton` |
| `QUEST.DIALOG.ACTION.DECLINE` | `QuestFrameDeclineButton` |
| `QUEST.DIALOG.ACTION.ACCEPT` | `QuestFrameAcceptButton` |
| `QUEST.DIALOG.ACTION.GOODBYE` | `QuestFrameGoodbyeButton` |
| `QUEST.DIALOG.ACTION.COMPLETE` | `QuestFrameCompleteButton` |
| `QUEST.DIALOG.ACTION.CANCEL` | `QuestFrameCancelButton` |
| `QUEST.DIALOG.ACTION.COMPLETE_QUEST` | `QuestFrameCompleteQuestButton` |

所有按钮均需普通／悬停／按下／禁用，文字由客户端绘制。

物品与奖励：

| ID | 原生对象 | 约束 |
|---|---|---|
| `QUEST.DIALOG.ITEM.PROGRESS` | `QuestProgressItem1..6` | 图标／数量／名称动态 |
| `QUEST.DIALOG.ITEM.DETAIL` | `QuestDetailItem1..6` | 同上 |
| `QUEST.DIALOG.ITEM.REWARD.SLOT` | `QuestRewardItem1..6` | 同上 |
| `QUEST.DIALOG.ITEM.REWARD.SELECTION` | `QuestRewardItemHighlight`，只在 `this.type == "choice"` | 唯一持有 selected 语义 |

## 任务物品行为

- `QUEST.ITEM.TOOLTIP`：pfUI `questitem.lua`，视觉 `N/A`，只做功能回归。
- `QUEST.ITEM.QUICKBUTTON`：当前无可靠对象，`P0` future extension。
