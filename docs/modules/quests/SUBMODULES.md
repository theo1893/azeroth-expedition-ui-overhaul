# Quests 子模块定义

本文件是任务模块唯一的真实对象合同，严格对齐当前仓库内 pfUI 与原生
Frame。美术见 [ART_BASELINE.md](ART_BASELINE.md)，状态见
[PROGRESS.md](PROGRESS.md)。

## 来源与所有权

| 来源 | 已证实职责 | 项目边界 |
|---|---|---|
| [`skins/blizzard/questlog.lua`](../../../addon/pfUI/skins/blizzard/questlog.lua) | `QuestLogFrame` 双栏几何、列表／详情 ScrollFrame、日志按钮、奖励槽、pfUI 等级与详情收起增强 | 保留原生数据与事件；新 adapter 不加载现代 backdrop |
| [`Modules/Quests.lua`](../../../addon/AzerothExpeditionUI/Modules/Quests.lua) | QL-A2 V4 固定 SHELL、阅读安全区、原生装饰隐藏与真实详情切换 Button | 只接管静态外壳和布局；不替代任务数据、原按钮脚本、动态内容或 SavedVariables |
| [`Modules/QuestVisualTheme.lua`](../../../addon/AzerothExpeditionUI/Modules/QuestVisualTheme.lua) | Quest Log／Tracker 共用媒体入口、字体角色、语义墨色与皮革控件色 | 唯一视觉主题入口；统一材料和状态语言，但不得把双页卷宗与纵向行军便笺合并为同一轮廓 |
| [`pfQuest/quest.lua`](../../../addon/pfQuest/quest.lua) | Quest Log 等级文字、在线／语言入口、显示／隐藏／清空／重置操作，以及对三个 Quest Log 刷新入口的后加载替换 | provider 继续拥有任务数据库与全部点击行为；AEUI 只在 provider 最终刷新后恢复安全区并搬移真实控件 |
| [`pfQuest/tracker.lua`](../../../addon/pfQuest/tracker.lua) | `pfQuestMapTracker`、三种追踪模式、七个工具 Button、最多二十五个动态任务／目标 Button | 唯一 tracker provider；AEUI 未来只替换 chrome、排版和状态反馈，不创建第二个追踪器 |
| [`pfQuest-turtle/`](../../../addon/pfQuest-turtle/) | Turtle WoW 任务数据库、语言数据、覆盖和补丁表 | 数据扩展；没有独立 tracker 或 Quest Log UI 所有权 |
| [`skins/blizzard/gossipquest.lua`](../../../addon/pfUI/skins/blizzard/gossipquest.lua) | `QuestFrame`、`GossipFrame`、五个内容面板、滚动条、八个操作按钮、奖励高亮 | 当前由 pfUI 正常加载；不在 Quest Log 的接管路由内 |
| [`modules/questitem.lua`](../../../addon/pfUI/modules/questitem.lua) | 任务物品 Tooltip 的任务归属、扫描与数量 | 原样保留；不是快捷使用按钮 |

当前 runtime 波次只接入按 `L` 打开的 `QuestLogFrame`。pfQuest tracker
已经完成对象审计；用户已确认聚焦主体的本地确定性 `QT-SIM V2` 几何方向。
QT-A1／B1 V1 已获独立生产授权，固定 Image 1／2／3、同段 edit 边界和各
`5` 次实际调用上限已冻结。QT-A1 已在 `5/5` 后因中心压花式微纹理、source
bbox 与原生色键失败成为 `candidate-rejected / repair-budget-exhausted`，
但用户随后选择直接使用大块背景；attempt 4 的确定性 RGBA 已按临时合同
例外晋级并导出九宫格 runtime。QT-B1 focus／tracked／complete 三件覆盖层
因真实排版很糟糕被暂停于 `1/5`，adapter 不挂载它们并隐藏 provider 的现代
半透明行矩形。QT-A2 七工具 Button 保持 `scope-deferred` 与 provider
fallback。NPC 对话仍没有获准生产资产。

## Quest Log 顶层

