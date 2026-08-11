# Unit Frames 主单位框批次 UF-PRIMARY V1

## 元数据

- 模块：`unitframes`
- 组件 ID：`UF.PLAYER.SHELL`、`UF.TARGET.SHELL`、
  `UF.TARGETTARGET.SHELL`、`UF.FOCUS.SHELL`、`UF.BAR.*`、`UF.STATE.*`
- 当前版本：`UF-A1 V1`／`UF-A2 V1`／`UF-B1 V1`
- 子状态：`prompt-authorized`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：`generate`；正式生产已授权，候选接受尚未发生
- 生成前模拟：deterministic-local-geometry；ImageGen `0/0`
- 本地渲染错误：初始模拟 `0`；确认后确定性复跑出现 `1` 次 sandbox 写权限
  错误，使用同一命令获准写入后复跑通过，输出 SHA 未变；不属于 ImageGen。
- 自动修复预算：未来 `UF-A1`／`UF-A2`／`UF-B1` 各最多 `5` 次实际生图，
  最坏合计 `15`；当前 A1 `1/5`、总计 `1/15`
- 流程错误：`1`（A1 `E1`；固定 child 在生成前返回 `No prompt provided`，无
  图片或 provider result，不占实际生图额度）
- 正式生产授权：`2026-08-11`；用户授权 A1→A2→B1 顺序、A1／A2 固定
  Image 1／2、同段紧邻前稿 edit 输入、B1 首次无图、每段最多 `5` 次实际
  ImageGen、最坏 `15` 次、流程错误不占额度、禁止跨段复用，以及合同内的
  固定分区、边缘连通色键、透明 RGB 清零、纵横比误差不超过 `1%` 的等比
  bbox-fit 和真实排版预演。
- 用户授权原文：`确认授权 UF-A1 V1、UF-A2 V1、UF-B1 V1；按 A1→A2→B1
  顺序执行；A1/A2 每次允许上传固定 SHA 的 Image 1/2，首次无 Image 3，仅允许
  同段紧邻前次输出在冻结修复边界内作为 Image 3 edit 输入；B1 首次不上传
  图片，仅允许同段紧邻前次输出作为后续 Image 1 edit 输入；每段最多 5 次实际
  ImageGen 调用，最坏合计 15 次，流程错误不占额度；禁止跨段复用像素；允许
  固定分区拆分、边缘连通色键、透明 RGB 清零、纵横比误差不超过 1% 的等比
  bbox-fit 与真实排版预演。`
- 锁定视觉基准：当前没有 Unit Frames 专属锁定图。
- 次级风格参考：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`：
    只提供香草时代绘制尺度、短黄铜高光、厚轮廓与综合色重；明确忽略其完整
    屏幕布局、圆形头像和单位框示意结构。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`：
    只提供深胡桃材料、左上暖光、手工误差与磨损节奏；明确忽略书页、书脊、
    木柱、龙饰、完整书框与大面积金边。
- Prompt provenance：`docs/GLOBAL_ART_BASELINE.md`、本模块
  `ART_BASELINE.md` 与 `SUBMODULE_ART_BASELINES.md`。

## 美术基准继承

### 权威顺序

1. `docs/GLOBAL_ART_BASELINE.md` 与用户本轮“项目一致、粗犷随性、不太工整”。
2. 本模块 `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md`。
3. `SUBMODULES.md` 的真实对象、几何、动态内容与禁止烘焙合同。
4. 两张 Chat 锁定图只承担上列受限跨模块视觉职责。
5. pfUI 当前媒体只提供 provider 接口与尺寸，不提供现代视觉方向。

### 必须继承的视觉 DNA

- 2004 年香草魔兽二维手绘位图、粗厚可读的低分辨率轮廓；
- 左上暖光、低饱和烟褐／深胡桃／氧化黄铜、短促且断续的高光；
- 不完全平直、不镜像、维修导致的真实不规则，而不是全表面随机噪声；
- 动态内容区安静，装饰只在外缘、端帽、连接和状态边缘。

### 本批组件级转译

- Chat 的“旧书厚重”转译为“手工包边的行军身份牌厚重”，不复制书本物件；
- 玩家／目标采用同族非镜像端帽；紧凑框用减法，不直接缩小大框；
- Focus 的独特识别来自被真实压住的褪色靛蓝猎踪布结；
- HP／Power 保留动态颜色，只增加低频哑光颜料纹。

