# Chat 核心 V3

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.FRAME`、`CHAT.FRAME.LEFT`、`CHAT.TABS`、`CHAT.INPUT`、
  `CHAT.UNREAD`、`CHAT.TEXT`
- 版本：`CHAT.CORE.V3 / runtime contract v1.18`
- 子状态：`runtime-corrected`
- 项目阶段：`P5`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 当前操作：保留 v1.15 的左书 Parent 唯一作用域、v1.14 的三层最终输出桥、
  v1.11 的旧字体与无描边／阴影、`3px` 行距、压光层退役和书本自愈；根据
  v1.17 实机“部分插件色过亮、团队与小队同色、职业／频道偏离原版识别色”
  反馈，取消任意 RGB 距离优先策略，改用 Vanilla 原色相的等比例深墨版本，
  单独拆分小队与团队，并为未知第三方亮色增加保留色相的连续压暗；
  本版本直接修改 runtime，不经过 Figma，未生图、未修改已接受 source 或 atlas
  像素，也未修改外部 ChatMOD 文件／配置
- 并行候选视觉方向：`CHAT-DARK-SIM-V1 / simulation-confirmed / P2`；用户已
  选择 B（`#18120D` 暖黑纸面＋接近 Vanilla 的识别色）。当前只固定
  可见方向与生产边界；v1.18 runtime、已接受 source、正式 TGA 与稳定
  美术基线仍保持不变
- 并行生产批次：`CHAT.FRAME.PAPER.V1 / prompt-authorized / P3`；用户已授权
  固定 V3 母版作为唯一 Image 1，同一生产正文最多 5 次实际 ImageGen
  调用；当前 `0/5`
- 锁定视觉基准：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 游戏内物件身份、紧凑尺度和香草 HUD 综合色感
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 手绘页边、旧皮革和实体厚度；不继承固定槽、龙饰或对称结构
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - 历史执行正文：Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- source：
  - [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
  - [`ChatTabs_Master_v3.png`](../../../../assets/source/chat/v3/ChatTabs_Master_v3.png)
  - [`ChatControls_Master_v3.png`](../../../../assets/source/chat/v3/ChatControls_Master_v3.png)
- source manifest：
  [`ChatV3_SourceManifest_v1.json`](../../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)
- runtime manifest：
  [`ChatV3_RuntimeManifest_v1.json`](../../../../assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json)

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图及 Chat 主／子模块 Prompt。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实对象、状态、几何和单左框合同。
4. 三张已接受 V3 source，只承担各自物理组件与材料连续性。

### 必须继承的视觉 DNA

- 屏幕左下角一本长期携带、反复修补的厚战地旧书。
- 纸张第一、深胡桃旧皮革第二、氧化黄铜第三。
- 左上暖光、低饱和暖赭／烟褐色域、二维手绘位图和非镜像磨损。
- 正文阅读区安静连续；Tab 是皮革索引签，输入是浅纸带，未读是小型蜡封。

### 本批组件级转译

- `CHAT.FRAME` 只导出空九宫格书框并挂载到 `pfChatLeft`。
- `CHAT.TABS` 使用一条承托带和同点击几何的四状态三段式 atlas。
- `CHAT.INPUT` 使用普通／聚焦两行三段式 atlas，焦点不改变 Frame 几何。
- `CHAT.UNREAD` 只覆盖 `ChatFrameNTabFlash` 的显示语义。
- `CHAT.TEXT` 继续由 runtime 绘制；频道签可使用霞鹜文楷，正文恢复 pfUI
  配置字体且不使用描边、文字阴影或外发光；基础消息类型与已审计内嵌颜色
  使用同一低饱和深色语义墨色板，保留职业／品质／链接等色相身份；书页不
  增加连续压光或半透明面板。

### 明确不继承

- 不导出旧母版中的公会／背包／延迟或复用底栏字段。
- 不为 `pfChatRight` 生成第二本书。
- 不把文字、Tab、输入、未读、语言按钮、弹出菜单或复制控件烘焙进主框。
- 不继承锁定独立资源中的龙饰、尖顶、固定槽和规则对称金属建筑。

### 冲突审计

- pfUI 原始设计允许右侧 Loot & Spam 框；用户明确只保留一个左侧聊天框。
  裁决为禁用 `C.chat.right.enable`、隐藏 `pfChatRight`，并把五类消息组回收到
  `ChatFrame1`，不能用隐藏造成数据丢失。
- 历史 source 预演包含已退役底栏；当前模块 Prompt 与用户决策优先。
  exporter 不裁切该字段，新预演只显示普通／聚焦输入纸带。
- V3 source 早于当前 manifest 工作流，原始 generation session／result ID
  未留存。manifest 明确记录 `null` 与 provenance gap，不伪造 ID。

## 组件合同

- 逻辑对象与数量：一个左侧书框；一个 Tab 承托带；每个可见左侧 Tab 一套
  三段式状态；一个三段式输入框；每个 Tab 一个独立未读覆盖。
- Tab 状态：normal／hover／selected／disabled。
- 输入状态：normal／focus。
- runtime 几何：书框最小 `440 × 320`；正文 `380 × 248`，受管窗口使用
  `12px` 用户字号基线与 `3px` `SetSpacing` 形成约 `15px` 行高和约 16 行
  中文；正文安全区不增加覆盖层；四枚 Tab 基准 `92 × 30`、间距 `3px`、
  顶部偏移 `2px`，Tab panel 高 `32px`，
  承托带高 `16px` 且顶部偏移 `18px`；超过四枚时按承托区等宽收缩；
  Tab 命中区仅向下扩展 `8px`；输入 `380 × 25`；未读 texture
  `16 × 32`、可见标记约
  `14 × 22`。
- TabText：锚到所属 `ChatFrameNTab` 的 `CENTER`，水平各留 `6px`，高
  `18px`，水平 `CENTER`／垂直 `MIDDLE`。
- 拉伸：书框九宫格；Tab 和输入仅横向三段式；状态切换不改 Parent、Point、
  Width、Height 或点击框。
- 布局所有权：首次 `Apply`，以及 `pfUI.chat.RefreshChat`、
  `FCF_SelectDockFrame`、`FCF_DockUpdate` 和 `FCF_SaveDock` 返回后检查
  合同；只修复发生偏移的 Tab、TabText 或正文锚点。登录／刷新后 `0.5s`
  再执行一次终局装配；周期 `Maintain` 只更新状态 UV。拖动锁期间只记录
  一次待布局，解锁后的下一帧执行一次，不持续抢写。
- 缩放例外：pfUI 解锁模式会直接执行 `pfChatLeft:SetScale`，随后调用
  `pfChatLeft.OnMove`，不保证触发 `UI_SCALE_CHANGED`。adapter 包装真实
  `OnMove` 回调，只在 LocalScale／EffectiveScale 数值变化时立即强制重放
  一次 panel、所有 docked Tab、TabText、正文锚点和命中区；普通拖动不
  强制重放。现有维护节拍只比较 EffectiveScale 边沿，以捕获
  `UIParent:SetScale` 等无事件路径；全局事件仍保留为兜底。
- Alpha：所有 TGA 为 RGBA、2 的幂；Tab cell 和 shelf 含至少 4px atlas
  间隔；source 不直接加载。
- 文字颜色：基础消息 RGB 只在与当前 `ChatTypeInfo` 精确匹配时按 Vanilla
  语义角色映射；内嵌颜色优先替换审计白名单中的八位 `|cAARRGGBB` 前缀，
  未知颜色只有在代表纸色上低于 `4.8:1` 时才等比例压低 RGB。相同转换同时
  挂在 pfUI `HookAddMessage` 解析出口与 ChatMOD `ORG_AddMessage` 最终出口，
  以覆盖两种加载顺序；足够深的未知色、`|H...|h` 链接载荷、消息参数和 Alpha
  原样转发；当前 Parent 为左书的全部 Frame 均受管，包括被 pfUI 启发式标为
  `pfCombatLog` 的 Frame，书外 Frame 排除。小队与团队必须分色；九职业目标
  必须保持各自 Vanilla 色相，不得为了任意距离门禁重新分配色域。
- 外部兼容：ChatMOD 1.1 的时间戳、彩色玩家名、等级难度、URL、自身高亮、
  配置与 SavedVariables 保持原有所有权；AEUI 不直接调用或改写 ChatMOD。
- 回退：禁用 AEUI Chat 时保留 pfUI 行为；legacy TGA 在 P6-C 前保留。

## 暗色羊皮纸生成前模拟：`CHAT-DARK-SIM-V1`

### 候选元数据与权威边界

- 组件范围：`CHAT.FRAME`、`CHAT.TABS` 与 `CHAT.TEXT` 的可见综合色重关系；
  不新增逻辑对象、状态、Frame、Tab、输入条或消息类型。
- 子状态：`simulation-confirmed`；用户方向结论 `B confirmed`。
- 项目阶段：候选方向 `P2`；现行 `CHAT.CORE.V3` runtime 仍为 `P5`。
- 操作：`simulate`；方式：`deterministic-local-geometry`。
- 固定正式执行器声明：`imagegen-0-143-0`／`@openai/codex@0.143.0`；本次没有
  启动固定执行器，ImageGen `0/0`，没有外部上传，正式生图预算尚未开启。
- 锁定视觉基准只读且未作为像素输入：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)，
    SHA-256 `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`
    — 只承担香草 HUD 尺度、战地旧书身份与邻接界面综合色感；
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)，
    SHA-256 `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`
    — 只承担手绘材料厚度与页／皮革／黄铜层级，不继承规则建筑、龙饰或亮纸色。
