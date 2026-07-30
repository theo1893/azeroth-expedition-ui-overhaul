# Quest Log 左页卷宗目录 V2

## 当前状态

- 工作范围：`QL-B0-B V2`；`QL-B0-A V2` 已由用户移出范围。
- 子状态：B `authority-blocked`；A `user-rejected / scope-removed`。
- 项目阶段：`P3`。
- 授权正文状态：B attempt 1／2／3 已完成并退回，下一次必须逐字使用本文件
  `QL-B0-B V2.r3` 完整正文；A V2.r4 只作为未执行草案，用户在任何 A5
  provider 调用前明确取消该对象，草案不得执行。
- 当前实际生图：A `4/5`；B `3/5`。
- 单段预算：最多 `5` 次实际生成／编辑。
- 原授权最坏总预算：`10` 次实际生成／编辑；A 在 `4/5` 主动停止后，有效
  最坏总实际调用变为 `9` 次。
- 流程错误：A `4`；B `1`，与实际生图次数分开记录。
- 固定执行器：`.codex/skills/imagegen-0-143-0/SKILL.md`，
  `@openai/codex@0.143.0`。
- 用户授权：`2026-07-30` 明确授权 `QL-B0-A V2` 与 `QL-B0-B V2`，
  允许分别上传固定 SHA 的 Image 1／Image 2；每段最多 `5` 次，最坏合计
  `10` 次。
- 当前门禁：`QL-B0-B V2.r3` 完整正文已提交，但用户现有上传授权只明确
  覆盖固定 Image 1／2。必须先取得对固定 SHA 的同循环 attempt 3 raw
  作为 Image 3 的显式上传授权，才能执行 B attempt 4 edit；不执行
  A attempt 5。任何 B 候选都只到 P3，不自动晋级 source 或 runtime。

## 为什么建立 V2

Turtle WoW 实机截图已经证明 QL-A2 V4 正常加载，但左页主体仍近似 pfUI：
当前 runtime 只拥有小尺寸的 QL-B1 墨记与 QL-B2 书签，没有列表内框、地区条
和任务行底板。旧 `23 × 15px`／`14px` 步进合同也让文字与状态层过密。

用户已确认下一方向为 `18 × 18`：保留真实任务数据、真实 Button、真实滚动
和脚本，只把同时显示的行窗口改为十八行，并为左页的大面积视觉对象建立独立
资源。当前 V1 runtime 在 V2 资源接受和导出前继续作为可回退实现，不把
`prompt-draft` 误记为已接入。

## 权威、输入与冲突审计

视觉裁决顺序：

1. Image 1：
   `assets/locked/quests/任务详情面板_视觉基准_v1.png`，
   SHA-256
   `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
   它是最高权威，定义正式公会任务卷宗的物件身份、粗厚手绘轮廓、
   暖赭纸面、暗木／旧皮与氧化黄铜关系、左上暖光和不完全规整的磨损。
2. `docs/modules/quests/ART_BASELINE.md`、
   `docs/modules/quests/SUBMODULE_ART_BASELINES.md` 与
   `docs/GLOBAL_ART_BASELINE.md`。
3. 本文件的真实对象、几何、状态、层序和禁止烘焙合同。
4. Image 2：
   `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，
   SHA-256
   `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
   它只提供当前 runtime 纸页接触色、材质尺度和受光连续性，不得覆盖
   Image 1 的物件身份与笔触。

冲突处理：

- Image 1 明确存在有所有权的地区条与任务条框。旧基线中“目录纸面保持连续，
  不生成逐行卡片”不能继续被解释为“整页没有任务条视觉”；V2 恢复薄型卷宗
  条目底板，但仍禁止现代不透明卡片、独立浮动面板和整页烘焙列表。
- Image 1 中不能映射到稳定真实对象的肖像、假图标槽、固定文字与装饰按钮
  不进入资源。
- 顶部筛选／控制、两套 ScrollBar、关闭和底部操作 Button 属于 `QL-C`，
  不得烘焙进 `QL-B0-A` 或 `QL-B0-B`。
- QL-B1／B2 已接受 source 只在 V2 接受后做确定性尺寸重导出；本批不重新
  生图。QL-B3 继续暂停，也不进入本批。

建议授权上传只包括上面固定 SHA 的 Image 1 与 Image 2。当前实机截图仅是
本地几何证据，不是本轮外部上传输入。

## 18 × 18 真实布局合同

- `QuestLogListScrollFrame` 阅读安全区保持
  `x=64, y=64, w=246, h=324 UI px`。
- V2 目标为 `QUESTS_DISPLAYED = 18`；活动窗口使用
  `QuestLogTitle1..18`。现有 `QuestLogTitle19..23` 不删除、不改脚本，
  只在 V2 模式隐藏；媒体或 adapter 失败时整体回退当前 P5／pfUI。
- 每个地区或任务 Button 为 `224 × 18 UI px`，纵向步进 `18px`，
  十八行总高恰好 `324px`。右侧 `22px` 永久留给间距与真实 ScrollBar。
- `QuestLogTitleN` 仍是唯一整行命中对象；所有新 Texture
  `EnableMouse(false)`，不得创建第二点击层。
- 地区 header 使用 Noto Serif SC SemiBold `12px`；普通任务使用
  LXGW WenKai `11px`。动态文字从行局部 `x=20` 起。
- 为后续 QL-B3 保留 type `x=176..186`、timer `x=187..197`、
  state `x=198..210`；追踪墨圈保留 `x=212..223`。这些覆盖不烘焙。
- V2 接受后，QL-B1 只确定性重导出为地区箭头 `14px`、追踪圈 `12px`；
  QL-B2 使用相同已接受 source 重导出为 `32 × 16` cell 内
  `30 × 16` 可见书签，锚点 `x=-12`，文字仍从 `x=20` 起。
- 维护刷新不得持续改写 Parent、Point、Width 或 Height；几何只在初始化、
  显示、缩放变更与明确的 Quest Log 更新边界重施。

## 组件合同

### `QL-B0-A V2` — `QUEST.LOG.LIST.INSET`（用户移出范围）

- 真实所有权：围绕 `QuestLogListScrollFrame` 的单一静态、无鼠标装饰框。
- runtime 显示外框 `262 × 340 UI px`，相对 `246 × 324` 阅读安全区四边
  各外扩 `8px`；固定尺寸，不九宫拉伸。
- 中央开口必须完全透明，恰好露出 `246 × 324 UI px` 连续纸面。
- 层序：QL-A2 SHELL 之上；全部行底板、书签、墨记、文字、真实 ScrollBar
  和 Button 之下。
- source 最终画布为 `1024 × 1024`、背景严格纯色 `#00FF00`。provider raw
  若使用其他正方形原生边长，候选审查只允许把完整画布等比归一化至
  `1024 × 1024`，不得裁切、拉伸、重定位或修补；这只是 provider-native
  inspection bridge，不是 source 例外。唯一物件的外接目标盒为
  `x=250..774, y=172..852`（`524 × 680px`）；内部纯绿色开口固定为
  `x=266..758, y=188..836`（`492 × 648px`）。它将以 `0.5` 等比缩为
  `262 × 340`，四边材料厚度为 `8px`，开口缩为 `246 × 324`。
