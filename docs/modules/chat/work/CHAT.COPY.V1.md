# Chat 复制纸页 V1

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.COPY.TOGGLE`、`CHAT.COPY.SURFACE`、`CHAT.COPY.TEXT`
- 版本：`CHAT.COPY.V1`
- 子状态：`prompt-authorized`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：`generate`
- 功能来源：
  [`addon/pfUI/modules/chatcopy.lua`](../../../../addon/pfUI/modules/chatcopy.lua)
- 锁定视觉基准：
  - Image 1：
    [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 战地旧书身份、香草 HUD 中的紧凑比例和低干扰控件尺度
  - Image 2：
    [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 二维手绘页边、纸张厚度和材料绘制精度；不继承其龙饰、尖顶或规则框架
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- 次级参考：
  - Image 3：
    [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
    — 只用于匹配当前运行时书页的纸色、皮革色、磨损尺度和左上暖光
  - Image 4：
    [`ChatControls_Master_v3.png`](../../../../assets/source/chat/v3/ChatControls_Master_v3.png)
    — 只用于小型控件的笔触密度、纸边厚度和皮绳尺度；不继承已退役底栏字段
- raw：生成后仅写入 `generated/chat/copy/v1/`
- 透明候选：生成后仅写入 `generated/chat/copy/v1/`
- 重组预演：生成后仅写入 `generated/chat/copy/v1/`
- 最终 source：无；必须经用户明确接受后才能进入 `assets/source/chat/copy/`

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图，以及 Chat 主／子模块 Prompt 和其历史 V3 provenance。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实 pfUI 对象、状态、几何和禁止
   烘焙合同。
4. 两张已接受 V3 source，只承担当前书本的材料连续性，不得改写锁定基准。

### 必须继承的视觉 DNA

- 组件必须像同一本长期携带、反复修补的战地旧书上的附加纸页和页夹，不能像
  覆盖在聊天框上的现代复制面板。
- 纸张第一、深胡桃旧皮革第二、氧化黄铜只允许作为极少量连接点；使用
  `#B8955C` 旧书页、`#D2B77E` 克制高光、`#76512E` 页影、
  `#28180E` 深皮革、`#80602D` 暗哑黄铜和 `#24170F` 墨褐结构线。
- 左上暖光、低饱和暖赭色域、略不规则手绘轮廓、非镜像磨损和可辨认的实体
  厚度必须与 V3 主框一致。
- 阅读区必须连续安静；高频破损只放在纸页外缘和小型页夹，不得穿过可选择
  文本。

### 本批组件级转译

- `CHAT.COPY.SURFACE` 是盖在原书正文纸面上的一张薄抄录纸，不是第二本书。
  它只在复制模式显示，以轻微错层毛边和短接触阴影区别于底页。
- `CHAT.COPY.TOGGLE` 是夹在书本右侧页边的一枚双层抄录页夹。关闭时两张纸
  收拢，开启时上层纸在同一外接框内略微展开；轮廓本身表达复制语义，不使用
  现代“双文档”图标、文字或发光。
- `CHAT.COPY.TEXT` 继续由 pfUI 的真实多行 EditBox 绘制。本批不改变聊天
  正文字体、频道颜色或复制文字配色。

### 明确不继承

- 不继承 Image 1 中其他模块的动作条、任务追踪、单位框和固定侧边按钮。
- 不继承 Image 2 的龙饰、尖顶、四枚规则槽、木柱或完整金属边框。
- 不复刻 V3 主框、Tab、输入纸带、蜡封未读、旧底栏字段或任何动态文字。
- 不生成滚动条、关闭按钮、搜索框、复选框、Tooltip 或独立 ChatMenu 外壳。

### 冲突审计

- pfUI 当前把 `pfChatCopyButton` 放在 `panelTop` 右上角，尺寸为
  `16 × 16`；四枚 `92px` Tab 加三个 `3px` 间距已占用 `377 / 380px`，
  原位置必然与第四枚 Tab 冲突。V1 将真实 Button 保持为同一逻辑对象，但把
  视觉和命中区移到书本右侧外缘，不能挤压或覆盖 Tab。
- pfUI 当前用 `95%` 不透明黑色覆盖 `ChatFrameScrollN`。它与锁定的连续
  羊皮纸阅读面冲突；V1 改成一张低对比抄录纸，保留复制、选择和滚动行为。
- Image 3／4 的材料连续性不能高于锁定图。若派生 source 的边框更规则、
  更工整，则以锁定图的手工误差和战地磨损为准。
- 用户已明确把正文可读性改造延后。本批不得借复制纸页生成或代码接入，顺带
  改写 `CHAT.TEXT` 字体、字号、描边或频道色。

## 组件合同

- 逻辑对象与数量：
  - 一个全局 `pfChatCopyButton`。
  - 每个 pfUI 判定为非战斗日志的 `ChatFrameN` 各一个
    `ChatFrameScrollN` 和 `pfChatCopyBoxN`；所有实例共享同一物理纸页资产。
