# Chat 详细进度

## 当前结论

- 主模块视觉：已锁定。
- Tab 替换方向：`CHAT.TABS.DARK.V2 / simulation-confirmed / production-draft / P2`。V1 固定
  0.143.0 循环已耗尽 `5/5`，流程错误 `2`；attempt 3 虽是唯一通过原冻结
  cell、真实排版与展示区域的候选，但用户于 `2026-08-04` 否决其轮廓过于
  工整，四态首先像现代网页标签，因此已转为 `candidate-rejected`，不得进入
  P4 或作为 edit 输入。V2 改以旧 V3 的斜梯形皮签、外撇端部、手工缝线误差、
  selected 夹页层和 Tab／承托带物理关系为轮廓权威，同时保留深胡桃烟褐、
  无大面积浅纸 selected、无贯穿亮金 shelf。已用当前 Full V1 主框、Dark V1
  输入、真实消息密度和精确 `440 × 320`／`540 × 420` 布局完成纯本地几何
  对照预演；三场景 display-region `0` violations，ImageGen `0/0`、上传 `0`、
  addon 未改。用户于 `2026-08-04` 在看到该具体预演后回复“继续”，确认旧式
  不规则皮签、深胡桃烟褐、压暗 selected 夹页、无连续亮金 shelf、原尺寸和
  层序方向；模拟像素未被接受。完整 V2 生产正文、四张固定输入职责、
  `1536×1024` 五 cell、三段伸缩、安全区、色键和 `0/5` 修复包络已经通过
  完整性预检；新技术 scaffold SHA 为 `f02fba2d…565a9`。当前等待独立生产
  授权；尚未上传或调用 ImageGen，runtime 仍加载 V3。
- 输入视觉生产：`CHAT.INPUT.DARK.V1.r3 attempt 4 / runtime-exported / P5`。用户指出
  V3 浅金输入纸带在 Full V1 暖黑书页上会被读成现代进度条；已按真实
  `380 × 25px`、普通／聚焦两态、三段横向伸缩、`34/22px` 文字 inset，使用
  当前 Full V1 书框、V3 Tab 与真实聊天密度完成本地几何预演。候选把输入改为
  夹在书页下沿的暖烟草抄写纸条，普通 `#403024`、聚焦 `#503A25`，反馈只用
  页叠、短暖光、纸浆局部响应和接触暗部；五个实际场景 display-region `0`
  violations。
  用户于 `2026-08-03` 明确接受 `CHAT.INPUT.DARK.V1-SIM`，并随后独立授权
  `CHAT.INPUT.DARK.V1` 完整正文、固定三张 SHA 参考、最多五次实际 ImageGen
  调用与循环内紧邻前次输出的冻结 edit 边界。完整性预检通过；模拟 ImageGen
  `0/0`、生产 `4/5`、流程错误 `4`。attempt 4 不上传 Image 4，只用固定
  Image 1／2／3 regenerate，得到两层薄烟熏 rag-paper 纸条；不再有重复卷曲
  压花、缝线、长导线或连续 focus 金边。共享 Alpha、candidate-self 色键、
  `380×25/480×25` 真实排版和五场景展示区域均通过，自主循环已在首个内部
  通过候选处停止。用户于 `2026-08-03` 明确接受精确 `.r3 attempt 4` 进入
  `P4`；透明归一源已保存为
  `assets/source/chat/input-dark-v1/ChatInput_Dark_V1_r3.png`，SHA-256
  `4df36bc607a024ca0a2355f5d20ff985f61cbf3304073a65e33caa978c50cda0`，并建立
  source manifest。剩余一次 ImageGen 终止且不转移。随后在不调用 ImageGen 的
  P4→P5 阶段，只从该固定 source 裁切两个 `1386 × 176` canonical cell，按
  `8/121/932/1016` 切线导出 `1024 × 256` `ChatInputDarkV1.tga`；最终 TGA
  SHA-256 `43cb9a01…766`，RGBA 像素与 P4 审查逻辑 atlas 完全一致。五个最终
  真实排版场景、`380 × 25`／`480 × 25` 横向伸缩、共享 Alpha、透明 RGB 和
  display-region 均通过。adapter 只把三枚 slice 媒体映射切到新 TGA；输入
  文字、焦点、光标、IME、历史、频道头、键盘事件、命中几何、pfUI、ChatMOD
  和 SavedVariables 均未改。生成证据与 V3 回退按 P6-C 门禁保留。