| ID | 真实对象 | 状态／资产合同 |
|---|---|---|
| `QUEST.LOG.SHELL` | `QuestLogFrame` | `676 × 464` 固定非交互空卷宗背景；不拉伸，不包含任何动态内容或交互状态 |
| `QUEST.LOG.TITLE` | `QuestLogTitleText` | layout-only 动态文字 |
| `QUEST.LOG.COUNT` | `QuestLogQuestCount`；兼容 `QuestLogCount` | layout-only；使用纸面深墨文字，不新增外框 |
| `QUEST.LOG.CLOSE` | `QuestLogFrameCloseButton` | 普通／悬停／按下／禁用 |
| `QUEST.LOG.EMPTY` | `EmptyQuestLogFrame`、`QuestLogNoQuestsText` | 安静纸面，不生成空状态卡片 |
| `QUEST.LOG.CHROME.SEAL` | `QuestLogFrame.aeuiQuestChromeSeal`，当前是 adapter-owned 无鼠标 `OVERLAY` Texture | QS-A1 V1.r4 美术与四态 atlas 仍 accepted；旧 `[600,-18,28,28]` 顶部悬空锚点只作为待替换 P5 fallback。V1–V7 已否决；当前 `QUEST-LOG-SEAL-ACTIONS-SIM-V8 / simulation-reviewed` 将 `32×32px` 漆章直接压在详情页右上纸面，`40×40px` 命中／保留区为 `[572,64,40,40]`，未确认前不得接入 |
| `QUEST.LOG.CHROME.SEAL.SUPPORT` | V8 无 runtime 对象 | 用户明确要求火漆直接印在详情页纸面；不得再创建书签、包角、皮革／黄铜承托或额外 Texture。最终只允许漆章自身与纸面接触阴影 |

支持 `closed`、`empty`、`list-only`、`dual-page` 与 `selected`。离线参考为
`676 × 464 UI px`，物理中心线 `x=338`；左右物理纸页近 1:1，可见宽度差
不超过约 `1%`。左 `42%`／右 `58%` 只属于文字列，不改变纸页宽度。
`list-only` 只隐藏右页动态内容，完整书体保持 `676 × 464`，不得缩成
`340px` 半本书。

旧 runtime 锚点位于书本右上方透明空间并产生 `18px` 顶部 outset，用户已
判定其“浮在空中”。随后 V1–V6 的外沿皮革、羊皮封签、下缘长书签、detail
替换、黄铜包角和页内右侧菜单方向也依次被否决。当前 V8 只保留用户明确指定的物理关系：
火漆直接压在右侧详情页右上纸面；标题与分隔线为其保留 `40×40px` 区域。
点击后七项事务作为真实独立 Button 从 detail 右边界 `x=612` 向书外伸出，
真实页边 mask 遮住根部；不得进入书页内容区或覆盖正文／奖励。打开态允许
`72px` 右侧 outset，并在屏幕右缘不足时整体左移后恢复。该方向在用户确认前
只是 work 中的几何提案，runtime 仍保持 fail-open fallback。

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
| `QUEST.LOG.LIST.CHECK` | `QuestLogTitleNCheck` 与历史 `aeuiQuestListCheck` | 用户于 `2026-08-01` 判定行末圈无有效信息价值；runtime 全部隐藏且不创建替代命中，追踪数据与 Shift 点击行为仍由 provider 保留 |
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

runtime `1.17` 已落实用户确认的 V2 阅读密度：`QUESTS_DISPLAYED = 18`，
活动窗口使用 `QuestLogTitle1..18`，每条 `246 × 18 UI px`、纵向步进
`18px`，总占高 `324px`。左右页 scrollbar chrome 均隐藏后，活动行使用
完整 `246px` 左页安全宽度；动态文字从 `x=18` 起，安全宽度 `226px`。
任务名、地区名以及模板可能拆出的完成／地下城等状态 FontString 统一继承
`pfUI.font_default`、固定 `12px`、使用 `OUTLINE` 并清零额外 shadow。
`QuestLogTitle19..23` 继续创建以
兼容 provider，但不删除、不改写脚本并保持隐藏；缺少 adapter 时仍回退
pfUI。完整资源与排版历史合同见
[work/QUEST.LOG.LEFTPAGE.md](work/QUEST.LOG.LEFTPAGE.md)。

QL-B 的生产边界：