### 明确不继承

书页、书脊、频道 Tab、蜡封、木柱、龙饰、地图罗盘、任务卷宗、动作条双头
狮鹫，以及 Chat 的完整框架轮廓均不属于本批资源。

### 冲突审计

- Chat 独立资源的大面积金属建筑感与全局“单位框不得成为战争圣龛”冲突：
  以全局和本模块 Prompt 为准，只保留少量断续黄铜。
- Chat 游戏内基准包含圆形头像，而当前 profile `portrait=off`：以真实 provider
  为准，不生成圆形假头像槽。
- 另一台设备位置尚未同步：位置不进入生产合同；只锁定资源尺寸和内外安全区。

## 组件合同

- 逻辑对象：四张独立静态 shell、两条共享 bar fill；Hover／Aggro 由 shell
  Alpha 确定性派生。
- Runtime 尺寸：Player／Target `214×42`；TargetTarget `112×34`；Focus
  `112×39`；Health `64×32`；Power `64×16`。
- 动态安全区：各 shell 中央完整保留对应 `200×25 + 200×4` 或
  `100×20/25 + 100×1` provider 区域。
- 禁止烘焙：文字、数字、颜色语义、头像、单位类型、Buff／Debuff、图标、
  预测治疗、状态标记、点击或配置控件。
- Alpha：正式 shell 真透明；生产阶段使用纯 `#00FF00` 外部色键并在 P4 前
  只做边缘连通色键与透明 RGB 清零。Bar fill 为不透明灰阶。
- 装配：shell 只作鼠标无关覆盖层；bar fill 继续由现有 StatusBar 裁切；状态
  rim 不扩大命中盒。