- 不得包含纸面填充、逐行分隔、文字、地区条、任务条、滚动条、按钮、印章、
  书签或假图标槽。
- 用户于 `2026-07-30` 在 A `4/5` 后决定不需要该框。A5 未调用；四次
  候选均不进入 source／runtime，运行时继续直接露出 QL-A2 连续纸面。

### `QL-B0-B V2` — 地区条与任务条基础底板

- `QUEST.LOG.REGION.BACKPLATE` 与
  `QUEST.LOG.ROW.BACKPLATE` 分别作为真实 `QuestLogTitleN` Button 的
  背景 Texture；一个 source 基础物件对应一个逻辑对象。
- 两者 runtime 显示均为 `224 × 18 UI px`，不能遮挡动态文字、QL-B1、
  QL-B2、QL-B3 或 `QuestLogTitleNCheck`。
- source 为 `1024 × 1024` 纯绿色画布，恰好两个独立横条：
  - 地区条：`x=112..912, y=272..336`，`800 × 64px`；
  - 任务条：`x=112..912, y=688..752`，`800 × 64px`。
  两者均以约 `0.28` 等比缩为 `224 × 18`，不能相互接触。
- 地区条是低饱和暗橄榄色公会目录条，边缘可有克制的暗墨／氧化黄铜收口，
  中央必须安静以承载动态地区文字。
- 任务条是更浅、更薄的暖赭卷宗条目底板，带手工切边、轻微缺口与深棕墨线，
  仍能读出下方连续纸页；不是现代卡片。
- 只生成两枚 base。`normal／hover／pressed／disabled` 四态在接受后
  确定性导出：normal 为 base；hover 只向暖色高光混合 `15%`；pressed
  RGB 乘 `0.82` 并由 runtime 下移 `1px`；disabled 降饱和并降低运行时
  Alpha。轮廓与 Alpha 不因状态重绘。
- 未来 runtime atlas 为 `512 × 128`，`2` 列 × `4` 行，
  每格 `256 × 32`，`224 × 18` content 居中；本阶段不导出。
- 不生成假图标槽，不烘焙文字、等级、计数、墨记、书签、状态章、选择高亮、
  Button 命中区或 ScrollBar。

## 生产正文完整性预检

- 组件身份明确：pass。
- 真实对象、状态来源与鼠标所有权明确：pass。
- 固定输入、角色、SHA 与视觉优先级明确：pass。
- 画布、色键、source bbox、runtime 尺寸与层序明确：pass。
- 禁止烘焙项与 QL-C／QL-B3 边界明确：pass。
- 每段预算、repair envelope 与停止条件明确：pass。
- 结论：pass。

## 已撤销且不得执行的草案 — QL-B0-A V2.r4

> 用户于 `2026-07-30` 在任何 A5 provider 调用前决定“不需要这个框”。
> 下列草案只保留到本次提交作为取消边界证据，不是当前可执行正文；后续 Git
> 历史已足以保存它，不得再调用。

使用 `@openai/codex@0.143.0` 的固定 ImageGen 执行器，生成一张
`1024 × 1024` RGBA 位图；整张画布也是唯一的 `1024 × 1024` 归一化设计
网格，不得裁边。若 provider 使用不同的正方形原生边长，仍必须严格保持下面
坐标在完整画布中的比例，以便后续只做一次全画布等比归一化。所有不属于物件
的像素，包括外部背景和中央开口，都必须是完全均匀、无纹理、无渐变、无阴影、
无光晕、无色偏的精确 RGB `#00FF00`。画面中只允许有一个正面朝向、无透视
的 Quest Log 左页目录内框 `QUEST.LOG.LIST.INSET`。

输入角色必须严格遵守。Image 1
`任务详情面板_视觉基准_v1.png`
（SHA-256
`03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`）
是最高视觉权威：继承正式公会任务卷宗身份、2004 年前后香草魔兽二维手绘
笔触、略不规则但清楚的明暗切面、左上暖光、低饱和赭黄／烟黑／暗酒红与
氧化黄铜关系，以及被长期翻阅造成的不均匀磨损。不要复制 Image 1 的完整
书体、顶部控件、逐行内容、文字、图标、按钮、滚动条、封印或书签。

Image 2 `QuestLogBookShell_Master_v1.png`
（SHA-256
`91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`）
只用于匹配当前 runtime 的纸页接触色、材质尺度和受光连续性。不要复制完整
书壳、书脊、四角、页沟或纸页；Image 2 不得覆盖 Image 1 的物件身份、
轮廓语言和笔触。

先锁定中央纯绿开口，再只从开口向外画一笔薄装订描边；不要先画常规边框后
缩放。中央开口严格位于
`x=266..758, y=188..836`，恰为 `492 × 648px`，中心为
`(512, 512)`，宽高比为 `0.7593`。它的四条直边必须完整、连续、矩形且
保持纯绿。

沿这个开口的外侧只画一笔 `16px` 宽的可见材料描边。左侧描边只能占
`x=250..266`，右侧只能占 `x=758..774`，顶部只能占
`y=172..188`，底部只能占 `y=836..852`。最终唯一物件的可见外接盒因此
严格为 `x=250..774, y=172..852`、`524 × 680px`，宽高比
`0.7706`。不得让任何皮革、暗边、磨损、投影或高光越过这四条外边界。

这不是有“框条宽度”的常规奇幻边框，而是一笔 UI 级细描边。任何直边处都
只有这 `16px` 一层；禁止第二圈内框、暗色衬框、阴影边、凸起边、平行高光
或外侧包边。理论可见材料约为 `37,504px`、占画布约 `3.58%`；所有纯绿
区域合计至少约占 `96.4%`。如果皮革纹理、磨损或金属细节无法放进
`16px`，必须简化或舍弃细节，绝不能加宽描边。

缩到 `262 × 340 UI px` 后，这一笔材料只能形成四边各 `8px` 的嵌边，
必须完整露出 `246 × 324 UI px` 的十八行阅读区。

这个物件是嵌在暖赭纸页接缝处的“薄目录装订唇边”，不是完整书壳、窗框、
门框、肖像框或独立厚面板。主体只用深胡桃木色旧皮与烟黑手绘硬边。不要画
黄铜包角、夹片或金属板；若必须表达 Image 1 的氧化黄铜关系，只允许左上与
右下各一个不超过 `4 × 4px` 的暗哑针头色点，完全藏在 `16px` 描边内。
禁止把浅色羊皮纸、砂岩、石板或厚木条当作四边主体。四边可有轻微手工起伏、
缺口和不均匀磨损，但必须始终留在 `16px` 描边内。

只保留低频、概括的二维手绘明暗，不要连续高光线、深黑内阴影、均匀压花、
高清裂纹或照片级皮革。不要为了展示材质而加宽任何一边。轮廓要能看出手工
切边，但不能弯成波浪或破坏矩形开口。整体应像 Image 1 书页上的小型目录
装订细节，而不是单独展示的豪华奇幻边框。

