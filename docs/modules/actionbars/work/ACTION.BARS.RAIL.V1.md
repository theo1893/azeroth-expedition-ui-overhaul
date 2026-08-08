# AB.RAIL.V1

## 元数据

- 模块：`actionbars`
- 组件 ID：`AB.RAIL.V1`
- 工作版本：`AB-RAIL-SIM-V1`
- 子状态：`simulation-confirmed`
- 项目阶段：`P2`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`；本阶段未加载、未调用，正式生产也不得改用其他执行器
- 当前操作：`prepare`；记录模拟确认并冻结最终生产正文，尚未执行
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
- 后续生产自动修复预算：最多 `5` 次实际 ImageGen 生图／修图，含首次；尚未授权
- 当前实际生图：`0/5`
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
- raw：无
- 透明候选：无
- 重组预演：无
- 真实排版预演：当前仅为生成前本地模拟，不是候选真实排版；战斗场景使用
  `1920×1080`、UI Scale `0.81269841269841`，组合板按目标设备物理像素显示
  `8` 个实例；相邻槽位使用当前 accepted runtime，姿态栏仍使用 pfUI fallback
- 实际展示区域合同／报告：
  - 合同：`tools/specs/action_rail_v1_sim_display_region.json`，SHA-256
    `6023ef0e6141f46cf6006b2b9f81705a034dea921be4fa73e3eba6ded503992e`
  - 报告：
    `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/display-region-report.json`
    ／`aebb3938953cadaaa7d5b32245ea90305cd94d19b6b63d5d1d8e31a01c80685e`
  - `1×1／12×1／6×2／4×3／1×12`、低 border／scale、
    高 border／spacing／scale 与合并双栏共 `8/8 pass`，violations `0`
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
- 下一门禁：用户另行授权已冻结的 `AB.RAIL.V1` 最终生产正文与最多五次实际
  生成／修复预算，并明确授权把指定 Character V3 锁定图作为 Image 1 上传至
  外部 ImageGen 服务；两项授权齐全前不得执行。

## 生产正文完整性预检

- 复杂度：`single-object / nine-slice / stretch`
- 结论：`pass as final AB.RAIL.V1 production body`；`AB-RAIL-SIM-V1` 已获用户
  确认，全部确认条款已冻结进正文；不得执行，原因是尚无本组件生产／预算授权，
  也没有指定 Image 1 的外部上传授权。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、范围、数量、状态与动态内容排除 | 一张正常态方形九宫格 Rail；明确不是完整动作条、槽位或状态 atlas | pass |
| 每张输入图的 inherit／ignore 职责与冲突 | Image 1 只继承材料 DNA；忽略窗口内容与几何；组件合同冲突时合同优先 | pass |
| 画布、边距、方向、透视、尺寸、光照与层序 | `1024² RGB`、`[160,160,864,864)`、正面无透视、左上暖／右下暗、Rail 最底层 | pass |
| 逐对象形态、材料、边缘、状态与相互关系 | 单对象、单正常态、皮革／木芯、断续暗黄铜、四角紧固点、安静中心 | pass |
| 安全区、裁切、拉伸、平铺、重复与接缝 | source cap `128`、center `448²`、九宫格边界与不可放置纹章范围已冻结 | pass |
| 美术 DNA、反模式、色键与最终自检 | 香草手绘、低频、低饱和、精确 `#00FF00` 与逐项自检完整 | pass |

- 未知但执行必需的值：无；未来 runtime atlas 格式由 accepted source 后的确定性
  exporter 冻结，不影响本次生成对象合同。
- 去冗余结论：只保留会改变对象、画布、拉伸安全区、材料关系与反模式的条款；
  不把模拟像素描述成可复制目标。

