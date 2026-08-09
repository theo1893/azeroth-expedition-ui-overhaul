# AB.RAIL.V1

## 元数据

- 模块：`actionbars`
- 组件 ID：`AB.RAIL.V1`
- 工作版本：`AB.RAIL.V1.r4`
- 子状态：`repair-prepared`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`；attempt 1–4 已调用，不得改用其他执行器
- 当前操作：`regenerate`；attempt 4 已成为近严格正方并可确定性归一，但仍有四角 L 形黄铜片和内框；完整 `AB.RAIL.V1.r4` 等待提交后执行最后一次
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 模拟脚本：`tools/render_action_rail_simulation.py`，SHA-256
  `0246691e44b932b34fa196165dab81484f4aba9e96c027a0ef6eec22478f3a25`
- 模拟 specification：`tools/specs/action_rail_v1_simulation.json`，SHA-256
  `27cb13d42ce22b432ba408deaaa23c054067bfb8d7b13f3f459a893abf8ddb26`
- Python：`D:\Softwares\miniconda3\python.exe`，`3.13.5`
- 本地渲染错误：`0`
- 模拟路径／SHA：
  - 战斗场景：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/AB.RAIL.V1.sim-v1.png`
    ／`123d1b4c485ec895741ef1cb3b64efa49d3bd31014cb6805e2c421cdd389cde6`
  - 等比例组合：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/AB.RAIL.V1.sim-v1.layouts.png`
    ／`a49088d18d7bbb8bda49e0932d0a4d0152f7807fccf5562f6058164b6e67e353`
- 模拟用户结论：`confirmed`；`2026-08-08`，用户原话：
  “接受 AB-RAIL-SIM-V1”
- 后续生产自动修复预算：最多 `5` 次实际 ImageGen 生图／修图，含首次；已于 `2026-08-09` 授权
- 当前实际生图：`4/5`
- 流程错误：`0`
- 多执行正文最坏实际生图数：`5`
- 锁定视觉基准：
  - Image 1：`assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`
    ／SHA-256
    `b5c364482adaace09af9b5196d2e8d4f7ef79d3b21706e189d94c106ba6ec2ba`；
    只负责香草时代手绘材质关系、深胡桃褐／烟褐／暗氧化黄铜配色、左上暖光、
    右下受压暗部、低饱和与克制磨损；本地模拟没有复制其像素
- 基准提示词 provenance：
  - `docs/modules/character/ART_BASELINE.md` 与
    `docs/modules/character/SUBMODULE_ART_BASELINES.md` 定义 Image 1 的原始视觉语义；
  - `docs/modules/actionbars/ART_BASELINE.md` 与
    `docs/modules/actionbars/SUBMODULE_ART_BASELINES.md` 把该语义收敛为 Rail 组件
- 次级参考：
  - `addon/AzerothExpeditionUI/Media/ActionBars/ActionSlotBaseV1.tga`，SHA-256
    `5c49a1db452560251422060545625b311e182ef5b8689be996aeda005b8e23ca`；
    只在本地模拟中作为当前 accepted/runtime 相邻图层，用于判断密度、遮挡和
    z-order；它不是 Rail 视觉权威、不是生产参考、不得上传
- raw：attempt 4
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/raw/AB.RAIL.V1.attempt-04.raw.png`
  ／SHA-256 `c29ea6d452d8ab858cd01da760a302022d114eec090358591c13d1130b6c0b4d`
- 候选审查工具：`tools/review_action_rail_candidate_v1.py`，SHA-256
  `af0bd3ddc5646aeb61a5df7a66f0abd856780374aaa7e06690d42a90a6ab5bb9`；
  只生成 ignored 指标、冻结 crop／九宫格装配和真实排版证据；opt-in canonical
  审查只允许完整 alpha bbox 纵横误差不超过 `1%` 时整体 fit 到冻结盒，不裁边、
  不重绘、不晋级像素
- 透明候选：attempt 4 review-only
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/transparent/AB.RAIL.V1.attempt-04.transparent.png`
  ／SHA-256 `852777377486dbd58d957c40b2b1084d379cfd618faaaf103983a37b2e7348ec`；
  固定 `remove_chroma_key.py --auto-key corners --soft-matte --spill-cleanup`
- canonical 色键审查：attempt 4 review-only
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/review-canonical/AB.RAIL.V1.attempt-04-canonical.canonical-key-review.png`
  ／SHA-256 `85f07b432dda5ebd1c8487a44a9027dead351b0ab802f8a85b0d4afc1defab87`
- 重组预演：attempt 4 canonical 九宫格组合板
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/review-canonical/AB.RAIL.V1.attempt-04-canonical.supported-layouts-board.png`
  ／SHA-256 `a8ac168ee8d95d98750ccb7a7c64779a28e4e5e1e9bff875bae7c79272ac7c12`
- 真实排版预演：attempt 4 canonical
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/review-canonical/AB.RAIL.V1.attempt-04-canonical.real-layout-1920x1080.png`
  ／SHA-256 `65ec3f3377147c83aa6c8320ffa64a088873760f3e22294ca78d175956306382`；
  `1920×1080`、UI Scale `0.81269841269841`，8 个真实参数实例，相邻槽位使用
  accepted runtime，姿态栏保留 pfUI fallback；仅 Rail 来自候选
