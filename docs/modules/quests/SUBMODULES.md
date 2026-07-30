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
| `QUEST.LOG.COUNT` | `QuestLogQuestCount`；兼容 `QuestLogCount` | layout-only；使用纸面深墨文字，不新增外框 |
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
| `QUEST.LOG.LIST.INSET` | 无独立 runtime 对象；`QuestLogListScrollFrame` 直接露出 QL-A2 连续纸面 | 用户已移出范围；不得创建内框 Texture、占位、命中或 fallback 分支 |
| `QUEST.LOG.REGION.BACKPLATE` | `QuestLogTitleN` 且 `isHeader=true` 的 Button 背景 Texture | normal／hover／pressed／disabled；同一基础物件确定性派生 |
| `QUEST.LOG.ROW.BACKPLATE` | `QuestLogTitleN` 且 `isHeader=false` 的 Button 背景 Texture | normal／hover／pressed／disabled；同一基础物件确定性派生 |
| `QUEST.LOG.REGION.TOGGLE` | `QuestLogTitleN` 且 `isHeader=true` 的图标区 | 展开／收起覆盖，不新增命中区 |
| `QUEST.LOG.LIST.ROW` | V1 fallback 为 `QuestLogTitle1..23`，其中 `7..23` 继承 `QuestLogTitleButtonTemplate` 创建；V2 活动窗口为 `QuestLogTitle1..18` | 普通／悬停／按下／禁用；保留真实 Button 与脚本；V1 不生成完整行卡片，V2 挂载独立薄型卷宗底板 |
| `QUEST.LOG.LIST.CHECK` | `QuestLogTitleNCheck` | 未追踪／已追踪；不是选择 Button |
| `QUEST.LOG.SELECTION` | 当前选中的非地区 `QuestLogTitleN` | 已接受的三态织物书签资产保留，但按 `2026-07-31` 用户决定暂停挂载并隐藏 |
| `QUEST.LOG.TYPE.BADGE` | `GetQuestLogTitle` 的可靠 `questTag` | `normal` 无资产；Elite／Dungeon／Raid／PvP 小压印；未知 tag 不猜测 |
| `QUEST.LOG.TIMER.BADGE` | `GetQuestTimers()` 与 `GetQuestIndexForTimer()` | timed 沙漏压印；API 缺失时不显示 |
| `QUEST.LOG.STATE.SEAL` | `GetQuestLogTitle` 的 `isComplete` | `+1` complete／`-1` failed；nil 不显示 |

整条 `QuestLogTitleN` 才是选择命中对象。名称、等级、任务数量与勾选均动态
绘制。地区展开状态来自同一条目的 `isHeader`／`isCollapsed`；追踪状态来自
绝对任务索引的 `IsQuestWatched`；选择状态来自 `GetQuestLogSelection()`。
不得通过解析本地化任务名或显示文字推断状态。

`QUEST.LOG.SELECTION` 不拥有鼠标。已接受的 QL-B2 source、runtime atlas、
manifest 与 exporter 继续作为可恢复的历史产物保留，但 `2026-07-31` 起
adapter 不再创建、挂载或刷新酒红色书签，也不再包装任务行的 hover／pressed
脚本。原生整行选择高亮仍保持透明抑制；目录文字继续从 `x>=18` 起，以维持
QL-B1 墨记及未来状态槽的安全区。

当前 P5／V1 fallback 仍保留 pfUI 的 `QUESTS_DISPLAYED = 23`：QL-A2 左页
`246 × 324 UI px` 安全区中使用 `23` 条 `224 × 15 UI px` 行、
`14px` 纵向步进，总占高 `323px`。实机已经证明该密度不足以承载新的大面积
左页视觉。

用户确认的 V2 目标改为 `QUESTS_DISPLAYED = 18`：活动窗口使用
`QuestLogTitle1..18`，每条 `224 × 18 UI px`，纵向步进 `18px`，总占高
`324px`；右侧 `22px` 预留给真实滚动条与间距。现有
`QuestLogTitle19..23` 不删除、不改写脚本，只在 V2 模式隐藏；缺少 adapter
或媒体时回退 V1／pfUI。动态文字从 `x=20` 起；地区使用 Noto Serif SC
SemiBold `12px`，任务使用 LXGW WenKai `11px`。完整资源与排版合同见
[work/QUEST.LOG.LEFTPAGE.md](work/QUEST.LOG.LEFTPAGE.md)。

QL-B 的生产边界：

