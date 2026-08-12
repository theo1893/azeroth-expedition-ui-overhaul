# Unit Frames Raid 团队框架工作记录

## UF-RAID-A2 当前工作快照

- 版本：`UF-RAID-A2 / UF-RAID-A2-SIM-V1`
- 子状态：`P3 / repair-prepared / attempt-04-ready`
- 用户选择的架构：`ImageGen material donor only + Python deterministic shell`
- 当前操作：`edit-attempt-04`
- 当前批 ImageGen：`3/5`；剩余 `2`
- production donor：`attempt 1–3 internal-fail；r3 已准备`
- 模拟用户结论：`confirmed / 2026-08-12 / accepts-pixels=false`
- candidate／source／runtime／addon：`均未写入`
- 最新 raw：`generated/unitframes/raid/A2/DONOR-V1/attempt-03/uf-raid-a2-donor-v1-attempt-03.provider-native-01.png`，SHA `6f54172b…4b28`
- provider：40 个 `pfRaid` Secure Button，`10×4 VERTICAL`，单 Button
  `70×33`，单成员显示包络 `74×39`，整团 `767×159`；结构沿用已经确认的
  `UF-RAID-SIM-V1`。
- 模拟规格：`tools/specs/unitframes_raid_donor_simulation_v1.json`
- production 草案：`tools/specs/unitframes_raid_donor_production_v1.json`
- 确定性构造器：`tools/build_unitframes_raid_donor_shells_v1.py`
- 真实排版渲染器：`tools/render_unitframes_raid_donor_simulation_v1.py`

### 架构职责冻结

ImageGen 未来只允许生成一张 `1536×1024 RGB` 粗粝材质 donor。它只提供四块
无物件轮廓的连续材料像素：深胡桃旧生皮、烟褐静内衬、暗哑氧化黄铜、烟黑
粗麻线材质。donor 不是 UI atlas，不得包含任何框、卡片、端帽、开口、补丁、
针脚、铆钉、标签或动态内容，也永远不被 addon 直接加载。

Python 独占并精确构造以下内容：

- 四张完整 `592×296 RGBA` source 的外轮廓、Alpha、内衬与接触阴影；
- 固定 provider inset `[16,16,576,280]`，对应 runtime `70×33` Button；
- 固定名称安静区 `[40,48,552,232]`；
- 固定横向三切片 `48/496/48`，对应 runtime `6/62/6`；
- 完整 source 下采样为 `74×37` runtime，并清零全透明像素 RGB；
- A/B/C/D 四种维修差异和所有维修坐标；
- 40 人真实排版、动态层序、缩放与展示区域验证。

四种维修身份冻结为：

| 变体 | 确定性差异 | 固定区 |
|---|---|---|
| A | 左上浅切口；右下两条长度和角度不等的粗线修补 | 左／右 `48px` source cap |
| B | 右侧一枚偏心暗铆钉；右下克制磨亮 | 右 `48px` source cap |
| C | 左侧短旧生皮补丁；两处不规则线修补；无金属 | 左 `48px` source cap |
| D | 右侧小型歪斜暗铜片；左下微裂 | 左／右 `48px` source cap |

名称、Health／Power、数值、颜色、治疗预测、光环、驱散、距离／离线 Alpha、
Hover／Aggro、Raid Icon、Leader、Master Looter 与 Resurrection 仍全部属于
运行时。Python 不改变 Frame、Secure hitbox、Point、Width、Height、事件、
Roster、SavedVariables 或 pfUI 状态逻辑。

### donor 固定格位

未来 production donor 只有一个 ImageGen 对象：

| 材料 | cell | 必须连续无边界的 sample window | Python 用途 |
|---|---|---|---|
| leather | `[64,64,736,448]` | `[144,112,656,400]` | 薄外夹边及 C 补片 |
| liner | `[800,64,1472,448]` | `[880,112,1392,400]` | 动态条下方的安静烟褐底层 |
| brass | `[64,576,736,960]` | `[144,624,656,912]` | B 铆钉与 D 暗铜修补 |
| thread | `[800,576,1472,960]` | `[880,624,1392,912]` | A／C 固定线修补 mask |

格位之间和画布外侧只用纯 `#00FF00`；四个 sample window 内不得出现绿色、
标签、边界、物件阴影或已经形成的绳／线／缝。模型不能推断或生成 UI 几何。

### A2 生成前模拟

- 模拟材质：由 Pillow 使用固定 seed 构造的低频占位色块；不是锁定像素、
  ImageGen 像素、source 或未来 edit/reference。
- source preview：
  `generated/unitframes/raid/simulation/A2-V1/unitframes-raid-a2-donor-sources.png`，
  SHA `ce084d35…0205`。
- 游戏场景：
  `generated/unitframes/raid/simulation/A2-V1/unitframes-raid-a2-donor-sim-v1.scene.png`，
  SHA `5697dcbb…5932`。
- 评审板：
  `generated/unitframes/raid/simulation/A2-V1/unitframes-raid-a2-donor-sim-v1.review.png`，
  SHA `ff2467d3…0f95`。
- 展示区域：沿用并补充
  `tools/specs/unitframes_raid_simulation_display_region_v1.json`；报告
  `ddb3fc51…e6dd0`，`7/7 pass`、violations `0`。
- 首次合同测试发现 D 的左下微裂有 `55` 个 source Alpha 像素进入 provider
  inset；已将裂口收回底部 `16px` 外壳轨。修正后 A-D 四个
  `[16,16,576,280]` inset 均为全 `255` Alpha，维修仍完全位于固定端部。
- 透明清理只在 `Alpha=0` 时把 RGB 清零；`Alpha=1..254` 的抗锯齿 RGB 保持
  非预乘，避免边缘被二次压暗。
- ImageGen：`0/0`；本阶段没有生图调用、candidate、source、runtime 或 addon
  变更。

当前模拟中只有下列内容可被确认：精确外壳轮廓、`2px` runtime 夹边、四种
维修的种类／位置／力度、三切片安全区、40 人密度和动态层序。模拟材质的
笔触、微纹理、最终色差、最终抗锯齿与 TGA 方向均不在本次接受范围。

### A2 用户方向结论

- 具体模拟版本：`UF-RAID-A2-SIM-V1`
- 用户原文：`确认UF-RAID-A2-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-12`
- 模拟像素接受：`false`
- production／ImageGen 授权：`true / UF-RAID-A2-DONOR V1 / 2026-08-12`
- 已冻结并写入 `UF-RAID-A2-DONOR V1` 的可见方向：
  - 保留真实 `40` 个 `pfRaid` Button、`10×4 VERTICAL` 和 `767×159` 编队；
  - 不增加共享 Raid 外框、书框、金属底板或装饰背景；
  - 每个成员使用精确 `74×37` 外壳承托原 `70×33` Secure Button，100% 尺寸
    只露出约 `2px` 手裁深胡桃夹边；
  - A-D 继续使用本规格冻结的浅缺口、偏心铆钉、短皮补丁、歪斜暗铜片、乱线
    修补和微裂位置；所有独特维修留在固定端部，中央保持安静；
  - 材料层级为深胡桃旧生皮／烟褐静内衬／极少暗哑氧化黄铜／烟黑粗麻；低
    饱和重量由 40 人整体形成，不把单框加厚成卡片；
  - 名称、Health／Power、Aura、Raid glyph、Range／Offline、Aggro／Hover、
    Resurrection 等维持模拟中审阅过的动态层序。
- 仍不权威：全部本地占位像素、donor 最终笔触与微纹理、精确综合色差、最终
  抗锯齿、TGA 方向和目标客户端渲染。
- 确认失效条件：改变编队／共享外框结论、成员物件隐喻、外夹边重量、A-D
  身份、材料层级／配色角色、动态层序，或把维修移出固定端部／烘焙动态内容。
- 跨设备 handoff：无。下一门禁只依赖 tracked 合同与正文；模拟可由已提交
  脚本确定性重建，不需要运输 ignored 像素。

### 下一门禁

`UF-RAID-A2-SIM-V1` 已确认，`UF-RAID-A2-DONOR V1` 已获得独立精确授权。
attempt 1–3 已完成；attempt 3 已通过主要美术门禁，但固定格位仍失败且
leather／thread 略偏亮。下一门禁是先提交 attempt 3 完整证据与
`UF-RAID-A2-DONOR V1.r3` 自包含修复正文，再以固定 Image 1／2 和同循环紧邻
attempt 3 donor 作为 Image 3 调用固定 `imagegen-0-143-0` attempt 4；不得在
提交前调用。

未来 donor 循环最多 `5` 次实际 ImageGen 调用，流程错误不计额度，通过即停。
attempt 1 只上传两张固定 Chat 锁定图且没有 Image 3；后续只允许同一 donor
循环紧邻前稿在冻结的四材料字段范围内作为 edit 输入。正式 Prompt 的唯一
初始机器正文保存在 `tools/specs/unitframes_raid_donor_production_v1.json`；
当前唯一执行正文按版本保存在本 work 的 fenced body，并由固定执行器逐字提取。
完整性复检为 `pass-final`、未知执行关键值为 `0`。当前
`production_authorized=true`；允许执行有界生成循环，但不允许自动接受、
晋级 source、导出 runtime 或接入 addon。

### `UF-RAID-A2-DONOR V1` 正文完整性复检

- 复杂度：`one material sheet / four fixed fields / deterministic downstream assembly`
- 结论：`pass-final / 2026-08-12`
- 未知但执行必需的值：`0`
- 固定输入：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
    只继承 2004 年宽块手绘尺度、左上暖光、材料厚度和低频手工磨损；忽略
    书本、书页、书脊、龙纹和完整框体。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
    只继承深胡桃层次、烟褐克制、粗粝颜料和暗哑氧化黄铜；忽略书本构造和
    所有 UI 轮廓。

| 门禁 | 正文证据 | 结论 |
|---|---|---|
| 物件身份、范围、数量和动态排除 | 首段明确只有一张 donor、四块材料、无 UI／动态内容 | pass |
| 输入 inherit／ignore 与权威冲突 | 倒数第二段逐图限制视觉职责，文字合同高于参考图 | pass |
| Canvas、格位、sample window、光照 | 前三段给出 `1536×1024`、四 cell／window 和左上暖光 | pass |
| 四材料形态、尺度与相互关系 | 中段逐项冻结 leather／liner／brass／thread 的可裁取材质 | pass |
| crop／repeat／safe area／后处理 | 固定 window 全填充，禁止边界；Python 独占几何和维修 | pass |
| 年代、美术 DNA、反模式、输出自检 | 正文冻结 2004 手绘、低饱和、粗粝尺度与完整禁止项 | pass |

### `UF-RAID-A2-DONOR V1` 最终执行正文

```text
Create from scratch exactly one 1536x1024 RGB material-donor sheet for a
2004-era vanilla World of Warcraft expedition raid UI. This is not a UI
mockup and must contain no frame, shell, card, plaque, button, atlas part,
status bar or interface geometry.

Use pure flat #00FF00 only in the outer gutters and the gap separating four
large rectangular material fields. Place exactly four unlabelled,
uninterrupted, full-field material paintings at these fixed cells: top-left
x64..736 y64..448 is deep soot-walnut salvaged rawhide; top-right x800..1472
y64..448 is quiet matte smoke-brown backing; bottom-left x64..736 y576..960
is dark tarnished umber brass; bottom-right x800..1472 y576..960 is coarse
smoke-dark flax thread material.

Every fixed inner sample window must be entirely filled by its material with
no green, border, edge, shadow, label, divider, object silhouette or embedded
ornament: leather x144..656 y112..400; liner x880..1392 y112..400; brass
x144..656 y624..912; thread x880..1392 y624..912.

Inherit only the references' broad hand-painted bitmap scale, warm upper-left
lighting, low-saturation expedition palette, material thickness and
low-frequency irregular wear. The leather should resemble reused saddle strap
or shield-backing rawhide: uneven smoke stain, blunt scraped grain, broad
pigment variation and sparse worn patches, never furniture upholstery. The
liner is visually quiet and darker, with broad matte soot variation and no
focal mark. The brass is oxidized dark umber, scratched and dull with only
short discontinuous warm catches, never bright gold. The thread field shows
coarse flax fibre and uneven smoke-dark dye at a broad usable scale, but no
already-formed thread, stitch, cord, braid, rope or seam. Keep each field
seamless enough for arbitrary deterministic cropping; avoid tiny photographic
noise, repeated tile motifs and high-frequency pores.

The written requirements outrank both input images. Use Image 1 only for its
circa-2004 broad hand-painted bitmap scale, warm upper-left light, apparent
material thickness and low-frequency handmade wear; ignore its book, page,
spine, dragon, complete-frame geometry and every object layout. Use Image 2
only for deep-walnut tonal depth, restrained smoke-brown pigment, rough
handmade paint and dull oxidized brass response; ignore its book construction,
every UI contour and every object layout. Do not copy pixels or shapes from
either input. Do not use any simulation image or rejected A1 candidate as a
reference or edit input.

Do not draw stitches, rivets, patches, notches, cuts, repairs, piping,
embossing, tooling, lacing, labels, grids or measurements: Python constructs
all exact geometry and A/B/C/D repair masks later. No pages, books, wax seals,
dragons, skulls, spikes, gems, runes, Diablo-style black iron, modern flat UI,
glass, neon, regular industrial bevels, mirrored decoration, product swatch
cards or photoreal antique photography. No text of any kind.

Before returning, verify visibly: exactly one 1536 by 1024 RGB donor sheet;
exactly four uninterrupted unlabelled material fields in the fixed cells;
every fixed sample window is completely material-filled; pure #00FF00 appears
only in the outer gutters and central gaps; no frame, shell, UI geometry,
formed repair object, text, label or measurement is present.
```

