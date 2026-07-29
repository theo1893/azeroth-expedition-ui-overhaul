# Chat URL 抄录便笺 V1

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.URLCOPY.SHELL`、`CHAT.URLCOPY.INPUT`、
  `CHAT.URLCOPY.CLOSE`
- 版本：`CHAT.URLCOPY.V1`
- 子状态：`prompt-draft`
- 项目阶段：`P2`
- 处置：`user-deferred`；用户于 `2026-07-30` 要求暂缓该项，优先处理对
  用户体验更关键的大面积 UI
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：shell 单物件 generate；input／close 只复用已接受 V3 source 和
  runtime atlas，不调用 ImageGen
- 功能来源：
  [`addon/pfUI/modules/chat.lua`](../../../../addon/pfUI/modules/chat.lua)
  中 `pfURLCopy`、`pfURLCopyEditBox`、`pfURLCopyClose` 与
  `_G.SetItemRef`
- 锁定视觉基准：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 香草 HUD 中战地旧书的物件身份、紧凑控件尺度与低干扰重量
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 二维手绘纸页厚度、旧皮革和材料精度；其完整框架、龙饰与固定槽排除
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- shell 生成时拟上传的受限参考：
  - Image 1：
    [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
    — SHA-256
    `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`
    — 只提供已部署纸色、皮革色、宽面笔触、磨损尺度与左上暖光，不提供
    完整书框结构
  - Image 2：
    [`ChatControls_Master_v3.png`](../../../../assets/source/chat/v3/ChatControls_Master_v3.png)
    — SHA-256
    `de0e5c66753ab59be1448f75f0843b37265c98f104381f3529314f494ac52968`
    — 只提供小尺度纸带的边缘精度、缝线尺度与综合色温；明确排除退役底栏
    字段、输入条几何和蜡封
- input 复用：
  - source：
    `assets/source/chat/v3/ChatControls_Master_v3.png`
    （SHA-256
    `de0e5c66753ab59be1448f75f0843b37265c98f104381f3529314f494ac52968`）
  - runtime：
    `addon/AzerothExpeditionUI/Media/Chat/ChatInputAtlasV3.tga`
    （SHA-256
    `0b613e1b2050090b76527db18ab69943e9bdbbdfa61edf4e2dd0bfe9a081646a`）
- close 复用：
  - source：
    `assets/source/chat/v3/ChatTabs_Master_v3.png`
    （SHA-256
    `8172d9d5145ac16ed23913fb7fbf75e626e0976d6bb33b27a555de4c55853023`）
  - runtime：
    `addon/AzerothExpeditionUI/Media/Chat/ChatTabAtlasV3.tga`
    （SHA-256
    `4ab2d572a345b53ee55b5a21b5ed542de27ec0bdcd3eb05b9c094cf6d9889384`）
- raw：无；尚未授权生成
- 透明候选：无
- 重组预演：无
- 最终 source：无；必须经用户明确接受后才能进入
  `assets/source/chat/urlcopy/`

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图及其 Chat 主／子模块 Prompt 与历史 V3 provenance。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 对三个真实对象、固定几何、动态文字、
   状态和回退的合同。
4. 已接受 V3 frame／controls／tabs source 只承担声明过的材料连续性与
   input／close 复用职责，不能高于锁定基准。

### 必须继承的视觉 DNA

- 弹窗必须像从同一本长期携带、反复修补的战地旧书中临时抽出的 URL 抄录
  便笺，而不是第二本迷你书、现代模态框或棕色网页卡片。
- 纸张第一、深胡桃旧皮革第二；黄铜不是本组件必需材料。色域继续使用
  `#B8955C` 旧书页、`#D2B77E` 克制高光、`#76512E` 页影、
  `#28180E` 深皮革和 `#24170F` 墨褐结构线。
- 左上暖光、低饱和暖赭／烟褐、二维手绘宽面笔触、略不规则页边与非镜像
  磨损必须和 V3 主聊天书一致。
- URL 文字区必须连续、安静、低对比；磨损、缝线和页影只位于外缘与连接处。

### 本批组件级转译

- `CHAT.URLCOPY.SHELL` 是一张从战地旧书抽出的窄横向抄录便笺：前层为安静
  旧纸，后层只露出很薄的深胡桃皮革承托与一处偏心缝线。它是一个可拖动
  shell，不包含标题、输入槽或关闭按钮。