- pfUI／Blizzard 映射：
  - `CHAT.COPY.TOGGLE` → `pfChatCopyButton`。
  - `CHAT.COPY.SURFACE` → `ChatFrameScrollN` 及其背景 Region。
  - `CHAT.COPY.TEXT` → `pfChatCopyBoxN`。
- 功能不变量：
  - 左键继续统一显示／隐藏复制纸页。
  - 右键继续显示／隐藏 `ChatMenu`。
  - 原有 100 条历史缓存、颜色码、滚动、选择、Escape 两段式退出和
    `ChatFrameN.AddMessage` 转发保持不变。
- `CHAT.COPY.TOGGLE` 状态：
  - `off-normal`、`off-hover`、`off-pressed`；
  - `on-normal`、`on-hover`、`on-pressed`；
  - 一个共用 `disabled`。
- Toggle runtime 几何：
  - 视觉 Button `22 × 26 UI px`，七状态外接尺寸完全一致。
  - 锚到 `pfChatLeft` 右侧页边：
    `RIGHT → RIGHT, x=-14, y=-8`。
  - 命中区只向四边各扩展 `3px`，最终 `28 × 32 UI px`；不得侵入
    `x=30..410` 正文安全区或顶部 Tab 带。
  - 父级保持 `pfUI.chat.left.panelTop`；只在首次装配和已知布局事件后按需
    恢复锚点，维护循环不持续改写 Parent、Point 或尺寸。
- `CHAT.COPY.SURFACE` runtime 几何：
  - 与所属 `ChatFrameN` 同尺寸；最小聊天书下为 `380 × 248 UI px`。
  - 九宫格固定边为 `8px`；中段可水平、垂直拉伸。
  - 复制 EditBox 在纸页内使用左／右 `10px`、上／下 `8px` 安全内边距；
    滚动子级仍由 pfUI 更新高度和垂直范围。
  - 隐藏状态不分配额外可见占位。
- 源画布与排布：
  - A：一张完整抄录纸，建议 `1536 × 1024`，对象比例严格服从
    `380 : 248`；四周保留均匀色键空间。
  - B：七个无字页夹状态，建议 `1536 × 1024`，上排四个、下排三个；每格
    留出独立色键间隔，不画格线、标签或状态文字。
- 拉伸、裁切与 UV：
  - A 只允许九宫格；毛边、折角和接触阴影必须留在 `8px` 固定边内。
  - B 七格确定性裁切；状态切换不得改变 Button 几何。
- Alpha：固定执行器先输出纯 `#00FF00` 平整色键背景，后处理为真透明 RGBA；
  任何纸页半透明边缘都必须检查绿色残色。
- 禁止烘焙：聊天消息、玩家名、颜色码、选择高亮、光标、按钮文字、现代复制
  图标、Tab、输入条、未读、滚动条、关闭按钮和 ChatMenu。
- 验收预演：
  - 在 `440 × 320` V3 主框中重组；
  - 关闭／开启两张预演分别显示页夹状态；
  - 开启预演显示 `380 × 248` 抄录纸和文字安全区，但不烘焙真实聊天内容。
- 回退：任何资产、Frame 或状态缺失时继续把 `chatcopy` 路由为不加载；不得
  恢复 pfUI 黑色覆盖层作为 AEUI 的局部替代。

## 最终执行正文

状态：`production`。用户已于 `2026-07-29` 明确授权以下 A／B 作为完整的
`CHAT.COPY.V1` 执行正文；执行时必须逐字传给固定执行器，不得改写。

### A：抄录纸面

```text
Create one production-ready modular bitmap asset for the chat-copy surface of
the locked Azeroth Expedition battlefield-journal UI for Turtle WoW 1.18.1.
This object is a thin loose transcription leaf placed over the existing chat
book's reading page while copy mode is active. It is not another book, not a
dialog window, and not a dark overlay.

The locked in-game chat baseline and its written project prompt are the highest
visual authority. Preserve their compact vanilla-era silhouette language,
hand-painted 2004-era bitmap rendering, slightly irregular handmade edges,
low-saturation warm palette, upper-left warm light, and practical long-use
wear. Paper must dominate. Use old parchment near #B8955C, restrained
highlights near #D2B77E, page shadows near #76512E, sparing deep-leather contact
details near #28180E, and dark ink-brown structural lines near #24170F. The
current accepted V3 book and control sources are secondary references only for
matching the already deployed paper hue, brush scale, edge thickness, and wear
density; they must not override the looser locked battlefield-journal identity.

Produce exactly one complete, text-free loose parchment sheet in an orthographic
front view. Its runtime contract is 380 by 248 UI pixels. The outer proportion
must therefore remain exactly 380:248. Give it one or two shallow offset page
edges, restrained deckled wear, and a short soft contact shadow so it visibly
rests on the main book page. Keep all visible wear, folds, page layering, and
shadow inside an 8-pixel runtime edge band. The center must remain continuous,
flat, quiet, and low contrast, with at least a 360 by 232 runtime-pixel safe
field before the code applies its final text insets. Use only low-frequency
smoke and subtle fiber variation in that center.

Build the sheet for deterministic nine-slice export: all four corners and the
8-pixel edge bands are fixed, while the entire middle of every edge and the
central parchment can stretch without crossing a tear, stitch, fold, stain,
repair, or hard shadow. The four edges may be individually irregular but no
detail may create a step across a stretch seam.

Do not include chat messages, player names, timestamps, color swatches,
selection highlights, cursors, tabs, input fields, scroll bars, buttons,
labels, icons, wax seals, metal frames, a second book cover, or any other UI
component. Reject a black or translucent panel, modern card, modal, framed
text box, clipboard, polished document viewer, ruled notebook paper, ornate
quest parchment, photographic antique paper, symmetrical gold framing, and
high-frequency dirt in the reading area.

Place the complete object on one perfectly flat uniform chroma-key green
background #00FF00. Use no checkerboard, gradient, floor, vignette, cast shadow
on the green field, labels, cell borders, or extra objects. Use a 1536 by 1024
source canvas with generous green separation around the object.
```