- `QL-B1`：`REGION.TOGGLE` 与 `LIST.CHECK` 四枚墨记；V1.r3 透明 source
  已接受。runtime 只允许按 manifest 固定四格裁切、等比缩放并居中，
  不得修改任务行交互或状态来源。当前只显示地区箭头；行末追踪圈按用户
  决定隐藏，accepted source 仍保留供顶部真实 CheckButton 使用，不重新生图。
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

QL-B0／B1 当前 runtime 已接入
`addon/AzerothExpeditionUI/Modules/Quests.lua`：atlas 为
`QuestLogDirectoryMarksV1.tga`，四个 `16 × 16` cell 的内部 content box
保留 `12 × 12` 箭头和 `10 × 10` 墨圈；任务行只挂载箭头，墨圈继续供顶部
等级／追踪 CheckButton 使用。覆盖 Texture 不接收鼠标；
原 `QuestLogTitleN` Button、脚本、滚动、选择和追踪数据均保持。字体仅按
模块基线把主标题设为 Noto Serif SC、任务及状态行恢复为
`pfUI.font_default` 的 `12px OUTLINE`，并清除额外 shadow，仍需实机加载
验证。QL-B2 的 `BORDER` Texture 挂载与三态脚本已从
runtime contract `1.5` 起移除；资产文件不删除，运行时一律隐藏。当前
Quests runtime contract 已升至 `1.17`；任务名难度色及完成／失败／类型提示
统一读取 Quest Visual Theme `1.6` 的高对比深墨，模板拆分 FontString 与
标题后的内联色码均在 provider 最终刷新后归一化。

QL-B0 V2 的 `LIST.INSET` 已在四次候选审查后由用户移出范围，不建立 source、
runtime、占位 Texture 或 fallback 分支。`REGION.BACKPLATE` 与
`ROW.BACKPLATE` 在五次候选耗尽后也由用户于 `2026-07-31` 明确移出范围；
不建立 source、runtime、占位 Texture 或新的生成路线。失败候选与合同只在
[work/QUEST.LOG.LEFTPAGE.md](work/QUEST.LOG.LEFTPAGE.md) 保留历史证据。

## Quest Log 滚动与控制