- `CHAT.URLCOPY.INPUT` 直接复用已接受 V3 normal／focus 输入纸带的三段式
  材料，在 `250 × 20` 内压缩端帽而不产生新位图。URL、选择和光标仍由
  `pfURLCopyEditBox` 绘制。
- `CHAT.URLCOPY.CLOSE` 复用已接受 V3 Tab 的 normal／hover／disabled
  皮革材料并横向三段式缩放到 `70 × 18`；pushed 由 normal 行整体向下
  `1px`、同步移动文字并短暂降低亮度表达，不生成新的虚假状态。

### 明确不继承

- 不继承完整聊天书的封皮外框、Tab 承托带、双页结构、输入位置、未读蜡封
  或退役底栏。
- 严禁裁切、加载或重新包装 `ChatControls_Master_v3.png` 中已退役的
  bottom-status field；runtime manifest 对它的禁止用途继续有效。
- 不继承锁定独立资源中的龙、尖顶、木柱、宝石、固定槽或重金属建筑。
- 不生成标题、“URL”“复制”“关闭”等文字，不生成按钮凹槽、输入框轮廓、
  图标、光标、选择高亮、Tooltip 或整屏遮罩。
- 不使用半透明黑玻璃、网页模态框、规则卡片、金属细线框、圆角胶囊、
  霓虹青绿文字或照片级古董材质。

### 冲突审计

- provider 把 `pfURLCopy` 放在屏幕中央并允许拖动；Chat 主基线把模块识别为
  左下角旧书。裁决为“从旧书抽出的独立抄录便笺”，保留屏幕中心交互，不
  生成第二本完整书。
- 当前 pfUI shell 是 `80%` 不透明现代 backdrop，EditBox 使用亮青绿色
  `.2,1,.8`。裁决为纸面 shell 与墨褐 URL 文字；选择高亮仍由客户端提供，
  不用常亮青色表达焦点。
- `ChatControls_Master_v3.png` 含一个被项目明确退役的底栏字段，外形接近
  小弹窗。该字段不得作为 shell 或 close 的 source、crop、mask 或 runtime
  纹理；Image 2 只传递小尺度材料和绘制精度。
- `UIPanelButtonTemplate` 可提供 pressed／disabled 语义，但 pfUI
  `SkinButton` 清空其四张纹理。AEUI 后续只接管视觉 Region，不改变 Button
  的 Click、Enable／Disable、动态文字或关闭行为。
- shell 固定为 `270 × 65`，不需要九宫格。ImageGen 只负责一个完整固定尺寸
  物件；若透明物件 bbox 的宽高比偏离 `54:13` 超过 `3%`，直接内部退回，
  不靠非等比拉伸修正。

## 组件合同

### 真实对象与功能

- `CHAT.URLCOPY.SHELL`：
  - 真实对象：`pfUI.chat.urlcopy`／`pfURLCopy`。
  - 一个显示／隐藏状态；`FULLSCREEN` strata；锚到 `UIParent CENTER`。
  - 保留左键拖动、`StartMoving`／`StopMovingOrSizing` 和拖动后的当前会话
    位置。
- `CHAT.URLCOPY.INPUT`：
  - 真实对象：`pfUI.chat.urlcopy.text`／`pfURLCopyEditBox`。
  - normal／focus 两个视觉状态；输入内容、全选、选择与光标由 EditBox
    持有。
  - `OnShow` 继续全选；Escape 与失焦继续关闭 shell。
- `CHAT.URLCOPY.CLOSE`：
  - 真实对象：`pfUI.chat.urlcopy.close`／`pfURLCopyClose`。
  - normal／hover／pushed／disabled 四个视觉状态；文字继续来自
    `T["Close"]`。
  - 点击仍只关闭 `pfURLCopy`。
- `_G.SetItemRef` 对 `url:` 链接的截取、其他链接的转发以及
  `pfUI.chat.urlcopy.CopyText` 的数据行为全部保持不变。

### Runtime 几何与状态

- shell：固定 `270 × 65 UI px`；不改 Parent、Point、Width、Height 或
  strata。新透明 shell 覆盖 provider backdrop，外缘装饰不得超过 `8px`。
- input：固定 `250 × 20 UI px`；`TOP → TOP, x=0, y=-10`。复用
  `ChatInputAtlasV3.tga`：
  - normal row `v=0..0.5`；
  - focus row `v=0.5..1`；
  - runtime 左／右端帽为 `22px／16px`，中段 `212px`；
  - 状态切换不改 EditBox 几何；URL 文字改为墨褐色并继续水平居中。
