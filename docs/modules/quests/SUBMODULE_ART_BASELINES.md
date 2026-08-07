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

导出与 `2026-08-05` 用户实机确认状态记录在
[work/QUEST.LOG.GUTTER.md](work/QUEST.LOG.GUTTER.md)；固定导出不得调用
ImageGen。

## 左页目录状态

目录纸面保持连续，不生成逐行卡片，指的是不得制作现代悬浮卡片或把完整列表
烘焙成一张背景；它不再排除与真实 `QuestLogTitleN` 一一对应的薄型卷宗
底板。Turtle WoW 实机证明旧 23 行纯文字方案无法呈现锁定基准中的左页身份，
因此 V2 使用十八行、每行 `246 × 18 UI px` 的真实 Button 窗口；隐藏页边
scrollbar chrome 后使用完整左页宽度。全部任务名、地区名以及完成／地下城等
状态 FontString 继承 `pfUI.font_default` 的统一界面字体，固定 `12px` 并使用
空 flags；不再强制霞鹜文楷，也不得用 `OUTLINE` 或 shadow 模拟字重。
字体 shadow 颜色与偏移都清零，清晰度由字体本身和高对比深墨承担。五档任务
难度色在实机代表深纸面
`#B08444` 上须保持约 `4.5:1` 或更高的正文对比，同时保留红／棕／赭／绿／
灰的色相区分。任务类型使用深紫墨，完成／失败使用独立深绿／深红；禁止
荧亮黄、发光色或与纸面明度接近的浅橄榄色。模板拆分与内联状态文字遵守
同一规则，不得绕开共用主题。

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
`+`／`-` 字符、无独立命中区。墨圈 source 继续用于顶部真实 CheckButton；
按 `2026-08-01` 用户决定，任务行末端不再显示 untracked／tracked 圈，也不
生成替代符号。

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

## Quest Log／Tracker 共用工具漆章

`QUEST.LOG.CHROME.SEAL` 与 `QUEST.TRACKER.HUB.SEAL` 共用 QS-A1 V1.r4 的
同一枚“远征公会工具漆章”：低饱和暗旧酒红蜡体、深乌棕浅压印、左上短暖光、
少量与主体连续的受压火漆扩散，以及粗短四向罗盘叠加一笔斜向羽毛笔。必须
继续读取为 2004 年前后香草魔兽二维手绘 sprite，而不是现代圆 icon、金属
勋章、宝石、照片级蜡封或暗黑式祭坛。无文字、阵营徽记、任务完成／失败符号、
发光符文、内建丝带、火焰、书页、书封或额外承载面；这里的“无丝带”只约束
QS-A1 漆章母版本身，不禁止 QS-B1 以独立组件在蜡体下装配授印绶带。

用户于 `2026-07-31` 接受 V1.r4 的运行时视觉，并授权原始 provider
`1254²`／渐变绿输出经过确定性色键、透明 RGB 清零与 `1024²` 等比归一化
进入 P4／P5；这些历史 raw 失败不改写为通过。最终透明 source、接受原文、
固定执行器／会话、raw／candidate SHA、Prompt、两张锁定视觉参考和禁止用途
见
[QS-A1_SourceManifest_v1.json](../../../assets/source/quests/qs-a1/QS-A1_SourceManifest_v1.json)。
tracked source 为
[QuestToolWaxSeal_Master_v1.png](../../../assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png)，
SHA-256
`377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75`；
`1024 × 1024 RGBA`、可见 bbox `[192,200,832,824]`、可见绿色残留 `0`，
全透明像素的 RGB 全为 `0`。

确定性 runtime 见
[QS-A1_RuntimeManifest_v1.json](../../../assets/source/quests/qs-a1/QS-A1_RuntimeManifest_v1.json)：
同一 Alpha 等比缩为 `60 × 58`，居中放入 normal／hover／pressed／disabled
四个 `64 × 64` cell；hover 只暖亮，pressed 只压暗且未来交互锚点下移
`1px`，disabled 只退灰，四态不重画轮廓。当前 Quest Log runtime `1.19` 以
`32px` 显示 accepted QS-A1 漆章，并直接压在详情页右上纸面；`40px` 保留区
不得承载标题、正文或奖励。Tracker 以 `34px` 位于顶部中央；两处当前均只
使用 normal 无鼠标 Texture。旧七个 provider Button 在 hub menu 取得一一
功能等价前继续可见可用，不能为了纯净构图提前隐藏。

