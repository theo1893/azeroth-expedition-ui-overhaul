# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- 用户于 `2026-07-31` 接受当前游戏内书本主体，并明确要求停止增加列表内框、
  地区条或任务条底板；后续只处理书本外的真实控件与交互反馈。
- `2026-07-31` 已完成魔改版 `pfQuest 7.0.1` 与
  `pfQuest-turtle 7.0.2` 的源码审计。布局失序来自 `pfQuest/quest.lua`
  后加载替换 Quest Log 刷新入口、再次调用 `QuestLogTitleButton_Resize`，
  并把六个 provider 控件塞入详情 ScrollChild；`pfQuest-turtle` 只扩展
  数据，没有独立 UI 写入。
- `2026-08-03` Quests runtime contract 已升至 `1.17`、共享主题升至 `1.6`。
  任务列表不再强制霞鹜文楷，改为继承 `pfUI.font_default` 的统一界面字体、
  `12px OUTLINE` 并清除额外 shadow，修复“字体与其他模块不一致／文字过细”。
  右页在 `214px` 正文和 `204px` 目标重新换行后，会以最底部真实动态对象
  重算 ScrollChild 高度并调用 `UpdateScrollChildRect()`；奖励双列槽收敛为
  `108px`、名称安全宽 `64px`，修复奖励横向／纵向被裁。Lua smoke 已覆盖
  字体、四个奖励槽、动态内容高与滚动范围；仍待目标客户端验证。
- 同日用户否决 Quest Log 漆章的旧顶部悬空锚点，并要求把底部分享／放弃等
  功能收纳到漆章。V1 外沿皮革事务签在进一步物理语义复核中也被淘汰：火漆
  若附着书框就没有封住文书。现已按用户要求完成
  V2 预演因伪页唇、二段式硬质按钮轮廓和断开的弹窗语义被用户否决；V3 又
  误用右侧横向方位；V4 虽修复下缘竖向锚点，却把书签拉成长吊坠，并新增
  覆盖右页的大型二级纸面，用户明确评价为过长、难看且图层不和谐。现已完成
  `QUEST-LOG-SEAL-ACTIONS-SIM-V5` 本地确定性关闭／展开两态预演：书签总高
  从 `125px` 收短为 `78px`，相对实际可见书框只露出约 `36px`；QS-A1 火漆
  仍完整压在纸张末端。点击后不画第二张纸，而是复用原
  `detail=[366,64,246,324]` shell UV，把同一右页动态内容切换为七项事务墨字；
  外壳、纸面、页缘和 z-order 不变。ImageGen `0/0`，
  当前为 `simulation-reviewed / awaiting-user-confirmation`；未修改火漆 runtime，
  未隐藏任何旧按钮。
- AEUI Quest Log provider 兼容子合同保持 `1.7`：在 provider 最终刷新后以
  事件驱动方式恢复 18 条列表行与右页正文安全区，将 online／language 搬至
  右页固定顶部工具行，将 show／hide／clean／reset 搬至右页固定底部四格；
  所有 provider OnClick／OnUpdate、显隐、禁用、ID 和数据行为保持。没有使用
  维护型 `OnUpdate` 几何争夺；late-load 与幂等 smoke 已通过，仍待实机。
- `2026-08-01` 共享主题建立为 `Quest Visual Theme 1.5`，当前已由上方
  `2026-08-03` 的 Theme `1.6` 字体修订覆盖。Quest Log 的卷宗书体与
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
  状态提示，不再把整个任务名染成另一种颜色。该次“霞鹜文楷／空 flags”
  字体决定已被 `2026-08-03` 的 runtime `1.17` 明确覆盖；其他布局和语义色
  结论继续有效。无新位图、无 ImageGen。
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
- `QL-A2 V4`：`runtime-exported / P5`。用户于 `2026-07-30` 确认 QL-A1
  单一静态背景、`676 × 464`、list-only 不缩窄书体和 `GUTTER.*` 静态
  归属。确定性 exporter 已生成 `1024 × 512` TGA 与 runtime manifest；
  AEUI adapter 把它挂在 `QuestLogFrame` 的非交互背景层，隐藏原生装饰
  Texture，但保留动态文字、列表、详情、原操作 Button、脚本和
  SavedVariables。缺少详情切换时只创建真实 Button。任务行、两套
  ScrollBar、按钮状态、奖励槽与状态覆盖的最终美术仍属于 QL-B/C/D。
