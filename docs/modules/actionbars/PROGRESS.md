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
  TrinketMenu；当前角色明确启用 TrinketMenu、禁用 AutoBar，因此 AutoBar
  只作为可选消耗品 provider，不被强制启用。
- `AB.FIELDKIT.V1` 已完成 provider 级审计与第二版本地确定性模拟。TrinketMenu
  主栏严格为水平 `92×52 UI`／垂直 `52×92 UI`、两枚 `36×36 UI` 已装备
  Button、`18×18 UI` Queue inset；候选为 `0–30` 个 `36 UI` Button、步距
  `40 UI`，当前配置四列、右侧停靠并向上增长。用户明确指出 V1 的 `5×2`
  消耗品容量不足并要求按类型分组；V2 改用 AutoBar 完整 `24` 个主 Button 的
  `4×6`，连续 `1–8／9–16／17–24` 分为应急／增益／工具，分类内仍由最多
  `12` 个四向 popup 展开真实物品。display `16/16 pass`、布局 `72/72 pass`、
  violations `0`、ImageGen `0/0`；当前为 `simulation-reviewed / P2`，等待用户
  对 `AB-FIELDKIT-SIM-V2` 的方向结论。
- `AB.SLOT.BASE.V1` 有界生产循环已在 `5/5` 停止；用户于 `2026-08-08` 明确
  “接受 AB.SLOT.BASE.V1 第5稿”，随后以“进行下一步”授权 P4→P5。exact source
  RGBA `6d4a4d16…7dc0` 已按冻结 `[200,200,824,824)` crop 确定性导出为
  `128×128` 32-bit TGA `ActionSlotBaseV1.tga`，SHA `5c49a1db…23ca`，像素 SHA
  `e527c038…c35c` 与已验收 attempt 5 runtime review 完全一致。AEUI `0.7.0`
  的 `ActionBars` adapter 只在现有 pfUI Bar `1–10` 的逐按钮 `backdrop` 上创建
  full-UV 子纹理；Bar `11／12`、按钮逻辑、动态图标／文字／状态、命中区、分页、
  拖放、位置、scale 与 SavedVariables 均未接管。五种最终排版 `5/5 pass`、
  violations `0`；Lua smoke、媒体／manifest 测试与 fresh-checkout package 均
  `pass`，目标设备无需构建。用户随后提供 Turtle WoW 实机截图
  `dc9615ac…4d5d`，明确确认“CD没问题. 距离红没问题. 按下反馈没问题”与
  “动作条功能验证通过”；截图静态层级和完整交互清单分开取证。当前为
  `P6 / game-validated`，P5→P6 新增外部生成 `0`，尚未执行单组件 `P6-C`。
- 用户于 `2026-08-08` 明确“接受 AB-RAIL-SIM-V1”。该结论只冻结 Rail 的
  连续轻量承托、深胡桃褐主体、断续暗黄铜窄外缘、极少四角紧固点、安静中心、
  无固定格线、横／竖／多行同厚、Bar 1／6 合并无内部中缝，以及位于已接受
  Slot／provider 动态层之下的可见方向；模拟像素没有被接受为 source、runtime
  或生产输入。用户于 `2026-08-09` 另行授权 `AB.RAIL.V1` 最终正文、最多 `5`
  次实际生成／修复，并授权把指定 Character V3 作为本组件唯一 Image 1 上传；
  当前为 `prompt-authorized / P3`，正式生产仍为 `0/5`。

## 已确定的设计决策

- 保留 pfUI 全部 `1–12` Bar；视觉必须适配 `12×1`、`6×2`、`4×3`、竖栏、
  姿态与宠物条，不把用户锁进一种格数或行数。
- 推荐战斗预设只在用户主动应用时写入一次：主栏 `12×1 / 36 UI`，副栏
  `12×1 / 30 UI`，姿态条独立，消耗品 `4×6 / 24 类 / 三组`，饰品 `2×1`，辅助栏可保留
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
  不竞争其全局 hook。TrinketMenu 缺失时只保留真实装备槽 `13／14` 的安全
  fallback；AutoBar 缺失或当前禁用时 V1 不显示、不占位，钉选 fallback 以后
  另立功能合同。
- 饰品更换菜单保留 provider 原功能并 fail-open；当前四列 `1／8／30` 候选
  分别为 `172×52／172×92／172×332 UI`，自动五列最大 `212×252 UI`，合法
  三十列极宽为 `1212×52 UI`。左键换入槽 `13`、右键换入槽 `14`、战斗 Queue、
  八种停靠、独立 scale／方向／拖动均不改写。
- AutoBar 的视觉外壳跟随真实 Button 边界，而不是直接相信 `AutoBarFrame`
  边界；推荐 `4×6` 可见簇 `153×231 UI`、主体外壳 `165×243 UI`，三枚
  `40×20 UI` 非交互标题皮签使完整视觉边界为 `207×243 UI`。分组签名不匹配
  即隐藏标题与分隔；Popup 使用逐 Button 薄口袋与 `3 UI` 短连接带，不生成
  固定整张背景。