- 实际展示区域合同／报告：
  - 合同：`tools/specs/action_rail_v1_sim_display_region.json`，SHA-256
    `6023ef0e6141f46cf6006b2b9f81705a034dea921be4fa73e3eba6ded503992e`
  - 报告：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/display-region-report.json`
    ／`aebb3938953cadaaa7d5b32245ea90305cd94d19b6b63d5d1d8e31a01c80685e`
  - `1×1／12×1／6×2／4×3／1×12`、低 border／scale、
    高 border／spacing／scale 与合并双栏共 `8/8 pass`，violations `0`
  - attempt 4 canonical 候选合同：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/review-canonical/display-region-contract.json`
  - attempt 4 canonical 报告：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/production/AB.RAIL.V1/attempt-04/review-canonical/display-region-report.json`
    ／SHA-256 `c1fe2bb937d3fa081197588de306545885558a76c953f292f8a3ecc8dff96a34`；
    provider 几何 `8/8 pass`、violations `0`，但不覆盖候选画布／bbox／材质失败
- 精确布局报告：
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/layout-report.json`
  ／`bb8f77299e54f2651afcf7b3017c97b45217ac6975dae581a86d58894299377c`；
  所有实例九宫格中心为正、按钮均包含、四角装饰与按钮区域无相交、层序正确
- 最终 source：无

## 跨设备 handoff

- 无。模拟可由已跟踪脚本与 specification 确定性重建，下一门禁不依赖 ignored
  像素；不得为本阶段发布 `handoff/actionbars/AB.RAIL/`。

## 美术基准继承

### 权威顺序

1. Character V3 锁定图与对应原始提示词：视觉 DNA 最高权威。
2. Action Bars 的 `ART_BASELINE.md` 与 `SUBMODULE_ART_BASELINES.md`。
3. `docs/GLOBAL_ART_BASELINE.md`。
4. `SUBMODULES.md` 与真实 pfUI 对象：几何、层序、状态和禁止烘焙权威。
5. 当前 accepted `AB.SLOT.BASE.V1`：仅本地相邻 runtime 上下文。

### 必须继承的视觉 DNA

- 物件身份是轻量远征装备承托轨，不是整块固定动作条面板。
- 深胡桃褐皮革／木芯为主体，暗氧化黄铜只作窄、断续、低对比外缘。
- 左上只有短促暖色摩擦光，右下为较暗的受压边；整体低饱和、粗颗粒、
  香草时代手绘小图块，而非写实材质渲染。
- 磨损集中在外缘和极少的四角紧固点；可拉伸中心保持低频、安静。

### 本组件级转译

- 一张正面方形正常态母版拆为九宫格；四角只在真实外框四角出现，四条边只沿
  真实外沿延伸，中心允许双轴拉伸。
- 横栏、竖栏、`6×2`、`4×3` 与 pfUI 合并双栏使用同一 `6 UI` 端宽和视觉厚度；
  行列变化只改变外轮廓，不增加内部格线。
- Rail 永远位于逐槽底座与 provider 动态内容之下，因此只能承担连续材质和
  最外轮廓，不能替代槽位可读性或交互反馈。

### 明确不继承

- 不继承 Character V3 的完整窗口轮廓、厚面板框、纸张、角色、装备槽、
  紫色品质光、文字、页签、按钮或布局。
- 不把 `AB.SLOT` 的具体槽框轮廓、图标中心或像素风格提升为 Rail 视觉权威。
- 不继承 V3 本地场景的占位单位框、施法条、攻击条、DoiteDPS、卷袋、饰品或
  背景像素。

### 冲突审计

- 锁定图是完整角色面板，而 Rail 是窄背景层：保留材料 DNA，舍弃完整窗口
  轮廓与厚重装饰。
- `AB.SLOT` 已经承担逐格轮廓；若 Rail 再画固定格线会产生双重边框，因此
  Rail 明确禁止任何按钮分格。
- pfUI 可让 Bar 1 与 Bar 6 共用 `mergedBackdrop`；固定单栏端帽会制造中缝，
  因此合并态必须以一块外围九宫格覆盖两行。

## 组件合同

- 逻辑对象与数量：每个启用且 `background="1"` 的 `pfActionBar*` 背景为一块
  `AB.RAIL`；Bar 1／6 满足 pfUI 原条件时由一块 `bar1.mergedBackdrop` 替代两块
  独立背景。
- 状态：只有 `normal`。Rail 没有 hover、pressed、cooldown、range、OOM、
  equipped、active 或 disabled 状态。
- provider 映射：`addon/pfUI/modules/actionbar.lua` 的 Bar `1–12` 既有 Frame、
  `bar.backdrop` 与 `bar1.mergedBackdrop`；不新建技能按钮、不改分页或动作槽。
- 显隐：`background="0"` 时 Rail 不存在／隐藏并恢复 pfUI 原视觉；autohide、
  combat fade、enable 与父 Frame 显隐自然传递，不另装维护循环。
- 交互：Rail 不接收鼠标，不改变 Parent、Point、Width、Height、Scale、命中区、
  拖动、锁定或 SavedVariables；`UpdateMovable` 行为保持原样。
- provider Bar Frame 公式：
  `width=(icon+2*border+spacing)*cols+spacing`，height 同式；第一个 icon Button
  锚点为 `border+spacing`，逐槽步长为 `icon+2*border+spacing`。
- Rail 真实目标是 `CreateBackdrop` 产生的背景 Frame，所以独立栏在 Bar Frame
  四周各外扩一个 `border`。合并态跨度为两个相同 Bar Frame 高度减去锚接
  `spacing`，再只在整体外围外扩一次 border。