### B：双层抄录页夹七状态

```text
Create one production-ready sprite source for the real pfChatCopyButton in the
locked Azeroth Expedition battlefield-journal chat UI for Turtle WoW 1.18.1.
The button is a tiny double-leaf transcription clip attached to the right page
edge of the same deployed chat book. Its physical silhouette, rather than a
modern pictogram, must communicate that it opens a selectable copy sheet.

The locked in-game chat baseline and its written project prompt are the highest
visual authority. Inherit their compact vanilla-era scale, hand-painted
low-resolution bitmap language, slightly crooked handmade construction,
upper-left warm light, low-saturation worn parchment, deep-walnut leather, and
restrained practical wear. Use paper near #B8955C and #D2B77E, shadows near
#76512E, a small leather clip or tie near #28180E, dark structural accents near
#24170F, and no more than a pinhead of oxidized brass near #80602D. The current
accepted V3 book and control sources are secondary material references only;
match their deployed brush scale and paper thickness without copying the
retired status field, unread seal, or input strip.

Produce exactly seven separate, text-free state sprites:
1. off-normal;
2. off-hover;
3. off-pressed;
4. on-normal;
5. on-hover;
6. on-pressed;
7. disabled.

Every state must use the exact same outer canvas, anchor, 22 by 26 runtime-pixel
visual bounds, light direction, and underlying double-leaf construction.
Nothing may move outside those shared bounds. In the off family, the two small
paper leaves sit closely aligned and partially closed under one short worn
leather clip. In the on family, the upper leaf fans outward slightly inside the
same bounds so two distinct page edges are readable at runtime size. Hover adds
only a short candle-warm edge and slightly clearer paper separation. Pressed
looks compressed downward by one to two runtime pixels inside the unchanged
canvas. Disabled keeps the same silhouette with lower saturation and contrast.

Keep the shape compact and readable at 22 by 26 pixels: broad value groups,
two clear paper layers, one small dark leather attachment, no one-pixel noise,
no long cords, and no decorative protrusion. It must look like a physical page
clip from the same battered journal, not a toolbar icon.

Arrange the seven sprites with generous equal green spacing on a 1536 by 1024
source canvas, four objects in the upper row and three in the lower row. Keep
each object's full alpha silhouette isolated. Do not draw cell frames, state
labels, numbers, arrows, text, a duplicate-document glyph, clipboard symbol,
quill, book icon, button plaque, red notification dot, glow, rune, jewel, or
continuous metal border.

Reject modern flat icons, web toolbar buttons, beveled square buttons,
symmetrical gold badges, photorealistic stationery, polished brass, rigid
machine-perfect folds, and state sprites with different outer geometry.

Place all seven objects on one perfectly flat uniform chroma-key green
background #00FF00. Use no checkerboard, gradient, floor, vignette, cast shadow
on the green field, labels, or additional objects.
```

## 执行记录

- 日期：未执行
- 会话／结果 ID：无
- 实际输入绝对路径与职责：待用户授权后按元数据中的 Image 1–4 映射
- imagegen 报告的 revised prompt：无
- 输出尺寸／模式／SHA-256：无
- Alpha／残色：未检查
- 内部失败重试：无

## 审查记录

- 语义／物理：待生成
- 透视／图层：待生成
- 美术一致性：待生成
- 对象／状态合同：待生成
- 装配／尺寸：待生成
- 技术像素：待生成
- 结论：`prompt-authorized / P3`
- 用户结论与日期：`2026-07-29`，明确授权执行 `CHAT.COPY.V1` A／B
- 下一门禁：固定 ImageGen 0.143.0 分别执行 A／B，并记录原始输出与会话

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| V1 | 用户于 `2026-07-29` 授权本文件 A／B 正文 | `prompt-authorized` | 使用固定执行器逐字执行 |
