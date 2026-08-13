# Quests 子模块美术基线 Prompt

所有条款继承 [ART_BASELINE.md](ART_BASELINE.md) 与
[全局美术基线](../../GLOBAL_ART_BASELINE.md)。本文件只保留稳定的最终视觉规则；
生产状态、接入路径和下一门禁见 [PROGRESS.md](PROGRESS.md)。

## `QUEST.LOG.SHELL`

按 `L` 打开的 Quest Log 是从内部观看、可翻页的厚重公会卷宗：左右两页来自
同一批旧羊皮纸，近等宽，中央是自然凹陷页沟和少量离散装订回路；页叠、旧皮革
书体、暗旧黄铜与接触阴影共同形成重量。视角必须像书已在玩家面前打开，不能把
外侧封脊压在页面上，也不能出现无法翻页的夹死结构。

accepted source 为
[`QuestLogBookShell_Master_v1.png`](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png)。
runtime 固定显示 `676×464 UI px`，不得独立拉伸、镜像或重画。SHELL 必须是
空书体，不烘焙任务名、正文、奖励、按钮、页码、选择状态或滚动状态。

## 左右纸页与页沟

`LIST.PAPER`、`DETAIL.PAPER` 与 `GUTTER.*` 是同一 SHELL 的逻辑安全区，不是
独立可加载背景。纸面保持低频、安静、可承载高密度文字；左右页的综合色、纤维、
污渍尺度和左上暖光连续。中央缝线必须短、离散、受力方向合理并自然进入页叠，
不得出现独立木条、织带拉链、外置封脊、孔环、绳结或高频压花。

左页不再增加独立内框、地区底板或逐任务底板，直接露出连续纸面。活动列表固定
十八行，每行 `246×18 UI px`；任务与状态 FontString 使用 `pfUI.font_default`
`12px`，无 `OUTLINE`、无 shadow。五档难度色保持深红／棕／赭／绿／灰的香草
语义并达到足够对比；任务类型为深紫墨，完成／失败为深绿／深红，禁止荧亮色。

`REGION.TOGGLE` 使用深乌棕手绘三角墨箭头；`LIST.CHECK` 使用开放墨圈与粗短
墨勾。它们是无金属底座、无方形 checkbox 的低分辨率香草 sprite。任务行末端
追踪圈当前隐藏。accepted 暗酒红织物选择书签 source 仍保留，但 runtime 隐藏；
恢复前需重新确认。类型／计时／状态章当前暂停，不能从旧失败稿裁切。

## Quest Log／Tracker 共用漆章

两处共用同一枚“远征公会工具漆章”：低饱和暗旧酒红蜡、深乌棕浅压印、左上
短暖光、少量与蜡体连续的受压扩散，以及粗短四向罗盘叠一笔斜向羽毛笔。必须
读成 2004 年前后香草魔兽二维手绘 sprite，而非现代圆 icon、金属勋章、宝石、
照片级蜡封或暗黑祭坛。漆章本体不含文字、阵营徽记、完成／失败符号、内建丝带、
火焰、书页或书封。

accepted source 为
[`QuestToolWaxSeal_Master_v1.png`](../../../assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png)；
四态由同一 Alpha 确定性派生。Quest Log 以 `32px` 使用，Tracker 以 `34px`
使用；当前均为无鼠标 Texture。

## Quest Log 火漆事务载体

闭合态火漆位于右页详情 ScrollChild 右上，必须真实压住其下方载体，并随正文
滚动、由真实 viewport 裁切。载体是一条较窄、略有挺度的烟熏旧骨褐誓约纸／
粗纤维亚麻混合物：宽阔低频手绘面、不对称大褶皱、安静中央区、非周期边缘，
尾端约五个长短和深浅不等的锋利撕裂点。禁止规则锯齿、同长排穗、深 V、对称
鱼尾、流苏、现代工具条、压花壁纸或近黑软布。

accepted source 为
[`QuestLogSealPurityRibbon_Master_v1.png`](../../../assets/source/quests/qs-b1/QuestLogSealPurityRibbon_Master_v1.png)；
runtime 只允许整幅等比缩为 `32×192`，使用连续 prefix 与固定 tail 采样。
载体无鼠标，不含纹章、文字、状态或功能含义；不得平铺、镜像、非等比拉伸或
把蜡色复制进布面。

