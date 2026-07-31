# Quests 子模块美术基线 Prompt

以下 Prompt 全部继承 [Quests 主模块](ART_BASELINE.md) 与
[全局基线](../../GLOBAL_ART_BASELINE.md)，并受
[真实子模块合同](SUBMODULES.md)约束。

## `QUEST.LOG.SHELL`／QL-A1

生成一册正对玩家、轻微内部俯视、打开的空公会任务卷宗结构母版。使用厚实的
暗酒红／深胡桃旧皮革封皮、克制旧黄铜包角、外围多层纸页和接近等宽的左右
暖赭纸面。第一眼必须是香草魔兽公会任务簿，不是现代棕色面板、聊天旧书、
照片级古董或暗黑祭坛。

保持 2004 年前后香草魔兽二维手绘位图：粗厚略不规则轮廓、明确明暗切面、
略夸张实体厚度、左上暖光和低饱和暖色。左右纸页中央保持连续安静，不生成
任务行、文字、按钮、滚动条、奖励槽、书签、页码或固定徽记。整图是高分辨率
结构 source；只能经 QL-A2 V4 的确定性等比缩放、透明 padding 和 TGA 转换
进入 runtime，原始高分辨率 PNG 不能由客户端直接加载。

已接受源：
[QuestLogBookShell_Master_v1.png](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png)，
manifest：
[QL-A1_SourceManifest_v1.json](../../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)。
固定执行器 `imagegen-0-143-0`，会话
`019fac35-620b-78d3-8b46-2e1f02105f74`，接受日期 `2026-07-29`。

## `LIST.PAPER`／`DETAIL.PAPER`／`GUTTER.*` — QL-A2 V4

这些固定结构已经由 QL-A1 的空卷宗 source 持有，不再作为独立生图对象。
左右同高近等宽纸页、自然内缘、凹陷页沟、离散短装订回路与装订端部共同
属于 `QUEST.LOG.SHELL` 的静态像素；固定显示尺寸为 `676 × 464`，不得
单独拉伸、重复、镜像或自由重画。

左右阅读区仍必须表现为同一纸张批次的连续安静纸面。`LIST.PAPER` 与
`DETAIL.PAPER` 仅定义真实 ScrollFrame 的安全区；`GUTTER.*` 仅保留逻辑
provenance。所有任务行、正文、按钮、滚动条、奖励槽和交互状态继续由独立
运行时对象持有。禁止重新引入外置封脊、织纹竖条、木质针脚、装饰绳结、
独立纸条、拉链、孔环、横向把手或满页高频压花。

导出与尚未实机验收的状态记录在
[work/QUEST.LOG.GUTTER.md](work/QUEST.LOG.GUTTER.md)；固定导出不得调用
ImageGen。

## 左页目录状态

目录纸面保持连续，不生成逐行卡片，指的是不得制作现代悬浮卡片或把完整列表
烘焙成一张背景；它不再排除与真实 `QuestLogTitleN` 一一对应的薄型卷宗
底板。Turtle WoW 实机证明旧 23 行纯文字方案无法呈现锁定基准中的左页身份，
因此 V2 使用十八行、每行 `224 × 18 UI px` 的真实 Button 窗口。

`QUEST.LOG.LIST.INSET` 不再是独立美术对象。完整重启后的实机图证明 QL-A2
连续纸面与十八行布局本身稳定；用户在四次候选审查后明确移除额外内框。
左页继续直接露出 QL-A2 纸面，后续不得自行补回皮革内框、纸内框、阴影框、
占位 Texture 或假命中层；若要重开，必须由用户重新建立范围与合同。

`QUEST.LOG.REGION.BACKPLATE` 是低饱和暗橄榄公会目录条；
`QUEST.LOG.ROW.BACKPLATE` 是更浅、更薄的暖赭卷宗条目。两者继承锁定图中
粗厚、不完全规整的手绘边缘和不均匀磨损，但中央保持低对比以承载动态文字。
它们各只生成一枚基础物件，normal／hover／pressed／disabled 由同一轮廓和
Alpha 确定性派生；不得连接成围绕整张列表的第二层框，也不得烘焙文字、
等级、计数、墨记、书签、状态章、选择层、Button 命中区、滚动条、肖像或
假图标槽。完整 V2 合同与仍有效的 B 自包含正文见
[work/QUEST.LOG.LEFTPAGE.md](work/QUEST.LOG.LEFTPAGE.md)。

`QUEST.LOG.REGION.TOGGLE` 使用同一枚深乌棕手绘三角墨箭头：collapsed 向右、
expanded 向下。`QUEST.LOG.LIST.CHECK` 使用同一枚开放墨圈：untracked
为空圈，tracked 只增加一笔粗短墨勾。它们都是正面、低分辨率友好的
2004 年前后香草魔兽二维手绘 sprite，无金属底座、无方形 checkbox、无
`+`／`-` 字符、无独立命中区。

