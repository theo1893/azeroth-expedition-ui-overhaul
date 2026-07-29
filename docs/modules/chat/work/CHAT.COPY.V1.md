# Chat 复制纸页 V1.3

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.COPY.TOGGLE`、`CHAT.COPY.SURFACE`、`CHAT.COPY.TEXT`
- 版本：`CHAT.COPY.V1.3`
- 子状态：`candidate-rejected`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：A 为确定性派生；B 复用 V1.2 固定执行器 raw 的合格表面区域，
  只做确定性裁取、归一化、分层、局部变形与 Alpha
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
- 确定性派生依据：
  - [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
    — 只在本地提取已接受的安静纸面，确定性生成 A；它只承担已部署纸色、
    笔触与磨损连续性，不高于两张锁定图及其 Prompt
  - V1.2 B1 第一次完整调用 raw
    — 只保留其已通过内部审查的纸叶／皮夹对象身份、表面笔触、材料分离和
    左上暖光；明确丢弃其画布、坐标、比例、绿底与外接框
- V1.3 外部输入：无；本版本不再调用 ImageGen，也不上传图片
- V1.2 donor raw：
  - `generated/chat/copy/v1_2/b1/CHAT.COPY.TOGGLE.CLOSED.V1_2.raw.png`
    — `1254 × 1254 RGB`，SHA-256
    `682459afa17ac43d3961085d211b340ed446152cf52fd2e7b250422316180e4b`
  - donor provenance：session
    `019fae80-fabb-7030-8fc7-fbee2c142d99`／result
    `ig_063f0c62bfe8a6e9016a6a1cfd1a148191b735c96afa0341ec`
- V1.3 透明候选：
  - A：
    `generated/chat/copy/v1_3/a/CHAT.COPY.SURFACE.V1_3.candidate.png`
    — `1140 × 744 RGBA`，SHA-256
    `ed4e1c1a3bfdf4b37775a383b18636454834562eefd7ab526f3ecaf03f8e8efb`
  - B closed：
    `generated/chat/copy/v1_3/b/CHAT.COPY.TOGGLE.CLOSED.V1_3.candidate.png`
    — `1024 × 1024 RGBA`，SHA-256
    `e8a38407ac05131763032796a7e6ac9000bece42b3692462e53a68567b3666ce`
  - B open：
    `generated/chat/copy/v1_3/b/CHAT.COPY.TOGGLE.OPEN.V1_3.candidate.png`
    — `1024 × 1024 RGBA`，SHA-256
    `ba1134e704f326dd895a01b5592d6162e4c564a6e6b96ab84b4633a44c4ea3ac`
- V1.3 重组预演：
  - `generated/chat/copy/v1_3/previews/CHAT.COPY.ASSEMBLY.OFF-ON.V1_3.png`
  - `generated/chat/copy/v1_3/previews/CHAT.COPY.TOGGLE.CLOSED-OPEN.10X.V1_3.png`
  - 完整本地构建记录：
    `generated/chat/copy/v1_3/CHAT.COPY.V1_3.build.json`
- V1.1 失败 raw：继续只保留在被忽略的
  `generated/chat/copy/v1_1/`，只作反例，不进入 V1.3 输入
- 最终 source：无；必须经用户明确接受后才能进入
  `assets/source/chat/copy/`

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图，以及 Chat 主／子模块 Prompt 和历史 V3 provenance。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实 pfUI 对象、状态、几何和禁止
   烘焙合同。
4. 已接受 V3 source 只承担已部署纸色、笔触与磨损连续性。
5. V1／V1.1 失败候选只提供反例。V1.2 B1 第一次 raw 仅以本文件声明的
   表面 donor 职责进入 V1.3；它不能提供任何几何权威。

### 必须继承的视觉 DNA

- 组件必须像同一本长期携带、反复修补的战地旧书上的附加抄录纸与页夹。
- 纸张第一、深胡桃旧皮革第二、黄铜最多只是一枚暗哑连接点；使用
  `#B8955C` 旧书页、`#D2B77E` 克制高光、`#76512E` 页影、
  `#28180E` 深皮革、`#80602D` 暗哑黄铜和 `#24170F` 墨褐结构线。
