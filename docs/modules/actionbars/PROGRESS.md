# Action Bars 详细进度

## 当前结论

- pfUI 十二条逻辑 Bar、按钮状态、分页、姿态／宠物、合法行列、移动／缩放与
  当前目标设备 profile 已完成 `P1` 审计。
- `ACTION-BARS-CORE-SIM-V1` 已完成本地确定性方向预演，状态为
  `simulation-reviewed`；用户结论待确认，因此模块尚未锁定 `P2`。
- 推荐方向是“自适应远征战斗甲板＋炼金卷袋＋饰品双护套”，不是固定布局
  重写。现有 pfUI 位置、scale、按钮数和行列默认保持不变。
- 目标客户端为 `1920×1080`、UI Scale `0.81269841269841`；当前使用习惯是
  底部两条 `12×1` 与若干 `4×3` 辅助栏，模拟据此而非抽象容量绘制。
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
  `4×3`。
- 主栏、战斗核心栏、消耗品和饰品在战斗中保持可见；只有非核心辅助栏允许
  脱战淡出或 mouseover。
- 自适应 Rail 与逐槽边框分离。狮鹫只附着水平主栏，过窄／竖向布局自动关闭，
  不影响拖动和点击。
- AutoBar／TrinketMenu 存在时只做 feature-detect 视觉桥接，不复制其数据表、
  不竞争其全局 hook；缺失时 fallback 只处理明确绑定的真实物品／装备槽。
- 饰品更换菜单保留 provider 原功能并 fail-open；其候选层几何尚未锁定，不能
  与双槽主框一起提前生产。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `AB.RAIL` | `P1 / simulation-reviewed` | pfUI `BarLayoutSize` 公式与 V1 预演 | 用户确认自适应 Rail 的综合色重；再测 border／scale 极值 |
| `AB.SLOT／STATE` | `P1 / simulation-reviewed` | 真实 Action Button 状态已审计；Character V3 材料继承 | 冻结图标安全区、四态 atlas 与 runtime 覆盖顺序 |
| `AB.ENDCAP.GRYPHON` | `P1 / simulation-reviewed` | pfUI 左右端帽对象、64 UI 默认能力 | 用户确认成对狮鹫的大小和是否常驻 |
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET` | `P1 / simulation-reviewed` | AutoBar 1–24 真按钮与 `5×2` V1 实例 | 用户确认卷袋隐喻；再冻结 popup 支持上限 |
| `AB.TRINKET.DOCK` | `P1 / simulation-reviewed` | TrinketMenu 槽 `13／14`、水平主框与 V1 实例 | 用户确认双护套位置和重量 |
| `AB.TRINKET.MENU` | `P1` | provider 已证实可换装／排队 | 记录 0／典型／最大候选数、方向和战斗限制 |
| `AB.MOVER／CONFIG` | `P1` | pfUI `UpdateMovable` 与 unlock 已审计 | 设计只在 unlock 出现的把手和一次性预设入口 |

## 当前方向预演

- specification：`tools/specs/action_bars_core_simulation_v1.json`
- 本地渲染：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V1/action_bars_core_sim_v1.png`
- display-region 合同：
  `tools/specs/action_bars_core_simulation_v1_display_region.json`
- 报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V1/display-region-report.json`
- 模拟像素为非权威本地中间件，不能切片、晋级或作为 ImageGen 输入。

## 下一门禁

1. 用户确认或否决 `ACTION-BARS-CORE-SIM-V1` 的中心两层布局、左右随身栏、
   成对狮鹫重量、炼金卷袋隐喻和综合色重。
2. 确认后把可见条款写回主／子模块 Prompt，模块才进入 `P2`；若布局或隐喻
   变化则先出新的 `0` 次 ImageGen 模拟。
3. 分批完成 `AB.SLOT＋RAIL`、狮鹫、消耗品卷袋、饰品护套的 source／atlas
   合同；每批生产正文另行取得授权。
4. 正式候选接受后才允许登记 Action Bars 精确接管路由和 runtime adapter；
   未接管 Bar 与第三方 provider 始终 fail-open。