- 当前 runtime：`CHAT.CORE / runtime-exported / P5`，contract `1.21`。其中
  `CHAT.FRAME.FULL.V1.r1` 资产合同保持 `1.19`：固定 P4 source 已按全图比例导出为 `1024²`
  `ChatBookFrameFullV1.tga`，九个 slice 只挂载唯一左框；五个最终 TGA 真实排版
  场景和 display-region 均通过，violations `0`。暖黑阅读区继续无
  glow／outline／shadow；v1.21 已移除 AEUI 的基础 RGB、内嵌色、pfUI 出口和
  ChatMOD 最终出口改色链，目标客户端／pfUI／ChatMOD 的经典颜色逐字节透传。
  `CHAT.INPUT.DARK.V1` 资产合同仍为 `1.20`；两个确定性导出都没有 ImageGen
  调用。整体仍待 Turtle WoW `/reload`，不得标记 `P6`。
- 暗色候选方向：`CHAT-DARK-SIM-V1 / simulation-confirmed / P2`。用户提出把
  羊皮纸压到接近黑色，以恢复熟悉的 Vanilla 职业／频道色；现已用纯本地
  确定性几何完成 A（当前 `#CDA155` 亮纸＋v1.18 深墨）／B（`#18120D`
  暖黑烟熏纸＋接近 Vanilla 识别色）同场对照。两个实例都严格为
  `440 × 320`、`380 × 248` 正文安全区、12px／15px、15 条可见行且无截断，
  展示区域合同两场景通过。用户于 `2026-08-02` 明确选择 B，并要求保持现有
  合理尺寸与资源布局。模拟 ImageGen `0/0`、无上传，像素被忽略且禁止进入
  source／runtime／生产输入。`CHAT.FRAME.PAPER.V1 / candidate-rejected / P3`
  已把正式对象收窄为单一暖黑旧纸表面 donor；已提前固定 `1608 × 978`
  母版、Alpha、九宫格切线、`440 × 320` 装配、Tab／输入 atlas，并以本地 mask
  确认只会替换纸面和页叠表面，不重画皮革、缝线、黄铜或整本书。完整生产
  提示词、唯一固定上传图和最多 `5` 次调用修复包络已写入 work。
  用户于 `2026-08-02` 明确授权该版本、固定 SHA 的唯一 Image 1 及固定
  `npx @openai/codex@0.143.0` 子进程机制。attempt 1 已在 session
  `019fc0b0-167a-7ad1-9489-1a07d1f7d066` 完成，实际 ImageGen `1/5`；raw
  SHA-256 为
  `5e45c11b1a8a902e27e1912eac6488bee3f945cd6445bd962a4efdf2fe5c233c`。
  单一暖黑旧纸对象、确定性 mask 装配、Alpha 与 mask 外字节、现有
  `440 × 320` 九宫格、典型 15 行／最大 16 行排版，以及空／最小／典型／最大
  四种展示场景均通过内部审查；但用户于 `2026-08-02` 明确退回：暖黑 donor
  与未重绘的金色页边／旧皮革仍像拼接。首个失败门禁为材料连续性／整体物件
  身份，剩余 `4` 次终止且不转移。新建
  `CHAT.FRAME.FULL.V1 / simulation-reviewed / P2`，改为只把同一固定 V3
  母版作为结构比例参考，让纸面、页叠、皮革、黄铜、阴影、磨损与光照在一次
  edit 中整体重绘，禁止旧像素 mask 合成；Tab、文字、输入和未读仍独立。
  `CHAT-FULL-SIM-V1` 以本地几何完成 15／16 行两个 `440 × 320` 实例，空／
  最小／典型／最大／`540 × 420` 扩展五个展示场景全部通过。新模拟 ImageGen
  `0/0`、上传 `0`，完整生产正文已写入 work。用户于 `2026-08-02` 明确确认
  `CHAT-FULL-SIM-V1`，并授权 `CHAT.FRAME.FULL.V1` 完整正文、固定 SHA 的
  唯一 Image 1、新 `0/5` 预算及一个固定 `@openai/codex@0.143.0` 子进程。
  attempt 1 在纸／皮身份区分门禁失败；只针对该门禁的完整 `.r1` 由 commit
  `c28d6b3` 固定。用户随后明确允许 `.r1` 使用剩余预算并额外启动一个固定
  `@openai/codex@0.143.0` 子进程。attempt 2 已在 session
  `019fc27e-f6fb-7d90-ac30-5fbdfef99c11` 实际生成，累计 ImageGen `2/5`；raw
  SHA-256 为
  `8275b815b19677fda2fe242b79a06557af90032e570841236cab41ec429917b5`。
  完整书体、整体材料连续性、禁止烘焙内容和暖黑纤维纸／皮革身份全部通过。
  provider 烘焙的 RGB 棋盘背景已仅用该候选自身像素做确定性透明清理；
  `1608 × 978 RGBA` 审查副本 SHA-256 为
  `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`，
  四边透明留白为 `24/25/24/26px`。`2026-08-03` macOS 复核发现旧审查
  副本外沿仍有 `95` 个 `alpha=1..26` 的绿键优势 RGB 像素；确定性工具只用
  候选自身邻域替换这 `95` 个 RGB，Alpha 与不透明像素均未改变，最终
  `inspect_candidate.py` 的纯绿／高绿计数为 `0/0`，不涉及 ImageGen、上传、
  source 或 runtime。
  `440 × 320` 空／最小／15 行／16 行及 `540 × 420` 22 行扩展场景均无截断，
  display-region 五场景 violations `0`。用户于 `2026-08-03` 明确接受
  `CHAT.FRAME.FULL.V1.r1 attempt 2` 进入 `P4`。精确候选已保存为
  `assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，SHA-256
  `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`，并建立
  source manifest；实际 ImageGen 最终为 `2/5`，剩余 `3` 次终止且不转移。
  该 source 接受进入 `P4` 时 V3 正式 TGA、Lua 和 v1.18 runtime 均未改变；
  后续确定性 P5 导出见本节首条。
- 历史核心批次：`CHAT.CORE.V3 / runtime-corrected / P5`；runtime contract
  v1.18 保留 v1.15 的左书 Parent 唯一作用域、v1.14 的三层最终输出桥、
  v1.11 的无阴影旧字体、v1.8 的 `3px` 行距、v1.7 书本自愈和 v1.6 pfUI
  解锁缩放链。v1.17 为扩大任意色差，把战士改成铁锈红并把小队／团队合并为
  同一钴蓝；最新两张实机图证明这种重新分配破坏了玩家对原版职业／频道色的
  识别习惯，同时 DPSMate 的 `#FF8080`／`#8CFF80` 报告色仍在书页上过亮。
  v1.18 改为保留 Vanilla 色相、只压低明度：说话／公共／系统／公会／小队／
  团队／密语／警告／表情九类分别使用中性、深玫瑰、赭黄、绿、蓝紫、焦橙、
  洋红、红、橙褐；小队 `#3B3B59` 与团队 `#623100` 明确分开。九职业使用原始
  RGB 的等比例深色版本，战士恢复棕褐 `#4B3B2A`，牧师为中性 `#333333`。
  已知常用内嵌色继续确定性映射；未知第三方颜色只在代表纸色上低于 `4.8:1`
  时等比例压暗，足够深的自定义色保持原样。基础频道与职业色在 `#CDA155`
  上仍约为 `4.5:1` 或更高，不恢复发光、描边、阴影或正文底色。消息内容、
  `|H...|h` 链接载荷、ChatMOD 配置与历史保持原样；不修改全局 `ChatTypeInfo`、
  SavedVariables 或其他 pfUI 模块。Lua 语法、Chat／pfUI／Quest smoke、
  repository／quest design／asset workflow 契约均通过；尚待 `/reload`。