- 回退：任一媒体缺失时局部恢复 pfUI 当前 backdrop／bar／glow。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-PRIMARY-SIM-V1`
- 真实资源尺寸：四框按 `214×42`、`214×42`、`112×34`、`112×39` 绘制；
  放大审阅图明确标记为 `2×`。
- 代表性动态内容：玩家、敌对目标、目标的目标、Focus；HP／Power、名称、
  数值、四枚目标 Aura、Aggro 与 Hover 状态。
- 邻接 UI：简化战地旧书 Chat 与双头狮鹫动作条，均为非权威几何占位。
- 屏幕位置：因另一设备布局未同步而明确非权威；不进入资源合同。
- 用户需要确认：行军身份牌隐喻、非镜像不规则轮廓、材料层级、Focus 靛蓝
  布结、综合色重、装饰克制度。
- 刻意简化：手绘笔触、皮革／黄铜微纹理、Alpha、切片、接缝和最终状态 rim。
- 禁止用途：模拟图不得成为 source、runtime、裁切／切片或生产输入。

### 本地模拟执行

- 规格：`tools/specs/unitframes_primary_simulation_v1.json`
- 渲染器：`tools/render_unitframes_primary_simulation_v1.py`
- 命令：`conda run -n py312 python tools/render_unitframes_primary_simulation_v1.py`
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- ImageGen：`0/0`
- 初始本地渲染错误：`0`
- 确认后复跑：首次因当前 sandbox 无法写入 ignored `generated/`，返回
  `PermissionError: [Errno 1] Operation not permitted`；随后仅提升同一命令的
  文件写权限重跑成功。scene／zoom／report SHA 均与确认前完全一致，不消耗
  ImageGen 或正式生产流程错误额度。
- 输出与 SHA：
  - scene：
    `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.scene.png`；
    `107b2a71cf29938bf69f8a871c8fcdcae50a561a9b438a929f2a7d684264861c`；
    `1600×900 RGBA`。
  - zoom：
    `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.zoom.png`；
    `d5e76afef373c96a93571ddf9d6a1116e6428a1aec86b53046c8cb73ac1a4e48`；
    `1200×620 RGBA`。
- 实际展示区域合同：
  `tools/specs/unitframes_primary_simulation_display_region_v1.json`，SHA
  `e9546270234d3097bd8b43eacce71c05099888222ed09d8788f19db7d1de5d21`；报告
  `generated/unitframes/primary/simulation/V1/display-region-report.json`，SHA
  `9d22e5e2c50e0c25b7ad0dbb5dfb11562f71b2e097a730285458c281de7b82ad`；
  `4/4 pass`，violations `0`。
- 内部结论：`displayable`。四框使用真实资源尺寸与代表性动态内容；所有文字、
  HP／Power 和 Button hitbox 均落在安全区。玩家／目标端帽非镜像，紧凑框采用
  减法，Focus 布结有实体压接；Target Aggro 与 Focus Hover 均为断续短边。
  几何图不证明正式笔触、微纹理、Alpha 或远端屏幕位置。

### 用户方向结论

- 具体模拟版本：`UF-PRIMARY-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-11`
- 用户原文：`接受 UF-PRIMARY-SIM-V1`
- 确认并写回生产正文的可见条款：
  - 四个框首先读作同一工匠体系、长期携带并手工修补的粗犷行军身份牌，不能
    读作现代卡片、黑铁圣龛、书本缩略件或规整金框。
  - 深胡桃旧皮革是主结构，烟褐内衬承托动态条，氧化黄铜只形成短促、断续、
    不对称的夹片与铆钉；左上暖光和低饱和综合色必须与现有 Chat 同年代。
  - Player 左端修补偏重；Target 右端破损压片偏重；二者从零独立绘制且不得
    镜像。TargetTarget／Focus 用减法形成紧凑身份牌，不能缩放大框。
  - Focus 只使用一段褪色靛蓝猎踪布结识别；布结被皮革夹层和一枚暗铜钉真实
    压住，不漂浮、不发光、不侵入内容走廊。
  - 外轮廓只做低频歪斜，端部、铆钉、缺口与修补位置不等；粗犷来自使用和
    维修逻辑，不是随机噪声。中央动态内容区持续安静。
  - Hover／Aggro 只呈现两三段断续短边响应，不形成整框霓虹；当前无头像
    profile 不生成圆形假头像槽。
- 非确认项：模拟图像素、微纹理、手绘笔触、Alpha、切片、最终贴图接缝及
  另一台设备的屏幕位置。
- 确认失效条件：物件隐喻、材料主次、非镜像结构、Focus 识别件、综合色重或
  与现有 UI 的整合关系发生实质变化。
- 下一门禁：用户看过并明确授权三段最终生产正文；本方向确认不等于正式
  ImageGen 授权。

## 生产正文完整性预检

- 复杂度：三个独立 atlas／state 执行正文。
- 当前结论：`pass`；模拟确认条款、固定参考职责、对象／状态、画布、边界、
  runtime 几何、动态排除、色键和最终自检均已进入各自完整正文。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 身份、范围、对象数量与动态排除 | A1／A2 均固定上下两件空外壳；B1 固定两条无色 donor；文字、头像、图标、状态与颜色语义逐项排除 | pass |
| 图片输入职责与冲突 | A1／A2 逐张定义 Image 1／2 的 inherit／ignore，并声明文字合同优先；B1 明确无图片输入 | pass |
| Canvas、格位、方向、尺度、光照与层序 | 三段均固定画布、上下半区、隔离带、正视二维方向、左上暖光和目标 bbox 比例 | pass |
| 逐对象轮廓、材料与关系 | 非镜像 Player／Target、减法紧凑框、Focus 实体压接布结及两条不同密度颜料纹均单列 | pass |
| 安静区、裁切、拉伸与接缝 | 四壳完整保留真实 bar stack；两 donor 禁止中心焦点、重复接缝和全宽划痕 | pass |
| 美术 DNA、反模式、色键与自检 | 香草手绘、低饱和材料层级、低频维修不规则、纯绿隔离与每段客观末检均明确 | pass |

- `UF-A1`：两个对象、固定两格、同尺寸但非镜像、动态内容排除、色键与
  `214×42` 等比 bbox-fit 已明确。
- `UF-A2`：两个不同高度对象、固定两格、Focus 布结、紧凑减法与各自安全区
  已明确。
- `UF-B1`：两条灰阶不透明 donor、运行时着色、横向拉伸与重复节奏已明确。
- 未知但执行必需的值：无；远端屏幕位置不影响本批资源生成。
- 去冗余结论：保留对象数量、输入职责、动态排除、物理压接、非镜像、
  safe-area、色键与反现代门禁的必要重复；不把模拟历史或情绪描述塞入正文。

## 最终执行正文

状态：`production / authorized 2026-08-11`。以下三段已完整吸收
`UF-PRIMARY-SIM-V1` 的确认结论并获得用户逐项授权；首次调用必须原样执行。
模拟图不得上传或成为生产输入。

### `UF-A1 V1` — Player／Target 大外壳

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Never copy either reference's object geometry. If an image conflicts with this
text, follow this text.

Create one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate horizontal unit-frame shell objects on a perfectly uniform pure
#00FF00 background. The upper 1536 by 512 cell is the Player shell and the
lower 1536 by 512 cell is the Target shell. Draw no other object. Show both as
front-facing orthographic 2D game-UI assets with no scene, camera tilt or
perspective foreshortening. Each shell must remain fully inside its own half,
with at least 96 pixels of pure-green isolation from the canvas edges and cell
boundary. Give each an approximately 5.10:1 visible bbox suitable for
proportional, non-distorting fit to exactly 214 by 42 runtime pixels.

These are empty physical shells around an existing pfUI bar stack, not complete
unit frames. Leave the entire central live-content corridor visually open and
quiet for a 200 by 25 health bar plus a 200 by 4 power bar. Do not draw any
fill, portrait, name, level, number, icon, aura, status text, classification,
button or glow. The dynamic bars and text are drawn by the game.

Both objects are restrained, hand-repaired Azeroth expedition field badges:
compact equipment carried through a long campaign, not decorative fantasy
plaques. Use thick deep-walnut worn leather as the main structure, a soot-brown
inner liner, a few short pieces of dull oxidized brass and two or three coarse
repair stitches. Use circa-2004 Vanilla WoW hand-painted bitmap language,
low-resolution readable masses, warm upper-left light, short broken highlights
and real contact shadows. The long edges may wander gently only at low
frequency. Unequal ends, rivets, nicks and repairs must look caused by use and
field maintenance, never by all-over random noise.

The Player shell has a slightly heavier, crooked brass clamp and two coarse
stitches at the left end, while its right end is mostly worn leather with one
off-centre rivet. The Target shell must be redrawn independently rather than
mirrored: its right end carries a visibly damaged short brass compression plate
and its left end is mainly a polished leather fold. Keep both central corridors
calm and the ornament subordinate to live combat information.

Do not make complete continuous gold outlines, matching corner ornaments,
perfect rounded rectangles, web cards, glass panels, industrial rivet grids,
black-iron shrines, skulls, horns, large crests, portrait wells, book pages,
book spines, wax seals, dragons, gemstones, neon or photoreal antiques. Outside
the two objects every pixel must be pure #00FF00, including the open central
corridors and the isolation band. Before returning, verify exactly two shells,
correct upper Player/lower Target order, no baked dynamic content, no mirror
duplication, no edge contact and no non-green pixel outside the two cells.

### `UF-A2 V1` — TargetTarget／Focus 紧凑外壳

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Never copy either reference's object geometry. If an image conflicts with this
text, follow this text.

Create one production-ready 1024 by 1024 bitmap sheet containing exactly two
separate compact horizontal unit-frame shell objects on a perfectly uniform
pure #00FF00 background. The upper 1024 by 512 cell is TargetTarget and the
lower 1024 by 512 cell is Focus. Draw both as front-facing orthographic 2D
game-UI assets with no scene, camera tilt or perspective foreshortening. Keep
at least 72 pixels of pure-green isolation from canvas edges and the cell
boundary. The upper visible bbox must be approximately 3.294:1 for
proportional, non-distorting fit to exactly 112 by 34 runtime pixels; the lower
must be approximately 2.872:1 for fit to exactly 112 by 39. Do not draw any
other object.

These shells surround real pfUI bars. Keep the full central corridor quiet for
a 100 by 20 plus 100 by 1 bar stack in TargetTarget and a 100 by 25 plus 100 by
1 stack in Focus. Draw no bar fill, portrait, text, number, icon, aura, status,
classification, click control or glow.

Use a restrained hand-repaired Azeroth expedition field-badge identity:
deep-walnut worn leather, soot-brown liner, restrained oxidized brass, warm
upper-left light, thick readable silhouette, real contact depth and
low-frequency hand-cut irregularity in circa-2004 Vanilla WoW bitmap language.
The irregularity must follow wear and repair rather than random noise. These
are compact purpose-built objects, not scaled copies of the large shells.
TargetTarget is the quietest member: thin worn leather, only two or three short
brass traces, unequal ends and no centre ornament.

Focus uses the same restrained compact structure but has one small faded-indigo
hunter's tracking cloth knot emerging from the upper-right leather seam. The
cloth must be physically trapped under the leather and one dull brass rivet;
it may not float, glow or intrude into the live-content corridor. This cloth is
the sole focus identifier. Do not use a gem, rune ring, wax seal or blue neon
outline.

Forbid continuous gold trim, matched corners, perfect rounded cards, glass,
industrial grids, black-iron altars, skulls, horns, book parts, large crests,
portraits, text and dynamic game content. Outside and inside the open shell
corridors every background pixel must remain pure #00FF00. Verify exactly two
objects, upper/lower identity, distinct proportions, physical cloth attachment,
quiet corridors, isolation margins and no edge contact.

### `UF-B1 V1` — Health／Power 无色填充纹

No reference images are supplied for this body; everything required is stated
below. Create one production-ready 1024 by 1024 bitmap sheet with exactly two
separate horizontal opaque grayscale paint-texture swatches on a perfectly
uniform pure #00FF00 background. The upper 1024 by 512 cell contains only the
Health fill donor at approximately 2:1 visible bbox for proportional,
non-distorting fit to exactly 64 by 32. The lower 1024 by 512 cell contains only
the Power fill donor at approximately 4:1 for fit to exactly 64 by 16. Show both
front-facing with at least 80 pixels of pure-green isolation from canvas edges
and the cell boundary. Each swatch must be a plain rectangle with no frame,
cap, text, icon, colour meaning or glow.

Both swatches are neutral grayscale because pfUI supplies health, reaction,
class and power colours at runtime. Use matte hand-painted mineral pigment with
subtle low-frequency horizontal brush drag and slight pigment accumulation.
Health is a little coarser and deeper; Power is narrower, calmer and slightly
denser. Keep the middle overwhelmingly quiet so horizontal stretch and
StatusBar clipping never reveal a focal motif or repeating seam.

The material must read as a Vanilla-era painted bar surface, not leather,
parchment, brushed metal, glass or fabric. No diagonal stripe, bevel shine,
central hotspot, gradient gloss, noise carpet, scratches crossing the entire
width, transparent holes or chromatic tint. Maintain fully opaque swatches,
pure #00FF00 everywhere else and at least a broad green gap between them.
Verify exactly two neutral swatches, upper Health/lower Power order, no colour
cast, no dynamic content, no edge contact and no non-green pixels outside them.

## 自主修复循环

- 不可变边界：上述三段各自的组件 ID、对象数量与顺序、参考图职责、Canvas、
  runtime 尺寸、正视方向、动态内容排除、材料主次、色键和最多五次实际生图。
- 固定上传：`UF-A1 V1` 与 `UF-A2 V1` 的每次调用都只允许上传本文件固定 SHA
  的 Image 1／2，顺序和职责不变；`UF-B1 V1` 的首次调用不上传图片。
- 允许修复：同段内调整占用率、低频端帽不规则、材料粗细、磨损／修补位置、
  Focus 布结的物理接触和纯绿隔离。A1／A2 只有明确保留正确区域时，才允许把
  同段紧邻前次输出作为 Image 3 edit 输入；B1 同条件下作为 Image 1 edit
  输入。不得跨段复用像素。
- 允许的确定性候选处理：按固定上下半区拆分；只做边缘连通 `#00FF00`
  色键、透明 RGB 清零和各对象等比 bbox-fit。源 bbox 与目标比例误差超过 `1%`
  时必须退回，禁止非等比压缩。正式候选每次都要以真实 runtime 尺寸、真实
  动态文字／条／状态和当前邻接 UI 生成排版预演；这些处理不构成 P4 接受。
