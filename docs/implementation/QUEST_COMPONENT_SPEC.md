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

NPC 任务对话、Gossip 和任务物品 Tooltip 已完成真实对象拆分，但 NPC 对话
的视觉隐喻、目标客户端几何和生产提示词尚未锁定，因此仍不在本轮生成资产。
任务快捷按钮目前没有可靠基础对象，不得假设 pfUI 已经提供。`QL-A1`
空卷宗结构母版已经用户确认并达到 `P4`；透明源母版与来源清单位于
`assets/source/quests/ql-a1/`。该整张母版只作为结构来源，不能直接充当
runtime 背景。`QL-A2 V1` 的五对象方案已因外置封脊朝向、翻页空间、共同
透视和图层关系错误而退回，不得进入 source 或 runtime。`QL-A2 V2.1`
虽然生成了八组逻辑对象的透明候选并完成技术检查，但用户于 `2026-07-29`
因装订针脚偏离绝对中心线、针脚端点与纸页交界突兀以及正文纹理过密而退回；
它只保留在被忽略的 `generated/quests/QL-A2/v2/`，没有成为源资产。替代的
`QL-A2 V3` 也已因页沟、内折、针脚可见性、收口和正文纹理问题被内部退回；
流程审计同时发现它遗漏锁定基准的原始提示词并倒置了视觉权威。替代的
`QL-A2 V3.1` 为 `production-draft / P2`，尚未授权或生图。

视觉权威：

- [任务详情视觉基准](../../assets/locked/quests/任务详情面板_视觉基准_v1.png)
- [任务追踪视觉基准](../../assets/locked/quests/任务追踪面板_视觉基准_v1.png)
- [两张锁定基准的原始提示词 provenance](../../prompts/quests/任务模块_视觉原型提示词_v1.md)
- [任务模块视觉规范](../modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md)
- [统一美术方向](../ART_DIRECTION.md)

锁定图与原始提示词共同构成最高视觉权威。`QL-A1 source` 只承担书体结构和
相邻材料职责，不能覆盖基准的物件身份、笔触、配色、光照、磨损或正文纹理。

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
| `QUEST.LOG.SHELL` | `QuestLogFrame` | Frame | 原生显示、隐藏、层级 | 封皮外壳、外围页叠、左右纸面和内部装订结构；必须切片 |
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
离线重组时，书本物理中心线固定在 `QuestLogFrame` 局部 `x=338`。左右物理
纸页围绕该轴近 1:1 对称，可见宽度差不得超过约 `1%`；左右文字列的不同宽度
不能改变纸页外接尺寸、页沟位置或装订轴线。

#### 3.1.1 内页沟与装订结构

`QUEST.LOG.SPINE` 只保留为“中央装订结构包”的父级兼容名称，不对应一张
可直接渲染的外置封脊资产。进入组件生产与 crop manifest 后必须使用以下
六个稳定子组件 ID：

| ID | 运行时对象／层 | 逻辑职责 | 资产粒度 |
|---|---|---|---|
| `QUEST.LOG.GUTTER.UNDERLAY` | `QuestLogFrame` 中央非交互底层 Texture | 向内凹陷的页沟衬布与接触阴影 | 独立纵向可平铺底层 |
| `QUEST.LOG.GUTTER.LEFT_FOLD` | 左页内缘上方非交互 Texture | 左纸面到页沟的内折过渡 | 独立窄长覆盖层 |
| `QUEST.LOG.GUTTER.RIGHT_FOLD` | 右页内缘上方非交互 Texture | 右纸面到页沟的内折过渡 | 独立窄长覆盖层 |
| `QUEST.LOG.GUTTER.STITCH` | 页沟中央非交互 Texture | 单个可离散重复的横向粗麻针脚站 | 只有横向针脚与极少接触阴影；无纵向绳杆、皮革底板 |
| `QUEST.LOG.GUTTER.TOP` | 页沟顶端非交互 Texture | 藏在纸页下方的小型装订收口 | 独立小线结 |
| `QUEST.LOG.GUTTER.BOTTOM` | 页沟底端非交互 Texture | 藏在纸页下方的小型装订收口 | 独立小线结 |

固定图层顺序为：