- 当前物理实例如下：V3 主栏 Bar Frame `506×44 UI`、Rail `510×48 UI`，目标
  设备显示约 `493×43 px` 与 `497×47 px`；`6×2` Rail `198×70 px`，`4×3`
  Rail `115×88 px`，`1×12 / 48 UI` Rail `49×532 px`，合并双栏 Rail
  `497×88 px`。
- 已测范围：图标 `20–48 UI`、border `1–5 UI`、spacing `1–12 UI`、movable
  scale `0.75–1.5`；九宫格 `6 UI` 端宽在最小物理实例仍留下 `8×8 px`
  正中心。
- 生产画布：未来仅生成一张 `1024×1024 RGB` 方形母版；画布外部为精确
  `#00FF00`，完整物件在 `[160,160,864,864)`，裁切后为 `704×704`。
- 九宫格：source 裁切坐标边界为 `0／128／576／704`；对应画布中央可拉伸区
  `[288,288,736,736)`，即 `448×448`。未来 exporter 再按已确认 source
  确定 runtime atlas／UV；本阶段没有 runtime 输出。
- 安全区：可见紧固点只占最外 `2 UI`，不进入任何 Button backdrop；九宫格
  cap 内其余部分为安静过渡，不得放不可拉伸纹章或接缝。
- Alpha／色键：生成阶段为 RGB 精确绿幕；未来只允许确定性转 Alpha，并清零
  透明 RGB。不得用半透明雾、投影或 near-green 替代纯绿。
- 禁止烘焙：技能／物品图标、热键、数量、宏名、冷却、文字、页码、职业状态、
  距离红、法力蓝、不可用灰、装备绿、按下位移、hover／active 光、固定格线、
  狮鹫、消耗品、饰品、单位框、施法条、攻击条或 DoiteDPS。
- 失败回退：媒体、adapter、Frame 或版本检查失败时只恢复该 Bar 的 pfUI
  background，不得阻止 pfUI／AEUI 其余模块加载。

## 生成前模拟实例图

### 模拟合同

- 版本：`AB-RAIL-SIM-V1`
- 目标场景与 Frame 真实比例：`1920×1080` 的 V3 战斗信息纵栈；Bar 原点、
  UI Scale、local scale、Frame 与 backdrop 外扩全部按 provider 公式计算。
- 当前 accepted/runtime 相邻 UI：Bar `1–10` 代表实例使用已验收
  `ActionSlotBaseV1.tga`；Bar 11 姿态栏刻意保留 pfUI fallback，防止模拟暗示
  已扩大 `AB.SLOT` 接管范围。
- 真实对象数量与密度：战斗场景含主栏 `12×1`、副栏 `12×1`、姿态 `3×1`、
  辅助 `4×3`；等比例板另覆盖 `1×1`、`6×2`、`1×12`、极端参数和 `24` 槽
  合并双栏。
- 目标层序：`AB.RAIL → 当前槽位底座 → provider 动态图标／文字／状态`；
  Rail 不参与交互。
- 用户需要确认：深胡桃褐主体、断续暗黄铜窄外缘、极少四角铆钉、无固定格线、
  同厚横竖适配，以及双栏合并后没有中缝的整体轻重关系。
- 刻意简化且非权威：Alpha、真实九宫格接缝、source 笔触、微纹理、最终色值、
  runtime atlas／UV 与 adapter 均未生产。
- 禁止用途：不得作为 source／runtime，不得裁切、切片、晋级或作为 ImageGen
  edit／reference 输入。

### 本地模拟规格正文

用本地 Pillow primitives 绘制一层低对比、深胡桃褐的方形九宫格外壳；最外沿
为烟黑接触线，左上只有断续暗黄铜和短暖光，右下只有受压暗边；四角在空间足够
时各有一枚极小暗紧固点。中心只用宽幅低频矩形色块表示可双轴拉伸区域，不画
斜向焦点、内部格线、固定槽数或任何动态内容。然后把当前 accepted Action Slot
与抽象 provider 图标／状态按真实层序叠在上方。全屏图保留 V3 的单位框、Aura、
双施法条、攻击计时与 DoiteDPS 作为非权威邻接上下文；组合板按物理像素绘制
八个真实参数实例，只有 `1×1` 另给明确标注的近邻放大检查图。

### 模拟执行与内部检查

- 命令：
  `python tools/render_action_rail_simulation.py tools/specs/action_rail_v1_simulation.json --repo-root .`
- display 命令：
  `python .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_rail_v1_sim_display_region.json --report generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/display-region-report.json`
- ImageGen：`0/0`
- 本地渲染错误：`0`
- 真实 Frame 比例／屏幕位置：pass；主栏中心 `x=960`，上沿 `y=827`，没有改写
  已确认 V3 战斗焦点布局。
- 相邻 UI／对象数量／信息密度：pass；accepted 槽位只用于 Bar `1／6／3`，
  姿态 fallback 与未完成消耗品／饰品占位均有明确说明。
- 物件隐喻／材质／配色／重量：pass for user review；Rail 读作轻量连续承托，
  没有固定十二格板、石台或黑玻璃底座。
- 非权威简化：已在两张图和 specification 内明示。
- 内部结论：`displayable / simulation-reviewed`

| 本地渲染错误 | specification 版本 | 命令 | 错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 无 | `AB-RAIL-SIM-V1` | 上述 renderer／validator | 无 | 首次视觉复核将放大材质示意中的斜向色块改为安静矩形色团，并把竖栏说明移回画布；属于同版本地修整 | 不涉及 ImageGen |