| ID | 真实对象 | 状态／资产 |
|---|---|---|
| `QUEST.LOG.LIST.SCROLL.TRACK` | `QuestLogListScrollFrameScrollBar` 轨道 | 视觉隐藏且不接收鼠标；真实 Slider 保留供滚轮设置值 |
| `QUEST.LOG.LIST.SCROLL.THUMB` | 对应 ThumbTexture | 视觉隐藏 |
| `QUEST.LOG.LIST.SCROLL.UP` | 对应 ScrollUpButton，需 feature-detect | 视觉隐藏且不接收鼠标 |
| `QUEST.LOG.LIST.SCROLL.DOWN` | 对应 ScrollDownButton，需 feature-detect | 视觉隐藏且不接收鼠标 |
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
| `QUEST.LOG.REWARD.SLOT` | `QuestLogItem1..MAX_NUM_ITEMS` | 普通／悬停／按下／禁用；图标动态，无 selected；runtime `1.17` 将双列单格收敛为 `108px`，名称安全宽 `64px` |
| `QUEST.LOG.TRACK` | `QuestLogTrack`、`QuestLogTrackTracking` | 复用 QL-B1 开放墨圈／墨勾 atlas；保留原状态控制 |
| `QUEST.LOG.ACTION.ABANDON` | `QuestLogFrameAbandonButton` | 当前程序化暗皮革 fallback；目标事务菜单只代理原 OnClick，必须保留原生确认 |
| `QUEST.LOG.ACTION.SHARE` | `QuestFramePushQuestButton`；兼容名需探测 | 当前程序化暗皮革 fallback；目标事务菜单代理原 Button |
| `QUEST.LOG.ACTION.EXIT` | `QuestFrameExitButton`；兼容 `QuestLogFrameCancelButton` | 目标视觉不重复收纳；右上真实 Close 保持独立，fallback 在迁移验收前继续存在 |
| `QUEST.LOG.DETAIL.TOGGLE` | pfUI `QuestLogFrameExpandButton`；缺失时可创建真实 Button | 当前底部 fallback；目标事务菜单代理同一动态开合行为 |
| `QUEST.LOG.ACTION.SEAL_MENU` | proposed adapter-owned 右页外侧卷宗索引签 Button 列；未接入 | `QUEST-LOG-SEAL-ACTIONS-SIM-V8` 沿用分享、详情开合、pfQuest 四个地图操作与放弃，共七项；左键切换，选择／书外点击／Esc 收起，禁用态镜像 provider。七个 Button 位于 `[612,108,136,186]`，和 detail 右边界排他相切并向书外伸出；真实页边 mask `[604,96,24,210]` 遮住根部，正文／奖励零占用，不画整块二级弹窗 |
| `QUEST.LOG.LEVELS` | pfUI `QuestLogFrameLevelsCheckButton` | 复用 QL-B1 开放墨圈／墨勾 atlas；保留原脚本与文字 |
| `QUEST.LOG.PFQUEST.ONLINE` | `pfQuest.buttonOnline`／`pfQuestOnline` | `72 × 16`，右页顶部固定工具行；动态 ID 与原 OnClick 不变 |
| `QUEST.LOG.PFQUEST.LANGUAGE` | `pfQuest.buttonLanguage`／`pfQuestLanguage` | `86 × 16`，与 ONLINE 同行；动态语言、下拉与原 OnUpdate／OnClick 不变 |
| `QUEST.LOG.PFQUEST.SHOW` | `pfQuest.buttonShow`／`pfQuestShow` | `52 × 20`，右页固定底部四按钮行第 1 格 |
| `QUEST.LOG.PFQUEST.HIDE` | `pfQuest.buttonHide`／`pfQuestHide` | `52 × 20`，第 2 格 |
| `QUEST.LOG.PFQUEST.CLEAN` | `pfQuest.buttonClean`／`pfQuestClean` | `52 × 20`，第 3 格 |
| `QUEST.LOG.PFQUEST.RESET` | `pfQuest.buttonReset`／`pfQuestReset` | `52 × 20`，第 4 格 |

右页仍由 `QuestLogDetailScrollFrame` 承担裁切与滚动；左页仍由
`QuestLogListScrollFrame`、FauxScrollFrame offset 与隐藏的真实 Slider
承担列表滚动。adapter 只隐藏两侧滚动条 chrome，并分别追加
`OnMouseWheel`：右页以 `28 UI px` 在真实 range 内限位，左页按原生
`QUESTLOG_QUEST_HEIGHT`（缺失时 `18px`）推进一个逻辑行。隐藏视觉不删除
ScrollFrame、offset、裁切或数据。

runtime `1.17` 在把普通正文收敛为 `214px`、目标收敛为 `204px` 后，遍历
当前可见的标题、正文、目标、奖励文字、`QuestLogItemN` 与附加奖励 Frame，
以最底部对象加 `12px` 余量重算 ScrollChild 高度（最低 `324px`、保护上限
`4096px`），随后调用真实 `UpdateScrollChildRect()`。因此长文本重新换行后
奖励不会再被旧固定内容高裁掉；鼠标滚轮仍使用真实动态 range。

pfQuest 在加载后会替换 `QuestLog_Update`、
`QuestLog_UpdateQuestDetails` 和 `QuestLogFrame` 的 `OnShow`，并在详情
ScrollChild 内增加六个控件和 `30px` 标题预留。AEUI 必须在 provider 的
最终刷新之后，以事件驱动方式恢复 `QuestLogTitle1..18` 的
`246 × 18` 行盒、`226px` 文字宽度，隐藏 `19..23` 与行末追踪圈，并恢复
右页正文几何；不得用 `OnUpdate`
持续争夺 Parent／Point／Size。六个 provider Button 只改 Parent、Point、
Size、字体和视觉状态，不替换脚本、ID、Enable／Disable、Show／Hide 或
SavedVariables。

## pfQuest Quest Tracker

用户于 `2026-07-31` 提供的当前游戏内结构参考：
[01_external_quest_tracker_current_state.png](../../../assets/references/quests/session-2026-07-31/01_external_quest_tracker_current_state.png)。
该图只证明现有信息密度和层级，不是美术权威。Quest Log 兼容失败证据为
[02_third_party_quest_plugin_layout_failure.png](../../../assets/references/quests/session-2026-07-31/02_third_party_quest_plugin_layout_failure.png)。