- Prompt provenance 仍为 [`ART_BASELINE.md`](../ART_BASELINE.md)、
  [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md) 与
  [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。此次确认只进入生产草案，
  在 source 候选被接受前不反向修改这些稳定条款。
- 冲突审计：稳定基线和已接受 source 要求暖赭连续纸面；用户最新方向要求把
  阅读纸面压到接近黑色，以恢复原版频道／职业颜色识别。裁决为先建立独立的
  暖黑烟熏纸候选，不把它伪称为现行基线，也不通过透明黑板覆盖亮纸；若用户
  接受，正式正文必须把它转译为仍可识别的深色纸纤维、毛边页叠和旧皮革关系，
  不能退化成现代半透明黑聊天板。

### 模拟合同

- 版本：`CHAT-DARK-SIM-V1`。
- 目标场景：一张 `1000 × 420` 对照画布中的两个真实聊天实例；A、B 每个都
  严格为 `440 × 320 UI px`，不是固定容量画布冒充 provider Frame。
- 相同运行时几何：四枚 `92 × 30px` Tab、`3px` 间距、共同顶部布局；正文
  安全区 `x=30..410`、`y=32..280`，即 `380 × 248px`。
- 相同排版：12px 中文正文、15px 行高（含 `3px` spacing）、13 条代表消息
  形成 15 条可见行，容量上限 16 行，未截断。内容同时覆盖世界、团队、小队、
  公会、密语、系统、说话、警告、表情、九职业中的代表玩家、物品品质与
  DPSMate 正／负报告色。
- A：代表当前接受纸色 `#CDA155` 和 v1.18 深墨映射；B：暖黑烟熏纸
  `#18120D`、深色页叠／旧皮革／氧化黄铜边，以及接近 Vanilla 的频道和九
  职业识别色。B 的萨满蓝为可读性轻抬后的 `#1684ED`，不是陌生色域。
- 当前 accepted/runtime 邻接 UI 只以几何 primitives 表达：同一旧书轮廓、
  多层页边、连续皮革承托带和四枚索引签；未读取或复制现有 source／TGA 像素。
- 用户需要确认：B 的近黑色纸面是否仍首先像旧书；综合色重是否合适；恢复
  原版职业／频道颜色后是否确实能一眼扫读；是否存在过亮、霓虹或现代黑面板感。
- 刻意简化且非权威：纸纤维、烟熏斑驳、毛边笔触、Alpha、接缝、九宫格切片、
  精确 Tab 状态、字体栅格和最终逐色数值。画布标题、对照说明和抽象世界背景
  也不属于 runtime。
- 禁止用途：模拟 PNG 不得进入 `assets/source/` 或 `addon/`，不得裁切、切片、
  晋级、复用像素，也不得作为正式 ImageGen edit／reference 输入。

### 本地模拟规格、执行与展示区域证据

- specification：
  [`tools/specs/chat_dark_parchment_simulation_v1.json`](../../../../tools/specs/chat_dark_parchment_simulation_v1.json)，
  SHA-256 `122cf98dfedb21810035a26a9efce8e9bbd213541366d5a51e6e842dfedaaefd`。
- renderer：
  [`tools/render_chat_dark_parchment_simulation_v1.py`](../../../../tools/render_chat_dark_parchment_simulation_v1.py)，
  SHA-256 `88f78d340310c80090231ee3ec7d538c5e44645f6eb0d045edcdf931b3ec9b09`。
- 命令：
  `python tools/render_chat_dark_parchment_simulation_v1.py tools/specs/chat_dark_parchment_simulation_v1.json`。
- Python：`D:\Softwares\miniconda3\python.exe`，`3.13.5`。
- 输出：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/chat_dark_parchment_ab_v1.png`，
  `1000 × 420 RGBA`，SHA-256
  `4a8d78c026147a87b5a0a3bde97cdd142344a7441d12ff84957184062990be8f`。
- 指标：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/chat_dark_parchment_ab_v1.metrics.json`，
  SHA-256 `2a841508f610522b7b391759dba59e6633ee7d8bb703645627b2a9cb68a5319d`；
  A／B 均为 15 行且 `truncated=0`。
- 展示区域合同：
  [`tools/specs/chat_dark_parchment_display_region_v1.json`](../../../../tools/specs/chat_dark_parchment_display_region_v1.json)，
  SHA-256 `675d73fe5557da86befde11100eaa613eb195c826b4150d1d6cb9f190650c8d3`。
- 展示区域报告：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/display-region-report.json`，
  SHA-256 `af610b76753f5368232d78bfef8d5acc843e5069120165e056dcae9375a1043e`；
  A／B 两个 `440 × 320` 场景、四枚 Tab 和正文安全区全部 `pass`，首个失败码
  为 `null`。
- ImageGen：`0/0`；上传范围：无；三个 `generated/` 输出均由 `.gitignore`
  排除。

| 本地错误 | 版本 | 可观察错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|
| SE1 | `CHAT-DARK-SIM-V1` | 初始展示区域合同保留了无公式字段的 `provider_layout`，validator 要求 `panel_height` | 删除本组件不适用的 provider 高度公式对象，再以同一几何合同验证 | `pass`；不涉及 ImageGen |

### 内部审查与用户方向门禁

- 真实排版：两个实例均严格使用 `440 × 320`、`380 × 248`、12px／15px 与
  现实高密度中文消息；没有扩大 Frame、减少消息或加描边来制造可读性。
- 语义／物理：B 保留页叠、毛边轮廓、皮革索引签和黄铜边的旧书层级，核心
  阅读面为不透明暖黑纸，不是用半透明黑矩形覆盖亮纸。
- 综合色重：A 的基础频道／职业集中在约 `4.50:1`；B 的最低代表色是萨满蓝
  `4.913:1`，战士 `7.434:1`、术士 `5.566:1`、警告 `5.357:1`，其他展示色
  更高。数值只证明没有明显失败，不能替代用户对扫读和沉浸感的判断。
- 文字：无 `OUTLINE`、无阴影、无逐行底色；A／B 的消息、几何和字体完全
  相同，因此可直接判断背景极性与语义色的关系。
- 刻意省略：第一次内审发现规则长横纹会被误读为消息分隔线，最终模拟完全
  省略微纤维；正式资产必须从锁定美术 DNA 重新表达不规则低频纸纹，不能从
  本模拟补回规则线。
- 内部结论：`displayable / simulation-reviewed`。
- 静态回归：renderer `py_compile`、display-region validator、
  `asset_workflow_skill_test.py`、`repository_contract_test.py`、Chat Lua smoke、
  pfUI scoped ownership contract 与 `git diff --check` 均通过。
- 用户结论：`2026-08-02 / B confirmed`。确认的可见条款是：阅读面为
  `#18120D` 附近的不透明暖黑旧纸；仍首先读作厚重战地旧书；保留当前
  `440 × 320` 书框、`380 × 248` 正文安全区、Tab／输入条几何与
  Vanilla 职业／频道色识别方向。模拟像素仍不被接受。
- 确认失效条件：若后续要改为亮纸、现代黑面板、重新生成整本书、改变
  九宫格／Tab／正文几何或改写材料层级，必须回到新的本地模拟门禁。
- 下一门禁：审查下方 `CHAT.FRAME.PAPER.V1` 完整生产正文、固定上传图和
  最多五次调用预算，再单独明确授权。当前不修改 runtime。

## 暖黑纸面生产草案：`CHAT.FRAME.PAPER.V1`

### 产品与几何合同

- 子状态：`prompt-authorized`；项目阶段 `P3`；操作 `generate`；正式授权
  `2026-08-02 confirmed`。
- 生成对象只有一个：一张边到边、不透明的暖黑旧纸材质 donor。它不是
  书、UI 面板、完整书框、atlas 或 runtime 贴图，也不承担任何几何或 Alpha。
- 接受母版固定为
  [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)，
  `1608 × 978 RGBA`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
- 母版的画布、Alpha 轮廓、皮革、缝线、页叠深度、黄铜、现有九宫格切线、
  `440 × 320` runtime 装配、四枚 Tab／输入条的独立 atlas 全部冻结。不让
  ImageGen 重画整本书，不修改点击区、UV、安全区或消息容量。
- donor 由确定性工具居中 LANCZOS 适配到 `1608 × 978`，只在固定纸面
  mask 内替换表面像素；使用原母版亮度保留页边、折痕、接触暗部和页叠
  体积。mask 外 RGB 字节不变，整张 Alpha 字节不变。
- 固定装配规格：
  [`tools/specs/chat_dark_paper_assembly_v1.json`](../../../../tools/specs/chat_dark_paper_assembly_v1.json)，
  SHA-256 `d8158d0de876db4d635796529b2e3c5339411db9ea4f45f5e3c925fae33a6e44`。
- 固定装配工具：
  [`tools/build_chat_dark_paper_v1.py`](../../../../tools/build_chat_dark_paper_v1.py)，
  SHA-256 `c098bca607b054e857ad66bf2c47ba80c59af2ee804421c475a7a40c72230e4b`。
- 本地 mask 审查证据：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/assembly/ChatBookPaperMaskV1.overlay.png`，
  SHA-256 `464b12de1a4353287b13faee6e047239b3d445fcfc5bebade8bea6bbe3dd9701`；
  只覆盖纸面与页叠，顶部缝线、外圈皮革、透明轮廓和右下黄铜全部排除。
- 本地装配合同报告：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/local-contract-test/ChatBookPaperAssemblyV1.report.json`，
  SHA-256 `57ebbf1656ea5d8b0ca1698209bac4de10f700438faab01ec59cfbf870539e71`；
  用固定母版作为本地替身 donor 验证装配，输出 `1608 × 978 RGBA`、Alpha
  差异像素 `0`、mask 外 RGB 差异像素 `0`。该候选只是技术测试，不是美术产物。

### 固定外部输入与上传边界

- 唯一上传输入拟为 Image 1：上述已接受 V3 母版及其固定 SHA。它只作为
  手绘笔触尺度、纸纤维颗粒、烟熏／磨损节奏和微观暖光的低权重材质参考。
- 明确忽略 Image 1 的外轮廓、画布几何、Alpha、页叠、缝线、皮革、黄铜、布局和
  亮金纸色；这些全由确定性装配所有。
- 两张 locked 图继续是美术权威，但本执行不上传；只通过下方自包含提示词
  继承其已写入基线的稳定条款。
- `CHAT-DARK-SIM-V1` 的 PNG、指标和任何裁片禁止上传或作为生产输入。
- 原始结果只能写入
  `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-XX/`；通过对象身份、材料与
  非对称纹理门禁前，不得进入 `assets/source/` 或 `addon/`。

### 自包含生产提示词（授权后原样传入）

```text
Create exactly one edge-to-edge, front-facing material surface for the reading paper of a 2004-era hand-painted fantasy MMORPG battlefield chat book. This output is a surface donor only. It is not a complete UI, not a book, not a frame, not a panel, and not an atlas. The output contains one opaque rectangular swatch of worn parchment material occupying the entire canvas. Do not include a border, page edge, binding, leather, brass, tabs, icons, text, symbols, controls, objects, cutouts, transparent margins, presentation board, or surrounding scene.

Image 1 is a lower-authority material-scale reference from the accepted current chat-book master. Inherit only its hand-painted brush scale, subtle paper fibers, restrained smoky staining, irregular wear rhythm, low-resolution vanilla-era bitmap character, and warm upper-left micro-lighting. Explicitly ignore and do not reproduce Image 1's outer silhouette, geometry, alpha boundary, stacked page edges, stitches, leather, brass corner, layout, or light golden parchment color. Geometry and alpha are owned by deterministic runtime assembly, not by this image.

The material is soot-darkened warm-black parchment, never black leather, metal, stone, wood, cloth, a modern black card, or a translucent dark overlay. Center the base color visually near #18120D. Use restrained fiber-catching variation near #392A1D and the deepest pores or smoke near #0D0906. Preserve a warm brown undertone. Avoid neutral gray, blue-black, pure #000000, or a sepia-gold reading center.

The entire canvas must still read as fibrous paper at normal game scale: subtle irregular fibers, low-frequency smoke and age variation, sparse restrained scuffs, slightly uneven hand-painted marks, and organic nonrepeating tonal drift. Keep the field continuous and quiet enough for dense 12px multicolored chat text with 3px line spacing. Do not create a center glow, vignette, rectangular gradient band, horizontal ruled lines, repeated pattern, tile seam, high-frequency speckle, large stains behind text, scratches, holes, burned edges, blood, runes, ornament, bright highlights, or readable marks.

Use a flat orthographic front view and even edge-to-edge coverage. Do not add perspective, folds, curled corners, cast shadows, thickness, isolated-object silhouette, or blank margin. Micro-highlights may imply warm light from the upper left only at fiber scale; they must not become a panel-wide lighting gradient. Output a clean landscape 1536 x 1024 opaque RGB or RGBA image with no transparency and no chroma-key background.

Final self-check: exactly one full-canvas warm-black parchment surface; paper material is unmistakable; no UI frame or object appears; no regular lines or seams appear; the center stays dark, quiet, and continuous; nothing is baked that could compete with runtime text.
```

### 完整性审计与有界修复包络

- 身份、对象数、输入职责、画布／视角、材料、主色／暗色／高光、光照、纹理频率、
  正文安静区、透明度、禁止烘焙内容、禁止对象和最终自检全部显式；无未声明
  尺寸、动态状态或运行时文字。完整性审计 `pass`。
- 同一生产正文最多五次**实际** ImageGen 生成，当前 `0/5`；工具或进程错误
  单独记录，不占生成次数。每次只处理第一个可观察失败门禁。
- 允许的修复：只可调整纸纤维、烟熏、磨损、暗部或亮部的描述强度；若上一张
  已正确是单一纸面 donor 且没有禁止对象，可在同循环作为 edit 输入。
- 不可变的约束：单一 donor、Image 1 唯一外部输入、暖黑纸材质、色相极性、
  不透明全画布、无 UI／无书框／无边缘／无规则线，以及确定性几何所有权。
- 若需新增或更换外部图、改变对象身份／数量、纸色极性、材料层级、输出职责、
  画布要求或现有几何，立即停止并请求新授权。
- 每个 raw 通过对象范围、结构、材料、一致性、技术与反模式审查后，才可装入固定
  mask；装配候选还必须验证 `1608 × 978 RGBA`、Alpha 零差异、mask 外 RGB
  零差异，并用现有 exporter 生成真实 `440 × 320` 九宫格预演。

### 精确授权记录

- 用户授权日期：`2026-08-02`。
- 授权版本：`CHAT.FRAME.PAPER.V1`。
- 唯一允许上传图：固定 SHA-256 的 V3 母版，作为 Image 1。
- 预算：同一生产正文最多 `5` 次实际 ImageGen 生成／编辑；当前 `0/5`。
- 用户原文：

> 明确授权 `CHAT.FRAME.PAPER.V1`，允许上传固定 SHA-256
> `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`
> 的 `ChatBookFrame_Master_v3.png` 作为 Image 1；同一生产正文最多 5 次实际
> ImageGen 调用。

### `CHAT.FRAME.PAPER.V1` 自主修复循环

- 固定执行器：`imagegen-0-143-0` / `@openai/codex@0.143.0`。
- 不可变修复边界：单一不透明暖黑旧纸 donor；Image 1 唯一外部输入；
  不生成书、框、边缘、Tab、文字、图标或控件；当前画布、Alpha、九宫格、
  `440 × 320` runtime 几何和 Tab／Input atlas 不变。
- 允许的自主修复：仅修改纸纤维、烟熏、磨损、暗部或亮部的描述强度；
  候选已正确为单一 donor 且无禁止对象时，才可作为同循环 edit 输入。
- 必须重新授权：新增／替换外部图、改变对象或状态数、暖黑纸极性、材料层级、
  画布、几何、Alpha 或 runtime 职责。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `CHAT.FRAME.PAPER.V1` / pending | generate | pending | pending | pending | pending | pending |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| — | — | — | — | — | 当前 `0` 次流程错误 |

## 最终执行正文

### 已接受 V3 的确定性导出

本批不调用 ImageGen。对三张已接受 V3 source 只执行以下确定性导出，不重绘、
不补画、不裁切退役底栏字段：

```text
python3 tools/build_chat_v3_runtime_assets.py
  --runtime-dir addon/AzerothExpeditionUI/Media/Chat
  --artifact-dir generated/chat/v3/runtime-artifacts
  --manifest assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json
```

## 执行记录

- exporter：
  [`build_chat_v3_runtime_assets.py`](../../../../tools/build_chat_v3_runtime_assets.py)
- 日期：`2026-07-29`
- ImageGen 会话／结果 ID：本批未生图；接受 source 的历史 ID 未留存，见
  source manifest 的 provenance gap。
- 正式 runtime：
  - `addon/AzerothExpeditionUI/Media/Chat/ChatBookFrameV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatTabAtlasV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatTabShelfV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatInputAtlasV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatUnreadSealV3.tga`
- Lua 所有权：
  [`Modules/Chat.lua`](../../../../addon/AzerothExpeditionUI/Modules/Chat.lua)
- raw、atlas contact sheet 和重组预演仅在被忽略的
  `generated/chat/v3/`，不是跨设备资产。

### Runtime contract v1.1 修正

- 实机证据：
  [`04_chat_tabs_p5_game_failure.png`](../../../../assets/references/chat/session-2026-07-29/04_chat_tabs_p5_game_failure.png)
- 首个失败门禁：`runtime-exported → game-validated` 的 Tab 点击几何／视觉
  装配。原生 `FCF_DockUpdate` 在首次 Apply 后按文字宽度重新设置 Tab，
  四枚实际只占承托区约四分之三；选中签使用原生顶端锚点，贴住书框上沿。
- 排除项：重放 exporter 后四状态源裁切、atlas 行、三段 UV、Alpha 与 TGA
  SHA 全部和 manifest 一致；不是 source 或 imagegen 结构失败。
- 修正：
  - 按 `DOCKED_CHAT_FRAMES` 顺序，在 `FCF_DockUpdate` 返回后同一帧恢复
    `92 × 42`、`3px` 间距和 `3px` 顶部偏移；
  - 超过四枚时按 `380px` 可用宽度等宽收缩；
  - AEUI 三段纹理标记为受管 Region，pfUI 通用 Tab Region 高度循环不再
    把它们压回文字高度；
  - 维护循环仍不改写 Tab 几何。
- 未改变：五张正式 runtime TGA 的 SHA、已接受 source、状态 UV 和主框正文
  安全区。

### Runtime contract v1.2 修正

- 实机证据：
  [`05_chat_tabs_p5_height_failure.png`](../../../../assets/references/chat/session-2026-07-29/05_chat_tabs_p5_height_failure.png)
- 第一个失败门禁：`runtime-corrected → game-validated` 的 Tab 纵向尺度。
  该截图后来确认仍由原始 Git HEAD 安装副本产生，不能证明 v1.1 已在游戏
  加载；但用户对原始 `42px` 外接高度的直接否决仍是有效产品反馈。
- 修正：
  - 四状态共同外接高度从 `42px` 降为 `30px`，顶部偏移从 `3px` 降为
    `2px`；
  - panel 从 `45px` 降为 `32px`，承托带从 `23px` 降为 `16px` 并放在
    `y=18px`；
  - 正文上沿从 `44px` 收回到 `32px`，新增空间归还消息区域，不留下空槽；
  - `FCF_DockUpdate` 后仍只执行一次几何恢复，维护循环仍只换状态 UV。
- 未改变：Tab 宽度、间距、四状态语义、点击顺序、五张 runtime TGA 像素与
  SHA、已接受 source 和输入区。

### Runtime contract v1.3 修正

- 有效实机结论：v1.2 正确加载后，点击任意 Tab 会使四枚标签恢复
  `92 × 30` 的紧凑布局，证明最终几何合同有效；但刚进入游戏时仍保留
  pfUI／原生的临时尺寸。选中签文字同时被压成近黑色，标签皮革主体的中下部
  也位于原点击框之外。
- 第一个失败门禁：`runtime-corrected → game-validated` 的启动时序、文字
  可读性与实际命中范围。
- 根因：
  - AEUI 首次 `Apply` 早于登录阶段最后一次 pfUI／原生停靠装配；点击 Tab
    会触发后续停靠更新并恢复 AEUI 几何；
  - v1.2 的 selected 文字色与深色皮革选中签对比不足；
  - Button 外接高度虽然已降为 `30px`，但视觉皮革向下延伸的部分没有纳入
    命中范围。
- 修正：
  - `Apply`、`PLAYER_ENTERING_WORLD` 与 `UI_SCALE_CHANGED` 后安排一次
    `0.5s` 终局装配；到期后仅重做一次 Tab panel、聊天正文与 Tab 状态，
    不把几何写入周期维护；
  - 选中文字改为亮暖金 `RGBA(1.00, 0.88, 0.62, 1.00)`；
  - 保持 `92 × 30` 视觉和排列不变，通过
    `SetHitRectInsets(0, 0, 0, -8)` 只把命中边界向下扩展 `8px`；
  - `/aeui status` 增加 `chat-runtime=1.3`，用于直接确认游戏当前加载的
    运行时合同。
- 未改变：五张正式 runtime TGA、已接受 source、atlas 裁切与 UV、Tab
  状态语义、正文内容和消息路由。

### Runtime contract v1.4 修正

- 实机证据：
  [`07_chat_tab_text_content_overflow.png`](../../../../assets/references/chat/session-2026-07-29/07_chat_tab_text_content_overflow.png)
- 结论：v1.3 仍未通过 `runtime-corrected → game-validated`。截图中四枚
  TabText 沿皮革签上沿排列而非处于 Button 中心；正文左右边距从合同的
  `30px` 退回 pfUI 默认窄边距，底部红字越过书页边缘。
- 触发审计：仅凭截图无法还原用户点中的具体对象，但越界后的锚点形态与
  `pfUI.chat.RefreshChat()` 对全部 docked `ChatFrameN` 写入的默认
  `TOPLEFT/BOTTOMRIGHT` 边距一致。该函数可由停靠保存、聊天框拖动结束、
  channel 设置和登录刷新触发；Tab 切换／`FCF_DockUpdate` 也可能随后改写
  docked 对象。
- 根因：
  - AEUI v1.3 只设置 Tab 字体和颜色，没有接管
    `ChatFrameNTabText` 的 Point、文字安全宽度与垂直对齐；
  - `FCF_SelectDockFrame` 的后置 Hook 只调用状态维护，
    `FCF_DockUpdate` 的后置 Hook 只恢复 Tab，均未恢复正文安全区；
  - AEUI 没有监听 `pfUI.chat.RefreshChat()` 完成后的最终几何。
- 修正：
  - 每枚 TabText 使用所属 Button 的单一 `CENTER` 锚点，水平各留 `6px`、
    文字区高 `18px`，水平 `CENTER`／垂直 `MIDDLE`，并标记为
    `aeuiManaged`，pfUI 后续刷新跳过其默认底边布局；
  - 在 `pfUI.chat.RefreshChat()`、`FCF_SelectDockFrame`、
    `FCF_DockUpdate` 与 `FCF_SaveDock` 返回后统一核对 Tab、TabText 和正文
    `30/30/32/40px` 安全区；
  - 几何完全匹配时不写 Point／Width／Height；拖动锁期间只保留一个 pending
    标志，解锁后的下一帧恢复一次，避免维护循环持续抢写；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.4`。
- 未改变：五张 runtime TGA 像素与 SHA、已接受 source、atlas UV、频道消息、
  停靠数据、输入和未读语义。

### Runtime contract v1.5 修正

- 有效实机结论：v1.4 改变 UI Scale 后，未交互的默认 Tab 继续以旧屏幕比例
  显示；点击任意 Tab 后，四枚 Tab 才同时应用新比例。
- 第一个失败门禁：`runtime-corrected → game-validated` 的 UI Scale 动态
  装配。
- 根因：v1.4 在 `UI_SCALE_CHANGED` 后仍走“只修复逻辑数值偏移”的路径。
  缩放前后 Tab 的 Width／Height 仍是 `92 × 30 UI px`，Point 也不变，因此
  `PointMatches` 判定无需写入；香草客户端保留了旧屏幕像素缓存。首次点击
  触发 `FCF_*` 对几何的实际写入后，缓存才刷新。
- 修正：
  - `UI_SCALE_CHANGED` 单独标记 `startupLayoutForce`，连续缩放事件合并到
    最后一次后的 `0.5s`；
  - 普通 addon Refresh 既不能推迟已安排的缩放定型时间，也不能清除该
    force 标记；
  - 到期后无条件重放一次 Tab panel、全部 docked Tab、TabText、正文锚点和
    HitRect，即使逻辑 Point／Width／Height 与合同完全相同；
  - 强制状态在成功 reflow 后立即清除，后续普通事件和 `Maintain` 继续只在
    真实偏移时恢复，不形成周期几何写入；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.5`。
- 未改变：`92 × 30` 逻辑合同、Tab 状态与顺序、正文安全区、五张 runtime
  TGA 像素与 SHA、source、消息／停靠数据。

### Runtime contract v1.6 修正

- 有效实机结论：v1.5 正确加载后改变缩放，默认 Tab 仍不应用新比例；仍需
  点击一次 Tab。v1.5 的静态缓存模拟通过，但没有覆盖用户实际使用的 pfUI
  解锁缩放入口。
- 第一个失败门禁：`runtime-corrected → game-validated` 的 pfUI owner
  局部缩放装配。
- 根因：
  - `addon/pfUI/modules/unlock.lua` 的 `DraggerOnMouseWheel` 直接执行
    `frame:SetScale(scale)`，随后调用 `frame:OnMove()`；该路径不会可靠发送
    `UI_SCALE_CHANGED`；
  - `pfChatLeft.OnMove` 原实现只调用 `pfUI.chat:RefreshChat()`；后者会更新
    正文锚点，但不会保证重新写入逻辑数值仍为 `92 × 30` 的 Tab，因此
    v1.5 的条件恢复仍跳过 Tab；
  - 点击 Tab 后原生 `FCF_*` 实际重写 Tab 几何，才刷新香草客户端的屏幕像素
    表现。
- 修正：
  - adapter 保留并包装 `pfChatLeft.OnMove`；原回调完整返回后比较 owner 的
    `GetScale()` 与 `GetEffectiveScale()`；
  - 只有任一缩放值真正变化时同步强制重放一次全部受管几何；同一 Scale 下
    的普通拖动／保存不会强制重写；
  - 现有 `Maintain` 不增加第二个轮询器，只在原有节拍中比较
    EffectiveScale；检测到 `UIParent:SetScale` 等无事件边沿时同样只强制
    重放一次；
  - `UI_SCALE_CHANGED` 与登录终局装配继续保留；若边沿检测已经同步完成，
    会清除同一缩放的待执行 force，避免重复重放；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.6`。
- 未改变：Tab 逻辑尺寸、文字／命中区、安全区、五张 runtime TGA 像素与
  SHA、已接受 source、atlas UV、消息与停靠数据。

### Runtime contract v1.7 修正

- 有效实机结论：`2026-07-31` 截图中四枚 AEUI Tab 仍存在，正文消息也仍
  路由到左框，但九宫格书本主体未显示，画面退回 pfUI 的透明容器外观。
- 第一个失败门禁：`runtime-corrected → game-validated` 的主框持续装配。
- 当前证据不能唯一证明是模块 Apply 被前序异常中断，还是书本 Texture／
  BACKGROUND draw layer 被后续刷新剥离；因此修正同时覆盖两个可独立验证的
  失败面，不把推断写成已证实根因。
- 修正：
  - Bootstrap 逐模块 `pcall` 执行 Initialize／Apply；单模块异常只记录在
    `moduleFailures` 并对同一错误打印一次，不再中断其他模块；
  - `Chat:EnsureBookVisible()` 在现有维护节拍与延迟布局恢复前检查书本中心片、
    Tab 承托带、Texture 路径和 runtime 标记；
  - 缺失、隐藏、贴图被清空或版本过期时调用既有 `EnsureBook()`，恢复
    BACKGROUND draw layer、透明 pfUI backdrop、九宫格与承托带；
  - 不增加新的 OnUpdate，不在书本完整时重写几何。
- 静态证据：Lua 5.0 语法、Chat smoke 中的贴图剥离恢复断言、失败模块后
  健康模块继续 Apply 的隔离断言均通过。
- 未改变：Tab 逻辑尺寸、文字／命中区、安全区、五张 runtime TGA 像素与
  SHA、已接受 source、atlas UV、消息与停靠数据。

### Runtime contract v1.8 修正

- 有效实机结论：`2026-08-01` 截图中正文使用 `12px` 中文字体与描边，但
  相邻行几乎粘连。主客户端 `chat-cache.txt` 确认窗口字号为 `12`；pfUI
  SavedVariables 确认区域兼容字体、`OUTLINE` 与 `pfChatLeft` 局部缩放
  `1.1` 均启用。
- 根因：既有组件合同要求 `12px` 字号、约 `14px` 行高，但 v1.7 及以前只
  接管 `ChatFrameN` 安全区，没有调用 `SetSpacing`。中文满字面字体与描边
  占满原生零额外行距，局部缩放只放大字形，不会产生新的行间留白。
- 修正：
  - 只对 AEUI 左框内真实停靠的 `ChatFrameN` 设置 `2 UI px` 行距；
  - 支持有／无 `GetSpacing` 的 Vanilla API；有读取能力时只在偏离合同或
    runtime 版本变化时写入，无读取能力时仅在既有布局事件后重施；
  - pfUI `RefreshChat`、`FCF_SetChatWindowFontSize`、Tab 选择、Dock
    更新／保存与缩放恢复继续共用既有事件驱动路径，不增加维护型 OnUpdate；
  - 用户字号、字体、描边、频道色、消息内容和其他 pfUI 模块保持不变。
- 静态证据：Chat smoke 覆盖初次应用、用户调整字号、pfUI 把 spacing 重置
  为 `0` 后恢复，以及缺少 `GetSpacing` 时的兼容路径。
- 未改变：正文安全区、Tab／输入／未读几何、五张 runtime TGA 像素与 SHA、
  已接受 source、消息路由和停靠数据。

### Runtime contract v1.9 修正

- 有效实机结论：v1.8 已消除相邻中文行的直接粘连，但 `2026-08-01` 后续截图
  仍显示每个中文字被 pfUI 全方向 `OUTLINE` 包围；高饱和频道色、密集黑色
  字圈和正文区纸纤维同时出现，长期阅读产生明显视觉疲劳。
- 根因：pfUI 配置项“Enable Text Shadow”实际把 `ChatFontNormal` 设为
  `OUTLINE`。对于满字面的中文字体，这会把每个字扩成高对比色块；单纯增加
  行距只能分离行，不能降低字内与字间的高频边缘噪声。
- 修正：
  - 只对 AEUI 左框内真实停靠的 `ChatFrameN` 使用项目已有
    `NotoSansSC-Medium.ttf`，从 `GetFont` 保留用户字号，缺少读取 API 时使用
    既有记录或 `12px` 兜底；
  - 调用 `SetFont` 时不传 flags，移除全方向描边；改用
    `RGBA(0.16,0.09,0.04,0.78)`、偏移 `(1,-1)` 的单向深棕阴影；
  - 行距由 `2px` 调整为 `3px`，12px 基线约为 15px 行高和 16 行中文；
  - 在 `380 × 248` 正文安全区内创建内置 `WHITE8X8` 连续压光层，使用
    `RGBA(0.18,0.11,0.06,0.10)`，位于书页之上、聊天文字之下；不新增 TGA，
    不形成黑色面板、边框或逐条消息底色；
  - 压光层进入书本自愈检查；字体、阴影和行距继续沿用 pfUI Refresh、字号
    调整、Tab／Dock 与缩放后的事件式恢复，不增加消息级 Hook 或维护型几何
    改写。
- 静态证据：Chat smoke 覆盖 Noto 字体、空 flags、阴影参数、`3px` 行距、
  压光层层级／锚点／透明度、贴图剥离自愈、字号调整以及 pfUI 重置后恢复；
  同时覆盖缺少 `GetFont`／`GetSpacing` 的兼容路径。
- 未改变：用户字号选择、频道色、物品色、链接、消息字符串与路由、正文安全
  区、Tab／输入／未读几何、五张正式 runtime TGA 像素与 SHA、其他 pfUI
  模块。

### Runtime contract v1.10 修正

- 有效实机结论：v1.9 截图显示浅粉公共频道正文与暖黄羊皮纸的明度过于接近；
  同时安全区 `10%` 暖色压光形成了边界可见的浅暗矩形，削弱整张书页的连续
  材质。用户要求执行频道色方案并恢复 v1.8 使用的旧字体。
- 修正：
  - 删除压光层的创建、锚点和自愈依赖；若旧对象仍存在则清空 texture 并
    隐藏，书页仅显示正式九宫格自身像素；
  - 受管 `ChatFrameN` 不再固定 Noto Sans SC Medium，而从当前 Frame 或
    `pfUI.font_default` 恢复 provider 配置字体；继续保留用户字号、空 font
    flags、单向深棕阴影和 `3px` 行距；
  - 在 pfUI 完成消息解析后、真实 `HookAddMessage` 显示前安装受管 Frame
    wrapper；只当基础 RGB 与当前 `ChatTypeInfo.CHANNEL` 匹配时，将显示参数
    改为 `RGB(0.36,0.16,0.14)`；
  - wrapper 每次调用都确认 AEUI Chat 启用且 Frame 真实停靠在
    `pfUI.chat.left`，因此禁用模块或移出受管左框后不改色；
  - 不调用 `ChangeChatColor`，不写全局 `ChatTypeInfo` 或 SavedVariables，
    不重写消息字符串；时间、玩家职业、物品、链接等内嵌颜色保持原义。
- 静态证据：Chat smoke 覆盖压光层不存在／旧对象退役、pfUI 字体恢复、字号
  调整与 Refresh 后恢复、公共频道局部 RGB 映射、非频道色及消息参数原样转发；
  repository contract 覆盖 runtime 版本和无全局色彩写入。
- 限制：pfUI 在 AEUI 加载前重放到聊天框的历史行已经完成显示，v1.10 不清空
  或重建历史；局部墨色从 wrapper 安装后的新公共频道消息开始生效。
- 未改变：正文安全区、Tab／输入／未读几何、五张正式 runtime TGA 像素与
  SHA、聊天历史存储、路由及其他 pfUI 模块。

### Runtime contract v1.11 修正

- 有效实机结论：v1.10 已恢复 pfUI 旧字体并移除压光层，但截图显示
  `RGBA(0.16,0.09,0.04,0.78)`、偏移 `(1,-1)` 的正文投影在当前旧字体和
  游戏缩放下形成大面积重复字形，用户明确要求取消阴影。
- 修正：
  - 受管 `ChatFrameN` 的 `SetShadowColor` 固定为 `RGBA(0,0,0,0)`，
    `SetShadowOffset` 固定为 `(0,0)`；
  - 字体仍取当前 Frame／`pfUI.font_default`，`SetFont` 继续不传 flags；用户
    字号、`3px` 行距、公共频道深酒红基础色和书页无覆盖层合同全部保持；
  - pfUI Refresh、字号调整、Tab／Dock 与缩放后的既有事件路径会重新清零
    阴影，不增加消息级改写或维护型几何循环。
- 静态证据：Chat smoke 覆盖首次应用、字号调整和 pfUI Refresh 后均为透明
  阴影与零偏移；repository contract 固定 v1.11 的两组零值常量。
- 未改变：消息字符串、全局频道色、内嵌语义色、正文安全区、Tab／输入／未读
  几何、五张正式 runtime TGA 像素与 SHA、聊天历史存储及其他 pfUI 模块。

### Runtime contract v1.12 修正

- 有效实机结论：v1.11 已解决正文重影；`2026-08-01` 最新截图仍显示时间戳、
  职业玩家名、等级难度、物品／URL 与公共正文使用适合深色聊天底板的高明度
  RGB，在暖黄羊皮纸上明度接近或产生发光感。用户要求全部文本颜色统一修正，
  并确认聊天增强 provider 为 ChatMOD；随后明确要求直接实施、不经过 Figma。
- provider 审计：主／测试客户端均为 ChatMOD 1.1 且 `ChatMOD.lua` SHA-256
  一致；主客户端 SavedVariables 启用了彩色玩家名、时间戳、等级、URL 与自身
  高亮。源码确认 `S_AddMessage` 在原始消息进入 pfUI 前写入精确八位颜色码，
  然后沿 pfUI 的 `HookAddMessage` 最终显示链输出。
- 修正：
  - 新增七类基础墨色：正文深酒红 `#4A2A22`、元数据深胡桃 `#3D2C1E`、
    警告深朱红 `#5F1E1B`、正向苔绿黑 `#263919`、队伍靛蓝黑 `#17364E`、
    密语桑葚黑 `#54243A`、强调焦赭 `#51270F`；
  - 只在基础 RGB 与动态 `ChatTypeInfo` 项精确匹配时，按普通／公共、系统、
    公会／收益、队伍／团队、密语、警告、表情语义映射；不写全局表；
  - 对 ChatMOD 1.1 全部字面颜色、九职业色和 Vanilla 物品品质色建立精确
    白名单，时间戳改为深青黑；职业、品质、等级、URL 与自身高亮保留色相
    身份但统一降低明度／饱和度；
  - `NormalizeInlineMessageColors` 只替换 `|cAARRGGBB` 前缀，不解析或重建
    `|H...|h` 链接；未知第三方色原样保留；
  - wrapper 每次确认 AEUI Chat 启用、Frame 停靠于左书且不是 `pfCombatLog`；
    禁用模块、战斗日志与未受管 Frame 完整回退 provider 输出。
- 静态证据：Chat smoke 覆盖基础频道／系统映射、ChatMOD 大写时间戳、职业、
  等级、稀有物品、URL、未知自定义颜色、四类链接载荷、战斗日志隔离与禁用
  回退；repository contract 固定 runtime 版本、精确白名单入口及禁止全局
  `ChatTypeInfo`／`ChangeChatColor` 写入。
- 限制：已显示的聊天历史行不会被 Frame 重新着色；v1.12 从 wrapper 安装后
  的新消息开始生效。未审计的第三方动态色不猜测映射，避免破坏语义。
- 未改变：外部 ChatMOD／pfUI 文件和 SavedVariables、消息事件／历史／路由、
  链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、五张正式 TGA
  像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.13 修正

- 有效实机结论：v1.12 重载后的截图中，时间戳仍为 ChatMOD 原始亮青
  `#33CCFF`，公共正文和职业名仍为浅粉／高明度职业色；用户直接反馈“看不清”。
  因为 v1.12 目标墨色一个都没有出现在截图中，首个失败门禁是运行时消息链，
  不是色板本身的深浅选择。
- 根因：源码审计暴露两个 v1.12 未覆盖的合法时序。其一，AEUI 首次布局时
  pfUI 的 `HookAddMessage` 可能尚未创建，而 v1.12 的 Maintain 不会再次安装
  颜色 hook；其二，ChatMOD 可先把原生显示函数保存到 Frame 的
  `ORG_AddMessage`，pfUI 随后把 `S_AddMessage` 保存为 `HookAddMessage`，形成
  `pfUI AddMessage → AEUI v1.12 wrapper → S_AddMessage 注入亮色 →
  ORG_AddMessage → 原生显示`。截图本身不能区分是哪一个时序或两者共同发生，
  但两条路径都会让最终亮色绕过白名单，且都已由 v1.13 覆盖。
- 修正：
  - 把受管条件、基础 RGB 与内嵌色转换合并为幂等的
    `ApplyMessagePalette`，供两个出口复用；
  - 保留 pfUI `HookAddMessage` wrapper，同时仅在检测到全局
    `S_AddMessage` 且 Frame 链真实引用它时，包裹该 Frame 的
    `ORG_AddMessage` 最终出口；不误接管其他插件同名字段；
  - wrapper 闭包保存原 provider，重复维护时比较真实函数身份，只安装一次；
    runtime 版本变化只更新标记，不形成递归链；
  - 现有 `Maintain` 节拍只对左框 docked Frame 检查 hook，使 pfUI
    `HookAddMessage` 或 ChatMOD `ORG_AddMessage` 在 AEUI 首次布局之后出现时
    都能被发现；不增加 OnUpdate，不改几何；
  - 两个出口都调用同一受管判断，因此禁用 AEUI、移出左框或
    `pfCombatLog` 时仍完整回退 provider 输出。
- 静态证据：Chat smoke 新增晚出现的 `HookAddMessage`，以及两条相反加载
  顺序：一条复现
  `HookAddMessage → S_AddMessage → ORG_AddMessage` 的 v1.12 旁路，一条复现
  ChatMOD 晚于 pfUI 时回调已包装链；两条都验证亮青／浅粉被最终转换、基础
  正文墨色生效、第二次 Maintain 不重复安装。既有未知色、四类链接、战斗日志
  与禁用回退断言继续通过。
- 未改变：v1.12 色板数值、外部 ChatMOD／pfUI 文件与 SavedVariables、全局
  `ChatTypeInfo`、消息事件／历史／路由、链接载荷、字体／字号／行距、安全区、
  Tab／输入／未读几何、五张正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.14 修正

- 有效实机结论：用户重启游戏并确认 `/aeui status` 为
  `chat-runtime=1.13`，但新消息截图仍显示 `#33CCFF` 时间戳、浅粉公共正文和
  高明度职业色；这排除了旧会话和 Junction 未更新，证明 v1.13 的两个 hook
  仍没有进入实际显示调用。
- 新增审计：v1.13 的最终 wrapper 只有在 Frame 的 `AddMessage`、
  `HookAddMessage` 或保存的 provider 与全局 `S_AddMessage` 为同一函数对象时
  才安装；ChatMOD／其他增强可通过包装函数保持相同行为而改变函数身份。
  `IsMessagePaletteManaged` 同时要求 `frame.isDocked`，该标志由原生停靠流程
  管理，不应作为消息显示瞬间的视觉所有权门禁。这两项都比稳定的 Parent
  所有权更脆弱。
- 修正：
  - `InstallChatMODFinalColorHook` 对受管 Frame 已存在的 `ORG_AddMessage`
    无条件幂等包装，不再猜测其上游函数身份；闭包仍保存并转发原 provider；
  - 消息作用域改为 Frame 当前 Parent 精确等于 `pfUI.chat.left` 且不是
    `pfCombatLog`，不依赖瞬时 `isDocked`；hook 发现同样按 Parent 执行；
  - `addon/pfUI/modules/chat.lua` 在完成 URL／职业／等级／时间解析、历史保存和
    密语修正后，调用 `ApplyExpeditionMessagePalette`，再进入 provider
    `HookAddMessage`；这是 Chat 模块内的显式最终输出桥，不影响其他 pfUI 模块；
  - 原 AEUI `HookAddMessage` 和 ChatMOD `ORG_AddMessage` wrapper 保留为另外
    两层幂等兜底，任一加载顺序下重复调用不会再次改变已映射墨色；
  - 内嵌颜色 pattern 改为显式八位十六进制字符类，避免依赖目标 Lua 对 `%x`
    类别的实现差异；
  - `ApplyMessagePalette` 记录受管调用和实际变更次数；`/aeui status` 输出
    `chat-color=m#/h#/f#/c#/x#`，其中 `m` 为当前受管 Frame，`h` 为 Hook
    wrapper，`f` 为最终 ORG wrapper，`c` 为受管调用，`x` 为真实颜色变更。
- 静态证据：Chat smoke 覆盖 `isDocked=nil` 但 Parent 仍在左框、ChatMOD 经
  非同一函数对象的 proxy 调用、晚出现 provider、两种加载顺序、hook 幂等、
  计数与 status；pfUI／repository contract 固定最终输出桥和无
  `S_AddMessage` 身份门禁。Lua 语法、Chat／pfUI／Quest smoke、repository／
  quest design／asset workflow 契约均通过。
- 未改变：v1.12 色板数值、ChatMOD 源码／配置／SavedVariables、全局
  `ChatTypeInfo`、pfUI 历史存储内容、未知色、链接载荷、战斗日志、字体／字号／
  行距、安全区、Tab／输入／未读几何、五张正式 TGA 像素与 SHA 以及其他
  pfUI 模块。

### Runtime contract v1.15 修正

- 有效实机结论：用户确认 v1.14 已加载，并在有新消息前后持续得到
  `chat-color=m2/h3/f3/c30/x5`。`h3/f3` 证明三个 Frame 都已装上 AEUI Hook
  和最终出口 wrapper；`m2` 则证明其中一个 Frame 在调用时被受管判断排除。
  新消息到达后 `c/x` 均不增长，说明当前可见“综合”窗口就是被排除的第三帧，
  因而 v1.14 未通过运行时门禁。
- 根因：pfUI `RefreshChat` 会统计各 Frame 的 `messageTypeList`；只要超过五个
  名称包含 `SPELL` 或 `COMBAT` 的消息类型，就设置 `frame.pfCombatLog=true`。
  这是用于布局／隐藏的启发式分类，不是稳定的显示所有权。频道较多的常规
  “综合”窗口也会命中。v1.14 虽按左书 Parent 安装了 Hook，却又在
  `IsMessagePaletteManaged` 中排除 `pfCombatLog`，形成“已挂钩但不转换”的
  精确旁路。
- 修正：
  - `IsMessagePaletteManaged` 只要求 AEUI Chat 启用且 Frame 当前 Parent 精确
    等于 `pfUI.chat.left`，不再把 `pfCombatLog` 启发式标记作为颜色门禁；
  - 左书内所有 Frame 共用同一语义墨色板，包括被 pfUI 标为战斗日志的窗口；
    Parent 不在左书的 Frame 仍完整回退 provider 输出；
  - 保留 pfUI 最终输出直桥、`HookAddMessage` 与 `ORG_AddMessage` 三层路径，
    不更改 pfUI 的战斗日志识别、隐藏、布局或消息路由逻辑；
  - runtime contract 升级至 `1.15`，强制现有 Frame 的版本标记重新装配。
- 静态证据：Chat smoke 把 `pfCombatLog=true` 且 Parent 为左书的 Frame 固定为
  必须转换，继续验证书外／禁用回退、链接与未知色保持；repository contract
  固定 `IsMessagePaletteManaged` 中不得重新加入 `pfCombatLog` 排除。Lua 语法、
  Chat／pfUI／Quest smoke、repository／quest design／asset workflow 契约均
  通过。
- 未改变：v1.12 色板数值、ChatMOD 源码／配置／SavedVariables、全局
  `ChatTypeInfo`、pfUI 的 `pfCombatLog` 分类及其其他用途、历史存储、消息内容、
  未知色、链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、五张
  正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.16 修正

- 有效实机结论：v1.15 色板进入游戏后，用户反馈“各个频道／职业的颜色区别
  太小，很难一眼看出来”。这证明消息作用域与最终显示链已足以进入视觉审查，
  但 v1.12 起为了压制亮青／浅粉而采用的色板把多个频道、职业和品质压缩到
  少数接近黑褐的目标色，未通过扫读区分度门禁。
- 色板修正：
  - 七类基础语义分别使用：普通／公共 `#56211F`、系统 `#382D22`、警告
    `#721A17`、公会／正向 `#214513`、队伍 `#143E64`、密语 `#5C235A`、
    表情／强调 `#5D2C04`；时间戳使用独立深青 `#063F4A`；
  - 香草九职业改为九个唯一目标墨色：战士 `#4E3727`、圣骑士 `#6A2447`、
    猎人 `#1E430E`、盗贼 `#493B03`、牧师 `#40382F`、萨满 `#243A73`、
    法师 `#034254`、术士 `#49245F`、德鲁伊 `#672C03`；
  - 物品品质继续保留灰／绿／蓝／紫／橙／金色相，但复用相应可读墨色；链接、
    等级、自身高亮和通用 ChatMOD 色按同一扩展色域重新映射；
  - 优先扩大色相与彩度距离，只有限提升明度；所有通道仍处于深墨范围，不
    恢复原始满亮度颜色、描边、阴影或正文底色。
- 纸面对比审查：正式 `ChatBookFrameV3.tga` 三个阅读区采样框均值约为
  `RGB(204..206, 160..162, 83..86)`，取 `#CDA155` 为代表色；上述七类基础色
  与九职业色的 sRGB 静态对比约为 `4.5:1` 或更高。该数值是纹理上的确定性
  代理，实机仍以常用 UI Scale 下的扫读体验为最终门禁。
- 静态证据：Chat smoke 验证六种可用基础 `ChatTypeInfo` 样本互不合并、九职业
  精确映射且目标色全部唯一，并继续覆盖两种 ChatMOD 加载顺序、链接、未知色、
  `pfCombatLog` 左书作用域与禁用回退；repository contract 固定 runtime 版本、
  九职业源色和九个唯一目标色。Lua 语法、Chat／pfUI／Quest smoke、
  repository／quest design／asset workflow 契约均通过。
- 未改变：左书 Parent 作用域、pfUI 最终输出直桥与 Hook／ORG 两层兜底、
  ChatMOD 源码／配置／SavedVariables、全局 `ChatTypeInfo`、历史存储、消息内容、
  未知第三方色、链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、
  五张正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.17 修正

- 有效实机结论：v1.16 已让九职业目标值互不相同，但用户仍无法快速区分频道
  和职业，明确指出战士 `#4E3727` 与牧师 `#40382F` 都呈灰色。两色 CIE76
  距离约 `9.5`，因此“颜色唯一 + 纸面对比”不足以保证扫读区分度。
- 七类基础语义重排为：普通／公共 `#4B3321`、系统 `#383B42`、警告
  `#681821`、公会／正向 `#154710`、队伍 `#163C75`、密语 `#50206A`、
  表情／强调 `#682C00`；时间戳继续使用独立深青 `#063F4A`。
- 香草九职业重排为：战士 `#5C2525`、圣骑士 `#6C1F4C`、猎人 `#154710`、
  盗贼 `#473D00`、牧师 `#403A33`、萨满 `#163C75`、法师 `#004452`、
  术士 `#50206A`、德鲁伊 `#682C00`。战士改为明确铁锈红，牧师保留中性灰，
  不再落在相邻暖灰。
- 代表书页 `#CDA155` 上所有基础／职业目标色仍约为 `4.5:1` 或更高；CIE76
  最近距离由九职业 v1.16 的约 `9.5` 提升至约 `23.9`，七类基础最近距离约
  `21.9`。repository contract 同时锁定两组 RGB 最近距离 `>=35` 和逐色
  `>=4.5:1` 对比，避免未来只满足数值唯一。
- 未改变最终输出链、作用域、ChatMOD／pfUI 配置、消息字符串、链接、未知色、
  字体／字号／行距、书页资产或其他 pfUI 模块；旧历史行不会重绘。

### Runtime contract v1.18 修正

- 有效实机结论：v1.17 的任意色差优先策略使团队与小队都显示为钴蓝、战士
  偏成铁锈红，用户无法沿用原版颜色记忆；DPSMate 死亡报告注入的
  `#FF8080`／`#8CFF80` 又绕过未知色白名单，在书页上形成浅粉／浅绿亮字。
- 基础语义改为 Vanilla 默认 RGB 的等比例深色版本：说话 `#3D3D3D`、公共
  `#4D3939`、系统 `#404000`、公会 `#124712`、小队 `#3B3B59`、团队／战场
  `#623100`、密语 `#5A2D5A`、警告 `#751D1D`、表情 `#613118`。团队恢复
  焦橙，小队保留蓝紫，二者不再共用目标色。
- 九职业改为：战士 `#4B3B2A`、圣骑士 `#583243`、猎人 `#354224`、盗贼
  `#423F1B`、牧师 `#333333`、萨满 `#003D7A`、法师 `#22424E`、术士
  `#413959`、德鲁伊 `#633004`。除无彩牧师外，各目标与原始职业色的 HSV
  色相偏差不超过 `0.01` 圈；代表纸色上仍约为 `4.5:1` 或更高。
- 已审计时间戳、URL、品质色与 DPSMate 红／绿报告使用确定性保色相目标值；
  其他未知 `|cAARRGGBB` 由缓存的 sRGB 对比计算处理，低于 `4.8:1` 时只等比例
  压低 RGB，足够深则字节级保留。全部确定性目标色登记为终态，消息重复经过
  pfUI／ChatMOD 多层桥时不会被二次压暗。转换只改显示颜色前缀，不解析或
  重建链接。
- 未改变最终输出链、左书 Parent 作用域、ChatMOD／pfUI 配置、消息／链接载荷、
  Alpha、字体／字号／行距、书页资产、历史或其他 pfUI 模块；旧历史行不重绘。

### 测试客户端部署核验

- 未同步部署截图：
  [`06_chat_tabs_stale_deployment.png`](../../../../assets/references/chat/session-2026-07-29/06_chat_tabs_stale_deployment.png)
- 核验结论：该截图不是 v1.2 失败。截图产生后检查
  `D:\Softwares\TurtleWoWTest\Interface\AddOns`，安装文件仍精确匹配
  Git HEAD：
  - `AzerothExpeditionUI/Modules/Chat.lua` blob
    `e4c6ff291217ab38516bddcb49d8278692e2c5bf`，不含 `TAB_LAYOUT`；
  - `pfUI/modules/chat.lua` blob
    `b6bc6f670e0a6bdfb0b7437e11a81ca91e8e3b99`，不含
    `aeuiManaged` Region 保护。
- 排除项：测试目录只有一个 `AzerothExpeditionUI` 与一个 `pfUI`；两份 TOC
  和全部 Chat TGA 均与仓库一致，不是重复插件或旧媒体。
- 已同步并逐文件校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `8abc5aa6ba2b0a852fb1f9a90e08a32f796ad5a6000dd6f435bc0cef067c0bb0`；
  - `pfUI/modules/chat.lua` SHA-256
    `fdaf6644561226bf23a657d39fc49b3b31cbf849deceeb780b8690fe67dcd2a4`。
- 部署时 `WoW.exe` 正在运行；磁盘副本已正确，但必须 `/reload` 或重启后
  才能形成第一张有效的 v1.2 实机证据。
- v1.3 已再次按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `176eda4650cf4aab504786e39400eb4c5fb4306c24a6e02cbb39aab775dfc193`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` 继续与仓库匹配，SHA-256
    `fdaf6644561226bf23a657d39fc49b3b31cbf849deceeb780b8690fe67dcd2a4`。
- v1.3 部署时 `WoW.exe` 仍在运行；需要 `/reload` 或重启后，通过
  `/aeui status` 中的 `chat-runtime=1.3` 确认新代码已经进入当前会话。
- v1.4 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `89bf389b0790a201545717ae45e1935bf0021bee84d40e801c3f081aa5ab33a5`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- 同步时检测到两个 `WoW.exe` 进程；磁盘副本已匹配，但相关游戏会话必须
  `/reload` 或重启，并以 `/aeui status` 的 `chat-runtime=1.4` 为加载证据。
- v1.5 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `6dd4c5e352e7fbc5b44dd603e261fc15bcbd3a7ff1a44ed2af9f4bab5783027a`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- v1.5 同步时仍检测到两个 `WoW.exe` 进程；相关游戏会话必须 `/reload`
  或重启，并以 `/aeui status` 的 `chat-runtime=1.5` 为加载证据。
- v1.6 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `47f569a2ea77b2c16eb2ad548ff0c765c02503944e007787c488c722e3a59617`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- v1.6 同步时仍检测到两个 `WoW.exe` 进程；磁盘副本已匹配，相关游戏会话
  必须 `/reload` 或重启，并以 `/aeui status` 的
  `chat-runtime=1.6` 为加载证据。
- v1.14 已由用户通过 `/aeui status` 确认加载，但固定计数
  `m2/h3/f3/c30/x5` 证明可见 Frame 被 `pfCombatLog` 启发式排除，未通过
  颜色运行时门禁。v1.15 修复作用域后已进入实机颜色审查，但因频道／职业
  区分度不足被用户退回。v1.16 也因战士／牧师发灰和频道扫读不足被用户退回；
  v1.18 位于仓库工作树并取代已被实机退回的 v1.17。测试客户端的
  `Interface\AddOns\AzerothExpeditionUI` 是指向该目录的 Junction，无需
  复制第二份文件。当前游戏会话仍必须 `/reload` 或重启，并以
  `/aeui status` 的 `chat-runtime=1.18` 与 `chat-color` 计数为加载证据；
  当前三帧布局预期 `m3/h3/f3`，且 `c/x` 随可见新消息增长。主客户端同样
  通过 Junction 指向当前仓库；尚无 v1.18 实机通过结论。

## 审查记录

- 语义／物理：主框、Tab、输入、未读均对应真实 runtime 对象；右框无资产。
- 透视／图层：主框为底层，承托带位于 Tab 后，正文和动态文字在纸面上，
  输入独立覆盖书页下沿。
- 装配：`440 × 320` 无底栏预演保留 `380 × 248` 正文安全区。
- 技术：五张 TGA 均为 RGBA 与 2 的幂；SHA、crop 和 UV 见 runtime manifest。
- 静态测试：Chat smoke、pfUI expedition contract、repository contract、
  asset-workflow contract、quest design contract、Python AST 和
  `git diff --check`。
- 尚未发生：Turtle WoW `1.18.1` 实机验证和 `P6-C` 清理。
- 2026-07-29：用户指出当前正文可读性不足，但明确决定把字体、描边与频道色
  改造延后；本批继续保持现有 `CHAT.TEXT` 呈现，不把该问题混入后续
  `CHAT.COPY` 资产。
- 2026-07-29 首轮实机：**失败，保持 P5**。书框和正文可见；Tab 几何未
  保持 runtime 合同。v1.1 静态修正完成，等待同场景复测。
- 2026-07-29 后续两张截图：安装副本仍为 Git HEAD，故不作为 v1.1／v1.2
  游戏结论；用户对 `42px` 的否决保留为 v1.2 产品输入。
- 2026-07-29 v1.2 正确加载后的复测：点击任意 Tab 后几何正常，但登录初始
  状态、选中文字和皮革主体命中范围未过门禁；v1.3 静态修正完成，等待部署。
- 2026-07-29 v1.3：Chat smoke、pfUI expedition contract、repository
  contract 与 asset-workflow contract 通过；目标目录三份相关 Lua 哈希
  匹配，已部署到测试客户端，等待重载后的实机结论。
- 2026-07-29 v1.3 实机：Tab 外接尺度、selected 文字颜色与主体点击问题已
  不再构成本截图的首个失败门禁；TabText 中心和正文事件后安全区失败，保持
  `P5`。v1.4 已完成代码与合同修正并同步，等待重载复测。
- 2026-07-29 v1.4：新增 pfUI Refresh、Tab 选择、Dock 更新、Dock 保存与
  拖动锁后恢复模拟；Chat smoke、pfUI expedition contract、repository
  contract、asset-workflow contract、Python AST 与 `git diff --check`
  通过；三份目标 Lua 哈希匹配，等待实机重载。
- 2026-07-29 v1.4 缩放复测：改变 UI Scale 后默认 Tab 没有主动刷新屏幕
  比例，点击一次后才生效；保持 `P5`。v1.5 已加入对“逻辑数值不变但必须
  重放”的 smoke 场景。
- 2026-07-29 v1.5：缩放 force 标记、普通 Refresh 不延后、单次全几何
  reflow 与 force 清除断言通过；完整静态测试通过，三份目标 Lua 哈希匹配，
  随后实机确认缩放问题没有变化，仍需点击一次 Tab；v1.5 失败并保持
  `P5`。代码审计确认测试模拟的是全局 `UI_SCALE_CHANGED`，未覆盖 pfUI
  解锁模式的 `pfChatLeft:SetScale → OnMove` 真实入口。
- 2026-07-29 v1.6：新增 owner LocalScale／EffectiveScale 记录、
  `pfChatLeft.OnMove` 后置边沿检测、无事件 EffectiveScale 兜底，以及
  “普通拖动不强制写几何”的 smoke 断言；完整静态测试通过，三份目标 Lua
  哈希匹配并已部署，等待 `/reload` 后实机复测。
- 2026-07-31 v1.7：用户报告 Tab 与正文仍在但书本主体消失。新增书本
  Texture／版本自愈以及模块 Initialize／Apply 失败隔离；Lua 语法、
  Chat smoke 与隔离断言通过，等待 `/reload` 实机复测。
- 2026-08-01 v1.8：用户确认中文正文行距过小并授权执行。主客户端配置证据
  为字号 `12`、区域字体、`OUTLINE`、局部缩放 `1.1`，而 runtime 未设置
  spacing；现只对受管左框写入 `2px` 行距。Chat smoke 覆盖 pfUI 重置与
  无 `GetSpacing` 的兼容路径，等待 `/reload` 实机复测。
- 2026-08-01 v1.9：用户复测后确认聊天框仍令人眼睛疲劳，并要求直接实施
  舒适阅读方案。受管正文现使用 Noto Sans SC Medium、无全描边的单向深棕
  阴影、`3px` 行距与正文安全区连续暖色压光层；不改频道色、消息字符串或
  用户字号，静态 smoke 已覆盖 pfUI 重置恢复，等待 `/reload` 实机复测。
- 2026-08-01 v1.10：用户实机确认公共频道浅粉正文仍过淡，正文安全区压光
  形成可见矩形并要求恢复旧字体。现已停用压光层、恢复 pfUI 配置字体，并只
  在受管显示入口把公共频道基础 RGB 映射为深酒红；不写全局频道色或消息
  字符串，等待 `/reload` 后以新公共频道消息复测。
- 2026-08-01 v1.11：v1.10 实机截图显示旧字体叠加 `(1,-1)` 投影后出现大面积
  重影。按用户要求将受管正文阴影改为透明、零偏移；旧字体、无描边、`3px`
  行距、深酒红公共频道基础色和无压光书页均保持。
- 2026-08-01 v1.12：用户确认重影已解决并要求修正全部文本颜色，补充聊天增强
  provider 为 ChatMOD，随后明确要求直接实施、不经过 Figma。审计 ChatMOD
  1.1 源码与当前配置后，受管最终显示链加入基础消息语义色和精确内嵌色白名单；
  未知色、链接、战斗日志、外部插件文件／配置与全局颜色表保持原样。实机截图
  随后证明该 wrapper 位于 ChatMOD 实际注色之前，v1.12 未通过运行时门禁。
- 2026-08-01 v1.13：针对“看不清”截图复现真实加载链；保留 v1.12 色板并增加
  ChatMOD `ORG_AddMessage` 最终出口幂等 wrapper，现有维护节拍负责发现晚出现
  的出口。两种相反加载顺序 smoke 均通过；用户确认 v1.13 已加载后，实机
  新消息仍保持原始亮色，因此该版本未通过门禁。
- 2026-08-01 v1.14：移除 `S_AddMessage` 函数身份与 `isDocked` 门禁，以左框
  Parent 作为作用域；在 pfUI Chat 最终输出加入直接色板桥，保留 Hook／ORG
  两层兜底，并通过 `/aeui status` 暴露调用与变更计数。用户实机固定得到
  `m2/h3/f3/c30/x5`，证明第三个已挂钩 Frame 被作用域排除，版本未通过门禁。
- 2026-08-01 v1.15：根据 v1.14 计数移除 `pfCombatLog` 启发式颜色排除；左书
  Parent 成为唯一显示作用域。完整静态回归通过；实机进入颜色审查后，用户
  退回频道／职业区分度。
- 2026-08-01 v1.16：在左书作用域和三层输出链不变的前提下，重排七类基础
  语义、时间戳、九职业与品质色；正式书页采样代理下保持约 `4.5:1` 对比，
  Chat smoke 固定频道互异和九职业一对一。完整静态回归通过，但实机仍因
  战士／牧师发灰和频道区分不足被退回。
- 2026-08-01 v1.17：按色相优先重排基础／职业墨色，战士改铁锈红、牧师改
  中性灰；增加最近色 RGB 距离与纸面对比机器门禁。完整静态回归通过，等待
  实机重载；随后被“插件色仍过亮、团队／小队同色、偏离原版识别色”的实机
  反馈退回。
- 2026-08-01 v1.18：频道与职业改为 Vanilla 原色相的等比例深墨版本；小队／
  团队拆分；DPSMate 常用亮色加入确定性映射，未知亮色增加 `4.8:1` 连续压暗，
  深色自定义值与链接载荷保持；修复多层桥对确定性目标色二次压暗的幂等性
  缺口。Lua 语法、Chat／pfUI／Quest smoke、repository／quest design／asset
  workflow 契约全部通过，等待实机重载。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一门禁 |
|---|---|---|---|
| V3 runtime contract v1 | source／runtime manifests、五张 TGA、Lua 与 tests | `runtime-exported / P5` | Turtle WoW 实机验证 |
| V3 runtime contract v1.1 | exporter 重放；事件后 Tab 重排与受管 Region 静态测试 | 未获得有效独立实机加载，已由 v1.2 取代 | 改为紧凑纵向合同 |
| V3 runtime contract v1.2 | 用户否决原始 `42px`；`30px` Tab、`16px` 承托带、`32px` 正文上沿；目标目录哈希核验；有效游戏加载 | 点击后几何正确；启动时序、选中文字和命中范围失败，保持 `P5` | 修正初始化、对比度与命中区 |
| V3 runtime contract v1.3 | 登录后单次终局装配；亮暖金 selected 文字；底部命中区扩展 `8px`；runtime 版本自报；有效实机截图 | TabText 未居中；交互后正文退回 pfUI 默认安全区，保持 `P5` | 接管文字锚点与所有已知布局事件 |
| V3 runtime contract v1.4 | TabText 中心合同；pfUI Refresh／选择／停靠后按需恢复完整几何；拖动锁后单次恢复；runtime 版本自报；有效缩放实机反馈 | 缩放后逻辑尺寸未变，条件恢复跳过实际重放；点击后才刷新，保持 `P5` | 为 UI Scale 增加一次强制定型 |
| V3 runtime contract v1.5 | `UI_SCALE_CHANGED` force 标志；连续事件合并；延迟单次全几何重放；force 自动清除；缓存场景 smoke；有效实机反馈 | 未覆盖 pfUI owner 局部缩放入口；实机仍需点击一次 Tab，失败并保持 `P5` | 挂接真实 `pfChatLeft.OnMove` 缩放链 |
| V3 runtime contract v1.6 | owner Scale／EffectiveScale 边沿检测；`pfChatLeft.OnMove` 后置单次强制重放；全局无事件兜底；普通移动零几何写入 smoke；完整静态测试与目标目录哈希核验 | `runtime-corrected / P5`，已部署到测试客户端 | `/reload` 后分别测试 pfUI 局部 Scale 与全局 UI Scale，全程不点击 Tab |
| V3 runtime contract v1.7 | 书本中心片／承托带／贴图／版本自愈；BACKGROUND 恢复；Bootstrap 逐模块失败隔离；Chat smoke 与 Lua 语法 | `runtime-corrected / P5`，Junction 已指向当前工作树但尚未重载验证 | `/reload` 确认书本主体恢复并记录任何单次模块错误 |
| V3 runtime contract v1.8 | 受管 `ChatFrameN` 使用 `2px SetSpacing`；字号／pfUI 重置恢复；无 `GetSpacing` 兼容；不改用户字号、字体或频道色 | `runtime-corrected / P5`，静态测试通过 | `/reload` 确认 `chat-runtime=1.8` 与中文行距，同时复测书本主体 |
| V3 runtime contract v1.9 | 受管 `ChatFrameN` 使用 Noto Sans SC Medium、空 font flags、单向深棕阴影、`3px SetSpacing` 与安全区 `10%` 暖色压光；无 `GetFont`／`GetSpacing` 兼容；不改用户字号、频道色或消息字符串 | `runtime-corrected / P5`，Chat smoke 通过 | `/reload` 确认 `chat-runtime=1.9`、连续阅读舒适度与各频道语义辨识度 |
| V3 runtime contract v1.10 | 停用安全区压光；恢复 pfUI 配置字体；受管 `HookAddMessage` 仅把 `ChatTypeInfo.CHANNEL` 基础 RGB 映射为 `0.36,0.16,0.14`；不写全局颜色或消息字符串 | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.10`，以新公共频道消息验证墨色和语义色 |
| V3 runtime contract v1.11 | 受管 `ChatFrameN` 使用透明阴影色与零偏移；保留旧字体、无描边、`3px` 行距、公共频道深酒红与无压光书页 | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.11` 与正文无重影 |
| V3 runtime contract v1.12 | ChatMOD 1.1／pfUI／原生颜色审计；七类基础语义墨色；时间戳、职业、等级、物品品质、URL、自身高亮精确内嵌色白名单；有效实机截图 | wrapper 位于 ChatMOD 实际注色之前，截图仍为原始亮色；`runtime-failed / P5` | 接管 ChatMOD 的真实最终出口 |
| V3 runtime contract v1.13 | 共享幂等色板转换；pfUI `HookAddMessage` 与 ChatMOD `ORG_AddMessage` 双出口；晚出现 hook 发现；两种相反加载顺序 smoke；有效重启截图 | 用户确认 runtime 正确但新消息仍为原始亮色；`runtime-failed / P5` | 移除脆弱身份／停靠门禁，并建立 pfUI 直接桥 |
| V3 runtime contract v1.14 | Parent 作用域；无身份门禁 ORG wrapper；pfUI Chat 最终输出直桥；显式十六进制 pattern；运行时调用／变更计数；有效实机计数 | `m2/h3/f3/c30/x5` 固定不变；第三个可见 Frame 被启发式排除，`runtime-failed / P5` | 移除 `pfCombatLog` 颜色门禁 |
| V3 runtime contract v1.15 | 左书 Parent 唯一作用域；`pfCombatLog` 启发式不再排除；书外 Frame 回退；版本与回归断言更新；有效实机颜色反馈 | 色板已进入视觉审查，但频道／职业目标色过度压缩；`runtime-failed / P5` | 扩大语义与职业色差，同时保持深墨感 |
| V3 runtime contract v1.16 | 七类基础语义互异；时间戳独立深青；九职业一对一；代表纸色上约 `4.5:1` 静态对比；有效实机反馈 | 战士／牧师仍发灰且频道扫读不足；`runtime-failed / P5` | 增加最近色距离门禁并按色相优先重排 |
| V3 runtime contract v1.17 | 七类基础与九职业按色相优先重排；战士铁锈红／牧师中性灰；RGB 最近距离 `>=35`；代表纸色对比 `>=4.5:1` | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.17`，重点比较战士／牧师及世界／系统／警告 |
| V3 runtime contract v1.18 | Vanilla 原色相等比例深墨；团队焦橙／小队蓝紫分色；DPSMate 与未知亮色保色相压暗；多层桥终态幂等；链接载荷不变 | `runtime-corrected / P5`，完整静态回归通过 | `/reload` 确认 `chat-runtime=1.18`，重点比较团队／小队、职业原色识别与 DPSMate 红绿报告 |
