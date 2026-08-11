# Unit Frames 主单位框批次 UF-PRIMARY V1

## 元数据

- 模块：`unitframes`
- 组件 ID：`UF.PLAYER.SHELL`、`UF.TARGET.SHELL`、
  `UF.TARGETTARGET.SHELL`、`UF.FOCUS.SHELL`、`UF.BAR.*`、`UF.STATE.*`
- 当前版本：`UF-PRIMARY-SIM-V1`
- 子状态：`simulation-reviewed`
- 项目阶段：`P1 → P2 direction gate`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：`simulate`；正式生产尚未授权
- 生成前模拟：deterministic-local-geometry；ImageGen `0/0`
- 自动修复预算：未来 `UF-A1`／`UF-A2`／`UF-B1` 各最多 `5` 次实际生图，
  最坏合计 `15`；当前 `0/15`
- 流程错误：`0`
- 锁定视觉基准：当前没有 Unit Frames 专属锁定图。
- 次级风格参考：
  - `assets/locked/chat/聊天框视觉基准_v1.png`：只提供香草时代绘制尺度、
    短黄铜高光、厚轮廓与综合色重；明确忽略其完整屏幕布局和单位框示意结构。
  - `assets/locked/chat/聊天框独立艺术资源_v3.png`：只提供深胡桃材料、左上
    暖光、手工误差与磨损节奏；明确忽略书页、书脊、木柱、龙饰与大面积金边。
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
- 本地渲染错误：`0`
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
- 用户结论：pending
- 下一门禁：用户确认／否决本模拟方向；确认不等于授权正式 ImageGen。

## 生产正文完整性预检

- 复杂度：三个独立 atlas／state 执行正文。
- 当前结论：`draft-pass`；必须在模拟确认后加入确认条款并重新审查，才可请求
  正式生产授权。
- `UF-A1`：两个对象、固定两格、同尺寸但非镜像、动态内容排除、色键与
  `214×42` bbox-fit 已明确。
- `UF-A2`：两个不同高度对象、固定两格、Focus 布结、紧凑减法与各自安全区
  已明确。
- `UF-B1`：两条灰阶不透明 donor、运行时着色、横向拉伸与重复节奏已明确。
- 未知但执行必需的值：无；远端屏幕位置不影响本批资源生成。

## 最终执行正文

状态：`production-draft / unauthorized`。以下三段尚未授权。用户确认模拟后，
必须将可见结论写入并展示最终版本；不得以本草案直接调用固定执行器。

### `UF-A1 V1` — Player／Target 大外壳

Create one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate horizontal unit-frame shell objects on a perfectly uniform pure
#00FF00 background. The upper cell is the Player shell and the lower cell is
the Target shell. Draw no other object. Each shell must remain fully inside
its own half with a broad pure-green isolation margin and an approximately
5.10:1 visible silhouette suitable for proportional bbox fitting to 214 by 42
runtime pixels.

These are empty physical shells around an existing pfUI bar stack, not complete
unit frames. Leave the entire central live-content corridor visually open and
quiet for a 200 by 25 health bar plus a 200 by 4 power bar. Do not draw any
fill, portrait, name, level, number, icon, aura, status text, classification,
button or glow. The dynamic bars and text are drawn by the game.

Both objects belong to the same hand-made Azeroth expedition field-badge
family. Use thick deep-walnut worn leather as the main structure, a soot-brown
inner liner, a few short pieces of dull oxidized brass and two or three coarse
repair stitches. Use circa-2004 Vanilla WoW hand-painted bitmap language,
low-resolution readable masses, warm upper-left light, short broken highlights
and real contact shadows. The long edges may wander gently at low frequency;
the two ends, rivets, nicks and repair locations must not be symmetrical.

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

Create one production-ready 1024 by 1024 bitmap sheet containing exactly two
separate compact horizontal unit-frame shell objects on a perfectly uniform
pure #00FF00 background. The upper cell is TargetTarget and the lower cell is
Focus. Keep broad pure-green isolation around both. The upper silhouette must
fit proportionally to 112 by 34 runtime pixels; the lower silhouette must fit
proportionally to 112 by 39 runtime pixels. Do not draw any other object.

These shells surround real pfUI bars. Keep the full central corridor quiet for
a 100 by 20 plus 100 by 1 bar stack in TargetTarget and a 100 by 25 plus 100 by
1 stack in Focus. Draw no bar fill, portrait, text, number, icon, aura, status,
classification, click control or glow.

Use the same circa-2004 hand-painted expedition field-badge family as the large
shells: deep-walnut worn leather, soot-brown liner, restrained oxidized brass,
warm upper-left light, thick readable silhouette, real contact depth and
low-frequency hand-cut irregularity. These are compact purpose-built objects,
not scaled copies of the large shells. TargetTarget is the quietest member: thin
worn leather, only two or three short brass traces, unequal ends and no centre
ornament.

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

Create one production-ready 1024 by 1024 bitmap sheet with exactly two separate
horizontal opaque grayscale paint-texture swatches on a perfectly uniform pure
#00FF00 background. The upper swatch is the Health fill donor and the lower
swatch is the Power fill donor. Each swatch must be a long plain rectangle with
broad green isolation and no frame, cap, text, icon, colour meaning or glow.

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

- 不可变边界：上述三段各自的对象数量、顺序、输入职责、Canvas、runtime
  尺寸、动态内容排除、材料方向、色键与最多五次实际生图。
- 允许修复：同段内调整占用率、端帽不规则、材料粗细、布结接触、绿色隔离；
  只有明确保留正确区域时才允许使用同段紧邻前次输出作 edit 输入。
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
- 循环终态：`simulation-reviewed`；正式生产循环尚未开始。

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
- 结论：`displayable / simulation-reviewed`，允许进入用户方向复审；不允许
  进入 source、runtime 或正式 ImageGen。
- 用户结论：pending。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `UF-PRIMARY-SIM-V1` | deterministic scene／zoom；SHA 与 display-region `4/4` 如上；ImageGen `0/0` | `simulation-reviewed` | 等待用户确认；若否决则按具体可见问题创建新模拟版本 |

## 下一门禁

渲染并内部检查 `UF-PRIMARY-SIM-V1`，向用户展示全屏 scene 与放大 zoom；等待
明确方向确认。确认后仍需展示三段最终 production 正文和总预算，再分别获得
正式 ImageGen 授权。
