# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- 用户于 `2026-07-30` 将 Quest Log 选为当前首要大面积 UI；地图与角色因
  实机对象几何尚未完成，继续保持后续顺位。
- Quest Log 真实对象合同：`P1` 完成，QL-A 当前处于 `P4–P5`；QL-B1
  V1.r3 与 QL-B2 V1.r4 bbox-fit 均已由用户接受运行时视觉并完成
  `runtime-exported / P5`。
- `QL-A1` 空卷宗结构 source：用户确认，`P4`。
- `QL-A2 V3.2` 已终止：A attempt 5 目标级通过；B 在 `5/5` 后仍有约
  `45%` 格宽的针脚和完整外露结，整批 `10/10` 额度耗尽。没有形成
  accepted source 或 runtime；A 候选仍只是 ignored `generated/` 中的
  本机重组输入。
- `QL-A2 V3.3`：`P3` 部分执行。已将失败的 B 六件同画布合同拆成
  B1 underlay＋folds、B2 单枚 stitch、B3 top／bottom closures 三个尺度
  族；三段完整 Prompt、固定输入、验收合同、确定性等比归一化和真实纸缘
  遮挡方案已经预检通过。用户于 `2026-07-30` 明确授权三段正文、固定上传
  范围及每段 `5` 次预算。B1 已耗尽 `5/5`：最终 underlay 仍是深色纹样
  竖条，fold 仍有满面压纹，且背景不可安全色键。B2 attempt 1 生成了
  单根水平对象；attempt 5 去除了编织纹，却变成 `832 × 101px` 的光滑
  木质／角质实体，仍非亚麻线且背景不可安全色键，B2 已耗尽 `5/5`。
  B3 已耗尽 `5/5`；合计 `15/15`。终态原尺寸复核纠正了此前的误判：
  attempt 3–5 仍是多圈交叠、装饰性绳结和横向杆状尾端，第一失败门禁是
  语义／物理，不只是尺寸／位置。三段均为
  `candidate-rejected / repair-budget-exhausted`，无任何候选可晋级。
- `QL-A2 V4`：`runtime-exported / P5`。用户于 `2026-07-30` 确认 QL-A1
  单一静态背景、`676 × 464`、list-only 不缩窄书体和 `GUTTER.*` 静态
  归属。确定性 exporter 已生成 `1024 × 512` TGA 与 runtime manifest；
  AEUI adapter 把它挂在 `QuestLogFrame` 的非交互背景层，隐藏原生装饰
  Texture，但保留动态文字、列表、详情、原操作 Button、脚本和
  SavedVariables。缺少详情切换时只创建真实 Button。任务行、两套
  ScrollBar、按钮状态、奖励槽与状态覆盖的最终美术仍属于 QL-B/C/D。
- `QL-B`：已完成目录对象与状态来源复核。旧 P5／V1 runtime 保留 pfUI
  23 行，以 `15px` 行高／`14px` 步进占用 `323px`；实机已确认这种密度
  和仅有小墨记／书签的资产范围不足以形成可感知的左页改造。用户确认 V2
  改为 `QUESTS_DISPLAYED = 18`、`224 × 18px`、`18px` 步进，总占高
  `324px`。
- `QL-B0 V2`：新的 [左页卷宗目录 work](work/QUEST.LOG.LEFTPAGE.md)
  已于 `2026-07-30` 获用户明确授权。A attempt 1／2／3 已由固定
  `@openai/codex@0.143.0` 执行并完成透明／100% 真实排版审查。attempt 3
  已收敛为单层暗酒红旧皮并只保留左上／右下两个非对称黄铜接缝，但归一化
  外框／开口仍约为 `585 × 838`／`510 × 764`，不是目标
  `524 × 680`／`492 × 648`，背景也仍不是精确 `#00FF00`。当前为
  `repair-prepared / P3`，A `3/5`，完整 `V2.r3` 正文待提交后执行。
  A 段只生成固定 `262 × 340` 列表内框；
  B 段只生成 `224 × 18` 地区条与任务条 base，四态确定性派生。顶部控件、
  ScrollBar 与按钮继续归 QL-C；QL-B1／B2 只在 V2 source 接受后从现有
  accepted source 确定性重导出，QL-B3 继续暂停。B 当前 `0/5`，最坏总预算
  仍为 `10` 次；下一门禁是提交 A attempt 3 审查与 `V2.r3` 后执行
  A attempt 4。