- `QL-B`：已完成目录对象与状态来源复核。旧 P5／V1 runtime 曾保留 pfUI
  23 行，以 `15px` 行高／`14px` 步进占用 `323px`；实机已确认这种密度
  和仅有小墨记／书签的资产范围不足以形成可感知的左页改造。用户确认 V2
  改为 `QUESTS_DISPLAYED = 18`、`18px` 步进，总占高 `324px`；runtime
  `1.17` 在隐藏页边 scrollbar 后进一步把每行扩到完整 `246px`，文字安全宽
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
  exporter 和 adapter 已 tracked，当前为 `runtime-exported / P5`；固定
  执行器仍是 `5/5` 且接受后没有新增调用。
- `QL-B0／B1 runtime`：Quests runtime contract 已升至 `1.17`。继续创建／
  复用 `QuestLogTitle1..23` 以兼容 provider，但只显示 `1..18`，使用
  `246 × 18` 行盒／`18px` 步进和真实滚动偏移。地区箭头仍由
  `GetQuestLogTitle` 驱动；任务行追踪圈全部隐藏，追踪数据和 Shift 点击行为
  保留。覆盖 Texture 不接管点击；原行脚本、选择、滚动与 SavedVariables 保留。实机发现的
  `QuestLogHighlightFrame` 与行内 highlight／pushed 旧选择视觉
  已在每次刷新后透明抑制。主标题使用 Noto Serif SC，任务与状态行恢复为
  `pfUI.font_default` 的 `12px OUTLINE` 并清除额外 shadow。V2 阅读密度现已
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
  fail-open fallback；`QUEST-LOG-SEAL-ACTIONS-SIM-V5` 未确认前不隐藏。
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
| `QL-A2` | 静态空卷宗结构与页沟 | `P5` V4 runtime-exported | V3.3 `15/15` 已终止；V4 已从 QL-A1 source 导出 `676 × 464` 显示区／`1024 × 512` TGA，固定执行器 `0/0`，Lua smoke 通过 | Turtle WoW 验证纹理方向、裁切、命中与 list-only |
| `QL-B0` | 左页列表几何；内框、地区条与任务条底板均已撤销 | V1 `P5 fallback`；V2 `P3 user-rejected / scope-removed` | A 在 `4/5` 后由用户移出范围；B `5/5` 耗尽后也于 `2026-07-31` 被用户移出范围；均无 source/runtime，见 [work](work/QUEST.LOG.LEFTPAGE.md) | 保持当前连续书页，不再增加框或底板 |
| `QL-B1` | 地区展开／收起、追踪开／关四枚墨记 | `P5 runtime-exported` | 用户接受 V1.r3；[source manifest](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)、[runtime manifest](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)、`64 × 16` TGA、exporter 与真实排版预演已完成；内部失败与 `5/5` 事实保留 | Turtle WoW 验证 TGA、四态切换、字体和 fallback |
| `QL-B2` | 当前任务暗酒红书签三状态 | `P5 asset-retained / runtime-hidden` | 用户接受的 source、manifest、`128 × 16` TGA、exporter 与历史证据全部保留；`2026-07-31` 起 adapter 不再挂载或包装任务行脚本 | 暂缓；只有用户重新确认后才恢复 runtime |
| `QL-B3` | 类型、计时、完成／失败状态章 | `P3 repair-budget-exhausted` | [三段 V1 work](work/QUEST.LOG.STATUS.md) 已获授权；A `5/5` exhausted，B／C 各 `0/5` 并暂停 | 不阻塞 QL-B0 V2；等待用户以后决定 A 的色键例外／source 策略／视觉重开 |
| `QL-C` | 两套 ScrollBar、关闭、Collapse All、操作、辅助按钮与 pfQuest 六控件兼容 | `P5 runtime-integrated`；seal-menu `P2 simulation-reviewed` | 既有 late-load 兼容和原 Button fallback 保留；V2–V4 已否决，V5 收短底部书签，并直接在原 detail 书页切换七项事务内容，不新增纸面或层级，尚未接入 | 用户确认 `QUEST-LOG-SEAL-ACTIONS-SIM-V5` 后实现同页模式；再做实机点击／禁用／详情恢复／确认框验证 |
| `QL-D` | 奖励槽、分隔与文字安全区 | geometry `P5 runtime-integrated`；final art `P1–P2` | runtime `1.17` 已把双列槽收敛为 `108px`／名称 `64px`，按真实最底对象重算 ScrollChild；奖励只读，无 selected | 实机覆盖 0／1／2／4／6 奖励和长中文正文；最终槽美术另行确认 |

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
| `QS-A1` | 两处共用漆章母版；Quest Log 新承载／事务菜单不改母版 | asset `P5 runtime-exported / 5/5`；Quest Log placement `P2 simulation-reviewed` | 漆章 source／atlas 保持 accepted；旧悬空锚点及 V1–V4 承载均不再作为方向；V5 短书签与原 detail 同页事务模式等待确认 | 用户确认或退回 `QUEST-LOG-SEAL-ACTIONS-SIM-V5`；确认前不改 runtime、不隐藏 fallback |