- 运行时：插件 `0.6.0` 已加载 Full V1 主框、V3 四状态 Tab、普通／聚焦输入
  和独立未读覆盖；静态测试通过，旧 V3 主框 TGA 保留为 P6-C 前回退。
- 容器：只保留 `pfChatLeft`。`pfChatRight` 默认强制隐藏，原本分流到右框的
  拾取、经验、荣誉、声望与技能消息组回收到 `ChatFrame1`。
- 尚未完成：language、聊天弹出菜单、URL copy、chatcopy、whisper proxy 的
  最终美术；这些对象保持原生或默认不加载。
- 用户此前决定延后 `CHAT.TEXT` 的字体、描边和频道色可读性改造，并于
  `2026-08-01` 先单独授权 v1.8 修复 `2px` 行距。随后实机截图确认文字虽不再
  粘连，但 pfUI 的全方向 `OUTLINE`、满字面中文字体与高频纸纹仍造成明显
  视觉疲劳；用户同日明确要求直接实施 v1.9 舒适阅读方案。v1.9 不改频道色或
  消息内容，只接管受管正文的字体、阴影、`3px` 行距和连续压光层。最新实机
  随后确认浅粉公共频道仍与羊皮纸缺少对比，且 `10%` 压光已形成可见矩形；
  用户要求执行局部频道墨色方案并恢复旧字体，形成 v1.10。v1.10 实机截图又
  显示 `(1,-1)` 投影在旧字体与当前缩放下形成大面积重影；用户要求取消阴影，
  形成 v1.11。用户随后确认阴影问题已经解决，但要求统一修正全部文本颜色，
  并补充当前聊天增强 provider 为 ChatMOD。源码与当前 SavedVariables 审计
  确认 ChatMOD 1.1 正在注入时间戳、职业玩家名、等级难度、URL 与自身高亮；
  用户明确要求直接实施且不经过 Figma，形成 v1.12。v1.12 实机截图仍显示
  原始亮青／浅粉色；加载链审计确认初次布局后的 provider 晚出现与
  ChatMOD 在原 wrapper 之后注色、直达 `ORG_AddMessage` 都可能绕过 v1.12，
  因而增加晚加载发现并同时守卫真正的最终出口，形成 v1.13。用户确认
  `chat-runtime=1.13` 后截图仍未改变；再次审计移除函数身份／`isDocked`
  门禁，并把色板直接桥接进 pfUI Chat 最终输出，形成 v1.14。用户随后报告
  `m2/h3/f3/c30/x5` 始终不变，证明第三个可见 Frame 被 `pfCombatLog` 启发式
  排除；v1.15 将左书 Parent 设为唯一颜色作用域。用户随后确认颜色已经出现，
  但频道／职业之间过于接近；v1.16 首次扩大色差后仍被最新实机反馈退回，
  v1.17 改用色相优先和最近色距离门禁。此前下一项
  曾选择复用 pfUI `chatcopy` 逻辑；
  固定 ImageGen 0.143.0
  已按用户授权分别执行 `CHAT.COPY.V1` A／B，但 A 错生为完整第二聊天框，
  B 错生为四个现代方形文档按钮；两者均在范围与对象身份门禁被内部退回。
  `CHAT.COPY.V1.1 / candidate-rejected / P3` 已按用户授权用固定
  ImageGen 0.143.0 执行到 A：单纸对象身份和安静中心通过，但主体外接比例
  相对 `380:248` 偏差 `+1.70%`，上下边中段的独特缺口、撕裂和卷边违反
  九宫格 stretch-zone 合同；照片式纸纤维与中性光也是次要美术漂移。
  因此未做 Alpha、预演或 source，B1 scaffold／B1 raw／B2 均未创建或
  上传。当前活跃版本已升级为
  `CHAT.COPY.V1.2 / candidate-rejected / P3`：A 不再调用 ImageGen，而从已接受
  V3 安静纸面确定性派生精确 `1140 × 744` 候选，分别锁定
  `1092 × 696` 九宫格 stretch center 与 `1080 × 696` 文字安全区；
  B1／B2 使用同一 `22:26` 外接框的 closed／open scaffold 与确定性 mask，
  ImageGen 只承担纸叶和皮夹表面。用户已于 `2026-07-29` 明确授权
  `CHAT.COPY.V1.2`，并允许上传 B1 closed scaffold、通过 mask 的 B1
  candidate 与 B2 open scaffold。A 的确定性候选和两种九宫格预演通过内部
  审查；B1 固定执行器的两次完整调用均输出 `1254 × 1254`，把对象放大到
  scaffold 外，并把纯绿底改成渐变。第一个失败门禁是 B1 画布／外接框／
  色键结构，故未做 mask，B2 没有上传或调用。chatcopy 继续默认不加载。
  `CHAT.COPY.V1.3 / candidate-rejected / P3` 已按用户授权完成纯本地确定性
  构建：A 保持 V1.2 已通过的 SHA；固定 SHA 的 V1.2 第一次 B1 raw 只读
  提供表面，全程没有 ImageGen、网络访问或外部上传。B 的画布、共同外接框、
  polygon、Alpha、图层和 off／on 局部变形均通过技术门禁；但在真实
  `22 × 26` 尺寸下，两状态的 Alpha 差异均值只有 `0.021/255`、最大
  `7/255`，并排与 `440 × 320` 装配预演均几乎无法分辨开合；两页夹同时
  退化成浅色矩形书签。第一个失败门禁是运行时状态语义／组件身份，因此
  内部退回，未创建 source、runtime 或 Lua，chatcopy 继续默认不加载。
  用户于 `2026-07-30` 判断该功能对体验提升不明显并明确暂缓；不再准备
  V1.4，只有用户主动恢复时才重开门禁。下一项改为已随 `chat.lua` 加载、
  点击 URL 即可见的 `CHAT.URLCOPY.V1 / prompt-draft / P2`：静态审计确认
  shell／input／close 分别为 `270 × 65`、`250 × 20`、`70 × 18`。V1 只
  新生成一个无字抄录便笺 shell；input 复用 V3 normal／focus 输入纸带，
  close 复用 V3 Tab 材料并由 runtime 表达 pushed，避免重复生产低价值
  资产。尚未上传参考、调用 ImageGen 或修改 runtime。用户随后于
  `2026-07-30` 要求该项也暂缓，优先处理对体验更关键的大面积 UI；V1
  草案与审计证据保留，但不再占用当前生产门禁。