- 左上暖光、低饱和暖赭色域、略不规则二维手绘边缘、非镜像磨损和清楚的
  纸页厚度必须与当前 V3 聊天书一致。
- 阅读区域连续、安静、低对比；高频磨损只允许出现在抄录纸外缘和页夹。

### 本批组件级转译

- `CHAT.COPY.SURFACE` 是覆盖正文区域的连续抄录纸面。V1.3 继续不让
  ImageGen 决定它的外轮廓：直接从已接受 V3 主框提取安静纸面并确定性
  缩放到严格 `380:248` 的三倍源尺寸。它保持完整消息容量，不再增加第二
  纸叶、毛边或任何可能跨越九宫格 stretch zone 的独特细节。
- `CHAT.COPY.TOGGLE` 只生成关闭、开启两个持久物理状态。关闭时两张短纸叶
  收拢；开启时上层纸叶在同一外接框内稍微扇开。悬停继续由 pfUI／adapter
  对同一物理纹理调整 Alpha。两状态的画布、外接框、下层纸叶、夹具和
  上层纸叶变形全部由确定性 polygon／mask 锁定。V1.2 donor 只提供已经
  生成的纸叶与皮夹表面像素，不再参与任何外部调用。
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
- V1.1 的 A 虽然通过单纸身份审查，但固定执行器的 revised prompt 删除了
  精确比例、固定边和 stretch-zone 条款，并主动增加底边撕裂。V1.2 不再
  试图用更强文字要求模型遵守像素几何，而是把 A 的全部几何从 ImageGen
  所有权中移除；V1.1 raw 不作为 edit 输入。
- V1.1 同时把 `24px` 九宫格固定边后的中心误写为 `1080 × 696`。正确关系
  是九宫格 stretch center 为 `1092 × 696`；`1080 × 696` 是另一个合同，
  即 `30px` 左右文字内边距和 `24px` 上下文字内边距后的文本安全区。
- V1.2 的 A 已证明确定性几何有效；B1 两次独立完整调用都把
  `1024 × 1024` 改成 `1254 × 1254`、放大对象并污染平整绿底，说明固定
  ImageGen 不适合承担像素坐标保真。两次 raw 的对象身份、纸／皮革物理关系
  和第一次 raw 的宽面笔触通过内部审查。V1.3 因此只保留第一次 raw 的
  donor 表面，按固定 SHA 与固定 crop 读取；其错误画布、背景、坐标和轮廓
  一律不继承。此使用范围明确、局部且不把失败候选伪装成已通过 source。
- pfUI 的真实 `pfChatCopyButton` 只有关闭／开启两种持久纹理，并用
  `OnEnter`／`OnLeave` 调整 Alpha；当前实现没有独立 pressed 或 disabled
  纹理。V1 的七状态表高于真实 provider 所有权。V1.3 保持两个物理 source，
  悬停由 runtime 派生，不生产不存在的状态。
- `pfChatCopyButton` 原始 `16 × 16` 位置与第四枚 Tab 冲突。V1.3 仍保留同一
  Button 和左右键逻辑，只把视觉放在书本右侧页边，不覆盖 Tab 或正文。
- pfUI 原始 `95%` 黑色复制覆盖层与连续纸面冲突；V1.3 只替换其背景 Region，
  不改变历史缓存、滚动、选择、Escape 或消息转发。
- 用户已延后 `CHAT.TEXT` 可读性改造；V1.3 不借本批修改正文字体或频道色。

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
  - 当前 provider 不拥有独立 pressed／disabled 纹理，V1.3 不生成。
- `CHAT.COPY.SURFACE`：
  - 与所属 `ChatFrameN` 同尺寸；最小书框下为 `380 × 248 UI px`。
  - 九宫格固定边 `8px`；中间边段与中心可水平、垂直拉伸。
  - `pfChatCopyBoxN` 使用左右 `10px`、上下 `8px` 安全内边距。
  - 隐藏状态不占用额外可见空间。
