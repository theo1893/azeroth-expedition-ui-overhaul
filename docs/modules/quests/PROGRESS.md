# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- `QS-B1 V6-A..G` 已完成授权批次：实际 ImageGen `28/35`、流程错误 `7`；
  A／B／C 只形成内部候选，D／E／F／G 各自耗尽。用户保留七个独立功能位、
  动态收拢与 ScrollChild 结构，但否决现有承载层的可见效果：火漆未压住布条、
  近黑布质感过轻、双钝缺口过于规整。随后重开的生成前模拟
  `QUEST-LOG-SEAL-PURITY-RIBBON-SIM-V17 / QS-B1 V7-A`：漆章后绘并与较窄
  旧骨褐誓约条带相交 `24px`，尾端改为约五个不等距尖锐破口；真实排版
  `42/42 pass`、展示区 `6/6 pass`、ImageGen `0/0`。用户于 `2026-08-06`
  回复“确认”，状态为 `simulation-confirmed / production-prepared / P2`。
  最终单 donor 正文、固定 Image 1／2、`128×768` mask、QS-A1 Alpha 接触
  压暗及 `32×192px` runtime 合同已完成完整性审计；下一门禁是独立生产授权。
  当前不改 source、runtime 或 addon。V5-A accepted source 仅保留为可恢复
  fallback，旧功能按钮继续原子 fail-open。
- 用户于 `2026-08-05` 在 Turtle WoW 中确认当前 Quest Log 左页与右页的既有
  bug 和显示问题均已修复。活动范围中的 QL-A2 V4 书体、18 行左页字体／
  无描边／类型墨色，以及 Quests `1.25`／Theme `1.8` 的右页金额、动态
  ScrollChild、奖励无循环锚点、间隔／换行和原生 `NameFrame` 抑制记为
  `game-validated / P6 / user-confirmed`。本轮没有新增截图文件，文档只记录
  用户给出的实机结论；QL-D 最终美术、QS-B1、Tracker、QL-B3 和 NPC 对话
  不在此次验收范围。
- 用户于 `2026-07-31` 接受当前游戏内书本主体，并明确要求停止增加列表内框、
  地区条或任务条底板；后续只处理书本外的真实控件与交互反馈。
- `2026-07-31` 已完成魔改版 `pfQuest 7.0.1` 与
  `pfQuest-turtle 7.0.2` 的源码审计。布局失序来自 `pfQuest/quest.lua`
  后加载替换 Quest Log 刷新入口、再次调用 `QuestLogTitleButton_Resize`，
  并把六个 provider 控件塞入详情 ScrollChild；`pfQuest-turtle` 只扩展
  数据，没有独立 UI 写入。
- `2026-08-04` 远端分支审计确认：默认 `origin/main` 曾只有 Quests runtime
  `1.16`／Theme `1.5`；随后交付的 runtime `1.18`／Theme `1.6` 已恢复
  `pfUI.font_default`，但最新实机截图又精确暴露两个剩余问题：任务行的
  `OUTLINE` 形成粗黑阴影，且把 `QuestLogItemReceiveText`／
  `QuestLogRequiredMoneyText` 强制为 `214px` 后，其右侧原生 MoneyFrame 被推到
  ScrollChild 外，只剩最右侧金额残片。当前 runtime 已升至 `1.19`、共享主题
  升至 `1.7`：任务与状态行保持 `pfUI.font_default`／`12px`，但 flags 置空并
  清零 shadow；只有可换行正文使用固定宽度，两个行内金额标签恢复原生
  `SetWidth(0)` 自适应宽度。详情测量同时纳入原生 `QuestLogSpacerFrame` 这个
  `25px` 内容末端标记，再由最底对象加 `12px` 重算 ScrollChild，并保留最多
  两帧、完成即停止的有限重排。奖励双列槽仍为 `108px`、名称安全宽 `64px`。
  Lua smoke 已覆盖无描边字体、行内金额宽度、spacer 内容高、四个奖励槽和
  两帧动态滚动范围；仍待目标客户端验证。
- 同日后续两张实机图继续暴露三项独立问题：左页本地化
  `（地下城）／（精英）／（团队）` 没有稳定的开头颜色码，因而继续继承任务
  等级的荧亮黄／绿；pfUI／provider 旧奖励锚点在多奖励时重叠；右页仍沿用
  难读的旧 QuestFont／描边。runtime `1.20` 现先剥离后缀内 provider 色码，
  再按真实显示的全角／半角括号段显式注入 Theme `1.8` 的深紫任务类型墨，
  不再依赖 API 返回的英文 tag 与本地化文字完全相同。Theme `1.8` 同时新增
  `detailHeading`（Noto Serif SC `14px`）和 `detailBody`
  （`pfUI.font_default` `12px`），详情标题、正文、目标、奖励标签与奖励名均无
  outline／shadow。选择／法术／固定奖励分别读取真实数量并重建锚点，单格
  `108×41px`、列距 `8px`、行距 `4px`，不再继承 provider 重叠位置。
  正式奖励槽资产确认前只把 pfUI 黑灰底降为低透明暖纸 fallback；QL-D V1
  已完成确定性本地模拟，0／1／2／4／6 五场景 display-region `5/5 pass`、
  violations `0`、ImageGen `0/0`，当前等待用户确认“旧皮革外框＋黄铜图标
  凹槽＋羊皮纸名称面”可见方向。
- 用户随后以新实机图明确否决上述两项修复结论：同一页的团队／精英／地下城
  Tag 仍同时出现深紫、荧黄和绿色，两个奖励 backdrop 仍视觉相接。复核原生
  `QuestLogFrame.lua` 与 pfUI skin 后确认了两个遗漏：`QuestLogTitleNTag`
  是独立 FontString，原生选中／悬停会直接把它改成 highlight 或从 Button 的
  `r/g/b` 恢复难度色；另外 pfUI 用 `SetAllPointsOffset(..., 4)` 把每个奖励
  backdrop 向四边扩 `4px`，恰好吃掉两个 Button 之间的 `8px` 逻辑列距。
  runtime `1.21` 改以屏幕上真实非空 Tag 为权威：完成／失败仍用各自语义墨，
  其余 Tag 即使 API tag 缺失或本地化不一致也统一为深紫任务类型墨；同时把
  该色写入行 Button 的 `r/g/b`，并在原生 `QuestLogTitleButton_OnEnter` 后置
  恢复，覆盖普通、选中、悬停和离开路径。奖励 backdrop 现先
  `ClearAllPoints()` 再 `SetAllPoints(item)`，可见边界与真实 `108×41px`
  Button 一致，保留完整 `8px` 空隙。新增 smoke 覆盖 API tag 缺失、全角／
  半角标签、原生 hover 强写，以及 pfUI `4px` 外扩收回；仍待目标客户端复验。
- 用户再次确认 runtime `1.21` 的类型色与奖励间隔均未修复。逐行复核 pfUI
  `SetAllPointsOffset` 实现后确认上一结论方向相反：正 `4px` 是向内 inset，
  `SetAllPoints(item)` 反而把 fallback 放大到 Button 全边界，使相邻卡片更接近。
  同时，一次性调用真实 Tag 的 `SetTextColor` 仍会输给原生更新、选择、悬停或
  provider 的后写。runtime `1.22` 不再改写 Button 的难度色 `r/g/b`，而是在
  每个真实 `QuestLogTitleNTag.SetTextColor` 上安装事件驱动语义 setter lock；
  后续写色仍执行原 setter，但参数被约束为当前完成／失败／任务类型语义墨，
  不需要 OnUpdate 轮询。奖励 backdrop 改为两个明确锚点，各边向内 `4px`；
  `108px + 8px + 108px` 的 Button 几何不变，两张可见 backdrop 之间形成
  `4 + 8 + 4 = 16px` 纸面断口。status 新增
  `tag=semantic-setter-lock, reward=inset-4-gap-8` 以排除陈旧部署。
- 最新实机截图确认 runtime `1.22` 的左页类型色已经修复，但三件选择奖励的
  首行仍共享同一条边界。由此排除 backdrop 颜色／文字宽度，确认是原生或
  provider 在 AEUI 重排结束后又把真实 `QuestLogItemN` 的 Point／Width／Height
  写回旧值。runtime `1.23` 在每个真实奖励 Button 的几何 setter 上安装
  事件驱动锁：provider 写入仍可发生，但立即落回当前分组合同的 `108×41px`、
  `8px` 列距与 `4px` 行距；不使用维护型 OnUpdate。pfUI backdrop 继续向内
  `4px`。smoke 现在主动模拟 `-8px` 晚到锚点和 `116×35px` 晚到尺寸，并确认
  setter lock 恢复合同。status 改为
  `reward=geometry-setter-lock-gap-8-inset-4`。
- 下一张实机图仍显示同一原生卡面相接，由此否决 runtime `1.23` 对“可见面来自
  pfUI backdrop”的前提。最终复核作用域路由确认：`skin_owners["Quest Log"]`
  使 pfUI Quest Log skin 在 AEUI 路径被明确跳过，因此真实奖励没有
  `item.backdrop`；截图中的灰褐长条是 Blizzard `QuestLogItemNNameFrame`。
  runtime `1.24` 现在为每个真实 Button 创建无鼠标的 adapter-owned 暖纸容器，
  把动态图标、数量和名称迁入容器，隐藏并锁住原生 NameFrame 的晚到 `Show()`；
  Button／Tooltip／点击脚本／品质色保持原对象。原 `108×41px` 几何锁继续保留，
  stock 数量 API 全为零时再以真实可见 Button 范围完成 `8px` 双列兜底。smoke
  已覆盖无 pfUI backdrop、原生名牌晚回显、第三项换行和可见数量兜底；status 为
  `reward=native-container-visible-fallback-gap-8`。
- runtime `1.24` 实机随后报错
  `QuestLogItemReceiveText:SetPoint(): QuestLogItem3 is dependent on this`。
  根因是 AEUI 把每组首个奖励锚到对应分组标题，而原生 `QuestFrame.lua` 又会
  反向把 `QuestLogItemReceiveText` 锚到其判定的末个奖励；AEUI 与原生数量状态
  短暂不一致时即形成 `标题 → Item3 → 标题` 环。runtime `1.25` 保留标题视觉
  位置，但把所有奖励项的依赖根改为 `QuestLogRewardTitleText` 或上一组末行左项，
  不再让任何奖励项依赖 `ItemChoose／SpellLearn／ItemReceive`。smoke 的 SetPoint
  mock 现会拒绝锚点环，并主动复现原生把 ReceiveText 锚到 Item3 的调用；当前
  单向锚点树通过。status 改为
  `reward=native-container-acyclic-visible-fallback-gap-8`。
