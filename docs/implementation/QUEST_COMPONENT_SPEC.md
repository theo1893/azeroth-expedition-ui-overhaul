# 任务模块组件与资产合同

## 1. 范围与当前门槛

本合同把已锁定的“公会任务卷宗／行军便笺”视觉方向映射到真实游戏对象，
用于下一轮组件级资产生产和 runtime adapter 实现。当前只完成可离线验证的
结构审计，不代表 Turtle WoW `1.18.1` 实机通过。

当前实现波次只包含：

1. 按 `L` 打开的 `QuestLogFrame` 双页任务卷宗。

游戏画面中的任务追踪由另一个外部插件提供。该插件源码、名称与 provider
对象尚未纳入仓库，所以“行军便笺”只保留锁定视觉和未来逻辑组件 ID，不在
本轮生成资产、创建 Hook 或实现 runtime，也不得把原生 `QuestWatchFrame`
当作替代 provider。

NPC 任务对话、Gossip 和任务物品 Tooltip 已完成对象登记，但不在本轮生成
资产。任务快捷按钮目前没有可靠基础对象，不得假设 pfUI 已经提供。`QL-A1`
空卷宗结构母版已经用户确认并达到 `P4`；透明源母版与来源清单位于
`assets/source/quests/ql-a1/`。该整张母版只作为结构来源，不能直接充当
runtime 背景。

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
| Quest Log 数据、选择、日志内追踪标记、展开分组、奖励与事件 | 香草／Turtle WoW FrameXML | 保留；只通过现有 API 和安全 Hook 读取状态 |
| pfUI 任务等级显示、双栏布局等 UI 相关增强 | pfUI `questlog.lua` | 可在新 adapter 中按需重建，但不得启用其现代 backdrop |
| 任务物品 Tooltip 扫描与计数 | pfUI `questitem.lua` | 原样保留；不改写扫描、缓存或 Tooltip 行为 |
| 双页卷宗、按钮与日志内状态覆盖 | `AzerothExpeditionUI` | 新建纯呈现层；缺失对象时局部回退原生 |
| NPC 任务交互和奖励选择 | 原生 `QuestFrame`／`GossipFrame` | 本波次保持原生；以后单独换肤 |
| 游戏页面任务追踪器 | 对应外部插件 | 当前完全不接管；取得源码与真实对象后再建立 provider adapter |

默认 `native_blizzard_skins = "1"` 时 pfUI 的 `Quest Log` 和
`Gossip and Quest` skin 不加载。新任务模块必须直接检测原生全局对象，不能
以 pfUI skin 已经创建的辅助按钮为前提。

上述直接检测仅适用于 `QuestLogFrame`。追踪器不得扫描或猜测
`QuestWatchFrame`、命名相似的全局对象或屏幕区域来自动接管。

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

## 4. Quest Tracker 未来兼容合同（暂停）

### 4.1 Provider 证据门槛

用户已确认当前游戏页面中的任务追踪来自另一个插件。仓库目前没有该插件源码、
provider 名称、运行时对象树或版本信息，因此本项目当前没有默认 tracker
provider。此前把香草 `QuestWatchFrame` 设为第一 provider 的假设已作废；
下列对象也不能作为本次实现依据：

- `QuestWatchFrame`
- `QuestWatchLine1..MAX_QUESTWATCH_LINES`
- `QuestWatch_Update`
- `QuestTimerFrame`

恢复兼容工作前，必须从外部插件源码和目标客户端同时取得：

1. 插件名称、版本、加载顺序和 SavedVariables 边界。
2. 顶层 Frame、任务组、目标行、标题、计时器与所有可点击对象。
3. 列表刷新入口、事件生命周期、任务状态和排序数据来源。
4. 拖动、锁定、缩放、收起、过滤和战斗态等插件自身能力。
5. 每个可见对象的实际尺寸、锚点、层级、所有权与缺失回退。

在这些证据齐全前，`AzerothExpeditionUI` 不注册 tracker Hook、不改变外部
插件 Frame、不生成追踪器资产。外部插件继续按它自身的原始界面运行。

### 4.2 保留的视觉逻辑组件

下表只记录已锁定视觉方向未来可能需要的逻辑粒度，不声称对应对象已经存在。
实际 provider 可能合并、拆分或不提供其中某些交互；完成对象映射后必须据实
修订，不能为了沿用这张表而伪造功能。

