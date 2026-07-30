# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- 用户于 `2026-07-30` 将 Quest Log 选为当前首要大面积 UI；地图与角色因
  实机对象几何尚未完成，继续保持后续顺位。
- Quest Log 真实对象合同：`P1` 完成，QL-A 当前处于 `P4–P5`；QL-B1
  V1.r3 已由用户接受运行时视觉并晋级 `source-accepted / P4`。
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
  改写成通过。透明母版与 source manifest 已 tracked，当前为
  `source-accepted / P4`，固定执行器仍是 `5/5` 且不再调用。
- `QL-B2`／`QL-B3`：只完成稳定边界。选中书签与类型／计时／状态章将在
  QL-B1 小尺寸视觉重量确认后分别准备；Collapse All 归 QL-C 独立 Button，
  不混入目录墨记。
- Quest Tracker：视觉 `P2`，外部 provider `P0`，暂停。
- NPC Quest／Gossip：对象合同 `P1`，美术与实机几何未锁定，保持原生。
- `questitem.lua`：行为保留，视觉 `N/A`。

## Quest Log 批次

| 批次 | 子模块 | 阶段 | 当前事实 | 下一门禁 |
|---|---|---:|---|---|
| `QL-A1` | `QUEST.LOG.SHELL` 结构母版 | `P4` | [透明 source](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 已接受；原始 PNG 不直接加载，只允许 QL-A2 V4 确定性全幅导出 | Turtle WoW 中复核最终显示 |
| `QL-A2` | 静态空卷宗结构与页沟 | `P5` V4 runtime-exported | V3.3 `15/15` 已终止；V4 已从 QL-A1 source 导出 `676 × 464` 显示区／`1024 × 512` TGA，固定执行器 `0/0`，Lua smoke 通过 | Turtle WoW 验证纹理方向、裁切、命中与 list-only |
| `QL-B0` | 23 行创建、排布、文字安全区和状态刷新 | `P2 contract` | 保留 23 行的 `323px` 离线几何已定义，尚未接入 | 随已接受目录资产实现并做 smoke |
| `QL-B1` | 地区展开／收起、追踪开／关四枚墨记 | `P4 source-accepted` | 用户接受 V1.r3 运行时视觉；[透明母版](../../../assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png) 与 [manifest](../../../assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json) 已 tracked；内部失败与 `5/5` 事实保留 | 确定性导出四格 atlas、接入 QL-B0 23 行并静态验证 |
| `QL-B2` | 当前任务暗酒红书签三状态 | `P2 baseline` | 真实语义与美术边界已定义，无执行正文 | QL-B1 视觉重量确认 |
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
  `assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png`，runtime
  尚未导出。
- Turtle WoW 实机验证尚未开始。

## 下一步

QL-A2 保持 [runtime work](work/QUEST.LOG.GUTTER.md)，等待 Turtle WoW
`1.18.1` 实机验收后才可进入 `P6`／清理。QL-B1 V1.r3 已由用户接受并进入
`P4`；下一门禁是按 manifest 导出四格 runtime atlas、把 23 行真实布局与
状态刷新接入 adapter，并以真实任务文本密度和当前新 UI 生成 100% 尺寸
预演。不得继续调用 V1 ImageGen，也不得把确定性处理描述成重新生成美术。