- 同日用户否决 Quest Log 漆章的旧顶部悬空锚点，并要求把底部分享／放弃等
  功能收纳到漆章。V1–V4 先后因外沿承托语义、伪页唇、错误横向方位、过长
  书签和大型二级纸面被否决；V5 虽收短书签，却把 detail 变成事务内容模式，
  用户明确否决“detail 变成二级功能页面”。V6 以右下黄铜包角和底部事务轨
  作为区域审查备选，但用户立即指定漆章必须直接印在详情页右上角书页上，
  且点击后的功能必须在书页右侧展示，因此 V6 未成为候选方向。V7 把七项
  事务放在右页内部右侧，虽不替换 detail，却仍占据／遮挡书页正文，用户明确
  要求功能必须从书页右边外侧展开、完全不占书页空间。
  `QUEST-LOG-SEAL-ACTIONS-SIM-V8` 首次实现 detail／奖励零占用，但用户认为
  `136×24px` 尖头、逐项铆钉／亮黄铜、整条酒红危险项和 `72px` 外伸仍过重，
  已标记 `user-rejected`。当前 `QUEST-LOG-SEAL-ACTIONS-SIM-V9` 保留同一
  QS-A1 火漆 `seal_visual=[576,68,32,32]` 与
  `[572,64,40,40]` 命中／保留区，七个 provider 代理仍从 detail 排他右边界
  `x=612` 向书外伸出，但收敛为七条 `112×20px` 短书口事务签，整体
  `exterior_action_menu=[612,112,112,158]`。真实 QL-A1 页边
  `[604,102,24,180]` 遮住根部；无尖头、逐项铆钉或明亮顶部高光，放弃项只
  用低饱和酒红文字／边线。打开态只声明 `48px` 右侧 outset，机器展示区域
  `25/25` 通过。ImageGen `0/0`；用户于 `2026-08-03` 回复“进入下一步”，
  明确确认 V9 的可见方向。当前已形成 `QS-B1 V1` 单一无字事务签母版、
  standard／danger 各四态确定性 atlas 和七个独立 Button 的完整合同与生产
  正文；`QS-B1-INTERACTION V1` 的非模态即时开合、源 Button 委托、
  `96×20px` 可见区命中与原子 fail-open 已于 `2026-08-05` 获用户确认；同日
  用户又独立授权 `QS-B1 V1` 完整正文、固定 Image 1／2、受限同循环 Image 3
  edit、最多五次实际调用与合同内确定性后处理。状态为
  `candidate-rejected / user-rejected / repair-budget-exhausted / P3 / 5/5`。
  首次 transport 因 0.143.0 可变长 `--image` 吞入位置 prompt 而在生成前退出，
  无图片或 provider result，记为流程错误 `1`、不占额度；下一门禁是在 Image 2
  后加入 `--` 终止符，以同一正文重试 attempt 1。重试已生成，但原图比例仅
  `4.3636:1`，完整亮铜框、过圆外端和密集现代皮纹同时违背合同；确定性审查虽
  证明七槽、18 行、四奖励、右缘 clamp 几何成立，仍不能修复结构与美术失败。
  V1.r1 regenerate 明显修复了内框、圆帽和过亮边，但比例反而为
  `4.2851:1`，运行时仍仅 `86×20px`；完整排版继续证明其视觉方向比 attempt 1
  收敛，但固定槽合同仍失败。已准备完整 `QS-B1 V1.r2`，下一次只把 attempt 2
  作为 Image 3 edit target，压薄轮廓并打断顶部／右端连续高光。attempt 3
  已把比例推进到 `5.1456:1`、runtime-visible `103×20px`，排版视觉明显接近
  目标，但仍低于冻结的 `5.45` 下限；同时重新出现均匀微纹和中央斜向擦痕。
  已准备完整 `QS-B1 V1.r3`，只对 attempt 3 再做约 `8%` 压薄与低频重绘。
  attempt 4 只从 `5.1456` 改到 `5.1707:1`，同一首要失败连续出现，因此最终
  attempt 5 改变策略：不再泛化“压薄重绘”，而是对 attempt 4 做精确轮廓
  surgery，保留 `1060px` 宽并把 `205px` 高裁减／重绘到 `187..191px`。
  attempt 5 返回 `1184×193px`、`6.1347:1`：高度已变薄，但宽度擅自增加
  `124px`，越过 `5.75` 上限；等比 bbox-fit 后只得到 `112×18px` 可见内容，
  上下留透明行。七槽真实排版仍为 `25/25 pass`，但均匀压纹、近全长顶部
  亮线与右端连续亮边也仍违背香草美术合同。五次额度已经耗尽，不得执行
  attempt 6；没有 source、atlas 或菜单接入。用户随后于 `2026-08-05` 对
  attempt 5 明确回复“不可接受”，因此 V1 不允许非等比／裁切例外，也不得
  作为 V2 edit 输入。V10 的页外旧卷宗索引签在确认前又被用户明确改向，
  标记为 `user-superseded-before-confirmation`。当前已完成
  `QUEST-LOG-SEAL-ACTIONS-SIM-V11 / QS-B1 V2` 四状态本地确定性预演：火漆、
  `6px` 折叠根、七个 `32×22px` 独立纹章段和短尾端都挂到详情
  ScrollChild；scroll `0` 保持既有火漆位置，展开临时覆盖正文最右
  `14..24px` 但不重排，尾端在真实 `108×41px` 奖励槽前 `32px` 停止；
  scroll `52` 第一段裁切且禁用隐藏 hitbox，scroll `208` 全部滚出且命中数
  为零。模拟 `21/21 pass`、display-region `4/4 pass`／violations `0`、
  ImageGen `0/0`。用户于 `2026-08-05` 在明确“确认后只准备生产正文、仍需
  独立生图授权”的上下文中回复“继续”，因此该具体可见方向已确认；模拟像素
  仍不是 source 或 runtime。V2 随后实际执行至 `4/5`：attempt 4 的等比 bbox
  与九区几何虽可通过，但质感仍差、过于工整，且把七项纹章与布底合并成一张
  图，无法独立隐藏功能。用户明确要求改为“单独出图，再叠在一条背景上”，
  因而 V2 标记为
  `candidate-rejected / user-superseded-before-attempt-5 / 4/5`；attempt 5
  未调用，旧授权不转移。
