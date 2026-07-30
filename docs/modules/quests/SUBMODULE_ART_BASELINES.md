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

目录纸面保持连续，不生成逐行卡片。23 个真实 `QuestLogTitleN` 保留整行
点击和 pfUI 的扩展显示数量；行本体只使用动态 FontString 色、顶点色与独立
覆盖，不生成现代矩形 hover card。

`QUEST.LOG.REGION.TOGGLE` 使用同一枚深乌棕手绘三角墨箭头：collapsed 向右、
expanded 向下。`QUEST.LOG.LIST.CHECK` 使用同一枚开放墨圈：untracked
为空圈，tracked 只增加一笔粗短墨勾。它们都是正面、低分辨率友好的
2004 年前后香草魔兽二维手绘 sprite，无金属底座、无方形 checkbox、无
`+`／`-` 字符、无独立命中区。

`QUEST.LOG.SELECTION` 使用从左页外缘探入当前行的暗酒红窄织物书签舌，不铺满
整行；选中、选中悬停、选中按下只改变受光、压入和色重，不改变物件身份。

`QUEST.LOG.TYPE.BADGE` 只为客户端可靠返回的 Elite、Dungeon、Raid、PvP
制作克制小压印；normal 与未知 tag 不显示资产。`QUEST.LOG.TIMER.BADGE`
由计时 API 独立驱动，使用小型沙漏压印，不能冒充 questTag。
`QUEST.LOG.STATE.SEAL` 用小型完整／破裂蜡封表达 complete／failed。所有覆盖层
真透明、无文字，并只绑定 [SUBMODULES.md](SUBMODULES.md) 声明的真实语义；
任务名称、等级、数量和本地化标签永远动态。

QL-B1 V1 的完整五次执行、内部退回和用户覆盖性接受记录在
[work/QUEST.LOG.DIRECTORY.md](work/QUEST.LOG.DIRECTORY.md)。用户于
`2026-07-30` 接受 V1.r3 在 `12px`／`10px` 下的运行时视觉；透明母版与
provenance 位于
[QL-B1_SourceManifest_v1.json](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)。
像素级旋转同源、完全相同外圈、源安全盒和 raw 精确纯绿色仍作为历史生产
偏差保留，不被改写为通过；它们不再阻塞已授权的逐格裁切、等比缩放、居中
与 Alpha 清理。QL-B2／B3 以已接受的小尺寸视觉重量继续分别建立完整执行
正文，不能从概念图或未接受候选直接裁切。

## ScrollBar 与操作 Button

轨道像嵌在页边的窄装订槽，拆为不可拉伸上／下端与可纵向平铺中段；滑块像
小型黄铜页夹。上下按钮、关闭扣、放弃／分享／退出按钮必须分别提供普通、
悬停、按下、禁用。操作按钮为厚皮革或纸页搭扣，文字由客户端绘制；不使用
现代矩形按钮、细金框或常亮高光。

## 奖励槽与分隔

奖励槽使用深皮革凹面、克制黄铜外沿和纸面接触阴影；物品图标、数量、名称与
品质色均为 runtime。Quest Log 奖励只读，不提供 selected 状态。分区墨线为
无命中的三段式短线，不切断整张右页。

## Quest Tracker

视觉基线是纵向行军便笺：顶部短皮带与双铆钉、可纵向扩展的安静纸面、独立
叠页边、自然撕裂底边、极少量羽毛笔／指南针徽记。多个任务共享连续纸面，
没有逐项卡片。完成使用墨勾，重点任务使用小暗酒红页边标，完成／失败使用
小蜡封，限时使用沙漏压印。

这只是锁定基线，不是生产 Prompt。外部 provider 未映射前禁止执行、生成或
创建 adapter。

## NPC Quest／Gossip

当前没有美术基线 Prompt。未来必须在保留 `QuestFrame`／`GossipFrame`
肖像、五类正文面板、二十个滚动绑定、八个真实操作 Button 和四类物品／奖励
对象的前提下，单独锁定“NPC 委托文书”方向。不得从完整 Quest Log 背景直接
裁切，也不得用一张图替代真实按钮。

## 历史收敛

QL-A2 V1、V2.1、V3 与 V3.1 均已退回。当前树不再保存每次尝试的独立 Prompt；
可复用结论已进入当前 work 文件，完整执行正文、会话和 diff 保留在 Git
历史。任何新尝试都必须从锁定任务基准与本文件重新继承，不上传失败候选。