### 顶层、纸面与工具条

| ID | provider 对象 | 合同 |
|---|---|---|
| `QUEST.TRACKER.SHELL` | 全局 `tracker`／`pfQuest.tracker`，Frame 名 `pfQuestMapTracker` | 唯一顶层 Frame；保留拖动、锁定、屏幕限位、位置保存、显隐和 WorldMap strata 行为 |
| `QUEST.TRACKER.PAPER.TOP` | adapter-owned、挂在 `tracker.backdrop` 下的无鼠标 Texture | 横向三段式纸面顶部；宽度随 tracker 变化 |
| `QUEST.TRACKER.PAPER.MIDDLE` | adapter-owned、挂在 `tracker.backdrop` 下的无鼠标 Texture | 可横纵延展的连续安静纸面；不得烘焙任务行 |
| `QUEST.TRACKER.PAPER.BOTTOM` | adapter-owned、挂在 `tracker.backdrop` 下的无鼠标 Texture | 横向三段式自然撕裂底边 |
| `QUEST.TRACKER.PAPER.EDGE` | adapter-owned 独立叠页边 Texture | 只在边缘表现错层纸页，不改变 Frame 命中 |
| `QUEST.TRACKER.HUB.SEAL` | `pfQuestMapTracker.aeuiQuestHubSeal`，adapter-owned 无鼠标父级 `ARTWORK` Texture；未来有功能等价后才升级为 Button | QS-A1 V1.r4 accepted；`34 × 34` 顶部中央明显漆章，实际可见蜡体约 `32 × 31`；`x=floor((W-34)/2)`、`y=-18`，底边落在 `y=16`，不移动或覆盖列表；采样同一 atlas normal cell |
| `QUEST.TRACKER.HUB.MENU` | 未来 adapter-owned 临时交互层 | 独立后续批次；必须一一委托七个 provider Button 的既有行为后，才能允许旧 icon 隐藏 |
| `QUEST.TRACKER.HEADER.STRAP` | `tracker.panel` 的未来 adapter-owned 三段式背景 | `scope-deferred`；当前不创建或挂载资产，provider 工具条不变 |
| `QUEST.TRACKER.HEADER.EMBLEM` | 未来 adapter-owned 无鼠标 Texture | `scope-deferred`；当前不存在 source 或 runtime |
| `QUEST.TRACKER.MODE.QUESTS` | `tracker.btnquest` | `scope-deferred`；保留 `QUEST_TRACKING` 和全部真实状态／行为 |
| `QUEST.TRACKER.MODE.DATABASE` | `tracker.btndatabase` | `scope-deferred`；保留 `DATABASE_TRACKING` 和全部真实状态／行为 |
| `QUEST.TRACKER.MODE.GIVERS` | `tracker.btngiver` | `scope-deferred`；保留 `GIVER_TRACKING` 和全部真实状态／行为 |
| `QUEST.TRACKER.ACTION.SEARCH` | `tracker.btnsearch` | `scope-deferred`；保留打开数据库脚本、Tooltip 与状态 |
| `QUEST.TRACKER.ACTION.CLEAN` | `tracker.btnclean` | `scope-deferred`；保留清空数据库结果脚本、Tooltip 与状态 |
| `QUEST.TRACKER.ACTION.SETTINGS` | `tracker.btnsettings` | `scope-deferred`；保留设置入口、Tooltip 与状态 |
| `QUEST.TRACKER.ACTION.CLOSE` | `tracker.btnclose` | `scope-deferred`；保留隐藏、配置写入、Tooltip 与状态 |