- 当前 `QUEST-LOG-SEAL-ACTIONS-SIM-V12 / QS-B1 V3` 已把资产拆为动态空白
  背景，以及七张独立透明纹章与七个独立 Button。hidden 项会移除并无空洞
  收拢，disabled 项留位但不命中；六个真实排版场景覆盖 7／5／3 项、部分滚动
  与完全滚出，本地检查 `35/35 pass`，display-region `6/6 pass`、violations
  `0`、ImageGen `0/0`。用户于 `2026-08-05` 回复“可以”，V12 已记为
  `simulation-confirmed / P2`；模拟像素仍不作为 source、runtime 或后续
  ImageGen 输入。生产拓扑在不改变 V12 屏幕几何的前提下进一步收敛为一条
  连续的最大长度空白布母版：runtime 按可见项数裁取前缀并接独立 tail，从
  根源消除三段重复、横缝和 `22px` 周期。七纹章则由固定七格工作表生成，
  P4 必须拆为七张独立 tracked RGBA source。V3-A／V3-B 完整正文、固定输入、
  edit 边界和各 `5` 次／最坏 `10` 次预算已于 `2026-08-05` 获用户联合生产
  授权。V3-A 已执行 `5/5`：单物件、动态 cut band、tail 接合、布局 `26/26`
  与 display-region `6/6` 均成立，但五稿持续出现 source 级连续卷曲微纹，
  最终稿宽高比误差仍为 `9.86%`，因此以
  `internal-rejected / repair-budget-exhausted` 终止。用户随后明确否决该版：
  切口过于整齐、综合色过亮而显得轻浮；V3-A 现同时为 `user-rejected`。
  联合授权要求 A 内部通过后才执行 B，故 V3-B 保持 `0/5`、未执行。
  新的 `QUEST-LOG-SEAL-SUBSTRATE-SIM-V13 / QS-B1 V4-A` 已只针对上述两点
  完成本地确定性预演：主体压为低饱和烟熏深旧棕，侧边改成少量非周期宽幅
  偏移，尾端只保留两处不等宽钝缺口，亮面改成断续宽块；7／5／3 项仍从同一
  `32×174px` 最大母版取前缀并接同一 tail。真实排版与结构检查 `40/40 pass`，
  display-region `6/6 pass`、violations `0`，ImageGen `0/0`。用户于
  `2026-08-05` 回复“接受, 用这一套试试效果”；
  V13 像素不是 source、runtime 或未来 ImageGen 输入。V4-A 完整 production
  prompt、固定 Image 1／2、最多五次实际调用与冻结修复边界已完成审计并于
  `2026-08-05` 获用户明确授权。五次实际 ImageGen 已执行并耗尽，流程错误
  `1`；attempt 5 为本轮最佳综合色和形制，但 raw `176×892px` 相对目标
  `128:696` 的比例误差 `7.287%`，超过授权 `≤1%`，同轴等比只能形成
  `128×649px`。自动检查 `5/9`，真实排版 `26/26`、display-region `6/6`
  通过；终态为 `candidate-rejected / repair-budget-exhausted / P3 / 5/5`。
  当前已进入 `QUEST-LOG-SEAL-SUBSTRATE-SIM-V14 / QS-B1 V5-A` 生成前门禁：
  ImageGen 未来只负责全幅连续暗旧布面 donor，固定中央裁片和 tracked mask
  独占精确 `128×696` 轮廓、Alpha 与双钝缺口。V14 用真实 Quest Log 六态完成
  `46/46 pass`，继承未变化的展示区合同后仍为 `6/6 pass`、violations `0`，
  ImageGen `0/0`。用户于 `2026-08-05` 在审视六态 board、构造图与设计审查后
  回复“不走figma, 直接下一步”，因此 V14 已推进为
  `simulation-confirmed / P2`；确认只冻结可见方向，不接受模拟像素。用户随后
  于 `2026-08-05` 明确授权 V5-A 最终 production 正文、固定 Image 1／2、
  deterministic crop／mask、受限同循环 Image 3 edit 和最多五次实际调用，
  已以 commit `87903e8` 冻结并执行 attempt 1。raw `1254² RGB`、fixed composite
  `128×696 RGBA`、自动 `18/18`、六态布局 `29/29` 与 display-region `6/6`
  通过；综合色与单一布面身份可保留，但均匀细颗粒／毡皮式微纹、圆斑以及
  crop-local y≈`224／400` 两道横贯整宽折面违反 V5-A 美术／安静带合同。受限
  r1 Image 3 edit 已作为 attempt 2 执行；技术门禁仍全过，但细纹变成更规则的
  卷曲／编织图案，褶皱增多且 crop 仍有横贯亮带，相同首要失败连续出现。
  attempt 3 已按完整 V5-A.r2 只用固定 Image 1／2 regenerate；自动 `18/18`、
  六态 `29/29`、展示区 `6/6`，并成功消除规则微纹、多重垂褶与圆斑。attempt 4
  再以完整 V5-A.r3、固定 Image 1／2 和紧邻 attempt 3 raw 受限 edit，已擦除两个
  局部 dim plane 的横贯外溢；同样自动 `18/18`、六态 `29/29`、展示区 `6/6`，
  scope→style→assembly／pixel 内审完整通过。用户于 `2026-08-06` 在候选专属
  门禁中回复“接受”，因此 exact attempt 4 composite 已进入
  `source-accepted / P4 / 4/5`；流程错误仍为 `1`，按通过即停保留 attempt 5
  未调用。tracked source 与 manifest 已写入 `assets/source/quests/qs-b1/`，
  跨设备 handoff 已消费；尚无 runtime 或 addon 改动。
  V15 随后直接使用该 accepted source 完成六态真实排版。用户于
  `2026-08-06` 在明确“接受只确认综合色、正式生成仍需独立授权”的门禁下
  回复“接受”，因此六项哑光低饱和旧赭金矿物颜料与放弃项灰暗酒红已成为
  稳定方向；本地几何纹章像素仍非 source 或 edit input。V5-B 完整自包含
  production Prompt 已重写并通过完整性审计；用户于
  `2026-08-06` 明确授权
  固定 Image 1／2、受限同循环 Image 3 edit、最多五次实际调用和合同内
  确定性后处理。用户随后要求重试，固定 child 已恢复并执行五次 countable
  generation；终稿自动 `10/12`，但只有 ABANDON 位于 safe box，其他六项仍因
  行锚点错误被固定 cell crop 截断，RESET 另有 `44` 个绿残留。当前为
  `candidate-rejected / repair-budget-exhausted / P3 / production 5/5`；无纹章
  source、runtime 或 addon 改动。用户随后选择另开 V6 七张单对象 source；
  `QUEST-LOG-SEAL-MOTIFS-SIM-V16` 已在不改变 V15 外观的前提下完成本地真实
  排版与 source 隔离预演，自动 `59/59 pass`、展示区 `6/6 pass`、ImageGen
  `0/0`。用户于 `2026-08-06` 回复“接受”，确认七张独立单对象 source 拓扑；
  用户同日独立授权 V6-A..G 最终 production 正文、固定输入、同段 edit 边界与
  逐段五次预算。该批次最终实际 ImageGen `28/35`、流程错误 `7`；A／B／C
  只形成内部候选且未获用户接受，D／E／F／G 各自耗尽。用户保留七张独立
  source 拓扑，但取代其近黑布、双钝缺口和火漆悬浮方向；当前执行入口已切换
  为 `QUEST-LOG-SEAL-PURITY-RIBBON-SIM-V17 / QS-B1 V7-A`；用户于
  `2026-08-06` 确认方向，当前等待独立生产授权。
  V5-B 失败像素不进入 V6 或 V7。
  runtime `1.25` 继续把已接受的 QS-A1 漆章以 `32px` 无鼠标 Texture 放到
  详情页右上纸面；菜单尚未接入，也未隐藏任何旧按钮。
- AEUI Quest Log provider 兼容子合同保持 `1.7`：在 provider 最终刷新后以
  事件驱动方式恢复 18 条列表行与右页正文安全区，将 online／language 搬至
  右页固定顶部工具行，将 show／hide／clean／reset 搬至右页固定底部四格；
  所有 provider OnClick／OnUpdate、显隐、禁用、ID 和数据行为保持。没有使用
  维护型 `OnUpdate` 几何争夺；late-load 与幂等 smoke 已通过，仍待实机。
- `2026-08-01` 共享主题建立为 `Quest Visual Theme 1.5`，当前已由上方
  `2026-08-04` 的 Theme `1.8` 详情可读性修订覆盖。Quest Log 的卷宗书体与
  pfQuest Tracker 的行军便笺仍保留不同物件轮廓，但两者的媒体入口、标题／
  任务名字体角色、正文墨色、五档任务难度色、完成／进行中／未完成／失败色和
  皮革按钮色现只由
  `addon/AzerothExpeditionUI/Modules/QuestVisualTheme.lua` 定义。Quest Log 在
  原生／pfQuest 列表与详情刷新后套用主题；Tracker 的真实 Button 在
  `OnEvent`／`OnClick`／`OnShow` provider 脚本之后只标记主题失效，由 tracker
  下一次自身 `OnUpdate` 将整批条目统一套色、按主题字体测宽并一次提交高度。
  clean 帧不写入几何，也不争抢 Parent、Point、排序或条目锚点。
  后续视觉换版只改该主题和它指向的两类表面资产，不再分别维护两份颜色常量。
  最新实机截图中左页代表纸面约为 `#B08444`，旧普通难度墨 `#7A6118`
  仅约 `1.75:1`，在无描边字体上明显发淡。Theme `1.5` 因此把五档难度色
  收紧为深红／焦棕／深赭／森林绿／炭灰墨，在该代表纸面约为
  `4.58:1..4.94:1`；任务类型改为深紫墨，完成／失败分别使用深绿／深红。
  adapter 同时处理模板拆出的 `Tag`／`Complete` FontString 与任务标题后的
  内联颜色码，避免原生荧亮黄绕过共享主题。
- `2026-08-01` 最新 Quest Log 实机图暴露左页字体描边、字号、状态提示、
  行末追踪圈、滚动条以及跨面板颜色六项问题。runtime `1.16` 当时将活动窗口
  固定为 `QuestLogTitle1..18` 的 `246 × 18px` 行盒，文字安全区 `226px`；
  任务名、地区名和模板拆出的完成／地下城等 FontString 全部使用 `12px`
  霞鹜文楷、空 flags、透明／零偏移 shadow。`QuestLogTitle19..23` 继续创建
  供 provider 兼容但始终隐藏。任务行原生 check 与历史 AEUI 圈全部隐藏；
  左右页 scrollbar chrome 均隐藏并禁用鼠标，真实 ScrollFrame／Slider／
  FauxScrollFrame offset 保留，通过页面滚轮到达首尾。Quest Log 和 Tracker
  的任务名都调用 `ResolveQuestNameInk`；完成、失败、地下城与进度只着色各自
  状态提示，不再把整个任务名染成另一种颜色。该次霞鹜文楷字体路径先被
  runtime `1.18` 的 `pfUI.font_default` 覆盖；runtime `1.19` 保留统一字体路径，
  同时恢复空 flags／零 shadow。其他布局和语义色结论继续有效。无新位图、
  无 ImageGen。
- `2026-08-01` 用户根据最新 Tracker 实机截图明确要求隐藏每个任务左侧的
  彩色点／问号，并移除任务名的黑色阴影感。runtime `1.13` 只隐藏真实
  `button.icon` Texture，保留 `button.node`、Button、命中区和全部脚本；
  provider 事件若重写 icon，AEUI 的后置回调会立即再次隐藏，避免单帧闪现。
  共享主题新增独立 `trackerQuestName` 字体角色，flags 为空并同时清零
  FontString shadow。用户随后要求任务名换回旧的统一字体；runtime `1.14`
  因此不再覆盖 Tracker 的字体路径，优先读取 `pfUI.font_default`，保留 provider
  当前动态字号，仅将 flags 置空。Quest Log 的 `questName` 角色当时不受
  影响，后于 `2026-08-03` 独立恢复为同一 `pfUI.font_default`。
- `2026-08-01` 实机确认接受／放弃任务触发 pfQuest `Reset()` 时，旧 adapter
  会在 provider 逐条重建期间反复提交主题和宽度，且最后一条目标会进入
  `16px` 撕裂底边。runtime `1.12+` 现把逐条回调合并为一次批次提交，并按
  `tracker.panel` 实际高度（缺失时 `16px`）加全部有效 Button 高度计算内容区，
  再固定预留 `16px` 底部安全区。空状态因此至少为 `32px`，动态最后一行不再
  占用装饰 cap；纸面在同一次提交中读取最终尺寸。任务数据、排序、点击、拖动、
  Tooltip、模式和 SavedVariables 均未修改，仍待 Turtle WoW 接受／放弃任务实测。
- `2026-08-01` 修复打开任务面板时
  `QuestFramePushQuestButton doesn't have a "Onenable"` 的实机错误。Vanilla
  1.12 Button 不支持 `OnEnable`／`OnDisable` 脚本；底部皮革按钮的禁用态现由
  合法的 `QuestLog_Update` 与空任务页显隐生命周期显式刷新，不替换原生
  `Enable`／`Disable` 方法。Lua smoke 也会拒绝再次注册这两个非法脚本名。
- pfQuest tracker 的真实对象合同已完成：唯一 root 为
  `pfQuestMapTracker`，包含三种模式、七个工具 Button、最多二十五个动态
  Button，宽度 `130..330px`、高度随目标变化。当前结构图与 Quest Log
  故障图继续只作信息层级和复现证据，不是美术权威。