### `UF-RAID-A2-DONOR V1` 不可变修复边界与授权范围

- 一段、一次只输出一张 `1536×1024 RGB` donor；四材料字段、cell、sample
  window、参考图路径／SHA／职责和禁止 UI 几何全部不可变。
- attempt 1 固定上传 Image 1／2，`Image 3 = none`。
- 后续 attempt 只允许把同一 donor 循环紧邻前稿作为 Image 3，并且只修复四个
  冻结材料字段内的材质内容／格位污染；禁止跨循环、跨段或复用 A1 失败像素。
- 每段最多 `5` 次实际 ImageGen；当前 `3/5`，剩余 `2`。返回图片或 provider generation
  证据才计数；无图且无生成证据的流程错误单列，不占额度；内部通过即停。
- Python 可执行固定 sample-window crop、cover-fit、精确 Alpha／liner／光照／
  A-D mask、透明 RGB 清零、`592×296 → 74×37`、`6/62/6` 三切片和 40 人真实
  排版；不得生成新笔触、修补 donor 美术或推断模型外壳几何。
- 本授权若未来取得，也不代表候选接受、P4 source 晋级、P5 addon 导出、P6
  实机验收或中间数据清理。
- 当前授权状态：`granted / 2026-08-12 / bounded-repair-loop-active`。

### `UF-RAID-A2-DONOR V1` 用户授权记录

- 用户原文：`确认授权 UF-RAID-A2-DONOR V1；允许每次上传合同中固定 SHA 的 Image 1/2，attempt 1 无 Image 3；仅允许同循环紧邻前次 donor 输出在冻结四材料字段修复边界内作为后续 Image 3 edit 输入；最多 5 次实际 ImageGen 调用，流程错误不占额度；允许按合同执行固定 sample-window crop、Python 精确外壳/A-D 维修 mask、透明 RGB 清零、592×296 source、74×37 runtime、6/62/6 三切片及 40 人真实排版预演。`
- 日期：`2026-08-12`
- 授权版本：`UF-RAID-A2-DONOR V1`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- attempt 1：每次上传合同固定 SHA 的 Image 1／2，`Image 3 = none`。
- attempt 2–5：每次仍上传固定 Image 1／2；只允许同循环紧邻前次 donor 输出
  在冻结四材料字段内作为 Image 3 edit 输入。若不明确保留前稿则从固定两图
  regenerate；禁止跨循环、跨段、模拟图或 A1 失败像素。
- 预算：最多 `5` 次实际 ImageGen；当前 `3/5`，剩余 `2`；流程错误 `1` 不占额度；内部通过
  即停。
- 允许的确定性操作：固定 sample-window crop、cover-fit、Python 精确外壳／
  A-D mask、透明 RGB 清零、`592×296 → 74×37`、`6/62/6` 三切片和 40 人真实
  排版预演。
- 未授权：候选自动接受、P4 source 晋级、P5 addon 导出／接入、P6、清理。
- 下一操作：提交 attempt 3 的 session／result、raw SHA、完整审查与 r3 正文后，
  执行 attempt 4；使用固定 Image 1／2 与同循环紧邻 attempt 3 raw 作 Image 3。

### A2 自主修复循环

- 不可变修复边界仍为上文已授权合同：一张 `1536×1024 RGB` donor、固定四材料
  角色与 cell／sample window、固定 Image 1／2 的路径／SHA／职责、禁止 UI
  几何／文字／维修对象、Python 独占外壳和 A-D mask、`592×296 → 74×37`、
  `6/62/6`、40 人真实排版及全部动态排除。
- 允许修复：四个冻结材料字段内的材质笔触、频率、明暗、污染与 cell 占用；
  可在明确保留前稿正确结构时使用同循环紧邻 raw 作 Image 3 edit。
- 当前：`repair-prepared`；实际 ImageGen `3/5`，剩余 `2`；流程错误 `1`。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-RAID-A2-DONOR V1` / `68e43e5` | generate | session `019ff524-4c79-7f92-8246-d5e46140250d`／provider `ig_02657bd92b3d4522016a7c32547f2481919c19c602f0fdb5c2` | raw `ac2f7a2a…ec23` | 美术一致性：leather／brass／thread 为照片级高频表面，运行时形成连续锯齿滚边；其次四 field bbox 越出固定 cell | 保留四材料顺序、低饱和深色层级、完整 sample window、安静 liner 与无 UI 几何；attempt 2 用紧邻 raw 作 Image 3，重画材质频率并收回 cell | internal-fail |
| 2/5 | `UF-RAID-A2-DONOR V1.r1` / `6cb51d3` | edit | session `019ff531-86c6-7333-9ea1-31a8d5ec461f`／provider `ig_0a7b3d9d79050dcb016a7c35bc352c819183b83d8fa24aeaff` | raw `d6479b89…c893` | 美术一致性：四材料仍共享重复卷曲压纹，thread 仍为纠缠纤维、brass 仍有大片亮区；其次最大 field bbox 偏移 `55px` | 不继承失败纹理；保留冻结职责／深色层级／sample window／无 UI 几何。attempt 3 只用固定 Image 1／2 从零生成超低频哑光颜料字段 | internal-fail |
| 3/5 | `UF-RAID-A2-DONOR V1.r2` / `542810f` | regenerate | session `019ff53a-39b4-79c0-94bd-b308a4a29962`／provider `ig_09b4123c1cee1bb7016a7c37ecb4ac81919dcddc53fa6d9b0e` | raw `6f54172b…4b28` | 技术：四 field bbox 仍偏离固定 cell，最大 `42px`，leather／liner contract cell 内分别残留 `3840/4224` dominant-green px；其次 leather／thread 略偏亮 | 完整保留本稿已成立的宽块哑光笔触、无共享纹理、安静 liner、粗犷运行时；attempt 4 仅用紧邻 raw 作 Image 3 精确收边，并克制压暗 leather／brass／thread | internal-fail |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 1 | `UF-RAID-A2-DONOR V1.r1` / `6cb51d3` | session `019ff531-86c6-7333-9ea1-31a8d5ec461f` | provider 已只生成一图后，child 的重复 Pillow 元数据检查因环境缺少 PIL 失败；随后用 `file`／`sips` 成功确认并逐字节落盘，没有第二次生成 | 固定执行器主进程返回 `0`；正式技术审查使用 macOS `py312`，不依赖 child 系统 Python | 流程错误，不增加生图次数 |

#### Attempt 1 执行与内部审查

- 固定子进程 user block 已完整回显；Prompt body SHA
  `5726f689…23c`，Image 1／2 路径、顺序和 SHA 与授权一致，Image 3 不存在。
  固定执行器 `@openai/codex@0.143.0` 返回 `1536×1024 RGB` 一张；provider
  native 与 child byte-for-byte copy SHA 同为 `ac2f7a2a…ec23`。启动日志中的
  model-cache `base_instructions` 与 plugin icon warning 没有阻止生成、复制或
  输出，因此不是流程错误。
- 范围／语义：通过。只有四块无字材料，没有 UI 框、按钮、状态条、维修对象、
  书页、蜡封或动态内容；四个 fixed sample window 的 dominant-green 像素均为
  `0`，材料没有互相污染。
- 物理／层序：通过。donor 只提供连续材料；外壳轮廓、Alpha、liner、A-D 修补
  和状态层全部由 Python 构造，未让模型拥有 UI 几何。
- 第一失败——美术一致性：leather 是均匀细碎的照片级皮面，brass 有大面积
  亮斑与纵横长划痕，thread 像高频纠缠纤维毯；它们违背“2004 宽块手绘、低频
  磨损、无照片微噪声”。进入确定性 rim 后形成近连续的暖色锯齿边，抢过动态
  Health／Power，仍有工业滚边感。liner 的烟褐低对比方向可保留。
- 次级技术失败：四个 material bbox 分别为
  `[37,37,754,499]`、`[781,37,1499,499]`、`[37,524,754,987]`、
  `[781,524,1499,987]`，相对合同 cell 最大越界 `52px`，超过 `3px` 容差；
  `fixed_cells_pass=false`。Canvas／mode、sample window、四个 `592×296` source、
  四个 `74×37` runtime、provider inset 全不透明和透明 RGB 清零均通过。
- 真实排版：40 个独立 Secure Button、`767×159`、`100%` runtime、实际动态
  名称／Health／Power／Aura／状态层均已渲染。display-region 仍为
  `7/7 pass`、violations `0`；这只证明几何，不能挽救材质失败。
- 证据：technical report SHA `d42376d6…33e7`；display report SHA
  `ddb3fc51…6dd0`；source preview SHA `b9222d9c…1b96`；真实排版 review SHA
  `6e98e13f…5478`，scene SHA `d2c83bcf…6a46`。
- 内部结论：`internal-fail / repair-prepared`。不得交用户接受、不得写 source、
  runtime 或 addon。attempt 2 明确保留四材料身份和 liner，仅在冻结材料字段
  内修复笔触频率、综合色差与 cell 占用。

### `UF-RAID-A2-DONOR V1.r1` — attempt 2 自包含低频手绘材质修复

```text
Edit Image 3 into exactly one corrected 1536x1024 RGB material-donor sheet for
a 2004-era vanilla World of Warcraft expedition raid UI. This remains a
material-only development sheet, not a UI mockup. It must contain no frame,
shell, card, plaque, button, atlas part, status bar or interface geometry.

Preserve from Image 3 only the successful high-level structure and palette:
four separate dark low-saturation material roles in the same order; deep
soot-walnut salvaged rawhide at top-left; quiet smoke-brown backing at
top-right; dark tarnished umber brass at bottom-left; smoke-dark coarse flax
material at bottom-right; uninterrupted material throughout every fixed
sample window; and no text, UI geometry or already-formed repair object. Do
not preserve Image 3's oversized field bounds, photographic microtexture,
uniform tiny leather grain, tangled hair-like fibre carpet, large brass
hotspots or long crossing scratch network.

Use pure flat #00FF00 only outside and between four exact rectangular fields.
The top-left leather field is x64 inclusive through x735 inclusive and y64
through y447. The top-right liner field is x800 through x1471 and y64 through
y447. The bottom-left brass field is x64 through x735 and y576 through y959.
The bottom-right flax field is x800 through x1471 and y576 through y959. Keep
every pixel beyond those four rectangles pure flat #00FF00 with no glow,
gradient, shadow, texture or antialiasing. Do not let a field cross its cell or
touch another field.

Every fixed inner sample window must remain completely filled by its assigned
material, with no green, border, edge, shadow, divider, label, object
silhouette or embedded ornament: leather x144..656 y112..400; liner
x880..1392 y112..400; brass x144..656 y624..912; flax x880..1392 y624..912.
The sample windows are arbitrary crop donors, so no focal object or boundary
may occur inside them.

Repaint all four fields as deliberately broad circa-2004 World of Warcraft UI
bitmap material painting rather than photographed surfaces. Use chunky value
groups, matte pigment, warm upper-left illumination, restrained contrast and
low-frequency handmade variation that will remain readable after an eight-to-
one reduction. Eliminate one-to-three-pixel pores, hair, grit, digital noise,
procedural grain, repeated tile motifs and evenly distributed sharp detail.

The leather field resembles reused saddle strap or shield-backing rawhide.
Use broad uneven soot stain, blunt scraped grain, sparse worn patches and slow
pigment changes roughly tens of pixels across. Leave long matte stretches.
Do not create pebble grain, upholstery embossing, reptile scales, rope-like
edge rhythm, fine pores or an all-over scratch carpet.

The liner field remains the quietest and darkest material. Preserve Image 3's
successful smoke-brown restraint, but simplify any remaining small cloudy
repetition into only a few broad matte soot and dye fields with soft lost
edges. It has no central mark, seam, highlight strip, vignette, frame or fake
panel.

The brass field is one continuous oxidized dark-umber material sample, not a
metal plate object. Replace the large golden blotches and long crossing
scratches with broad dull oxidation, sparse short broken scuffs and only a few
small discontinuous warm catches. Lift the dark-umber midtone slightly enough
to remain distinguishable when used in a tiny rivet or repair mask, but never
make it bright gold, polished, reflective or a focal light source.

The flax field is a continuous smoke-dark coarse fibre material sample, not a
nest of hair and not an already-formed thread object. Replace dense tangled
loops and all-over sharp fibres with broad pulped flax direction, uneven dark
dye and a small number of coarse broken fibre groups at a usable hand-painted
scale. Draw no individual cord, stitch, braid, rope, seam, knot, loop, woven
pattern or high-frequency felt carpet. Keep it slightly more legible than
Image 3 after reduction, while remaining darker and less focal than leather.