`QUEST.LOG.SELECTION` 使用从左页外缘水平探入当前行的暗酒红窄织物书签舌，
不铺满整行。它是贴纸面的厚旧布短舌：左端像仍压在纸缘下，右端柔软收口而
不形成箭头、燕尾旗、标签牌或按钮；无黄铜、扣环、文字和高频刺绣。只生成
一枚基础 source；选中、选中悬停、选中按下由同一 Alpha 确定性派生，只改变
受光、色重与运行时 `1px` 压入，不改变轮廓、磨损位置和物件身份。当前完整
生产正文与真实排版验收合同见
[work/QUEST.LOG.SELECTION.md](work/QUEST.LOG.SELECTION.md)。

用户于 `2026-07-30` 接受 QL-B2 V1.r4 bbox-fit 候选及一次性确定性 source
合同例外。最终美术母版为
[QuestLogSelectionBookmark_Master_v1.png](../../../assets/source/quests/ql-b2/QuestLogSelectionBookmark_Master_v1.png)；
它保留第五次候选的同一剪影、材料、综合色和磨损，只把可见 Alpha bbox
等比缩入冻结安全盒并清理低 Alpha 绿色边缘。该接受不把原始 raw 的安全盒
与纯色键失败改写成通过，也不允许后续自由修图；三态只能按 source manifest
声明的固定 RGB 公式与同一 Alpha 导出。

确定性 runtime 已记录在
[QL-B2_RuntimeManifest_v1.json](../../../assets/source/quests/ql-b2/QL-B2_RuntimeManifest_v1.json)：
三态从同一 `24 × 14` 像素 Alpha 派生并装入 `128 × 16` atlas，第四格
保持全透明；selected-hover 只暖亮，selected-pressed 只压暗，`1px`
下移只在 adapter 锚点发生。三张 `676 × 464` 真实排版预演来自最终 atlas，
未完成的 QL-B3／C／D 仍明确为非权威 fallback。用户于 `2026-07-31`
认为酒红书签的当前游戏内效果不佳，因此自 runtime contract `1.5` 起暂停挂载；
这不撤销已接受 source，也不授权删除或重新生成，恢复显示前需再次确认。

`QUEST.LOG.TYPE.BADGE` 只为客户端可靠返回的 Elite、Dungeon、Raid、PvP
制作同一深乌棕旧墨家族的克制无底座压印：三尖精锐纹章、粗短石门、
三面行军旗与交叉短剑；normal 与未知 tag 不显示资产。
`QUEST.LOG.TIMER.BADGE` 由计时 API 独立驱动，使用同线重的小型沙漏压印，
不能冒充 questTag 或烘焙倒计时。`QUEST.LOG.STATE.SEAL` 使用 Image 1
页脚旧蜡材质的微型化转译：同一枚暗酒红封印的完整／沿物理裂缝破裂两态，
不使用现代绿色勾／红色叉。三类分别以 `10px`／`10px`／`12px` 显示，
固定并列且可以同时出现；不使用单槽优先级。所有覆盖层真透明、无文字、
无鼠标，并只绑定 [SUBMODULES.md](SUBMODULES.md) 声明的真实语义；任务名称、
等级、数量和本地化标签永远动态。当前完整三段生产合同见
[work/QUEST.LOG.STATUS.md](work/QUEST.LOG.STATUS.md)。

QL-B1 V1 的完整五次执行、内部退回和用户覆盖性接受记录在
[work/QUEST.LOG.DIRECTORY.md](work/QUEST.LOG.DIRECTORY.md)。用户于
`2026-07-30` 接受 V1.r3 在 `12px`／`10px` 下的运行时视觉；透明母版与
provenance 位于
[QL-B1_SourceManifest_v1.json](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)。
像素级旋转同源、完全相同外圈、源安全盒和 raw 精确纯绿色仍作为历史生产
偏差保留，不被改写为通过；它们不再阻塞已授权的逐格裁切、等比缩放、居中
与 Alpha 清理。确定性 runtime 与 UV 记录在
[QL-B1_RuntimeManifest_v1.json](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)；
23 行真实密度预演与接入状态作为 V1 历史继续记录在 work；V2 采用
`18 × 18` 排版，并只对已接受的 QL-B1／B2 source 做确定性尺寸重导出。
QL-B3 继续暂停，不能从概念图或未接受候选直接裁切。

## ScrollBar 与操作 Button

左页列表滚动仍可使用嵌在页边的窄装订槽与小型黄铜页夹；右页书本正文不显示
轨道、滑块或上下箭头，阅读改由纸面 `ScrollFrame` 的鼠标滚轮完成。隐藏的是
chrome，不是 ScrollFrame、裁切、滚动范围或任务详情数据。

顶部 Collapse All 不再呈现：真实 Button 与 pfUI `+`／`-` 子控件完整隐藏
并禁用，不生产替代按钮或装饰。“任务：N/20”只使用同族深墨字体，不增加
牌匾或第二层框。等级与追踪控件复用已接受 QL-B1 开放墨圈／墨勾 atlas，
不另造 checkbox 外壳。