- `2026-07-31` 新增实际展示区域复核。atlas 九格采样完整、普通尺寸背景可
  铺满 Frame；runtime `1.16` 已静态修复空 tracker 低于九宫格 `29px` 最小值、
  最后一行进入底部装饰 cap 以及节点图标压入左 cap 三项，但左右外侧工具 icon 和文字
  右缘仍未完成 live 内容安全区验收。旧 `180/500/865/500px` 固定高度预演
  不是 provider 实例，已由空状态、`104/256/420/516/136px` 及三种模式的
  精确预演取代。QT-A1 保持
  P5 文件，但标记 `display-region-blocked`，不能直接进入 P6。
- 用户于 `2026-07-31` 否决 `QT-GEO V1` 的外置装饰端帽：tracker 外侧不得
  增加类似书框的边界，当前 tracker 直接展示已经足够。`QT-GEO V2` 已按
  “显示面严格等于 pfQuest live Frame、四边 outsets 全为 `0px`”完成七种
  真实尺寸的本地确定性预演与机器审查，ImageGen `0/0`；七场景公式、动态
  内容包含与 `visual-shell-equals-live` 全部通过，当前等待用户确认具体
  模拟版本。确认前不修改 runtime。
- 用户于 `2026-07-31` 将七个低频工具 Button 与 `HEADER.*` 的视觉改造暂缓，
  当前优先确认 tracker 主体。provider 对象、Tooltip、OnClick、模式切换和
  SavedVariables 合同不变；暂缓不授权隐藏、删除、重挂、换皮或改写脚本。
- 用户随后重开一个更窄的工具入口方向：Quest Log 与 Tracker 共用同族旧酒红
  漆章；Tracker 不使用微型 icon，而以 `34 × 34` 漆章置于列表顶部中央，
  目标视觉隐藏七枚旧 icon，并在未来由漆章唤起的一对一菜单承载全部行为。
  用户已接受 `QUEST-SEALS-SIM-V1` 的共用美术、尺寸与 Tracker 方向，但
  明确否决 Quest Log 落在右下翻页／书封上的锚点。V2 只把该 `28px` 漆章
  移到任务书右上方透明 UI 空间；与 SHELL 可见 Alpha 重叠 `0`，其余方向
  不变，机器报告 `pass`、ImageGen `0/0`。用户于 `2026-07-31` 回复
  “进行下一步”确认 V2 外置锚点。`QS-A1 V1` 最终生产正文已将两张锁定图的
  inherit／ignore 职责写入执行正文，并把 atlas 可见蜡体收紧为 Quest Log
  约 `26px`、Tracker 约 `32px`。用户已于 `2026-07-31` 独立授权完整
  `QS-A1 V1`、固定 Image 1／2、受限同循环 Image 3 edit 与最多 `5` 次实际
  ImageGen 五次额度已耗尽（`5/5`）。用户现已接受 r4 的运行时视觉，并授权
  确定性色键、透明 RGB 清零与 `1024²` 归一化例外。tracked source SHA-256
  为 `377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75`；
  可见 bbox `[192,200,832,824]`，可见绿色残留与透明像素 RGB 均为 `0`。
  normal／hover／pressed／disabled 四态以同一 Alpha 导出为 `256 × 64` TGA，
  SHA-256
  `f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`。
  Quest Log `28px` 与 Tracker `34px` 无鼠标 Texture 已接入，Tracker 追加
  `18px` top clamp inset；三种宽度展示区域与 Lua smoke 通过，当前为
  `runtime-exported / P5`。其中 Quest Log 顶部悬空位置已于 `2026-08-03`
  被用户否决，accepted 漆章美术与 atlas 不受影响。功能等价完成前 runtime
  不隐藏旧按钮；`130px`
  下的旧按钮覆盖属于已记录的过渡层序，仍待实机。
- 用户于 `2026-07-30` 将 Quest Log 选为当前首要大面积 UI；地图与角色因
  实机对象几何尚未完成，继续保持后续顺位。
- Quest Log 真实对象合同：`P1` 完成，QL-A 当前处于 `P4–P5`；QL-B1
  V1.r3 与 QL-B2 V1.r4 bbox-fit 均已由用户接受运行时视觉并完成
  `runtime-exported / P5`。
- `QL-A1` 空卷宗结构 source：用户确认，`P4`。
- `QL-A2 V3.2` 已终止：A attempt 5 目标级通过；B 在 `5/5` 后仍有约
  `45%` 格宽的针脚和完整外露结，整批 `10/10` 额度耗尽。没有形成
  accepted source 或 runtime；A 候选仍只是 ignored `generated/` 中的
  本机重组输入。
- `QL-A2 V3.3`：`P3` 部分执行。已将失败的 B 六件同画布合同拆成
  B1 underlay＋folds、B2 单枚 stitch、B3 top／bottom closures 三个尺度
  族；三段完整 Prompt、固定输入、验收合同、确定性等比归一化和真实纸缘
  遮挡方案已经预检通过。用户于 `2026-07-30` 明确授权三段正文、固定上传
  范围及每段 `5` 次预算。B1 已耗尽 `5/5`：最终 underlay 仍是深色纹样
  竖条，fold 仍有满面压纹，且背景不可安全色键。B2 attempt 1 生成了
  单根水平对象；attempt 5 去除了编织纹，却变成 `832 × 101px` 的光滑
  木质／角质实体，仍非亚麻线且背景不可安全色键，B2 已耗尽 `5/5`。
  B3 已耗尽 `5/5`；合计 `15/15`。终态原尺寸复核纠正了此前的误判：
  attempt 3–5 仍是多圈交叠、装饰性绳结和横向杆状尾端，第一失败门禁是
  语义／物理，不只是尺寸／位置。三段均为
  `candidate-rejected / repair-budget-exhausted`，无任何候选可晋级。
- `QL-A2 V4`：`game-validated / P6 / user-confirmed`。用户于 `2026-07-30` 确认 QL-A1
  单一静态背景、`676 × 464`、list-only 不缩窄书体和 `GUTTER.*` 静态
  归属。确定性 exporter 已生成 `1024 × 512` TGA 与 runtime manifest；
  AEUI adapter 把它挂在 `QuestLogFrame` 的非交互背景层，隐藏原生装饰
  Texture，但保留动态文字、列表、详情、原操作 Button、脚本和
  SavedVariables。缺少详情切换时只创建真实 Button。任务行、两套
  ScrollBar、按钮状态、奖励槽与状态覆盖的最终美术仍属于 QL-B/C/D。用户于
  `2026-08-05` 进一步确认当前左右页 bug 与显示修复通过；这不替代其余批次
  各自的验收。
- `QL-B`：已完成目录对象与状态来源复核。旧 P5／V1 runtime 曾保留 pfUI
  23 行，以 `15px` 行高／`14px` 步进占用 `323px`；实机已确认这种密度
  和仅有小墨记／书签的资产范围不足以形成可感知的左页改造。用户确认 V2
  改为 `QUESTS_DISPLAYED = 18`、`18px` 步进，总占高 `324px`；runtime
  `1.18` 在隐藏页边 scrollbar 后进一步把每行扩到完整 `246px`，文字安全宽
  `226px`。
- `QL-B0 V2`：新的 [左页卷宗目录 work](work/QUEST.LOG.LEFTPAGE.md)
  已于 `2026-07-30` 获用户明确授权。A attempt 1–4 已由固定
  `@openai/codex@0.143.0` 执行并完成透明／100% 真实排版审查；attempt 4
  的开口最接近目标，但归一化外框仍约 `581 × 763`，可见材料约占
  `9.74%` 而非 `3.58%`，背景也不是精确 `#00FF00`。用户在任何 A5
  provider 调用前明确认为该框没有必要，并用完整重启后的实机图确认 QL-A2
  连续左页与十八行布局稳定。A 终止于 `4/5`、`user-rejected /
  scope-removed / P3`，不建立 source、runtime 或占位对象。B 已完成
  `5/5`：attempt 1 的金属牌匾语义已在 attempt 2／3 修正为平面暗橄榄／
  暖赭纸条，100% 十八行排版方向正确；attempt 4／5 edit 继续保住语义和
  美术，但都未执行固定 `800 × 64` bbox。最终 attempt 5 归一化上条约
  `830 × 99`、下条约 `831 × 100`，中心也错误，背景仍不是精确色键。
  B 在预算耗尽后又被用户明确移出范围，终态为
  `user-rejected / scope-removed / P3`，不建立 source/runtime，也不得
  attempt 6。B 的历史设计范围只包含
  `224 × 18` 地区条与任务条 base，
  四态确定性派生；顶部控件、ScrollBar 与按钮继续归 QL-C；
  QL-B1／B2 只在 V2 source 接受后从现有 accepted source 确定性重导出，
  QL-B3 继续暂停。原授权最坏总预算为 `10` 次；A 未使用第 5 次后有效最坏
  总调用已达到 `9` 次。该路线已关闭，不再等待 bbox-fit 例外或 source
  策略决定。
- `QL-B1 V1` 的固定执行循环在
  `candidate-rejected / P3 / repair-budget-exhausted` 终止。用户于
  `2026-07-30` 授权固定 Image 1／2、同循环 edit 输入和最多五次调用。
  attempt 1 因只读保存环境失败；attempt 2 触发同名包装 skill 递归，已启动
  的嵌套固定调用按 attempt 3 保守计数后中断；attempt 4 首次形成四格候选；
  attempt 5 以该候选为 Image 3 编辑。最终仍未满足两枚箭头严格旋转同源、
  两枚外圈只差墨勾、平面墨迹身份、`224²` 安全盒和均匀 `#00FF00` 色键。
  用户随后于 `2026-07-30` 明确接受 V1.r3 的运行时视觉，并允许用确定性逐格
  裁切、等比缩放、居中与 Alpha 规则进入 P4/P5；该决定不把内部失败门禁
  改写成通过。透明母版、source/runtime manifest、`64 × 16` TGA、确定性
  exporter 和 adapter 已 tracked；`2026-08-05` 用户确认当前活动左页字体、
  无描边／类型墨色与地区箭头显示通过，因此活动 runtime 为
  `game-validated / P6`。固定执行器仍是 `5/5` 且接受后没有新增调用。