1. `QUEST.LOG.SHELL` 的封皮和外围页叠。
2. `GUTTER.UNDERLAY`、`GUTTER.STITCH`、`GUTTER.TOP`、
   `GUTTER.BOTTOM`。
3. `LIST.PAPER` 与 `DETAIL.PAPER` 两张近等宽顶层纸面。
4. `GUTTER.LEFT_FOLD` 与 `GUTTER.RIGHT_FOLD`。
5. runtime 文字、滚动条、任务行和按钮。

纸面必须覆盖页沟两侧，麻线只能从中央窄缝局部露出。不得出现正面朝向
观察者的凸起皮革长条、覆盖正文的束带、横向压条、巨大上下端帽或完整底部
页块。左右物理纸页保持近等宽；左 `42%`／右 `58%` 只指 runtime 文字阅读
安全区，由内边距、列宽和滚动条占用实现。

`GUTTER.STITCH` 不允许纵向平铺或拉伸。runtime 只能把同一个横向针脚站沿
`x=338` 离散重复放置；其左右端点必须延伸到两张内折覆盖层下方，再由
`LEFT_FOLD`／`RIGHT_FOLD` 在更高图层遮住。不得额外生成显眼的纸页接头、
孔环、底板或连续纵向麻线。`GUTTER.TOP`、`GUTTER.BOTTOM` 也必须与同一
中心线共线，且不得参与重复。

`LIST.PAPER` 与 `DETAIL.PAPER` 的 crop manifest 必须分别标出中央安静填充、
不可拉伸页边／页角和不可拉伸专用内缘。中央至少约 `70%` 的文字安全区只
允许低频纤维、缓慢综合色差和大片淡污渍；禁止把 V2.1 的满页密集高频纹样
带入下一候选。

### 3.2 左页目录

