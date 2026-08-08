# Action Bars 详细进度

## 当前结论

- pfUI 十二条逻辑 Bar、按钮状态、分页、姿态／宠物、合法行列、移动／缩放与
  当前目标设备 profile 已完成 `P1` 审计。
- 用户于 `2026-08-08` 否决 `ACTION-BARS-CORE-SIM-V1` 的贴底动作条和分散、
  不同基线单位框；V2 完成上移与收拢后，用户继续要求纳入施法条、攻击条及
  DoiteDPS。用户已于 `2026-08-08` 以“依照这个设计继续进行”确认
  `ACTION-BARS-CORE-SIM-V3`，模块状态现为 `simulation-confirmed / P2`。
- 推荐方向仍是“自适应远征战斗甲板＋炼金卷袋＋饰品双护套”，V3 在 V2
  中下战斗焦点上增加单一纵向信息栈：DoiteDPS → 攻击计时 → Aura／双方状态 →
  双施法条 → 姿态／技能栏。这是用户主动应用的一次性 preset，不由维护循环
  重写位置或 scale。
- 目标客户端为 `1920×1080`、UI Scale `0.81269841269841`；当前使用习惯是
  两条 `12×1` 与若干 `4×3` 辅助栏。V3 沿用主栏外框
  `[713,827,1207,870]`，底边净空 `210 px`；玩家／目标框内缘间距 `80 px`。
- pfUI 施法条与 SwingTimer 已按真实对象审计：玩家／目标／Focus Castbar 均可
  独立移动；攻击条为 `200×12 UI` 主手、随主手锚定副手及独立 ranged。V3
  双施法条物理 `239×20 px`，近战双计时物理 `163×10 px`。
- 目标设备已安装 DoiteDPS；真实根 Frame 为 `318×46 UI`，Ready 槽 `46 UI`、
  Forecast `34 UI`、资源框 `178×22 UI`，现有 scale `1.0`。V3 只提出中心落位
  与以后可选的低重量视觉桥接，不改其推荐逻辑、锁定、显隐或保存值。
- 目标客户端另已安装 TrinketMenu 与 AutoBar。饰品桥接优先保留正在使用的
  TrinketMenu；AutoBar 作为可选消耗品 provider，近期无活跃布局也不被强制
  启用。
- 当前实际 ImageGen：`0/5`；没有正式候选、source、runtime、接管路由或
  addon 变更。首批 `AB.SLOT.BASE.V1` 已拆成单一普通／空槽基底并完成正式
  生产正文；用户于 `2026-08-08` 明确授权该正文及最多五次实际生成／修复，
  当前进入 `P3 / prompt-authorized`。固定子进程在启动前因指定 Character V3
  锁定图缺少明确的外部 ImageGen 上传授权而被数据出境审查阻止；已记无生成、
  不计预算的流程错误 `E1`。

## 已确定的设计决策

- 保留 pfUI 全部 `1–12` Bar；视觉必须适配 `12×1`、`6×2`、`4×3`、竖栏、
  姿态与宠物条，不把用户锁进一种格数或行数。
- 推荐战斗预设只在用户主动应用时写入一次：主栏 `12×1 / 36 UI`，副栏
  `12×1 / 30 UI`，姿态条独立，消耗品 `5×2`，饰品 `2×1`，辅助栏可保留
  `4×3`；V3 沿用主栏 `scale=1.2`、副栏 `scale=1.1`，中心均为物理 `x=960`。
- V3 邻接建议把 pfUI Player／Target 统一为 `280×72 UI / scale 1.05 / y=468`，
  玩家 `x=-49`、目标 `x=49`，得到物理同基线和 `80 px` 内缘间距；Action Bars
  不接管其视觉，也不在本模拟写入 SavedVariables。
- DoiteDPS 原生根 Frame 置于物理 `[831,514,1089,551]`；主／副手攻击条置于
  `[879,570,1042,580]` 与 `[879,583,1042,593]`，ranged 复用同层；Aura 移到
  `y=612–631` 的两侧外肩；玩家／目标施法条置于 `y=708–728` 并与各自状态框
  同宽。相邻信息层最小净空已明确，不新增维护循环。
- Focus Castbar 继续跟随可选 Focus Frame，不进入中央双框；DoiteDPS、Castbar
  和 SwingTimer 均保留原 provider 的独立拖动、缩放、显隐与 fail-open。
- 主栏、战斗核心栏、消耗品和饰品在战斗中保持可见；只有非核心辅助栏允许
  脱战淡出或 mouseover。
- 自适应 Rail 与逐槽边框分离。V3 推荐 preset 默认关闭狮鹫以减轻中央重量；
  狮鹫仍可在 unlock 中为合法水平主栏开启，过窄／竖向布局自动关闭。
