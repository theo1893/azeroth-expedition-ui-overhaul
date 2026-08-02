# Chat 详细进度

## 当前结论

- 主模块视觉：已锁定。
- 暗色候选方向：`CHAT-DARK-SIM-V1 / simulation-confirmed / P2`。用户提出把
  羊皮纸压到接近黑色，以恢复熟悉的 Vanilla 职业／频道色；现已用纯本地
  确定性几何完成 A（当前 `#CDA155` 亮纸＋v1.18 深墨）／B（`#18120D`
  暖黑烟熏纸＋接近 Vanilla 识别色）同场对照。两个实例都严格为
  `440 × 320`、`380 × 248` 正文安全区、12px／15px、15 条可见行且无截断，
  展示区域合同两场景通过。用户于 `2026-08-02` 明确选择 B，并要求保持现有
  合理尺寸与资源布局。模拟 ImageGen `0/0`、无上传，像素被忽略且禁止进入
  source／runtime／生产输入。`CHAT.FRAME.PAPER.V1 / candidate-reviewed / P3`
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
  四种展示场景均通过内部审查；循环已停止，剩余 `4` 次未使用。首次启动前的
  sandbox 拒绝仍记为非计数流程错误 `E1`。下一门禁是用户复审纸面与皮革的
  材质边界；当前亮纸基线、V3 source、正式 TGA、Lua 和 v1.18 runtime 均未改变。
- 核心批次：`CHAT.CORE.V3 / runtime-corrected / P5`；runtime contract
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
- 运行时：插件 `0.6.0` 已加载 V3 主框、四状态 Tab、普通／聚焦输入和独立
  未读覆盖；静态测试通过。
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
| `CHAT.FRAME`／`LEFT` | `P5` V3 / r1.18 | `ChatBookFrameV3.tga` 九宫格；唯一左侧实例；现有维护节拍在贴图缺失／隐藏／版本过期时重建；r1.18 继续停用旧正文压光 texture，不改正式 TGA | `/reload` 确认主体恢复且书页上不再出现矩形色块，再检查接缝、缩放、拖动 |
| `CHAT.FRAME.RIGHT` | `P5` disabled-route | `single_chat_frame=1`；不分配资产 | 验证右框不显示且消息无丢失 |
| `CHAT.TABS` | `P5` V3 / r1.18 | `92 × 30` 四状态 atlas；沿用 r1.6 的 TabText、命中与 Scale 修正；r1.18 不修改 Tab 资产／几何 | 在书本主体恢复后复测 pfUI 解锁滚轮与全局 UI Scale |
| `CHAT.INPUT` | `P5` V3 | 普通／聚焦两状态三段式 atlas | 实机验证焦点、IME、输入历史 |
| `CHAT.INPUT.LANGUAGE` | `P1` | 可选原生 Button 已映射 | 实机确认对象、尺寸和语言状态 |
| `CHAT.UNREAD` | `P5` V3 | 独立 `ChatFrameNTabFlash` 覆盖 | 实机验证闪烁配置与选中清除 |
| `CHAT.TEXT` | `P5` parchment-palette / r1.18 | `380 × 248`／约 16 行；pfUI 配置字体、用户字号、无描边／无阴影、`3px` spacing、无额外背景层；频道／职业保留 Vanilla 色相并降低明度，小队与团队分色；未知亮色连续压暗 | 实机确认团队焦橙／小队蓝紫、战士棕褐及其余职业仍符合原版识别，同时 DPSMate 红绿报告不再发亮 |
| `CHAT.FRAME`／`CHAT.TEXT` 暖黑候选 | `P3` `CHAT-DARK-SIM-V1` confirmed／`CHAT.FRAME.PAPER.V1` candidate-reviewed | B 已确认；attempt 1 只生成单一暖黑旧纸 donor，确定性 mask 保留 V3 母版、Alpha、皮革／黄铜、九宫格、`440 × 320` 布局与独立 Tab／Input atlas；当前实际生成 `1/5`、流程错误 `E1`，对象／技术／装配／15–16 行真实排版与四场景展示区域均通过，剩余四次未使用；无 tracked source／runtime 变更 | 用户复审 attempt 1，重点确认极深烟熏纸是否仍明确区别于旧皮革；接受后只晋级 P4 source／manifest |
| `CHAT.SCROLL.*`／`MENU.BUTTON`／`RESIZE` | `P1` hidden | 原生对象已登记，pfUI 当前隐藏 | 仅在决定恢复时建立资产合同 |
| `CHAT.POPUP.*` | `P1` | 四个原生菜单实例已映射，仍为过渡外观 | 实机拆分 shell、行状态和滚动 |
| `CHAT.URLCOPY.*` | `P2` V1 prompt-draft / user-deferred | 三个真实对象与现有锚点已锁定；只新生成 shell，input／close 复用 V3 接受资产；用户于 `2026-07-30` 暂缓；当前 pfUI 功能继续可用 | 仅在用户明确恢复该功能时重新开放授权门禁 |
| `CHAT.COPY.*` | `P3` V1.3 candidate-rejected / user-deferred | A 候选继续通过；B 技术合同通过但真实尺寸状态不可辨认；用户认为体验收益不明显并于 `2026-07-30` 暂缓；pfUI 逻辑保持未加载 | 仅在用户明确恢复该功能时准备新版本 |
| `CHAT.WHISPER.TOGGLE` | `P5` route／`P1` object | 功能源码保留，默认不加载 | 锁定代理开关视觉 |
| `CHAT.WHISPER.DIALOG` | `P1` shared-owner | 归未来 System 公共弹窗 | System 模块统一拆分 |