- `QL-B0／B1 runtime`：Quests runtime contract 已升至 `1.25`。继续创建／
  复用 `QuestLogTitle1..23` 以兼容 provider，但只显示 `1..18`，使用
  `246 × 18` 行盒／`18px` 步进和真实滚动偏移。地区箭头仍由
  `GetQuestLogTitle` 驱动；任务行追踪圈全部隐藏，追踪数据和 Shift 点击行为
  保留。覆盖 Texture 不接管点击；原行脚本、选择、滚动与 SavedVariables 保留。实机发现的
  `QuestLogHighlightFrame` 与行内 highlight／pushed 旧选择视觉
  已在每次刷新后透明抑制。主标题使用 Noto Serif SC，任务与状态行恢复为
  `pfUI.font_default` 的 `12px`、空 flags 和零 shadow，不再产生粗黑描边。V2 阅读密度现已
  进入 runtime。
- QL-B1 真实排版预演：`676 × 464`／100% runtime，使用当前 QL-A2
  shell、全部 23 行、代表性中文任务内容与四态分布，SHA-256
  `c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5`。
  QL-C 未完成按钮仅为 manifest 标注的非权威占位；该预演不能替代实机。
- `QL-B2 V1`：用户于 `2026-07-30` 明确授权固定 Image 1／2、同循环
  edit 输入和最多五次实际生图／修图；五次生成与三态 23 行真实排版内审
  已完成，当前 `candidate-rejected / repair-budget-exhausted / P3`，
  实际生图 `5/5`、流程错误 `3`。第五张已达到 `1.776:1` 与
  `24 × 14` 运行时比例，运行时视觉可审视，但 source 安全盒和原生纯色键
  仍不符合冻结合同；没有 source 或 runtime，且不得继续第六次调用。
  流程错误单列且不占实际生图额度。现已额外完成一次不调用 ImageGen 的
  “固定色键清理＋可见 bbox 等比缩入中心安全盒”合同例外预演：候选
  `352 × 198px`、bbox `[336,413,688,611]`、可见绿色残留 `0`，三态
  真实排版与第五张运行时 Alpha 完全一致。用户已明确接受该具体候选和
  一次性确定性 bbox-fit 合同例外；同 SHA 文件已晋级 tracked source。确定性
  exporter 已按 `24 × 14` content、`32 × 16` cell、三态同 Alpha 和第四
  透明格合同生成 `128 × 16` TGA。原始 attempt 5 的安全盒与纯色键失败仍作为
  历史事实保留；接受后 ImageGen 调用为 `0`。用户于 `2026-07-31` 要求先
  隐藏酒红书签，因此 source、manifest、exporter 与 TGA 均保留，但 adapter
  runtime contract `1.6` 不再引用 atlas、不创建 `BORDER` Texture，也不再
  包装任务行 hover／pressed／click 脚本；原生整行选择高亮继续透明抑制。
- `QL-C runtime`：provider 兼容子合同 `1.7` 已完成第一批书本外控件
  和 pfQuest Quest Log 兼容。
  Collapse All 真实 Button 与 pfUI `+`／`-` 子控件已完整隐藏、禁用且阻止
  外部 `Show()` 回生；任务计数改为深墨字体；等级／追踪控件复用 QL-B1
  墨圈 atlas。底部放弃、
  分享、退出与详情开合保留原 Button／OnClick，并使用程序化暗皮革四状态。
  最右侧 `QuestLogDetailScrollFrameScrollBar`、Thumb 与上下箭头隐藏且不
  接收鼠标，详情页本体追加 `28px` 步进、按真实范围限位的鼠标滚轮；左页
  列表滚动条不受影响。pfQuest 六个控件已按真实 Button 粒度归位，后加载
  全局函数和 Frame `OnShow` 替换均有事件驱动恢复。Lua 5.0 语法与 smoke
  已通过，尚待 Turtle WoW 实机。旧底部按钮现同时承担事务菜单完成前的
  fail-open fallback；`QS-B1 V1` 未完成七项代理等价前不隐藏。
- `QL-B3`：三类真实语义已拆为三个固定并列槽，类型／计时／状态可同时出现。
  [QL-B3 work](work/QUEST.LOG.STATUS.md) 已形成 A／B／C 三段完整
  生产正文：分别生成四类类型压印、单枚沙漏和同一蜡封的完整／破裂两态。
  用户于 `2026-07-30` 明确授权 A／B／C V1、固定 Image 1／2、同段前次
  输出的冻结边界 edit，以及每段最多 `5` 次／最坏合计 `15` 次实际调用；
  A 已执行到 attempt 5，四个物件语义、综合色、安全盒和 10px 真实排版
  通过，但 native 精确色键仍失败且发生 1px 级重绘漂移，当前为
  `candidate-rejected / repair-budget-exhausted / 5/5`。B／C 仍为
  `0/5` 并暂停。非地区行文字安全宽度收敛为 `155px`；类型 token 的显式等值表
  仍需在 P5 前由目标客户端证实。Collapse All 归 QL-C 独立 Button，
  不混入目录状态。
- Quest Tracker：provider 对象合同 `P1`、视觉 `P2`；聚焦主体的
  `QT-SIM V2` 已由本地确定性几何 renderer 完成，当前
  `simulation-confirmed`、ImageGen `0/0`；用户于 `2026-07-31` 回复
  “继续”确认主体方向。用户随后独立授权 QT-A1／B1 V1 的最终正文、固定
  Image 1／2／3、同段 edit 和各 `5` 次实际调用上限。QT-A1 已执行五次：
  attempt 4 恢复宽缓纸面但 bbox／native 色键失败，attempt 5 又引入全幅
  压花式微纹理且 bbox／色键仍未通过，当前为
  `candidate-rejected / repair-budget-exhausted / 5/5`。用户随后选择暂时
  直接使用大块背景 tracker，attempt 4 的确定性 RGBA 已按临时合同例外晋级
  并导出为 `256 × 512` 九宫格 TGA；当前为
  `runtime-exported-temporary / P5`。QT-B1 attempt 1 的三件覆盖层虽有正确
  身份，但 cell、focus 综合色／绿边和 native 色键均失败；用户认为真实
  排版很糟糕并暂停整段于 `1/5`，旧 V1.r1 不再执行。QT-A2 为
  `scope-deferred 0/5`，七工具 Button 使用 provider fallback。
  后续展示区域门禁证明历史 `QT-SIM V2` 的 `330 × 865` 只是容量包络，不是
  十任务／十七目标的 provider 真实高度；其材料／综合色方向仍保留，但精确
  几何证据失效。QT-A1 当前完整状态为
  `runtime-exported-temporary / display-region-blocked / P5`。用户已否决外置
  端帽；`QT-GEO V1` 为 `user-rejected / superseded`，新的无边界
  `QT-GEO V2` 为 `simulation-rendered / awaiting-user-confirmation`，
  没有修改 adapter。
- NPC Quest／Gossip：对象合同 `P1`，美术与实机几何未锁定；当前恢复 pfUI
  `Gossip and Quest` skin，只有 `Quest Log` skin 让渡给 AEUI。
- `questitem.lua`：行为保留，视觉 `N/A`。

## Quest Log 批次

