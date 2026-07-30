# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- 用户于 `2026-07-30` 将 Quest Log 选为当前首要大面积 UI；地图与角色因
  实机对象几何尚未完成，继续保持后续顺位。
- Quest Log 真实对象合同：`P1` 完成，QL-A 当前处于 `P4–P5`；QL-B1
  V1.r3 已由用户接受运行时视觉并完成 `runtime-exported / P5`。
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
- `QL-B`：已完成目录对象与状态来源复核。pfUI 的 23 行／350px 与 QL-A2
  `324px` 安全区存在明确几何冲突；当前离线合同保留 23 行，以
  `15px` 行高／`14px` 步进占用 `323px`，不减少 pfUI 可见行数。该数值
  仍需实机验证文字基线、点击重叠和滚动偏移。
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
- `QL-B0／B1 runtime`：adapter runtime contract `1.1` 已创建／复用
  `QuestLogTitle1..23`，使用 `224 × 15` 行盒／`14px` 步进和真实滚动偏移，
  从 `GetQuestLogTitle`／`IsQuestWatched` 切换四种 atlas 状态。覆盖 Texture
  不接管点击；原行脚本、选择、滚动与 SavedVariables 保留。主标题使用
  Noto Serif SC，任务行使用霞鹜文楷。
- QL-B1 真实排版预演：`676 × 464`／100% runtime，使用当前 QL-A2
  shell、全部 23 行、代表性中文任务内容与四态分布，SHA-256
  `c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5`。
  QL-C 未完成按钮仅为 manifest 标注的非权威占位；该预演不能替代实机。
- `QL-B2 V1`：组件合同、锁定基准继承／冲突审计、单 source 三状态的
  确定性导出合同、完整生产正文和三张真实排版预演要求已经形成
  `production-draft / P2`；尚无生图授权，固定执行器 `0/5`。
- `QL-B3`：只完成稳定边界。类型／计时／状态章将在 QL-B2 候选形成后单独
  准备；Collapse All 归 QL-C 独立 Button，不混入目录状态。
- Quest Tracker：视觉 `P2`，外部 provider `P0`，暂停。
- NPC Quest／Gossip：对象合同 `P1`，美术与实机几何未锁定，保持原生。
- `questitem.lua`：行为保留，视觉 `N/A`。

## Quest Log 批次

| 批次 | 子模块 | 阶段 | 当前事实 | 下一门禁 |
|---|---|---:|---|---|
| `QL-A1` | `QUEST.LOG.SHELL` 结构母版 | `P4` | [透明 source](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 已接受；原始 PNG 不直接加载，只允许 QL-A2 V4 确定性全幅导出 | Turtle WoW 中复核最终显示 |
| `QL-A2` | 静态空卷宗结构与页沟 | `P5` V4 runtime-exported | V3.3 `15/15` 已终止；V4 已从 QL-A1 source 导出 `676 × 464` 显示区／`1024 × 512` TGA，固定执行器 `0/0`，Lua smoke 通过 | Turtle WoW 验证纹理方向、裁切、命中与 list-only |
| `QL-B0` | 23 行创建、排布、文字安全区和状态刷新 | `P5 runtime-exported` | 23 行 `323px` 几何、字体与状态刷新已接入；Lua smoke 覆盖创建、偏移、状态和原脚本 | Turtle WoW 验证文字基线、重叠命中与滚动 |
| `QL-B1` | 地区展开／收起、追踪开／关四枚墨记 | `P5 runtime-exported` | 用户接受 V1.r3；[source manifest](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json)、[runtime manifest](../../../assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json)、`64 × 16` TGA、exporter 与真实排版预演已完成；内部失败与 `5/5` 事实保留 | Turtle WoW 验证 TGA、四态切换、字体和 fallback |
| `QL-B2` | 当前任务暗酒红书签三状态 | `P2 production-draft` | [V1 work](work/QUEST.LOG.SELECTION.md) 已冻结一枚基础 source、`24 × 14` 可见几何、三态确定性派生和 23 行逐态真实排版；固定执行器 `0/5` | 用户授权 `QL-B2 V1` 与五次修复边界 |
| `QL-B3` | 类型、计时、完成／失败状态章 | `P2 baseline` | 类型 tag、timer API、isComplete 已分离；未知 tag 不猜测 | QL-B1 视觉重量确认 |
| `QL-C` | 两套 ScrollBar、关闭、Collapse All、操作与辅助按钮 | `P1–P2` | 真实对象已拆，部分全局名需 feature-detect | 实机对象与几何 |
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
  adapter runtime contract `1.1`，Lua smoke 覆盖 23 行创建、四态、滚动偏移、
  原脚本与原生纹理抑制。
- QL-B2 V1 生产合同：
  [`QUEST.LOG.SELECTION.md`](work/QUEST.LOG.SELECTION.md)；当前为
  `production-draft / P2`，固定执行器 `0/5`，没有 raw、source 或 runtime。
- Turtle WoW 实机验证尚未开始。

## 下一步

QL-A2 保持 [runtime work](work/QUEST.LOG.GUTTER.md)，等待 Turtle WoW
`1.18.1` 实机验收后才可进入 `P6`／清理。QL-B0／B1 已进入 `P5` 并等待
实机。离线下一门禁是用户审阅并明确授权 `QL-B2 V1` 的完整执行正文、固定
Image 1／2 职责、同循环 edit 输入边界和最多五次调用；“继续”本身不触发
ImageGen。QL-B1 不得继续调用 V1 ImageGen，也不得把确定性处理描述成重新
生成美术。