## 最终执行正文（`AB.RAIL.V1`，冻结待授权）

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.RAIL.V1: exactly one reusable normal-state square nine-slice master for the background rail beneath a pfUI action bar. It is a lightweight expedition equipment support that stretches around an arbitrary legal action-bar frame. It is not a complete action bar, not a fixed twelve-slot plate, not an action-button base, not an icon, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 will be the locked Character V3 visual authority. Inherit only its classic vanilla-era World of Warcraft hand-painted material relationship and value logic: deep walnut and smoke-brown aged leather or dark wood as the dominant body, a small amount of muted dark oxidized brass, low saturation, broad illustrated value groups, short warm wear light from the upper left, darker pressure toward the lower right, restrained handmade wear, and a deliberately old low-resolution game-interface character. Do not copy Image 1 pixels. Do not inherit its complete character-window silhouette, thick panel frame, paper, character, equipment slots, item or spell icons, purple quality glow, tabs, buttons, text, numbers, ornaments, internal layout, proportions, perspective, or 1254-by-1254 canvas. If Image 1 conflicts with this component contract, preserve only its material DNA and obey this prompt's exact geometry, quiet stretch zones, single-object scope, and exclusions.

Create a brand-new exact 1024 by 1024 RGB canvas. Use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background on every pixel outside the object, including all four canvas edges. Do not return transparency, a checkerboard, near-green, gradient, noise, haze, floor, shadow, vignette, or environmental scene. Place exactly one front-facing square rail master centered on the canvas, without perspective, camera depth, tilt, cast shadow, detached pieces, labels, guides, cell lines, or a presentation frame. Keep every visible object pixel, antialiasing pixel, wear mark, highlight, and compact contact edge inside the right-and-bottom-exclusive object box [160,160,864,864). Aim for one complete 704-by-704 square object whose crop is exactly that box.

The cropped 704-by-704 object will be divided deterministically at x and y coordinates 0, 128, 576, and 704. Therefore the four corner cells are 128 by 128, the horizontal edge cells are 448 by 128, the vertical edge cells are 128 by 448, and the center cell is 448 by 448. On the full canvas, the strict two-axis stretch center is [288,288,736,736). Keep that entire center low-frequency, quiet, and free of any unique mark. Keep every non-stretchable corner decision within the four 128-by-128 corner cells. Along each edge cell, use only broad nearly uniform material bands that can stretch along that edge without revealing a repeated motif, seam, rivet chain, directional scratch, or focal highlight. Do not draw the slice boundaries or any guide.

Build one coherent, lightly weighted expedition rail from outside to inside: a compact smoke-black contact edge; a shallow deep-walnut leather or dark-wood support body; one narrow, broken, muted dark-oxidized-brass line near the true outer perimeter; and a quiet smoke-brown center field. The brown material must remain dominant. Brass is only a functional trace and a few short ochre value breaks, never a bright continuous bezel, double bevel, full metal plate, jewelry frame, or gold ornament. Put at most one tiny dark fastener near each true outer corner, contained within the outermost approximately 48 source pixels of the object; omit a fastener rather than enlarging it. Do not place fasteners anywhere along the stretchable edges or center. Keep the complete visible border thickness consistent on all four sides so the same slices read equally on horizontal bars, vertical bars, 6-by-2 bars, 4-by-3 bars, one-button bars, and a merged two-row bar. When assembled around merged pfUI Bar 1 and Bar 6, it must read as one uninterrupted outer rail with no internal horizontal seam. At runtime this rail remains the lowest visual layer beneath separate accepted action-slot backdrops and all provider-drawn icons, text, cooldowns, and interaction states.

The center and stretchable edge bands must use only a few broad matte hand-painted value masses. Avoid realistic grain, pores, dense fibers, crack networks, micro-scratches, precision seams, stitches, embossed marks, long specular lines, glossy highlights, machined symmetry, smooth PBR gradients, or any detail that would smear when stretched. The upper-left warmth should be short and broken. The lower-right pressure should be dark and restrained. The master must remain visually subordinate when displayed as a runtime rail with 6 UI-unit caps behind live action-slot backdrops at icon sizes from 20 to 48 UI units and movable scales from 0.75 to 1.5.