## V3 正式运行时

| 文件 | 画布 | 运行时职责 |
|---|---:|---|
| `ChatBookFrameV3.tga` | `1024 × 1024` | 左侧旧书九宫格 |
| `ChatTabAtlasV3.tga` | `512 × 512` | 普通／悬停／选中／禁用 Tab |
| `ChatTabShelfV3.tga` | `1024 × 64` | 连续承托带 |
| `ChatInputAtlasV3.tga` | `1024 × 256` | 普通／聚焦输入纸带 |
| `ChatUnreadSealV3.tga` | `64 × 128` | 未读覆盖 |

源资产与 provenance：
[source manifest](../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)。
裁切、UV、画布和 runtime SHA：
[runtime manifest](../../../assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json)。

## 当前证据

- [`build_chat_v3_runtime_assets.py`](../../../tools/build_chat_v3_runtime_assets.py)
- [`chat_module_smoke.lua`](../../../tests/chat_module_smoke.lua)
- [`pfui_expedition_contract_test.lua`](../../../tests/pfui_expedition_contract_test.lua)
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

1. `CHAT.FRAME.PAPER.V1` attempt 1 已完成固定子进程生成与完整内部审查；实际
   `1/5`，剩余四次未使用。单一 donor、确定性装配、真实 `440 × 320` 排版与
   四场景展示区域均通过，source、正式 TGA 与 Lua 未修改。
2. 用户复审原始暖黑纸 donor 与 100% 布局预演，重点确认正文综合色感和纸／
   皮革边界。接受后只晋级 P4 source／manifest；退回时先停下，因为当前补充
   授权不允许再启动另一个 Codex／npx 子进程。

### 仍保留的 v1.18 实机门禁

1. 在 Junction 指向当前仓库的客户端执行 `/reload`；确认 `/aeui status`
   报告 `chat-runtime=1.18`。分别观察小队与团队新消息，确认前者为蓝紫、后者
   为焦橙；再检查战士棕褐、牧师中性和其余职业是否仍接近原版识别色，并确认
   DPSMate 报告中的浅红／浅绿已变为深红／深绿而不发亮。
2. 再次执行 `/aeui status`，确认 `chat-color` 的 `c/x` 随可见新消息增长；
   当前三帧布局下 `m/h/f` 预期仍为 `3/3/3`。若 Frame 数量变化，则 `m` 应与
   当前 Parent 为左书的 Frame 数量一致。
3. 先确认九宫格书本主体与承托带正常、正文区域不再出现矩形压光；确认正文
   恢复 pfUI 旧字体、没有黑色全描边或任何文字重影，并保留 `3px` 额外行距。
   等待新消息，逐项确认时间戳为深青黑、公共正文为暖棕墨、职业／物品／URL／
   等级／自身高亮保留语义但不再发亮；再检查系统、公会、队伍、密语、警告与
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