- `QL-B1 V1` 的固定执行循环在
  `candidate-rejected / P3 / repair-budget-exhausted` 终止。用户于
  `2026-07-30` 授权固定 Image 1／2、同循环 edit 输入和最多五次调用。
  attempt 1 因只读保存环境失败；attempt 2 触发同名包装 skill 递归，已启动
  的嵌套固定调用按 attempt 3 保守计数后中断；attempt 4 首次形成四格候选；
  attempt 5 以该候选为 Image 3 编辑。最终仍未满足两枚箭头严格旋转同源、
  两枚外圈只差墨勾、平面墨迹身份、`224²` 安全盒和均匀 `#00FF00` 色键。
  用户随后于 `2026-07-30` 明确接受 V1.r3 的运行时视觉，并允许用确定性逐格
  裁切、等比缩放、居中与 Alpha 规则进入 P4/P5；该决定不把内部失败门禁
  改写成通过。透明母版、source/runtime manifest、`64 × 16` TGA、确定性
  exporter 和 adapter 已 tracked，当前为 `runtime-exported / P5`；固定
  执行器仍是 `5/5` 且接受后没有新增调用。
- `QL-B0／B1 runtime`：adapter runtime contract 已升至 `1.4`。已创建／复用
  `QuestLogTitle1..23`，使用 `224 × 15` 行盒／`14px` 步进和真实滚动偏移，
  从 `GetQuestLogTitle`／`IsQuestWatched` 切换四种 atlas 状态。覆盖 Texture
  不接管点击；原行脚本、选择、滚动与 SavedVariables 保留。实机发现的
  `QuestLogHighlightFrame` 与行内 highlight／pushed 旧选择视觉
  已在每次刷新后透明抑制，避免其覆盖 QL-B2 书签。主标题使用 Noto Serif SC，
  任务行使用霞鹜文楷。该实现现在明确是 V1 fallback；V2 尚未改写 runtime。
- QL-B1 真实排版预演：`676 × 464`／100% runtime，使用当前 QL-A2
  shell、全部 23 行、代表性中文任务内容与四态分布，SHA-256
  `c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5`。
  QL-C 未完成按钮仅为 manifest 标注的非权威占位；该预演不能替代实机。
- `QL-B2 V1`：用户于 `2026-07-30` 明确授权固定 Image 1／2、同循环
  edit 输入和最多五次实际生图／修图；五次生成与三态 23 行真实排版内审
  已完成，当前 `candidate-rejected / repair-budget-exhausted / P3`，
  实际生图 `5/5`、流程错误 `3`。第五张已达到 `1.776:1` 与
  `24 × 14` 运行时比例，运行时视觉可审视，但 source 安全盒和原生纯色键
  仍不符合冻结合同；没有 source 或 runtime，且不得继续第六次调用。
  流程错误单列且不占实际生图额度。现已额外完成一次不调用 ImageGen 的
  “固定色键清理＋可见 bbox 等比缩入中心安全盒”合同例外预演：候选
  `352 × 198px`、bbox `[336,413,688,611]`、可见绿色残留 `0`，三态
  真实排版与第五张运行时 Alpha 完全一致。用户已明确接受该具体候选和
  一次性确定性 bbox-fit 合同例外；同 SHA 文件已晋级 tracked source。确定性
  exporter 已按 `24 × 14` content、`32 × 16` cell、三态同 Alpha 和第四
  透明格合同生成 `128 × 16` TGA，adapter 已从
  `GetQuestLogSelection()` 与原行 hover／left-press 脚本切换三态，当前
  `runtime-exported / P5`。原始 attempt 5 的安全盒与纯色键失败仍作为
  历史事实保留；接受后 ImageGen 调用为 `0`。