### 用户方向结论

- 具体模拟版本：`AB-RAIL-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-08`；用户原话：
  “接受 AB-RAIL-SIM-V1”。
- 已确认并写回 `AB.RAIL.V1` 最终生产正文的可见条款：连续轻量承托轨；深胡桃褐
  主体；断续暗黄铜窄外缘；四角极少紧固点；中心安静；无固定格线；横／竖／
  多行同厚；Bar 1／6 合并双栏为一块外围 Rail 且无内部中缝；Rail 位于已接受
  Slot 与 provider 动态内容之下。
- 确认边界：只接受上述文字化视觉方向，不接受模拟像素；模拟图仍不得复制、
  裁切、切片、晋级、导出，或作为正式生产 edit／reference 输入。
- 拒绝时必须改变：按用户指出的可见布局、物件隐喻、材料层级、配色、视觉重量
  或整合关系制作下一模拟版本；不进入生产循环。
- 确认失效条件：上述任一可见关系发生实质变化。
- 生产授权：`authorized / 2026-08-09`。用户明确授权执行 `AB.RAIL.V1` 并同意
  最多 `5` 次实际生成／修复，同时授权把
  `assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`
  作为本组件唯一 Image 1 上传至外部 ImageGen 服务；该上传授权不得复用于
  其他组件，也不允许加入模拟图、`AB.SLOT` 或候选作为额外输入。
- 下一门禁：提交本次已授权正文与不可变修复边界，然后调用固定执行器执行
  `AB.RAIL.V1` attempt 1。

## 生产正文完整性预检

- 复杂度：`single-object / nine-slice / stretch`
- 结论：`pass as complete AB.RAIL.V1.r4 repair body`；`AB-RAIL-SIM-V1` 已获用户
  确认，全部确认条款与不可变边界保持不变；`.r4` 只处理 attempt 4 剩余的角饰／
  内框／尺度失败：保留近严格正方与低频中心，最终一次把暗氧化黄铜压成近黑接触
  迹并取消所有亮金属、角饰、内框和纹理填充，把绿色安全带改写为面积比例自检，
  提交后允许执行。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、范围、数量、状态与动态内容排除 | 一张正常态方形九宫格 Rail；明确不是完整动作条、槽位或状态 atlas | pass |
| 每张输入图的 inherit／ignore 职责与冲突 | Image 1 只继承材料 DNA；忽略窗口内容与几何；组件合同冲突时合同优先 | pass |
| 画布、边距、方向、透视、尺寸、光照与层序 | `1024² RGB`、`[160,160,864,864)`、正面无透视、左上暖／右下暗、Rail 最底层 | pass |
| 逐对象形态、材料、边缘、状态与相互关系 | 单对象、单正常态、皮革／木芯、近黑氧化黄铜接触迹、plain corners、安静中心 | pass |
| 安全区、裁切、拉伸、平铺、重复与接缝 | source cap `128`、center `448²`、九宫格边界与不可放置纹章范围已冻结 | pass |
| 美术 DNA、反模式、色键与最终自检 | 香草手绘、低频、低饱和、精确 `#00FF00` 与逐项自检完整 | pass |

- 未知但执行必需的值：无；未来 runtime atlas 格式由 accepted source 后的确定性
  exporter 冻结，不影响本次生成对象合同。
- 去冗余结论：只保留会改变对象、画布、拉伸安全区、材料关系与反模式的条款；
  不把模拟像素描述成可复制目标。

## 当前完整修复正文（`AB.RAIL.V1.r4`，同一已授权边界）

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.RAIL.V1: exactly one reusable normal-state square nine-slice master for the background rail beneath a pfUI action bar. The returned bitmap file itself must be exactly 1024 pixels wide by 1024 pixels high; do not return 1254 by 1254 or any other size. It is a lightweight expedition equipment support that stretches around an arbitrary legal action-bar frame. It is not a complete action bar, not a fixed twelve-slot plate, not an action-button base, not an icon, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 will be the locked Character V3 visual authority. Inherit only its classic vanilla-era World of Warcraft hand-painted value logic: deep walnut and smoke-brown aged leather or dark wood as the dominant body, low saturation, broad illustrated value groups, short warm wear light from the upper left, darker pressure toward the lower right, restrained handmade wear, and a deliberately old low-resolution game-interface character. Retain its oxidized-brass material relationship only as a fully oxidized near-black contact trace with no distinct metal ornament or bright metal hue; prior candidates repeatedly turned visible brass into heavy corner hardware. Express the restrained expedition hierarchy using walnut brown, smoke brown, and smoke black. Do not copy Image 1 pixels. Do not inherit its complete character-window silhouette, thick panel frame, paper, character, equipment slots, item or spell icons, purple quality glow, tabs, buttons, text, numbers, ornaments, internal layout, proportions, perspective, or 1254-by-1254 canvas. If Image 1 conflicts with this component contract, preserve only its material DNA and obey this prompt's exact geometry, quiet stretch zones, single-object scope, and exclusions.