The written requirements outrank all input images. Use Image 1 only for its
circa-2004 broad hand-painted bitmap scale, warm upper-left light, apparent
material thickness and low-frequency handmade wear; ignore its book, page,
spine, dragon, complete-frame geometry and every object layout. Use Image 2
only for deep-walnut tonal depth, restrained smoke-brown pigment, rough
handmade paint and dull oxidized-brass response; ignore its book construction,
every UI contour and every object layout. Use Image 3 only for the successful
four-role order, low-saturation dark palette and quiet liner. Explicitly
discard Image 3's field bboxes, photo-like surface frequency, leather
micrograin, brass hotspot and scratch network, and tangled flax carpet. Do not
copy pixels or shapes from Image 1 or Image 2. Do not use any simulation image
or rejected A1 candidate.

Do not draw stitches, rivets, patches, notches, cuts, repairs, piping,
embossing, tooling, lacing, labels, grids or measurements: Python constructs
all exact geometry and A/B/C/D repair masks later. No pages, books, wax seals,
dragons, skulls, spikes, gems, runes, Diablo-style black iron, modern flat UI,
glass, neon, regular industrial bevels, mirrored decoration, product swatch
cards or photoreal antique photography. No text of any kind.

Before returning, verify visibly: exactly one 1536 by 1024 RGB donor sheet;
exactly four uninterrupted unlabelled fields at the four specified rectangles;
all pixels outside those rectangles are flat #00FF00; every fixed sample
window is completely material-filled; the four fields use broad low-frequency
hand-painted material decisions; leather has no micrograin carpet; liner is
quiet; brass has no large hotspot or long scratch web; flax has no tangled
loops or formed thread; and no UI geometry, repair object, text, label or
measurement is present.
```

#### Attempt 2 执行与内部审查

- 固定子进程 user block 完整回显；Prompt body SHA `a6f2a877…9516`。Image 1／2
  路径、顺序和 SHA 与授权一致；Image 3 只使用同循环紧邻 attempt 1 raw，SHA
  `ac2f7a2a…ec23`，没有上传其他像素。固定执行器返回一张 `1536×1024 RGB`；
  session `019ff531-86c6-7333-9ea1-31a8d5ec461f`，provider result
  `ig_0a7b3d9d79050dcb016a7c35bc352c819183b83d8fa24aeaff`；provider native 与
  child copy SHA 同为 `d6479b89…c893`。
- 范围／语义：通过。四材料职责、顺序、低饱和深色层级、无文字、无 UI 几何、
  无维修对象均保持；四个 fixed sample window 的 dominant-green 像素仍为 `0`。
- 第一失败——美术一致性：高频边缘指标虽相对 attempt 1 约下降一半，但 leather、
  liner、brass、thread 仍共享同一种均匀卷曲压纹；leather 像工业压花皮具，thread
  仍像纠缠纤维毯，brass 仍有大面积暖亮斑。Python 造壳后表面不再完全抢占
  Health／Power，但 source 与 8× runtime 仍能读出规则商品纹理，不符合 Chat
  锁定基准的宽块手绘、粗粝随性和低频磨损。
- 次级技术失败：四个 material bbox 分别为
  `[51,42,752,503]`、`[780,42,1486,503]`、`[51,529,752,984]`、
  `[780,529,1487,984]`，相对合同 cell 最大偏移 `55px`；
  `fixed_cells_pass=false`。Canvas／mode、sample window、A-D 四张 `592×296`
  source、四张 `74×37` runtime、provider inset 全不透明与透明 RGB 清零均通过。
- 真实排版：40 个独立 Secure Button、`767×159`、`100%` runtime 和真实动态层
  已重建；display-region 为 `7/7 pass`、violations `0`。这些几何通过项不能
  挽救重复压纹的年代／美术失败。
- 证据：technical report SHA `fe967f56…13be`；display report SHA
  `ddb3fc51…6dd0`；source preview SHA `e09ba261…1e4`；真实排版 review SHA
  `331dc14c…72e8`，scene SHA `bacb6c16…4a59`。executor JSON SHA
  `751591a0…fa64`，log SHA `ca26f61e…a6cb`。
- 流程错误 `1`：provider 已只生成一张图并完成 copy 后，child 用缺少 Pillow 的
  系统 Python 做重复元数据检查失败；随后 `file`／`sips` 成功确认同一图并正常
  返回。没有第二张 provider 图，不增加实际生图次数。
- 内部结论：`internal-fail / repair-prepared`。不得交用户接受、不得写 source、
  runtime 或 addon。attempt 3 不保留 attempt 2 的失败纹理，因此不上传
  Image 3；只用固定 Image 1／2 regenerate。

### `UF-RAID-A2-DONOR V1.r2` — attempt 3 自包含超低频哑光颜料重建

```text
Create from scratch exactly one 1536x1024 RGB material-donor sheet for a
2004-era vanilla World of Warcraft expedition raid UI. This is a coarse
hand-painted game-texture donor, not material photography, not a UI mockup
and not a product swatch board. It contains only four flat uninterrupted
painted material fields and a pure-green chroma background. Do not use or
reconstruct any prior donor output; no Image 3 is supplied for this attempt.

Build a clean hard-edged geometric mask before painting. The canvas has a
64-pixel pure #00FF00 outer gutter on every side, a 64-pixel pure-green
vertical gap between columns, and a 128-pixel pure-green horizontal gap
between rows. Paint exactly four rectangular fields, each exactly 672 by 384
pixels: leather x64 inclusive through x735 inclusive and y64 through y447;
liner x800 through x1471 and y64 through y447; brass x64 through x735 and
y576 through y959; flax x800 through x1471 and y576 through y959. Every pixel
outside those four rectangles is flat RGB #00FF00 with no antialiasing,
shadow, glow, gradient, texture, spill or detached mark.

Keep these crop-safe windows completely filled by their assigned material:
leather x144..656 y112..400; liner x880..1392 y112..400; brass
x144..656 y624..912; flax x880..1392 y624..912. A sample window may contain
no green, border, edge, vignette, seam, divider, focal object, embedded
ornament, silhouette, shadow, label or measurement. Python crops these exact
windows and cover-fits them later, so every area inside a window must remain a
continuous generic material painting.

Use deliberately under-resolved circa-2004 game-interface painting. Think
matte opaque gouache blocked into broad low-resolution value clusters, not a
photograph, scan, procedural texture, PBR material, bump map or normal map.
Inside each sample window use only about six to ten large soft-lost tonal
masses. Most deliberate value changes should span 60 to 180 pixels; no
recognizable surface element may be smaller than about 24 pixels. Preserve
long quiet matte stretches. Use warm upper-left illumination, deep
low-saturation expedition colours, simple shadow groups and hand-made
unevenness. Do not cover a field with repeated grain, curls, pores, hairs,
fibres, pebbles, scratches, speckles, stipple, noise or embossed relief. No
single surface pattern may repeat across two material fields.

Top-left leather is deep soot-walnut salvaged rawhide suggested by colour and
broad wear, not by literal pores. Use five to eight slow smoke or uneven-dye
clouds, two or three blunt broad scraped passages and wide untouched matte
areas. A scrape is a soft painted value change tens of pixels thick, never a
thin line. No pebble grain, all-over wrinkle network, upholstery embossing,
reptile scale, hair, fine crackle, stitched edge or orange highlight.

Top-right liner is the darkest and quietest field: matte smoke-brown backing
with only three to five very broad soot or dye masses, extremely low contrast,
soft lost edges and no focal highlight. It must be visibly calmer than all
other fields. No leather grain, cloudy repeating motif, fabric weave, panel,
vignette, rim, centre mark or horizontal strip.

Bottom-left brass is a continuous dark tarnished-umber pigment field that
will only be sampled through tiny Python repair masks; it is not a metal plate
object. Suggest aged brass with four to seven broad matte oxidation pools and
at most three short broken dull-warm catches. Keep catches small, separated
and subordinate. No large yellow hotspot, reflective shine, long crossing
scratch web, hammered dimples, engraved pattern, raised relief, border or
polished gold.

Bottom-right flax is an abstract smoke-dark coarse-flax pigment field, not a
photographic fibre mat. Suggest flax with three to six broad broken dry-brush
directions, each 32 to 96 pixels thick, plus slow uneven dark dye. Do not draw
individual fibres, hair, thread, cord, stitch, braid, rope, seam, knot, loop,
weave, felt curls or a tangled carpet. It must remain darker and less focal
than leather and must not share leather's marks.

The written requirements outrank both references. Use Image 1 only for its
circa-2004 broad painted bitmap scale, warm upper-left light, apparent material
weight, restrained warm contrast and low-frequency handmade wear; ignore its
screen composition, text, portraits, book, pages, spine, tabs, dragon, wax
seals, complete-frame geometry and all object layout. Use Image 2 only for
deep-walnut tonal depth, smoke-brown restraint, matte rough pigment, dull
oxidized-brass response and hand-made error; ignore its book construction,
pages, spine, columns, dragons, ornaments, UI contour and all object layout.
Do not copy pixels or shapes from either reference. No simulation image,
rejected raid-shell image or prior donor is an input.

Do not draw a frame, shell, card, plaque, panel, button, atlas part, status
bar, opening, border, stitches, rivets, patches, notches, cuts, repairs,
piping, tooling, lacing, grid or guide. Python alone constructs all exact
shell geometry, Alpha, lighting, A/B/C/D repair masks, 592x296 source,
74x37 runtime and 6/62/6 three-slice output. No pages, books, wax seals,
dragons, skulls, spikes, gems, runes, Diablo-style black iron, modern flat UI,
glass, neon, industrial bevels, mirrored decoration or text of any kind.

Before returning, verify visibly: exactly one 1536 by 1024 RGB sheet; exactly
four and only four hard-edged 672 by 384 fields in the specified coordinates;
all outer and central gutters are uniform #00FF00; every crop-safe window is
fully material-filled; the four materials are distinguishable without any
shared repeating surface pattern; all marks are broad matte hand-painted
value groups readable as a 2004 game texture; leather has no micrograin,
liner is quiet, brass has no large hotspot, flax has no individual fibre; and
there is no UI geometry, formed repair object, label, measurement or text.
```

#### Attempt 3 执行与内部审查

- 固定子进程 user block 完整回显；Prompt body SHA `2de5a46b…9dd7`。只上传
  固定 Image 1／2，路径、顺序和 SHA 与授权一致，`Image 3 = none`；没有上传
  其他像素。固定执行器返回一张 `1536×1024 RGB`；session
  `019ff53a-39b4-79c0-94bd-b308a4a29962`，provider result
  `ig_09b4123c1cee1bb7016a7c37ecb4ac81919dcddc53fa6d9b0e`；provider native 与
  child copy SHA 同为 `6f54172b…4b28`。没有流程错误。
- 主要美术门禁：通过。attempt 2 的重复卷曲压纹、照片皮孔、纠缠纤维与长划痕
  已消失；leather、liner、brass、thread 使用明显不同的宽块哑光颜料决定，liner
  安静，运行时不再呈工业压花或连续锯齿表面。四个 sample window 均无 green、
  文字、UI 几何或维修对象。
- 剩余美术修复：leather 的少量暖斑在薄上轨仍形成偏亮连续段；brass 与 thread
  的平均亮度分别为 `54.089/53.035`，高于 leather `41.541` 与 liner `34.805`。
  它们只用于很小的 Python 维修 mask，但应再克制压暗，避免 A/C 线补或 D 铜片
  成为 40 人阵列中的重复亮点。
- 第一失败——固定格位：detected bbox 为
  `[74,47,749,489]`、`[787,47,1461,490]`、`[74,535,749,977]`、
  `[787,535,1461,977]`，最大偏移 `42px`；leather／brass 的 contract cell 左侧
  各残留 `3840` dominant-green px，liner／thread 各 `4224`。因此
  `fixed_cells_pass=false`，本稿仍不能直接成为候选。
- Python／真实排版：A-D `592×296` source、`74×37` runtime、provider inset
  全不透明、透明 RGB 清零全部通过；40 个独立 Secure Button、`767×159`、
  `100%` runtime 与真实动态层已重建。display-region `7/7 pass`、violations `0`。
- 证据：technical report SHA `657c094e…5f32`；display report SHA
  `ddb3fc51…6dd0`；source preview SHA `0bd17938…b1c1`；真实排版 review SHA
  `4b8da3cc…0010`，scene SHA `72b2f19d…6fd`。executor JSON SHA
  `d1340302…065f`，log SHA `a37e9a7c…0b96`。
- 内部结论：`internal-fail / repair-prepared`。attempt 4 使用同循环紧邻本稿作
  Image 3，只修固定矩形 mask 与三种材料的克制亮度；禁止重引入细纹或改变
  四材料职责，不得写 source、runtime 或 addon。

### `UF-RAID-A2-DONOR V1.r3` — attempt 4 自包含精确收边与克制降亮

```text
Edit Image 3 into exactly one corrected 1536x1024 RGB material-donor sheet
for a 2004-era vanilla World of Warcraft expedition raid UI. This remains a
material-only development sheet, not a UI mockup, atlas, product swatch board
or photograph. Keep exactly four uninterrupted painted material fields on a
flat pure-green background and no other object.

Image 3 already has the correct artistic solution. Preserve its deliberately
under-resolved matte gouache character, broad 60-to-180-pixel hand-painted
value masses, distinct mark language for each material, low-saturation
expedition palette, warm upper-left light, long quiet areas, calm liner, lack
of repeated embossed texture, and complete absence of UI geometry, text and
formed repairs. Do not replace these broad marks with leather pores, curls,
hairs, fibres, scratches, stipple, procedural grain, PBR relief or any new
high-frequency surface pattern.