| ID | 运行时对象 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.LOG.LIST.PAPER` | `QuestLogListScrollFrame` 周围的呈现层 | 左页连续纸面 | 独立九宫格；不能包含任务行 | 普通 |
| `QUEST.LOG.LIST.SCROLL.TRACK` | `QuestLogListScrollFrameScrollBar` 的轨道区域 | 列表滚动范围 | 上端／可纵向平铺中段／下端；无交互命中 | 普通 |
| `QUEST.LOG.LIST.SCROLL.THUMB` | `QuestLogListScrollFrameScrollBar` 的 ThumbTexture | 当前滚动位置与拖动 | 独立黄铜书签滑块 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.SCROLL.UP` | ScrollBar 的 ScrollUpButton；精确全局名需 feature-detect | 向上滚动 | 独立页角／黄铜箭头 Button | 普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.SCROLL.DOWN` | ScrollBar 的 ScrollDownButton；精确全局名需 feature-detect | 向下滚动 | 独立页角／黄铜箭头 Button | 普通／悬停／按下／禁用 |
| `QUEST.LOG.COLLAPSE.ALL` | `QuestLogCollapseAllButton` | 展开／收起全部地区 | 独立页角／墨箭头按钮 | 展开／收起；各有普通／悬停／按下／禁用 |
| `QUEST.LOG.REGION.TOGGLE` | `QuestLogTitleN` 且 `isHeader=true` 时的展开图标区域 | 单个地区展开／收起 | 独立墨箭头覆盖；不改变整行点击区 | 展开／收起；各有普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.ROW` | `QuestLogTitle1..QUESTS_DISPLAYED` | 地区标题或任务条目点击 | 不生成完整行卡片；仅状态覆盖层，不含书签 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.LIST.CHECK` | `QuestLogTitleNCheck` | 已追踪状态标记；不是独立任务选择 Button | 小型墨圈／墨勾；不创建新命中区域 | 未追踪／已追踪 |
| `QUEST.LOG.SELECTION` | 绑定当前被选中的 `QuestLogTitleN` | 当前任务指示 | 唯一持有选中书签的暗酒红织物覆盖 | 选中／选中悬停／选中按下 |
| `QUEST.LOG.TYPE.BADGE` | `GetQuestLogTitle` 可可靠返回的任务 tag | 精英、地下城、团队等类型 | 一枚一对象的压印徽记图集 | normal／elite／dungeon／raid／timed |
| `QUEST.LOG.STATE.SEAL` | 行状态覆盖 | 完成／失败 | 完成蜡封、破裂蜡封分别制作 | complete／failed |

地区标题和任务条目共用 `QuestLogTitleN`，必须在更新后读取 `isHeader` 决定
排版和 `REGION.TOGGLE` 是否显示。任务选择的真实命中对象是整条
`QuestLogTitleN`；`QuestLogTitleNCheck` 只显示已追踪状态，不能绘制成一个
看似可以单独点击的选择框。任何美术都不能把固定数量的任务名称、等级、计数
或复选标记烘焙进纸面。

### 3.3 右页详情与奖励

| ID | 运行时对象 | 逻辑职责 | 资产粒度 | 状态 |
|---|---|---|---|---|
| `QUEST.LOG.DETAIL.PAPER` | `QuestLogDetailScrollFrame` | 右页连续正文纸面 | 独立九宫格；标题、正文和奖励均为 runtime | 普通 |
| `QUEST.LOG.DETAIL.SCROLL.TRACK` | `QuestLogDetailScrollFrameScrollBar` 的轨道区域 | 正文滚动范围 | 上端／可纵向平铺中段／下端；无交互命中 | 普通 |
| `QUEST.LOG.DETAIL.SCROLL.THUMB` | `QuestLogDetailScrollFrameScrollBar` 的 ThumbTexture | 当前滚动位置与拖动 | 独立黄铜书签滑块 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.DETAIL.SCROLL.UP` | ScrollBar 的 ScrollUpButton；精确全局名需 feature-detect | 向上滚动 | 独立页角／黄铜箭头 Button | 普通／悬停／按下／禁用 |
| `QUEST.LOG.DETAIL.SCROLL.DOWN` | ScrollBar 的 ScrollDownButton；精确全局名需 feature-detect | 向下滚动 | 独立页角／黄铜箭头 Button | 普通／悬停／按下／禁用 |
| `QUEST.LOG.DETAIL.TITLE` | `QuestLogDetailScrollChildFrame` 中的任务标题 FontString；实机确认精确全局名 | 标题与来源安全区 | layout-only，不生成文字资产 | 动态文字 |
| `QUEST.LOG.DETAIL.DESCRIPTION` | 同一 ScrollChild 中的叙述 FontString 集；实机 feature-detect | 任务叙述安全区 | layout-only，不生成背景卡片 | 动态文字 |
| `QUEST.LOG.DETAIL.OBJECTIVES` | 同一 ScrollChild 中的目标 FontString 集；实机 feature-detect | 目标与需求安全区 | layout-only，不生成固定勾选或数字 | 动态文字 |
| `QUEST.LOG.DETAIL.REWARD_TEXT` | 同一 ScrollChild 中的奖励标题、金币、经验或法术 FontString；按客户端实际存在裁减 | 奖励文字安全区 | layout-only，不生成固定奖励内容 | 动态文字 |
| `QUEST.LOG.DETAIL.DIVIDER` | adapter 创建的非交互 Texture | 叙事、目标、奖励分区 | 短墨线，可横向三段式拉伸 | 普通 |
| `QUEST.LOG.REWARD.SLOT` | `QuestLogItem1..MAX_NUM_ITEMS` 及其 Icon／Count／Name | 日志中的只读奖励查看 | 槽底、悬停、按下分别制作；物品图标保持动态 | 普通／悬停／按下／禁用 |
| `QUEST.LOG.TRACK` | `QuestLogTrack`、`QuestLogTrackTracking` | 追踪／取消追踪 | 独立墨圈与羽毛笔勾记 | 未追踪／已追踪／禁用 |

任务标题、来源、正文、目标、奖励名称、数量和金币全部由客户端绘制。生产资产
不得出现伪文字、固定物品图标或固定奖励数量。`QuestLogItemN` 不承担 NPC
任务交付时的奖励选择，不能拥有“已选择奖励”状态；该状态只属于
`QUEST.DIALOG.ITEM.REWARD.SELECTION`。

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

## 5. NPC 任务／Gossip 对话组件合同（已拆分，暂不换肤）

本节解决“右页还应有奖励、拒绝、接受、完成按钮”的对象边界问题。这些对象
不属于按 `L` 打开的 `QuestLogFrame` 右页，而属于与 NPC 交互时出现的
`QuestFrame`／`GossipFrame`。它们已经按 pfUI
[`gossipquest.lua`](../../addon/pfUI/skins/blizzard/gossipquest.lua)
实际处理的原生对象拆分，但当前仍有三个门槛：