禁止绘制任何纸面填充、行分隔、地区条、任务条、文字、数字、图标、按钮、
滚动条、滑块、选择高亮、书签、印章、状态章、假肖像槽或假图标槽。禁止现代
矩形面板、暗黑祭坛、聊天旧书风格、细金框、宝石、巨大徽章、浮夸雕花和常亮
发光。

输出前逐项自检：先确认纯绿开口正好是
`[266,188]..[758,836]`，再确认材料只向外延伸 `16px` 到
`[250,172]..[774,852]`；可见材料约占画布 `3.58%`，绿色约占
`96.4%`；细节装不下时已经舍弃，没有加宽；外盒以外与开口以内都是同一个
精确 `#00FF00`；没有第二圈内框、金属包角、投影、绿色纹理或抗锯齿污染
扩散到安全区；内框正面、无透视、无拉伸；在 `262 × 340 UI px` 显示时
不会遮挡 `246 × 324 UI px` 的十八行内容；没有任何被禁止的动态或交互
内容。

## 当前执行正文 — QL-B0-B V2.r3

使用 `@openai/codex@0.143.0` 的固定 ImageGen 编辑器，以 Image 3 为
唯一编辑目标，输出一张 `1024 × 1024` RGBA 位图；这也是唯一的归一化
设计网格。不要重新发明两个物件，不要改变它们的材料身份、综合色或自然
磨损方向；只修正两个既有横条的尺寸、中心和纯绿背景。

输入角色必须严格遵守。Image 1
`任务详情面板_视觉基准_v1.png`
（SHA-256
`03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`）
是最高视觉权威：继承正式公会任务卷宗身份、2004 年前后香草魔兽二维手绘
笔触、粗厚略不规则轮廓、明确明暗切面、左上暖光、低饱和赭黄／烟黑／暗酒红
与氧化黄铜关系，以及不均匀的翻阅磨损。不要复制 Image 1 的完整书体、顶部
控件、文字、图标、肖像槽、按钮、滚动条、封印、书签或完整列表。
Image 1 中的黄铜只定义整套卷宗的综合色关系，本批两个细薄目录底条不得
绘制任何黄铜物件、端帽、包角、徽记、铆钉或几何装饰。

Image 2 `QuestLogBookShell_Master_v1.png`
（SHA-256
`91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`）
只用于匹配当前 runtime 的暖赭纸页接触色、材质尺度和左上受光连续性。
不要复制完整书壳、书脊、四角、页沟或纸页；Image 2 不得覆盖 Image 1 的
物件身份、轮廓语言和笔触。

Image 3 `QL-B0-B_V2_r2_attempt-03_raw.png`
（SHA-256
`5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721`）
是本次同循环编辑目标。只继承 Image 3 中恰好两个正面、无端件、无金属框的
平面横条：上方低饱和暗橄榄涂色厚纸／极薄旧皮，下方更浅的暖赭笔洗／薄纸；
保留两者现有的低频表面色差、自然不对称收边和上暗下浅关系。不要继承
Image 3 的横条尺寸、纵向位置或近绿色背景；Image 3 不能覆盖 Image 1 的
最高美术权威。

把 Image 3 完整画布先等比解释为 `1024 × 1024` 设计网格，不裁画布。
当前上条可见 bbox 约为 `[69,317]..[954,421]`、`885 × 104px`；
当前下条约为 `[69,626]..[954,730]`、`885 × 104px`。这两个旧 bbox
只是待修正输入，不得原样保留。

对上条 `QUEST.LOG.REGION.BACKPLATE` 只做一次几何编辑：以其中心为基准，
宽度缩放为当前的约 `90.40%`，高度缩放为当前的约 `61.54%`，然后把中心
移动到精确 `(512,304)`。最终唯一可见 bbox 必须严格成为
`[112,272]..[912,336]`、`800 × 64px`、`12.5:1`。保留现有暗橄榄平面
纸／薄皮表面和自然边缘，不增加细节；设计网格中上、下、左、右的视觉边厚
均不得超过 `3px`，中央至少 `780 × 54px` 安静。

对下条 `QUEST.LOG.ROW.BACKPLATE` 做同样的独立几何编辑：宽度缩放为当前的
约 `90.40%`，高度缩放为当前的约 `61.54%`，然后把中心移动到精确
`(512,720)`。最终唯一可见 bbox 必须严格成为
`[112,688]..[912,752]`、`800 × 64px`、`12.5:1`。保留现有暖赭平面
笔洗／薄纸表面和自然边缘，不增加细节；设计网格中上、下、左、右的视觉
边厚均不得超过 `2px`，中央至少 `784 × 56px` 安静。

几何编辑完成后，清除 Image 3 中两个旧 bbox 的全部残影，并把两个新 bbox
以外的每一个像素统一替换为精确 `#00FF00`。外部背景必须完全均匀、无纹理、
无渐变、无阴影、无光晕；两个物件之间不接触。不要对两个横条做第二次自由
重绘，不要增加第三个物件，也不要让旧位置留下绿色以外的像素。

这里只生成两个 normal base，不绘制 `normal／hover／pressed／disabled`
四态，不绘制状态矩阵。禁止绘制文字、数字、等级、任务计数、箭头、勾选圈、
书签、选择高亮、类型章、计时章、完成／失败章、按钮、滚动条、肖像槽、
假图标槽或任何命中区。禁止两端菱形、十字、珠宝形状、厚金属包边、双层
闭合边框和整齐牌匾轮廓。禁止现代 UI 卡片、照片级皮革、完美镜像角、
细金框、高频雕花、宝石与常亮发光。磨损必须低频且不对称，但不能借磨损
越过固定 bbox。

输出前逐项自检：恰好两个独立横条；上方唯一可见 bbox 正好是
`[112,272]..[912,336]`，下方唯一可见 bbox 正好是
`[112,688]..[912,752]`，两者都是 `800 × 64px`、`12.5:1`；bbox 外与
两物件之间全部是同一个精确 `#00FF00`，旧位置没有残影；上条中心
`(512,304)`、下条中心 `(512,720)`；两条确实是对 Image 3 正确平面物件
的缩放与移动，不是新画的横幅；没有菱形、徽记、端帽、铆钉、金属轨道或
闭合金属框；缩到各自 `224 × 18 UI px` 时，暗橄榄地区条与暖赭任务条仍可
区分，但不会把十八行目录变成十八块厚牌匾；没有任何被禁止的动态、状态或
交互内容。

## Repair envelope 与计数

每段第一次调用使用该段完整正文与固定 Image 1／2。后续 repair 只能在同段
前一次候选上做边界内 edit，并必须再次携带该段完整正文：

- A 只允许修正单物件数量、外盒／开口 bbox、纯绿色污染、透视、被禁内容、
  过度工整或与 Image 1 美术 DNA 不一致；不得改变为另一种物件或加入纸面。
- B 只允许修正两物件数量、各自 bbox、间距、纯绿色污染、两类材料区分、
  被禁内容、过度工整或与 Image 1 美术 DNA 不一致；不得新增四态或完整 UI。
- 单段达到 `5/5` 仍失败时立即标记
  `candidate-rejected / repair-budget-exhausted`，不得借用另一段预算。
- provider／保存／包装器错误单列，不自动计入实际生图；只要已产生可审查
  位图，就计入一次 actual generation。