- 维护约束：只在首次装配和已知布局事件后按需恢复 Anchor；周期维护不得
  持续改写 Parent、Point、Width 或 Height。

### 确定性本地输入

- A 确定性候选：
  1. 验证 `ChatBookFrame_Master_v3.png` 为 `1608 × 978 RGBA` 且
     SHA-256 为
     `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
  2. 取半开区间 `(270,130)–(1338,827)`，得到 `1068 × 697` 的已接受
     安静纸面；相较 V1.1 向上平移 `30px`，明确排除其底边撕裂。该区域
     不含封皮、Tab、金属框、页夹或动态内容。
  3. Lanczos 缩放为精确 `1140 × 744 RGBA`，对应最小 runtime
     `380 × 248` 的三倍。Alpha 全部保持 `255`；不添加毛边、第二纸叶、
     描线、阴影、色键或生成像素。
  4. 九宫格 source 固定边为四边各 `24px`，切线为
     `x=24/1116`、`y=24/720`；其 stretch center 是
     `1092 × 696`。复制文字安全区另按 source 左右各 `30px`、上下各
     `24px` 检查，得到 `1080 × 696`。
  5. 写入
     `generated/chat/copy/v1_3/a/CHAT.COPY.SURFACE.V1_3.candidate.png`；
     在通过原尺寸、`380 × 248`，以及 `540 × 420` 书框所对应的
     `480 × 348` 正文尺寸拉伸预演前，
     不创建 tracked source。
- B 表面 donor 与确定性状态：
  1. 验证 V1.2 第一次 B1 raw 为 `1254 × 1254 RGB`，SHA-256 为
     `682459afa17ac43d3961085d211b340ed446152cf52fd2e7b250422316180e4b`。
     只允许此文件；V1.2 retry2 不进入 V1.3。
  2. 对 donor 每个像素计算 `d = G - max(R,B)`。`d >= 96` 时 Alpha 为
     `0`，`d <= 16` 时 Alpha 为 `255`，中间用 smoothstep
     `t=(96-d)/80; a=round(255*t*t*(3-2*t))`。半透明像素把绿色通道上限
     压到 `max(0,max(R,B)-1)`；不增加羽化、阴影、描边或新表面。
  3. 只读取半开 crop `(360,242)–(915,994)`。该固定 `555 × 752` 区域由
     V1.2 raw 的绿色优势预检得出，完整包含一个双页夹对象；crop 外所有
     像素，包括错误画布与绿底，全部丢弃。
  4. 把 crop 以 Lanczos 归一化为 `352 × 416 RGBA`，放入共同逻辑画布
     `(336,304)–(688,720)`。归一化结果只是 donor surface，不直接成为
     候选。
  5. 两状态使用以下逐像素固定 polygon；坐标均在 `1024 × 1024` 工作画布：
     - lower：
       `(336,348),(674,332),(687,719),(344,711)`
     - upper closed：
       `(370,328),(650,340),(638,672),(358,690)`
     - upper open：
       `(370,328),(650,340),(678,684),(350,704)`
     - clamp：
       `(420,312),(584,304),(606,338),(592,378),(414,370),(402,340)`
  6. lower 在 off／on 中都取 A 候选半开 crop
     `(0,0)–(600,744)`，Lanczos 缩放到 `352 × 416` 后放入共同外接框，
     再以 lower polygon 裁出，保证逐像素相同；clamp 从 normalized donor
     的 clamp polygon 读取，在两状态中逐像素相同。
     upper 从 normalized donor 的 closed upper polygon 读取：off 原位；
     on 只按四角对应关系把 upper closed 确定性透视变形到 upper open。
     图层固定为 lower → upper → clamp。
  7. 两状态最终 Alpha 分别与 `lower ∪ upper-state ∪ clamp` 相乘；共同可见
     外接框必须精确为 `(336,304)–(688,720)`。不得用此 mask 保存 donor 的
     错误轮廓；候选的轮廓、开合差和锚点全部来自上述 polygon。

### 输出、裁切与验收

- A：只有一张精确 `1140 × 744 RGBA` 的确定性矩形候选；不产生 A raw，
  不经过色键或 Alpha 清理。九宫格固定边与文字安全区按上节的两套独立
  切线检查，不再混用。
- B：不产生新 raw、不调用 ImageGen、不上传任何图。只从固定 SHA donor
  裁取已声明表面，确定性生成 off／on 两张 `1024 × 1024 RGBA` 候选；
  两者的可见外接框、锚点和 Alpha 合同相同。
- A 只允许九宫格；B 后续确定性合成两个 UV cell，状态切换不改几何。
- 禁止烘焙：聊天消息、玩家名、颜色码、选择高亮、光标、Tab、输入条、
  未读、现代复制图标、状态标签、按钮牌、ChatMenu 和任何完整聊天框结构。
- 验收预演：
  - 在 `440 × 320` 当前 V3 主框中分别重组 off／on；
  - on 预演显示 `380 × 248` 抄录纸和安全区，不烘焙真实聊天内容；
  - A 另以 `380 × 248` 和 `540 × 420` 书框对应的 `480 × 348` 正文尺寸
    检查九宫格 stretch zone，不接受接缝、重复突变或纸纹频率漂移；
  - 以 `22 × 26` 和 `28 × 32` 调试覆盖分别检查视觉与命中区。
- 回退：任何资产、Frame 或状态缺失时 `chatcopy` 继续不加载；不得恢复
  pfUI 黑色覆盖层作为 AEUI 局部替代。

## 最终执行正文

状态：`production`。用户已于 `2026-07-29` 明确授权
`CHAT.COPY.V1.3`，允许按固定 SHA 只复用 V1.2 第一次 B1 raw 的表面像素，
并明确要求不进行任何外部上传。本版本不调用 ImageGen、不上传图片，也不
复用 V1.2 的错误画布／坐标。以下确定性正文已冻结，执行时不得改写。

### A：确定性连续抄录纸面

以下是确定性构建合同，不是 ImageGen Prompt：

```text
Input only assets/source/chat/v3/ChatBookFrame_Master_v3.png at its recorded
SHA-256. Crop the half-open rectangle (270,130)-(1338,827), resize that exact
accepted quiet parchment sample to 1140 by 744 RGBA with Lanczos resampling,
and preserve fully opaque alpha. Add no generated pixels, border, deckle,
second leaf, shadow, outline, stain, text, or control.