Create a brand-new exact 1024 by 1024 RGB output file. This is the actual returned pixel canvas, not a conceptual 1024-square design placed inside a larger provider canvas. Use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background on every pixel outside the object, including all four canvas edges; every background pixel must have RGB values exactly 0, 255, 0 with no variation. Do not return transparency, a checkerboard, near-green, gradient, noise, haze, floor, shadow, vignette, or environmental scene. Place exactly one front-facing square rail master centered on the canvas, without perspective, camera depth, tilt, cast shadow, detached pieces, labels, guides, cell lines, or a presentation frame. The object's exact right-and-bottom-exclusive visible bounding box must be [160,160,864,864): no visible, antialiased, worn, highlighted, or contact-edge pixel may exist outside it, and the complete object must fill that exact 704-by-704 box without being clipped. The latest result was successfully square within 0.1 percent but much too large, normalizing to approximately [92,92,931,931), or about 839 square pixels. Preserve that square shape while reducing both dimensions by about sixteen percent. On the requested 1024 canvas, the object must occupy exactly 68.75 percent of the canvas width and height, leaving a uniform 15.625-percent green moat on every side. The green background must occupy more than half of all canvas pixels. If the fixed image service unavoidably wraps the requested composition in a 1254-by-1254 returned container, use the proportional fallback object box [196,196,1058,1058), exactly 862 square pixels, leaving 196 green pixels on every side. This is a provider accommodation, not a different target. Do not reuse the previous raw [116,116,1137,1138) silhouette and do not crop its border to obtain the smaller square.

The cropped 704-by-704 object will be divided deterministically at x and y coordinates 0, 128, 576, and 704. Therefore the four corner cells are 128 by 128, the horizontal edge cells are 448 by 128, the vertical edge cells are 128 by 448, and the center cell is 448 by 448. On the full canvas, the strict two-axis stretch center is [288,288,736,736). Keep that entire center low-frequency, quiet, and free of any unique mark. Keep every non-stretchable corner decision within the four 128-by-128 corner cells. Along each edge cell, use only broad nearly uniform material bands that can stretch along that edge without revealing a repeated motif, seam, rivet chain, directional scratch, or focal highlight. Do not draw the slice boundaries or any guide.

Build one coherent, lightly weighted expedition backing from only three low-value zones: one compact fully oxidized near-black brass contact trace no thicker than approximately 16 canonical pixels, one shallow deep-walnut support band no thicker than approximately 48 canonical pixels, and one quiet smoke-brown center field that begins immediately after that single band. The brown material must remain dominant. Every point on all four sides must use the same visual thickness. Use no gold, yellow, orange, ochre, bright brass, bronze, copper, metallic highlight, or other visible metal color anywhere in the object. Use zero rivets, zero circular fasteners, zero corner wear marks, and zero corner ornaments. Every corner must be a plain continuation of the same smoke-black and dark-brown edge bands, with no brighter or more complex shape than the middle of an edge. Do not create an inset rectangle, nested frame, double border, separate top or bottom rail bar, raised inner lip, square corner cap, corner block, corner plate, L-shaped reinforcement, diagonal corner stroke, jewelry frame, or metal bezel. All four long 448-pixel stretchable edge cells must contain only the same broad smoke-black and dark-brown bands with no line, repeated highlight, unique bright segment, seam, or directional ornament. Keep the complete visible border thickness consistent so the same slices read equally on horizontal bars, vertical bars, 6-by-2 bars, 4-by-3 bars, one-button bars, and a merged two-row bar. When assembled around merged pfUI Bar 1 and Bar 6, it must read as one uninterrupted outer support with no internal horizontal seam. At runtime this rail remains the lowest visual layer beneath separate accepted action-slot backdrops and all provider-drawn icons, text, cooldowns, and interaction states.

The entire 448-by-448 stretch center, all four stretchable edge bands, and all four corner cells must use only two or three broad matte hand-painted value masses. Make them almost flat and nearly uniform at a glance. Do not texture-fill any region. Use no all-over leather grain, pebbling, pores, dense fibers, crack networks, micro-scratches, repeating mottling, diagonal or radial lighting bands, directional marks, precision seams, stitches, embossed marks, long specular lines, glossy highlights, machined symmetry, smooth PBR gradients, or any detail that would smear or repeat when stretched. The upper-left warmth should be one broad, barely visible low-contrast value mass, not a diagonal spotlight. The lower-right pressure should be broad, dark, and restrained. The object must read as a narrow lightweight backing rail once covered by action slots, not as an ornate framed full leather panel. The master must remain visually subordinate when displayed as a runtime rail with 6 UI-unit caps behind live action-slot backdrops at icon sizes from 20 to 48 UI units and movable scales from 0.75 to 1.5.

Render it like practical classic vanilla World of Warcraft 2D sprite art painted directly for a 64-by-64 or 128-by-128 interface sprite and then enlarged cleanly for review: coarse controlled brush shapes, compact illustrated value clusters, slightly imperfect hand-cut edges, low-frequency texture, restrained contrast, and functional wear. No material mark should be finer than a shape that remains readable after reduction to 128 by 128. It must not look photorealistic, PBR-rendered, glossy, glassy, plastic, vector-clean, precision-machined, cyber-neon, gothic, demonic, monumental, stone-carved, jewel-encrusted, or like a modern MMO dashboard slab. Do not create a black translucent glass panel, stone plinth, scroll, book, paper panel, ornate crest, wing, claw, chain, rune, gem, or large endcap.

Do not bake any slot subdivision or fixed grid. Do not bake any spell or item icon, action-slot border, hotkey, count, macro name, cooldown sweep, timer, text, number, page marker, class symbol, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected color, hover glow, active glow, pressed displacement, disabled state, gryphon, consumable, trinket, unit frame, cast bar, swing timer, DoiteDPS content, or any hit-area cue. The output contains only the one normal-state adaptive Rail master.

