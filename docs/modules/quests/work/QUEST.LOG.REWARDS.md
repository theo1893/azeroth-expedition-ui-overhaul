# QL-D Quest Log 奖励槽 V2

## 元数据

- 模块：Quests／Quest Log 右页。
- 批次：`QL-D V2`。
- 组件 ID：`QUEST.LOG.REWARD.SLOT`。
- 子状态：`prompt-authorized / production-active`。
- 项目阶段：当前几何／fallback `P6 game-validated`；最终美术 `P3`。
- 固定执行器：本次已授权生产只允许
  `imagegen-0-143-0`／`@openai/codex@0.143.0`。
- 生成前模拟 ImageGen：`0/0`；production 预算为最多 `5` 次实际 ImageGen
  generation／edit，当前 `0/5`。用户已授权生产；尚未上传、尚无 countable
  output、source 或 runtime 位图。
- 当前请求：用户于 `2026-08-07` 先以 `QL-D-SIM-V2` 明确确认当前 V2 可见
  方向，随后逐字确认授权 `QL-D V2` 完整 production 正文、固定 Image 1／2、
  受限同循环 Image 3、最多五次实际调用，以及下述确定性处理与真实排版预演。
- 用户问题来源：`2026-08-04` 实机截图确认多奖励重叠／末端裁切、详情与奖励
  字体难读，以及 pfUI 平面黑灰奖励卡片过于现代。
- 实机修复确认：`2026-08-05` 用户确认 Quest 右页的既有 bug 和显示问题均已
  修复；覆盖 FrameXML 锚点错误、奖励间隔／换行、详情末端及原生 NameFrame
  回显。该确认接受当前运行时几何和 fallback 表现，不等于确认 QL-D V2
  最终奖励槽美术方向或授权 ImageGen。

## 美术基准继承