- close：固定 `70 × 18 UI px`；`BOTTOMRIGHT → BOTTOMRIGHT,
  x=-10, y=10`。复用 `ChatTabAtlasV3.tga`：
  - normal／hover／disabled 分别使用对应状态行；
  - pushed 使用 normal 行、三段纹理和动态文字整体向下 `1px`，亮度短暂
    降低；松开后恢复；
  - runtime 左／右端帽各 `10px`，中段 `50px`；文字安全区至少
    `50 × 14px`。
- 状态维护只在 `OnShow`、EditBox focus、Button enter／leave／mouse
  down／up 与 Enable／Disable 边沿更新纹理或颜色；不得使用周期循环改写
  Parent、Point 或尺寸。

### 新 shell 源与输出合同

- 固定调用只生成一个 shell raw；input／close 不进入 ImageGen。
- raw 中只允许一个正交横向物件，放在完全平坦的 `#00FF00` 背景上。
- raw 透明化后按非绿可见 bbox 裁取；bbox 宽高比必须位于
  `54:13 ±3%`，否则内部退回。
- 通过比例门禁后只做等比裁取与 Lanczos 缩放，得到精确
  `810 × 195 RGBA` 候选，即 runtime `270 × 65` 的三倍；不得用非等比
  拉伸修正构图。
- 候选可见 bbox 必须为完整画布；Alpha 只来自色键转换，不追加外发光、
  描边、按钮槽或新装饰。
- runtime export 尚未授权；未来只在 source 接受后写入带至少 `4px` 防渗色
  padding 的 2 次幂 TGA cell。

### 禁止烘焙与验收

- 禁止烘焙：URL、选择、光标、标题、关闭文字、按钮状态标签、输入框、
  Button、Tab、未读、ChatMenu 或完整聊天书。
- 最低预演：
  1. shell 原始透明棋盘预览；
  2. `270 × 65` shell 单独真实尺寸；
  3. input normal／focus 与 close 四状态按真实 z-order 装回 shell；
  4. 放在 `1024 × 768` 中心的整体比例预演；
  5. 选中长 URL、Escape、失焦、拖动和关闭按钮的 Lua smoke／实机门禁。
- 回退：shell media 或 AEUI adapter 缺失时保留当前 pfUI backdrop、EditBox
  与 Button，不阻止 URL 复制功能。

## 最终执行正文

状态：`production-draft`。下列英文正文是根据用户目标与项目锁定美术基线
转译出的精确专业提示词；只有用户查看并明确授权 `CHAT.URLCOPY.V1`，同时
允许上传本文件元数据中的 Image 1／Image 2 后，才原样交给固定
`imagegen-0-143-0`。固定执行器不得再次改写、翻译或补充创意内容。

