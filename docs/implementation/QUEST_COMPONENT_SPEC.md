# 任务模块组件与资产合同

## 1. 范围与当前门槛

本合同把已锁定的“公会任务卷宗／行军便笺”视觉方向映射到真实游戏对象，
用于下一轮组件级资产生产和 runtime adapter 实现。当前只完成可离线验证的
结构审计，不代表 Turtle WoW `1.18.1` 实机通过。

第一实现波次只包含：

1. 按 `L` 打开的 `QuestLogFrame` 双页任务卷宗。
2. 游戏画面中的原生 `QuestWatchFrame` 行军便笺。

NPC 任务对话、Gossip 和任务物品 Tooltip 已完成对象登记，但不在本轮生成
资产。任务快捷按钮目前没有可靠基础对象，不得假设 pfUI 已经提供。

视觉权威：

- [任务模块视觉规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md)
- [任务详情视觉基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)
- [任务追踪视觉基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png)
- [统一美术方向](../ART_DIRECTION.md)

实现审计来源：

- [pfUI Quest Log skin](../../addon/pfUI/skins/blizzard/questlog.lua)
- [pfUI Gossip and Quest skin](../../addon/pfUI/skins/blizzard/gossipquest.lua)
- [pfUI questitem 行为模块](../../addon/pfUI/modules/questitem.lua)

## 2. 所有权边界

| 职责 | 所有者 | 本项目允许的处理 |
|---|---|---|
| 任务数据、选择、追踪、展开分组、奖励与事件 | 香草／Turtle WoW FrameXML | 保留；只通过现有 API 和安全 Hook 读取状态 |
| pfUI 任务等级显示、双栏布局等 UI 相关增强 | pfUI `questlog.lua` | 可在新 adapter 中按需重建，但不得启用其现代 backdrop |
| 任务物品 Tooltip 扫描与计数 | pfUI `questitem.lua` | 原样保留；不改写扫描、缓存或 Tooltip 行为 |
| 双页卷宗、便笺、按钮与状态覆盖 | `AzerothExpeditionUI` | 新建纯呈现层；缺失对象时局部回退原生 |
| NPC 任务交互和奖励选择 | 原生 `QuestFrame`／`GossipFrame` | 本波次保持原生；以后单独换肤 |
| 第三方任务追踪器 | 对应第三方插件 | 默认不接管；以后以 provider adapter 兼容 |

默认 `native_blizzard_skins = "1"` 时 pfUI 的 `Quest Log` 和
`Gossip and Quest` skin 不加载。新任务模块必须直接检测原生全局对象，不能
以 pfUI skin 已经创建的辅助按钮为前提。

## 3. Quest Log 运行时对象图

### 3.1 顶层与模式

| ID | 运行时对象 | 类型 | 行为所有者 | 需要的视觉资产／状态 |
|---|---|---|---|---|
| `QUEST.LOG.SHELL` | `QuestLogFrame` | Frame | 原生显示、隐藏、层级 | 封皮外壳、页叠、左右纸面、书脊；结构切片 |
| `QUEST.LOG.TITLE` | `QuestLogTitleText` | FontString | 原生文字 | 无烘焙文字；只定义标题安全区和字体 |
| `QUEST.LOG.COUNT` | Vanilla `QuestLogQuestCount`；兼容对象 `QuestLogCount` | FontString／Frame | 原生／客户端 | 无背景卡片；可使用小型墨印分隔 |
| `QUEST.LOG.CLOSE` | `QuestLogFrameCloseButton` | Button | 原生关闭 | 黄铜书扣，普通／悬停／按下／禁用 |
| `QUEST.LOG.EMPTY` | `EmptyQuestLogFrame`、`QuestLogNoQuestsText` | Frame／FontString | 原生空状态 | 仅保留安静纸面，不生成独立空状态卡片 |

必须支持以下模式：