## ScrollBar 与操作 Button

左右书页都不显示滚动轨道、滑块或上下箭头，阅读改由纸面真实
`ScrollFrame` 的鼠标滚轮完成。隐藏的是 chrome，不是 ScrollFrame、
FauxScrollFrame offset、裁切、滚动范围或任务详情数据；也不以新装订槽、
页夹或装饰符号替代滚动条。

顶部 Collapse All 不再呈现：真实 Button 与 pfUI `+`／`-` 子控件完整隐藏
并禁用，不生产替代按钮或装饰。“任务：N/20”只使用同族深墨字体，不增加
牌匾或第二层框。等级与追踪控件复用已接受 QL-B1 开放墨圈／墨勾 atlas，
不另造 checkbox 外壳。

底部放弃／分享／退出、详情开合与 pfQuest 四个地图操作在火漆事务菜单取得
完整功能等价前仍保留真实 Button 和原脚本，使用程序化暗旧皮革搭扣作为
fail-open fallback。目标交互只允许由火漆入口代理原 Button；不得复制任务
业务逻辑、绕过放弃确认或在 provider 尚未捕获时提前隐藏 fallback。Quest Log
入口仍直接压在现有详情页右上纸面，不能附着书框、护轨、包角、虚构封面或
悬空充当红色图标。V11 已冻结漆章与菜单共同挂到右页
`QuestLogDetailScrollChild` 的物理关系：scroll `0` 时保持现有
`[576,68,32,32]` 可见位置，收起态只在蜡体下露出 `6px` 空白布根；展开态向下
形成 `32×22px` 行节距的“远征公会授印绶带”，随后与正文一起滚动并由真实
viewport 裁切。绶带不能形成页外书签、第二纸面、共享 popup、书框或常驻侧栏。

V2 将背景和七枚纹章烘焙进一张连续母版，四次实际生成仍表现为低质、均匀、
过度工整的压纹布条，并阻止按配置独立隐藏功能。用户于 `2026-08-05` 在第
`4/5` 次后明确改向；V2 attempt 5 未调用，旧剩余额度与候选不得转入 V3。
V3 必须把“连续背景”和“功能纹章”分为两种资产所有权：背景只是一条无鼠标、
无功能含义的连续最大长度空白布母版；runtime 按 visible count 裁取其前缀并
接独立 tail，不再以三个 body variant 重复拼接。七个功能各有一张透明纹章
source，并各由一个真实 Button 独立叠放。runtime 可将七张纹章确定性打包
atlas，但不得合并 UV、Button 或 manifest ID，也不得把纹章重新烘焙进背景。

背景材料冻结为厚实、柔软、做旧的远征公会誓约亚麻布。经 V13 方向确认后，
该小面积功能承载物不再使用暖亮赭布，而以低饱和烟熏深旧棕、暗胡桃和深褐
阴影作为卷宗上的厚重暗色点缀；禁止金黄、橙亮、象牙白、全长亮边或庆典色。
质感必须由宽而低频的不对称褶皱、三块大明暗、两段断续暗亮面、少量跨段低
对比非周期污渍、手裁边缘偏差和稀疏受力磨损构成；中央保持哑光、安静、厚重。
左右边只允许少量宽幅、互不镜像且不对齐 `22px` 节距的非周期偏移；尾端恰好
两处不等宽、粗钝、浅上收缺口。禁止满幅均匀颗粒、程序化微型织纹、压花
壁纸、相同斑点按 `22px` 节距重复、等距波浪、锯齿、流苏、同长排穗、深 V、
对称鱼尾、全长平直高光或左右精确镜像。最大长度母版的明暗和纤维必须从 root
连续流到 tail；八个可能裁取坐标附近不得出现强横折、裂口、亮线或边缘突变。
任意长度都不得看见横缝、七格卡片或复制粘贴节奏。不规则必须保留克制：仍是
一条可弯曲的旧布，而非碎布、旗穗、破洞网或随机噪声。