- `QL-B1`：`REGION.TOGGLE` 与 `LIST.CHECK` 四枚墨记；V1.r3 透明 source
  已接受。runtime 只允许按 manifest 固定四格裁切、等比缩放并居中，
  不得修改任务行交互或状态来源。V2 接受后只允许从同一 source 确定性
  重导出为地区箭头 `14px` 与追踪圈 `12px`，不重新生图。
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
  三态 Alpha 逐像素相同。V2 接受后只允许从同一 source 确定性重导出为
  `32 × 16` cell 内 `30 × 16` 可见书签，锚点 `x=-12`；不重新生图。
  当前 runtime 明确暂停挂载；恢复前必须由用户重新确认，不得因为资产仍在
  仓库中而自动显示。
- `QL-B3`：四类可靠 `TYPE.BADGE`、独立 `TIMER.BADGE` 与两类
  `STATE.SEAL`。非地区行固定保留三个可同时显示的无鼠标状态槽：
  type `10 × 10 UI px`、`x=176..186`；timer `10 × 10 UI px`、
  `x=187..197`；state `12 × 12 UI px`、`x=198..210`。QL-B1
  追踪墨圈继续位于 `x=212..222`；任务文字保持 `x=18` 起点并收敛为
  `155px` 宽，右边界 `x=173`。地区 header 不显示 QL-B3，继续使用
  `190px` 文字宽度。类型、限时和完成状态不得互相覆盖或用优先级丢弃。
  `questTag` 只允许匹配 adapter 中显式登记且经目标客户端证实的等值 token；
  禁止解析任务名、显示文字或做模糊本地化猜测。未知 token、API／媒体缺失
  时只隐藏对应覆盖并保留现有动态 `level+` 回退。
- `LIST.ROW` 自身只承担真实点击、脚本与布局。V2 的地区／任务底板分别由
  `REGION.BACKPLATE`／`ROW.BACKPLATE` 的无鼠标 Texture 承担；它们是薄型
  卷宗条目，不是现代卡片，也不改变 Button 命中区。

QL-B0／B1 当前 V1 runtime 已接入
`addon/AzerothExpeditionUI/Modules/Quests.lua`：atlas 为
`QuestLogDirectoryMarksV1.tga`，四个 `16 × 16` cell 的内部 content box
分别以 `12 × 12` 箭头和 `10 × 10` 墨圈显示。覆盖 Texture 不接收鼠标；
原 `QuestLogTitleN` Button、脚本、滚动、选择和追踪数据均保持。字体仅按
模块基线把主标题设为 Noto Serif SC、任务行设为霞鹜文楷，仍需实机加载
与 1px 行重叠命中验证。QL-B2 的 `BORDER` Texture 挂载与三态脚本已从
runtime contract `1.5` 起移除；资产文件不删除，运行时一律隐藏。当前
runtime contract 已升至 `1.6`，该决定保持不变。

QL-B0 V2 的 `LIST.INSET` 已在四次候选审查后由用户移出范围，不建立 source、
runtime、占位 Texture 或 fallback 分支。`REGION.BACKPLATE` 与
`ROW.BACKPLATE` 在五次候选耗尽后也由用户于 `2026-07-31` 明确移出范围；
不建立 source、runtime、占位 Texture 或新的生成路线。失败候选与合同只在
[work/QUEST.LOG.LEFTPAGE.md](work/QUEST.LOG.LEFTPAGE.md) 保留历史证据。

## Quest Log 滚动与控制

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.LIST.SCROLL.TRACK` | `QuestLogListScrollFrameScrollBar` 轨道 | 上端／可平铺中段／下端 |
| `QUEST.LOG.LIST.SCROLL.THUMB` | 对应 ThumbTexture | 普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.SCROLL.UP` | 对应 ScrollUpButton，需 feature-detect | 四状态 Button |
| `QUEST.LOG.LIST.SCROLL.DOWN` | 对应 ScrollDownButton，需 feature-detect | 四状态 Button |
| `QUEST.LOG.COLLAPSE.ALL` | `QuestLogCollapseAllButton` | runtime `1.6` 起完整隐藏并禁用真实 Button 与 pfUI `+`／`-` 子控件；不保留命中区、不生产替代资产 |