1. “NPC 委托文书”的视觉隐喻尚未由用户锁定。
2. Turtle WoW `1.18.1` 的实际尺寸、锚点、ScrollBar 子对象名和 Greeting
   条目对象尚未实机测量。
3. 尚无组件级 production prompt、source、manifest 或 runtime。

因此下列已确认映射统一为 `P1 contract-draft`，缺少精确对象的条目为
`P0 geometry`。当前路由继续显示原生界面；不得因完成对象清单而生成资产或
开启 pfUI 的现代透明换肤。

### 5.1 外壳、肖像与标题

| ID | 原生对象 | 逻辑职责 | 资产／状态合同 |
|---|---|---|---|
| `QUEST.DIALOG.QUEST.SHELL` | `QuestFrame` | 任务委托对话外壳 | 必须切片；不能含正文、按钮或奖励 |
| `QUEST.DIALOG.GOSSIP.SHELL` | `GossipFrame` | NPC Gossip 外壳 | 可与任务外壳共用物理资产，但独立绑定 |
| `QUEST.DIALOG.QUEST.PORTRAIT` | `QuestFramePortrait` | 任务 NPC 动态肖像 | 保留客户端肖像；只生成独立肖像框 |
| `QUEST.DIALOG.GOSSIP.PORTRAIT` | `GossipFramePortrait` | Gossip NPC 动态肖像 | 保留客户端肖像；只生成独立肖像框 |
| `QUEST.DIALOG.QUEST.NPC_NAME` | `QuestFrameNpcNameText` | NPC 名称安全区 | layout-only；不烘焙文字 |
| `QUEST.DIALOG.GOSSIP.NPC_NAME` | `GossipFrameNpcNameText` | NPC 名称安全区 | layout-only；不烘焙文字 |
| `QUEST.DIALOG.QUEST.CLOSE` | `QuestFrameCloseButton` | 关闭任务对话 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.GOSSIP.CLOSE` | `GossipFrameCloseButton` | 关闭 Gossip | 普通／悬停／按下／禁用 |

pfUI 当前换肤会隐藏两张原生肖像；本 overhaul 不得把这种现代简化当作功能
合同。是否保留肖像必须在“NPC 委托文书”视觉方向中明确决定；在此之前原生
肖像与名称均保持可见。

### 5.2 正文面板与滚动子组件

| 面板 ID | Panel／ScrollFrame | 内容职责 | 当前门槛 |
|---|---|---|---|
| `QUEST.DIALOG.QUEST.GREETING.PANEL` | `QuestGreetingPanel`／`QuestGreetingScrollFrame` | NPC 开场、可接与可交任务 | 条目对象待目标客户端映射 |
| `QUEST.DIALOG.GOSSIP.GREETING.PANEL` | `GossipGreetingPanel`／`GossipGreetingScrollFrame` | Gossip 选项与开场文本 | 条目对象待目标客户端映射 |
| `QUEST.DIALOG.QUEST.DETAIL.PANEL` | `QuestDetailPanel`／`QuestDetailScrollFrame` | 新任务标题、叙述、目标与奖励预览 | 动态文字，不烘焙内容 |
| `QUEST.DIALOG.QUEST.PROGRESS.PANEL` | `QuestProgressPanel`／`QuestProgressScrollFrame` | 进行中任务进度和所需物品 | 动态文字与物品 |
| `QUEST.DIALOG.QUEST.REWARD.PANEL` | `QuestRewardPanel`／`QuestRewardScrollFrame` | 交付文本、奖励选择与结果 | 动态文字与奖励 |

每个面板都必须分别登记以下四个滚动子组件，不能用一张完整 ScrollBar 图片
代替。`<PANEL>` 依次代表
`QUEST.GREETING`、`GOSSIP.GREETING`、`QUEST.DETAIL`、
`QUEST.PROGRESS`、`QUEST.REWARD`：

| 稳定后缀 | 原生对象 | 资产／状态合同 |
|---|---|---|
| `QUEST.DIALOG.<PANEL>.SCROLL.TRACK` | 对应 `ScrollFrameScrollBar` 的轨道区域 | 上端／可纵向平铺中段／下端；无命中区 |
| `QUEST.DIALOG.<PANEL>.SCROLL.THUMB` | 对应 ScrollBar 的 ThumbTexture | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.<PANEL>.SCROLL.UP` | 对应 ScrollUpButton；全局名需 feature-detect | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.<PANEL>.SCROLL.DOWN` | 对应 ScrollDownButton；全局名需 feature-detect | 普通／悬停／按下／禁用 |

五组面板可以在 manifest 中引用同一套物理滚动条图集，但必须保留二十个逻辑
绑定 ID。Greeting 中每条任务／Gossip 选项的精确全局对象不在
`gossipquest.lua` 中枚举；取得 FrameXML 或 `/fstack` 证据前只登记
`QUEST.DIALOG.QUEST.GREETING.ENTRY` 和
`QUEST.DIALOG.GOSSIP.GREETING.ENTRY` 为 `P0 geometry`，不得凭空创建
“任务选框”或独立按钮。

### 5.3 八个真实操作按钮

| ID | 原生 Button | 语义 | 状态 |
|---|---|---|---|
| `QUEST.DIALOG.ACTION.QUEST_GREETING_GOODBYE` | `QuestFrameGreetingGoodbyeButton` | 从任务 Greeting 告别 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.GOSSIP_GREETING_GOODBYE` | `GossipFrameGreetingGoodbyeButton` | 从 Gossip 告别 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.DECLINE` | `QuestFrameDeclineButton` | 拒绝新任务 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.ACCEPT` | `QuestFrameAcceptButton` | 接受新任务 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.GOODBYE` | `QuestFrameGoodbyeButton` | 关闭任务进度对话 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.COMPLETE` | `QuestFrameCompleteButton` | 继续到奖励／完成阶段 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.CANCEL` | `QuestFrameCancelButton` | 取消奖励交付 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ACTION.COMPLETE_QUEST` | `QuestFrameCompleteQuestButton` | 确认完成任务 | 普通／悬停／按下／禁用 |