七张独立纹章依次为双羽笔／结约、折页、公会罗盘、遮蔽罗盘、清扫地图线、
回环路线结和断裂契约线。普通六项使用哑光、低饱和的旧赭金矿物公会颜料：
它在已接受烟熏深旧棕布底上必须清楚可读，但仍保持泥土感、厚重和克制，禁止
金属金、亮黄、橙亮、象牙白或发光；只有放弃任务使用灰暗、退饱和的旧酒红。
每枚采用少量粗笔画、局部缺料、轻微渗化、非恒定线宽和独立 `±1px` 视觉重心
偏移。禁止七枚同尺寸、同中心、同笔压的精确图标柱，也禁止现代微型 icon、
矢量工具栏、规则卡片、圆角、完整金框、逐项铆钉、玻璃、霓虹、科幻金属、
骷髅、双头鹰或任何战锤帝国符号。可以借用“蜡封压住垂直誓约带”的物理逻辑，
但必须第一眼仍属于 2004 年前后艾泽拉斯公会文书，而不是复制其他 IP。

展开时背景与纹章只临时覆盖正文最右 `14..24px`，不得改变既有 `214px` 正文
宽度、`204px` 缩进宽度或触发绕排；七项全显时尾端必须在真实 `108×41px`
奖励槽前至少留 `32px`。hidden 项从 visible order 中移除，背景与其余 Button
无空洞收拢；disabled 项留位、退色并禁用命中。动态名称、enabled、Tooltip、
原生确认与点击逻辑仍由游戏／provider 持有。部分裁切 Button 不得留下不可见
的完整 hitbox，完全滚出时命中数必须为零。用户于 `2026-08-05` 回复“可以”，
确认 V12 的 V3 几何、层序、动态收拢和分层资产方向；模拟像素仍非 source 或
ImageGen 输入。V3-A 五次候选随后因连续微纹、比例误差、规则切口与亮色轻浮
被否决；V3-B 未执行。用户于 `2026-08-05` 又确认 V13 的暗色、非周期宽边与
双钝缺口 V4-A 方向；V13 像素仍非 source 或 ImageGen 输入。V4-A 随后在
固定 Image 1／2 与冻结边界内执行至 `5/5`；第五稿的暗色宽面、非周期边和
双缺口最接近 V13，但 raw `176×892px` 相对目标比例误差仍为 `7.287%`，超过
授权 `≤1%`，因此为 `candidate-rejected / repair-budget-exhausted / P3`。
它不构成新的稳定 source 美术基线；V1、V2、V3、V4-A 失败候选和 V10–V13
模拟均不得成为后续 edit input、source、runtime 或未授权的确定性美术例外。
V5-A 改由 ImageGen 只提供全幅连续布面 donor，tracked V14 固定 crop／`4×`
polygon mask 独占最终 `128×696` 轮廓、Alpha 与两处不等宽钝浅缺口。用户于
`2026-08-06` 明确接受 attempt 4 deterministic composite；最终稳定空白布底
source 为
[QuestLogSealMenuSubstrate_Master_v1.png](../../../assets/source/quests/qs-b1/QuestLogSealMenuSubstrate_Master_v1.png)，
SHA-256 `6b3207f15d96…11d9c`，manifest 为
[QS-B1_SourceManifest_v1.json](../../../assets/source/quests/qs-b1/QS-B1_SourceManifest_v1.json)。
它冻结低饱和烟熏深旧棕、三块低频明暗、外侧宽折、中央安静区、连续非周期
布面和双钝缺口；不接受 raw donor，也不接受七枚功能纹章、Button、文字、
状态或 runtime。后续只允许按 manifest 等比缩为 `32×174`，按动态前缀加固定
tail 装配，不得 bbox-fit、非等比拉伸、平铺、镜像、重绘或把纹章烘焙回背景。
该 exact source 的历史接受与可恢复性继续有效，但用户于 `2026-08-06` 的最新
复审已取代它作为目标可见方向：火漆必须在层序、宽度和接触区上明确跨压载体，
不得悬浮在其上方；载体不得再读成近黑软布或现代工具条，而应转为较窄、略有
挺度的烟熏旧骨褐誓约纸／粗纤维亚麻混合物；尾端必须是约五个长短、深浅不一
的尖锐撕裂点，禁止双钝缺口、等距锯齿、对称鱼尾和流苏。只借用“蜡封固定
誓约载体”的物理语法，禁止战锤阵营符号、双头鹰、骷髅、经文或科幻金属。
用户于 `2026-08-06` 回复“确认”，接受
`QUEST-LOG-SEAL-PURITY-RIBBON-SIM-V17` 的新综合色、装配和尖锐非周期尾端
方向。该确认只冻结文字化可见条款；模拟像素和确切 RGB 不是稳定 source。
V7-A production 只生成连续材质 donor，由 tracked `128×768` mask 独占
轮廓／Alpha，并由 accepted QS-A1 Alpha 确定性形成接触压暗。用户随后于
`2026-08-06` 独立授权该最终正文与最多五次实际 ImageGen 调用，并于
`2026-08-07` 明确接受 attempt 5 的运行时视觉、source/runtime 导出与 addon
接入。稳定 source 为
[`QuestLogSealPurityRibbon_Master_v1.png`](../../../assets/source/quests/qs-b1/QuestLogSealPurityRibbon_Master_v1.png)，
SHA-256 `168f527f…05b8`；它冻结较窄、略挺、灰暗旧骨褐誓约纸／粗纤维亚麻
混合物的宽阔低频手绘面、不等距尖锐撕裂 tail，以及由 QS-A1 Alpha 形成但不
复制蜡色的接触压暗。runtime 只允许整幅等比缩至 `32×192`、透明 RGB 清零与
连续 prefix＋固定 `14px` tail 采样；禁止 bbox-fit、拉伸、平铺、镜像、重绘、
烘焙纹章或给予载体鼠标。V5-A bytes 作为历史 fallback 保留，不再是当前目标
方向；七枚功能纹章仍未形成稳定 source，不能从 V6 失败候选或模拟像素继承。
用户于 `2026-08-06` 回复“接受”，确认 V15 在该 accepted 深布上采用“普通
六项旧赭金矿物颜料＋放弃项灰暗酒红”的综合色方向。该确认只冻结上述颜色
角色、低饱和厚重感与四态关系；V15 本地几何纹章像素、确切 RGB、边缘、
缺料和 Alpha 均非 source 或未来 edit input。V5-B 正式提示词必须重新继承
全局／Quest／本节基线，并保持七张独立 source、七个独立 Button 与动态
hidden／disabled／滚动合同。
`QS-B1 V1` 的五次候选仍保持历史结论：用户于 `2026-08-05` 明确判定“不可接受”，
不得成为 V2 edit input；该结论不会因 V3 改向而重写。