Apply four exact hard rectangular masks and crop or extend the existing broad
paint beneath those masks without inventing a border. The final top-left
leather rectangle is exactly x64 inclusive through x735 inclusive and y64
through y447. The final top-right liner rectangle is exactly x800 through
x1471 and y64 through y447. The final bottom-left brass rectangle is exactly
x64 through x735 and y576 through y959. The final bottom-right flax rectangle
is exactly x800 through x1471 and y576 through y959. Each is exactly 672 by
384 pixels. Every pixel outside those four rectangles must be uniform flat
RGB #00FF00, with no antialiasing, gradient, shadow, glow, texture, fringe,
spill or detached mark.

Correct Image 3's current approximate bounds rather than preserving them.
Its top-left field currently appears around x74..749/y47..489: extend its
left edge ten pixels, trim its right edge about thirteen, move its top edge
down about seventeen and trim its bottom by about forty-one. Its top-right
field currently appears around x787..1461/y47..490: trim the left by about
thirteen, extend the right by about eleven, move the top down about seventeen
and trim the bottom by about forty-two. Its bottom-left appears around
x74..749/y535..977 and its bottom-right around x787..1461/y535..977: move
both top edges down about forty-one and both bottom edges up about seventeen,
while applying the same exact horizontal masks stated above. The written
absolute coordinates outrank these approximate correction descriptions.

Keep every fixed crop-safe window completely material-filled: leather
x144..656 y112..400; liner x880..1392 y112..400; brass x144..656 y624..912;
flax x880..1392 y624..912. These windows may contain no green, border, edge,
vignette, seam, divider, focal object, embedded ornament, silhouette, shadow,
label or measurement. Python crops these exact windows and cover-fits them
later; do not introduce an edge or special mark inside a window.

Preserve the leather's broad soot-walnut clouds and blunt dry-brush wear, but
lower its warm highlights by roughly fifteen percent so no bright passage
reads as a continuous orange top rim after reduction. Preserve the liner
almost unchanged: it remains the darkest and quietest smoke-brown field, with
only a few broad low-contrast matte masses. Preserve the brass's broad
oxidation structure but lower its total brightness roughly twenty percent,
remove yellow cast and keep only tiny separated dull-umber catches. Preserve
the flax's broad diagonal dry-brush directions but lower total brightness
roughly twenty-five percent and contrast roughly twenty percent; it must read
as smoke-dark flax pigment, not pale canvas, individual fibre or a focal
stripe. Do not change material order or share marks between fields.

The written requirements outrank all inputs. Use Image 1 only for its
circa-2004 broad painted bitmap scale, warm upper-left light, apparent material
weight, restrained warm contrast and low-frequency handmade wear; ignore its
screen composition, text, portraits, book, pages, spine, tabs, dragon, wax
seals, complete-frame geometry and object layout. Use Image 2 only for
deep-walnut depth, smoke-brown restraint, matte rough pigment, dull oxidized
brass and hand-made error; ignore its book construction, pages, spine,
columns, dragons, ornaments, UI contour and object layout. Use Image 3 only
for its successful four-role order, broad low-frequency gouache decisions,
dark palette and quiet liner. Explicitly discard Image 3's approximate field
bounds and its excess leather, brass and flax brightness. No other image,
simulation or rejected raid-shell candidate is a source.

Do not draw a frame, shell, card, plaque, panel, button, atlas part, status
bar, opening, border, stitches, rivets, patches, notches, cuts, repairs,
piping, tooling, lacing, grid or guide. Python alone constructs all exact
shell geometry, Alpha, lighting, A/B/C/D repair masks, 592x296 source,
74x37 runtime and 6/62/6 three-slice output. No pages, books, wax seals,
dragons, skulls, spikes, gems, runes, Diablo-style black iron, modern flat UI,
glass, neon, industrial bevels, mirrored decoration or text of any kind.

Before returning, verify visibly: exactly one 1536 by 1024 RGB sheet; exactly
four and only four hard-edged 672 by 384 fields at the specified absolute
coordinates; the outer gutters are exactly 64 pixels, the vertical centre gap
exactly 64 and horizontal centre gap exactly 128; all other pixels are uniform
#00FF00; every crop-safe window is fully material-filled; Image 3's successful
broad matte 2004 hand-painted material language is retained; leather has no
bright continuous rim, liner stays quiet, brass is dull umber, flax is dark
and non-focal; and there is no UI geometry, formed repair, label, measurement
or text.
```

## UF-RAID-A1 历史元数据

- 模块：Unit Frames
- 组件 ID：`UF.RAID.*`
- 方向版本：`UF-RAID-SIM-V1`
- 正式生产版本：`UF-RAID-A1 V1 final.r4 / repair-budget-exhausted`
- 子状态：`candidate-rejected / 5/5 / waiting-new-user-direction`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前操作：`stop-no-sixth-call`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 自动修复预算：`UF-RAID-A1 V1 final` 最多 5 次实际 ImageGen，含首次；
  流程错误不计额度
- 当前实际生图：`5/5`；剩余 `0`
- 流程错误：`2`；均发生在 provider 已只生成一张图之后，不增加实际生图数
- 多执行正文最坏实际生图数：`5`；本批只有一段正式正文
- 最新 raw：`generated/unitframes/raid/A1/V1/attempt-05/uf-raid-a1-v1-attempt-05-raw.png`，
  SHA `684e3f5e…96c1`；当前最佳内部视觉参考为 attempt 3 raw
  `41c9d561…e760`，但二者都不是 candidate；无 source／runtime／addon 变更
- 锁定视觉基准：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
    只继承 2004 年位图尺度、材料厚度、暖光与粗糙磨损。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
    只继承深胡桃旧皮革、手工误差和克制的暗铜响应。
- 次级现有 runtime：`UnitFrameHealthFillV1.tga`／`UnitFramePowerFillV1.tga`；
  模拟按真实像素使用，但 addon 尚未把它们路由给 Raid。

## 美术基准继承

### 权威顺序

1. 上述两张 Chat 锁定图及其在 Unit Frames 主／子模块 Prompt 中声明的受限职责；
2. `docs/modules/unitframes/ART_BASELINE.md`；
3. `docs/GLOBAL_ART_BASELINE.md`；
4. `docs/modules/unitframes/SUBMODULES.md` 的真实对象、几何和动态所有权；
5. 已接受 Health／Power source，只负责条形颜料材质，不反向定义外壳。

### 必须继承的视觉 DNA

- 物件身份仍属于“远征队行军身份牌”：旧马鞍带、盾牌背带、帐篷捆扎皮被
  拆下重用，皮革承担结构，黄铜只作少量修补。
- 低饱和烟褐／深胡桃色、左上暖光、早期 WoW 宽块面和低频手工误差；不靠
  均匀毛孔、规则针脚或对称铆钉制造做旧。
- 粗犷感在 40 个对象组成的整体编队中成立；单个成员条必须轻薄，不能把每个
  `70×33` Button 变成一个厚重卡片。

### 本批组件级转译

- 每个成员是夹在远征点名册编队中的短皮革名条，不是独立书页、书签或缩小的
  Player／Target 外壳。
- 使用 `A/B/C/D` 四个完整外壳变体，按 `pfRaid` 槽位确定性分配；缺口、补针、
  暗铆钉和短修补位置不同，但综合色重相同。换人不改变槽位外观。
- 外夹边只在 Button 外露约 `2px`，中心由真实 Health／Power、名称与状态占据；
  40 人密度下不增加一圈共享书框、金属框或半透明底板。
- Hover／Aggro 只响应两三段破边；Range／Offline 继续由 pfUI Alpha 表达。

### 明确不继承

- 不继承 Chat 的书页、书脊、频道签、蜡封、立柱、龙纹或完整书框；
- 不继承主单位框的较厚端部、身份夹片比例或 `214×42` 轮廓；
- 不新增《暗黑破坏神 3》黑铁祭坛、现代玻璃卡片、整框霓虹或规则工业网格。

### 冲突审计

- 全局“厚重”与 40 人信息密度冲突：厚重由整组暗色材料和真实状态密度产生，
  单成员外夹边保持 2px；不得把重量误译为 40 个厚框。
- “不工整”与可读性冲突：只在外轮廓、染色、短补针和四变体分布中产生低频
  差异；Health／Power、安全区、名称中心与点击盒仍精确对齐。
- 原 pfUI 完整矩形 Glow 与本项目语言冲突：保留状态逻辑，未来只替换绘制层。

## provider 审计与边界

- `addon/pfUI/modules/raid.lua` 创建 `pfRaid1..pfRaid40`，每个均来自
  `pfUI.uf:CreateUnitFrame("Raid", i, C.unitframes.raid)`；全部是真实 Secure
  Button，并登记 ClickCast。
- 当前仓库 profile：`maxraid=40`、`raidlayout=10x4`、`raidfill=VERTICAL`、
  `raidpadding=5`、`border=1`、`width=70`、`height=30`、`pheight=2`、
  `pspace=-1`、`portrait=off`。
- `UpdateFrameSize()` 得到 Button `70×33`；HP 为 `70×30`，Power 为 `70×2`，
  中间 `1px`；布局 pitch 为 `77×40`。40 个 Button bbox 为 `763×153`；计入
  `2px` 外壳和最高 Raid Icon 后的视觉包络为 `767×159`。
- Cluster 固定从屏幕左下 `x=2` 开始；因此左侧外扩最多 `2px`，否则首列会被
  屏幕裁切。模拟使用 `74×37` 外壳，不修改 Cluster Point。
- `raidforgroup` 可把同一对象用于五人队，`selfinraid` 可用于单人；二者当前
  profile 均关闭。`raidgrouplabel` 当前关闭，但 provider 最多已有 8 个
  `Group N` FontString 对象。
- `addon/pfUI/modules/group.lua` 的 Party／PartyTarget／PartyPet 以及
  `modules/raidmarkers.lua` 的 Raid Marker 血条列表均不属于本批。

## 组件合同

| 逻辑对象 | runtime 数量 | 本批处理 | 动态所有权／禁止烘焙 |
|---|---:|---|---|
| `UF.RAID.MEMBER.SHELL.A-D` | 40 选 4 | 四个完整背景外壳；每个标准 art box `74×37` | 不烘焙名称、血量、职业色、状态、图标或点击 |
| `UF.RAID.BAR.HEALTH.FILL` | 40 | 模拟复用已接受 `64×32` donor；确认后再扩展 adapter scope | 数值、宽度、颜色、动画与治疗预测归 pfUI |
| `UF.RAID.BAR.POWER.FILL` | 40 | 模拟复用已接受 `64×16` donor；真实显示高 `2px` | Mana／Rage／Energy／Focus 色与裁切归 pfUI |
| `UF.RAID.STATE.RIM` | 每框按需 | 未来从接受外壳 Alpha 确定性派生短边 mask | Hover／Aggro／Combat 事件归 pfUI；禁止整框光圈 |
| `UF.RAID.STATE.PIP` | 每框最多 1 | provider 选项启用时使用小型破颜料角标；不单独 ImageGen | `squareaggro`／`squarecombat` 判定归 pfUI |
| `UF.RAID.AURA.RIM` | 每框最多 6＋驱散图标 | 只增加 1px 烟黑承托；图标本体不重绘 | Aura、层数、冷却、驱散类型与 Tooltip 归 pfUI |
| Vanilla 功能 glyph | 每框按需 | 队长、主拾取、Raid Target、复活保留动态身份 | 不烘焙进外壳；后续只允许增加暗色承托 |
| `UF.RAID.GROUP.LABEL.BACKING` | 最多 8 | 已审计，因当前关闭而暂停 production | `Group N` 文字继续是 FontString |

### 尺寸、拉伸与层序

- 标准外壳相对真实 Button 外扩 `left/right/top/bottom=2px`；外壳必须
  `EnableMouse(false)`，Button 命中盒仍为 `70×33`。
- 标准高度固定为 `33px`。整体 UI Scale 由共同 Parent 同步缩放，不会产生
  拼接错位；若用户只改变 Width，接受完整 source 可确定性派生横向三切片，
  唯一修补必须留在固定端部。Height 偏离当前合同则局部 fail-open，不纵向
  强拉美术。
- 层序由低到高：外壳／烟褐 liner → HP／Power 背景 → 动态 fill／治疗预测 →
  名称 → Buff／Debuff／Raid Icon／复活 → 短边状态响应。任何 art 不接管鼠标。
- 原 `CreateBackdrop` 透明方块与 `glow2` 只会在 P5 adapter 成立后针对 Raid
  隐藏／替换；其他 UnitFrame 保持原状。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-RAID-SIM-V1`
- 目标场景：当前 profile 的完整 40 人团队、真实屏幕锚点、Chat／经典动作条／
  罗盘邻接；审阅板另含四变体、状态层、可选 Group Label 与 100% 重复密度。
- 真实对象数量：`40`；不是稀疏 contact sheet。
- 状态分布：Hover、Aggro、Range、Offline、Dead、Incoming Heal、Resurrection、
  Buff、Magic／Poison、Leader、Master Looter 与三个 Raid Marker。
- 当前 accepted/runtime：Health／Power 使用 addon 内现有 TGA 的真实像素；
  新外壳、状态边缘与相邻 UI 均为简单几何占位。
- 用户需要确认：不增加共享外框；薄皮革点名名条隐喻；四变体力度；暗色配色；
  单框与 40 人整体的重量；状态是否清楚且不过度现代。