| 批次 | 子模块 | 阶段 | 当前事实 | 下一门禁 |
|---|---|---:|---|---|
| `QL-A1` | `QUEST.LOG.SHELL` 结构母版 | `P4` | [透明 source](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 已接受；原始 PNG 不直接加载，只允许 QL-A2 V4 确定性全幅导出 | Turtle WoW 中复核最终显示 |
| `QL-A2` | 静态空卷宗结构与页沟 | `P6 game-validated / user-confirmed` | V3.3 `15/15` 已终止；V4 已从 QL-A1 source 导出 `676 × 464` 显示区／`1024 × 512` TGA，固定执行器 `0/0`，Lua smoke 通过；`2026-08-05` 用户确认左右页当前显示与 bug 修复通过 | 保留至组件／整模块收口；不扩展到未完成范围 |
| `QL-B0` | 左页列表几何；内框、地区条与任务条底板均已撤销 | V1 `P5 fallback`；V2 `P3 user-rejected / scope-removed` | A 在 `4/5` 后由用户移出范围；B `5/5` 耗尽后也于 `2026-07-31` 被用户移出范围；均无 source/runtime，见 [work](work/QUEST.LOG.LEFTPAGE.md) | 保持当前连续书页，不再增加框或底板 |
| `QL-B1` | 地区展开／收起、追踪开／关四枚墨记 | `P6 game-validated / user-confirmed`（当前活动 runtime） | 用户接受 V1.r3；[source manifest](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)、[runtime manifest](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)、`64 × 16` TGA、exporter 与真实排版预演已完成；`2026-08-05` 用户确认 18 行字体、无描边／零 shadow、类型墨色和活动地区箭头显示通过。隐藏的行末追踪圈不在验收范围 | 保留至组件／整模块收口；不再生图 |
| `QL-B2` | 当前任务暗酒红书签三状态 | `P5 asset-retained / runtime-hidden` | 用户接受的 source、manifest、`128 × 16` TGA、exporter 与历史证据全部保留；`2026-07-31` 起 adapter 不再挂载或包装任务行脚本 | 暂缓；只有用户重新确认后才恢复 runtime |
| `QL-B3` | 类型、计时、完成／失败状态章 | `P3 repair-budget-exhausted` | [三段 V1 work](work/QUEST.LOG.STATUS.md) 已获授权；A `5/5` exhausted，B／C 各 `0/5` 并暂停 | 不阻塞 QL-B0 V2；等待用户以后决定 A 的色键例外／source 策略／视觉重开 |
| `QL-C` | 两套 ScrollBar、关闭、Collapse All、操作、辅助按钮与 pfQuest 六控件兼容 | `P5 runtime-integrated`；QS-B1 V7-A `P2 simulation-confirmed / production-prepared` | V6 授权批次已结束：ImageGen `28/35`、流程错误 `7`；A／B／C 未获用户接受，D／E／F／G 各自耗尽。用户保留七项独立代理结构但否决 V5-A 可见承载方向，并于 `2026-08-06` 确认 V17 火漆跨压旧骨褐誓约条带与不等距尖锐破口。自动 `42/42`、展示区 `6/6`、ImageGen `0/0`；最终 donor 正文与确定性合同已审计，无新 source/runtime/addon | 用户独立授权或否决 V7-A 最终 production；七项代理 parity 前旧按钮继续 fail-open |
| `QL-D` | 奖励槽、分隔与文字安全区 | current geometry／fallback `P6 game-validated`；final art `P2 simulation-proposed` | runtime `1.25` 保持真实 Button 的 `108×41px` 双列／`64px` 名称／`8px` 列距／`4px` 行距、setter 锁、无鼠标程序化容器、原生 `NameFrame` 抑制和可见数量兜底。所有奖励项只依赖奖励总标题或上一组奖励项，不再依赖三个分组标题，消除原生 `QuestLogItemReceiveText` 反向锚定造成的 FrameXML 环；`2026-08-05` 用户确认当前右页 bug 与显示修复通过。Theme `1.8` 奖励文字无描边。V1 模拟 0／1／2／4／6 `5/5 pass`、ImageGen `0/0`；奖励只读，无 selected | 确认最终容器美术方向；确认不等于生产授权 |

QL-A1 manifest 记录：

- `1514 × 1039` RGBA。
- SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- 透明／半透明／不透明像素：`241402／5650／1325994`。
- 可见绿色残留：`0`。
- 固定执行会话：`019fac35-620b-78d3-8b46-2e1f02105f74`。
- 物理双页接近等宽；`42%／58%` 只用于 runtime 阅读列。

## NPC Quest／Gossip

| 批次 | 范围 | 阶段 | 下一门禁 |
|---|---|---:|---|
| `QD-A` | 两外壳、两肖像、名称、关闭与五内容面板 | `P1 contract-draft` | 锁定 NPC 委托文书主视觉并实测几何 |
| `QD-B` | 五面板 × 四滚动子件；两类 Greeting Entry | Scroll `P1`／Entry `P0` | FrameXML／`/fstack` 证据 |
| `QD-C` | 八个真实操作 Button | `P1` | 四状态尺寸与点击区 |
| `QD-D` | 所需物品、奖励槽与选择覆盖 | `P1` | 奖励流程实机验证 |

当前原生 `QuestFrame`／`GossipFrame` 完整保留；没有 production Prompt、
source 或 runtime。

## 外部 Quest Tracker

| 批次 | 范围 | 阶段 | 下一门禁 |
|---|---|---:|---|
| `QT-SIM V2` | `330 × 865` 高密度容量包络；无工具条，十任务、十七目标与三类反馈 | `P2 direction-confirmed / exact-geometry-superseded` | 材料／综合色方向保留；真实 provider 高度需以新几何模拟重新确认 |
| `QT-GEO V1` | 外置纸张装饰端帽；七种真实 provider Frame 与 100% UI 像素游戏内预演 | `user-rejected / superseded` | 用户拒绝外置书框；不得接入 runtime |
| `QT-GEO V2` | 纸面严格等于 live Frame；无外置书框、端帽、页叠层、轮廓或投影 | `simulation-rendered / awaiting-user-confirmation` | 用户确认该具体模拟版本；确认前不改 runtime |
| `QT-A1 V1` | 可变宽高纸面 shell、九宫格与叠页边 | `P5 runtime-exported-temporary / display-region-blocked` | source／manifest／`256 × 512` TGA／adapter 保留；底部 `16px` 安全区已接入，继续复核横向 icon／文字安全区与动态重建 |
| `QT-A2 V1` | `HEADER.*`、皮带／徽记、七工具 Button 与 selected 压片 | `P2 scope-deferred` | provider 对象与行为原样保留；未来重开需独立模拟、新 Prompt 与新授权；当前 `0/5` |
| `QT-B1 V1` | focus 墨洗、tracked 页边墨记、complete 墨勾 | `P3 scope-deferred / user-paused / 1/5` | 不挂载三件覆盖层；旧 V1.r1 作废，未来恢复需新模拟、新版本与新授权 |

完整合同和生产正文见
[QUEST.TRACKER.CORE.md](work/QUEST.TRACKER.CORE.md)。当前不生成折叠、
timer 或 failed 资产：provider 没有可用的公开状态来源。本项目不会扫描或
接管 `QuestWatchFrame`，也不会创建第二个追踪器。

## Quest Log／Tracker 共用漆章

| 批次 | 范围 | 阶段 | 下一门禁 |
|---|---|---:|---|
| `QS-A1` | Quest Log／Tracker 共用漆章母版 | `P5 runtime-exported / page-placement-integrated / 5/5` | source／四态 atlas 保持 accepted；当前 Quest Log runtime `1.25` 直接使用 `32px` 页上 Texture，Tracker 不受影响；没有重开美术或 ImageGen | Turtle WoW 验证页上位置、TGA 方向与标题／正文安全区 |
| `QS-B1` | Quest Log ScrollChild 内火漆 Button、动态承载条、七张独立纹章与七个代理 Button | V7-A `simulation-confirmed / production-prepared / P2 / ImageGen 0/0`；V6 closed `28/35`；V5-A source retained as fallback | 用户于 `2026-08-06` 确认 V17 的 `24px` 漆章／载体相交、较窄烟熏旧骨褐誓约条带和约五个不等距尖锐破口；真实排版 `42/42`、展示区 `6/6`。最终单 donor 正文、固定 Image 1／2、受限同循环 edit 与确定性 mask／接触／runtime 合同已完整审计。无新 source/runtime，菜单未接入 | 用户独立授权或否决 `QS-B1 V7-A` 最终 production 正文与最多 `5` 次实际 ImageGen 调用；旧按钮继续 fail-open |

QS-A1 当前事实：

- source：
  `assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png`；source manifest：
  `QS-A1_SourceManifest_v1.json`；runtime manifest：
  `QS-A1_RuntimeManifest_v1.json`。
- exporter：`tools/build_quest_tool_wax_seal_v1.py`；runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestToolWaxSealStatesV1.tga`。
- 最终展示区域合同：
  `tools/specs/quest_seals_runtime_display_region_v1.json`；ignored 报告 SHA-256
  `7d84d0beb391a850f5ec84f46dd1f61230574bd105f449cd415cc3030f96e3bb`，
  Quest Log 与 Tracker `130／230／330px` 均 `pass`。最窄宽度下旧
  `search` 覆盖漆章右下部且 `giver／clean` 各触及 `1px`，但 Button 仍在
  父级装饰 Texture 上方并保留脚本、鼠标、Tooltip 与显隐。
- 接受后新增生成 `0`；正式调用仍为 `5/5`、流程错误 `0`。没有目标客户端
  证据，不得进入 P6 或清理 work／中间产物。

QT-A1 临时 runtime 事实：

- source：
  `assets/source/quests/qt-a1/QuestTrackerPaperShell_Temporary_v1.png`，
  SHA-256
  `a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b`；
- runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestTrackerPaperV1.tga`，
  `256 × 512 RGBA`，SHA-256
  `c6b1f64034fa69f01709403e592c3350445c9a6739f4b559242be48831666c61`；
- exporter：`tools/build_quest_tracker_paper_v1.py`；九宫格 cap 为
  左／右 `14px`、上 `12px`、下 `16px`；
- adapter：`Quests.lua` runtime contract `1.18`。纸面为九个无鼠标
  `BACKGROUND` Texture；provider 黑色 panel／行矩形隐藏，动态文字、图标、
  七工具 Button、模式、Tooltip、点击、拖动和 SavedVariables 保持。provider
  条目回调只置 dirty，tracker 下一次自身更新统一提交主题、宽度和
  `panel + entries + 16px` 内容安全高度；条目 icon 被立即视觉隐藏，任务名
  使用 pfUI／pfQuest 原有统一字体与动态字号，只移除描边和 shadow。
- 验证：exporter 重跑哈希稳定；Python 编译、quest design contract、
  repository contract、asset workflow skill contract、Quest Lua smoke 与
  `git diff --check` 全部通过。Lua smoke 覆盖 pfQuest 晚加载、动态 resize、
  provider `OnUpdate` 保留、接受／放弃式批次重建、底部安全高度和刷新幂等。另有
  `tools/specs/quest_tracker_display_region_v1.json` 的七场景展示区域报告：
  `fail / 35 violations`，第一失败码
  `FRAME_BELOW_NINE_SLICE_MINIMUM`；报告只在 ignored `generated/`，SHA-256
  `511dcffcf9bbb93a9e969c75d3dcb1fe10711258be85442044e3450af261801c`。
  额外失败项是 provider 未限制 `trackerfontsize` 和单任务 objective 数量，
  项目支持边界仍需冻结。
- 已拒绝的外置端帽提案 specification：
  `tools/specs/quest_tracker_external_caps_simulation_v1.json`；renderer：
  `tools/render_quest_tracker_external_caps_simulation_v1.py`。本地 ignored
  输出为 `1536 × 1024` 游戏内观感图、`1800 × 1240` 七场景板和机器报告；
  报告 `pass`，但用户拒绝其可见方向，不得接入 runtime。
- 当前 direct-paper specification：
  `tools/specs/quest_tracker_direct_paper_simulation_v1.json`，复用同一 renderer
  的零 outsets 分支。本地 ignored 输出同样覆盖游戏内高密度场景与七种真实
  provider 尺寸；报告 `pass / 7 of 7`，当前等待用户确认 `QT-GEO V2`。

## 当前验证

- 静态对象合同与 Prompt 继承测试：
  [`quest_design_contract_test.py`](../../../tests/quest_design_contract_test.py)。
- QL-A1 source manifest：
  [`QL-A1_SourceManifest_v1.json`](../../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)。
- QL-A2 runtime manifest：
  [`QL-A1_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-a1/QL-A1_RuntimeManifest_v1.json)；
  runtime SHA-256
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`。
- adapter：
  [`Quests.lua`](../../../addon/AzerothExpeditionUI/Modules/Quests.lua)；
  Lua smoke：
  [`quest_module_smoke.lua`](../../../tests/quest_module_smoke.lua)。
- QS-A1 accepted source／manifest：
  [`QuestToolWaxSeal_Master_v1.png`](../../../assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png)／
  [`QS-A1_SourceManifest_v1.json`](../../../assets/source/quests/qs-a1/QS-A1_SourceManifest_v1.json)；
  runtime manifest：
  [`QS-A1_RuntimeManifest_v1.json`](../../../assets/source/quests/qs-a1/QS-A1_RuntimeManifest_v1.json)。
  runtime `QuestToolWaxSealStatesV1.tga` SHA-256
  `f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`；
  四态 Alpha SHA-256 均为
  `f11b4072daa68b8afd3b26afbd53e8c3772e64ae26c28ae610b11f260a276e8c`。
- QL-A2 raw、透明候选与失败候选只存在于被忽略的
  `generated/quests/QL-A2/`；未晋级任何 V3.2／V3.3 候选。
- QL-B1 生产合同、五次循环与用户接受记录：
  [`QUEST.LOG.DIRECTORY.md`](work/QUEST.LOG.DIRECTORY.md)；固定执行器
  `5/5`，终态 `candidate-rejected / repair-budget-exhausted`。attempt 5
  normalized raw SHA-256
  `73f719d44a55b01d0ef8bc6f2c07343679a10b155d612941ca72d16869527596`，
  transparent SHA-256
  `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`。
  同 SHA 透明稿已晋级为
  `assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png`。
- QL-B1 runtime manifest：
  [`QL-B1_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)；
  runtime `QuestLogDirectoryMarksV1.tga` SHA-256
  `e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f`。
- QL-B1 exporter：
  [`build_quest_log_directory_marks_v1.py`](../../../tools/build_quest_log_directory_marks_v1.py)；
  adapter runtime contract `1.7`，Lua smoke 覆盖 23 行创建、四态、滚动偏移、
  原脚本、整行旧高亮抑制、顶部墨圈复用与刷新后不回生。
- QL-B2 V1 生产合同：
  [`QUEST.LOG.SELECTION.md`](work/QUEST.LOG.SELECTION.md)；当前为
  `runtime-exported / P5`，实际生图 `5/5`、流程错误 `3`；第五张 raw、
  原透明稿和预演仍只在 ignored `generated/` 作为审查证据。同 SHA 的
  bbox-fit 候选已晋级
  [`QuestLogSelectionBookmark_Master_v1.png`](../../../assets/source/quests/ql-b2/QuestLogSelectionBookmark_Master_v1.png)，
  SHA-256
  `4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa`。
  source manifest 记录用户接受、合同例外与 Alpha 证据。runtime
  `QuestLogSelectionBookmarkV1.tga` SHA-256
  `bab9e8bf6961b743d9591bb148878e9eadbbbbd99eac9a183446bf9c81a770b4`；
  三态 cell Alpha SHA-256 均为
  `2cd8de894c389f5c7eaf5c5d5388a20b363fa414022dc4dac57eacda1fa79029`。
- QL-B2 exporter：
  [`build_quest_log_selection_bookmark_v1.py`](../../../tools/build_quest_log_selection_bookmark_v1.py)；
  runtime manifest：
  [`QL-B2_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-b2/QL-B2_RuntimeManifest_v1.json)。
  三张来自最终 atlas 的真实排版 SHA-256 分别为 selected
  `bba74c3591c60efa27c3f3d9c1a3266661d76c7aff7ed46230f8ef2b1ca4baaf`、
  hover
  `eac7c0fee22ca7f7eb57449b2710588743f141745510cc6029d2b9478d7a9f40`、
  pressed
  `47397145620353eabbca33c20be67fefe9fccc84e7f1334ae577d609e6915eb6`。
- QL-B3 生产合同：
  [`QUEST.LOG.STATUS.md`](work/QUEST.LOG.STATUS.md)。三段均为
  `P3`；固定 Image 1／2、三槽真实行几何、同段 edit、每段最多五次实际
  生图和最坏 `15` 次总预算已获授权。当前 A `5/5` exhausted、B `0/5`、
  C `0/5`；A attempt 5 已通过四格安全盒、语义、美术与 10px 真实排版，
  但 native 精确 `#00FF00` 像素仍为 `0`，背景-only edit 亦发生 1px 级
  重绘漂移，已按 skill 标记 `candidate-rejected / repair-budget-exhausted`；
  三次无 provider 结果的错误与一次 provider 后处理异常均已单列，均不
  新增实际生图计数。
- QL-B3 候选审查工具：
  [`review_quest_log_status_candidate_v1.py`](../../../tools/review_quest_log_status_candidate_v1.py)；
  只在 ignored `generated/` 中确定性生成 `10px`／`10px`／`12px` 临时
  atlas、23 行真实排版和 sidecar，不晋级 source 或 addon runtime。
- Turtle WoW 实机验证已于 `2026-07-30` 开始。首次加载在
  `Modules\Quests.lua:223` 因 Lua 5.0 不支持 `original(...)` 形式的
  vararg 转发而解析失败，客户端因此完整回退到 pfUI Quest Log。adapter
  已改为固定位置参数脚本包装，并增加 Lua 5.0 静态兼容回归。复验后 shell、
  双页、23 行和 QL-B2 书签均已实际加载；同轮截图确认两项 runtime 错误：
  原生整行浅色选择层仍覆盖书签，右页正文仍沿用旧 FontString 宽度并被
  ScrollFrame 硬裁。runtime contract `1.3` 已 feature-detect 并抑制旧选择层，
  同时把右页 ScrollChild 收敛为 `224px`、普通正文 `214px`、缩进目标
  `204px`，并在 `QuestLog_UpdateQuestDetails` 后重施几何。下一轮实机图证实
  旧整行高亮已消失、右页已重新换行，但用户明确指出左页主体仍无可感知变化。
  复核确认当前 runtime 只有 `12px`／`10px` QL-B1 状态墨记和
  `24 × 14px` QL-B2 可见书签；列表内框、地区条、任务行底板和顶部工具条
  均没有独立资源，因而仍主要呈现 pfUI。该结论是 P5 视觉未通过，不是加载
  失败。runtime contract `1.4` 另隐藏 pfUI 已意图隐藏的
  `QuestLogTrackTitle`，修复上一版计数锚点暴露出的“追踪任务/20”重叠。
  当前 V1 保持 `P5 fallback`。用户随后确认 `18 × 18` V2 方向；完整重启
  后的实机图进一步确认连续纸面与十八行布局稳定，因此独立列表内框已被用户
  移除。`2026-07-31` 用户进一步接受当前书本主体，并同时移除地区条／任务条
  底板路线与酒红选择书签的 runtime 显示。contract `1.6` 转而隐藏
  Collapse All，并保留顶部任务计数／追踪控件、底部操作 Button 与右页无
  scrollbar chrome 的滚轮阅读；外部任务插件启用后的布局冲突已另列 TODO。

## 下一步

当前唯一 QS-B1 门禁是用户独立授权或否决 `QS-B1 V7-A` 最终 production
正文。用户已于 `2026-08-06` 确认
`QUEST-LOG-SEAL-PURITY-RIBBON-SIM-V17` 可见方向；本地模拟证明漆章跨压
载体、七项功能独立、动态收拢、滚动裁切、正文零重排和奖励前 `32px` 安全距，
自动 `42/42`、展示区 `6/6`。最终执行体只生成连续 smoked old-bone
vellum-linen 材质 donor；固定 Image 1／2、受限同循环 Image 3、`1024²`
归一化、固定 `[448,128,576,896]` crop、tracked `128×768` mask、QS-A1 Alpha
接触压暗、`32×192px` runtime 和最多 `5` 次实际 ImageGen 上限均已完整审计。
授权前 ImageGen 仍为 `0/0`，不上传、不启动 provider、不改 source/runtime/
addon。V5-A source 与旧按钮保留 fail-open。

以下为封闭历史，不再作为当前执行入口：

用户于 `2026-08-05` 已确认当前 Quest Log 左右页 bug 与显示修复通过；
QL-A2、当前活动左页 runtime 与 QL-D 当前几何／fallback 的实机门禁不再是
开放项。`QS-B1 V3` 正式生产授权已于 `2026-08-05` 获得并按顺序执行。
V3-A 五次实际 ImageGen 已全部使用，最终仍因 source 级连续卷曲微纹和
`9.86%` 宽高比误差未通过，状态为
`internal-rejected / repair-budget-exhausted / user-rejected`。授权规定
只有 V3-A 内部通过才执行 V3-B，因此 V3-B 保持 `0/5`。此前用户回复“可以”
所确认的 V12“动态空白背景＋七张独立透明纹章＋七个独立 Button”方向仍冻结；
V12 模拟像素仍不属于 source 或 ImageGen 输入。

生产合同现拆成两个执行体。`QS-B1 V3-A` 生成一条无纹章、无功能所有权的
连续最大长度旧亚麻布母版，固定上传任务详情锁定图和 QL-A1 accepted shell；
runtime 只裁取 `12 + visible_count × 22px` 前缀并接独立 tail，避免重复布片、
横缝和 `22px` 周期。`QS-B1 V3-B` 生成七格隔离印墨工作表，固定上传同一
任务详情锁定图和 QL-B1 accepted directory-marks source；P4 必须拆成七张
独立 RGBA source、七个 manifest ID 和七个 UV，工作表不作为单一菜单资产。
两段各最多 `5` 次实际 ImageGen 调用，最坏合计 `10` 次；流程错误没有生成
证据时不占额度。V3-A 已耗尽 `5/5` 且流程错误 `0`；V3-B 未触发。用户随后
明确指出 V3-A 的切口过于整齐、综合色太亮而显得轻浮。
`QUEST-LOG-SEAL-SUBSTRATE-SIM-V13 / QS-B1 V4-A` 已据此完成新的本地几何
预演：综合色压为烟熏深旧棕；侧边使用少量、宽幅、互不镜像且避开 `22px`
节距的偏移；尾端只有两处不等宽钝缺口；中央亮面断成短而宽的暗赭块。
V13 继续使用 V12 的真实 ScrollChild 几何、一张最大母版前缀＋tail、七张
独立纹章与七个 Button；真实排版 `40/40 pass`、display-region `6/6 pass`，
ImageGen `0/0`。用户于 `2026-08-05` 已确认 V13 可见方向；完整 V4-A
production 正文、固定 Image 1／2、同循环 edit 边界、确定性后处理与最多五次
实际 ImageGen 调用合同已于 `2026-08-05` 获用户独立生产授权，并执行至
`5/5`。第五稿的暗色宽面方向最好，但精确比例仍误差 `7.287%`，V4-A 已以
`candidate-rejected / repair-budget-exhausted` 终止。

`QUEST-LOG-SEAL-SUBSTRATE-SIM-V14 / QS-B1 V5-A` 已由用户确认。它不改变
V12／V13 的屏幕结构或综合色，只把 source 生产拆为“ImageGen 全画幅连续布面
donor”和“tracked 固定 crop／deterministic mask”。mask 独占精确
`128×696` 外轮廓、Alpha 与两处双钝缺口，accepted 对象必须是组合后的
composite，不是 raw donor。V14 六态真实排版 `46/46 pass`、继承展示区合同
`6/6 pass`、ImageGen `0/0`。用户已于 `2026-08-05` 独立授权固定 Image 1／2、
square donor 同轴归一化、固定 crop／deterministic mask、透明 RGB 清零、受限
同循环 Image 3 edit 和最多五次实际调用。attempt 1–4 已计入 `4/5`；attempt 4
以固定 Image 1／2＋紧邻 attempt 3 raw 完成受限 edit，擦除横贯中央 crop 的两道
外溢，并通过自动 `18/18`、六态 `29/29`、display-region `6/6` 与完整美术内审。
用户于 `2026-08-06` 已明确接受 attempt 4 composite；精确 bytes 已固化为
[`QuestLogSealMenuSubstrate_Master_v1.png`](../../../assets/source/quests/qs-b1/QuestLogSealMenuSubstrate_Master_v1.png)
及 [source manifest](../../../assets/source/quests/qs-b1/QS-B1_SourceManifest_v1.json)，
当前为 `source-accepted / P4 / production 4/5`。流程错误 `1`，因通过即停，
attempt 5 未调用，跨设备 handoff 已消费。此次接受只覆盖空白连续布底；不接受
raw donor、七枚独立纹章、runtime 或菜单接入。
旧 V3-B 授权要求 V3-A 先通过，而 V3-A 已失败；其近黑印墨放在 V5-A 深色
accepted 布底上也缺少可读对比，故不能直接执行。新的
`QUEST-LOG-SEAL-MOTIFS-SIM-V15 / QS-B1 V5-B` 已直接使用 accepted source 在
真实六态排版中提议六项哑光旧赭金矿物颜料与放弃项灰暗酒红；本地自动
`51/51 pass`、V15 display-region `6/6 pass`、ImageGen `0/0`。用户于
`2026-08-06` 在独立生产授权尚未开放的上下文中回复“接受”，确认六项哑光
低饱和旧赭金矿物颜料与放弃项灰暗酒红的综合色方向；几何纹章仍只是本地
占位，不属于 source 或未来 edit input。完整、自包含的 V5-B production
Prompt、七格 safe box、七张独立 source、四态 atlas 与五次自主修复边界已
准备并通过完整性审计。用户于
`2026-08-06` 已独立授权
V5-B 最终 production 正文、每次固定 Image 1／2、同循环紧邻前稿的受限
Image 3 edit，以及最多五次实际 ImageGen 调用；流程错误无图片证据时不占
额度。

固定 0.143.0 child 的六次无生成流程错误已在用户明确“重试”后恢复。V5-B
随后完成五次实际 generation，每次都在失败记录和下一完整正文提交后继续，
最终达到 `5/5`。attempt 5 已修正底排四槽并清空第八格，综合色回到平面两色
颜料；但自动仍为 `10/12`：仅 ABANDON 位于 safe box，其他六项持续被模型
放在错误纵向行位并被固定 cell crop 截断，RESET 有 `44` 个封闭绿像素。
因此终态为 `candidate-rejected / repair-budget-exhausted / P3 / 5/5`，禁止
attempt 6。用户已选择七张单对象 source 新版本；V16 已把 SHARE／DETAIL／
SHOW／HIDE／CLEAN／RESET／ABANDON 分成七个独立 `1024²` production body，
同时用 accepted V5-A 布底完成原六场景真实排版，自动 `59/59 pass`、展示区
`6/6 pass`、ImageGen `0/0`。用户于 `2026-08-06` 回复“接受”，因此当前为
`simulation-confirmed`。V6-A..G 七份完整、自包含正文、固定 Image 1／2、
同段 edit 边界与修复合同随后由用户于 `2026-08-06` 以原文明确授权。该批次
已封闭执行：实际 ImageGen `28/35`、流程错误 `7`；A／B／C 只形成内部候选，
D／E／F／G 各自耗尽。用户随后保留结构但否决综合色与物理装配，A／B／C
未进入 P4，V6 不再是当前执行入口。后续
runtime 若重开仍必须按
manifest 确定性导出 `32×174` 布底，并一一代理原 Button、镜像
禁用态、保留放弃确认，并在任一 provider 未捕获时原子 fail-open；七纹章和
七项代理 parity 完成前不接入菜单，也不隐藏放弃／分享／退出／详情或 pfQuest
四按钮。

[QL-D V1 奖励槽方向](work/QUEST.LOG.REWARDS.md) 仍是独立开放视觉门禁，
不被 QS-B1 的确认或授权自动覆盖。

Quest Log 的类型色、详情字体、金额、奖励容器／锚点与内容末端裁切修复已经
进入 runtime `1.25`／Theme `1.8`，并由本次用户实机结论确认。QL-D V1
正式容器尚未生产，当前暖纸 fallback 不代表最终美术；旧顶部悬空漆章位置
不再作为待接受方向。

Tracker `34px` 漆章仍按既有合同在 `130／230／330px` 居中，继续等待实机
验证 `SetClampRectInsets`、拖动恢复、TGA 方向与旧七按钮层序。Tracker hub
menu 仍是另一独立范围，不能用本次 Quest Log 菜单授权替代。

QL-A2 保持 [runtime work](work/QUEST.LOG.GUTTER.md)，当前活动范围已进入
`P6 user-confirmed`，但尚未规划 P6-C 清理。以下条目从开放门禁转为后续
回归清单；QS-B1 接入或 Quest Log runtime 再变化时仍需复测：

- 18 条活动任务行在滚动、地区展开和等级重写后仍保持 `246 × 18` 行盒、
  `226px` 文字安全区和 `pfUI.font_default` 的 `12px`、空 flags、零 shadow；
  `19..23` 不闪回，
  完成／地下城提示使用同一字体，且原点击／Shift 追踪行为不变；
- online／language 始终位于右页顶部工具行；在事务菜单接入前
  show／hide／clean／reset 仍位于右页底部四格，六个 provider 控件的点击、
  OnUpdate、显隐和禁用都保持；
- 确认 Collapse All 在两种场景都不可见、不可点击且不会被外部 `Show()`
  恢复；
- 菜单接入前底部放弃／共享／退出／详情按钮继续可用；接入后逐项验证菜单代理
  与 fail-open fallback，放弃必须继续出现原生确认；
- `QuestLogItemReceiveText`／`QuestLogRequiredMoneyText` 保持自适应宽度，右侧
  MoneyFrame 完整位于 ScrollChild；长正文换行后动态高度包含原生
  `QuestLogSpacerFrame` 末端，不留空尾、不截断奖励，0／1／2／4／6 奖励的
  `108px` 双列槽均完整位于右页；
- 左右页滚动条始终不显示，长任务列表与正文仍可用鼠标滚轮滚到首尾；
- 任务行右侧不出现原生／AEUI 追踪圈，不出现酒红书签或旧整行浅色高亮；
- 同一任务在 Quest Log 与 Tracker 的任务名难度墨色一致，五档色在左页不再
  发淡；所有团队／精英／地下城 Tag 在普通、选中、悬停与离开后都保持同一
  深紫任务类型墨；完成率／完成／失败提示保持各自深墨语义色，不再出现原生
  荧亮黄／绿；两个同排奖励 backdrop 之间保留真实可见空隙，4／6 奖励不重叠。

pfQuest tracker 当前在 [QT V2 work](work/QUEST.TRACKER.CORE.md) 为
`P5 / display-region-blocked`。历史结构证据继续固定为：

- 结构参考：
  [`01_external_quest_tracker_current_state.png`](../../../assets/references/quests/session-2026-07-31/01_external_quest_tracker_current_state.png)，
  `363 × 865`，SHA-256
  `88ecd502e190311c8709a6fd15e2cde6d1f5f288a749e5f5b318f7038e188504`；
- Quest Log 兼容失败证据：
  [`02_third_party_quest_plugin_layout_failure.png`](../../../assets/references/quests/session-2026-07-31/02_third_party_quest_plugin_layout_failure.png)，
  `1009 × 629`，SHA-256
  `36e172e15ea6c6939d4f2e784131ff0e9a9a51a926aaec046a95a21af5361faf`；
- 两图只用于信息层级、真实密度与复现，不继承其字体、颜色、现代按钮或
  其他美术表现。`QT-SIM V2` 已由本地脚本用简单几何和代表性排版生成，参考图
  没有上传或进入模拟像素，ImageGen 固定 `0/0`。V2 刻意不绘制工具条，只供
  tracker 主体材料／综合色方向判断，不代表 runtime 删除按钮，也不再作为
  精确 Frame 高度证据。用户已于 `2026-07-31`
  确认 V2 可见方向，确认条款已写回 QT-A1／B1 最终正文。用户随后独立授权
  两段的固定上传、同段 edit 边界和各 `5` 次实际调用上限。QT-A1 五次原始
  生成循环虽耗尽，随后临时例外 source/runtime 已接入；QT-B1 在 `1/5`
  后由用户暂停，QT-A2 继续 `scope-deferred 0/5`。当前下一门禁不是继续
  ImageGen 或直接实机 P6，而是用本地简单几何提出 cap 外扩或 live 内边距
  方案，以 provider 公式的空／短／典型／密集／二十五条上限／数据库／
  任务给予者七场景重新确认。

QL-B0 V2 的内框与两类底板均已由用户移出范围，不再等待 source 例外，也不
继续 ImageGen。QL-B2 的 accepted source、atlas、manifest 与 exporter 保留，
但 runtime 显示暂停；恢复前必须重新确认，在此之前不得清理 work 或删除资产。
QL-B3-A／B／C V1 已获明确授权；当前
A 已按五次上限停止。等待用户决定是否授权 attempt 4／5 的确定性色键合同
例外、改变 source 策略重开 A，或拒绝现有视觉。决定前不执行 B／C、
不晋级 source／runtime。QL-A2／B1 当前活动 runtime 已获本轮用户实机确认。
每个 countable output 后必须完成真实排版内审与边界内自主修复。不得继续
调用 QL-B2 V1 ImageGen。QL-B1 的旧计数保留为当时流程的历史事实，不作为
新口径先例。