- 推荐分类只重排 AutoBar 已有类别 ID；职业资源／用品按职业 profile 选取。
  已审计版本没有独立 `FLASK` 类别；每个主槽原生允许最多 `16` 个类别字符串或
  数字 item ID，因此“合剂手动”只由用户在 AutoBar 配置中拖入真实物品，AEUI
  不按名称猜测。
- `AB-RAIL-SIM-V1` 已于 `2026-08-08` 完成本地确定性渲染：Rail 映射到真实
  `bar.backdrop`，独立栏在 Bar Frame 四周各外扩 border；Bar 1／6 满足 pfUI
  原合并条件时改用单一外围 Rail，不产生内部中缝。等比例板覆盖 `1×1`、`12×1`、
  `6×2`、`4×3`、`1×12`、图标 `20–48 UI`、border `1–5`、spacing `1–12`、scale
  `0.75–1.5` 与合并双栏共 `8` 场景，display `8/8 pass`、violations `0`。
  当前 accepted `AB.SLOT` 只作为模拟中的只读相邻 runtime，姿态栏仍保留 pfUI
  fallback；本阶段 ImageGen `0/0`，没有 source、runtime、adapter 或游戏改动。
  用户已接受该具体模拟版本，确认条款已冻结进 `AB.RAIL.V1` 最终生产正文；
  正文、五次预算及指定 Image 1 外部上传已于 `2026-08-09` 独立授权。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `AB.RAIL` | `P3 / prompt-authorized` | [work](work/ACTION.BARS.RAIL.V1.md)；用户于 `2026-08-08` 接受 `AB-RAIL-SIM-V1`；真实 backdrop 外扩、合并双栏、8 个独立场景均 pass；用户于 `2026-08-09` 授权最终正文、最多 `5` 次实际生成／修复和指定 Character V3 Image 1 外部上传；正式生产 `0/5` | 提交授权正文后由固定 `imagegen-0-143-0` 执行 attempt 1，并逐稿完成语义、九宫格、真实排版与展示区域审查 |
| `AB.SLOT` | `P6 / game-validated` | [source](../../../assets/source/actionbars/ab-slot/ActionSlotBase_Master_v1.png)／[source manifest](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_SourceManifest_v1.json)／[runtime manifest](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_RuntimeManifest_v1.json)／[P6 evidence](../../../assets/references/actionbars/p6/AB-SLOT-BASE-V1_P6Evidence_v1.json)；TGA `5c49a1db…23ca`、像素 `e527c038…c35c`、实机截图 `dc9615ac…4d5d`；Bar `1–10` scoped adapter，display `5/5`、package／P6 交互均 `pass` | 独立 Rail 模拟已完成；`AB.SLOT` 进入 `P6-C` 前另行展示精确保留／删除清单并取得用户批准 |
| `AB.SLOT.STATE` | `P2 / scoped` | highlight／active／equipped／icon tint／cooldown／按键动画的真实覆盖顺序已冻结 | 基底 P6 已验证；如需独立换肤再写悬停／激活覆盖合同，不生产假 disabled cell |
| `AB.ENDCAP.GRYPHON` | `P2 / direction-locked` | pfUI 左右端帽对象、64 UI 默认能力；用户确认的 V3 preset 默认关闭 | `AB.SLOT／RAIL` 后另行授权可选端帽正文 |
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET／POPUP` | `P2 / simulation-reviewed` | [work](work/ACTION.BARS.FIELDKIT.V1.md)；V1 `5×2` 已按用户要求修订；V2 使用 AutoBar `24` 主 Button 的 `4×6` 满容量布局及 `1–12` popup，主体 `165×243 UI`；当前 provider disabled；display 全场景 pass，ImageGen `0/0` | 用户接受或修订 `AB-FIELDKIT-SIM-V2`；确认前不启用 AutoBar、不执行 `AB.CONSUMABLE.KIT.V1` |
| `AB.CONSUMABLE.GROUP` | `P2 / simulation-reviewed` | 推荐 profile 的 `1–8／9–16／17–24` 对应应急／增益／工具；三枚标题皮签与两条分隔均不接收鼠标；签名失配自动退回无标签外壳；AutoBar 无原生 `FLASK` 类别，合剂只走 provider 原生的手动物品 ID | 与 V2 一起等待用户方向确认；确认前不写 profile、不创建 runtime FontString |
| `AB.TRINKET.DOCK` | `P2 / simulation-reviewed` | [work](work/ACTION.BARS.FIELDKIT.V1.md)；现用 TrinketMenu 的 `92×52／52×92 UI` 双槽、Queue、当前 scale／方向与主栏右侧 `16 px` 邻接均已模拟；V2 未改变饰品方向 | 与 Field Kit V2 一起等待用户确认；确认前不执行 `AB.TRINKET.KIT.V1` |
| `AB.TRINKET.MENU` | `P2 / simulation-reviewed` | provider `0／1／8／30`、自动／手动列数、横竖方向、最大三十列、停靠与战斗 Queue 已冻结；display 全场景 pass；V2 未改变 | 与双槽方向一起等待用户确认；生产与外部上传另行授权 |
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
- `AB.RAIL.V1` specification：`tools/specs/action_rail_v1_simulation.json`
- `AB.RAIL.V1` 战斗场景：
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/AB.RAIL.V1.sim-v1.png`
  （SHA `123d1b4c…cde6`）