provider 的内容几何仍是 `16px` 工具条加动态条目；adapter 只在 root 底部
追加 `16px` 非交互内容安全区，使最后一条目标不进入撕裂装饰 cap。纸面四边
outset 继续为 `0px`；`QUEST.TRACKER.HUB.SEAL` 单独允许顶部 `18px` 可见 outset，不构成
书框或纸面边界。由于 provider 的 `SetClampedToScreen(true)` 只保证 root
Frame，adapter 现已 feature-detect `SetClampRectInsets` 并在既有 top inset
上补 `18px`；目标客户端仍需复核缺少该 API 时的 provider fallback 与拖动
保存。不能让子 Texture 在屏幕顶缘被裁掉。目标视觉隐藏
七枚旧 icon，但只有
`QUEST.TRACKER.HUB.MENU` 完成七项功能等价、Tooltip、状态反馈和原脚本委托后，
才允许把原 Button 视觉隐藏并禁用鼠标；迁移前它们继续原样可见可用。
当前 runtime 不隐藏、删除、重挂、换皮或改写 provider 对象。最窄
`130px` 时 `search` 覆盖漆章右下部、`giver／clean` 各触及 `1px` 边条；
Button 子 Frame 继续绘制在父级 ARTWORK 之上并保有鼠标与原脚本。这是 hub
menu 等价完成前的显式过渡状态，不授权隐藏、删除、重挂、换皮或改写重叠
按钮。

### 动态条目

| ID | provider 对象／状态 | 合同 |
|---|---|---|
| `QUEST.TRACKER.ENTRY` | `tracker.buttons`／`pfQuestMapButton1..25` | 真实 Button；高度为 `entryheight + objectives × fontsize`，不生成逐项卡片；provider 回调后只置主题 dirty，整批重建完成后统一提交呈现 |
| `QUEST.TRACKER.ENTRY.FOCUS` | `button.bg` 与 `pfMap.highlight == button.title` | 可横向延展的低对比墨洗；不创建命中区 |
| `QUEST.TRACKER.ENTRY.ICON` | `button.icon`／`button.node` | 用户于 `2026-08-01` 明确要求隐藏彩色点／问号；adapter 只隐藏 `button.icon` Texture，保留 `button.node` 数据、Button 命中与全部 provider 行为，也不生成替代图标 |
| `QUEST.TRACKER.ENTRY.TITLE` | `button.text` | 动态等级、任务名与完成率；保留 pfUI／pfQuest 原有统一字体路径和 provider 动态字号；任务名与 Quest Log 调用同一难度墨色 resolver，进度保留独立状态墨色；移除 `OUTLINE`，shadow 为透明／零偏移 |
| `QUEST.TRACKER.OBJECTIVE` | `button.objectives[i]` | 动态目标文字与计数；保留 provider 高可读字号，完成／未完成状态读取共享主题墨色 |
| `QUEST.TRACKER.ENTRY.TRACKED` | `button.tracked` | 仅在任务模式可用的克制页边墨记；无新 Button |
| `QUEST.TRACKER.ENTRY.COMPLETE` | `button.perc == 100` | 小型完成墨勾；无失败／蜡封语义 |

provider 当前根宽度为 `min(内容宽度, 300) + 30`，即 `130..330 UI px`；
provider 内容高度为 `16px` 工具条加最多二十五个动态条目，AEUI root 显示高度
固定再加 `16px` 底部安全区。空状态显示高度因此为 `32px`；非空状态在一次
dirty 批次提交中按全部有效 Button 高度计算，clean 帧不重复写尺寸。三种模式、空状态、目标折叠／
展开和任意高度都必须由同一组可拉伸／平铺切片承载，禁止使用一张固定尺寸
tracker 背景。

`expand_states` 是 provider 文件内局部表，没有独立 Frame 或公开状态字段；
当前不得为 `QUEST.TRACKER.COLLAPSE` 生成假 Button。pfQuest tracker 没有
独立 timer／failed 状态，因此 `QUEST.TRACKER.TIMER` 和失败蜡封不进入当前
合同。未来只有取得真实状态来源后才能新增。

所有现有行为保持：左键折叠／展开目标，右键打开 Quest Log，Ctrl 点击打开
地图／切色，Shift 点击隐藏节点或标记完成；三模式、Tooltips、最多二十五条、
动态排序、配置字体／透明度、`trackerpos` 和 `showtracker` 均由 provider
继续拥有。provider 隐藏原生 `QuestWatchFrame` 的行为保持；AEUI 不扫描或
接管 `QuestWatchLineN`，也不创建第二个追踪器。

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