Do not use green verdigris or any green material inside the object, and do not allow green spill into the leather, wood, brass, edge antialiasing, or wear. Outside the exact [160,160,864,864) object box every pixel must be the same exact RGB #00FF00; do not use #03FA05, #04F907, another near-green, or a noisy green field.

Before returning the image, inspect every requirement literally: the returned file itself is exactly 1024 by 1024 RGB whenever the service allows it; there is exactly one centered front-facing square object; its canonical exact visible bounding box is [160,160,864,864), or the proportional [196,196,1058,1058) only if the fixed service unavoidably returns a 1254-square container; width and height are equal within one percent, the object occupies only 68.75 percent of each canvas dimension, the uniform green moat occupies 15.625 percent on each side, no pixel lies outside the applicable box, and no edge is clipped; the previous oversized approximately [92,92,931,931) normalized silhouette has been reduced equally on both axes; the canonical crop is designed for slice boundaries 0/128/576/704; the canonical stretch center [288,288,736,736) is nearly uniform, quiet, and contains no unique or high-frequency detail; there is only one shallow outer boundary and no visible metal color, corner mark, corner ornament, inset rectangle, nested frame, separate rail bar, continuous bright line, square corner cap, corner bracket, rivet, fastener, texture fill, visible slice guide, slot grid, repeated motif, dynamic UI content, or neighboring component; every corner is the same plain brown continuation as the middle of each edge; brown leather or dark wood dominates; all sides have the same visual thickness; the style is coarse, matte, low-saturation vanilla-era hand-painted UI rather than modern PBR; and every background pixel outside the applicable object box is exactly RGB 0,255,0.
```

## 自主修复循环（已授权）

- 不可变修复边界：组件 ID、单对象、单 normal 状态、权威顺序、Image 1 职责、
  `1024² RGB`、`#00FF00`、`[160,160,864,864)`、九宫格
  `0／128／576／704`、安静中心、动态内容排除和全部反模式。
- 允许的自主修复：在最多五次实际生成总额内，按首个失败门禁调整对象在固定
  安全盒内的居中、边带厚度、中心安静度、胡桃褐／暗黄铜综合色、左上／右下
  明暗、磨损密度和纯绿色键。只有在明确保留已通过区域时才可编辑紧邻前一候选；
  否则只从同一固定 Image 1 重新生成。每次必须先形成并提交完整自包含 `.rN`
  正文。
- 必须重新授权：新增／替换输入图或上传；把模拟图、`AB.SLOT`、candidate 或
  scaffold 作为输入；增加对象／状态；改变画布、对象盒、切片坐标、provider、
  runtime 映射、Alpha 策略、视觉方向或允许的动态内容。
- 预算：首次生成计 `1/5`；已生成但不可用仍计数；无候选且无 provider 生成
  证据的流程错误不计。任一候选完整内审通过立即停止；第 `5` 个仍失败则记录
  `repair-budget-exhausted`，不得 attempt 6。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| `1/5` | `AB.RAIL.V1`／`a4bf7c8` | `generate` | session `019fe458-b245-7f83-bcd8-7d1a9ddf83f3`／result `ig_0d74c14d0ce00e90016a77e595df388191902509ccb3b66398` | raw `48811c03…f31b` | 画布／输出：返回 `1254²`，归一 bbox `[103,103,921,921)` 越出合同；背景非 exact green；视觉上四角金属板／多铆钉过重且中心纹理过密 | 保留单对象、正面、胡桃褐与暗黄铜关系；不复用错误像素，从同一 Image 1 以完整 `.r1` regenerate | `internal-fail / repair-prepared` |
| `2/5` | `AB.RAIL.V1.r1`／`974f17c` | `generate` | session `019fe460-242c-7dc0-b80f-1cbcc37362dc`／result `ig_084d9b46d47957b5016a77e77f03b881919844a1cbb7afd254` | raw `334a7dc9…bfe5` | 画布／输出仍为 `1254²`；审查归一 bbox `[100,91,923,933)` 仍越出合同且偏高、非方形；背景非 exact green；长拉伸边形成连续亮黄铜线 | 保留单对象、正面、每角最多一枚小铆钉、降低后的中心纹理与综合色域；不复用错误像素，以完整 `.r2` 从同一 Image 1 regenerate | `internal-fail / repair-prepared` |
| `3/5` | `AB.RAIL.V1.r2`／`9b0a4c7` | `generate` | session `019fe466-849b-7971-898e-a7e5ee0e51b5`／result `ig_0eb645a14530ae9f016a77e91f90cc81919661a6505de31574` | raw `4eb01991…3abb` | 输出仍为 `1254²`；审查归一 bbox `[124,98,900,926)` 为 `776×828` 纵向矩形且越出合同；背景非 exact green；仍有嵌套框、角块、铆钉和连续金线 | 保留单对象、正面、综合色域和更接近的总体尺度；不复用错误像素，以完整 `.r3` 从同一 Image 1 重新绘制无角块／无铆钉的方形低调承托片 | `internal-fail / repair-prepared` |
| `4/5` | `AB.RAIL.V1.r3`／`9408077` | `generate` | session `019fe46c-0b95-7e13-bd36-3a722bd0b477`／result `ig_029743cd41d9c020016a77ea87ffa481919fb7edd5f38ecfe7` | raw `c29ea6d4…0b4d` | 输出仍为 `1254²`；归一 bbox `[92,92,931,931)` 太大，但原始透明 bbox `1021×1022` 已为近严格正方；完整物件 canonical fit 技术 pass，视觉仍有四角 L 形黄铜片、内框和纹理填充 | 保留近严格正方、无铆钉、综合色域与更低中心高频；不复用错误像素，以完整 `.r4` 从同一 Image 1 最终 regenerate，全部黄铜压成近黑接触迹并取消角饰／内框 | `internal-fail / final-repair-prepared` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 无 | — | — | — | — | `0` |