| ID | 未来 provider 证据 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.TRACKER.HEADER` | 外部顶层容器及其可装饰安全区待映射 | 顶部皮带、双铆钉 | 三段式横向结构 | 普通 |
| `QUEST.TRACKER.EMBLEM` | 外部标题区与鼠标命中范围待映射 | 羽毛笔与指南针徽记 | 独立透明装饰，不接收点击 | 普通 |
| `QUEST.TRACKER.PAPER` | 外部内容容器和尺寸更新方式待映射 | 可纵向扩展正文纸面 | 中段可平铺，左右叠页边独立 | 普通／插件可证实的战斗态 |
| `QUEST.TRACKER.BOTTOM` | 外部容器底部锚点待映射 | 自然撕裂底边 | 独立三段式；不得纵向拉伸 | 普通 |
| `QUEST.TRACKER.COLLAPSE` | 外部插件真实 Button 待映射 | 收起／展开 | 仅在插件已有交互时制作独立皮革拉环 | 展开／收起；真实 Button 支持的状态 |
| `QUEST.TRACKER.ENTRY` | 外部任务组／行对象待映射 | 任务标题和目标文字 | 无条目背景卡片；动态排版 | provider 实际可判定状态 |
| `QUEST.TRACKER.OBJECTIVE` | 外部目标行和完成状态待映射 | 目标进度 | 空心墨圈、羽毛笔勾记分别制作 | incomplete／complete |
| `QUEST.TRACKER.FOCUS` | 外部重点任务数据待映射 | 当前重点任务 | 小型暗酒红页边织物标记 | 仅在 provider 有该语义时 |
| `QUEST.TRACKER.SEAL` | 外部完成／失败状态待映射 | 整项完成／失败 | 小蜡封与破裂蜡封分别制作 | provider 实际可判定状态 |
| `QUEST.TRACKER.TIMER` | 外部计时对象与阈值待映射 | 限时状态 | 沙漏压印 | provider 实际可判定状态 |

未来 adapter 若能安全实现，追踪器纸面应由实际可见内容高度驱动：

- 顶部和底部保持固定尺寸。
- 中段仅在内容增加时纵向平铺。
- 没有追踪任务时隐藏整个便笺，不显示空纸。
- 多个任务共享连续纸面，不能给每项任务创建独立卡片。
- 不改变外部插件原有的点击、拖动、折叠或排序能力；若没有稳定点击对象，
  不额外伪造点击行为。

当前这些条目统一为“视觉 `P2`／兼容 `P0`”。对应提示词是暂停的
`deferred-compatibility-draft`，不得执行，也不能创建空壳 runtime。

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

任何获准执行的批次都只能生成下面列出的逻辑对象。禁止生成整张带按钮、
任务文字和奖励图标的完成界面。

| 批次 | 组件 | 输出责任 | 当前状态 |
|---|---|---|---|
| `QL-A` | `SHELL`、`LIST.PAPER`、`DETAIL.PAPER`、中央书脊、页叠 | 纯结构资源；分离九宫格／三段式部件 | `QL-A1` 源母版已确认为 `P4`；`QL-A2` 待单独确认 |
| `QL-B` | `LIST.ROW`、`SELECTION`、`TYPE.BADGE`、`STATE.SEAL` | 目录状态覆盖与任务徽记 | 后续任务详情草案 |
| `QL-C` | 两套 ScrollBar、`CLOSE`、操作按钮、`TRACK`、`DETAIL.TOGGLE`、`LEVELS` | 每个交互对象的完整状态画布 | 后续任务详情草案 |
| `QL-D` | `REWARD.SLOT`、`DETAIL.DIVIDER` | 奖励槽和非交互墨线 | 后续任务详情草案 |
| `QT-A` | `HEADER`、`PAPER`、左右叠页边、`BOTTOM`、`EMBLEM` | 可动态伸缩的追踪器结构 | 外部 provider 未映射，暂停且不可执行 |
| `QT-B` | `COLLAPSE`、`OBJECTIVE`、`FOCUS`、`SEAL`、`TIMER` | 追踪器交互与状态覆盖 | 外部 provider 未映射，暂停且不可执行 |

对应提示词状态：

- [QL-A1 空卷宗结构母版 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md)：
  已确认执行结果；[透明源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png)
  与 [manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)
  已登记为 `P4`。
- [任务详情后续组件资产生产提示词 V2](../../prompts/quests/任务详情组件资产_生产提示词_v2.md)：
  `QL-A2`、`QL-B`、`QL-C`、`QL-D` 仍为 `production-draft`。
- [任务追踪组件资产兼容草案 V2](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md)：
  `deferred-compatibility-draft`，不能执行。

## 7. 资产与 Runtime 实现顺序

1. 保持 `QL-A1` 已确认源母版不变：整图不得进入 runtime，不得从旧草案
   无版本重跑。
2. 另行确认 `QL-A2` 可拉伸纸面、书脊与页叠部件；确认 `QL-A1` 不会自动
   授权 `QL-A2`。
3. `QL-A2` 通过并回到目标客户端后，记录 Quest Log 对象是否存在、原始
   尺寸、锚点和层级，再确定结构切片、拉伸安全区与 adapter 几何。物理双页
   接近等宽已被接受，runtime 阅读安全区仍以左 `42%`／右 `58%` 为目标。
4. 先接入 `QUEST.LOG.SHELL`，只改变呈现，不修改事件与数据。
5. 后续逐批确认并接入左右 ScrollBar、真实 Button 状态、任务行覆盖、日志内
   追踪标记和奖励槽；确认点击区没有改变。
6. 最后评估是否重建 pfUI 的等级显示与详情收起增强。
7. NPC 对话继续使用原生回退；外部 tracker 保持其插件原状，直到完成独立
   provider 合同、重写提示词并再次获得用户确认。

## 8. 当前 Quest Log 实机验收清单

- `L` 打开、关闭、拖动和 ESC 行为不变。
- 地区展开／收起、任务选择、追踪、分享、放弃和滚动都能点击。
- 空日志、满日志、长中文标题、长正文和多奖励不会越过安全区。
- 右页隐藏或对象缺失时仍可使用左页。
- UI Scale 改变后文字与纸面仍对齐。
- 禁用 `AzerothExpeditionUI` 后恢复原生任务界面；pfUI 非视觉功能不变。
- 外部任务追踪插件的 Frame、事件、设置和视觉保持不变，本轮不会重复创建
  第二个追踪面板。

未来恢复 tracker 兼容后，另行验收一项、多项、完成、失败、限时、收起、
移动和战斗态；这些不是当前 `QL-A1` 或 Quest Log runtime 的完成门槛。