## 奖励槽与分隔

奖励槽必须使用香草魔兽式粗颗粒手绘和受控不规整材料搭接；不得再使用完整
皮革／金属闭合框、镜像削角、等距装饰或现代 HUD 轨道。外缘可以潦草、错位、
断续，但图标与名称承载面必须安静。物品图标、数量、名称与品质色均为
runtime。Quest Log 奖励只读，不提供 selected 状态。右页双列
每格最大 `108px`，名称安全宽 `64px`；正文换行后必须按实际最底部可见对象
和原生 `QuestLogSpacerFrame` 末端哨兵重算 ScrollChild 高度，不能用固定
`324px` 内容高裁掉奖励。内联“将得到／需要金钱”文字必须保持自动宽度，
不得把锚在其右侧的金额 Frame 推出纸页。分区墨线为
无命中的三段式短线，不切断整张右页。

用户曾于 `2026-08-07` 确认 `QL-D-SIM-V2` 并独立授权其 production，但在五次
循环结束后明确撤销该可见方向：即使削弱黄铜，完整规则外框仍“太规整、过于
现代”。当前稳定要求改为手绘／潦草并加强 RPG 沉浸感；“潦草”只作用于粗裁
轮廓、断续笔触、材料叠压、缝扎和错位固定痕，不能变成密集噪声、剪贴簿贴纸
或现代独立游戏速写卡。