- Turtle WoW 实机：原始 runtime 截图确认 `FCF_DockUpdate` 覆盖停靠几何，
  且用户否决 `42px` 外接高度。随后两张复测截图仍由未同步的 Git HEAD
  安装副本产生，未加载 v1.1／v1.2，因此不构成版本验收。v1.2 正确部署后
  确认点击 Tab 可恢复紧凑尺寸，但登录首帧不会自动完成；同时选中文字过暗、
  点击区偏上。v1.3 复测后 Tab 尺度和选中文字已可进入下一轮，但新截图显示
  TabText 仍沿用 pfUI 底边锚点，且某次交互后的正文退回 pfUI 默认边距并越出
  书页。v1.4 继续复测发现改变缩放后默认 Tab 仍需点击一次才生效；v1.5
  虽增加 `UI_SCALE_CHANGED` 强制重放，但实机确认问题没有变化。代码审计
  随后确认 pfUI 解锁模式缩放直接调用 `pfChatLeft:SetScale` 与
  `pfChatLeft.OnMove`，并不走 v1.5 监听的全局事件。当前仍为 `P5`，不能
  标记 `P6`。`2026-07-31` 最新截图又显示四枚 AEUI Tab 存在而书本主体
  未显示；v1.7 已增加自愈与模块失败隔离，但还没有实机复测结论。