- 每个 countable output 必须依次完成：原尺寸语义／美术检查、纯绿色与
  source bbox 检查、确定性透明预演、`262 × 340` 或 `224 × 18` 真实排版
  预演。未通过时只能在同段 envelope 内修复。

## 执行账本

| 段 | 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---|---:|---|---|---|---|---|---|---|
| A | 1/5 | `QL-B0-A V2`／`8e934f6` | generate | fixed child session `019fb343-1f5c-7c83-94d4-a89c7b11451f`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/inset/attempt-01/raw/QL-B0-A_V2_attempt-01_raw.png`；SHA `c089b2069ec34ac6be089fba36dfc0fa7835e1c208acd7804f277ec30e602224` | source 画布／几何／色键：raw 为 `1254 × 1254 RGB`，归一化可见 bbox 约 `154..870 × 53..963`，不是目标盒；背景不是精确 `#00FF00` | 保留“单一正面空框、无动态内容”；V2.r1 改为严格中心、薄 `16px` 带、限制材料和完整设计网格比例，仍只上传固定 Image 1／2 | `candidate-rejected`；A 为 `1/5` |
| A | 2/5 | `QL-B0-A V2.r1`／`c484357` | generate | fixed child session `019fb354-1d02-78f3-8d01-9cde28c841bf`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/inset/attempt-02/raw/QL-B0-A_V2_r1_attempt-02_raw.png`；SHA `64990bc5dd6f38ee0bce7f746a9335c265a9a15dd385875e4f467b106e329024` | source 几何／色键：归一化外框约 `585 × 799`、开口约 `501 × 710`，仍不是目标 `524 × 680`／`492 × 648`；背景不是精确 `#00FF00` | 保留暗酒红旧皮、去除浅色厚板、单一正面空框；V2.r2 进一步按画布百分比收小、禁止第二圈内框，只留左上／右下两个微型非对称黄铜接缝 | `candidate-rejected`；A 为 `2/5` |
| A | 3/5 | `QL-B0-A V2.r2`／`2d05f77` | generate | fixed child session `019fb35e-6697-71f3-b2b7-f6033ef290d2`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/inset/attempt-03/raw/QL-B0-A_V2_r2_attempt-03_raw.png`；SHA `92ce740a8812d2c5fee96ae6152cac482458fa958b683795abf742dc792a723c` | source 几何／色键：归一化外框约 `585 × 838`、开口约 `510 × 764`，高度比 attempt 2 更偏离；背景不是精确 `#00FF00` | 保留单层暗皮、仅左上／右下两枚非对称黄铜；V2.r3 明确宽高比、3.58% 可见材料面积与任何直边最多 16px | `candidate-rejected`；A 为 `3/5` |
| A | 4/5 | `QL-B0-A V2.r3`／`366a32c` | generate | fixed child session `019fb367-828c-71a2-a5b8-088bcf4e1472`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/inset/attempt-04/raw/QL-B0-A_V2_r3_attempt-04_raw.png`；SHA `f2d03067e47578a8444ec8efb4d9548f185ab320152e8cf9d4fdcd7c9b44ef4f` | source 几何／色键：开口已接近，但归一化外框约 `581 × 763`，可见材料占 `9.74%` 而非 `3.58%`；背景不是精确 `#00FF00` | 保留外框宽高比、单层暗皮与开口位置收敛；V2.r4 改为“先锁开口，再只向外画一笔 16px”，细节装不下即舍弃并取消黄铜包角 | `candidate-rejected`；A 为 `4/5` |
| A | — | `QL-B0-A V2.r4`／未冻结为 production | cancelled before generation | 无 child session／provider result | 无输出 | 用户明确认为该框没有必要 | 保留 A1–A4 审查证据；删除 source／runtime 路线，继续露出 QL-A2 连续纸面 | `user-rejected / scope-removed`；A 停在 `4/5` |
| B | 1/5 | `QL-B0-B V2`／`e3ab929` | generate | fixed child session `019fb37c-4303-7c13-9208-06c86d57abbe`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/backplates/attempt-01/raw/QL-B0-B_V2_attempt-01_raw.png`；SHA `ddf18110041b24b700077f52fcaeabd48340739966b067edc6495092f574a195` | 语义／物理：两个对象均成为带两端菱形假徽记、厚黄铜闭合边和浮雕体积的金属牌匾；违反底板身份与禁止假图标合同 | 保留恰好两个独立正面横条、暗橄榄／暖赭区分和低频旧化；V2.r1 删除全部端部装饰与金属框，严格限制 `12.5:1` bbox 和 7px／4px 边厚；只用固定 Image 1／2 重新生成 | `candidate-rejected`；B 为 `1/5` |
| B | 2/5 | `QL-B0-B V2.r1`／`7962924` | generate | fixed child session `019fb386-2fd3-76e3-b11b-1828fec80275`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/backplates/attempt-02/raw/QL-B0-B_V2_r1_attempt-02_raw.png`；SHA `0b948e68cb50c1bf10fede8dcb473f6d2b33680f81c6d29366895fae440effab` | source 几何／色键：语义已修正，但归一化两条均约 `916 × 102`，不是 `800 × 64`；背景中位色不是精确 `#00FF00` | 保留无端件、无金属框的平面暗橄榄／暖赭纸条和真实排版层级；V2.r2 以中心、画布百分比、112px 绿边距、64px 高度和 3px／2px 边厚收紧几何，只用固定 Image 1／2 重新生成 | `candidate-rejected`；B 为 `2/5` |
| B | 3/5 | `QL-B0-B V2.r2`／`eddca40` | generate | fixed child session `019fb38e-19d1-7a70-9e4a-efdb8bff70c1`；built-in `image_gen` 返回图片 | raw `generated/quests/QL-B0/v2/backplates/attempt-03/raw/QL-B0-B_V2_r2_attempt-03_raw.png`；SHA `5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721` | source 几何／色键：归一化两条均约 `885 × 104`，上条中心下移、下条中心上移，固定 cell 裁切丢失主体；背景仍非精确色键 | 保留两个平面纸条的综合色、自然边与无装饰语义；V2.r3 以本 raw 为同循环 Image 3，只缩放／移动到精确 bbox 并清除旧位置，Image 1／2 权威不变 | `candidate-rejected`；B 为 `3/5` |