- `QL-B2 runtime`：adapter runtime contract 已升至 `1.4`。每行创建一个
  无鼠标 `BORDER` Texture；仅当前可见的非 header 选择行显示。Texture
  使用 `x=-12`，selected／hover `y=0`，pressed `y=-1`；原
  `OnEnter`／`OnLeave`／`OnMouseDown`／`OnMouseUp`／`OnClick` 先执行，
  adapter 再刷新视觉。缺少选择 API 时隐藏覆盖，不改变点击、滚动或
  SavedVariables。
- `QL-B3`：三类真实语义已拆为三个固定并列槽，类型／计时／状态可同时出现。
  [QL-B3 work](work/QUEST.LOG.STATUS.md) 已形成 A／B／C 三段完整
  生产正文：分别生成四类类型压印、单枚沙漏和同一蜡封的完整／破裂两态。
  用户于 `2026-07-30` 明确授权 A／B／C V1、固定 Image 1／2、同段前次
  输出的冻结边界 edit，以及每段最多 `5` 次／最坏合计 `15` 次实际调用；
  A 已执行到 attempt 5，四个物件语义、综合色、安全盒和 10px 真实排版
  通过，但 native 精确色键仍失败且发生 1px 级重绘漂移，当前为
  `candidate-rejected / repair-budget-exhausted / 5/5`。B／C 仍为
  `0/5` 并暂停。非地区行文字安全宽度收敛为 `155px`；类型 token 的显式等值表
  仍需在 P5 前由目标客户端证实。Collapse All 归 QL-C 独立 Button，
  不混入目录状态。
- Quest Tracker：视觉 `P2`，外部 provider `P0`，暂停。
- NPC Quest／Gossip：对象合同 `P1`，美术与实机几何未锁定，保持原生。
- `questitem.lua`：行为保留，视觉 `N/A`。

## Quest Log 批次