- pfUI `panel` 模块与配置页正常加载；视觉上仍隐藏贴附聊天框的左右两条信息
  Panel（左：公会／护甲／好友；右：帧率与延迟／时间／金币），并以 `OnShow`
  guard 防止 pfUI 刷新后重现。独立小地图 Panel 不受影响；旧全局回退 profile
  首次加载仍迁移回 pfUI 默认槽位，关闭 AEUI Chat 后可由 pfUI 正常恢复。

## 子模块状态

| ID | 阶段 | 当前资产／实现 | 下一门禁 |
|---|---:|---|---|
| `CHAT.FRAME`／`LEFT` | `P5` Full V1 / r1.19 | `ChatBookFrameFullV1.tga` 九宫格；唯一左侧实例；最终 atlas SHA `becb504f…25ae`；旧 V3 主框仅作回退 | `/reload` 检查主体、九宫格接缝、缩放、拖动和常用 UI Scale |
| `CHAT.FRAME.RIGHT` | `P5` disabled-route | `single_chat_frame=1`；不分配资产 | 验证右框不显示且消息无丢失 |
| `CHAT.TABS` | 当前 runtime `P5` V3；替换 `P2` V2 simulation-confirmed／production-draft | V1 attempt 3 已由用户否决；用户已确认 V2 旧式斜梯形皮签、外撇端部、手工缝线、压暗夹页层及深色低亮 shelf 方向。完整生产正文、固定 Image 1–4、五 cell scaffold 与 `0/5` 包络已就绪；无上传、ImageGen `0/0`、runtime 未改 | 用户独立授权 `CHAT.TABS.DARK.V2` 固定四输入、受限 Image 5 edit 与最多五次实际 ImageGen；“继续”不等于生图授权 |
| `CHAT.INPUT` | `P5` `CHAT.INPUT.DARK.V1` / r1.20 | `ChatInputDarkV1.tga` 普通／聚焦两状态三段式 atlas；固定 source SHA `4df36bc…cda0`，最终 TGA SHA `43cb9a01…766`，共享 Alpha、最终真实排版与五场景 `0` violations；旧 V3 atlas 仅作回退 | 实机验证 normal/focus、输入文字、光标、IME、频道头、历史、键盘事件与 `380/480px` 伸缩 |
| `CHAT.INPUT.LANGUAGE` | `P1` | 可选原生 Button 已映射 | 实机确认对象、尺寸和语言状态 |
| `CHAT.UNREAD` | `P5` V3 | 独立 `ChatFrameNTabFlash` 覆盖 | 实机验证闪烁配置与选中清除 |
| `CHAT.TEXT` | `P5` classic-provider pass-through / r1.21 aggregate | `380 × 248`／约 16 行；pfUI 配置字体、用户字号、无描边／无阴影、`3px` spacing、无额外背景层；客户端、pfUI 与 ChatMOD 的基础和内嵌颜色不再由 AEUI 改写 | 实机确认频道／职业／物品／ChatMOD／DPSMate 颜色与经典 provider 输出一致 |
| `CHAT.FRAME` 暖黑替换源 | `P5` `CHAT.FRAME.FULL.V1.r1` runtime-exported | `1608 × 978` 固定 source 经确定性 exporter 生成 `1024²` TGA；50 个 Lanczos 低 Alpha 绿振铃像素仅清零 RGB，Alpha 不变；最终纯绿／高绿 `0/0`，五场景 `0` violations | Turtle WoW 目标客户端实机 P6；P6-C 前保留 source、证据和 V3 回退 |
| `CHAT.SCROLL.*`／`MENU.BUTTON`／`RESIZE` | `P1` hidden | 原生对象已登记，pfUI 当前隐藏 | 仅在决定恢复时建立资产合同 |
| `CHAT.POPUP.*` | `P1` | 四个原生菜单实例已映射，仍为过渡外观 | 实机拆分 shell、行状态和滚动 |
| `CHAT.URLCOPY.*` | `P2` V1 prompt-draft / user-deferred | 三个真实对象与现有锚点已锁定；只新生成 shell，input／close 复用 V3 接受资产；用户于 `2026-07-30` 暂缓；当前 pfUI 功能继续可用 | 仅在用户明确恢复该功能时重新开放授权门禁 |
| `CHAT.COPY.*` | `P3` V1.3 candidate-rejected / user-deferred | A 候选继续通过；B 技术合同通过但真实尺寸状态不可辨认；用户认为体验收益不明显并于 `2026-07-30` 暂缓；pfUI 逻辑保持未加载 | 仅在用户明确恢复该功能时准备新版本 |
| `CHAT.WHISPER.TOGGLE` | `P5` route／`P1` object | 功能源码保留，默认不加载 | 锁定代理开关视觉 |
| `CHAT.WHISPER.DIALOG` | `P1` shared-owner | 归未来 System 公共弹窗 | System 模块统一拆分 |