- 非权威：最终笔触、Alpha、source extraction、production canvas、atlas packing、
  Group Label 成品和目标设备 SavedVariables。
- 禁止用途：模拟像素不得成为 source/runtime，不得作为生产 edit/reference 输入。

### 本地模拟规格与执行

- specification：`tools/specs/unitframes_raid_simulation_v1.json`
- renderer：`tools/render_unitframes_raid_simulation_v1.py`
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 命令：`conda run -n py312 python tools/render_unitframes_raid_simulation_v1.py`
- scene：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.scene.png`，
  SHA-256 `41468266052da80579f1194f028a83adf7dc81afce6f458d617a0ea246325519`。
- review：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.review.png`，
  SHA-256 `10158347dd9ba002cb07f3519d8a42174547340ee79ff176fce9e9608e08eca2`。
- ImageGen：`0/0`；本地渲染错误：`0`。
- 内部结论：`displayable`。40 人密度、四变体分布、已接受条纹理、状态层和
  相邻 UI 可共同读取；没有额外共享外框。

### 实际展示区域门禁

- 合同：`tools/specs/unitframes_raid_simulation_display_region_v1.json`
- 报告：`generated/unitframes/raid/simulation/V1/display-region-report.json`，
  SHA-256 `ddb3fc51b7c3ef2e1590ecc145b4668ed3d23c5e627600dfa2d0a424a8ce6dd0`。
- 结果：`7/7 pass`，violations `0`，first failure `null`。
- 覆盖：单成员普通／重状态、40 人 Vertical／Horizontal、20 人、五人复用、
  `width=90` 横向变化；Height 变更明确不在本合同内并 fail-open。

### 用户方向结论

- 具体模拟版本：`UF-RAID-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-12`
- 模拟像素接受：`false`
- 正式生产授权：`true / UF-RAID-A1 V1 final / 2026-08-12`
- 已确认并写回正式正文的可见条款：
  - 维持真实 `40` 个 `pfRaid` Button 与 `10×4 VERTICAL` 密度，不增加覆盖
    整团的共享外框、底板或装饰背景；
  - 每个成员是薄的手裁旧皮革点名名条，四变体重量一致；粗犷与厚重来自
    40 个暗色物件形成的编队，而不是把每个对象做成厚卡片；
  - 使用低饱和烟褐、深胡桃、少量氧化暗铜与左上暖光；继承 Chat 的年代、
    笔触、材料厚度与磨损节奏，但不复制书本轮廓；
  - 既有 Health／Power 材质、名称、状态、Aura 与 Vanilla glyph 保持动态，
    Hover／Aggro 未来只用断续短边反馈。
- 确认失效条件：改变共享外框结论、成员物件隐喻、四变体数量、综合色重、
  配色、真实编队密度或动态状态层级时，必须返回新模拟版本。
- 授权原文：用户确认每次上传固定 SHA 的 Image 1／2，attempt 1 无 Image 3；
  仅允许同循环紧邻前次完整 production sheet 在冻结修复边界内作为 Image 3
  edit 输入；最多 5 次实际 ImageGen，流程错误不占额度；允许合同内固定四格
  拆分、边缘连通色键、透明 RGB 清零、bbox 归一化、`74×37` runtime、
  `6/62/6` 三切片派生及真实排版预演。
- 下一门禁：以已提交的 `UF-RAID-A1 V1 final` 原文调用固定执行器 attempt 1，
  然后执行完整内部审查；不得自动晋级 source。

## `UF-RAID-A1 V1 final` 正式生产合同

### 生产粒度与打包

- 一段正式正文只生成 `UF.RAID.MEMBER.SHELL.A-D` 四个完整背景外壳，物理上
  放在同一 `1536×1024` 生产 sheet，逻辑上仍是四个独立 source；固定格位可
  确定性拆分，不会把 40 个 Secure Button 合并为一张交互背景。
- `UF.RAID.STATE.RIM`／`STATE.PIP`／`AURA.RIM` 在接受外壳后确定性派生，不
  单独 ImageGen；Health／Power 在接受本批后复用现有已接受 source；当前关闭
  的 Group Label backing 继续暂停。因此本批只有一段正文，最坏总计 `5` 次
  实际 ImageGen。
- 机器合同：`tools/specs/unitframes_raid_production_v1.json`。

### Canvas、格位与 source 几何

- 输出：`1536×1024 RGB`，纯 `#00FF00` 背景，正面正交视角，无标签、网格、
  尺寸字或 UI 效果图。
- 固定 cell：A `[0,0,768,512]`；B `[768,0,1536,512]`；
  C `[0,512,768,1024]`；D `[768,512,1536,1024]`。
- 各完整外壳目标可见 bbox 均为 `592×296`：A `[88,108,680,404]`；
  B `[856,108,1448,404]`；C `[88,620,680,916]`；
  D `[856,620,1448,916]`。每格恰好一个连通实体，不跨格、无独立碎屑。
- 每格提取并归一化为一个 `592×296 RGBA` source，确定性缩至完整
  `74×37` runtime。normalized source 中真实 Button 为 `[16,16,576,280]`，
  Health `[16,16,576,256]`，`8px` 间隔 `[16,256,576,264]`，Power
  `[16,264,576,280]`；名称安静区 `[40,48,552,232]`。
- 横向 width 变化只从同一完整 source 派生 `48/496/48` source 三切片，即
  runtime `6/62/6`；变体唯一识别细节必须完全留在左右固定 `48px` source
  cap。高度固定，不纵向拉伸；整体 UI Scale 由共同 Parent 一起缩放。

### 色键、后处理与客观门禁

- 外壳是完整不透明的“皮革夹边＋烟褐 liner”背景板，不是空心皮环；纯绿只
  存在于每个物件外轮廓之外。liner 会位于真实动态条下方，必须安静、低对比。
- 允许：固定格位拆分、边缘连通绿幕转 Alpha、透明 RGB 清零、每格单物件 bbox
  提取、在 ratio error 与 X／Y anisotropy 均 `≤8%` 时归一化为 `592×296`、
  完整纹理缩放、atlas padding／extrusion、三切片与状态短边 mask 派生。
- 禁止：Python 补画／移动／复制／镜像修补，跨格复用像素，删除结构来挽救
  失败物件，或改变 provider Frame、点击、事件、Roster 和动态内容。
- 技术门禁：每格 `1` 个前景连通实体；四边最小隔离 `64/80/64/80`；目标比例
  `2:1`、ratio error `≤8%`、归一化 anisotropy `≤8%`；detached fleck、内部
  绿洞与可见绿溢色均为 `0`。技术通过不能替代语义和美术审查。

## 生产正文完整性预检

- 复杂度：`atlas / four independent sources / repeat / horizontal-stretch`。
- 结论：`pass-final`；执行必需但未知的值：无。

| 门禁 | `UF-RAID-A1 V1 final` 中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、数量与动态排除 | 第 1、4、8、9 段冻结四个点名名条与全部禁止烘焙项 | pass |
| Image 1／2 inherit／ignore 与权威冲突 | 第 7 段逐图声明职责，并规定文字高于输入图 | pass |
| Canvas、格位、bounds、视角、光照与层序 | 第 2、3、4 段给出四格绝对坐标、bbox、正交视角和背景板层序 | pass |
| 逐对象轮廓、材料、磨损与四变体关系 | 第 5、6 段冻结统一重量与 A／B／C／D 身份 | pass |
| 安静区、crop、repeat、三切片和接缝 | 第 4、5 段给出 normalized source、动态区和 `48/496/48` | pass |
| 年代、反模式、色键与最终自检 | 第 6、8、9 段冻结 2004 手绘 DNA、禁用现代语言并逐项自检 | pass |

- 去冗余结论：只重复“恰好四物件／固定格位／完整背景板而非空心框／变体细节
  只在端帽／禁止动态内容”五项高风险约束；provenance 历史不写进模型正文。

## 最终执行正文

### `UF-RAID-A1 V1 final` — 四变体完整成员背景外壳

```text
Create one production sheet containing exactly four complete empty raid-member
background shells for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul.
Return one 1536 by 1024 RGB bitmap on a perfectly uniform pure #00FF00
background. This is a source-asset sheet, not a gameplay screenshot, raid
window, concept board, contact-sheet presentation or assembled forty-player
panel. Draw no title, label, letter, number, grid line, guide, legend or fifth
object.

Use a fixed two-by-two cell layout. Cell A is x0..767/y0..511. Cell B is
x768..1535/y0..511. Cell C is x0..767/y512..1023. Cell D is
x768..1535/y512..1023. Put exactly one front-facing orthographic horizontal
shell in each cell. Aim each visible shell at exactly 592 by 296 source pixels:
A x88..679/y108..403, B x856..1447/y108..403, C
x88..679/y620..915, and D x856..1447/y620..915. Keep broad uninterrupted pure
green isolation around every object. Nothing may touch a cell edge, cross a
cell boundary, cast a shadow outside its own bbox or exist as a detached fleck.

Each cell is one complete solid background plate, not a hollow ring and not a
pile of separate border pieces. The plate is one physically connected object:
a thin hand-cut dark-walnut leather clamp edge wrapped around a quiet opaque
soot-brown liner that fills the entire interior. Pure green exists only outside
the outer silhouette; there is no green opening, transparent hole, internal
cutout, second slot or detached repair inside a plate. The liner sits behind
live Health and Power bars, so keep it matte, continuous, very low contrast and
free of symbols or sharp focal marks.

Every cell will be extracted to one 592 by 296 RGBA source and downsampled by
eight to one complete 74 by 37 runtime texture. At that runtime size the real
pfUI Secure Button occupies x2..71/y2..34, Health x2..71/y2..31, a one-pixel
gap y32, and Power x2..71/y33..34. The live name occupies the quiet central
area. Do not paint any simulated bar, fill amount, class colour, status colour,
name or icon. At full health only about two runtime pixels of the leather edge
remain visible around the live Button; therefore keep the individual shell
thin. The liner must still look intentional when an unfilled part of a live
StatusBar reveals it.

Design each complete source so it can later be divided horizontally into fixed
48-pixel left cap, quiet 496-pixel centre and fixed 48-pixel right cap, equal to
6/62/6 at runtime. Put every unique notch, stitch, rivet, patch or brass repair
entirely inside a fixed end cap. Keep the long centre extremely quiet, with
only broad low-frequency dye and soot variation; no unique mark may cross a
slice boundary, and no repeated stitch, cord, embossing or seam may run along
the centre. Height is fixed and will never be vertically stretched.

All four shells belong to one expedition muster set and must have the same
outer scale, liner area, darkness, visual weight and light direction. Their
differences are low-frequency and useful only to prevent forty industrially
identical repeats. A has one blunt hand-cut notch at the upper-left and two
short unequal repair stitches at lower-right. B has one off-centre dark rivet
at upper-right and a more repeatedly rubbed lower edge. C has one short
attached leather patch at the left edge and no bright metal. D has one short
skewed dark oxidized-brass repair at upper-right and one small split at
lower-left. Keep every repair attached to the plate, sparse and subordinate.
No variant may be more ornate, brighter or thicker than the others.

The world object is a compact expedition roster slip cut from discarded saddle
leather, shield straps or tent bindings and clipped behind one raid-member row.
It is not a miniature Player frame, book page, bookmark, scroll, furniture
trim, luxury leather label or modern card. Use deep soot-dark walnut and smoke
brown, very low saturation, sparse tarnished umber brass, and warm upper-left
light. Paint it like circa-2004 Vanilla World of Warcraft UI art: broad chunky
value blocks, readable material thickness, matte broken highlights and
deliberate low-resolution hand-painted edges. Ruggedness comes from slow
unequal cut thickness, uneven dye, smoke, mud rub, pressure wear and a few
repairs with believable tension. It does not come from random noisy waviness,
uniform pores or a procedural texture carpet.

The written requirements outrank both input images. Use Image 1 only for its
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and believable material thickness. Ignore its screen
composition, text, portraits, book, pages, spine, channel tabs, wax seals and
complete frame geometry. Use Image 2 only for deep-walnut depth, warm
upper-left light, contact shadow, restrained dull-brass response, rough wear
and hand-made error. Ignore its pages, spine, columns, dragons, broad book
construction and large metal ornaments. Do not copy pixels, shapes or book
parts from either image. Do not use the geometric simulation, existing bar
textures, rejected unit-frame candidates or any unlisted image as a visual
source.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, symmetrical gold border, continuous metal rim, rounded
web card, transparent black glass, modern bevel, glossy meter, neon, full-frame
glow, black-iron shrine, spikes, skulls, horns, faction emblem, class emblem,
gem, magic rune, photoreal antique, regular lacing, equal-distance stitches,
symmetric rivets, repeated pebble embossing, orange piping, upholstery and
precision industrial geometry. Draw no portrait, Health or Power fill, text,
number, class colour, reaction colour, aura, buff, debuff, raid marker,
leader icon, master-looter icon, resurrection icon, combat mark, aggro mark,
hover state, button highlight or click feedback.

Before returning, verify visibly: one 1536 by 1024 RGB sheet; exactly four and
only four connected solid plates in fixed A/B/C/D cells; one plate near 592 by
296 in each cell; broad pure-green isolation with no detached flecks; no green
hole inside any plate; identical scale, liner area and weight; unique details
only in fixed end caps; thin rough hand-cut Vanilla craft; deep walnut and
soot-brown palette with restrained dull brass; quiet stretchable centres; no
shared raid panel, book geometry, modern industrial repetition or baked live
content.
```