- `closed`：不创建持续可见纹理。
- `empty`：左、右页仍属于同一本卷宗；只显示空状态文字。
- `list-only`：右页详情不可用或被收起时，左页保留完整交互。
- `dual-page`：左页目录和右页详情同时显示，是默认目标模式。
- `selected`：当前任务由页边织物书签与原生选中状态共同表达。

pfUI skin 当前使用 `676 × 440` 双栏布局、`350` 高列表和 `376` 高详情区；
这些值只作为首轮离线几何参考。外层美术允许在不改变点击对象的情况下向上下
各延展约 `8–12 UI px`，最终位置必须由目标客户端 `/fstack` 和截图复核。

### 3.2 左页目录

| ID | 运行时对象 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.LOG.LIST.PAPER` | `QuestLogListScrollFrame` 周围的呈现层 | 左页连续纸面 | 独立九宫格；不能包含任务行 | 普通 |
| `QUEST.LOG.LIST.SCROLL` | `QuestLogListScrollFrameScrollBar` | 列表滚动 | 轨道、滑块、上按钮、下按钮分别制作 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.COLLAPSE.ALL` | `QuestLogCollapseAllButton` | 展开／收起全部地区 | 独立页角／墨箭头按钮 | 展开／收起；各有普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.ROW` | `QuestLogTitle1..QUESTS_DISPLAYED` | 地区标题或任务条目点击 | 不生成完整行卡片；仅状态覆盖层 | 普通／悬停／选中／禁用 |
| `QUEST.LOG.LIST.CHECK` | `QuestLogTitleNCheck` | 已追踪标记 | 小型墨勾／书签孔位 | 未追踪／已追踪 |
| `QUEST.LOG.SELECTION` | 绑定当前 `QuestLogTitleN` | 当前任务指示 | 独立暗酒红织物书签 | 普通／悬停／选中 |
| `QUEST.LOG.TYPE.BADGE` | `GetQuestLogTitle` 可可靠返回的任务 tag | 精英、地下城、团队等类型 | 一枚一对象的压印徽记图集 | normal／elite／dungeon／raid／timed |
| `QUEST.LOG.STATE.SEAL` | 行状态覆盖 | 完成／失败 | 完成蜡封、破裂蜡封分别制作 | complete／failed |

地区标题和任务条目共用 `QuestLogTitleN`，必须在更新后读取 `isHeader` 决定
排版。任何美术都不能把固定数量的任务名称、等级、计数或复选标记烘焙进纸面。

### 3.3 右页详情与奖励

| ID | 运行时对象 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.LOG.DETAIL.PAPER` | `QuestLogDetailScrollFrame` | 右页连续正文纸面 | 独立九宫格；标题、正文和奖励均为 runtime | 普通 |
| `QUEST.LOG.DETAIL.SCROLL` | `QuestLogDetailScrollFrameScrollBar` | 正文滚动 | 轨道、滑块、上按钮、下按钮分别制作 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.DETAIL.DIVIDER` | adapter 创建的非交互 Texture | 叙事、目标、奖励分区 | 短墨线，可横向三段式拉伸 | 普通 |
| `QUEST.LOG.REWARD.SLOT` | `QuestLogItem1..MAX_NUM_ITEMS` 及其 Icon／Count／Name | 奖励物品 | 槽底、悬停、选择框分别制作；物品图标保持动态 | 普通／悬停／选中／禁用 |
| `QUEST.LOG.TRACK` | `QuestLogTrack`、`QuestLogTrackTracking` | 追踪／取消追踪 | 独立墨圈与羽毛笔勾记 | 未追踪／已追踪／禁用 |

任务标题、来源、正文、目标、奖励名称、数量和金币全部由客户端绘制。生产资产
不得出现伪文字、固定物品图标或固定奖励数量。

### 3.4 底部操作

| ID | 首选对象 | 兼容／辅助对象 | 资产 | 状态 |
|---|---|---|---|---|
| `QUEST.LOG.ACTION.ABANDON` | `QuestLogFrameAbandonButton` | 无 | 共用厚皮革操作按钮；文字 runtime | 普通／悬停／按下／禁用 |
| `QUEST.LOG.ACTION.SHARE` | `QuestFramePushQuestButton` | 客户端可能使用其他全局名，必须 feature-detect | 同上 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.ACTION.EXIT` | `QuestFrameExitButton` 或原生关闭操作按钮 | `QuestLogFrameCancelButton` | 同上 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.DETAIL.TOGGLE` | pfUI skin 才创建的 `QuestLogFrameExpandButton` | adapter 可选择重建 | 独立折页按钮 | 左／右；各有普通／悬停／按下／禁用 |
| `QUEST.LOG.LEVELS` | pfUI skin 才创建的 `QuestLogFrameLevelsCheckButton` | adapter 可选择重建 | 小型墨勾复选框 | 未选／已选／悬停／禁用 |

`DETAIL.TOGGLE` 和 `LEVELS` 属于 UI 相关增强，不是首轮运行的硬依赖。若目标
客户端对象或对应配置不存在，整个任务日志仍必须正常打开和交互。

## 4. Quest Tracker 运行时对象图

### 4.1 Provider 策略

第一 provider 是香草 `QuestWatchFrame`：

- 顶层：`QuestWatchFrame`
- 动态文字：`QuestWatchLine1..MAX_QUESTWATCH_LINES`
- 更新入口：`QuestWatch_Update`
- 数据入口：`GetNumQuestWatches`、`GetQuestIndexForWatch`、
  `GetNumQuestLeaderBoards`、`GetQuestLogLeaderBoard`

这些对象在 Turtle WoW `1.18.1` 上仍需实机确认，因此 adapter 必须逐项
feature-detect。找不到 `QuestWatchFrame` 时只跳过 tracker 皮肤，不阻止
Quest Log 或插件其他模块加载。

第三方任务插件不得通过字符串猜测强制接管。以后每个 provider 必须单独登记
顶层 Frame、行对象、更新事件、所有权和降级路径。

### 4.2 结构与内容

| ID | 运行时对象 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.TRACKER.HEADER` | adapter 呈现层，锚定 `QuestWatchFrame` | 顶部皮带、双铆钉 | 三段式横向结构 | 普通 |
| `QUEST.TRACKER.EMBLEM` | adapter Texture | 羽毛笔与指南针徽记 | 独立透明装饰，不接收点击 | 普通 |
| `QUEST.TRACKER.PAPER` | adapter 呈现层 | 可纵向扩展正文纸面 | 中段可平铺，左右叠页边独立 | 普通／战斗收紧 |
| `QUEST.TRACKER.BOTTOM` | adapter 呈现层 | 自然撕裂底边 | 独立三段式；不得纵向拉伸 | 普通 |
| `QUEST.TRACKER.COLLAPSE` | adapter 可选 Button | 收起／展开 | 独立皮革拉环 | 展开／收起；普通／悬停／按下／禁用 |
| `QUEST.TRACKER.ENTRY` | 一组 `QuestWatchLineN` | 任务标题和目标文字 | 无条目背景卡片；动态排版 | normal／focus／complete／failed／timed |
| `QUEST.TRACKER.OBJECTIVE` | 对应目标行 | 目标进度 | 空心墨圈、羽毛笔勾记分别制作 | incomplete／complete |
| `QUEST.TRACKER.FOCUS` | adapter Texture | 当前重点任务 | 小型暗酒红页边织物标记 | hidden／shown |
| `QUEST.TRACKER.SEAL` | adapter Texture | 整项完成／失败 | 小蜡封与破裂蜡封分别制作 | complete／failed |
| `QUEST.TRACKER.TIMER` | 任务时间数据；具体 `QuestTimerFrame` 待实测 | 限时状态 | 沙漏压印 | normal／warning |