未来七项功能纹章必须各自为独立透明 source 并叠在同一可伸缩载体上：分享
（双羽笔／结约）、详情（折页）、显示（开放罗盘）、隐藏（遮蔽罗盘）、清理
（三道地图线）、重置（回环路线结）、放弃（断裂契约线）。普通六项使用哑光、
低饱和旧赭金矿物颜料；放弃项使用灰暗旧酒红。每枚允许粗笔画、局部缺料、
轻微渗化和 `±1px` 重心偏差，禁止现代矢量工具栏、规则卡片、完整金框、逐项
铆钉、发光、骷髅、双头鹰或其他 IP 阵营符号。

每个纹章对应独立真实 Button；hidden 项从排列移除并收拢背景，disabled 项留位
退色且禁用命中。动态名称、Tooltip、确认和点击仍由 provider 持有。七项代理
没有达到功能等价前，旧按钮必须保持可见可用，火漆不得获得菜单 hitbox。

## ScrollBar 与操作 Button

左右书页隐藏滚动轨道、滑块与上下箭头，但保留真实 ScrollFrame、offset、裁切、
滚动范围与鼠标滚轮。Collapse All 完整隐藏并禁用，不生产替代装饰。

放弃、分享、退出、详情开合及 pfQuest 操作在事务菜单完成前使用程序化暗旧
皮革 fallback。未来视觉只能代理原 Button，不得复制任务业务逻辑或绕过放弃
确认。关闭按钮、等级／追踪墨圈及所有真实命中区仍是独立组件。

## 奖励槽与分隔

每个 `QuestLogItem` 是一枚后补军需装备签：左侧非镜像粗裁深胡桃皮革补片压住
右侧烟熏撕边羊皮纸名签，接缝只出现少量长短／角度／间距不等的手扎与两处
错位暗铜固定痕。整体必须手绘、潦草而可读，禁止闭合金属框、镜像削角、规则
轨道、等距装饰和现代 HUD 卡槽。

accepted source 为
[`QuestLogRewardSlot_Master_v1.png`](../../../assets/source/quests/ql-d/QuestLogRewardSlot_Master_v1.png)。
runtime `108×41px`，图标安静区 `[4,4,37,37]`，名称区
`[41,4,105,37]`；normal／hover／pressed／disabled 共用同一 Alpha，pressed
只产生 `1px` 运行时压入。物品图标、数量、名称、品质色与 Tooltip 永远动态，
不得烘焙。双列槽之间保留 `8px`，行距 `4px`。

分隔线只允许用低对比深墨、断续短线表达内容层级，不切断整页，不增加第二层
容器或现代 section header。

## Quest Tracker

Tracker 是从公会卷宗抽出的纵向行军便笺：连续、可延展的安静暖赭纸面、少量
错层页边和自然撕裂底边。它共享 Quest 的纸张、墨色、旧酒红和香草手绘笔触，
但不能变成双页书、聊天旧书、透明黑 HUD、现代卡片列或金属祭坛。

纸面必须严格服务真实 `pfQuestMapTracker` live Frame，不增加外置书框、装饰
端帽、页叠轮廓或投影。`TOP／MIDDLE／BOTTOM／EDGE` 组成可变宽高切片；多个
任务共享一张连续纸，不生成逐项卡片，也不烘焙任务名、目标、百分比、图标或
按钮。当前临时纸面不是最终美术；重新生产前必须先测量真实区域并确认简单几何
预演。

任务名沿用 pfUI／pfQuest 字体和动态字号，无描边／shadow；难度墨色与 Quest
Log 共用 resolver。目标用缩进和行距表达层级。聚焦态只能是边缘自然消散的
淡墨洗，tracked 是克制页边墨记，complete 是小型深墨勾。彩色点／问号隐藏且
不生成替代。

七个工具 Button 的新视觉当前 deferred；provider 对象、状态、Tooltip、脚本、
拖动、三种模式和最多二十五条动态内容必须保留。provider 没有可靠公开的折叠、
timer 或 failed 状态时，不生成假控件或假状态。

## NPC Quest／Gossip

`QuestFrame`、`GossipFrame`、五内容面板、滚动条、八个操作 Button、委托物品与
奖励流程已映射但尚未锁定美术。当前完整保留 pfUI／原生视觉和行为。未来方向
应是公会正式委托文书，与个人 Quest Log 同族但更庄重；开始前必须重新取得实机
几何和用户确认，不能直接复用 Tracker 或 Quest Log 整图。