## 自主修复循环

- 当前：`repair-prepared`；attempt 1／2 已退回，实际 ImageGen `2/5`，剩余
  `3`；流程错误 `1`。
- attempt 1 固定上传：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
  - attempt 1 无 Image 3；模拟图与既有／失败 UnitFrame 像素禁止上传。
- attempt 2–5：每次仍固定 Image 1／2；只有明确保留合格格位时，才允许同一
  循环紧邻前次的完整 production sheet 作为 Image 3 edit 输入。每次从完整
  清单重新审查；同一首要失败不得重复相同策略。
- 不可变修复边界：四个组件 ID、四物件数量、A／B／C／D 格位与 Canvas、
  Image 1／2 路径／SHA／职责、已确认物件隐喻与综合色方向、完整背景板拓扑、
  runtime／安全区／三切片合同、动态排除和无共享 Raid 外框。
- 允许自主修复：固定格内 occupancy、低频手裁轮廓、磨损／染色／烟熏、liner
  对比、暗铜克制度、四变体端帽细节与绿幕隔离；可以按门禁选择 edit 或从固定
  Image 1／2 regenerate。
- 必须重新授权：新增或减少对象／状态／参考图，改变格位／Canvas／物件身份／
  配色／共享外框结论／runtime 几何／完整背景板拓扑，跨循环或跨段复用像素，
  把 Party／RaidMarker／Group Label 加入本批，或允许动态内容烘焙。
- 预算：最多 `5` 次实际 ImageGen；只有返回图或 provider generation 证据才
  计数。无图且无生成证据的流程错误单列，不占额度；内部通过即停，第五次仍
  有客观失败则 `candidate-rejected / repair-budget-exhausted`。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-RAID-A1 V1 final` / `1c9f021` | generate | session `019ff4da-2586-7cc1-8174-8de62fab3f64`／result `ig_08eef8f9236c6505016a7c1f562d3081919a559bfb4db7deb9` | raw `88c8b1a0…7152` | 美术一致性：连续编绳／压纹边、规则圆角与家具皮具感；其次四格 ratio／isolation 失败 | 保留四格、实体背景板、深胡桃综合色、左上暖光与 A/B/C/D 身份；`.r1` 同时修正手裁边和绝对 bbox | internal-fail |
| 2/5 | `UF-RAID-A1 V1 final.r1` / `a741f91` | edit | session `019ff4e5-8c60-7fb2-a18f-49dda781d752`／result `ig_071317d2c8000f24016a7c22463e648191a391e53f1306efca` | raw `6e2b9686…8696` | 同一美术失败持续：连续压纹边、规则圆角、均匀皮纹；ratio／isolation 仍失败 | 停止沿用像素；`.r2` 从固定 Image 1／2 regenerate，保留合同但重建材料／轮廓 | internal-fail |
| 3/5 | `UF-RAID-A1 V1 final.r2` / pending repair commit | regenerate | — | — | — | attempt 3 不上传 Image 3 | repair-prepared |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 1 | `UF-RAID-A1 V1 final.r1` / `a741f91` | `019ff4e5…d752` | provider 图已生成并复制；child 后续使用无 Pillow 的系统 Python 做尺寸确认失败 | 不重生；以 `sips` 确认 `1536×1024 RGB` 并继续审查 | 不额外占生图额度；attempt 2 仍只计一次 |

### Attempt 1 执行与内部审查

- 固定执行器：`@openai/codex@0.143.0`；完整 user block 已确认未截断，没有
  wrapper 递归；Image 1／2 SHA 与授权一致，attempt 1 无 Image 3。
- session：`019ff4da-2586-7cc1-8174-8de62fab3f64`；provider result：
  `ig_08eef8f9236c6505016a7c1f562d3081919a559bfb4db7deb9`；执行器未报告 revised
  prompt。模型缓存 `base_instructions` 日志为不阻塞 warning，生成已真实完成，
  因而本次计 `1/5`，不登记为流程错误。
- raw：`1536×1024 RGB`，SHA-256
  `88c8b1a08c053aebf91a37416cbdbfb8bd28d53817d8d6fb7a42136886287152`。
- reviewer：`tools/review_unitframes_raid_candidate_v1.py`；技术报告
  `generated/unitframes/raid/A1/V1/attempt-01/review/technical-report.json`，SHA
  `e3b15de7…2e9f`；contact SHA `b7db933a…b94f`；40 人真实排版 SHA
  `2215fb21…e0ff`。后者使用真实 `40×`、成员 `74×37`、Button `70×33` 与
  `767×159` 包络；因本稿 ratio 失败，只能使用等比留白的诊断 runtime，不能
  冒充 candidate/source。

审查顺序与结论：

1. 范围／语义：通过。恰好四格、每格一个连通实体背景板、无动态文字／条／
   图标烘焙；A 缺口＋右下补针、B 暗铆钉、C 左补片、D 右暗铜修补均可辨认。
2. 物理／层序：通过。修补贴在皮革上，liner 是外壳内部底层，四物件均为正面
   正交视角；没有共享 Raid Panel。
3. 第一失败门禁——美术一致性：四件均形成连续隆起的编绳／压纹滚边、近完美
   等半径圆角和均匀家具皮革表面；D 的金属片与 C 的补片过大。它们违背
   “旧马鞍／盾带手裁、长段裸边、非工业重复”的锁定条款。
4. 组件／装配次级失败：A/B/C/D bbox 分别 `674×275`、`668×276`、
   `670×280`、`668×279`；ratio error `22.55%/21.01%/19.64%/19.71%`，
   anisotropy `18.40%/17.37%/16.42%/16.47%`，均超过 `8%`。四格 padding
   分别 `[70,186,24,51]`、`[29,186,71,50]`、`[69,51,29,181]`、
   `[29,51,71,182]`，均至少一边低于 `64/80/64/80`。
5. 技术通过项：四格各 `1` 个 Alpha32 连通体，visible green spill `0`，raw
   尺寸／模式正确；这些通过项不能挽救美术与比例失败。

- 内部结论：`internal-fail / repair-prepared`；不得交用户接受、不得写
  `assets/source/`、不得导出 runtime。下一步使用同段紧邻 attempt 1 完整 sheet
  作 Image 3，执行下列完整 `.r1` 有界 edit。

### `UF-RAID-A1 V1 final.r1` — attempt 2 自包含手裁边与绝对格位修复

```text
Edit Image 3 into one corrected production sheet containing exactly four
complete empty raid-member background shells for Turtle WoW 1.18.1 and a
Vanilla-era pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly
uniform pure #00FF00 background. This is a bounded edit of the immediately
preceding full sheet from this same production loop. Do not create a gameplay
screenshot, raid panel, concept board, labels, letters, numbers, grid lines,
guides, a fifth object or separate loose parts.

Preserve only Image 3's successful structure and identity: exactly four cells;
one front-facing orthographic solid background plate in each cell; a dark
walnut leather edge around one quiet opaque soot-brown liner; one connected
physical mass per plate; consistent warm upper-left light; low saturation; and
the recognizable A/B/C/D repair identities. Do not preserve Image 3's current
object positions, panoramic 2.39-to-2.45 ratios, continuous raised braided
border, embossed piping, equal-radius rounded corners, uniform upholstery
finish or oversized repair hardware.

Use the same fixed two-by-two cells: A x0..767/y0..511, B
x768..1535/y0..511, C x0..767/y512..1023, and D
x768..1535/y512..1023. Redraw and recenter each complete visible plate into its
absolute target bbox, exactly 592 by 296 pixels: A x88..679/y108..403, B
x856..1447/y108..403, C x88..679/y620..915, and D
x856..1447/y620..915. Each object must become visibly less panoramic and
slightly taller than Image 3: reduce its current width by about 76 to 82 pixels
and increase its current height by about 16 to 21 pixels. Do not merely crop an
existing wide plate. Keep at least 64 pure-green pixels left and right and at
least 80 pure-green pixels above and below every object inside its own cell.
Nothing may touch or cross a cell edge, cast an external shadow, or exist as a
detached fleck.

Each object remains one complete solid opaque background plate, not a hollow
ring. Pure green exists only outside the outer silhouette; there is no green
opening, transparent hole, internal cutout, second slot or detached repair.
Fill the whole interior with the same quiet matte soot-brown liner, because
live Health and Power bars will be drawn above it. Keep the liner continuous,
low contrast and free of emblems, hard scratches, bar-like gradients or focal
marks.

Replace the current industrial perimeter on all four plates. Remove every
continuous rope, braid, lacing, pebble emboss, raised piping and machine-rolled
lip. Remove the perfect repeated rounded-rectangle silhouette and equal corner
radii. Redraw a thin attached leather clamp edge about 12 to 20 source pixels
wide: long mostly bare stretches, slow unequal hand-cut thickness changes,
four differently worn corner joins, a few matte broken highlights and no
repeating rhythm. The edge may be subtly blunt or chipped but must not become
randomly wavy. It must read as discarded saddle, shield-strap or tent-binding
leather cut and repaired in an Azeroth expedition camp, not upholstery,
furniture trim, a luxury label or an industrial product.

The final 592 by 296 source for each role will be divided horizontally into a
48-pixel left cap, quiet 496-pixel centre and 48-pixel right cap, then reduced
to one 74 by 37 runtime texture. Keep every unique identity feature completely
inside those fixed end caps. In A, keep one blunt upper-left notch only inside
x88..135 and two short unequal lower-right stitches only inside x632..679. In
B, keep one small off-centre dark rivet and its characteristic extra rub only
inside x1400..1447; the long lower centre keeps only the same quiet family wear
as the other variants. In C, shrink the attached left leather patch and its
unequal stitches entirely into x88..135; use no bright metal. In D, shrink the
skewed oxidized-brass repair entirely into x1400..1447 and keep the small
lower-left split entirely inside x856..903. No detail may cross a cap boundary.
No variant may be brighter, thicker or more ornate than another.

Keep the centre of each plate deliberately uneventful. Use broad low-frequency
smoke and dye changes only. Do not place a unique scratch, seam, stitch,
fastener, patch, hotspot or ornament across the central 496-pixel stretch band.
At 74 by 37, live bars, names, auras and status icons must remain dominant and
the perimeter must read as only a thin rough support.

Paint with circa-2004 Vanilla World of Warcraft UI language: broad chunky
hand-painted value blocks, deliberate low-resolution readability, matte
material thickness and restrained warm contrast. Use deep soot-dark walnut,
smoke brown and only sparse tarnished umber brass under warm upper-left light.
Ruggedness comes from unequal cut pressure, uneven dye, smoke, mud rub, missing
repair holes and believable local tension. Avoid random noise, photo texture,
uniform pores, orange leather, polished metal and glossy modern bevels.

The written requirements outrank all three input images. Use Image 1 only for
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and material thickness; ignore its screen, text,
portraits, book, pages, spine, tabs, wax seals and full-frame geometry. Use
Image 2 only for deep-walnut depth, warm upper-left light, contact shadow,
restrained dull-brass response, rough wear and hand-made error; ignore pages,
spine, columns, dragons, broad book construction and large metal ornaments.
Use Image 3 only for its same-loop four-cell topology, solid plate anatomy,
deep-walnut palette, light direction and A/B/C/D identity anchors. Explicitly
discard its current bbox positions, wide ratios, furniture-like rounded form,
continuous embossed border and oversized C/D attachments. Do not use the
geometric simulation, accepted bar textures, rejected primary unit-frame
pixels or any unlisted image.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, black glass, glossy meter, neon, full-frame glow, black-iron shrine,
spikes, skulls, horns, faction or class emblems, gems, runes, photoreal
antiques, regular lacing, equal-distance stitches, symmetric rivets, pebble
embossing, orange piping, upholstery and precision industrial geometry. Draw
no portrait, Health or Power fill, name, number, class or reaction colour,
aura, buff, debuff, raid marker, leader or loot icon, resurrection icon,
combat, aggro, hover, button highlight or click feedback.