- 必须重新授权：新增／删除对象、改变物件身份、使用新参考、改变 Canvas／
  runtime 几何、改成头像结构、改变综合色方向或跨段复用像素。

## 执行记录

- 日期：`2026-08-11`
- 操作：本地确定性几何模拟；未启动固定 ImageGen 子进程。
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 规格／渲染器：`tools/specs/unitframes_primary_simulation_v1.json`／
  `tools/render_unitframes_primary_simulation_v1.py`
- 输出：本文件“生成前模拟实例图”所列 scene／zoom。
- 实际 ImageGen：`0/0`；流程错误：`0`。
- 循环终态：`simulation-confirmed`；正式生产循环尚未开始。

## 正式生产循环

### `UF-A1 V1`

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-A1 V1` / `d902e2b` | generate | child `019fee93-168d-7360-85c0-e7d02095deff`／result `ig_019be3007b694521016a7a83ee64d88191aa391033b667c3df` | raw `generated/unitframes/primary/UF-A1/V1/attempt-01/raw/UF-A1_V1_attempt-01.png`／SHA `80d928ac…33d3` | 组件合同：两框纵横比与动态安全走廊失败 | 保留深胡桃材质、克制装饰和 Player 左／Target 右非镜像关系；用 Image 3 edit 修正比例、隔离、开口与内缘 | failed；进入 `V1.r1` |
| 2/5 | `UF-A1 V1.r1` / pending | edit | pending | pending | pending | pending | pending |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `UF-A1 V1` / `d902e2b` | unified exec `99073`；无 child session／result | 固定 child 在读取 prompt 前退出：`No prompt provided. Either specify one as an argument or pipe the prompt into stdin.`；无图片、无 provider result、无生成证据 | 保持提交正文和 Image 1／2 完全不变，只把同一参数从 argv transport 改为 CLI 明示的 stdin transport | 不占 `0/5`；以同一正文重试 |

#### Attempt 1 审查

- 输入：固定 Image 1 SHA `90e30ba…ee06`、Image 2 SHA `272528e6…aab8`；无
  Image 3。正文来自提交 `d902e2b`，stdin transport 完整回显；fixed child 未
  报告 revised prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `80d928ac1f07d090da2b28b5eeede38055683dab58cf3909f8c71b3d282533d3`。
- 范围／语义：恰有上下两张空外壳，没有文字、头像、图标或状态；Player 左端
  黄铜修补较重、Target 右端破损压片较重，二者没有镜像复用。通过。
- 物理／美术：深胡桃皮革、少量黄铜、粗线结和接触阴影成立，装饰克制；但
  内开口过窄且呈规则胶囊圆角，粗犷维修逻辑不足。该项必须在几何修复时一并
  收敛，不能保留其规整内缘。
- 第一失败门禁：Player keyed bbox `1343×280`，比例误差 `5.864486%`；Target
  `1295×266`，误差 `4.451549%`，均超过授权 `1%`。Player 下隔离 `88px`，
  低于 `96px`。等比装入 `214×42` 后两框分别只有 `201×42`／`204×42`，真实
  `200×30` 动态走廊分别被 `3875`／`3599` 个可见 Alpha 像素侵入。
- 确定性处理：固定两格；外边缘与声明的中央内容孔连通色键；一像素 despill；
  透明 RGB 清零；只做等比 fit，无非等比压缩。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-01/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-01/real-layout-preview.png`，SHA
  `e9e6a6a9f3a87ea53f8c961f8b2b39fdd8588178db5e38526e561ce2e0139073`；
  Player／Target 候选为 `100%` runtime，动态条与文字为真实几何；屏幕锚点、
  TargetTarget／Focus 和动作条为明确非权威 fallback。预演可见端帽挤压条形区。
