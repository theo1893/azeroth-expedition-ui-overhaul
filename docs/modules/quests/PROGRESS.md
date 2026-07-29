# Quests 详细进度

## 当前结论

- Quest Log 主视觉：已锁定。
- 用户于 `2026-07-30` 将 Quest Log 选为当前首要大面积 UI；地图与角色因
  实机对象几何尚未完成，继续保持后续顺位。
- Quest Log 真实对象合同：`P1` 完成，QL-A 当前处于 `P2–P4` 混合阶段。
- `QL-A1` 空卷宗结构 source：用户确认，`P4`。
- `QL-A2 V3.1`：用户于 `2026-07-30` 明确授权执行正文与固定 SHA 的
  Image 1／2／3 上传；完整固定执行会话
  `019faed6-8104-7ef2-94f7-8d80c5c885bc` 已形成 raw，但内部审查在第一道
  语义／物理门禁退回，当前为 `candidate-rejected / P3`。raw 虽恰好包含
  八组对象，却仍有满页高频压花、双边实心内折、粗长辫绳针脚和完全外露
  线结；RGB 背景也不是合同要求的真透明或均匀 `#00FF00`。未创建透明候选、
  重组预演、source 或 runtime。
- Quest Tracker：视觉 `P2`，外部 provider `P0`，暂停。
- NPC Quest／Gossip：对象合同 `P1`，美术与实机几何未锁定，保持原生。
- `questitem.lua`：行为保留，视觉 `N/A`。

## Quest Log 批次

| 批次 | 子模块 | 阶段 | 当前事实 | 下一门禁 |
|---|---|---:|---|---|
| `QL-A1` | `QUEST.LOG.SHELL` 结构母版 | `P4` | [透明 source](../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png) 已接受；整图不得进 runtime | 等待 QL-A2 后确定 crop／UV |
| `QL-A2` | 两纸页与六个 `GUTTER.*` | `P3` candidate-rejected | V1、V2.1、V3、V3.1 均已退回；[V3.1 work](work/QUEST.LOG.GUTTER.md) 已记录完整执行与首个失败门禁 | 先提交 V3.1 退回记录，再准备拆分纸页／页沟源画布的 V3.2 草案 |
| `QL-B` | 目录行、展开、追踪、选择、类型、状态 | `P1–P2` | 子模块与稳定美术基线已定义，无生产 work | QL-A2 source 接受后逐对象建 Prompt |
| `QL-C` | 两套 ScrollBar、关闭、操作与辅助按钮 | `P1–P2` | 真实对象已拆，部分全局名需 feature-detect | 实机对象与几何 |
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
- QL-A2 失败候选只存在于被忽略的 `generated/quests/QL-A2/`；没有 tracked
  source 或 runtime。
- Turtle WoW 实机验证尚未开始。

## 下一步

先提交 [QL-A2 V3.1 退回记录](work/QUEST.LOG.GUTTER.md)，保存授权提交、
完整会话、raw SHA 与首个失败门禁。随后在同一 work 文件中准备 V3.2：
把两张大纸页与六个页沟小件拆成两个固定调用，避免八种尺度挤在同一画布；
新版本正文必须重新展示并取得明确授权，不能自动重试。
