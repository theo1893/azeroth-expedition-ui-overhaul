# Quest Log 左页卷宗目录 V2

## 当前状态

- 工作范围：`QL-B0-A V2` 与 `QL-B0-B V2`。
- 子状态：`repair-prepared`。
- 项目阶段：`P3`。
- 授权正文状态：`production`；A attempt 1 已完成并退回，下一次必须逐字
  使用本文件 `QL-B0-A V2.r1` 完整正文；B 首次执行仍必须逐字使用
  `QL-B0-B V2` 完整正文。
- 当前实际生图：A `1/5`；B `0/5`。
- 单段预算：最多 `5` 次实际生成／编辑。
- 最坏总预算：`10` 次实际生成／编辑。
- 流程错误：A `4`；B `0`，与实际生图次数分开记录。
- 固定执行器：`.codex/skills/imagegen-0-143-0/SKILL.md`，
  `@openai/codex@0.143.0`。
- 用户授权：`2026-07-30` 明确授权 `QL-B0-A V2` 与 `QL-B0-B V2`，
  允许分别上传固定 SHA 的 Image 1／Image 2；每段最多 `5` 次，最坏合计
  `10` 次。
- 当前门禁：先提交 A attempt 1 审查与 `QL-B0-A V2.r1` 完整正文，再以
  相同 Image 1／2 执行 A attempt 2。A 内部通过或预算耗尽后再执行 B。
  任何候选都只到 P3，不自动晋级 source 或 runtime。

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

### `QL-B0-A V2` — `QUEST.LOG.LIST.INSET`

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
- 候选接受后才允许建立 `512 × 512` TGA runtime 包；本阶段不导出。

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

## 当前执行正文 — QL-B0-A V2.r1

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

构图和厚度是本次最高几何门禁。唯一物件以 `(512, 512)` 为中心；可见外接盒
必须严格位于 `x=250..774, y=172..852`，恰为 `524 × 680px`，盒外不得有
任何物件像素、投影或光晕。中央必须是从 `x=266..758, y=188..836` 的完整
矩形纯绿色开口，恰为 `492 × 648px`。因此上、下、左、右的结构材料都只能
占用外盒与开口之间的 `16px` 薄带；四角也必须留在同一薄带内，绝不能向开口
增厚。它缩到 `262 × 340 UI px` 后必须只形成四边各 `8px` 的目录嵌边，并
完整露出 `246 × 324 UI px` 的十八行阅读区。

这个物件是嵌在暖赭纸页接缝处的“薄目录装订唇边”，不是完整书壳、窗框、
门框、肖像框或独立厚面板。主体只用深胡桃木色旧皮与烟黑硬边；氧化黄铜只可
作为少量、窄小、非对称的角部接缝点，不能形成大块角包、铆钉阵列或连续金属
边。禁止把浅色羊皮纸、砂岩、石板或厚木条当作四边主体。四边可有轻微手工
起伏、缺口和不均匀磨损，但必须始终留在 `16px` 薄带中；四角不能镜像复制，
装饰密度不能规律重复。保留 Image 1 的手绘概括和旧化尺度，避免高清写实
裂纹、照片级材质和机械般工整。

禁止绘制任何纸面填充、行分隔、地区条、任务条、文字、数字、图标、按钮、
滚动条、滑块、选择高亮、书签、印章、状态章、假肖像槽或假图标槽。禁止现代
矩形面板、暗黑祭坛、聊天旧书风格、细金框、宝石、巨大徽章、浮夸雕花和常亮
发光。

输出前逐项自检：只有一个薄目录内框；物件中心、外盒、开口和四边 `16px`
厚度全部正确；外盒以外与开口以内都是同一个精确 `#00FF00`；没有任何投影、
绿色纹理或抗锯齿污染扩散到安全区；内框正面、无透视、无拉伸；在
`262 × 340 UI px` 显示时不会遮挡 `246 × 324 UI px` 的十八行内容；没有
任何被禁止的动态或交互内容。

## 最终执行正文 — QL-B0-B V2

使用 `@openai/codex@0.143.0` 的固定 ImageGen 执行器，生成一张
`1024 × 1024` RGBA 位图。背景必须是完全均匀、无纹理、无渐变、无阴影、
无抗锯齿污染的纯绿色 `#00FF00`。画面中恰好有两个互不接触、正面朝向、
无透视的超宽横向基础物件；不要生成完整 UI、书页、书框或状态展示板。

输入角色必须严格遵守。Image 1
`任务详情面板_视觉基准_v1.png`
（SHA-256
`03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`）
是最高视觉权威：继承正式公会任务卷宗身份、2004 年前后香草魔兽二维手绘
笔触、粗厚略不规则轮廓、明确明暗切面、左上暖光、低饱和赭黄／烟黑／暗酒红
与氧化黄铜关系，以及不均匀的翻阅磨损。不要复制 Image 1 的完整书体、顶部
控件、文字、图标、肖像槽、按钮、滚动条、封印、书签或完整列表。