Render it like practical classic vanilla World of Warcraft 2D sprite art painted for a small interface: coarse controlled brush shapes, compact illustrated value clusters, slightly imperfect hand-cut edges, low-frequency texture, restrained contrast, and functional wear. It must not look photorealistic, PBR-rendered, glossy, glassy, plastic, vector-clean, precision-machined, cyber-neon, gothic, demonic, monumental, stone-carved, jewel-encrusted, or like a modern MMO dashboard slab. Do not create a black translucent glass panel, stone plinth, scroll, book, paper panel, ornate crest, wing, claw, chain, rune, gem, or large endcap.

Do not bake any slot subdivision or fixed grid. Do not bake any spell or item icon, action-slot border, hotkey, count, macro name, cooldown sweep, timer, text, number, page marker, class symbol, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected color, hover glow, active glow, pressed displacement, disabled state, gryphon, consumable, trinket, unit frame, cast bar, swing timer, DoiteDPS content, or any hit-area cue. The output contains only the one normal-state adaptive Rail master.

Do not use green verdigris or any green material inside the object, and do not allow green spill into the leather, wood, brass, edge antialiasing, or wear. Outside the object every pixel must be the same exact #00FF00.

Before returning the image, inspect every requirement literally: the file is exactly 1024 by 1024 RGB; there is exactly one centered front-facing square object; every visible object pixel is inside [160,160,864,864); the crop is designed for slice boundaries 0/128/576/704; the canvas stretch center [288,288,736,736) is quiet and contains no unique detail; non-stretchable details remain in the corner cells; there are no visible slice guides, slot grid, repeated motifs, dynamic UI contents, or neighboring components; brown leather or dark wood dominates; dark brass is narrow and broken; at most four tiny corner fasteners exist; all sides have the same visual thickness; the style is coarse, matte, low-saturation vanilla-era hand-painted UI rather than modern PBR; and every background pixel outside the object is exact #00FF00.
```

## 自主修复循环（尚未授权）

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
| `0/5` | `AB.RAIL.V1` 冻结待授权 | — | — | — | — | 等待独立生产／预算授权与指定 Image 1 外部上传授权 | `simulation-confirmed` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 无 | — | — | — | — | `0` |

## 执行记录

- 日期：`2026-08-08`
- 本阶段仅执行本地确定性模拟与 display-region 校验；ImageGen `0/0`，没有
  外部上传、候选、source、runtime 或 adapter 改动。
- 正式 `AB.RAIL.V1` 仍为 `0/5`，等待独立生产／预算与 Image 1 上传授权。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `AB-RAIL-SIM-V1` | scene `123d1b4c…cde6`；layouts `a49088d1…e353`；display `8/8` | `user-confirmed / P2` | 不改变已确认方向；生产仍待独立授权 |
| `AB.RAIL.V1` | ImageGen `0/5` | `not-executed` | 授权前不得生成 |

## 审查记录

- 语义／物理：pass for simulation；读作连续轻量承托轨，不冒充固定槽板。
- 透视／图层：pass；正面、无透视，Rail 始终在槽位与动态层之下。
- 美术一致性：方向已由用户确认；胡桃褐主导、暗黄铜克制，但本地 primitives
  仍不代表最终笔触、材料微纹理或 Alpha。
- 组件合同：`8/8 pass`、violations `0`；合并双栏无内部 Rail 中缝。
- 动态内容：全部由 provider／accepted runtime 模拟层承担，Rail 本身为零。
- 用户结论：`2026-08-08` 接受 `AB-RAIL-SIM-V1`；只确认文字化可见方向。
- 当前结论：`simulation-confirmed / P2`；`AB.RAIL.V1` 最终正文已冻结。生产／
  预算授权与 Image 1 外部上传授权齐全前，不得生成、导出、接入 addon 或晋级 P3。