## 正式运行时

| 文件 | 画布 | 运行时职责 |
|---|---:|---|
| `ChatBookFrameFullV1.tga` | `1024 × 1024` | 当前左侧暖黑旧书九宫格 |
| `ChatBookFrameV3.tga` | `1024 × 1024` | P6-C 前保留的旧主框回退 |
| `ChatTabAtlasV3.tga` | `512 × 512` | 普通／悬停／选中／禁用 Tab |
| `ChatTabShelfV3.tga` | `1024 × 64` | 连续承托带 |
| `ChatInputDarkV1.tga` | `1024 × 256` | 当前普通／聚焦暖烟草输入纸条 |
| `ChatInputAtlasV3.tga` | `1024 × 256` | P6-C 前保留的旧浅金输入回退 |
| `ChatUnreadSealV3.tga` | `64 × 128` | 未读覆盖 |

源资产与 provenance：
[V3 source manifest](../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)；
[暖烟草输入 source manifest](../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_SourceManifest_v1.json)。
裁切、UV、画布和 runtime SHA：
[V3 runtime manifest](../../../assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json)；
[暖烟草输入 runtime manifest](../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_RuntimeManifest_v1.json)。

## 跨设备插件接入审计（2026-08-04）

- Chat 的可部署接入链已经存在于当前分支，不需要在游戏设备重新开发：
  `a7ba939` 建立 V3 runtime、AEUI TOC／bootstrap 和 pfUI 单书路由；
  `501cac4` 接入 Full V1 主框；`5640716` 接入 Dark V1 输入；`06327bf`
  移除 AEUI／pfUI 消息改色桥并恢复 classic-provider 透传。
- 加载入口为
  [`AzerothExpeditionUI.toc`](../../../addon/AzerothExpeditionUI/AzerothExpeditionUI.toc)：
  `RequiredDeps: pfUI`，先加载 `Core\\Bootstrap.lua`，再加载
  `Modules\\Chat.lua`。Bootstrap 提供媒体根、逐模块 `pcall` 隔离、延迟刷新
  和 `/aeui status`；Chat adapter 当前自报 `1.21 / classic-provider`。