| 流程错误 | 段／正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | `npx` 写入用户 npm cache 时返回 `EPERM`；无图片、无 provider result、无生成证据 | 保持授权正文与 Image 1／2 不变；改用 `generated/` 下独立 npm cache，并以获准网络环境重试 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E2 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | 独立 npm cache 下载 `@openai/codex@0.143.0` 时连接被重置，npm 日志为 `ECONNRESET`；固定包未完成安装，空工作目录中无图片，进程管理记录与 session 中均无 child／provider 证据 | 保持授权正文与 Image 1／2 不变；复用已下载进独立 cache 的固定包内容，以持久 stdout／stderr 的隐藏后台执行器完成安装及执行，避免外层短超时截断 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E3 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | Windows PowerShell 5 按本地代码页读取无 BOM 的忽略目录 launcher，正文标题与中文 Image 1 路径在上传前失真，授权正文抽取失败；无图片、无 provider result | launcher 改为纯 ASCII 路由：按标题中的 `QL-B0-A V2`／`QL-B0-B V2` 标识抽取正文，并按授权 SHA-256 在目录中解析 Image 1；固定正文与输入不变 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E4 | A／`QL-B0-A V2.r1`／`b03a81a` | fixed CLI 未启动；无 child session／result | launcher 的旧正文正则只允许 A 标题恰好结束于 `V2`，没有接受 `.r1` 后缀；在 stdin 生成与上传前停止，无图片、无 provider result | 正则只扩展为接受 `V2.rN` 标题；独立校验的 V2.r1 正文 SHA-256 为 `bc93f2c47d338a3650b948ed213035d0c5a759bd6aeba01cf8b4acc16008d65d`，正文、Image 1／2 与执行参数不变 | `process-error`；不占生图额度，A 仍为 `1/5` |
| B-E1 | B／`QL-B0-B V2.r3`／`5e7a9d6` | fixed CLI 未启动；无 child session／result | 执行器上传审批在进程启动前拒绝：用户现有授权只明确涵盖固定 SHA 的 Image 1／2，尚未明确授权同循环 attempt 3 raw 作为 Image 3；没有上传、图片、provider result 或生成证据 | 保持已提交 V2.r3 正文、Image 1／2 和 B `3/5` 不变；暂停并向用户展示 Image 3 精确 SHA 与用途，取得显式授权后才重试同一正文 | `authority-blocked / process-error`；不占生图额度，B 仍为 `3/5` |

## A attempt 1 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb343-1f5c-7c83-94d4-a89c7b11451f`。子进程打印的
  `user` 区块包含完整授权正文，正文 UTF-8 SHA-256
  `15156eeb17caac4d88b1e6072808adbbb31ad9acf22bc096cab01c8d33f926d3`；
  没有 wrapper 递归。provider 已返回图片，因此计为 A `1/5`。
- 输入：只上传授权的 Image 1／Image 2；路径与本文件固定 SHA 一致。
  imagegen 未另行报告 revised prompt，实际传入正文以上述完整 `user`
  区块为准。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `c089b2069ec34ac6be089fba36dfc0fa7835e1c208acd7804f277ec30e602224`。
  child copy、provider cache 与本地 raw 三者 SHA 完全一致。
- 色键／透明候选：raw 的边界中位色为 `#04F80C`，不是合同要求的精确
  `#00FF00`，且背景存在大量近绿色变化。只为审查使用固定脚本
  `remove_chroma_key.py --auto-key border --soft-matte
  --transparent-threshold 12 --opaque-threshold 96 --spill-cleanup`；
  透明候选 SHA-256
  `da06fdd07405610082aa4f03f31f6e7ca7fe042a87e789a4bdaaa87ec0443c60`，
  Alpha 为 transparent `1205314`、partial `8042`、opaque `359160`，
  可见强绿色残留 `0`。
- 几何：透明候选 native 可见 bbox 为
  `[188,65,1065,1179]`，尺寸 `877 × 1114`；完整画布等比归一到
  `1024` 设计网格后约为 `[154,53,870,963]`，远大于目标
  `[250,172,774,852]`。中央开口 native 为
  `[287,177,961,1068]`，bbox-fit 到 `262 × 340` 后仅约
  `201 × 272`，不是 `246 × 324`。
- 语义／透视：单一物件、正面、中央开口、无文字／按钮／滚动条／状态内容，
  这些部分通过。
- 美术：退回。四边主体变成浅色羊皮纸／砂岩厚板，四角是大面积对称黄铜包角
  与铆钉，内部又叠一圈厚暗木框；它是完整奇幻窗框而不是嵌在纸页上的薄目录
  装订唇边。整体过度对称、装饰重复且偏高清写实，没有继承 Image 1 中粗厚
  手绘但不完全规整的卷宗边缘关系。
- 严格真实排版：`676 × 464`、100% runtime、当前 QL-A2 shell、十八个
  `224 × 18` 行槽、真实 QL-B1／QL-B2 runtime marks、代表性中文任务密度；
  按固定 source 盒 `[250,172,774,852]` 裁切后，候选盒恰落在错误的中央
  开口内，运行时完全看不到内框。预演 SHA-256
  `919f7624b4c9def6c5021ea43a7a5cd0e4be7d65e3bc0e5408d7d8b6a5531260`，
  路径
  `generated/quests/QL-B0/v2/inset/attempt-01/previews/QL-B0-A_V2_attempt-01_contract-layout_676x464.png`。
- 非权威美术排版：为观察物件本身另做 actual-bbox-fit 预演，SHA-256
  `a4834e2def457ff2c0c3a250de8cb7d57f4507f2c0509322b4ef1ad8f2656f95`；
  它显示厚框明显吞掉列表宽度与高度，但不代表允许 bbox-fit source 例外。
  预演中的右页样例文字与简化 ScrollBar 只用于现实密度／层序检查，不是
  QL-C／QL-D 美术。
- 判定：`candidate-rejected / repair-prepared / P3`。第一个失败门禁为
  source 画布／几何／色键；次要失败为组件身份与美术 DNA。不得进入用户
  复审、`assets/source/` 或 runtime。V2.r1 只在既有 A repair envelope 内
  收紧设计网格比例、外盒／开口、薄带厚度与材料反模式，不新增上传、对象、
  状态或视觉方向。

## A attempt 2 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb354-1d02-78f3-8d01-9cde28c841bf`。stdin 中的
  V2.r1 正文 UTF-8 SHA-256 为
  `bc93f2c47d338a3650b948ed213035d0c5a759bd6aeba01cf8b4acc16008d65d`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  A `2/5`。
- 输入：仍只上传授权的 Image 1／Image 2；没有上传 attempt 1 raw。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `64990bc5dd6f38ee0bce7f746a9335c265a9a15dd385875e4f467b106e329024`；
  child copy、provider cache 与本地 raw 三者 SHA 完全一致。
- 色键／透明候选：raw 边界中位色为 `#06F80D`，仍不是精确
  `#00FF00`。使用与 attempt 1 相同的确定性透明审查参数；透明候选
  SHA-256
  `1f1e8d1fde938c58f5b9329d4096cc4a58f879c5f94d57e2e6b738d6f1377e48`，
  Alpha 为 transparent `1410571`、partial `8761`、opaque `153184`，
  可见强绿色残留 `0`。
- 几何：native 可见 bbox `[268,138,984,1116]`，尺寸 `716 × 978`；
  归一到 `1024` 设计网格后约 `[219,113,804,911]`，尺寸
  `585 × 799`。中央开口 native `[320,191,934,1060]`，归一后约
  `[261,156,763,866]`，尺寸 `501 × 710`。比 attempt 1 收敛，但仍远离
  目标外框 `[250,172,774,852]`／`524 × 680` 与开口
  `[266,188,758,836]`／`492 × 648`。actual-bbox-fit 到
  `262 × 340` 后开口约 `225 × 302`，仍会遮挡十八行阅读区。
- 语义／材料：单一正面空框、无动态内容继续通过；浅色羊皮纸／砂岩厚板已
  消失，暗酒红旧皮与烟黑边方向明显优于 attempt 1，应保留。