Treat source x=24 and x=1116, y=24 and y=720 as the nine-slice cuts. The
nine-slice stretch center is 1092 by 696. Separately, reserve 30 source pixels
at left and right and 24 source pixels at top and bottom for the copy-text
safe area, producing 1080 by 696. Do not conflate those two rectangles.

Write only an ignored candidate under generated/chat/copy/v1_3/a/. Do not
promote it to assets/source, export a runtime TGA, or modify Lua until the
candidate and its real-size stretch previews are explicitly accepted.
```

### B：固定 donor 的确定性双状态

```text
Use only the internally reviewed surface regions from
generated/chat/copy/v1_2/b1/CHAT.COPY.TOGGLE.CLOSED.V1_2.raw.png.
Require a 1254 by 1254 RGB input with SHA-256
682459afa17ac43d3961085d211b340ed446152cf52fd2e7b250422316180e4b.
Do not call ImageGen and do not upload this or any other image.

For every donor pixel compute d = G - max(R,B). Set alpha to 0 when d is at
least 96 and to 255 when d is at most 16. Between those values use
t = (96-d)/80 and alpha = round(255*t*t*(3-2*t)). For partially transparent
pixels cap G at max(0,max(R,B)-1). Add no feather, shadow, outline, highlight,
stain, or generated pixel.

Crop only the half-open rectangle (360,242)-(915,994), then resize that exact
555 by 752 RGBA donor to 352 by 416 with Lanczos resampling and place it at
(336,304)-(688,720) in a 1024 by 1024 transparent working canvas. Treat the
result as surface material only, never as geometry.

