# Action Bars 详细进度

## 当前结论

- pfUI 十二条逻辑 Bar、按钮状态、分页、姿态／宠物、合法行列、移动／缩放与
  当前目标设备 profile 已完成 `P1` 审计。
- 用户于 `2026-08-08` 否决 `ACTION-BARS-CORE-SIM-V1` 的贴底动作条和分散、
  不同基线单位框；`ACTION-BARS-CORE-SIM-V2` 已按要求完成本地确定性改版，
  状态为 `simulation-reviewed`，用户结论待确认，因此模块尚未锁定 `P2`。
- 推荐方向仍是“自适应远征战斗甲板＋炼金卷袋＋饰品双护套”，但 V2 改为
  中下战斗焦点：主栏约 `39 px` 技能格并上移，玩家／目标状态框同基线收拢。
  这是用户主动应用的一次性 preset，不由维护循环重写位置或 scale。
- 目标客户端为 `1920×1080`、UI Scale `0.81269841269841`；当前使用习惯是
  两条 `12×1` 与若干 `4×3` 辅助栏。V2 主栏外框为
  `[713,827,1207,870]`，底边净空 `210 px`；玩家／目标框内缘间距 `80 px`。
- 目标客户端已安装 TrinketMenu 与 AutoBar。饰品桥接优先保留正在使用的
  TrinketMenu；AutoBar 作为可选消耗品 provider，近期无活跃布局也不被强制
  启用。
- 当前实际 ImageGen：`0/5`；没有正式候选、source、runtime、接管路由或
  addon 变更。

## 已确定的设计决策

- 保留 pfUI 全部 `1–12` Bar；视觉必须适配 `12×1`、`6×2`、`4×3`、竖栏、
  姿态与宠物条，不把用户锁进一种格数或行数。
- 推荐战斗预设只在用户主动应用时写入一次：主栏 `12×1 / 36 UI`，副栏
  `12×1 / 30 UI`，姿态条独立，消耗品 `5×2`，饰品 `2×1`，辅助栏可保留
  `4×3`；V2 主栏 `scale=1.2`、副栏 `scale=1.1`，中心均为物理 `x=960`。
- V2 邻接建议把 pfUI Player／Target 统一为 `280×72 UI / scale 1.05 / y=468`，
  玩家 `x=-49`、目标 `x=49`，得到物理同基线和 `80 px` 内缘间距；Action Bars
  不接管其视觉，也不在本模拟写入 SavedVariables。
- 主栏、战斗核心栏、消耗品和饰品在战斗中保持可见；只有非核心辅助栏允许
  脱战淡出或 mouseover。
- 自适应 Rail 与逐槽边框分离。V2 推荐 preset 默认关闭狮鹫以减轻中央重量；
  狮鹫仍可在 unlock 中为合法水平主栏开启，过窄／竖向布局自动关闭。
- AutoBar／TrinketMenu 存在时只做 feature-detect 视觉桥接，不复制其数据表、
  不竞争其全局 hook；缺失时 fallback 只处理明确绑定的真实物品／装备槽。
- 饰品更换菜单保留 provider 原功能并 fail-open；其候选层几何尚未锁定，不能
  与双槽主框一起提前生产。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `AB.RAIL` | `P1 / simulation-reviewed` | pfUI `BarLayoutSize` 公式与 V2 中下焦点预演 | 用户确认自适应 Rail 的综合色重；再测 border／scale 极值 |
| `AB.SLOT／STATE` | `P1 / simulation-reviewed` | 真实 Action Button 状态已审计；Character V3 材料继承 | 冻结图标安全区、四态 atlas 与 runtime 覆盖顺序 |
| `AB.ENDCAP.GRYPHON` | `P1 / simulation-reviewed` | pfUI 左右端帽对象、64 UI 默认能力；V2 preset 默认关闭 | 用户确认默认无狮鹫、unlock 可选开启的规则 |
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET` | `P1 / simulation-reviewed` | AutoBar 1–24 真按钮与随核心区上移的 `5×2` V2 实例 | 用户确认卷袋位置／隐喻；再冻结 popup 支持上限 |
| `AB.TRINKET.DOCK` | `P1 / simulation-reviewed` | TrinketMenu 槽 `13／14` 与随核心区上移的 V2 实例 | 用户确认双护套位置和重量 |
| `AB.TRINKET.MENU` | `P1` | provider 已证实可换装／排队 | 记录 0／典型／最大候选数、方向和战斗限制 |
| `AB.MOVER／CONFIG` | `P1` | pfUI `UpdateMovable` 与 unlock 已审计 | 设计只在 unlock 出现的把手和一次性预设入口 |

## 当前方向预演

- specification：`tools/specs/action_bars_core_simulation_v2.json`
- 本地渲染：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/action_bars_core_sim_v2.png`
- display-region 合同：
  `tools/specs/action_bars_core_simulation_v2_display_region.json`
- 报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/display-region-report.json`
- 精确布局报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/layout-report.json`；
  `20/20 pass`、violations `0`
- 模拟像素为非权威本地中间件，不能切片、晋级或作为 ImageGen 输入。

## 下一门禁

1. 用户确认或继续修订 `ACTION-BARS-CORE-SIM-V2` 的主栏高度、玩家／目标框
   距离、左右随身栏位置、默认无狮鹫和综合色重。
2. 确认后把可见条款写回主／子模块 Prompt，模块才进入 `P2`；若布局或隐喻
   变化则先出新的 `0` 次 ImageGen 模拟。
3. 分批完成 `AB.SLOT＋RAIL`、狮鹫、消耗品卷袋、饰品护套的 source／atlas
   合同；每批生产正文另行取得授权。
4. 正式候选接受后才允许登记 Action Bars 精确接管路由和 runtime adapter；
   未接管 Bar 与第三方 provider 始终 fail-open。