## Quest Log 右页与操作

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.DETAIL.SCROLL.TRACK` | `QuestLogDetailScrollFrameScrollBar` 轨道 | 视觉隐藏且不接收鼠标；不删除真实 ScrollFrame |
| `QUEST.LOG.DETAIL.SCROLL.THUMB` | 对应 ThumbTexture | 视觉隐藏 |
| `QUEST.LOG.DETAIL.SCROLL.UP` | 对应 ScrollUpButton，需 feature-detect | 视觉隐藏且不接收鼠标 |
| `QUEST.LOG.DETAIL.SCROLL.DOWN` | 对应 ScrollDownButton，需 feature-detect | 视觉隐藏且不接收鼠标 |
| `QUEST.LOG.DETAIL.TITLE` | ScrollChild 标题 FontString，需实机确认名 | layout-only |
| `QUEST.LOG.DETAIL.DESCRIPTION` | 叙述 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.OBJECTIVES` | 目标 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.REWARD_TEXT` | 奖励文字 FontString 集 | layout-only |
| `QUEST.LOG.DETAIL.DIVIDER` | adapter 非交互 Texture | 可横向三段式短墨线 |
| `QUEST.LOG.REWARD.SLOT` | `QuestLogItem1..MAX_NUM_ITEMS` | 普通／悬停／按下／禁用；图标动态，无 selected |
| `QUEST.LOG.TRACK` | `QuestLogTrack`、`QuestLogTrackTracking` | 复用 QL-B1 开放墨圈／墨勾 atlas；保留原状态控制 |
| `QUEST.LOG.ACTION.ABANDON` | `QuestLogFrameAbandonButton` | 程序化暗皮革搭扣四状态，文字动态，原脚本不变 |
| `QUEST.LOG.ACTION.SHARE` | `QuestFramePushQuestButton`；兼容名需探测 | 同族程序化暗皮革搭扣四状态，原脚本不变 |
| `QUEST.LOG.ACTION.EXIT` | `QuestFrameExitButton`；兼容 `QuestLogFrameCancelButton` | 同族程序化暗皮革搭扣四状态，原脚本不变 |
| `QUEST.LOG.DETAIL.TOGGLE` | pfUI `QuestLogFrameExpandButton`；缺失时可创建真实 Button | 加入底部暗皮革控件行，动态左右文字，pfUI 箭头贴图隐藏 |
| `QUEST.LOG.LEVELS` | pfUI `QuestLogFrameLevelsCheckButton` | 复用 QL-B1 开放墨圈／墨勾 atlas；保留原脚本与文字 |

右页仍由 `QuestLogDetailScrollFrame` 承担裁切与滚动，adapter 只隐藏最右侧
滚动条 chrome，并在页面本体上追加 `OnMouseWheel`，以 `28 UI px` 步进在
真实 `GetVerticalScrollRange()` 内限位。左页列表滚动条完全不受此规则影响。

## 外部 Quest Tracker（暂停）

以下 ID 只是已锁定视觉的未来逻辑，不证明 provider 已存在：

`QUEST.TRACKER.HEADER`、`QUEST.TRACKER.EMBLEM`、`QUEST.TRACKER.PAPER`、
`QUEST.TRACKER.BOTTOM`、`QUEST.TRACKER.COLLAPSE`、
`QUEST.TRACKER.ENTRY`、`QUEST.TRACKER.OBJECTIVE`、
`QUEST.TRACKER.FOCUS`、`QUEST.TRACKER.SEAL`、`QUEST.TRACKER.TIMER`。

用户于 `2026-07-31` 提供并要求保存当前外部 tracker 的游戏内结构参考：
[01_external_quest_tracker_current_state.png](../../../assets/references/quests/session-2026-07-31/01_external_quest_tracker_current_state.png)。
该图只证明纵向任务／目标层级、等级、完成率、目标计数与多种彩色状态标记的
可见结构，不是美术权威，也不证明任何 Frame 名、事件、数据 API 或插件身份。

同日确认该插件为魔改版 `pfQuest 7.0.1` 与配套
`pfQuest-turtle 7.0.2`，源码已复制到 `addon/pfQuest/` 与
`addon/pfQuest-turtle/`。启用后 Quest Log 任务行会增加等级，右页会出现
额外文字／按钮并破坏 AEUI 现有布局。兼容失败证据为
[02_third_party_quest_plugin_layout_failure.png](../../../assets/references/quests/session-2026-07-31/02_third_party_quest_plugin_layout_failure.png)。
该问题登记为后续 TODO；完成 pfQuest Hook／对象审计前不继续修补几何。

恢复前必须取得插件名称、版本、加载顺序、SavedVariables、顶层 Frame、任务
组、目标行、标题、计时器、点击对象、刷新入口、状态来源、拖动／缩放／收起
能力和真实几何；同时审计它对 `QuestLogFrame`、`QuestLogTitleN`、详情
ScrollChild、按钮与刷新函数的写入／Hook。此前对 `QuestWatchFrame`、
`QuestWatchLineN`、
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