Use these exact polygons in working-canvas coordinates:
lower = (336,348),(674,332),(687,719),(344,711)
upper_closed = (370,328),(650,340),(638,672),(358,690)
upper_open = (370,328),(650,340),(678,684),(350,704)
clamp = (420,312),(584,304),(606,338),(592,378),(414,370),(402,340)

For the lower leaf, crop (0,0)-(600,744) from the deterministically derived A
parchment sample, resize it to 352 by 416 with Lanczos, place it at the shared
outer box, and clip it by lower. Use those exact pixels in both states. Read
the clamp surface from the normalized donor inside clamp and keep it
pixel-identical between states. Read the upper-leaf surface from the
normalized donor inside upper_closed. For off, place that upper surface
unchanged. For on, transform only that upper surface by the four ordered
corner correspondences from upper_closed to upper_open. Composite in the
fixed order lower, upper, clamp.

Multiply final alpha by lower union upper_state union clamp. Both outputs
must have an exact visible bounding box of (336,304)-(688,720), one connected
two-leaf-and-clamp object, no visible green spill, and no pixels outside their
declared masks. Write the off state to
generated/chat/copy/v1_3/b/CHAT.COPY.TOGGLE.CLOSED.V1_3.candidate.png and the
on state to
generated/chat/copy/v1_3/b/CHAT.COPY.TOGGLE.OPEN.V1_3.candidate.png. Write
only ignored RGBA candidates and review previews under
generated/chat/copy/v1_3/. Do not create assets/source, runtime media, or Lua
changes until both states and their 22 by 26 assembly previews are explicitly
accepted.
```

## 执行记录

- 日期：`2026-07-29`
- 授权版本 commit：
  `77fb32f804d0b06700fcef4f9562318635866baa`
- 用户授权：明确授权 `CHAT.COPY.V1.3`；允许按固定 SHA 仅复用 V1.2
  第一次 B1 raw 的表面像素；禁止任何外部上传
- 本地工具：
  [`build_chat_copy_v1_3_candidates.py`](../../../../tools/build_chat_copy_v1_3_candidates.py)
- ImageGen／网络／上传：均未发生；V1.3 无新 session／result ID，构建记录
  为 `network_access=false`、`imagegen_called=false`、
  `external_uploads=[]`
- A：验证接受源 SHA 后按冻结 crop 与 Lanczos 重建；输出路径、尺寸和 SHA
  见元数据。`848160` 个像素全部不透明；无绿残留。
- B donor：严格验证 `1254 × 1254 RGB` 与 SHA
  `682459afa17ac43d3961085d211b340ed446152cf52fd2e7b250422316180e4b`；
  retry2 未读取。
- B closed：`134459` 不透明、`160` 半透明、`913957` 透明像素；可见
  bbox `(336,304)–(688,720)`；一个连通对象；无绿残留。
- B open：`134471` 不透明、`157` 半透明、`913948` 透明像素；可见
  bbox `(336,304)–(688,720)`；一个连通对象；无绿残留。
- 确定性层：lower／clamp 共享层 SHA 分别为
  `226c974f51d3eadfec56990e8c12d583c8becbe847b72390bdfbd77a8573b6f6`
  与
  `436c2f1b911e5453347b9007c543b7058d553f7c74c51116b4715aae7581168f`；
  状态差异只在 upper 合并区 `(350,329)–(679,705)`。
- 内部技术重试：
  1. 首次构建在插值后发现 closed 有 `6` 个半透明强绿像素，停止写出最终
     B；把已授权的半透明绿通道上限重放到每次插值之后。
  2. 第二次构建在 open 发现一个位于 `(373,329)`、`alpha=1` 的独立
     透视振铃像素；加入仅允许移除面积不超过 `4px` 且最大 Alpha 不超过
     `2` 的亚像素孤岛清理。更大的断裂仍会使构建失败。
  3. 第三次构建通过所有确定性断言；候选 SHA 如元数据所列。

## 审查记录

- 范围／对象身份：A 只对应 `ChatFrameScrollN` 背景；B 的两个状态只对应
  同一个 `pfChatCopyButton`，没有额外控件或烘焙文字。范围通过。
- 语义／物理：`352 × 416` 审查图能识别 lower、upper 和皮夹，on 也只
  改变 upper；但在合同要求的 `22 × 26` 真实尺寸下，两态都退化成同一枚
  浅色矩形书签，开合语义与“双纸叶页夹”身份不可读。此项失败。
- 透视／图层：A 是复制文字下方的连续纸面；B 是书本右侧页边上的独立
  Button。两者不覆盖 Tab 或输入条。
- 美术一致性：A 继续匹配已接受 V3 纸面。B 的纸／皮革表面、暖光和色域
  延续 donor，但硬 polygon 在右边与下边裁出规则直线；缩到运行时时纸张
  与主书阅读面合并，皮夹只剩约两像素暗线。此为次要失败。
- 对象／状态合同：A 的 `1092 × 696` stretch center 与
  `1080 × 696` text-safe center 继续分离。B 只有 off／on 两个物理状态；
  hover 仍由 runtime Alpha 派生。
- 装配／尺寸：A 在 `380 × 248` 与 `480 × 348` 无接缝或纹理突变；
  `1080 × 696` text-safe 与 `1092 × 696` stretch center 均正确。B 的
  共同外接框、`28 × 32` 命中区和书框锚点正确；但真实尺寸并排预演
  视觉上几乎相同。`22 × 26` 差异为 `491/572` 像素存在数值变化，但
  Alpha 差异均值只有 `0.021/255`、最大 `7/255`，综合色差主要来自轻微
  重采样，不能表达状态。
- 技术像素：A／closed／open 的尺寸、模式、SHA、Alpha、bbox、mask 外
  泄漏、连通性和绿残留全部通过；技术指标不能覆盖状态语义失败。
- 结论：`candidate-rejected / P3`
- 否决人：internal-review
- 日期：`2026-07-29`
- 第一个失败门禁：真实运行时尺寸的状态语义／物件身份
- 本版本保留：A 的全部确定性合同与 SHA；固定 donor 的受限职责、零上传
  边界、共同外接框和本地 Alpha 技术流程
- 下一版本必须改变：先在 `22 × 26` 锁定能读出的 closed／open 独立轮廓，
  增大上层纸叶开合差与层间接触阴影的屏幕像素占比，并避免硬 polygon
  把页边裁成规则矩形；再反推高分辨率 mask。未经新版本授权不执行。
- 用户结论与日期：无；内部审查已退回，未进入 source 接受门禁
- 本版本无 tracked source／runtime／Lua。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| V1 | commit `69ada1f`；session `019fae2a…`／`019fae2c…` | `candidate-rejected` | 不上传完整 UI；A 单物件 edit；B 按真实持久状态拆分 |
| V1.1 | commit `8b0a4e3`；A session `019fae4d…`／result `ig_0d80…`；B1／B2 因门禁停止 | `candidate-rejected` | A 必须锁死外接框；四条边的 stretch zone 不得由模型生成独特缺口；降低照片式纤维与中性光漂移 |
| V1.2 | commit `3e9eb8e`；A SHA `ed4e1c…`；B1 sessions `019fae80…`／`019fae83…`，results `ig_063f…`／`ig_0a42…` | `candidate-rejected / P3` | 保留 A；B 将 ImageGen 降为表面 donor，所有像素几何归确定性工具 |
| V1.3 | 授权 commit `77fb32f`；A SHA `ed4e1c…`；closed／open SHA `e8a3840…`／`ba1134e…`；零 ImageGen／网络／上传；技术合同通过；真实尺寸并排与书框装配 | `candidate-rejected / P3` | 保留 A 与受限 donor 边界；在 `22 × 26` 先锁定可辨认的开合轮廓、层影和页夹身份 |