QS-A1 当前事实：

- source：
  `assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png`；source manifest：
  `QS-A1_SourceManifest_v1.json`；runtime manifest：
  `QS-A1_RuntimeManifest_v1.json`。
- exporter：`tools/build_quest_tool_wax_seal_v1.py`；runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestToolWaxSealStatesV1.tga`。
- 最终展示区域合同：
  `tools/specs/quest_seals_runtime_display_region_v1.json`；ignored 报告 SHA-256
  `2f027e5459148da600835653e481f42ac535b2c1a2d44e1e43ad456587d2a97c`，
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
- adapter：`Quests.lua` runtime contract `1.17`。纸面为九个无鼠标
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

当前离线门禁是用户审查 `QUEST-LOG-SEAL-ACTIONS-SIM-V5`。可确认的是：短
羊皮纸书签是否仍正确从 detail 下缘竖着夹入、约 `60px` 可见长度与 `32px`
漆章的重量是否合适，以及点击后直接在原 detail 书页切换七项事务墨字、完全
不新增二级纸面的层级方案是否和谐；模拟不确认最终纸
纤维、折痕／磨损、客户端字体栅格、动画或右侧屏幕 clamp。用户确认前不实现
菜单、不移动 runtime 漆章，也不隐藏
放弃／分享／退出／详情与 pfQuest 四按钮。确认后实现必须一一代理原 Button、
镜像禁用态、保留放弃确认，并在任一 provider 未捕获时 fail-open。

Quest Log 的字体／奖励裁切修复已经进入 runtime `1.17`，下一次游戏设备验证
同时启用 pfQuest／pfQuest-turtle，覆盖：18 行字体与字重；长中文正文滚动到
完整奖励；0／1／2／4／6 奖励双列；provider 后加载；鼠标滚轮动态范围。旧
顶部悬空漆章位置不再作为待接受方向。

Tracker `34px` 漆章仍按既有合同在 `130／230／330px` 居中，继续等待实机
验证 `SetClampRectInsets`、拖动恢复、TGA 方向与旧七按钮层序。Tracker hub
menu 仍是另一独立范围，不能用本次 Quest Log 菜单授权替代。

QL-A2 保持 [runtime work](work/QUEST.LOG.GUTTER.md)，不得进入 `P6`／清理。
Quest Log 静态兼容已完成，下一门禁是在游戏设备同时启用 pfQuest 与
pfQuest-turtle 后验证：

- 18 条活动任务行在滚动、地区展开和等级重写后仍保持 `246 × 18` 行盒、
  `226px` 文字安全区和 `pfUI.font_default` 的 `12px OUTLINE`，额外 shadow
  为零；`19..23` 不闪回，
  完成／地下城提示使用同一字体，且原点击／Shift 追踪行为不变；
- online／language 始终位于右页顶部工具行；在事务菜单接入前
  show／hide／clean／reset 仍位于右页底部四格，六个 provider 控件的点击、
  OnUpdate、显隐和禁用都保持；
- 确认 Collapse All 在两种场景都不可见、不可点击且不会被外部 `Show()`
  恢复；
- 菜单接入前底部放弃／共享／退出／详情按钮继续可用；接入后逐项验证菜单代理
  与 fail-open fallback，放弃必须继续出现原生确认；
- 长正文换行后 ScrollChild 动态高度不留空尾、不截断奖励，0／1／2／4／6
  奖励的 `108px` 双列槽均完整位于右页；
- 左右页滚动条始终不显示，长任务列表与正文仍可用鼠标滚轮滚到首尾；
- 任务行右侧不出现原生／AEUI 追踪圈，不出现酒红书签或旧整行浅色高亮；
- 同一任务在 Quest Log 与 Tracker 的任务名难度墨色一致，五档色在左页不再
  发淡；完成率／完成／失败／任务类型提示保持独立深墨语义色，且不再出现
  原生荧亮黄。

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
不晋级 source／runtime。QL-A2／B1 当前 runtime 继续等待后续实机复核。
每个 countable output 后必须完成真实排版内审与边界内自主修复。不得继续
调用 QL-B2 V1 ImageGen。QL-B1 的旧计数保留为当时流程的历史事实，不作为
新口径先例。