追踪器的纸面高度必须由实际可见文字总高度驱动：

- 顶部和底部保持固定尺寸。
- 中段仅在内容增加时纵向平铺。
- 没有追踪任务时隐藏整个便笺，不显示空纸。
- 多个任务共享连续纸面，不能给每项任务创建独立卡片。
- 第一实现波次不改变原生行点击能力；若原生行只是 FontString，不额外伪造
  点击行为。

## 5. NPC 对话与任务物品的登记边界

| ID | 对象 | 当前处理 |
|---|---|---|
| `QUEST.DIALOG.FRAME` | `QuestFrame`、`GossipFrame` | 保持原生，后续单独建立“NPC 委托文书”组件合同 |
| `QUEST.DIALOG.PANELS` | Greeting／Detail／Progress／Reward panels 与 ScrollFrames | 保持原生 |
| `QUEST.DIALOG.ACTIONS` | Accept／Decline／Complete／Goodbye／Cancel buttons | 保持原生 |
| `QUEST.DIALOG.REWARD` | `QuestProgressItemN`、`QuestDetailItemN`、`QuestRewardItemN` | 保持原生 |
| `QUEST.ITEM.TOOLTIP` | pfUI `questitem.lua` | `N/A` 视觉；保留任务名称与数量扫描行为 |
| `QUEST.ITEM.QUICKBUTTON` | 当前无可靠基础对象 | `P0` future extension；不得归因给 `questitem.lua` |

