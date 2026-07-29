# Chat 复制纸页 V1.1

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.COPY.TOGGLE`、`CHAT.COPY.SURFACE`、`CHAT.COPY.TEXT`
- 版本：`CHAT.COPY.V1.1`
- 子状态：`prompt-authorized`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：`edit`
- 功能来源：
  [`addon/pfUI/modules/chatcopy.lua`](../../../../addon/pfUI/modules/chatcopy.lua)
- 锁定视觉基准：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 战地旧书身份、香草 HUD 中的紧凑比例和低干扰控件尺度
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 二维手绘页边、纸张厚度和材料精度；其完整框架结构明确排除
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- 本地派生依据：
  - [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
    — 只在本地提取安静纸面，生成 A 的单物件结构引导
  - A 通过内部对象审查后的候选
    — 只在本地构造 B1 的双页夹结构引导，保证 A／B 纸色与笔触一致
- 外部 ImageGen 实际输入计划：
  - A：只上传
    `generated/chat/copy/v1_1/inputs/CHAT.COPY.SURFACE.SCAFFOLD.V1_1.png`
  - B1：只上传
    `generated/chat/copy/v1_1/inputs/CHAT.COPY.TOGGLE.CLOSED.SCAFFOLD.V1_1.png`
  - B2：只上传内部通过后的
    `generated/chat/copy/v1_1/b1/CHAT.COPY.TOGGLE.CLOSED.V1_1.raw.png`
  - 两张完整锁定图与两张完整 V3 source 均不直接上传；它们继续通过本文件
    和基线 Prompt 提供项目权威，但不得再诱导执行器复制完整 UI 结构
- raw：执行后仅写入 `generated/chat/copy/v1_1/`
- 透明候选：执行后仅写入 `generated/chat/copy/v1_1/`
- 重组预演：执行后仅写入 `generated/chat/copy/v1_1/previews/`
- 最终 source：无；必须经用户明确接受后才能进入
  `assets/source/chat/copy/`

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图，以及 Chat 主／子模块 Prompt 和历史 V3 provenance。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实 pfUI 对象、状态、几何和禁止
   烘焙合同。
4. 已接受 V3 source 只承担已部署纸色、笔触与磨损连续性。
5. V1 失败候选只提供反例，不进入 V1.1 的任何编辑输入。

### 必须继承的视觉 DNA

- 组件必须像同一本长期携带、反复修补的战地旧书上的附加抄录纸与页夹。
- 纸张第一、深胡桃旧皮革第二、黄铜最多只是一枚暗哑连接点；使用
  `#B8955C` 旧书页、`#D2B77E` 克制高光、`#76512E` 页影、
  `#28180E` 深皮革、`#80602D` 暗哑黄铜和 `#24170F` 墨褐结构线。
- 左上暖光、低饱和暖赭色域、略不规则二维手绘边缘、非镜像磨损和清楚的
  纸页厚度必须与当前 V3 聊天书一致。
- 阅读区域连续、安静、低对比；高频磨损只允许出现在抄录纸外缘和页夹。

### 本批组件级转译

- `CHAT.COPY.SURFACE` 只是一张覆盖正文区域的薄抄录纸。V1.1 先在本地从
  V3 主框安静纸面构造严格 `380:248` 的单矩形编辑引导，再让 ImageGen
  只把这块矩形转成轻微错层毛边纸；执行器看不到完整聊天框。
- `CHAT.COPY.TOGGLE` 只生成关闭、开启两个持久物理状态。关闭时两张短纸叶
  收拢；开启时上层纸叶在同一外接框内稍微扇开。悬停继续由 pfUI／adapter
  对同一物理纹理调整 Alpha，不再要求模型绘制七个近重复状态。
- `CHAT.COPY.TEXT` 始终由真实 `pfChatCopyBoxN` 绘制。本批不改变正文或
  复制文字的字体、字号、颜色、选择和光标。

### 明确不继承

- 不继承游戏基准中其他模块的动作条、单位框、任务追踪或侧边按钮。
- 不继承独立艺术资源的龙饰、尖顶、顶部四槽、木柱、宝石或完整金属框。
- 不复刻 V3 主框、Tab、输入纸带、蜡封、底栏字段或动态文字。
- 不生成现代“双文档”图标、方形按钮牌、滚动条、关闭按钮、搜索框、
  Tooltip 或 ChatMenu 外壳。

### 冲突审计