- 美术：仍退回。它仍是双层奇幻边框：连续深黑内衬与外侧皮带共同造成约
  `18–19 UI px` 的厚边；四枚黄铜包角成对镜像，直线、接缝和磨损节奏过度
  规则，仍不像 Image 1 纸页上的小型非对称装订唇边。
- 严格真实排版：`676 × 464`、100% runtime、当前 QL-A2 shell、十八行与
  当前 QL-B1／B2 marks。固定 source 盒裁切后只残留很窄的左右边，上下边
  完全落在裁切区之外，无法形成四边内框。预演 SHA-256
  `1c5e122cb0cdd48bf54e86547b16ce8c0f5c1a8621e40ec760a96be028dee07d`，
  路径
  `generated/quests/QL-B0/v2/inset/attempt-02/previews/QL-B0-A_V2_r1_attempt-02_contract-layout_676x464.png`。
- 非权威美术排版：actual-bbox-fit 预演 SHA-256
  `964cbc3e1bae05e0c45e5b1728c72f74ee25e727c4ca2b18838847f7150a37b6`；
  它清楚显示上下内容被厚边压住，但不代表允许 bbox-fit source 例外。
- 判定：`candidate-rejected / repair-prepared / P3`。第一个失败门禁仍为
  source 几何／色键；美术身份是次要失败。不得进入用户复审、
  `assets/source/` 或 runtime。V2.r2 只保留已改善的暗皮材料，并在既有
  repair envelope 内进一步收紧尺寸、单层厚度与非对称黄铜关系。

## A attempt 3 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb35e-6697-71f3-b2b7-f6033ef290d2`。stdin 中的
  V2.r2 正文 UTF-8 SHA-256 为
  `af6f5a71ba250841234ea70c23264811b75fc4276cdbaddab071a9e0c897c534`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  A `3/5`。
- 输入：仍只上传授权的 Image 1／Image 2；没有上传 attempt 1／2 raw。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `92ce740a8812d2c5fee96ae6152cac482458fa958b683795abf742dc792a723c`；
  child copy、provider cache 与本地 raw 三者 SHA 完全一致。
- 色键／透明候选：raw 边界中位色为 `#05F809`，仍不是精确
  `#00FF00`。使用相同确定性透明审查参数；透明候选 SHA-256
  `e87224b0a3f660f63e041c3e291460a12a96b0ab7183c00a276a0b5021c85e4e`，
  Alpha 为 transparent `1424628`、partial `8657`、opaque `139231`，
  可见强绿色残留 `0`。
- 几何：native 可见 bbox `[269,110,985,1136]`，尺寸 `716 × 1026`；
  归一到 `1024` 设计网格后约 `[220,90,804,928]`，尺寸
  `585 × 838`。中央开口 native `[314,153,939,1088]`，归一后约
  `[256,125,767,888]`，尺寸 `510 × 764`。宽度基本停滞，高度比
  attempt 2 更偏离目标；actual-bbox-fit 到 `262 × 340` 后开口约
  `229 × 310`，仍不是 `246 × 324`。
- 语义／美术改善：单一正面空框、无动态内容继续通过；已去掉第二圈厚暗衬，
  只保留左上与右下两枚不同黄铜接缝，暗酒红旧皮与非对称方向应继续保留。
- 美术剩余问题：直边材料仍约为设计网格 `37–46px`，不是 `16px`；过长的
  竖向构图使其仍像独立瘦高展示框。皮面裂纹和连续亮边略显高清规则，缩小时
  仍形成约 `16–17 UI px` 厚边。
- 严格真实排版：固定 source 盒裁切后上下边再次完全落在裁切区之外，只能
  看到极窄左右残片，无法形成四边内框。`676 × 464`／100% runtime 预演
  SHA-256
  `4fc83fd50ec4345edba7dd5a3bc8ef243a35ceecac885ca5e228743d559819da`，
  路径
  `generated/quests/QL-B0/v2/inset/attempt-03/previews/QL-B0-A_V2_r2_attempt-03_contract-layout_676x464.png`。
- 非权威美术排版：actual-bbox-fit 预演 SHA-256
  `fe5737f80660a68c600fc5ff01a3a50e905cb7258c5934ac2f86a55d8763fb8d`；
  它显示非对称方向更好，但上下十八行仍被厚边压住。
- 判定：`candidate-rejected / repair-prepared / P3`。第一个失败门禁仍为
  source 几何／色键；不得进入用户复审、`assets/source/` 或 runtime。
  V2.r3 只在既有 repair envelope 内把同一几何改写为宽高比、可见面积占比
  与最大直边厚度，保留 attempt 3 已改善的材料与非对称关系。

## A attempt 4 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb367-828c-71a2-a5b8-088bcf4e1472`。stdin 中的
  V2.r3 正文 UTF-8 SHA-256 为
  `953bf86bb7e24628ee52d7b05bae5f551a41d1158a16ace94600ea50fe65b4f3`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  A `4/5`。
- 输入：仍只上传授权的 Image 1／Image 2；没有上传任何前次 raw。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `f2d03067e47578a8444ec8efb4d9548f185ab320152e8cf9d4fdcd7c9b44ef4f`；
  child copy、provider cache 与本地 raw 三者 SHA 完全一致。
- 色键／透明候选：raw 边界中位色为 `#10F804`，仍不是精确
  `#00FF00`。使用相同确定性透明审查参数；透明候选 SHA-256
  `b4731b5f4332cee89007817e398db18096dcd0843e49cf2d536fd2d6ee669890`，
  Alpha 为 transparent `1419322`、partial `7593`、opaque `145601`，
  可见强绿色残留 `0`。
- 几何：native 可见 bbox `[271,154,983,1088]`，尺寸 `712 × 934`；
  归一到 `1024` 设计网格后约 `[221,126,803,888]`，尺寸
  `581 × 763`，宽高比已经接近目标。中央开口 native
  `[322,209,932,1035]`，归一后约 `[263,171,761,845]`，尺寸
  `498 × 675`，是目前最接近目标 `[266,188,758,836]`／
  `492 × 648` 的版本。
- 第一失败仍是 source 几何／色键：内开口接近，但外缘仍向外多出约
  `29–46px`，可见材料占画布 `9.74%`，不是目标约 `3.58%`；
  actual-bbox-fit 到 `262 × 340` 后开口约 `224 × 301`，不是
  `246 × 324`。
- 语义／美术：单一正面空框、暗酒红旧皮、非对称磨损与两个角部接缝方向
  可保留；但皮带本体仍为常规宽框，细节密度推动了厚度，左上／右下黄铜片
  仍比 `16px` 带允许的尺度大。
- 严格真实排版：固定 source 盒裁切后左右边和少量底边可见，但顶部边仍在
  裁切区之外，不能闭合四边。`676 × 464`／100% runtime 预演 SHA-256
  `96ea48421304cfeef52afa9b740998537ca21fbcfa8dab0ba2d33cfdfa042ade`，
  路径
  `generated/quests/QL-B0/v2/inset/attempt-04/previews/QL-B0-A_V2_r3_attempt-04_contract-layout_676x464.png`。