用户于 `2026-08-07` 以 `QL-D-SIM-V3` 确认新 construction：每个真实
`QuestLogItem` 是一枚后补军需装备签；左侧非镜像粗裁深胡桃皮革补片压住
右侧烟熏撕边羊皮纸名签，接缝只出现三处长短／角度／间距不等的手扎，外缘
只有两处错位、近熏黑暗铜固定痕。禁止完整皮革／金属闭合框、镜像削角、规则
轨道和等距装饰；外缘可有约一至两个 runtime 像素的非周期手绘起伏，但
`[4,4,37,37]` 图标区和 `[41,4,105,37]` 名称区必须连续安静。四态共享同一
Alpha，只有 normal 由 ImageGen 生成。该确认只冻结可见文字条款，不接受模拟
像素、exact RGB、最终笔触或 Alpha；版本、授权、计数和审查只在
[work/QUEST.LOG.REWARDS.md](work/QUEST.LOG.REWARDS.md) 维护。

五次 V3 循环耗尽后，用户于 `2026-08-07` 明确选择第 4 稿。当前稳定 P4
source 因而冻结为 `QuestLogRewardSlot_Master_v1.png`（SHA
`816aeedd…47c5`）：粗裁深胡桃皮革补片压在低频烟熏纸签之上，接缝为不等
手扎与暗固定痕，整体比规则闭合框更潦草、更接近香草年代手绘装备签。该稿的
keyed aspect `2.7694524496` 超过原 `2.69` 上限，按一次性用户选稿例外保留
已经审阅的等比 `108×41px` 外观；禁止以此例外普遍放宽后续组件比例，也禁止
把原技术 `18/19` 改写为通过。四态必须从 exact source 按 manifest 公式派生，
Alpha 相同；不得非等比压缩、裁可见像素、重绘或把 live icon／count／name／
品质色烘焙进容器。

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
深墨勾；二者均为无鼠标覆盖，不能遮挡 `button.text` 或
`button.objectives[i]`。用户于 `2026-08-01` 明确移除条目左侧彩色点／问号，
因此 runtime 隐藏 `button.icon` 可见纹理但保留其 provider 数据，不生成替代
装饰。任务名、目标、等级、完成率与数字继续由客户端排版；Tracker 任务名
沿用 pfUI／pfQuest 配置的旧统一字体和动态字号，不使用描边或文字阴影；
其任务名难度墨色必须与 Quest Log 任务名调用同一个 resolver，完成率与
Quest Log 的完成／失败／地下城提示继续使用各自独立语义色，不能反向染色
任务名；所有任务与状态墨色同时继承左页的高对比深墨要求，不得在 Tracker
重新放亮；
目标使用缩进和行距表达层级，不加独立底板。

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
`scope-deferred / user-paused 1/5`，旧 V1.r1 不再执行。用户选择暂时只用
大块背景 tracker；attempt 4 的确定性 RGBA 按临时合同例外成为 QT-A1
source，并导出为九宫格 TGA。adapter 不创建三件 QT-B1 覆盖层，同时隐藏
provider 的现代半透明行矩形；QT-A2 保持 `scope-deferred 0/5`。

## NPC Quest／Gossip

当前没有美术基线 Prompt。未来必须在保留 `QuestFrame`／`GossipFrame`
肖像、五类正文面板、二十个滚动绑定、八个真实操作 Button 和四类物品／奖励
对象的前提下，单独锁定“NPC 委托文书”方向。不得从完整 Quest Log 背景直接
裁切，也不得用一张图替代真实按钮。

## 历史收敛

QL-A2 V1、V2.1、V3 与 V3.1 均已退回。当前树不再保存每次尝试的独立 Prompt；
可复用结论已进入当前 work 文件，完整执行正文、会话和 diff 保留在 Git
历史。任何新尝试都必须从锁定任务基准与本文件重新继承，不上传失败候选。