- V1 的授权正文已经明确排除完整框架，但同时上传四张完整 UI 图；ImageGen
  的 revised prompt 仍把 A 改成第二聊天框，把 B 改成现代文档按钮。
  V1.1 的裁决是保留完整书本的书面视觉权威，却只向外部模型提供每次调用
  唯一目标对象的隔离编辑引导。
- pfUI 的真实 `pfChatCopyButton` 只有关闭／开启两种持久纹理，并用
  `OnEnter`／`OnLeave` 调整 Alpha；当前实现没有独立 pressed 或 disabled
  纹理。V1 的七状态表高于真实 provider 所有权。V1.1 改为两个物理 source，
  悬停由 runtime 派生，不生产不存在的状态。
- `pfChatCopyButton` 原始 `16 × 16` 位置与第四枚 Tab 冲突。V1.1 仍保留同一
  Button 和左右键逻辑，只把视觉放在书本右侧页边，不覆盖 Tab 或正文。
- pfUI 原始 `95%` 黑色复制覆盖层与连续纸面冲突；V1.1 只替换其背景 Region，
  不改变历史缓存、滚动、选择、Escape 或消息转发。
- 用户已延后 `CHAT.TEXT` 可读性改造；V1.1 不借本批修改正文字体或频道色。

## 组件合同

### 真实对象与功能

- 一个全局 `pfChatCopyButton`：
  - 左键切换所有非战斗日志复制纸面的显示状态。
  - 右键继续显示／隐藏原生 `ChatMenu`。
  - 持久状态只有 `off` 与 `on`；`hover` 是同一纹理的 runtime Alpha。
- 每个非战斗日志 `ChatFrameN`：
  - 一个 `ChatFrameScrollN`，共享 A 的九宫格物理资产。
  - 一个 `pfChatCopyBoxN`，继续作为可选择多行 EditBox。
- 保留 100 条历史、颜色码、滚动、选择、Escape 两段式退出和
  `ChatFrameN.AddMessage` 转发。

### Runtime 几何与状态

- `CHAT.COPY.TOGGLE`：
  - 两个物理状态：`off`、`on`。
  - 视觉范围统一为 `22 × 26 UI px`；锚到 `pfChatLeft` 右侧页边
    `RIGHT → RIGHT, x=-14, y=-8`。
  - 命中区向四边各扩展 `3px`，最终 `28 × 32 UI px`。
  - normal／hover 共用相同 UV；hover 只改变 Alpha，不改变纹理、Point、
    Width、Height 或外接轮廓。
  - 当前 provider 不拥有独立 pressed／disabled 纹理，V1.1 不生成。
- `CHAT.COPY.SURFACE`：
  - 与所属 `ChatFrameN` 同尺寸；最小书框下为 `380 × 248 UI px`。
  - 九宫格固定边 `8px`；中间边段与中心可水平、垂直拉伸。
  - `pfChatCopyBoxN` 使用左右 `10px`、上下 `8px` 安全内边距。
  - 隐藏状态不占用额外可见空间。
- 维护约束：只在首次装配和已知布局事件后按需恢复 Anchor；周期维护不得
  持续改写 Parent、Point、Width 或 Height。

### 确定性本地输入

- A 结构引导：
  1. 从 `ChatBookFrame_Master_v3.png` 取半开区间
     `(270,160)–(1338,857)`，得到 `1068 × 697` 的安静纸面，不含封皮、
     Tab、金属框或页夹。
  2. Lanczos 缩放为 `1140 × 744`，精确等于 `380 × 248` 的三倍。
  3. 居中放入 `1536 × 1024` 的纯 `#00FF00` 画布，左上角
     `(198,140)`；输出 A scaffold。
- B1 结构引导：
  1. 只有 A 通过范围、对象身份与纸面安全区审查后才创建。
  2. 在 `1024 × 1024` 纯 `#00FF00` 画布的
     `(336,304)–(688,720)` 内构造一个 `352 × 416`、比例精确服从
     `22:26` 的双纸叶引导。
  3. 两张短纸叶使用 A 候选的纸面采样，彼此只横向错开少量；一个短深皮革
     夹横跨上缘且完全留在共同外接框内。引导只定义结构和材料分区，不是
     最终 source。
- B2 编辑输入：只使用内部通过后的 B1 raw；改变上层纸叶开合，保持画布、
  外接框、锚点、夹具和下层纸叶不变。

### 输出、裁切与验收