- adapter 的五个真实媒体映射均在可部署 addon 内：Full V1 九宫格主框、V3
  Tab atlas、V3 承托带、Dark V1 normal／focus 输入 atlas、V3 未读蜡封。
  Full V1 TGA SHA-256 为 `becb504f…25ae`，Dark V1 TGA 为
  `43cb9a01…766`；runtime manifests 对应文件和哈希已复核。
- [`addon/pfUI/modules/chat.lua`](../../../addon/pfUI/modules/chat.lua) 保留聊天
  数据、事件、历史和 SavedVariables，只实现 scoped single-journal route：
  右框被关闭，拾取／经验／荣誉／声望／技能消息回收到 `ChatFrame1`，同时为
  AEUI 管理的 Tab／TabText Region 保留布局所有权。左右聊天信息 Panel 由
  AEUI Chat adapter 隐藏，小地图 Panel 不受影响。
- fresh-checkout package validator：macOS 使用
  `conda run -n py312 python` 运行
  [validate_addon_package.py](../../../.codex/skills/run-aeui-asset-workflow/scripts/validate_addon_package.py)，
  报告 `generated/chat/core/addon-package-report.json`，SHA-256
  `8216aa78…ae36`；schema `aeui-addon-package-report-v1`，四个 addon、五份
  TOC、`538` 个 tracked runtime 文件、`26` 条 manifest runtime 记录，
  `status=pass`、violations `0`、`build_required_on_target_device=false`。
  报告是可复现且被忽略的本地证据，不作为跨设备资产。
- 静态结论：Chat 已满足新的 addon-package-ready P5 门禁。另一台设备只需
  拉取仓库并把 `addon/pfUI` 与 `addon/AzerothExpeditionUI` 放入
  `Interface/AddOns`；测试 Quest 时再一并安装 `addon/pfQuest` 与
  `addon/pfQuest-turtle`。无需运行 ImageGen、exporter、Python、patch 或修改
  Lua／pfUI。该结论不替代 Turtle WoW `/reload` 与交互 P6。

## 当前证据