## 执行记录

- 日期：`2026-08-09`
- 本地确定性模拟与 display-region 校验仍为 ImageGen `0/0`；生产正文、最多
  五次预算和指定 Character V3 Image 1 外部上传已获得独立授权。
- attempt 1 使用已提交正文 `a4bf7c8` 和唯一 Image 1；固定 child 完整显示授权正文，
  没有截断或额外输入。provider cache 原图为
  `C:\Users\西奥\.codex\generated_images\019fe458-b245-7f83-bcd8-7d1a9ddf83f3\ig_0d74c14d0ce00e90016a77e595df388191902509ccb3b66398.png`，
  与仓库 ignored raw SHA 完全相同；未返回独立 revised prompt。
- child 在生成后复制阶段先后遇到只读 `$HOME` 名称和受保护目录遍历错误，随后
  缩小到当前 session cache 并成功保存；已有生成图，因此仍计 attempt 1，且不列
  为“无候选／无生成证据”的非计数流程错误。
- 输出为 `1254×1254 RGB`；透明审查 bbox `[129,129,1125,1125)`，归一到
  `1024²` 后 bbox `[103,103,921,921)`，合同框外仍有 `168353` 个可见像素；
  背景透明样本中仅 `5` 个像素为 exact `#00FF00`，中位数为 `#03FA05`。
- attempt 1 候选 review JSON SHA `450bd197…e8f4`；display-region 几何
  `8/8 pass`、violations `0`，但候选技术／视觉合同失败。当前累计 `1/5`，
  流程错误 `0`。
- attempt 2 使用执行前已提交完整正文 `974f17c` 和同一唯一 Image 1；固定 child
  session 为 `019fe460-242c-7dc0-b80f-1cbcc37362dc`，provider result 为
  `ig_084d9b46d47957b5016a77e77f03b881919844a1cbb7afd254`；没有额外输入或
  独立 revised prompt。provider cache 与仓库 ignored raw 的 SHA 均为
  `334a7dc91ee224fad62e21dfa6c4ae7b96ce4733187e415b8baad32015c8bfe5`。
- attempt 2 输出仍为 `1254×1254 RGB`；透明原图 bbox
  `[125,114,1128,1140)`，审查画布归一到 `1024²` 后实际 alpha bbox
  `[100,91,923,933)`，合同框外仍有 `193277` 个可见像素；背景 exact
  `#00FF00` 像素为 `0`，中位数为 `#02F902`。透明审查 SHA 为
  `800eda2e…e188`。
- attempt 2 候选 review JSON SHA `8e146aa8…a5a1`；display-region 几何
  `8/8 pass`、violations `0`。四角重量与中心高频纹理较 attempt 1 改善，
  但画布／bbox／色键仍失败，且四条拉伸边出现连续亮黄铜线。当前累计 `2/5`，
  流程错误 `0`。
- attempt 3 使用执行前已提交完整正文 `9b0a4c7` 和同一唯一 Image 1；固定 child
  session 为 `019fe466-849b-7971-898e-a7e5ee0e51b5`，provider result 为
  `ig_0eb645a14530ae9f016a77e91f90cc81919661a6505de31574`；没有额外输入或
  独立 revised prompt。provider cache、child 原样副本与仓库 ignored raw 的
  SHA 均为 `4eb0199150b1dc36b2dfe20b85ab932923200bfb7abbb92bc027316521ef3abb`。
- child 在同一次生成后的保存阶段先因遍历受保护 `.sandbox-secrets` 失败，再因
  provider 文件名占位符 `_image_id_.png` 失败；随后只列出该 session 的
  `generated_images` 目录并原样复制成功。图片已在两次保存错误前生成，因此只计
  attempt 3 一次，也不列为“无候选／无生成证据”的非计数流程错误。
- attempt 3 输出仍为 `1254×1254 RGB`；透明原图 bbox
  `[155,123,1099,1131)`，审查画布归一到 `1024²` 后实际 alpha bbox
  `[124,98,900,926)`，即约 `776×828`，合同框外有 `143643` 个可见像素；
  背景 exact `#00FF00` 像素为 `62`，中位数为 `#03FA05`。透明审查 SHA 为
  `3e085195…3ed`。
- attempt 3 候选 review JSON SHA `deb40edc…b3cb`；display-region 几何
  `8/8 pass`、violations `0`。总体尺度继续接近合同，但物件仍为纵向矩形，
  并形成嵌套内框、四枚角块／铆钉和四边连续金线。当前累计 `3/5`，流程错误
  `0`。
- attempt 4 使用执行前已提交完整正文 `9408077` 和同一唯一 Image 1；固定 child
  session 为 `019fe46c-0b95-7e13-bd36-3a722bd0b477`，provider result 为
  `ig_029743cd41d9c020016a77ea87ffa481919fb7edd5f38ecfe7`；没有额外输入、
  保存错误或独立 revised prompt。provider cache、child 原样副本与仓库 ignored
  raw 的 SHA 均为
  `c29ea6d452d8ab858cd01da760a302022d114eec090358591c13d1130b6c0b4d`。