- A raw：建议 `1536 × 1024`；完整纸对象保持 `1140 × 744` 外接比例。
  所有毛边、页层、折角和接触阴影限制在外缘 `24px` source 带内，对应
  runtime `8px` 固定边；中心 `1080 × 696` 对应 runtime
  `360 × 232` 安静区。
- B1／B2 raw：各自一张 `1024 × 1024` 单物件图；共同外接框、锚点、光源
  和缩放必须相同。不得合成多状态 contact sheet 交给 ImageGen。
- 所有调用输出纯 `#00FF00` 平整背景，审查通过后才转为真透明 RGBA。
- A 只允许九宫格；B1／B2 后续确定性合成两个 UV cell，状态切换不改几何。
- 禁止烘焙：聊天消息、玩家名、颜色码、选择高亮、光标、Tab、输入条、
  未读、现代复制图标、状态标签、按钮牌、ChatMenu 和任何完整聊天框结构。
- 验收预演：
  - 在 `440 × 320` 当前 V3 主框中分别重组 off／on；
  - on 预演显示 `380 × 248` 抄录纸和安全区，不烘焙真实聊天内容；
  - 以 `22 × 26` 和 `28 × 32` 调试覆盖分别检查视觉与命中区。
- 回退：任何资产、Frame 或状态缺失时 `chatcopy` 继续不加载；不得恢复
  pfUI 黑色覆盖层作为 AEUI 局部替代。

## 最终执行正文

状态：`production`。用户已于 `2026-07-29` 明确授权
`CHAT.COPY.V1.1` A／B1／B2，并允许外部上传 A scaffold、B1 scaffold 和
B1 raw。以下三段正文必须逐字交给固定执行器，不得改写。

### A：单张薄抄录纸编辑

```text
Edit the supplied isolated paper scaffold into one production-ready loose
transcription leaf for the real ChatFrameScrollN copy surface in Turtle WoW
1.18.1. Preserve exactly one object, the scaffold's landscape 380:248 outer
proportion, its placement, and its generous green separation. This is a thin
sheet laid over the reading page of an existing battlefield journal. It is not
a chat window, not a second book, not a framed panel, and not a mockup.

The written Azeroth Expedition chat baseline is the visual authority: a
compact 2004-era hand-painted bitmap, upper-left warm light, low-saturation
smoked parchment, slightly irregular handmade edges, practical non-mirrored
wear, and clear paper thickness. Paper must account for the entire object.
Use old parchment near #B8955C, restrained highlights near #D2B77E, page
shadows near #76512E, and dark ink-brown edge accents near #24170F. The
scaffold already contains the deployed V3 paper sample; preserve its hue,
brush scale, fiber frequency, and wear density.

Replace only the scaffold's straight outer boundary with a restrained
deckled boundary and one shallow offset leaf underneath. Keep the result
orthographic and nearly flat. The second leaf may appear only as a narrow
paper edge. Add one short soft contact shadow between those two paper layers,
never a shadow cast onto the green field. Keep every tear, fold, page layer,
hard stain, and shadow inside the outer 24 source pixels. The complete center
1080 by 696 source pixels must remain continuous, quiet, low contrast, and
free of seams so it can become a 360 by 232 runtime text-safe field.

The four 24-pixel source edge bands and corners will become fixed nine-slice
regions. Do not place a tear, fold, stain, repair, stitch, or hard shadow
across the middle stretch zone of any edge. Do not change the outer object
ratio or create protrusions outside the scaffold's original bounds.

Include no leather cover, wood, brass frame, metal trim, tab, slot, pillar,
wax seal, button, icon, clipboard, document glyph, input strip, scroll bar,
text, letter, line, number, label, chat message, cursor, selection, or other
UI object. Reject ornate quest parchment, a complete book, a framed text box,
a modern card, black glass, a polished document viewer, photographic paper,
symmetrical decoration, and high-frequency dirt in the center.

Return exactly one isolated object on one perfectly flat uniform #00FF00
background. Preserve the 1536 by 1024 canvas. Use no checkerboard, gradient,
floor, vignette, cast shadow on green, cell border, label, or extra object.
```

### B1：关闭状态双页夹编辑