| 批次 | 子模块 | 阶段 | 当前事实 | 下一门禁 |
|---|---|---:|---|---|
| `QL-A1` | `QUEST.LOG.SHELL` 结构母版 | `P4` | [透明 source](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 已接受；原始 PNG 不直接加载，只允许 QL-A2 V4 确定性全幅导出 | Turtle WoW 中复核最终显示 |
| `QL-A2` | 静态空卷宗结构与页沟 | `P5` V4 runtime-exported | V3.3 `15/15` 已终止；V4 已从 QL-A1 source 导出 `676 × 464` 显示区／`1024 × 512` TGA，固定执行器 `0/0`，Lua smoke 通过 | Turtle WoW 验证纹理方向、裁切、命中与 list-only |
| `QL-B0` | 左页列表几何、内框、地区条与任务条底板 | V1 `P5 fallback`；V2 `P3 repair-prepared` | V1 的 23 行 `323px` 几何仍可回退；用户已授权 `18 × 18` V2 的 A／B 两段、固定 SHA 与各 `5` 次预算。A attempt 1／2／3 均因设计网格／bbox／开口／色键退回；attempt 3 的单层暗皮和两枚非对称黄铜予以保留，A `3/5`、B `0/5`，见 [work](work/QUEST.LOG.LEFTPAGE.md) | 提交 A V2.r3 完整正文后执行 attempt 4；内部通过只到 P3 |
| `QL-B1` | 地区展开／收起、追踪开／关四枚墨记 | `P5 runtime-exported` | 用户接受 V1.r3；[source manifest](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)、[runtime manifest](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)、`64 × 16` TGA、exporter 与真实排版预演已完成；内部失败与 `5/5` 事实保留 | Turtle WoW 验证 TGA、四态切换、字体和 fallback |
| `QL-B2` | 当前任务暗酒红书签三状态 | `P5 runtime-exported` | 用户接受 V1.r4 bbox-fit 合同例外；[source manifest](../../../assets/source/quests/ql-b2/QL-B2_SourceManifest_v1.json)、[runtime manifest](../../../assets/source/quests/ql-b2/QL-B2_RuntimeManifest_v1.json)、`128 × 16` TGA、exporter、三张真实排版预演与 adapter 已完成；历史 `5/5` 与三次流程错误保留，接受后 ImageGen `0` 次 | Turtle WoW 验证三态 UV、左缘位置、1px pressed、行重叠命中、滚动与 fallback |
| `QL-B3` | 类型、计时、完成／失败状态章 | `P3 repair-budget-exhausted` | [三段 V1 work](work/QUEST.LOG.STATUS.md) 已获授权；A `5/5` exhausted，B／C 各 `0/5` 并暂停 | 不阻塞 QL-B0 V2；等待用户以后决定 A 的色键例外／source 策略／视觉重开 |
| `QL-C` | 两套 ScrollBar、关闭、Collapse All、操作与辅助按钮 | `P1–P2` | 实机已证实 Collapse All、pfUI 等级／追踪控件、关闭与底部操作 Button；adapter 仅统一顶部安全区锚点，最终状态美术仍未生产 | 继续实机测量滚动条与按钮四态 |
| `QL-D` | 奖励槽、分隔与文字安全区 | `P1–P2` | Quest Log 奖励只读，无 selected | 实机奖励数量与尺寸 |

QL-A1 manifest 记录：

- `1514 × 1039` RGBA。
- SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- 透明／半透明／不透明像素：`241402／5650／1325994`。
- 可见绿色残留：`0`。
- 固定执行会话：`019fac35-620b-78d3-8b46-2e1f02105f74`。
- 物理双页接近等宽；`42%／58%` 只用于 runtime 阅读列。

## NPC Quest／Gossip

| 批次 | 范围 | 阶段 | 下一门禁 |
|---|---|---:|---|
| `QD-A` | 两外壳、两肖像、名称、关闭与五内容面板 | `P1 contract-draft` | 锁定 NPC 委托文书主视觉并实测几何 |
| `QD-B` | 五面板 × 四滚动子件；两类 Greeting Entry | Scroll `P1`／Entry `P0` | FrameXML／`/fstack` 证据 |
| `QD-C` | 八个真实操作 Button | `P1` | 四状态尺寸与点击区 |
| `QD-D` | 所需物品、奖励槽与选择覆盖 | `P1` | 奖励流程实机验证 |

当前原生 `QuestFrame`／`GossipFrame` 完整保留；没有 production Prompt、
source 或 runtime。

## 外部 Quest Tracker

| 批次 | 范围 | 阶段 | 下一门禁 |
|---|---|---:|---|
| `QT-A` | header、paper、叠页边、bottom、emblem | `P2 visual／P0 compat` | 提供外部插件源码与对象树 |
| `QT-B` | collapse、objective、focus、seal、timer | `P2 visual／P0 compat` | 真实交互与状态来源 |

本项目不会扫描或接管 `QuestWatchFrame`，也不会创建第二个追踪器。

## 当前验证

- 静态对象合同与 Prompt 继承测试：
  [`quest_design_contract_test.py`](../../../tests/quest_design_contract_test.py)。
- QL-A1 source manifest：
  [`QL-A1_SourceManifest_v1.json`](../../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)。
- QL-A2 runtime manifest：
  [`QL-A1_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-a1/QL-A1_RuntimeManifest_v1.json)；
  runtime SHA-256
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`。
- adapter：
  [`Quests.lua`](../../../addon/AzerothExpeditionUI/Modules/Quests.lua)；
  Lua smoke：
  [`quest_module_smoke.lua`](../../../tests/quest_module_smoke.lua)。
- QL-A2 raw、透明候选与失败候选只存在于被忽略的
  `generated/quests/QL-A2/`；未晋级任何 V3.2／V3.3 候选。
- QL-B1 生产合同、五次循环与用户接受记录：
  [`QUEST.LOG.DIRECTORY.md`](work/QUEST.LOG.DIRECTORY.md)；固定执行器
  `5/5`，终态 `candidate-rejected / repair-budget-exhausted`。attempt 5
  normalized raw SHA-256
  `73f719d44a55b01d0ef8bc6f2c07343679a10b155d612941ca72d16869527596`，
  transparent SHA-256
  `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`。
  同 SHA 透明稿已晋级为
  `assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png`。
- QL-B1 runtime manifest：
  [`QL-B1_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)；
  runtime `QuestLogDirectoryMarksV1.tga` SHA-256
  `e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f`。
- QL-B1 exporter：
  [`build_quest_log_directory_marks_v1.py`](../../../tools/build_quest_log_directory_marks_v1.py)；
  adapter runtime contract `1.4`，Lua smoke 覆盖 23 行创建、四态、滚动偏移、
  原脚本、整行旧高亮抑制与刷新后不回生。
- QL-B2 V1 生产合同：
  [`QUEST.LOG.SELECTION.md`](work/QUEST.LOG.SELECTION.md)；当前为
  `runtime-exported / P5`，实际生图 `5/5`、流程错误 `3`；第五张 raw、
  原透明稿和预演仍只在 ignored `generated/` 作为审查证据。同 SHA 的
  bbox-fit 候选已晋级
  [`QuestLogSelectionBookmark_Master_v1.png`](../../../assets/source/quests/ql-b2/QuestLogSelectionBookmark_Master_v1.png)，
  SHA-256
  `4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa`。
  source manifest 记录用户接受、合同例外与 Alpha 证据。runtime
  `QuestLogSelectionBookmarkV1.tga` SHA-256
  `bab9e8bf6961b743d9591bb148878e9eadbbbbd99eac9a183446bf9c81a770b4`；
  三态 cell Alpha SHA-256 均为
  `2cd8de894c389f5c7eaf5c5d5388a20b363fa414022dc4dac57eacda1fa79029`。
- QL-B2 exporter：
  [`build_quest_log_selection_bookmark_v1.py`](../../../tools/build_quest_log_selection_bookmark_v1.py)；
  runtime manifest：
  [`QL-B2_RuntimeManifest_v1.json`](../../../assets/source/quests/ql-b2/QL-B2_RuntimeManifest_v1.json)。
  三张来自最终 atlas 的真实排版 SHA-256 分别为 selected
  `bba74c3591c60efa27c3f3d9c1a3266661d76c7aff7ed46230f8ef2b1ca4baaf`、
  hover
  `eac7c0fee22ca7f7eb57449b2710588743f141745510cc6029d2b9478d7a9f40`、
  pressed
  `47397145620353eabbca33c20be67fefe9fccc84e7f1334ae577d609e6915eb6`。
- QL-B3 生产合同：
  [`QUEST.LOG.STATUS.md`](work/QUEST.LOG.STATUS.md)。三段均为
  `P3`；固定 Image 1／2、三槽真实行几何、同段 edit、每段最多五次实际
  生图和最坏 `15` 次总预算已获授权。当前 A `5/5` exhausted、B `0/5`、
  C `0/5`；A attempt 5 已通过四格安全盒、语义、美术与 10px 真实排版，
  但 native 精确 `#00FF00` 像素仍为 `0`，背景-only edit 亦发生 1px 级
  重绘漂移，已按 skill 标记 `candidate-rejected / repair-budget-exhausted`；
  三次无 provider 结果的错误与一次 provider 后处理异常均已单列，均不
  新增实际生图计数。
- QL-B3 候选审查工具：
  [`review_quest_log_status_candidate_v1.py`](../../../tools/review_quest_log_status_candidate_v1.py)；
  只在 ignored `generated/` 中确定性生成 `10px`／`10px`／`12px` 临时
  atlas、23 行真实排版和 sidecar，不晋级 source 或 addon runtime。
- Turtle WoW 实机验证已于 `2026-07-30` 开始。首次加载在
  `Modules\Quests.lua:223` 因 Lua 5.0 不支持 `original(...)` 形式的
  vararg 转发而解析失败，客户端因此完整回退到 pfUI Quest Log。adapter
  已改为固定位置参数脚本包装，并增加 Lua 5.0 静态兼容回归。复验后 shell、
  双页、23 行和 QL-B2 书签均已实际加载；同轮截图确认两项 runtime 错误：
  原生整行浅色选择层仍覆盖书签，右页正文仍沿用旧 FontString 宽度并被
  ScrollFrame 硬裁。runtime contract `1.3` 已 feature-detect 并抑制旧选择层，
  同时把右页 ScrollChild 收敛为 `224px`、普通正文 `214px`、缩进目标
  `204px`，并在 `QuestLog_UpdateQuestDetails` 后重施几何。下一轮实机图证实
  旧整行高亮已消失、右页已重新换行，但用户明确指出左页主体仍无可感知变化。
  复核确认当前 runtime 只有 `12px`／`10px` QL-B1 状态墨记和
  `24 × 14px` QL-B2 可见书签；列表内框、地区条、任务行底板和顶部工具条
  均没有独立资源，因而仍主要呈现 pfUI。该结论是 P5 视觉未通过，不是加载
  失败。runtime contract `1.4` 另隐藏 pfUI 已意图隐藏的
  `QuestLogTrackTitle`，修复上一版计数锚点暴露出的“追踪任务/20”重叠。
  当前 V1 保持 `P5 fallback`。用户随后确认 `18 × 18` V2 方向；列表内框、
  地区条和任务条底板的真实对象、固定几何与完整生成正文已经准备。

## 下一步

QL-A2 保持 [runtime work](work/QUEST.LOG.GUTTER.md)，不得进入 `P6`／清理。
runtime contract `1.4` 只修正顶部文字重叠，不把左页资源缺失改写成完成。
用户已明确授权 [QL-B0 左页 V2 work](work/QUEST.LOG.LEFTPAGE.md) 中
`QL-B0-A V2`／`QL-B0-B V2` 两段、固定 SHA 的 Image 1／2 上传和每段最多
五次／最坏十次预算。A attempt 1／2／3 已计数并完成全套内审；attempt 3
已改善为单层暗酒红旧皮与两枚非对称黄铜，但设计网格、bbox、开口、色键和
直边厚度仍退回。下一步提交 `QL-B0-A V2.r3` 完整正文后执行 attempt 4，
仍不上传任何前次 raw。A 内部通过或预算耗尽后再执行 B。
当前批次只覆盖列表内框、地区条与任务条底板；顶部真实控件和 ScrollBar
继续留给 QL-C 独立拆分。
QL-B2 V1 已在 `5/5` 停止；
用户接受的 bbox-fit source、固定三态 atlas、adapter 与静态测试现已完成到
P5，下一门禁仍是 Turtle WoW 实机验证，在此之前不得标记 P6 或清理 work。
QL-B3-A／B／C V1 已获明确授权；当前
A 已按五次上限停止。等待用户决定是否授权 attempt 4／5 的确定性色键合同
例外、改变 source 策略重开 A，或拒绝现有视觉。决定前不执行 B／C、
不晋级 source／runtime；QL-B3 不阻塞用户已选择的 QL-B0 V2 大面积左页
路线。QL-A2／B1／B2 的当前 V1 资产继续作为 fallback 等待后续实机复核。
每个 countable output 后必须完成真实排版内审与边界内自主修复。不得继续
调用 QL-B2 V1 ImageGen。QL-B1 的旧计数保留为当时流程的历史事实，不作为
新口径先例。