八个逻辑 Button 可以在几何实测一致后共用一套物理按钮图集，但不能合并为一个
父级 `ACTIONS` 行，也不能把按钮文字烘焙进资产。adapter 只换肤原生 Button，
不重写任务接受、拒绝、继续、完成或关闭逻辑。

### 5.4 所需物品、奖励与选择覆盖

| ID | 原生对象 | 逻辑职责 | 状态／约束 |
|---|---|---|---|
| `QUEST.DIALOG.ITEM.PROGRESS` | `QuestProgressItem1..6` | 当前进度所需／已交物品 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ITEM.DETAIL` | `QuestDetailItem1..6` | 接受前的奖励／需求预览 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ITEM.REWARD.SLOT` | `QuestRewardItem1..6` | 可选或固定奖励槽 | 普通／悬停／按下／禁用 |
| `QUEST.DIALOG.ITEM.REWARD.SELECTION` | `QuestRewardItemHighlight`；只在 `this.type == "choice"` 时绑定 | 玩家当前选择的奖励 | 未选择／已选择／已选择悬停 |

每个物品对象的 Icon、Count 与 Name 都是客户端动态内容。槽底、悬停层和奖励
选择层必须拆开；只有 `REWARD.SELECTION` 可以表达“已选择奖励”。这也是
`QUEST.LOG.REWARD.SLOT` 保持只读、没有 selected 状态的原因。

### 5.5 任务物品行为边界

| ID | 对象 | 当前处理 |
|---|---|---|
| `QUEST.ITEM.TOOLTIP` | pfUI `questitem.lua` | `N/A` 视觉；保留任务名称与数量扫描行为 |
| `QUEST.ITEM.QUICKBUTTON` | 当前无可靠基础对象 | `P0` future extension；不得归因给 `questitem.lua` |

## 6. 资产包与执行批次

任何获准执行的批次都只能生成下面列出的逻辑对象。禁止生成整张带按钮、
任务文字和奖励图标的完成界面。