```text
Edit the supplied isolated two-leaf structure scaffold into exactly one
production-ready closed transcription page clip for the real
pfChatCopyButton in Turtle WoW 1.18.1. Preserve the scaffold's one-object
scope, vertical 22:26 outer proportion, common anchor, placement, and green
separation. Do not turn it into a square button or a toolbar icon.

This physical object belongs to the same battered Azeroth Expedition chat
journal as the transcription leaf sampled into the scaffold. Preserve that
paper hue and brush scale. Render it as a compact 2004-era hand-painted bitmap
with upper-left warm light, broad readable value groups, slightly crooked
hand-cut edges, and restrained practical wear. Use two short overlapping
parchment leaves near #B8955C and #D2B77E, page separation near #76512E, one
small worn deep-walnut leather clamp near #28180E, and dark structural accents
near #24170F. Brass is optional and may occupy no more than one pinhead.

The two leaves are closed: they overlap closely under the short leather clamp,
with only two clear paper edges visible. Keep the complete construction inside
the scaffold's unchanged 22:26 outer bounds. The clamp must physically hold
both leaves at their upper edge. Use no long cord, hanging ornament, detached
part, or one-pixel noise. The silhouette must remain readable when reduced to
22 by 26 UI pixels and when runtime hover changes only its Alpha.

Include no duplicate-document pictogram, clipboard, quill, book symbol,
letter, line, arrow, rune, jewel, wax seal, text, label, square plaque,
beveled button frame, continuous metal border, glow, or other UI object.
Reject a modern copy icon, website toolbar button, symmetrical gold badge,
polished brass control, photoreal stationery, and machine-perfect folds.

Return exactly one isolated object on one perfectly flat uniform #00FF00
background. Preserve the 1024 by 1024 canvas and the scaffold's original
outer bounds. Use no checkerboard, gradient, floor, vignette, cast shadow on
green, cell border, label, or extra object.
```

### B2：开启状态局部编辑

```text
Edit the supplied internally reviewed closed transcription page clip into its
open persistent state for the same real pfChatCopyButton. This is a local
state edit, not a redesign. Preserve exactly the same 1024 by 1024 canvas,
22:26 outer bounds, anchor, lower leaf, leather clamp, paper material,
palette, brushwork, wear, light direction, and one-object scope.

Change only the upper paper leaf: fan its free lower and right edge outward
slightly around the existing top leather clamp so two paper layers read more
clearly at 22 by 26 UI pixels. Keep the rotated leaf completely inside the
unchanged outer bounds. The clamp must still hold both leaves, and no part may
detach, lengthen, or move the shared anchor. The difference from closed to open
must come from this small physical overlap change, not from a symbol, color
swap, glow, border, added decoration, or different canvas.

Add no duplicate-document pictogram, clipboard, quill, book symbol, text,
letter, line, arrow, rune, jewel, wax seal, square plaque, button frame,
continuous metal border, glow, or extra object. Do not alter the background.

Return exactly one isolated object on one perfectly flat uniform #00FF00
background. Use no checkerboard, gradient, floor, vignette, cast shadow on
green, cell border, or label.
```

## 执行记录

- 日期：未执行
- 会话／结果 ID：无
- 实际输入绝对路径与职责：按本文件的确定性输入合同创建后逐项记录
- imagegen 报告的 revised prompt：无
- 输出尺寸／模式／SHA-256：无
- Alpha／残色：未检查
- 内部失败重试：无

## 审查记录

- 语义／物理：提示词预检通过；A、B1、B2 均只对应一个真实物理对象。
- 透视／图层：A 是底页上的上层纸；B 是右侧页边上的独立 Button 纹理。
- 美术一致性：锁定图与 provenance 继续最高；完整 UI 图不直接上传。
- 对象／状态合同：已按 pfUI 真实代码把七张生成状态收敛为 off／on 两个
  持久 source；hover 由 runtime Alpha 派生。
- 装配／尺寸：合同已定义 `380 × 248`、`22 × 26`、九宫格固定边和预演。
- 技术像素：待生成。
- 结论：`prompt-authorized / P3`
- 用户结论与日期：`2026-07-29`，明确授权 `CHAT.COPY.V1.1`，并允许上传
  A scaffold、B1 scaffold 和 B1 raw
- 下一门禁：先创建并检查 A scaffold，再由固定 ImageGen 0.143.0 执行 A；
  A 通过首个语义门禁后才允许创建或上传 B1 输入

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| V1 | commit `69ada1f`；session `019fae2a…`／`019fae2c…` | `candidate-rejected` | 不上传完整 UI；A 单物件 edit；B 按真实持久状态拆分 |
| V1.1 | 三个隔离 edit 调用；用户于 `2026-07-29` 明确授权 | `prompt-authorized` | 固定执行器按 A → B1 → B2 门禁顺序执行 |