Before returning, verify visibly: exactly four and only four connected solid
plates; fixed A/B/C/D cells; each plate exactly 592 by 296 in its declared
absolute bbox; at least 64/80/64/80 pure-green cell padding; no detached fleck
or internal green hole; thin 12-to-20-pixel hand-cut perimeter; no continuous
braid, embossed piping or equal rounded corners; A/B/C/D identity entirely
inside fixed 48-pixel end caps; quiet stretchable centres; identical scale,
liner area, darkness and light; rough low-saturation Vanilla craft; and no
baked live content.
```

### Attempt 2 执行与内部审查

- 固定执行器 user block 完整；Image 1／2 与授权 SHA 一致，Image 3 是同循环
  attempt 1 完整 raw `88c8b1a0…7152`，未上传其他像素。session
  `019ff4e5-8c60-7fb2-a18f-49dda781d752`；provider result
  `ig_071317d2c8000f24016a7c22463e648191a391e53f1306efca`；未报告 revised
  prompt。raw `1536×1024 RGB`，SHA `6e2b9686…8696`。
- child 在生成／复制完成后用缺少 Pillow 的系统 Python 做尺寸确认失败，随后
  以 `sips` 成功确认。它是流程错误 `1`，没有第二张 provider 图；attempt 2
  仍只计一次实际 ImageGen。
- 报告：`generated/unitframes/raid/A1/V1/attempt-02/review/technical-report.json`，
  SHA `7c4a475b…c7d2`；contact SHA `afd38756…5e2f`；40 人真实排版 SHA
  `8862a384…d972`。
- 范围／物理仍通过：四个完整实体背景板、四身份、动态排除、正交视角和 liner
  层序未破坏。
- 第一失败仍是美术一致性：模型把连续压纹滚边、等半径圆角和均匀细碎皮纹
  原样保留，只降低了局部高光；A／C／D 端部附件依旧像规则家具修补件。相同
  首要失败连续出现，必须改变策略，不能继续拿本稿 edit。
- 次级几何：A/B/C/D bbox `679×287`、`675×288`、`678×290`、`675×289`；
  ratio error `18.29%/17.19%/16.90%/16.78%`，anisotropy
  `15.46%/14.67%/14.45%/14.37%`；padding `[65,189,24,36]`、
  `[29,188,64,36]`、`[63,60,27,162]`、`[28,60,65,163]`。虽比 attempt 1
  略收敛，仍不可执行授权 bbox normalize。
- 内部结论：`internal-fail / repair-prepared`。attempt 3 改为只用固定 Image 1／2
  从零 regenerate；不上传 attempt 2 或任何其他 Image 3，以摆脱连续工业滚边。

### `UF-RAID-A1 V1 final.r2` — attempt 3 自包含从零重建

```text
Create from scratch one production sheet containing exactly four complete
empty raid-member background shells for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly uniform pure
#00FF00 background. This attempt deliberately regenerates from the two fixed
visual references only. Do not reconstruct, imitate or retain any previous
raid-shell attempt. Do not create a gameplay screenshot, assembled raid panel,
concept board, title, label, letter, number, grid line, guide, fifth object or
loose component.

Use a strict two-by-two cell layout. Cell A is x0..767/y0..511. Cell B is
x768..1535/y0..511. Cell C is x0..767/y512..1023. Cell D is
x768..1535/y512..1023. In each cell draw exactly one complete front-facing
orthographic solid plate. Centre it with equal green bands on opposing sides.
Each plate is exactly 592 pixels wide and 296 pixels high, visibly a true 2:1
rectangle like two equal squares placed side by side, never a panoramic strip.
Use these absolute bboxes: A x88..679/y108..403; B
x856..1447/y108..403; C x88..679/y620..915; D
x856..1447/y620..915. That means each cell keeps about 88 pure-green pixels at
both left and right and about 108 pure-green pixels at top and bottom. Do not
expand a plate to fill most of its cell. Nothing touches or crosses a cell
edge, casts an outside shadow or appears as a detached fleck.

Each object is one solid opaque raid-row background plate: one quiet soot-brown
liner filling the complete interior, held by a very thin attached raw-hide
clamp edge. It is not a hollow frame, separate border kit, carved plaque,
furniture cushion or picture frame. Pure green occurs only outside the outer
silhouette. There is no internal green hole, transparent opening, second slot,
raised inset panel, horizontal divider or fake StatusBar. The liner is matte,
continuous, low contrast and nearly featureless because live Health, Power,
names, auras and state icons will cover it.

Make the perimeter fundamentally different from industrial leather goods. It
is the exposed hand-cut rim of one salvaged leather backing, only 12 to 20
source pixels thick, not an added cord or moulding. Use mostly flat, blunt,
near-square corner joins with four unequal wear patterns. Long sections are
bare and visually quiet. A few broken matte edge highlights may appear, but no
highlight continues around a corner and no two sides share a repeating rhythm.
Show slow hand-cut thickness variation, tiny nicks and pressure wear without
making a wavy cartoon outline. Draw absolutely no continuous piping, rope,
braid, lacing, rolled lip, embossed bead, pebble border, machine seam, regular
stitch track, perfect rounded rectangle or equal corner radius.

The final 592 by 296 plate becomes one 74 by 37 runtime texture and supports a
48/496/48 horizontal source split, equal to 6/62/6 at runtime. All unique
repair anatomy stays inside a fixed 48-pixel end cap. The central 496-pixel
band has only broad low-frequency soot and dye variation, with no unique
scratch, seam, stitch, patch, rivet, hotspot or ornament. Height is fixed and
will never be stretched.

All four objects have identical outer dimensions, liner area, darkness,
material thickness and warm upper-left light. Differences are sparse and
low-frequency. A has one blunt upper-left cut notch in its left cap and only
two short unequal lower-right repair stitches in its right cap. B has one
small off-centre dark rivet in its right cap and a slightly more rubbed patch
of raw leather at that same end; do not extend wear across the centre. C has
one very short attached leather repair within its left cap, held by two or
three irregular missing-hole stitches, and no bright metal. D has one small
skewed cracked oxidized-brass repair within its right cap and one tiny split
within its left cap. A repair occupies less than half of its cap height. No
variant is brighter, thicker, rounder or more ornate than another.

The world object is a compact expedition muster slip made from discarded
saddle leather, a shield strap or a tent binding, trimmed by hand in an
Azeroth camp. It is not a miniature Player frame, book page, bookmark, scroll,
luxury leather tag or modern card. Paint in circa-2004 Vanilla World of
Warcraft UI language: broad chunky hand-painted value blocks, deliberate
low-resolution readability, matte physical depth and restrained warm
contrast. Use deep soot-dark walnut, smoke brown and only tiny tarnished umber
brass accents. Ruggedness comes from unequal cut pressure, uneven dye, smoke,
mud rub, missing stitch holes and local repair tension—not uniform pores,
procedural grain, photo texture or random noise.

The written requirements outrank both input images. Use Image 1 only for
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and believable material thickness. Ignore its screen
composition, text, portraits, book, pages, spine, tabs, wax seals and complete
frame geometry. Use Image 2 only for deep-walnut depth, warm upper-left light,
contact shadow, restrained dull-brass response, rough wear and hand-made
error. Ignore its pages, spine, columns, dragons, broad book construction and
large metal ornaments. Do not copy their book shapes or pixels. No geometric
simulation, bar texture, rejected unit-frame candidate or previous raid-shell
image is an input or visual source for this attempt.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, transparent black glass, glossy meter, neon, full-frame glow,
black-iron shrine, spikes, skulls, horns, faction or class emblems, gems,
runes, photoreal antiques, upholstery, furniture trim, industrial moulding,
continuous rope, braid, lacing, piping, rolled lips, equal-distance stitches,
symmetric rivets, pebble embossing, orange leather and precision geometry.
Draw no portrait, Health or Power fill, name, number, class or reaction
colour, aura, buff, debuff, raid marker, leader or loot icon, resurrection
icon, combat, aggro, hover, button highlight or click feedback.

Before returning, verify visibly: one 1536 by 1024 RGB sheet; exactly four and
only four solid connected plates; one true 592 by 296, 2:1 plate centred in
each fixed cell; roughly equal 88-pixel left/right and 108-pixel top/bottom
green bands; no detached flecks or internal holes; one flat 12-to-20-pixel
hand-cut raw-hide rim rather than an added border; blunt unequal corners; zero
continuous piping, braid, embossing or regular seam; four sparse identities
inside fixed end caps; quiet stretchable centres; identical weight and light;
rough low-saturation Vanilla craft; and no baked live content.
```

### Attempt 3 执行与内部审查

- 固定执行器 user block 完整；仅上传授权 Image 1／2，SHA 均一致；按修复策略
  未上传 Image 3。session `019ff4eb-de51-7fe1-98cb-570447d68de3`；provider
  result `ig_0ddc4352582d4a90016a7c23de41148191a5febff072277aa0`；raw
  `1536×1024 RGB`，SHA `41c9d561…e760`。
- 报告：`generated/unitframes/raid/A1/V1/attempt-03/review/technical-report.json`，
  SHA `759240e7…f5df`；contact SHA `3d9345ff…264b`；40 人真实排版 SHA
  `daac9c12…96ce`。
- 成功项：从零重建消除了前两稿的家具式圆角和编绳滚边；四件都成为同族的
  深胡桃、低饱和、实体外壳，A/B/C/D 身份可辨；四格 ratio error
  `3.92%/3.92%/3.63%/3.47%`、anisotropy 同值，均已低于 `8%`；各格仅
  `1` 个 Alpha32 连通体且 green spill `0`。
- 第一失败门禁——真实排版美术：外沿仍形成几乎连续的暖色锯齿亮线，内衬有
  均匀重复的细碎云纹；D 的亮黄修补件占右端过多。缩到 `74×37` 后，边线和
  D 补片仍会先于动态生命／法力内容抢焦点，不符合聊天框基准的克制粗粝感。
- 装配失败：A/B/C/D bbox `638×332`、`638×332`、`638×331`、`639×331`；
  A/B 的底边留白仅 `55`，C/D 的顶边留白仅 `56`，而 A/C 右侧仅 `39`、
  B/D 左侧仅 `39/38`。四件都被吸向整张 sheet 的中央十字；没有满足每格
  `64/80/64/80` 的最低留白，故不得执行 bbox normalize。
- 内部结论：`internal-fail / repair-prepared`。attempt 4 使用同段紧邻 attempt 3
  完整 raw `41c9d561…e760` 作为 Image 3；保留已经成功的粗粝实体与身份，只
  做格位收缩／外移、亮边中断、内衬降频和 D 补片收敛。

### `UF-RAID-A1 V1 final.r3` — attempt 4 自包含格位与低频材质修复

```text
Edit Image 3 into one corrected production sheet containing exactly four
complete empty raid-member background shells for Turtle WoW 1.18.1 and a
Vanilla-era pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly
uniform pure #00FF00 background. This is a bounded edit of the immediately
preceding complete sheet from this same production loop. Do not create a
gameplay screenshot, raid panel, concept board, label, letter, number, grid,
guide, fifth object or separate loose component.

Preserve Image 3's successful art direction and topology: exactly four fixed
cells; one front-facing orthographic connected solid plate per cell; deep
soot-dark walnut leather; one quiet opaque liner; blunt unequal hand-cut
corners; sparse A/B/C/D end-cap identities; restrained warm upper-left light;
low saturation; and no baked live content. Do not replace these objects with
rounded cards, furniture trim, book pages, metal frames or a new metaphor.

Correct Image 3's sheet-centre attraction. The current plates are roughly 638
by 331 or 332 and all lean toward the central cross. Reduce every whole plate
to exactly 592 by 296 without cropping it, and move it away from the global
sheet centre into the exact centred bbox of its own 768 by 512 cell. A must be
x88..679/y108..403. B must be x856..1447/y108..403. C must be
x88..679/y620..915. D must be x856..1447/y620..915. Relative to Image 3,
shrink each object about 7 percent horizontally and 11 percent vertically;
move A about 26 pixels left and 35 pixels up, B 26 pixels right and 35 pixels
up, C 26 pixels left and 35 pixels down, and D 27 pixels right and 35 pixels
down. Keep at least 64 pure-green pixels left and right and at least 80
pure-green pixels above and below each object inside its cell. Make the
vertical green gutter between the two columns at least 128 pixels and the
horizontal green gutter between the two rows at least 160 pixels. Do not add
green inside an object, detach an end repair, cast an outside shadow or cross
a cell edge.

Each plate remains one complete opaque raid-row backing, not a hollow frame.
Pure green occurs only beyond the outer silhouette. Keep the whole interior
filled by one matte soot-brown liner because live Health, Power, names, auras
and state icons will be drawn above it. Do not draw a second inset panel,
divider, fake StatusBar, transparent opening or green hole.

Repair the current perimeter without changing its physical construction. The
attached raw-hide rim stays thin, flat and roughly 12 to 20 source pixels, but
remove the nearly unbroken amber jagged highlight that now traces all four
sides. Darken the rim toward soot walnut. Leave long matte stretches and only
four or five sparse broken dull-umber edge catches per object; no catch may
continue around a corner, and no pair may repeat at equal spacing. Flatten any
remaining beaded or craggy rhythm. Preserve slow unequal cut thickness, tiny
nicks and four differently worn blunt joins, but do not make a noisy sawtooth,
continuous piping, braid, rope, embossed lip or regular seam.

Repair the liner texture. Remove Image 3's evenly distributed small cloudy
rosettes, repeated mottling and procedural-looking grain. Replace them with
only two or three very broad, low-frequency, hand-painted soot or dye value
fields per plate, each roughly 80 to 180 source pixels across, with soft lost
edges and less than subtle contrast. The centre must look quiet at 74 by 37:
no repeated motif, uniform pores, pebble grain, sharp scratch, seam, stitch,
rivet, hotspot, emblem or ornament across its central 496-pixel stretch band.

The normalized 592 by 296 source will use a 48/496/48 horizontal split and
become one 74 by 37 runtime texture. Keep all unique anatomy completely inside
the 48-pixel end caps after the object is recentered. A keeps one small blunt
upper-left notch in its left cap and two short unequal lower-right stitches in
its right cap. B keeps one tiny off-centre dark rivet and a modest raw rub only
in its right cap. C keeps one short dark attached leather repair and irregular
missing-hole stitches only in its left cap, with no bright metal. D keeps one
small skewed cracked oxidized-brass repair only in its right cap and one tiny
split only in its left cap. Reduce D's current yellow patch to less than half
the cap width and less than half its height; darken it to tarnished umber so it
never becomes the brightest object. No unique feature may cross a cap boundary.