| 批次 | 组件 | 输出责任 | 当前状态 |
|---|---|---|---|
| `QL-A` | `SHELL`、`LIST.PAPER`、`DETAIL.PAPER`、六个 `GUTTER.*` 子组件 | 纯结构资源；近等宽双页、页沟、内折和装订分别裁切 | `QL-A1` 源母版为 `P4`；`QL-A2 V1`／`V2.1`／`V3` 已退回；基准继承修订 `V3.1` 为 `prompt-draft / P2`，未授权 |
| `QL-B` | `LIST.ROW`、`REGION.TOGGLE`、`LIST.CHECK`、`SELECTION`、`TYPE.BADGE`、`STATE.SEAL` | 目录展开、追踪、选择与任务状态覆盖 | 后续任务详情草案 |
| `QL-C` | 列表／详情各自的 `SCROLL.TRACK`、`THUMB`、`UP`、`DOWN`；`CLOSE`、操作按钮、`TRACK`、`DETAIL.TOGGLE`、`LEVELS` | 每个真实交互对象的完整状态画布 | 后续任务详情草案 |
| `QL-D` | `REWARD.SLOT`、`DETAIL.DIVIDER` 与四个 `DETAIL.*` layout-only 区域 | 只读奖励槽、非交互墨线和文字安全区 | 后续任务详情草案 |
| `QD-A` | Quest／Gossip `SHELL`、`PORTRAIT`、`NPC_NAME`、`CLOSE` 与五个正文 `PANEL` | NPC 委托文书外壳、标题和面板结构 | `P1 contract-draft`；视觉与目标几何未锁定，保持原生 |
| `QD-B` | 五个面板各自的 `SCROLL.TRACK`、`THUMB`、`UP`、`DOWN` 与 Greeting `ENTRY` | 二十个滚动绑定和两类动态条目 | ScrollBar 为 `P1`；Entry 为 `P0 geometry`；保持原生 |
| `QD-C` | 八个 `QUEST.DIALOG.ACTION.*` Button | 接受、拒绝、继续、完成、取消与两类告别 | `P1 contract-draft`；无 production prompt |
| `QD-D` | `ITEM.PROGRESS`、`ITEM.DETAIL`、`ITEM.REWARD.SLOT`、`ITEM.REWARD.SELECTION` | 需求物品、奖励槽和唯一奖励选择覆盖 | `P1 contract-draft`；保持图标／数量／名称动态 |
| `QT-A` | `HEADER`、`PAPER`、左右叠页边、`BOTTOM`、`EMBLEM` | 可动态伸缩的追踪器结构 | 外部 provider 未映射，暂停且不可执行 |
| `QT-B` | `COLLAPSE`、`OBJECTIVE`、`FOCUS`、`SEAL`、`TIMER` | 追踪器交互与状态覆盖 | 外部 provider 未映射，暂停且不可执行 |

对应提示词状态：

- [QL-A1 空卷宗结构母版 production V1](../../prompts/quests/任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md)：
  已确认执行结果；[透明源母版](../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png)
  与 [manifest](../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)
  已登记为 `P4`。
- [QL-A2 可拉伸结构部件 production V1](../../prompts/quests/任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md)：
  已执行但因外置封脊、翻页与图层错误被用户退回，只保留为失败记录。
- [QL-A2 内页沟结构部件 production V2](../../prompts/quests/任务详情内页沟结构部件_生产提示词_QL-A2_v2.md)：
  冻结过近等宽双页与六个中央结构子组件的八对象合同；后续复审结论已退回。
- [QL-A2 内页沟结构部件 production edit V2.1](../../prompts/quests/任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md)：
  固定版本执行后被用户退回；只保留 provenance，不得进入 tracked source。
- [QL-A2 对称内页沟结构部件 production V3](../../prompts/quests/任务详情对称内页沟结构部件_生产提示词_QL-A2_v3.md)：
  固定版本已执行并被内部结构／美术继承审查退回；只保留 provenance，不得
  进入 tracked source。
- [QL-A2 基准继承修订 production draft V3.1](../../prompts/quests/任务详情低频对称内页沟结构部件_生产提示词_QL-A2_v3.1.md)：
  `prompt-draft / P2`；保留绝对中心线、近 1:1 双页与横向针脚合同，并新增
  锁定基准 prompt provenance、美术 DNA、组件转译、排除项和冲突裁决。
- [任务详情后续组件资产生产提示词 V2](../../prompts/quests/任务详情组件资产_生产提示词_v2.md)：
  `QL-B`、`QL-C`、`QL-D` 仍为 `production-draft`；必须在 V3.1 结构通过后
  按本合同新增的对象粒度再次审查。