- 结论：`failed / attempt 1 of 5`；不允许用户复审、source 或 runtime。

#### `UF-A1 V1.r1` 完整修复正文

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Image 3 is the immediately preceding UF-A1 attempt. Preserve only its deep-
walnut material handling, restrained amount of ornament, Player-left versus
Target-right non-mirrored identity and coarse field-repair feeling. Do not
preserve its too-tall proportions, narrow inner holes, pill-shaped inner
corners, cell placement or exact silhouette. If any image conflicts with this
text, follow this text.

Edit into one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate horizontal unit-frame shell objects on a perfectly uniform pure
#00FF00 background. The upper 1536 by 512 cell is the Player shell and the
lower 1536 by 512 cell is the Target shell. Draw no other object. Show both as
front-facing orthographic 2D game-UI assets with no scene, camera tilt or
perspective foreshortening.

Make each complete visible shell bbox approximately 1320 pixels wide by 259
pixels high, a 5.0965:1 ratio within one percent of the required 5.10:1. Centre
each inside its own half: keep every visible Player pixel approximately within
x 108..1428 and local y 125..384, and every visible Target pixel within the
same safe envelope in its lower cell. Keep at least 96 pixels of uniform green
between every object and the canvas edges or horizontal cell boundary. The
result must support proportional, non-distorting fit to exactly 214 by 42
runtime pixels.