- `AB.RAIL.V1` 等比例组合板：
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/simulation/AB-RAIL-SIM-V1/AB.RAIL.V1.sim-v1.layouts.png`
  （SHA `a49088d1…e353`）
- `AB.RAIL.V1` display-region 合同为
  `tools/specs/action_rail_v1_sim_display_region.json`；`8/8 pass`、violations `0`；
  精确布局报告所有九宫格中心、按钮包含、装饰避让和层序检查均 pass。
- Rail 模拟像素同样只承担方向确认，不能切片、晋级、导出或作为 ImageGen 输入；
  用户已于 `2026-08-08` 接受 `AB-RAIL-SIM-V1`，但没有接受这些像素；下一设备
  只依赖已跟踪的文字化确认与冻结正文，因此没有发布 handoff。
- `AB.FIELDKIT.V1` 当前 specification：
  `tools/specs/action_fieldkit_v2_simulation.json`。
- 战斗场景：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V2/AB.FIELDKIT.V1.sim-v2.scene.png`
  （SHA `9fe4d159…164d`）；provider 状态板：同目录
  `AB.FIELDKIT.V1.sim-v2.provider-states.png`（SHA `16a90762…f467`）。
- display 合同：`tools/specs/action_fieldkit_v2_sim_display_region.json`；
  `16/16 pass`、violations `0`。精确布局报告 `72/72 pass`、violations `0`；
  ImageGen `0/0`，没有上传、source、runtime、adapter、SavedVariables 或游戏改动。
- V1 两张模拟仍可由旧 specification 确定性重建且 SHA 不变；其 `5×2` 推荐已因
  用户容量／分组要求进入修订，不再是当前方向。
- Field Kit 模拟像素只承担方向确认，不能切片、晋级、导出或作为 ImageGen
  输入；当前等待用户对具体 `AB-FIELDKIT-SIM-V2` 作出接受／修订结论。

## 下一门禁

1. `AB.SLOT.BASE.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-SLOT-BASE-V1_TurtleWoW_P6_2026-08-08.png`
   （SHA `dc9615ac…4d5d`）与同目录 P6 evidence JSON（SHA `73a8f942…0d0b`）；
   静态截图与用户交互确认的证明范围保持分离。
2. `AB.FIELDKIT.V1` 已达到 `simulation-reviewed / P2`。下一门禁是用户明确
   接受或修订 `AB-FIELDKIT-SIM-V2` 的两张本地模拟；确认只冻结工作文件中列出的
   布局、材料层级、轮廓、配色、视觉重量、整合与状态印象，不接受模拟像素。
   确认前不得启用 AutoBar、改变 TrinketMenu 保存值或执行 production。
3. 若 Field Kit 方向确认，分别冻结 `AB.TRINKET.KIT.V1` 与
   `AB.CONSUMABLE.KIT.V1` 最终正文；随后每个执行体都必须另行取得最多 `5` 次
   实际生成／修复授权及 Character V3 作为其 Image 1 的外部上传授权。两个
   执行体最坏合计 `10` 次，任何既有 AB.SLOT／AB.RAIL 授权均不得复用。
4. `AB.RAIL.V1` 已达到 `prompt-authorized / P3`。用户对
   `AB-RAIL-SIM-V1` 的确认仍只锁定已文字化的可见方向，不接受模拟像素；另于
   `2026-08-09` 授权最终正文、最多 `5` 次实际生成／修复和指定 Character V3
   作为本组件唯一 Image 1 外部上传。不得复用 `AB.SLOT` 的生产或上传授权。
5. 下一门禁是提交本次授权版本后调用固定 `imagegen-0-143-0` 执行 attempt 1；
   每次生成后必须重新完成语义／结构／美术、九宫格装配、`100%` 真实排版与
   display-region 审查。任一候选完整通过即停止，attempt 5 仍失败则耗尽，禁止
   attempt 6；内部通过不代表用户接受 source。
6. `AB.SLOT` 若要进入 `P6-C`，必须先在现存 work 中向用户展示精确保留／删除
   inventory 并取得明确批准；当前不得清理该组件的 ignored `generated`、work
   或其他专属中间证据。
7. `AB.SLOT.STATE` 与狮鹫继续各自形成独立合同并逐批授权。Bar `1–10` scoped
   visual adapter 不改变 pfUI 功能所有权；未登记 Bar 与第三方 provider 始终
   fail-open。