- [任务追踪组件资产兼容草案 V2](../../prompts/quests/任务追踪组件资产_生产提示词_v2.md)：
  `deferred-compatibility-draft`，不能执行。

`QD-A` 至 `QD-D` 当前只有对象合同，不存在 production prompt。不得借用
Quest Log 提示词，也不得把整张 NPC 对话效果图登记成可运行资产。

## 7. 资产与 Runtime 实现顺序

1. 保持 `QL-A1` 已确认源母版不变：整图不得进入 runtime，不得从旧草案
   无版本重跑。
2. 保留 `QL-A2 V1` 退回记录，不再从其中提取三段外置封脊或
   `140 × 60` 周期。
3. 保留 `QL-A2 V2.1` 的用户退回记录；不得上传它作为 V3.1 输入，不得通过
   Alpha 清理、锐化或手工平移伪装修正结构。
4. 保留 `QL-A2 V3` 的内部退回和流程审计记录；不得上传候选，也不得沿用其
   “QL-A1 source 最高权威”的错误参考职责。
5. 用户看到最终执行正文后，必须明确授权 `QL-A2 V3.1`；“继续”或“下一步”
   本身不构成生图授权。获得版本明确授权后才允许由固定
   `imagegen-0-143-0` 执行器生成新候选和确定性重组预演。
6. 只有 V3.1 候选再次经用户明确接受，才可复制到
   `assets/source/quests/ql-a2/` 并为八个逻辑对象建立 crop manifest。
7. `QL-A2` 通过并回到目标客户端后，记录 Quest Log 对象是否存在、原始
   尺寸、锚点和层级，再确定最终结构切片、拉伸安全区与 adapter 几何。物理
   双页继续接近等宽，runtime 阅读安全区仍以左 `42%`／右 `58%` 为目标。
8. 先接入 `QUEST.LOG.SHELL`，只改变呈现，不修改事件与数据。
9. 后续逐批确认并接入左右 ScrollBar、真实 Button 状态、任务行覆盖、日志内
   追踪标记和奖励槽；确认点击区没有改变。
10. 最后评估是否重建 pfUI 的等级显示与详情收起增强。
11. NPC 对话继续使用原生回退。只有“NPC 委托文书”视觉方向和目标几何均
    确认后，才能按 `QD-A` 至 `QD-D` 分批写 production prompt；不得从父级
    整图开始。
12. 外部 tracker 保持其插件原状，直到完成独立
   provider 合同、重写提示词并再次获得用户确认。

## 8. 当前 Quest Log 实机验收清单

- `L` 打开、关闭、拖动和 ESC 行为不变。
- 地区展开／收起、任务选择、追踪、分享、放弃和滚动都能点击。
- `QuestLogTitleN` 整行仍是任务选择命中区；`QuestLogTitleNCheck` 只表达
  追踪状态，不得伪装成可独立点击的任务选框。
- 空日志、满日志、长中文标题、长正文和多奖励不会越过安全区。
- 书本局部中心线、页沟、针脚站和上下收口共同对齐 `x=338`，离线偏移不超过
  `1 UI px`；左右物理页可见宽度差不超过约 `1%`。
- 针脚两端被左右内折自然遮住，纸页交界没有独立深色接头、孔环或底板。
- 右页隐藏或对象缺失时仍可使用左页。
- UI Scale 改变后文字与纸面仍对齐。
- 禁用 `AzerothExpeditionUI` 后恢复原生任务界面；pfUI 非视觉功能不变。
- 外部任务追踪插件的 Frame、事件、设置和视觉保持不变，本轮不会重复创建
  第二个追踪面板。

未来恢复 tracker 兼容后，另行验收一项、多项、完成、失败、限时、收起、
移动和战斗态；这些不是当前 `QL-A1` 或 Quest Log runtime 的完成门槛。

未来启动 NPC 对话换肤后，还必须另行覆盖 Greeting、Detail、Progress、
Reward 四种任务流程、纯 Gossip 流程、无奖励、固定奖励、多选一奖励、所需
物品不足和每个操作按钮禁用状态；这些也不是当前 QL-A2 的完成门槛。