- 非权威美术排版：actual-bbox-fit 预演 SHA-256
  `8f07a3b7104f6adc5dd8f46e0aa499c1f83ca7ac3af36e3aaf901fce6c552a5c`；
  它证明当前美术可读，但上下内容仍被宽边占用。
- 判定：`candidate-rejected / repair-prepared / P3`。不得进入用户复审、
  `assets/source/` 或 runtime。V2.r4 是 A 的最后一次，仍在既有 envelope
  内，不改变对象、状态、输入或视觉方向；只把几何构造顺序改为从已接近目标的
  开口向外画 `16px`，并要求细节为几何让步。

## A 用户取消决定

- 日期：`2026-07-30`。
- 用户原话：`看起来没必要做这个框`。
- 解释：这不是 A `5/5` 预算耗尽，也不是内部候选通过；它是用户在 A5
  provider 调用前撤销 `QUEST.LOG.LIST.INSET` 对象。A 的最终实际调用保持
  `4/5`。
- 补充实机证据：用户完整重启 Turtle WoW 后再次截图，QL-A2 连续左页、
  十八行窗口与左右页裁切均稳定恢复；左页缺少的是克制的目录层级提示，
  不是围绕阅读区的第二层框。这一证据进一步支持删除 A，同时不改变 B 的
  独立地区条／任务条合同。
- 运行时结论：不建立 A source、manifest、TGA、adapter Texture 或 fallback
  分支；`QuestLogListScrollFrame` 继续直接使用 QL-A2 V4 的连续纸面。
- 清理边界：ignored `generated/quests/QL-B0/v2/inset/attempt-01..04`
  暂留为本轮审查证据；A 达不到 P4，不进入 `assets/source/` 或 `addon/`。
- 后续：B 的地区条／任务条底板仍具有直接的信息分层价值，按既有授权与独立
  `0/5` 起始预算继续，不借用或消耗未使用的 A5。

## B attempt 1 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb37c-4303-7c13-9208-06c86d57abbe`。stdin 中的
  V2 正文 UTF-8 SHA-256 为
  `99cc7b15d673940bf91977b73ce3a9a8759d367da0c28e446b93c2399bd67f6c`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  B `1/5`。
- 输入：只上传授权的 Image 1／Image 2；没有上传实机截图、任何 A raw 或
  其他外部输入。imagegen 未报告额外 revised prompt。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `ddf18110041b24b700077f52fcaeabd48340739966b067edc6495092f574a195`；
  provider cache、child copy 与本地 raw 三者 SHA 完全一致。
- 第一失败门禁是语义／物理：虽然恰好生成两个互不接触、正面、暗橄榄／
  暖赭横条，但两条都是带厚黄铜闭合边、浮雕明暗与左右对称菱形徽记的金属
  牌匾。菱形会与真实 QL-B1 展开箭头、追踪圈发生图标语义冲突，且明确违反
  “不生成假图标槽／不能做成工整金属牌匾”的合同。
- 美术：综合色与旧化方向接近锁定卷宗，但轮廓过于工整、高清和实体化；
  连续金属边、对称端件与细密皮革纹理把十八行目录变成现代奇幻装备列表，
  不是贴在连续纸页上的克制卷宗底条。
- 色键／透明候选：raw 边界中位色为 `#05F80C`，不是精确 `#00FF00`。
  使用固定审查参数
  `remove_chroma_key.py --auto-key border --soft-matte
  --transparent-threshold 12 --opaque-threshold 96 --spill-cleanup`；
  透明候选 SHA-256
  `b2b78eac320f1e96ddfafb8b07358d76f6da27b9bd114da26ef0b0f716487299`，
  Alpha 为 transparent `1285657`、partial `6637`、opaque `280222`，
  可见强绿色残留 `0`。
- 几何：上方 native bbox `[33,350,1221,470]`，归一到 `1024` 后约
  `[27,286,997,384]`、`970 × 98`；下方 native bbox
  `[34,767,1220,897]`，归一后约 `[28,626,996,732]`、
  `968 × 106`。两者均远宽、远厚于目标 `800 × 64`，也没有落入固定
  `[112,272,912,336]`／`[112,688,912,752]` 盒。
- 严格真实排版：按完整 `1024` 网格归一并只裁固定 contract bbox，再缩到
  `224 × 18`；使用 QL-A2 shell、十八行真实密度、代表性中文、现有
  QL-B1／B2 atlas 和动态详情。`676 × 464`／100% runtime 预演 SHA-256
  `a91a5f264ddfa2d8cd1e996fa0484148f89789a74af3ae1fb6facf2fef752b71`，
  路径
  `generated/quests/QL-B0/v2/backplates/attempt-01/previews/QL-B0-B_V2_attempt-01_contract-layout_676x464.png`。
  固定裁切会截掉端部假徽记，但留下连续金属横线；十八行仍呈现密集的规则
  表格感。未完成 ScrollBar 只用非权威占位，其余周边为当前 runtime。
- 非权威美术排版：逐对象 actual-bbox-fit 预演 SHA-256
  `cd56fa1fd7624183c9c250f01fb400127d721193e8fa5f39ae4b2deaa43a04d3`。
  它清楚显示每行两端菱形与真实墨记叠加、闭合金框重复十八次，信息噪声远高
  于当前连续纸面；bbox-fit 还会把约 `10:1` 物件横向拉伸成 `12.44:1`，
  因此不能作为 source 例外。
- 判定：`candidate-rejected / repair-prepared / P3`。不得进入用户复审、
  `assets/source/` 或 runtime。缺陷覆盖两条完整轮廓与端部，V2.r1 使用
  regenerate，不上传 attempt 1 raw；只保留两个对象、综合色与低频旧化，
  在既有 envelope 内删除全部端件／金属框并收紧固定 bbox 与边厚。

## B attempt 2 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb386-2fd3-76e3-b11b-1828fec80275`。stdin 中的
  V2.r1 正文 UTF-8 SHA-256 为
  `21a0408405d53f20193a9f6e5da4de49217824a944a14138f4d4343d5bc18a2c`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  B `2/5`。
- 输入：仍只上传授权的 Image 1／Image 2；没有上传 attempt 1 raw、
  实机截图或任何 A raw。imagegen 未报告额外 revised prompt。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `0b948e68cb50c1bf10fede8dcb473f6d2b33680f81c6d29366895fae440effab`；
  provider cache、child copy 与本地 raw 三者 SHA 完全一致。
- 语义／物理改善：恰好两个互不接触、正面横条；菱形徽记、假图标、金属
  端帽和闭合黄铜框已全部移除。上条是平坦暗橄榄纸／薄皮，下条是平坦暖赭
  薄纸，中央安静，没有文字、按钮或状态内容；这些门禁通过。
- 美术：低频旧化、非对称自然收边和暗橄榄／暖赭分层与锁定卷宗协调；
  原尺寸仍有略细密的表面纹理，但在 18px 真实排版中已退到背景层，不再
  形成装备牌匾。正确方向应保留。