## 6. 资产包与执行批次

任何批次只能生成下面列出的逻辑对象。禁止生成整张带按钮、任务文字和奖励
图标的完成界面。

| 批次 | 组件 | 输出责任 |
|---|---|---|
| `QL-A` | `SHELL`、`LIST.PAPER`、`DETAIL.PAPER`、中央书脊、页叠 | 纯结构资源；分离九宫格／三段式部件 |
| `QL-B` | `LIST.ROW`、`SELECTION`、`TYPE.BADGE`、`STATE.SEAL` | 目录状态覆盖与任务徽记 |
| `QL-C` | 两套 ScrollBar、`CLOSE`、操作按钮、`TRACK`、`DETAIL.TOGGLE`、`LEVELS` | 每个交互对象的完整状态画布 |
| `QL-D` | `REWARD.SLOT`、`DETAIL.DIVIDER` | 奖励槽和非交互墨线 |
| `QT-A` | `HEADER`、`PAPER`、左右叠页边、`BOTTOM`、`EMBLEM` | 可动态伸缩的追踪器结构 |
| `QT-B` | `COLLAPSE`、`OBJECTIVE`、`FOCUS`、`SEAL`、`TIMER` | 追踪器交互与状态覆盖 |

对应 production draft：

- [任务详情组件资产生产提示词 V2](../../prompts/quests/任务详情组件资产_生产提示词_v2.md)
- [任务追踪组件资产生产提示词 V2](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md)

## 7. Runtime 实现顺序

1. 在目标客户端记录所有对象是否存在、原始尺寸、锚点、层级和 provider。
2. 先接入 `QUEST.LOG.SHELL`，只改变呈现，不修改事件与数据。
3. 接入左右 ScrollBar 和真实 Button 状态，确认点击区没有改变。
4. 接入任务行状态覆盖、追踪标记和奖励槽。
5. 对 `QuestWatchFrame` 建立局部 adapter；以可见文字高度驱动便笺伸缩。
6. 最后评估是否重建 pfUI 的等级显示与详情收起增强。
7. NPC 对话与第三方 tracker 在各自合同完成前继续使用原生回退。

## 8. 实机验收清单

- `L` 打开、关闭、拖动和 ESC 行为不变。
- 地区展开／收起、任务选择、追踪、分享、放弃和滚动都能点击。
- 空日志、满日志、长中文标题、长正文和多奖励不会越过安全区。
- 右页隐藏或对象缺失时仍可使用左页。
- 没有追踪任务时 `QuestWatchFrame` 不留下空纸。
- 一项、多项、完成、失败和限时任务能正确改变便笺高度与状态。
- UI Scale 改变后文字与纸面仍对齐。
- 禁用 `AzerothExpeditionUI` 后恢复原生任务界面；pfUI 非视觉功能不变。
- 出现第三方任务插件时宁可局部跳过，也不重复显示两个追踪面板。