- Bar `1–10` 的逐槽基底与状态覆盖分离：基底只映射
  `pfActionBar<BarName>Button1..12.backdrop`；`f.highlight`、`f.active`、
  `f.equipped`、`f.icon` 顶点色、`f.cd` 和既有按键动画继续表达悬停、当前技能、
  装备、不可用／距离／法力、冷却与按下。pfUI 没有独立 disabled Button cell，
  不为其生产假状态。
- AutoBar／TrinketMenu 存在时只做 feature-detect 视觉桥接，不复制其数据表、
  不竞争其全局 hook；缺失时 fallback 只处理明确绑定的真实物品／装备槽。
- 饰品更换菜单保留 provider 原功能并 fail-open；其候选层几何尚未锁定，不能
  与双槽主框一起提前生产。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `AB.RAIL` | `P2 / direction-locked` | pfUI `BarLayoutSize` 公式与用户确认的 V3 中下焦点；与逐槽资产分批 | `AB.SLOT` 后另写可伸缩 Rail 正文并测 border／scale 极值 |
| `AB.SLOT` | `P3 / prompt-authorized` | Bar `1–10` 真按钮／backdrop、`18–48 UI` 图标范围、约 `90%` 图标覆盖区与 Character V3 材料继承已冻结；正文已获授权；pre-launch 数据出境审查形成非计数 `E1`，ImageGen `0/5` | 用户明确授权指定 Character V3 锁定图上传至外部 ImageGen；之后固定执行器重试 attempt 1 |
| `AB.SLOT.STATE` | `P2 / scoped` | highlight／active／equipped／icon tint／cooldown／按键动画的真实覆盖顺序已冻结 | 基底 source 接受后另写悬停／激活覆盖合同；不生产假 disabled cell |
| `AB.ENDCAP.GRYPHON` | `P2 / direction-locked` | pfUI 左右端帽对象、64 UI 默认能力；用户确认的 V3 preset 默认关闭 | `AB.SLOT／RAIL` 后另行授权可选端帽正文 |
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET` | `P2 / direction-locked` | AutoBar 1–24 真按钮与用户确认的 `5×2` 上移实例 | `AB.SLOT／RAIL` 后冻结 popup 支持上限并另行授权 |
| `AB.TRINKET.DOCK` | `P2 / direction-locked` | TrinketMenu 槽 `13／14` 与用户确认的上移双护套实例 | 另行编写双护套正文；候选菜单继续独立 |
| `AB.TRINKET.MENU` | `P1` | provider 已证实可换装／排队 | 记录 0／典型／最大候选数、方向和战斗限制 |
| `AB.FOCUS.CASTBAR` | `P2 / direction-locked` | 玩家／目标／Focus 真实对象与用户确认的 V3 双框下沿实例 | 以后独立决定只做一次性布局 preset 或另授权细 Rail 换肤 |
| `AB.FOCUS.SWING` | `P2 / direction-locked` | 主手／副手／ranged 真对象、`200×12 UI` 与用户确认的中心双细轨 | 实机验证近战／远程复用；若换肤则另立合同 |
| `AB.DOITEDPS.TIMELINE` | `P2 / direction-locked` | 已安装 provider 的 `318×46 UI` 根 Frame及用户确认的中心落位 | 以后只做 feature-detect 一次性位置 preset 或独立换肤合同 |
| `AB.MOVER／CONFIG` | `P1` | pfUI `UpdateMovable` 与 unlock 已审计 | 设计只在 unlock 出现的把手和一次性预设入口 |

## 当前方向预演

- specification：`tools/specs/action_bars_core_simulation_v3.json`
- 本地渲染：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V3/action_bars_core_sim_v3.png`
- display-region 合同：
  `tools/specs/action_bars_core_simulation_v3_display_region.json`
- 报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V3/display-region-report.json`；
  新增战斗读数 `9/9 pass`、violations `0`，动作本体继承 V2 `9/9 pass`
- 精确布局报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V3/layout-report.json`；
  `46/46 pass`、violations `0`
- V2 回归重渲染 SHA 仍为
  `943d6fac246f0ebc98ebf478519da05f18c3e8e35c4279b785034a4c5548e5d0`。
- 模拟像素为非权威本地中间件，不能切片、晋级或作为 ImageGen 输入。

## 下一门禁

1. 用户明确授权将
   `assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`
   上传至外部 ImageGen，作为已授权 `AB.SLOT.BASE.V1` 的唯一 Image 1。
2. 使用固定 `@openai/codex@0.143.0`，按已提交的完整正文重试 attempt 1。
3. 对每次候选执行语义、组件、技术像素、`100%` runtime 真实排版与实际展示
   区域内审；任一候选通过即停止，失败才按第一门禁准备并提交完整 `.rN`。
4. 基底 source 接受后，再分别准备 `AB.SLOT.STATE` 与 `AB.RAIL`；狮鹫、消耗品
   卷袋和饰品护套继续各自形成独立 source／atlas 合同并逐批授权。
5. 正式候选接受后才允许登记 Action Bars 精确接管路由和 runtime adapter；
   未接管 Bar 与第三方 provider 始终 fail-open。