- 第一失败门禁转为 source 几何／色键。raw 边界中位色为 `#03F904`，
  不是精确 `#00FF00`。使用固定透明审查参数后，候选 SHA-256
  `be68ce6ca3e8a706016b3ddab6c495c31a1c809cceea5f536191de27453e2d17`；
  Alpha 为 transparent `1295999`、partial `5369`、opaque `271148`，
  可见强绿色残留 `0`。
- 几何：上方 native bbox `[65,325,1187,450]`，归一到 `1024` 后约
  `[53,265,969,367]`、`916 × 102`；下方 native bbox
  `[65,798,1187,923]`，归一后约 `[53,652,969,754]`、
  `916 × 102`。两条已经同源同尺寸，但仍比目标 `800 × 64` 宽
  `116px`、高 `38px`，左右纯绿边距只有约 `53px` 而不是 `112px`。
- 严格真实排版：按完整 `1024` 网格归一并只裁固定 contract bbox，再缩到
  `224 × 18`；QL-A2 shell、十八行真实密度、代表性中文、QL-B1／B2
  atlas 与动态详情均在目标 z-order。`676 × 464`／100% runtime 预演
  SHA-256
  `7c89554e75b866eedc9c9079130659149183646d825b16ba06d82fe4f6c4194f`，
  路径
  `generated/quests/QL-B0/v2/backplates/attempt-02/previews/QL-B0-B_V2_r1_attempt-02_contract-layout_676x464.png`。
  地区条层级清楚、任务行仍可读，连续纸面没有被第二层框包围；未完成
  ScrollBar 仍只是非权威占位。
- 非权威美术排版：逐对象 actual-bbox-fit 预演 SHA-256
  `b355292b9ce42c6dd7a6cf6dce47626deab9bbdc932ef8c843189ce62c0dd0f0`。
  它确认正确的平面底条身份，但会把 `8.98:1` 的源物件横向拉伸成
  `12.44:1`，不能作为 source 例外或内部通过依据。
- 判定：`candidate-rejected / repair-prepared / P3`。不得进入用户复审、
  `assets/source/` 或 runtime。V2.r2 保持对象、状态、输入、综合色和
  平面身份不变，只把完整画布的中心、百分比、纯绿边距、64px 高度与
  3px／2px 最大边厚写成首要构图门禁；继续 regenerate，且不上传任何 B raw。

## B attempt 3 审查记录

- 执行器／传输：`codex-cli 0.143.0`，model `gpt-5.5`，medium；
  child session `019fb38e-19d1-7a70-9e4a-efdb8bff70c1`。stdin 中的
  V2.r2 正文 UTF-8 SHA-256 为
  `17f78f99ab9c92a9eefbd0d679a2d550e653e4e7930637c3c60dcb2e59ddc636`，
  与提交正文完全一致；没有 wrapper 递归。provider 已返回图片，因此计为
  B `3/5`。
- 输入：仍只上传授权的 Image 1／Image 2；没有上传 attempt 2 raw、
  实机截图或任何 A raw。imagegen 未报告额外 revised prompt。
- raw：`1254 × 1254 RGB PNG`，SHA-256
  `5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721`；
  provider cache、child copy 与本地 raw 三者 SHA 完全一致。
- 语义／美术：继续通过两个正面平面底条、无端件、无金属框、暗橄榄／
  暖赭分层、安静中央、自然不对称边缘和无动态内容。与 attempt 2 相比，
  轮廓更像薄纸条，表面高频略降；这是当前应保留的同循环编辑目标。
- 第一失败仍为 source 几何／色键。raw 边界中位色为 `#03F905`，
  不是精确 `#00FF00`。使用固定透明审查参数后，候选 SHA-256
  `7009915ffda52e17d9e0cb11ebbc7f1e1649c8c5cafb8b45412a5d07ff931f78`；
  Alpha 为 transparent `1299669`、partial `5585`、opaque `267262`，
  可见强绿色残留 `0`。
- 几何：上方 native bbox `[85,388,1168,516]`，归一到 `1024` 后约
  `[69,317,954,421]`、`885 × 104`；下方 native bbox
  `[85,766,1168,894]`，归一后约 `[69,626,954,730]`、
  `885 × 104`。宽度比 attempt 2 收小 `31px`，但高度反而增加 `2px`；
  上条中心约 `(512,369)` 而非 `(512,304)`，下条中心约 `(512,678)`
  而非 `(512,720)`。
- 严格真实排版：固定 contract bbox 只截到上条顶部和下条底部，地区条
  暗橄榄主体基本丢失；`676 × 464`／100% runtime 预演 SHA-256
  `826ba5b264cb349af71696f9f1346f084eb63c7b68418ec76fdee9d064d0032e`，
  路径
  `generated/quests/QL-B0/v2/backplates/attempt-03/previews/QL-B0-B_V2_r2_attempt-03_contract-layout_676x464.png`。
  预演仍使用十八行、真实中文密度、QL-B1／B2 atlas 与当前 shell；
  ScrollBar 仍是非权威占位。
- 非权威美术排版：actual-bbox-fit 预演 SHA-256
  `197308e2d2765559903f0d7b9ea27988b8c419be070a9fe437e90d8ed8e3be8e`。
  它显示平面底条的层级与可读性正确，但会把约 `8.51:1` 的源物件拉伸成
  `12.44:1`，不能掩盖 source 几何失败。
- 判定：`candidate-rejected / repair-prepared / P3`。不得进入用户复审、
  `assets/source/` 或 runtime。连续 regenerate 已三次不能同时控制尺寸与
  位置；V2.r3 按已授权 repair envelope 改用同循环 edit。Image 3 只承担
  当前正确表面与物件身份，Image 1 仍是最高美术权威，Image 2 仍只匹配纸页；
  编辑只执行明确的 `90.40% × 61.54%` 缩放、中心移动和旧位置清除。

## B attempt 4 上传授权门禁

- 需要上传的新增同循环输入：
  `generated/quests/QL-B0/v2/backplates/attempt-03/raw/QL-B0-B_V2_r2_attempt-03_raw.png`。
- 固定 SHA-256：
  `5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721`。
- 用途：只作为 V2.r3 的 Image 3 编辑目标，保留已通过的两个平面底条表面，
  只修正其 bbox、中心和背景；不是新的视觉权威，也不取代 Image 1／2。
- 已发生的审批拒绝在 fixed child 启动前结束；无上传、无 session、无
  provider result、无图片，故 B 保持 `3/5`。
- 必需用户授权原文：
  `明确授权 QL-B0-B V2.r3，并允许上传固定 SHA
  5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721
  的同循环 attempt 3 raw 作为 Image 3；B 预算仍为 3/5，最多再 2 次。`

## 下一门禁

用户已于 `2026-07-30` 使用下面的精确语句完成授权：

> 明确授权 QL-B0-A V2 与 QL-B0-B V2，并允许分别上传固定 SHA 的
> Image 1、Image 2；每段最多 5 次，最坏合计 10 次。

下一门禁为：等待用户使用上方精确语句授权 Image 3 上传；获得授权后重试
同一已提交 `QL-B0-B V2.r3` 正文并执行 B attempt 4 edit。没有授权时不
改用间接上传或浪费剩余 regenerate 预算。B 任何内部通过都必须停在
`candidate-reviewed / P3` 等待用户视觉复审。