These are empty physical shells around an existing pfUI bar stack, not complete
unit frames. In each shell, the pure-green inner opening must occupy at least
93.5 percent of the shell bbox width and 71.5 percent of its height so the
entire runtime corridor x 7..207 and y 6..36 remains transparent for a 200 by
25 health bar, a one-pixel gap and a 200 by 4 power bar. Keep end clamps,
stitches, leather folds and every opaque edge completely outside that corridor.
Do not make the opening a perfect pill: use subtly unequal, hand-cut inner
corners and low-frequency edge drift while retaining the full safe corridor.
Do not draw any fill, portrait, name, level, number, icon, aura, status text,
classification, button or glow. Dynamic bars and text are drawn by the game.

Both objects are restrained, hand-repaired Azeroth expedition field badges:
compact equipment carried through a long campaign, not decorative fantasy
plaques. Use thick deep-walnut worn leather as the main structure, a soot-brown
inner liner, a few short pieces of dull oxidized brass and two or three coarse
repair stitches. Use circa-2004 Vanilla WoW hand-painted bitmap language,
low-resolution readable masses, warm upper-left light, short broken highlights
and real contact shadows. The long edges may wander gently only at low
frequency. Unequal ends, rivets, nicks and repairs must look caused by use and
field maintenance, never by all-over random noise.