- [`build_chat_v3_runtime_assets.py`](../../../tools/build_chat_v3_runtime_assets.py)
- [`build_chat_full_frame_v1_runtime.py`](../../../tools/build_chat_full_frame_v1_runtime.py)
- [`render_chat_full_frame_runtime_v1.py`](../../../tools/render_chat_full_frame_runtime_v1.py)
- [`chat_full_frame_runtime_test.py`](../../../tests/chat_full_frame_runtime_test.py)
- [`build_chat_input_dark_v1_runtime.py`](../../../tools/build_chat_input_dark_v1_runtime.py)
- [`render_chat_input_dark_runtime_v1.py`](../../../tools/render_chat_input_dark_runtime_v1.py)
- [`chat_input_dark_runtime_test.py`](../../../tests/chat_input_dark_runtime_test.py)
- [`chat_module_smoke.lua`](../../../tests/chat_module_smoke.lua)
- [`pfui_expedition_contract_test.lua`](../../../tests/pfui_expedition_contract_test.lua)
- [`validate_addon_package.py`](../../../.codex/skills/run-aeui-asset-workflow/scripts/validate_addon_package.py)
- 当前 adapter：[`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua)
- 活跃批次：
  [`work/CHAT.CORE.V3.md`](work/CHAT.CORE.V3.md)
- 已暂缓的 Chat copy 工作：
  [`work/CHAT.COPY.V1.md`](work/CHAT.COPY.V1.md)
- 已暂缓的 URL Copy 草案：
  [`work/CHAT.URLCOPY.V1.md`](work/CHAT.URLCOPY.V1.md)
- 首轮实机失败证据：
  [`04_chat_tabs_p5_game_failure.png`](../../../assets/references/chat/session-2026-07-29/04_chat_tabs_p5_game_failure.png)
- 第二轮高度失败证据：
  [`05_chat_tabs_p5_height_failure.png`](../../../assets/references/chat/session-2026-07-29/05_chat_tabs_p5_height_failure.png)
- 未同步部署证据：
  [`06_chat_tabs_stale_deployment.png`](../../../assets/references/chat/session-2026-07-29/06_chat_tabs_stale_deployment.png)
- v1.3 文字／正文布局失败证据：
  [`07_chat_tab_text_content_overflow.png`](../../../assets/references/chat/session-2026-07-29/07_chat_tab_text_content_overflow.png)

`assets/source/chat/v3/previews/` 中旧合成图仍包含已退役底栏，只作为历史 source
证据，不再作为当前运行时验收依据。新的无底栏预演由工具写入被忽略的
`generated/chat/v3/`。

## 下一步

### 当前优先门禁

1. `CHAT.TABS.DARK.V2` 已完成模拟确认和生产正文完整性预检，固定 Image 1–4、
   五 cell scaffold 与新 `0/5` 包络已就绪；下一门禁是用户独立授权该精确
   正文、四张固定 SHA 输入、受限同循环 Image 5 edit 和最多五次实际
   ImageGen。授权前不上传、不调用、不改 addon。
2. `CHAT.INPUT.DARK.V1.r3 attempt 4` 已完成确定性 P4→P5：固定 source、正式
   `ChatInputDarkV1.tga`、三段 adapter、最终 TGA 真实排版、display-region 与
   静态合同均已通过；导出阶段 ImageGen `0` 次，原生产仍为 `4/5`、流程错误
   `4`，剩余一次永久停止且不转移。下一门禁是目标客户端实机验证输入焦点、
   光标、IME、频道头、历史、键盘事件以及 normal/focus 可辨识度。
3. `CHAT.FRAME.FULL.V1.r1` 已完成 P4→P5：最终 TGA、九宫格 adapter、暖黑
   纸面、五场景真实排版和 display-region 均已验证；v1.21 另行移除消息改色
   wrapper 并恢复经典 provider 配色。本阶段 ImageGen
   `0` 次，原批次总计仍为 `2/5`，剩余三次终止且不转移。
4. 游戏设备可用后仍需执行 Turtle WoW `1.18.1` `/reload` P6 门禁；当前不
   清理 source、runtime 证据或 V3 回退。

### 仍保留的 v1.21 实机门禁

1. 在 Junction 指向当前仓库的客户端执行 `/reload`；确认 `/aeui status`
   报告 `chat-runtime=1.21` 与 `chat-color=classic-provider`。分别观察说话、
   公共频道、系统、公会、小队、团队、密语、警告和表情新消息，确认与客户端
   经典默认值一致，而不是 AEUI 暖黑纸面映射色。
2. 检查九职业、物品品质、ChatMOD 时间戳／等级／URL／自身高亮，以及 DPSMate
   红绿报告；确认内嵌 `|cAARRGGBB`、Alpha 和链接载荷均未被提亮、压暗或改写。
3. 先确认九宫格书本主体与承托带正常、正文区域不再出现矩形压光；确认正文
   恢复 pfUI 旧字体、没有黑色全描边或任何文字重影，并保留 `3px` 额外行距。
   等待新消息，逐项确认时间戳为亮青、公共正文为浅玫瑰，职业／物品／URL／
   等级／自身高亮保留语义且可读；再检查系统、公会、队伍、密语、警告与
   表情消息的角色区分。旧历史行不会重绘；若任一模块失败，记录 AEUI 单次
   打印的具体 `module <name> <method> failed` 信息。
4. 打开 pfUI 解锁界面，在 `pfChatLeft` 拖动层上连续滚轮切换至少三档局部
   Scale；全程不点击 Tab，确认每档四枚 Tab 都立即应用新比例。
5. 再切换至少两档全局 UI Scale；不点击 Tab，确认 EffectiveScale 边沿兜底
   同样只重放一次并应用新比例。
6. 检查四枚 Tab 文字是否同时水平、垂直居中，并从皮革主体中下部切换频道。
7. 依次切换 Tab、尝试拖动后松开、触发停靠保存，确认正文始终保留
   `30/30/32/40px` 安全区且不会越出书页。
8. 再验证左框滚动、Tab 四状态、未读、输入焦点、链接、聊天历史与
   `540 × 420`／常用 UI Scale。
9. 确认右框始终隐藏，并验证拾取、经验、荣誉、声望与技能消息仍进入左框。
10. 核心批次实机通过后达到 `P6`，但保留 work 与 legacy 回退资产直至用户批准
   `P6-C` 清理清单。
11. `CHAT.COPY` 与 `CHAT.URLCOPY` 均保持暂缓；不上传参考、不调用 ImageGen、
   不创建 source／runtime，也不恢复新加载项。
12. 当前资产优先级移交大面积主窗口；Chat 只继续核心 V3 实机门禁。
    `CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*` 与 `CHAT.WHISPER.TOGGLE` 后续再排期。