All four plates retain identical dimensions, liner area, darkness, material
thickness, scale and light. Paint in circa-2004 Vanilla World of Warcraft UI
language: broad chunky hand-painted value blocks, deliberate low-resolution
readability, matte depth and restrained warm contrast. Ruggedness comes from
unequal cut pressure, uneven dye, smoke, mud rub, missing stitch holes and
local repair tension—not precision geometry, random noise, photo texture,
uniform pores, orange leather, polished metal or glossy modern bevels.

The written requirements outrank all inputs. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, restrained warm
contrast and material thickness; ignore its screen, text, portraits, book,
pages, spine, tabs, wax seals and full-frame geometry. Use Image 2 only for
deep-walnut depth, warm upper-left light, contact shadow, restrained dull-brass
response, rough wear and hand-made error; ignore pages, spine, columns,
dragons, broad book construction and large metal ornaments. Use Image 3 only
for its same-loop four-cell topology, solid plate construction, successful
dark rough craft direction and A/B/C/D identity. Explicitly discard Image 3's
current oversized and centre-biased bboxes, continuous amber outline, repeated
cloudy liner grain and oversized bright D repair. No other image or prior
candidate is a source.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, black glass, glossy meter, neon, glow, black-iron shrine, spikes,
skulls, horns, faction or class emblems, gems, runes, photoreal antiques,
upholstery, furniture trim, industrial moulding, continuous rope, braid,
lacing, piping, rolled lip, equal-distance stitches, symmetric rivets, pebble
embossing and orange edge light. Draw no portrait, Health or Power fill, name,
number, class or reaction colour, aura, buff, debuff, raid marker, leader or
loot icon, resurrection icon, combat, aggro, hover, highlight or click state.

Before returning, verify visibly: exactly four and only four solid connected
plates; fixed A/B/C/D cells; every complete plate centred at exactly 592 by 296
with at least 64/80/64/80 pure-green cell padding; at least 128 green pixels
between columns and 160 between rows; no detached fleck or internal green hole;
thin mostly dark raw-hide rims with broken rather than continuous highlights;
no repeated liner grain; identities contained by fixed end caps; D patch small
and dull; quiet stretchable centres; matched visual weight; rough low-saturation
Vanilla craft; and no baked live content.
```

### Attempt 4 执行与内部审查

- 固定执行器 user block 完整；Image 1／2 的授权 SHA 一致，Image 3 为同循环
  紧邻 attempt 3 完整 raw `41c9d561…e760`，未上传其他像素。session
  `019ff4f2-9d85-7773-bdc8-c60f33f1e3bb`；provider result
  `ig_068f201333e6d4c6016a7c2599bd908191b9fb063298bc5793`；raw
  `1536×1024 RGB`，SHA `ab0a389f…fe44`。
- 报告：`generated/unitframes/raid/A1/V1/attempt-04/review/technical-report.json`，
  SHA `f2f377c6…5022`；contact SHA `7b778d2f…b946`；40 人真实排版 SHA
  `c3c442b4…27c3`。
- 第一失败门禁——美术回退：本稿把 attempt 3 的低频手绘表面改成了全域重复
  压花皮纹、连续等距边缝和规则商品皮具滚边；A/C 系带与 D 金属补片也重新
  变得工整。即使缩小后中心纹理被滤掉，来源像素仍违反全局基准和生产资产
  门禁，不能因运行时暂时不明显而放行。
- 装配仍失败：A/B/C/D bbox `632×323`、`628×323`、`631×327`、`630×327`，
  ratio error 与 anisotropy 均已小于 `4%`；但内侧水平 padding 仅
  `40/43/42/42`，A/B 底部仅 `57`，C/D 顶部仅 `56`。模型仍把四件吸向
  全局中央十字，未满足 `64/80/64/80`。
- 通过项：四格各一个 Alpha32 连通实体、green spill `0`、模式和尺寸正确；
  这些通过项不能挽救美术与 padding 失败。
- 内部结论：`internal-fail / repair-prepared`。attempt 5 是最后一次授权调用。
  不上传退化的 attempt 4 作为 Image 3；改用固定 Image 1／2 从零生成。为避免
  再次要求模型做不可靠的像素级终态定位，原始 sheet 使用每格 `440×220` 的
  同比例安全对象和宽绿幕护城河；通过门禁后才用已授权 bbox normalize 等比
  放大为 `592×296`，不做创意修补。

### `UF-RAID-A1 V1 final.r4` — attempt 5 自包含安全源与原始手裁重建

```text
Create from scratch one final production sheet containing exactly four
complete empty raid-member background shells for Turtle WoW 1.18.1 and a
Vanilla-era pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly
uniform pure #00FF00 background. This is a fresh regeneration from the two
fixed art references only. Do not reconstruct, imitate or retain any previous
raid-shell attempt. Do not create a gameplay screenshot, assembled raid
panel, concept board, title, label, letter, number, grid, guide, fifth object
or loose component.

The provider sheet intentionally contains generous extraction safety space.
Use four fixed 768 by 512 cells: A x0..767/y0..511, B
x768..1535/y0..511, C x0..767/y512..1023, and D
x768..1535/y512..1023. In each cell draw exactly one small complete
front-facing orthographic solid plate, exactly 440 pixels wide by 220 pixels
high, a true 2:1 ratio. Use these raw visible bboxes: A
x164..603/y146..365, B x932..1371/y146..365, C
x164..603/y658..877, and D x932..1371/y658..877. Each raw object therefore
occupies only about 57 percent of its cell width and 43 percent of its height,
with about 164 pure-green pixels at both sides and 146 above and below. The
central vertical green gutter is about 328 pixels and the central horizontal
green gutter about 292 pixels. The objects must look deliberately small on the
sheet. Nothing may lean toward the global centre, touch a cell boundary, cast
an external shadow or appear as a detached fleck.

After chroma key, each accepted 440 by 220 raw object will be enlarged once,
uniformly and non-creatively, to the authorized 592 by 296 normalized source;
both are exactly 2:1. This is why the broad green moat and exact raw ratio are
more important than filling the cell. Do not pre-enlarge the objects. Do not
use a panoramic ratio. Do not draw beyond the declared raw bbox.

Each object is one connected opaque expedition raid-row backing: one almost
flat soot-brown liner filling the complete interior, held by the thin exposed
hand-cut edge of the same salvaged rawhide. It is not a hollow frame, separate
border kit, carved plaque, upholstered cushion, book page or picture frame.
Pure green exists only beyond the outer silhouette. There is no internal
green, transparent opening, second inset panel, horizontal divider, fake
StatusBar or detached repair.

Treat these as deliberately coarse 2004 game-interface paintings enlarged for
production, not as detailed leather products. The interior liner is nearly
featureless: only two or three broad hand-painted soot, smoke or uneven-dye
value fields, each roughly 80 to 160 raw pixels across, with soft lost edges
and extremely low contrast. Draw no recognizable leather grain. Absolutely no
repeated curls, rosettes, floral emboss, tooling, pores, pebbles, scales,
crosshatch, procedural texture, fine scratches, seam, stitch track, emblem or
ornament may cover the centre. When reduced to 74 by 37, live bars, names and
states must be much stronger than the backing.

The attached rawhide rim is only about 8 to 14 raw pixels thick so that it
becomes roughly 11 to 19 pixels after normalization. It is a matte, mostly
soot-dark exposed cut edge, not a separately attached decorative strip. Use
long bare stretches, four blunt corners with visibly different wear, slow
unequal thickness and a few isolated dull-umber scuffs. No highlight may run
around a corner or continue along a whole side. Draw no continuous bright
outline, gold line, piping, rope, braid, lacing, rolled lip, embossed bead,
regular seam, equal-distance stitch row, repeated notch rhythm, perfect
rounded rectangle or industrial edge moulding. Roughness is sparse and
low-frequency, like a saddle offcut trimmed with a field knife, not a noisy
sawtooth or luxury luggage edge.

The normalized source uses a 48/496/48 horizontal split, equivalent to about
36/368/36 in this smaller raw object. Keep every unique role feature entirely
inside the outermost 34 raw pixels so later normalization cannot push it into
the stretchable centre. A has one small blunt upper-left cut notch within its
left end and two short unequal lower-right repair stitches within its right
end. B has one tiny off-centre dark rivet and one modest raw rub only at its
right end. C has one short dark attached leather repair with two or three
irregular missing-hole stitches only at its left end, and no bright metal. D
has one tiny skewed cracked oxidized-brass repair only at its right end and one
tiny split only at its left end. The D repair occupies less than 18 raw pixels
in width and less than 60 raw pixels in height, is dark tarnished umber rather
than yellow, and is never the brightest object. No variant receives a large
patch, decorative corner plate or centre detail.

All four objects have the same raw dimensions, liner area, darkness, material
thickness, scale and restrained warm upper-left light. Differences are sparse
field repairs, not four different product designs. Use deep soot-dark walnut,
smoke brown, dried mud and only tiny tarnished umber brass. Paint with the
circa-2004 Vanilla World of Warcraft interface language seen in the references:
broad chunky brush decisions, deliberate low-resolution readability, matte
physical weight, simple shadow groups and hand-made error. Let irregularity
come from unequal cut pressure, uneven dye, soot, mud rub, missing repair holes
and local tension—not micro-detail, photographic realism, random noise, glossy
bevels, polished metal, orange leather or precision geometry.

The written requirements outrank both input images. Use Image 1 only for
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast, material thickness and coarse silhouette decisions;
ignore its screen composition, text, portraits, book, pages, spine, tabs, wax
seals and complete frame geometry. Use Image 2 only for deep-walnut depth,
warm upper-left light, restrained dull-brass response, rough wear, matte
contact depth and hand-made error; ignore its pages, spine, columns, dragons,
broad book construction and large metal ornaments. Do not copy a book shape or
any literal source object. No prior raid candidate, geometric simulation,
accepted bar texture or primary unit-frame pixel is an input.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, black glass, glossy meter, neon, glow, black-iron shrine, spikes,
skulls, horns, faction or class emblems, gems, runes, photoreal antiques,
upholstery, furniture trim, industrial moulding, decorative tooling,
continuous rope, braid, lacing, piping, rolled lip, equal-distance stitches,
symmetric rivets, pebble embossing and orange edge light. Draw no portrait,
Health or Power fill, name, number, class or reaction colour, aura, buff,
debuff, raid marker, leader or loot icon, resurrection icon, combat, aggro,
hover, highlight or click feedback.

Before returning, verify visibly: one 1536 by 1024 RGB sheet; exactly four and
only four connected solid raw plates; one deliberately small exact 440 by 220,
2:1 object centred in each fixed cell; about 164/146/164/146 pure-green cell
padding and very wide central green gutters; no detached fleck or internal
hole; almost-flat liners with no repeated surface pattern; thin mostly dark
hand-cut rims with broken sparse scuffs and no continuous decorated border;
four restrained identities wholly inside the outermost 34 raw pixels; D repair
tiny and dull; matched visual weight; rough low-saturation Vanilla craft; and
no baked live content.
```

### Attempt 5 执行与终态审查

- 固定执行器 user block 完整；只上传授权 Image 1／2，SHA 均一致；按已提交的
  最终策略没有 Image 3。session `019ff4f8-5010-7df0-9ee0-8a6627b4c507`；
  provider result `ig_0f804440d375108d016a7c270efef0819181aa46c5724273d9`；raw
  `1536×1024 RGB`，SHA `684e3f5e…96c1`。
- child 已用 `file` 确认 raw 尺寸／模式，随后又用缺少 Pillow 的系统 Python
  做重复确认而失败；没有第二张 provider 输出。这是流程错误 `2`，attempt 5
  仍只计一次实际 ImageGen。
- 报告：`generated/unitframes/raid/A1/V1/attempt-05/review/technical-report.json`，
  SHA `5b9393e9…09a0`；contact SHA `8f294130…99f`；40 人真实排版诊断 SHA
  `566cf542…bac4`。
- 成功项：缩小原始对象的策略终于获得宽安全留白；四格 padding 分别
  `[216,196,167,195]`、`[169,196,213,195]`、`[216,188,167,203]`、
  `[169,188,213,203]`，远高于门禁。四格各只有一个 Alpha32 连通体，green
  spill `0`；内衬微纹理比 attempt 4 明显降频。
- 第一技术失败：模型把明确的 `440×220 / 2:1` 误画成约 `385–386×121`，
  source ratio `3.181818–3.190083`，ratio error `59.09%–59.50%`，X／Y
  normalize anisotropy `37.14%–37.31%`。合同最多只允许 `8%`，因此禁止把它
  非等比强拉为 `592×296`；真实排版图只能作为诊断，不能代表 runtime。
- 美术也未通过：平坦中心成立，但四边形成连续暖铜多层斜切滚边，角部过于
  对称，整体更像规则金属铭牌；D 端部仍像装饰扣件，而非低调的野战补片。
- 终态结论：`repair-budget-exhausted / candidate-rejected / 5/5`。attempt 3 是
  本循环当前最佳内部视觉参考，但仍有连续亮边、D 补片偏亮，以及四格内侧／
  上下 padding 不足，不能倒退绕过门禁。禁止第六次调用；不得写入
  `assets/source/`、不得导出 runtime、不得修改 addon。下一步只能由用户明确
  选择重开新合同、改变生成架构或授权具体确定性例外。