```text
Create exactly one production-ready, text-free, orthographic 2D hand-painted
bitmap object for Turtle WoW 1.18.1: the empty shell of the pfUI URL-copy
popup. The object is a narrow horizontal URL transcription slip temporarily
pulled from the same battered battlefield journal as the locked Azeroth
Expedition Chat V3 UI. It must read first as a loose field-note slip from that
book and only second as a UI popup shell. It must not read as a second miniature
book, a framed dashboard, a modern modal, a web card, or a button.

Produce one complete shell object and nothing else. The object has a quiet old
parchment face backed by a very thin strip of deep-walnut worn leather. Let
only four to seven runtime pixels of the leather backer remain visible along
parts of the left and lower edge. Add at most one small off-center hand-stitched
repair near the left edge. Keep the center, the upper writing region, and the
lower-right region calm, continuous, and undecorated so live URL text and a
separate runtime close button remain readable. Do not paint a title, input
slot, button recess, separator, icon, label, cursor, selection, close control,
or any control-shaped geometry into the shell.

The visible object must have a width-to-height ratio of 54:13, approximately
4.1538:1. Compose it as one very wide, shallow object centered on the output
canvas with generous empty background around it. Its front parchment may bow
slightly and its top and bottom deckled edges may vary by a few pixels, but the
overall silhouette must remain compact and usable at 270 by 65 UI pixels.
Keep all decorative thickness within the outer eight runtime pixels. Do not
use a thick book binding, four framed corners, bilateral symmetry, ruler-straight
double rails, or protrusions that consume the live interior.

Use the locked Chat art language explicitly: old parchment around #B8955C,
restrained parchment highlights around #D2B77E, page and contact shadows around
#76512E, deep worn leather around #28180E, and dark ink-brown structural lines
around #24170F. Paper is the dominant material; leather is a thin physical
backer and connector; brass is unnecessary. Use the same left-top warm light,
low-saturation ochre and smoke-brown palette, broad hand-painted bitmap
brushwork, non-mirrored wear, material thickness, and restrained contrast as
the accepted Chat V3 assets. Keep high-frequency wear only on the outer
deckled edge, leather backer, and the single stitched repair.

Image 1 is only the exact material, palette, broad-brush wear, paper thickness,
leather thickness, and left-top lighting reference. Do not copy its complete
book frame, binding, corners, page opening, tabs, or layout. Image 2 is only
the small-control edge precision, stitch scale, paper-to-leather relationship,
and color-temperature reference. Do not copy its two input strips, retired
bottom-status field, wax seal, object count, or sheet layout. The written
component identity and exclusions above override conflicting structures in
either image.

Reject a miniature chat frame, framed leather rectangle, regular vintage
panel, status field, input bar, website modal, rounded card, capsule, thin
gold outline, black translucent glass, cyan or neon accent, glossy metal,
photorealistic antique, Diablo-style black iron, Elder-Scrolls-like floating
text panel, dragon, crest, gem, rune, skull, or symmetrical corner ornament.

Place the single complete object on one perfectly flat, uniform chroma-key
green background #00FF00. The background must contain no checkerboard,
gradient, texture, floor, vignette, ambient shadow, or cast shadow. Keep the
entire object inside the canvas with clean green separation around every edge.
Output no text and no additional object.
```

### 固定执行映射

- `-i Image 1`：
  `D:\Git\azeroth-expedition-ui-overhaul\assets\source\chat\v3\ChatBookFrame_Master_v3.png`
- `-i Image 2`：
  `D:\Git\azeroth-expedition-ui-overhaul\assets\source\chat\v3\ChatControls_Master_v3.png`
- raw 目标：
  `generated/chat/urlcopy/v1/shell/CHAT.URLCOPY.SHELL.V1.raw.png`
- transparent candidate 目标：
  `generated/chat/urlcopy/v1/shell/CHAT.URLCOPY.SHELL.V1.candidate.png`
- 这两个输入只有在用户针对 `CHAT.URLCOPY.V1` 明确允许上传后才能传给固定
  子进程；“继续”本身不构成上传或生成授权。

## 执行记录

- 日期：未执行
- 授权版本 commit：无
- 会话／结果 ID：无
- 实际输入：无；Image 1／Image 2 尚未上传
- revised prompt：无
- 输出尺寸／模式／SHA-256：无
- Alpha／残色：未检查
- 内部失败重试：无

## 审查记录

- 范围／对象身份：Prompt 预检通过。只新生成一个 shell；input／close 明确
  复用真实已接受资产，不把三个对象烘焙为一张图。
- 语义／物理：Prompt 预检通过。便笺的前纸／薄皮革背托关系成立；shell
  可独立拖动，input／close 位于其上方。
- 透视／图层：正交前视；runtime 固定为 shell → input／URL text →
  close Button／动态文字。
- 美术一致性：两张锁定图及书面 Prompt 保持最高；两张 source 仅承担材料
  与小尺度精度职责，退役 bottom-status field 被明确禁止。
- 对象／状态合同：shell 一态、input 两态、close 四态均对应真实对象；没有
  虚构 provider 状态。
- 装配／尺寸：`270 × 65`、`250 × 20`、`70 × 18` 与三个现有锚点已从
  `chat.lua` 静态确认；仍需候选真实尺寸预演与 Turtle WoW 测量。
- 技术像素：待执行。
- 结论：`prompt-draft / P2`
- 用户结论与日期：`2026-07-30`；用户要求 URL Copy 也暂缓，转向大面积
  主窗口
- 下一门禁：无活跃生产门禁；仅在用户明确恢复 URL Copy 后，才重新开放
  V1 正文与 Image 1／Image 2 上传授权。暂缓期间不创建 raw、candidate、
  source、runtime 或 Lua。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| V1 | provider 静态对象／几何审计；锁定 provenance；单 shell generate + input／close 复用合同 | `prompt-draft / P2 / user-deferred` | 仅在用户明确恢复后重开授权门禁 |