The Player shell has a slightly heavier crooked brass clamp and two coarse
stitches at the left end, but compress that end treatment enough to preserve
the full inner opening. Its right end is mostly worn leather with one off-
centre rivet. Redraw the Target independently rather than mirroring: its right
end carries a visibly damaged short brass compression plate, compressed clear
of the safe corridor, while its left end is mainly a polished leather fold.
Keep both centres calm and all ornament subordinate to live combat information.

Do not make complete continuous gold outlines, matching corner ornaments,
perfect rounded rectangles, web cards, glass panels, industrial rivet grids,
black-iron shrines, skulls, horns, large crests, portrait wells, book pages,
book spines, wax seals, dragons, gemstones, neon or photoreal antiques. Outside
the two shells and inside both open content corridors every pixel must be pure
#00FF00. Before returning, verify exactly two shells, correct upper Player and
lower Target order, 5.10:1 bboxes within one percent, at least 96 pixels of
isolation, full green runtime corridors, no baked dynamic content, no mirror
duplication, no edge contact and no non-green pixels outside the two cells.

## 审查记录

- 语义／物理：四框均为包住现有动态条的身份牌外壳；没有假头像槽、浮动
  黄铜件或悬空 Focus 布结。
- 透视／图层：外壳、内衬、动态条与短边状态反馈层序清楚；端帽装饰不进入
  provider 内容走廊。
- 美术一致性：几何图已表达深胡桃皮革、断续暗铜、非镜像修补与减法紧凑件；
  正式手绘纹理仍属非权威。
- 对象／状态合同：四张 shell、两条 fill、两类确定性 rim 的职责完整；预演
  显示 Player normal、Target aggro、TargetTarget normal、Focus hover。
- 实际展示区域：合同与报告 SHA 如上；`4/4 pass`，violations `0`。
- 结论：`displayable / simulation-confirmed`；确认方向已写入三段最终生产
  正文。当前仍不允许进入 source、runtime 或正式 ImageGen。
- 用户结论：`confirmed / 2026-08-11`，原文“接受 UF-PRIMARY-SIM-V1”。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `UF-PRIMARY-SIM-V1` | deterministic scene／zoom；SHA 与 display-region `4/4` 如上；ImageGen `0/0` | `simulation-confirmed` | 可见方向已写入 A1／A2／B1；等待三段正式生产授权 |

## 下一门禁

执行 `UF-A1 V1` attempt 1，并按完整审查顺序决定内部通过或生成完整 `.rN`
修复正文；A1 结束后依次进入 A2、B1。每段最多 `5` 次实际 ImageGen，最坏
合计 `15`；流程错误不占额度。候选需要在本设备继续逐像素审查，因此本轮不
创建跨设备 handoff；若最终停在用户复审且需要换设备，再按稳定状态发布最小
检查点。