底部放弃／分享／退出与详情开合均保留真实 Button 和原脚本，使用程序化暗旧
皮革搭扣：暖旧铜色上／左薄边、深色下／右阴影、克制 hover、压暗 pressed
与退灰 disabled；文字由客户端绘制。不得增加整条底框、现代矩形按钮、细金框、
常亮高光或烘焙文字。该轮只使用确定性运行时 Texture 色块，不调用 ImageGen，
也不产生新的 bitmap 资产。

## 奖励槽与分隔

奖励槽使用深皮革凹面、克制黄铜外沿和纸面接触阴影；物品图标、数量、名称与
品质色均为 runtime。Quest Log 奖励只读，不提供 selected 状态。分区墨线为
无命中的三段式短线，不切断整张右页。

## Quest Tracker

provider 已锁定为 `pfQuest 7.0.1` 的 `pfQuestMapTracker`。稳定视觉基线
仍是纵向行军便笺：连续可延展的安静暖赭纸面、独立错层页边和自然撕裂底边。
它与 Quest Log 共享公会卷宗的纸张、墨迹、暗酒红、克制旧黄铜、左上暖光和
2004 年前后香草魔兽二维手绘笔触，但轮廓必须是从卷宗中抽出的单张野外便笺，
不能变成双页书、聊天旧书、透明黑色 HUD、现代卡片列或暗黑式金属祭坛。

`QUEST.TRACKER.PAPER.TOP`／`MIDDLE`／`BOTTOM`／`EDGE` 必须组成可横向适配
`130..330 UI px`、可纵向适配任意条目高度的切片系统。顶部和撕裂底边采用
左右端帽加可延展中段；纸面中部使用安静、低对比、无方向性接缝的可平铺／
拉伸中心和独立页边。多个任务共享一张连续纸，不制作逐项卡片、逐项皮框、
固定高度背景，也不在任何切片中烘焙任务名、等级、目标、百分比、节点图标、
按钮或空状态。

`QUEST.TRACKER.HEADER.STRAP`、`HEADER.EMBLEM` 与七个工具 Button 的逻辑 ID
继续保留，但视觉基线尚未冻结，QT-A2 当前为 `scope-deferred`。本轮不创建
它们的 Prompt、source、runtime 或 adapter，也不以 tracker 主体预演替代
按钮评审。provider 的现有对象、状态、Tooltip、脚本和模式行为必须保留。
未来恢复时需从主模块基线重新提出有独立 cell／UV 的组件方案，并完成新的
本地几何预演和生产授权。

`QUEST.TRACKER.ENTRY.FOCUS` 是可横向延展、边缘自然消散的淡墨洗，不形成卡片
边框。`ENTRY.TRACKED` 是克制的暗酒红页边短墨记，`ENTRY.COMPLETE` 是小型
深墨勾；二者均为无鼠标覆盖，不能遮挡 provider 的动态 `button.icon`、
`button.text` 或 `button.objectives[i]`。任务名、目标、等级、完成率与数字
继续由客户端排版；目标使用缩进和行距表达层级，不加独立底板。

当前 provider 没有公开的折叠状态对象，也没有 tracker timer／failed 状态。
因此本轮不生成折叠 Button、沙漏或失败蜡封，不把 Quest Log 的 B3 状态章
移植过来。聚焦 tracker 主体的 `QT-SIM V2` 本地几何 specification、QT-A1／
B1 完整可授权生产正文与真实排版验收合同均位于
[work/QUEST.TRACKER.CORE.md](work/QUEST.TRACKER.CORE.md)。用户已于
`2026-07-31` 确认 `QT-SIM V2` 的主体方向；模拟 ImageGen 固定 `0/0`。
用户随后于 `2026-07-31` 独立授权 QT-A1／B1 V1 的最终正文、固定
Image 1／2／3、同段前次输出的冻结边界 edit 和每段最多 `5` 次实际
ImageGen 调用。QT-A1 五次循环已耗尽：attempt 4 的宽缓纸面是本机最佳美术
证据，但 raw bbox 与 native 纯色键仍失败；attempt 5 又重绘出压花式中心
纹理，终态为 `candidate-rejected / repair-budget-exhausted / 5/5`，没有
source/runtime。QT-B1 attempt 1 已确认三件对象身份，但因 cell 越界、
focus 绿边／综合色和 native 色键失败成为
`internal-rejected / repair-prepared 1/5`；QT-A2 保持
`scope-deferred 0/5`。生产内审通过也不自动创建 adapter、source 或 runtime
媒体。

## NPC Quest／Gossip

当前没有美术基线 Prompt。未来必须在保留 `QuestFrame`／`GossipFrame`
肖像、五类正文面板、二十个滚动绑定、八个真实操作 Button 和四类物品／奖励
对象的前提下，单独锁定“NPC 委托文书”方向。不得从完整 Quest Log 背景直接
裁切，也不得用一张图替代真实按钮。

## 历史收敛

QL-A2 V1、V2.1、V3 与 V3.1 均已退回。当前树不再保存每次尝试的独立 Prompt；
可复用结论已进入当前 work 文件，完整执行正文、会话和 diff 保留在 Git
历史。任何新尝试都必须从锁定任务基准与本文件重新继承，不上传失败候选。