Image 2 `QuestLogBookShell_Master_v1.png`
（SHA-256
`91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`）
只用于匹配当前 runtime 的暖赭纸页接触色、材质尺度和左上受光连续性。
不要复制完整书壳、书脊、四角、页沟或纸页；Image 2 不得覆盖 Image 1 的
物件身份、轮廓语言和笔触。

上方物件是 `QUEST.LOG.REGION.BACKPLATE`，外接盒必须严格位于
`x=112..912, y=272..336`，恰为 `800 × 64px`。它是低饱和暗橄榄色的
公会目录地区条，材料像薄旧皮与涂色厚纸的混合，边缘有克制的暗墨线和少量
氧化黄铜收口；中央区域安静、低对比，专门承载运行时动态地区文字。保持手工
切边与轻微不对称，不能做成工整金属牌匾。

下方物件是 `QUEST.LOG.ROW.BACKPLATE`，外接盒必须严格位于
`x=112..912, y=688..752`，恰为 `800 × 64px`。它是更浅、更薄的暖赭卷宗
任务条底板：可见手工切边、少量自然缺口和深棕墨线，局部旧化不均匀，中央
保持安静；它应让人感到仍贴在同一张连续纸页上，而不是悬浮的现代不透明
卡片。

这里只生成两个 normal base，不绘制 `normal／hover／pressed／disabled`
四态，不绘制状态矩阵。禁止绘制文字、数字、等级、任务计数、箭头、勾选圈、
书签、选择高亮、类型章、计时章、完成／失败章、按钮、滚动条、肖像槽、
假图标槽或任何命中区。禁止现代 UI 卡片、照片级皮革、完美镜像角、细金框、
高频雕花、宝石与常亮发光。

输出前自检：恰好两个独立横条；各自外接盒和间距正确；外部背景保持可安全
色键的统一 `#00FF00`；两个物件正面、无透视；在各自
`224 × 18 UI px` 显示时仍能区分暗橄榄地区条与暖赭任务条，同时拥有同一
香草魔兽公会卷宗美术 DNA；没有任何被禁止的动态、状态或交互内容。

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
| A | 2/5 | `QL-B0-A V2.r1`／待执行前 commit | generate |  |  |  |  | 待执行 |
| B | 0/5 | `QL-B0-B V2`／待执行前 commit | generate |  |  |  |  | 待 A 内部通过或耗尽 |

| 流程错误 | 段／正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | `npx` 写入用户 npm cache 时返回 `EPERM`；无图片、无 provider result、无生成证据 | 保持授权正文与 Image 1／2 不变；改用 `generated/` 下独立 npm cache，并以获准网络环境重试 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E2 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | 独立 npm cache 下载 `@openai/codex@0.143.0` 时连接被重置，npm 日志为 `ECONNRESET`；固定包未完成安装，空工作目录中无图片，进程管理记录与 session 中均无 child／provider 证据 | 保持授权正文与 Image 1／2 不变；复用已下载进独立 cache 的固定包内容，以持久 stdout／stderr 的隐藏后台执行器完成安装及执行，避免外层短超时截断 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E3 | A／`QL-B0-A V2`／`8e934f6` | fixed CLI 未启动；无 child session／result | Windows PowerShell 5 按本地代码页读取无 BOM 的忽略目录 launcher，正文标题与中文 Image 1 路径在上传前失真，授权正文抽取失败；无图片、无 provider result | launcher 改为纯 ASCII 路由：按标题中的 `QL-B0-A V2`／`QL-B0-B V2` 标识抽取正文，并按授权 SHA-256 在目录中解析 Image 1；固定正文与输入不变 | `process-error`；不占生图额度，A 仍为 `0/5` |
| E4 | A／`QL-B0-A V2.r1`／`b03a81a` | fixed CLI 未启动；无 child session／result | launcher 的旧正文正则只允许 A 标题恰好结束于 `V2`，没有接受 `.r1` 后缀；在 stdin 生成与上传前停止，无图片、无 provider result | 正则只扩展为接受 `V2.rN` 标题；独立校验的 V2.r1 正文 SHA-256 为 `bc93f2c47d338a3650b948ed213035d0c5a759bd6aeba01cf8b4acc16008d65d`，正文、Image 1／2 与执行参数不变 | `process-error`；不占生图额度，A 仍为 `1/5` |

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

## 下一门禁

用户已于 `2026-07-30` 使用下面的精确语句完成授权：

> 明确授权 QL-B0-A V2 与 QL-B0-B V2，并允许分别上传固定 SHA 的
> Image 1、Image 2；每段最多 5 次，最坏合计 10 次。

下一门禁为：提交 attempt 1 审查与 `QL-B0-A V2.r1` 完整正文后执行
A attempt 2；仍只上传固定 SHA 的 Image 1／2，不上传 attempt 1 raw。
每次输出按完整审查清单与真实排版预演判定。A／B 任何内部通过都必须停在
`candidate-reviewed / P3` 等待用户视觉复审。