- attempt 4 输出仍为 `1254×1254 RGB`；透明原图 bbox
  `[116,116,1137,1138)`，审查画布归一 bbox `[92,92,931,931)`，合同框外有
  `202711` 个可见像素；背景 exact `#00FF00` 像素为 `50`，中位数为
  `#03FA04`。透明审查 SHA 为 `85277737…48ec`。
- attempt 4 原始透明物件为 `1021×1022`，纵横误差仅 `0.00097847`。审查工具
  opt-in canonical 只裁出完整 alpha bbox 并 LANCZOS fit 到冻结 `704²`，不裁边、
  不重绘、不创建 source／runtime；canonical bbox exact、框外像素 `0`、纯绿背景
  pass，技术审查 `4/4 pass`。canonical review JSON SHA `fc49e49b…56f4`；
  display-region `8/8 pass`、violations `0`。
- canonical 真实排版仍显示四角 L 形黄铜饰片，并保留内框／纹理填充；这是真实
  美术合同失败，不能由技术归一恢复资格。当前累计 `4/5`、流程错误 `0`；完整
  `AB.RAIL.V1.r4` 等待提交后执行最后一次 regenerate。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `AB-RAIL-SIM-V1` | scene `123d1b4c…cde6`；layouts `a49088d1…e353`；display `8/8` | `user-confirmed / P2` | 不改变已确认方向；生产授权已于 `2026-08-09` 齐全 |
| `AB.RAIL.V1` | `a4bf7c8`；session `019fe458…83f3`；raw `48811c03…f31b`；review `450bd197…e8f4` | `internal-fail / 1/5` | 以同一 Image 1 执行已提交的完整 `AB.RAIL.V1.r1`；不得复用 attempt 1 像素 |
| `AB.RAIL.V1.r1` | `974f17c`；session `019fe460…62dc`；raw `334a7dc9…bfe5`；review `8e146aa8…a5a1` | `internal-fail / 2/5` | 保留单角钉与低频中心；整体缩小约 `16%`、正方居中，亮黄铜只留在四角短断点 |
| `AB.RAIL.V1.r2` | `9b0a4c7`；session `019fe466…51b5`；raw `4eb01991…3abb`；review `deb40edc…b3cb` | `internal-fail / 3/5` | 保留更接近的总体尺度；分别修正宽高、取消嵌套框／角块／铆钉与连续金线 |
| `AB.RAIL.V1.r3` | `9408077`；session `019fe46c…b477`；raw `c29ea6d4…0b4d`；canonical review `fc49e49b…56f4` | `internal-fail / 4/5` | 保留近严格正方；取消全部可见金属色、角饰、内框与纹理填充，严格扩大绿色安全带 |
| `AB.RAIL.V1.r4` | 最终修复：近黑氧化黄铜只作接触迹、胡桃褐单层边带、plain corners、绿色面积比例自检 | `final-repair-prepared` | 提交后 regenerate attempt 5；不得 attempt 6 |

## 审查记录

- 结论：attempt 4 退回；`final-repair-prepared / P3`，不允许进入用户复审、source
  或 runtime。
- 第一个失败门禁：执行输出与画布合同。raw 为 `1254² RGB` 而非 `1024²`；审查
  画布归一 bbox `[92,92,931,931)` 越出 `[160,160,864,864)`；约 `839²`，仍比
  合同大约 `19%`；背景也不是逐像素 exact `#00FF00`。
- 语义／物理：单对象、正面、normal 状态与胡桃褐／暗黄铜身份可保留；没有
  动态图标、文字、状态或固定槽格。
- 透视／图层：正面无透视；按冻结 crop 九宫格装配后，Rail 能位于 accepted
  Slot 与 provider 动态内容之下，display-region `8/8 pass`。
- 技术归一：完整透明物件 `1021×1022`，纵横误差 `0.098%`；review-only canonical
  fit 后 bbox exact、框外 `0`、纯绿背景 pass，且没有裁边或重绘。这只说明
  attempt 4 具备无损比例归一基础，不自动覆盖美术失败。
- 美术一致性：综合色域接近 Character V3，中心 high-frequency mean 从原始冻结
  crop 的 `1.4434` 降至 canonical 的 `1.3840`，无铆钉且综合色域克制；但四角形成
  明显 L 形黄铜饰片，内框和全幅细纹仍让它读成完整面板而不是轻量承托轨。
- 装配／尺寸：`1×1／12×1／6×2／4×3／1×12`、极端参数与合并双栏均可完成
  几何装配且无内部中缝；由于冻结 crop 会切掉候选真实外框，该 pass 不能恢复
  候选资格。
- 下一版必须改变：保持正方，canonical 物件 exact bbox
  `[160,160,864,864)`；fixed provider 若仍返回 `1254²`，只把
  `[196,196,1058,1058)` 作为同比例辅助定位；绿色区域须超过画布一半。暗氧化
  黄铜只能以无金属色的近黑接触迹存在；取消全部可见金属色、角饰、角痕、内框、
  独立上下 rail 和纹理填充，四条 stretch edge 与四角都只能使用相同烟黑／暗褐
  宽色带。必须保持单对象、正面、胡桃褐主导、同厚横竖适配和全部动态内容排除。
- 当前结论：attempt 4 为 `internal-fail / 4/5`；完整 `AB.RAIL.V1.r4` 已形成，
  提交前不得执行 attempt 5，且任何结果后均不得 attempt 6。内部通过仍不等于
  用户接受。