- 锁定视觉基准：
  [`任务详情面板_视觉基准_v1.png`](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png)，
  SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- 稳定 Prompt provenance：
  [`ART_BASELINE.md`](../ART_BASELINE.md)、
  [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md) 的“奖励槽与分隔”、
  [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
- 当前邻接 runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogShellV4.tga`，SHA-256
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`；
  只提供已接受书页综合色、材料尺度与真实摆放环境。
- 已接受漆章 atlas：
  `addon/AzerothExpeditionUI/Media/Quests/QuestToolWaxSealStatesV1.tga`，SHA-256
  `f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`；
  只用于还原当前相邻页面，不属于奖励槽生成输入。
- 用户实机截图只用于诊断 provider 输出、阅读密度、重叠与裁切；截图像素没有
  进入模拟稿，也不得成为 source、Image 3 或修图输入。

## 组件合同

- 真实对象：`QuestLogItem1..MAX_NUM_ITEMS`；原 Button、图标、数量、名称、
  品质色、Tooltip、点击脚本和 provider 显隐全部保留。
- Quest Log 奖励只读；状态为 `normal／hover／pressed／disabled`，没有
  `selected`。
- 单格真实命中盒固定 `108 × 41 UI px`；名称安全宽 `64px`；两列间隔
  `8px`，同行间隔 `4px`，分区标题至第一行间隔 `5px`。
- 每个奖励分组由真实标题 FontString 起锚；第偶数项锚到前一项右侧，第奇数项
  锚到前两项下方。0／1／2／4／6 数量均不得依赖 provider 的旧锚点。
- `QuestLogItemReceiveText`／`QuestLogRequiredMoneyText` 保持内在宽度，金额
  Frame 不得被推到 ScrollChild 外。详情末端按最底可见对象及原生
  `QuestLogSpacerFrame` 重算，不能固定为 `324px` 后裁掉奖励。
- 正式位图如获确认，只能绘制容器材料：浅削角旧皮革边框、克制氧化黄铜边、
  左侧深皮革图标凹槽、右侧安静羊皮纸名称面和窄接触阴影。图标、数量、名称、
  品质色、状态文字和发光均不得烘焙。
- 任何媒体缺失时 fail-open 到当前暖纸色程序化 fallback；不能阻止奖励数据、
  鼠标或 Quest Log 加载。

## 当前代码修复

- Quests runtime `1.22` 对选择奖励、法术奖励和固定奖励分别读取真实数量并
  `ClearAllPoints` 后重建双列锚点；每项固定 `108 × 41px`，不再继承 pfUI
  压缩后的旧尺寸或 provider 重叠点。
- 复核确认 pfUI 的正 `4px` offset 实际把 backdrop 向 Button 内缩；runtime
  `1.21` 的 `SetAllPoints(item)` 反而把 fallback 放大到 Button 全边界。runtime
  `1.22` 改用两个显式锚点，把 backdrop 四边各向内收 `4px`；配合 `8px`
  Button 列距，同排卡片之间形成 `16px` 的稳定可见纸面间隔。
- 最新实机截图确认上述 backdrop 修复已执行，但三件选择奖励的首行仍相接；
  这证明 provider 在 AEUI 重排后又把真实 Button 写回了旧锚点／尺寸。runtime
  `1.23` 因此对 `QuestLogItemN.ClearAllPoints`、`SetPoint`、`SetWidth`、
  `SetHeight`／`SetAllPoints` 安装事件驱动几何锁：晚到写入会立即恢复当前分组的
  `108×41px`、`8px` 列距和 `4px` 行距，不新增维护型 OnUpdate。smoke 主动
  模拟 `-8px` 列锚点与 `116×35px` 尺寸回写并要求合同保持。
- 后续实机截图仍显示原生名牌相接，最终定位到作用域所有权事实：AEUI 接管
  `Quest Log` 后 pfUI 的同名 skin 被明确跳过，真实路径没有 `item.backdrop`；
  可见灰褐卡面来自 Blizzard `QuestLogItemNNameFrame`。runtime `1.24` 为每个
  原 Button 创建无鼠标的 adapter-owned 暖纸程序化容器，把真实图标、数量与
  名称迁入容器，隐藏并锁住原生 NameFrame 的晚到 `Show()`，同时保留 Tooltip、
  点击脚本、品质色和 Button 命中区。若 stock 数量 API 在 provider 晚刷新期间
  全部返回 `0`，则以真实可见 `QuestLogItemN` 范围完成最终双列布局兜底。
- runtime `1.24` 实机在 `QuestLogItemReceiveText:SetPoint()` 报出
  `QuestLogItem3 is dependent on this`：AEUI 的组首奖励依赖分组标题，原生 FrameXML 又会把
  `ItemReceiveText` 反向锚到奖励项，数量状态短暂不一致时形成环。runtime
  `1.25` 改成单向锚点树：分组标题仍排在上一对象下方，但每组首个奖励直接
  锚到同一个上一对象，并额外预留 `5 + 14 + 5px` 的标题／间隔高度；奖励项
  不再依赖任一分组标题。smoke 会模拟原生把 ReceiveText 锚回 Item3，并在
  任意锚点环出现时直接失败。
- Quest Visual Theme `1.8` 新增 `detailHeading` 与 `detailBody`：标题为
  Noto Serif SC `14px`、正文／奖励名为 `pfUI.font_default` `12px`，均无
  outline、无 shadow。
- 正式槽资产尚未确认前，runtime `1.25` 的 adapter-owned 容器只使用低透明
  暖纸底和深赭／旧黄铜边；它是可回退的程序化临时视觉，不是最终 source。

## V1 历史确定性本地模拟

- 规格：
  [`quest_log_reward_slots_simulation_v1.json`](../../../../tools/specs/quest_log_reward_slots_simulation_v1.json)，
  SHA-256
  `dab0f2685367fb66f8ee8c4454443c3ef9f8b6cf9da1120c12d1ce9e879460ff`。
- renderer：
  [`render_quest_log_reward_slots_simulation_v1.py`](../../../../tools/render_quest_log_reward_slots_simulation_v1.py)，
  SHA-256
  `3bf318e405e8dfd3d5730f17735feca25bfaf2280bcf945ddef14eb36d94456a`。
- Python fallback：`D:\Softwares\miniconda3\python.exe`，Python `3.13.5`，
  Pillow `11.3.0`；`py -3` 在当前设备不可用。
- 复现命令：

  ```powershell
  D:\Softwares\miniconda3\python.exe tools\render_quest_log_reward_slots_simulation_v1.py tools\specs\quest_log_reward_slots_simulation_v1.json --repo-root .
  ```

- ignored 输出：
  - `generated/quests/ql-d-reward-slots/simulation/V1/quest_log_reward_slots_sim_v1.png`，
    `676 × 464`，SHA-256
    `72be6792c80aab4485013205bc57314d2633c93baab0ba5960104f13925a6f1a`；
  - `quest_log_reward_slots_sim_v1_review_2x.png`，`1352 × 928`，SHA-256
    `430bf6e76d75a6dad928004b22636905a52ee8bdccf4af5a862d895d3957e235`；
  - 模拟报告 SHA-256
    `dde2a175ed64ce4442c5af316ea1471c601b342e9c8727fa3d355fe4eaae495c`。
- 模拟只展示方向：第一排为二选一，后两排为四件固定奖励；六格依次覆盖
  normal、hover、normal、pressed、normal、disabled。所有示例图标、数量和
  中文名称都是脚本动态绘制，不属于容器像素。
- 模拟像素为非权威 ignored 证据，永远不得晋级 source、作为生成上传或进入
  addon runtime。当前分支可由 tracked spec／renderer 确定性重建，因此没有
  发布 handoff 检查点。

V1 在 Windows 上形成的具体像素已被 V2 当前邻接 UI 预演取代；V1 的物件方向
与真实奖励几何仍保留为历史 provenance，不再作为当前用户确认对象。

## V2 当前邻接 UI 确定性本地模拟

- specification：
  [`quest_log_reward_slots_simulation_v2.json`](../../../../tools/specs/quest_log_reward_slots_simulation_v2.json)，
  SHA-256
  `d03de08ee54597af0cbbaf7b0f467e14a59a6a9f29bf1fbc153d1b608ec91ebd`。
- renderer：
  [`render_quest_log_reward_slots_simulation_v2.py`](../../../../tools/render_quest_log_reward_slots_simulation_v2.py)，
  SHA-256
  `6934b3fb18207a5619f76786d557cd41aaa991af1cba7abcec41c61b5e231d69`；
  它复用 V1 的简单几何奖励槽 renderer，只在最终合成中加入当前 accepted
  `QuestLogSealPurityRibbonV1.tga` 闭合根部，并按真实 runtime 层序重新后绘
  QS-A1 火漆。
- 当前 accepted/runtime 邻接 UI：`QuestLogShellV4.tga`、QS-A1 normal 漆章、
  QS-B1 V7-A `32×28px` 闭合载体根；层序为书体 → 奖励槽／动态示例内容 →
  载体 `ARTWORK` → 火漆 `OVERLAY`。
- Python：conda 环境 `py312` 的实际 `sys.executable` 已写入 ignored 模拟报告；
  tracked 文档按跨设备规则只保留环境名。Python `3.12.12`，Pillow `12.0.0`；
  OS 为 macOS／Darwin。
- 复现命令：

  ```text
  conda run -n py312 python tools/render_quest_log_reward_slots_simulation_v2.py tools/specs/quest_log_reward_slots_simulation_v2.json --repo-root .
  ```

- ignored 输出：
  - `generated/quests/ql-d-reward-slots/simulation/V2/quest_log_reward_slots_sim_v2.png`，
    `676×464`，SHA-256
    `687b9836c4342a3ede68e7544e764d67bffcecd2130d6f6cc1c632b0ffce9991`；
  - `quest_log_reward_slots_sim_v2_review_2x.png`，`1352×928`，SHA-256
    `c6457cb9e3cc2c4493450e2399f70170dd87ac3ddaca7b9feb4bcd1ee1d11c01`；
  - 模拟报告 SHA-256
    `c76ee0c62a7980bf39b92c90d11efe71929bf51ea0abc8378369d162010bff18`。
- V2 继续提出“一枚真实奖励 Button 对应一枚浅凹公会装备签槽”：深胡桃
  旧皮革浅削角外沿、被磨损打断的克制氧化黄铜边、左侧深皮革图标凹槽、
  右侧安静羊皮纸名称面和窄纸面接触阴影。六格依次覆盖 normal、hover、
  normal、pressed、normal、disabled；没有 selected。
- 示例物品图标、数量、中文名称、品质色和金额都是 renderer 动态示意，不属于
  未来容器资产。离线正文使用仓库 Noto Sans SC `12px` 近似中文客户端的
  `pfUI.font_default` 尺度；字体像素和示例文案不属于方向确认范围。
- ImageGen `0/0`，本地渲染错误 `0`。模拟可由 tracked spec／renderer
  确定性重建，且当前没有换设备／push 请求，因此没有发布 handoff。
- 用户方向结论：用户于 `2026-08-07` 回复 `QL-D-SIM-V2`，确认该具体版本。
  写回 production 的可见条款为：一枚真实奖励 Button 对应一枚浅凹公会装备
  签槽；深胡桃旧皮革浅削角外沿；黄铜只作被磨损打断的暗哑边迹；左侧为深
  皮革图标凹槽；右侧为安静羊皮纸名称面；窄纸面接触阴影；当前 `108×41px`
  双列结构、页面综合色和相邻漆章／载体层序不变。示例图标、文字、品质色和
  模拟几何像素均未被接受为 source 或生产输入。

## V2 展示区域门禁

- 合同：
  [`quest_log_reward_slots_sim_display_region_v2.json`](../../../../tools/specs/quest_log_reward_slots_sim_display_region_v2.json)，
  SHA-256
  `288673c9d5e6dbc16d75630f68a84bb7d5afa22c9b48631fedeb42f1fd81118e`。
- 运行命令：

  ```text
  conda run -n py312 python .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/quest_log_reward_slots_sim_display_region_v2.json --report generated/quests/ql-d-reward-slots/simulation/V2/quest_log_reward_slots_display_region_report_v2.json
  ```

- 结果：`pass`；场景为 0／1／2／4／6 奖励，`5/5` 通过，violations `0`，
  first failure `null`。ignored 报告 SHA-256
  `bfa64c2892232e2fe9d8cb442a4a22b359bb22d9a2ea3997d7b38d4e250945e4`。
- 该结果只证明方向稿几何，不证明最终纹理、客户端 UV、交互或 P6 实机表现。

## 最终执行正文

### 固定生产输入与权威职责

- `Image 1`：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
  它与 Quests／全局 Prompt 共同裁决 2004 年前后香草魔兽二维手绘年代、
  粗厚略不规则轮廓、明暗切面、材料层级、左上暖光、综合色、磨损尺度和
  反模式；不得复制完整书页、任务行、标题牌、漆章、书签、文字或布局。
- `Image 2`：
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
  它只校准当前 accepted Quest Log 的纸页综合色、深胡桃皮革／旧黄铜邻接
  色温、绘制精度、左上光向和磨损尺度；不得复制书形、纸页轮廓、页沟、针脚、
  包角、透明 Alpha 或任何现成像素。冲突时始终由 Image 1＋全局／Quests
  基线裁决。
- attempt 1 只允许按上述顺序上传固定 SHA 的 Image 1／2。不得上传 V1／V2
  模拟、实机截图、QS-A1 漆章、QS-B1 载体、pfUI 原卡面或旧失败候选。
- 计划 source：
  `assets/source/quests/ql-d/QuestLogRewardSlot_Master_v1.png`；计划 runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogRewardSlotStatesV1.tga`。
  两者当前均不存在。

### source、四态 atlas 与 runtime 合同

- ImageGen 只生成恰好 `1` 枚 `normal` 基础物件：单个只读奖励 Button 的
  “浅凹公会装备签槽”。不生成四态工作表，不生成多个槽，不生成完整奖励栏。
  `normal／hover／pressed／disabled` 由同一 normal source 确定性派生，四态
  Alpha 逐像素相同；Quest Log 奖励没有 `selected`。
- raw 目标是 `1024×1024 RGB`，画布外部为单一 `#00FF00`。单物件水平正投影、
  无旋转，目标可见 bbox 为 `[72,345,952,679]`，即 `880×334px`、约
  `2.635:1`；包括窄接触阴影在内均不得越界或触边。
- provider 返回正方形其他边长时只允许同轴等比归一为 `1024²`；非正方形
  输出直接失败。允许从画布边缘执行连通色键、软去绿和透明 RGB 清零；不得
  删除物件内部封闭区域。候选必须只有一个主物件、四边完整、可见 bbox 宽高比
  位于 `2.58..2.69`，否则属于美术／结构失败，确定性步骤不能伪装为通过。
- 合格 Alpha bbox 只允许一次等比 bbox-fit，居中放入 `1080×410 RGBA`
  canonical canvas 的 `[20,7,1060,402]` 安全盒；禁止非等比拉伸、裁切主体、
  旋转、镜像、重绘或补结构。该 canonical canvas 即 planned source 的像素
  内容；透明 RGB 必须全为零。
- canonical source 以十倍 runtime 几何审查：图标动态安全区
  `[40,40,370,370]`，名称动态安全区 `[410,40,1050,370]`（`xyxy`）。前者
  必须完全落在安静的深皮革凹槽内；后者必须完全落在连续低对比羊皮纸面内。
  所有图标、数量、名称、品质色、文字状态、发光和 Tooltip 均由游戏持有。
- source 全幅用 LANCZOS 等比缩为 `108×41px` normal runtime cell；再从该
  normal 像素确定性派生：hover 对 Alpha 内 RGB 使用
  `R=min(255,round(1.04R+4))`、`G=min(255,round(1.03G+3))`、
  `B=min(255,round(1.01B+1))`；pressed 使用
  `round(0.82R／0.80G／0.78B)`；disabled 先计算
  `L=round(0.299R+0.587G+0.114B)`，再对每个通道使用
  `round(0.30C+0.50L)`。每步 clip 到 `0..255`，Alpha 不变，最后再次清零
  全透明 RGB。
- runtime atlas 固定为 `512×64 RGBA TGA`，四个 `128×64` cell 顺序为
  normal／hover／pressed／disabled。每格的 `108×41px` 内容放在
  `[cellX+10,11,cellX+118,52]`；透明 padding 不进入 UV。对应精确采样区为
  normal `[10/512,118/512,11/64,52/64]`、hover
  `[138/512,246/512,11/64,52/64]`、pressed
  `[266/512,374/512,11/64,52/64]`、disabled
  `[394/512,502/512,11/64,52/64]`。
- P5 时只在现有 `item.aeuiRewardContainer` 内增加一张无鼠标 `ARTWORK`
  Texture，精确覆盖真实 `108×41px` Button；加载成功时停用程序化颜色面，
  媒体缺失时继续 fail-open 到现有暖纸 fallback。状态优先级为 disabled ＞
  pressed ＞ hover ＞ normal。pressed 期间容器以及其真实动态图标／数量／名称
  一起向右下移动 `1px`，真实 Button 命中盒不移动；不得使用维护型 `OnUpdate`。
- 每次 countable candidate 必须先完成对象／材质／Alpha／安全区审查，再从该
  候选构造临时四态 atlas，并在当前 `QuestLogShellV4`、QS-B1 V7-A 闭合根和
  QS-A1 漆章上以真实字体、图标、数量、品质色重做 `0／1／2／4／6` 奖励场景。
  单格 `108×41px`、列距 `8px`、行距 `4px`、名称宽 `64px` 和当前 ScrollChild
  高度合同不得改变；全部展示区域通过后才可交用户复审。

### 生产正文完整性预检

- 复杂度：`single-object normal source + deterministic four-state atlas + runtime assembly`。
- 结论：`pass`；未知但执行必需的值：`无`。

| 门禁 | 执行正文证据 | 结论 |
|---|---|---|
| 物件身份、数量、状态与动态内容排除 | 正文限定一枚 normal 装备签槽；四态由 exporter 持有；逐项排除 icon／count／name／quality／selected | pass |
| Image 1／2 inherit、ignore 与冲突 | 正文逐张声明最高美术职责、邻接职责、忽略项与冲突顺序 | pass |
| Canvas、bbox、方向、透视、尺度与光照 | `1024²`、`880×334`、水平正投影、左上暖光、无触边 | pass |
| 解剖、材料、边缘与层序 | 外皮革浅削角、断续旧铜、左凹槽、右纸面、窄接触阴影逐层定义 | pass |
| icon／name 安静区、crop、stretch、tile、repeat | 以未来 `108×41px` 坐标冻结 `[4,4,37,37]`／`[41,4,105,37]`；禁止拉伸／平铺／重复 | pass |
| 美术 DNA、反模式、色键与最终自检 | 香草低分辨率手绘、具体禁止项、`#00FF00`、单物件与 downsample 自检齐全 | pass |

### `QL-D V2` 最终 production prompt

Create exactly one isolated production raster asset for Turtle WoW 1.18.1: one
shallow, front-facing guild-archive equipment docket that serves as the empty
visual chassis for a single read-only `QuestLogItem` reward Button. At runtime
this one object will be displayed at exactly 108 x 41 UI pixels. The live game
will draw a 33 x 33 item icon in [4,4,37,37], a quantity over that icon, and a
dynamic item name in [41,4,105,37], while preserving item-quality colour,
tooltip and click behavior. Draw only one empty normal-state chassis. Do not
draw multiple slots, a reward section, a state sheet, a selected state, an item
icon, a placeholder icon, a number, a name, quality glow, text or tooltip.

Reference authority and filtering:
1. Image 1 plus the Azeroth quest-ledger art baseline is the highest visual
   authority. Inherit its circa-2004 vanilla World of Warcraft low-resolution
   2D hand-painted bitmap language, thick slightly irregular silhouette,
   broad readable light/mid/shadow planes, tangible material thickness, warm
   upper-left light, muted ochre/umber/old-brass palette, restrained edge wear,
   and substantial expedition-archive weight. Ignore and do not copy its full
   open book, pages, quest rows, title plaque, compass, wax seal, ribbons,
   buttons, text, icons, page borders or complete layout.
2. Image 2 is a secondary adjacency reference only. Inherit only the accepted
   live quest book's parchment colour temperature, dark-walnut leather and
   oxidized-brass relationship, paint scale, edge softness, upper-left light
   direction and wear scale so the docket belongs on that exact page. Ignore
   its full book silhouette, page shapes, spine, stitches, brass corners,
   transparency and every directly reusable pixel. If the references conflict,
   Image 1 plus the vanilla quest-ledger rules wins; Image 2 may only tune local
   adjacency.

Canvas and occupancy are mandatory. Output an exact 1024 x 1024 RGB bitmap.
Every pixel outside the object must be one uniform solid #00FF00 chroma-key
background with no gradient, vignette, checkerboard, haze, texture or colour
spill. Place exactly one horizontal object, unrotated, fully inside target
visible bbox [72,345,952,679], 880 x 334 pixels, approximately 2.635:1. Include
the narrow page-contact shadow inside this same bbox. Leave clean green space
on all four sides and do not touch or crop any canvas edge. Use a straight-on
orthographic front view with no perspective tilt, no foreshortening and no
three-quarter angle. Design for reduction to 108 x 41 pixels, never for
stretching, tiling, mirroring or nine-slicing.

Silhouette and construction: make one quiet, substantial, shallow recessed
archive fitting, not a modern card. Its outer contour is a hand-painted long
near-rectangle with mostly straight sides, small uneven shallow chamfers at the
four corners and one-to-two percent natural edge irregularity. It must not be a
rounded pill, capsule, mobile-app card, label tag, arrow, pointed bookmark,
fishtail or ornate metal plaque. The outer rim is aged low-saturation dark-
walnut leather with visible but restrained thickness: a short warm upper-left
light plane, a broad smoked-brown face and a narrow deep-umber lower/right
shadow plane. Add only sparse, broad wear at exposed corners; do not cover the
whole surface with fine grain, embossing or procedural noise.

The oxidized brass is subordinate. Use only a few short, interrupted,
low-contrast old-brass binding traces or small retaining accents along selected
outer-edge segments. Wear must visibly break these accents. Never create a
continuous gold outline, complete metal frame, bright top rail, symmetric
corner ornaments, rivet row or jewellery-like trim. Brass highlights are short,
dull and no brighter than needed to separate it from leather.

Inside the same chassis, build two integrated functional zones without turning
them into separate modern cards. The left zone is a recessed square dark-
leather icon well. Relative to the final 108 x 41 object, the entire dynamic
icon-safe rectangle [4,4,37,37] must be flat, dark, quiet and unobstructed; draw
no icon, symbol, slot placeholder, coloured quality border or central emblem.
Give the recess only a broad inner shadow and a restrained upper-left lip so it
still reads at 33 pixels. The right zone is one continuous smoked warm-parchment
name field integrated beneath the leather rim. Relative to the final object,
the entire dynamic name-safe rectangle [41,4,105,37] must stay calm, continuous
and low contrast, with no seam, ruling, ornament, scratch, stain, highlight,
glyph or printed line. The parchment may have one broad value drift and slight
edge wear only; it must remain quieter than the surrounding quest page text.
Separate the icon well and name field with one shallow material joint, not a
bright divider or independent frame.

Add a very narrow, soft painted contact shadow immediately below and to the
right of the chassis, equivalent to only one or two runtime pixels and fully
contained inside the object bbox. It must make the fitting sit on the accepted
quest page without becoming a floating black drop shadow. Keep the upper-left
edge slightly warmer and the lower-right edge deeper, matching both references.

Style lock: the downsampled result must read immediately as a small UI sprite
painted for a 2004-era vanilla WoW interface and as a formal guild reward docket
within the Azeroth expedition journal. Use coarse hand-painted decisions,
broad low-frequency wear, muted warm parchment, smoked walnut leather and dull
broken brass. It must feel weighty and archival while remaining subordinate to
the quest text and item icon. It must not look photorealistic, vector-clean,
procedural, precision-industrial or like a modern brown HUD component.

Strict exclusions: no full book, page, page frame, reward panel, row of slots,
button stack, wax seal, ribbon, bookmark, compass, quill, emblem, rune, text,
letters, numerals, glyphs, icon, item silhouette, quantity, quality colour,
selection glow, state variants, stitching, holes, rivet row, buckle, hinge,
gemstone, bright gold, complete metallic border, mirrored ornament, glass,
translucent black, neon, skull, spike, demonic horn, Diablo-style altar,
Skyrim-style minimalist overlay, modern rounded card or cast shadow outside the
object.

Before returning the image, verify all of these objective gates: exactly one
empty normal-state object; exact 1024 x 1024 RGB canvas; uniform #00FF00 outside
the object; one horizontal approximately 2.635:1 bbox fully inside
[72,345,952,679]; straight orthographic view; shallow irregular chamfered
dark-walnut rim; only broken dull-brass accents; unobstructed icon-safe
[4,4,37,37] and name-safe [41,4,105,37] regions in final-object proportions;
no baked icon, count, name, quality, text, selected state, book, seal, ribbon,
continuous gold outline or modern rounded card; readable material hierarchy
after reduction to 108 x 41 pixels.

### 自主修复循环与授权边界

- 不可变边界：组件 ID；恰好一枚 normal 基础物件；固定 Image 1／2、顺序、
  SHA 和职责；`1024²`／目标 bbox／水平正投影；`108×41px` runtime；图标／
  名称安全区；四态确定性派生；atlas cell／UV；真实 provider 映射；全部禁止
  烘焙和当前 `0／1／2／4／6` 展示区域合同。
- attempt 1 使用固定 Image 1／2 fresh generate。attempt 2–5
  仍固定上传同 SHA 的 Image 1／2；只有紧邻前稿保持单物件、正确两区解剖、
  基本比例／综合色／光向，且失败仅是局部边缘、黄铜连续度、纹理密度、纯绿
  背景或轻微安全区干扰时，才允许把该紧邻前稿作为唯一 Image 3 edit input。
  语义、两区结构、透视或总体材料错误时必须从固定 Image 1／2 regenerate。
- 允许的确定性后处理仅为：正方形同轴 `1024²` 归一化、边缘连通色键／软去绿、
  透明 RGB 清零、通过 `2.58..2.69` 比例门禁后的单次等比 bbox-fit、canonical
  source 装配、固定四态 RGB 派生、atlas packing、metrics、真实排版预演和
  display-region 验证。不得非等比变形、重绘、补结构或用后处理修复美术失败。
- 新增／替换参考、上传模拟或截图、改变对象／状态数量、画布、视觉方向、
  安全区、runtime 几何、provider、Alpha／atlas 策略或允许任何动态内容烘焙，
  都必须停止并重新授权。
- 本次授权最多 `5` 次实际 ImageGen generation／edit，含首次；没有图片且没有
  provider 生成证据的流程错误不占额度。任一候选完整通过即停止并交用户
  复审；第五次仍失败则停止于 `repair-budget-exhausted`。当前 production
  已进入自主修复循环，开始时为 `0/5`。

## 执行记录

- 本轮只运行 tracked V2 renderer 与展示区域 validator；两次命令、解释器、
  输入 SHA 和输出 SHA 已记录在上方。
- 用户于 `2026-08-07` 以 `QL-D-SIM-V2` 确认具体模拟方向；随后只完成固定
  production 输入、source／atlas／四态／后处理／真实排版合同和逐字正文。
- 用户随后明确回复：`确认授权 QL-D V2；允许每次上传固定 SHA 的 Image 1/2，
  允许同循环紧邻前次输出仅在冻结修复边界内作为 Image 3 edit 输入；最多 5 次
  实际 ImageGen 调用，流程错误不占额度；允许按合同执行正方形归一化、边缘
  连通色键、透明 RGB 清零、等比 bbox-fit、四态派生、atlas packing 与真实
  排版预演。` 该授权只开放已冻结正文，不开放换参考、改几何、接入 addon 或
  提前晋级 source／runtime。
- 实际生成／修图调用 `0/5`；流程错误 `0`；上传 `0`；没有候选、source、
  runtime atlas 或 addon 代码改动。

## 审查记录

- 自动几何：0／1／2／4／6 五场景全部通过，违规 `0`。
- 本地目视：六格均落在右页纸面，图标／数量／名称可辨，normal／hover／
  pressed／disabled 有克制差异；容器没有烘焙动态内容。当前 V7-A 闭合载体与
  QS-A1 火漆按 addon 层序装配，未遮挡奖励标题或槽体。
- 实机审查：用户于 `2026-08-05` 确认当前右页 bug 与显示均已修复，当前
  几何／fallback 进入 `P6 game-validated`。仓库没有新增或虚构本轮截图路径。
- 用户方向审查：`QL-D-SIM-V2` 已确认；确认只覆盖文字化可见条款，模拟像素、
  示例动态内容和 exact RGB 仍非权威。
- 未完成审查：最终 ImageGen 候选、小尺寸纹理、正式四态 atlas、P5 addon
  接入与 P6 实机；这些尚未生产，不属于当前 fallback 的实机验收。

## 尝试摘要

| 尝试 | 类型 | 实际生图 | 结果 |
|---|---|---:|---|
| `QL-D-SIM-V1` | 历史确定性本地模拟 | `0` | 由当前邻接 UI 的 V2 取代 |
| `QL-D-SIM-V2` | 确定性本地模拟 | `0` | `simulation-confirmed / P2`；display-region `5/5 pass` |
| `QL-D V2 production` | 固定 Image 1／2 的单物件 generate；已获逐字授权 | `0/5` | `prompt-authorized / production-active / P3` |

## 下一门禁

当前 runtime 几何／fallback 的实机门禁、V2 方向门禁和独立 production 授权
门禁都已通过。下一门禁是按最多五次实际调用执行 generate → review → retry
自主循环；每个 countable output 都必须完成技术检查、四态临时 atlas、真实
`0／1／2／4／6` 排版和 display-region 检查。内部完整通过即停止并交用户复审；
第五次仍失败则停止等待用户决定。用户接受候选前不得晋级 source／runtime、
修改 addon 或把生产授权误写成接入授权。
