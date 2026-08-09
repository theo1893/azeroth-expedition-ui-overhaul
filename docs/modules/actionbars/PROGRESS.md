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
  violations `0`、ImageGen `0/0`。用户于 `2026-08-09` 明确回复“接受
  AB-FIELDKIT-SIM-V2”，八项文字化方向已冻结进 `AB.TRINKET.KIT.V1` 与
  `AB.CONSUMABLE.KIT.V1` 最终正文；模拟像素未被接受。用户于 `2026-08-09`
  分别授权两个正文、各自最多五次实际生成／修复，并分别授权 Character V3
  作为各自唯一的 Image 1 外部上传；当前仍为 `P3`。
  Trinket attempt 4 raw `2e4efc1a…19e3a` 经确定性传输得到 exact canonical
  `82dd2260…c012`；四格各一显著组件、不触原始 cell 边界，visible green、透明
  RGB 和最终 `80 px` margin 全部 pass。语义、美术、provider 所有权及真实排版
  `16/16`／violations `0` 也全部通过，现为 `candidate-reviewed / pending-user-
  acceptance / 4/5`，按 pass 即停且不执行 attempt 5。用户此前于
  `2026-08-09` 明确授权两个 Kit 采用纯 `#00FF00`
  RGB raw→本地确定性 canonical `1024² RGBA` 的传输修订，允许整图归一、逐
  cell 完整 bbox 等比缩放居中、边缘连通色键转 straight Alpha 与透明 RGB
  清零；不重绘、不新增输入图、预算不重置。Consumable attempt 1 raw
  `de25567f…b8ba`／canonical `623f29c5…a2419` 也已在 `1/5` 通过同样的完整门禁与
  `16/16` display，现为 `candidate-reviewed / pending-user-acceptance`，不执行
  attempts 2–5。
- `AB.SLOT.BASE.V1` 有界生产循环已在 `5/5` 停止；用户于 `2026-08-08` 明确
  “接受 AB.SLOT.BASE.V1 第5稿”，随后以“进行下一步”授权 P4→P5。exact source
  RGBA `6d4a4d16…7dc0` 已按冻结 `[200,200,824,824)` crop 确定性导出为
  `128×128` 32-bit TGA `ActionSlotBaseV1.tga`，SHA `5c49a1db…23ca`，像素 SHA
  `e527c038…c35c` 与已验收 attempt 5 runtime review 完全一致。AEUI `0.8.0`
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
  固定执行器已完成 `5/5`。attempt 5 raw `3f92fb61…ac42` 保留 provenance；
  完整 provider 画布归一后 alpha bbox `744×751`、纵横误差 `0.932%`，整体 fit
  到冻结盒后 exact canonical RGBA `7c49995d…32e9` 完成 technical `4/4`、真实布局
  `8/8`、violations `0` 与内部视觉审查。用户于 `2026-08-09` 明确“接受
  AB.RAIL.V1 第5稿”；exact bytes 已晋升为
  `assets/source/actionbars/ab-rail/ActionRail_Master_v1.png`，source／candidate
  SHA 同为 `7c49995d…32e9`，manifest 已记录 Alpha、完整 bbox、prompt／executor
  provenance 与用户接受边界。用户随后以“进行下一步”授权 P4→P5；完整
  `704²` crop 只做一次等比 `704→176` LANCZOS 缩放，并置于 `256²` atlas 的
  `[40,40,216,216)`。最终 32-bit `ActionRailV1.tga` SHA 为
  `1e5cca09…0a3d`、像素 SHA 为 `1b09b93b…9db5`；九宫格边界
  `40／72／184／216`、UV `0.15625／0.28125／0.71875／0.84375`、cap `6 UI`。
  同一 `ActionBars` adapter 只在 Bar `1–12` 的既有 `bar.backdrop` 与 Bar `1／6`
  的既有 `mergedBackdrop.backdrop` 上创建九枚非交互纹理；不修改 pfUI、Button、
  SavedVariables 或 provider 几何。最终 display `8/8 pass`、violations `0`，
  Lua smoke、runtime／repository tests 与 fresh-checkout package 均通过，目标设备
  无需构建。用户于 `2026-08-09` 在收到完整六项 Rail 实机清单后明确回复
  “游戏内验证通过”，并补充 `580×129 RGB` Turtle WoW 截图
  `5e89c6e5…12942`；截图静态层级与用户对横／竖／多行、Bar `1／6` merged、
  拖动／缩放／显隐、姿态／宠物、fail-open 和 `rail-contract=1.0` 的交互确认
  分开取证。当前为 `P6 / game-validated`；禁止 attempt 6，P4→P6 新增
  ImageGen `0`，尚未执行单组件 `P6-C`。

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
- `AB.RAIL.V1` accepted source 与 runtime：
  `assets/source/actionbars/ab-rail/ActionRail_Master_v1.png`，SHA
  `7c49995d…32e9`；source manifest：同目录
  `AB-RAIL-V1_SourceManifest_v1.json`。母版为 `1024² RGBA`、visible bbox
  `[160,160,864,864)`，完整 `704²` crop 的 source 九宫格边界为
  `0／128／576／704`。确定性 exporter 为
  `tools/build_action_rail_v1_runtime.py`；runtime manifest 为同目录
  `AB-RAIL-V1_RuntimeManifest_v1.json`，客户端媒体为
  `addon/AzerothExpeditionUI/Media/ActionBars/ActionRailV1.tga`，SHA
  `1e5cca09…0a3d`。runtime 是 `256² RGBA`，可见 bbox
  `[40,40,216,216)`，九宫格为 `32／112／32 px`，端宽 `6 UI`；source 不直接
  被客户端加载。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `AB.RAIL` | `P6 / game-validated` | [source](../../../assets/source/actionbars/ab-rail/ActionRail_Master_v1.png)／[source manifest](../../../assets/source/actionbars/ab-rail/AB-RAIL-V1_SourceManifest_v1.json)／[runtime manifest](../../../assets/source/actionbars/ab-rail/AB-RAIL-V1_RuntimeManifest_v1.json)／[P6 evidence](../../../assets/references/actionbars/p6/AB-RAIL-V1_P6Evidence_v1.json)／[work](work/ACTION.BARS.RAIL.V1.md)；TGA `1e5cca09…0a3d`、像素 `1b09b93b…9db5`、实机截图 `5e89c6e5…12942`；Bar `1–12`＋Bar `1／6` merged scoped adapter，display `8/8`、package／P6 六项清单均 pass；固定生产 `5/5`，P4→P6 ImageGen `0`，不得 attempt 6 | 进入 `P6-C` 前在现存 work 中展示组件专属精确保留／删除清单并取得用户明确批准；当前不得清理中间证据 |
| `AB.SLOT` | `P6 / game-validated` | [source](../../../assets/source/actionbars/ab-slot/ActionSlotBase_Master_v1.png)／[source manifest](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_SourceManifest_v1.json)／[runtime manifest](../../../assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_RuntimeManifest_v1.json)／[P6 evidence](../../../assets/references/actionbars/p6/AB-SLOT-BASE-V1_P6Evidence_v1.json)；TGA `5c49a1db…23ca`、像素 `e527c038…c35c`、实机截图 `dc9615ac…4d5d`；Bar `1–10` scoped adapter，display `5/5`、package／P6 交互均 `pass` | 独立 Rail 模拟已完成；`AB.SLOT` 进入 `P6-C` 前另行展示精确保留／删除清单并取得用户批准 |
| `AB.SLOT.STATE` | `P2 / scoped` | highlight／active／equipped／icon tint／cooldown／按键动画的真实覆盖顺序已冻结 | 基底 P6 已验证；如需独立换肤再写悬停／激活覆盖合同，不生产假 disabled cell |
| `AB.ENDCAP.GRYPHON` | `P2 / direction-locked` | pfUI 左右端帽对象、64 UI 默认能力；用户确认的 V3 preset 默认关闭 | `AB.SLOT／RAIL` 后另行授权可选端帽正文 |
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET／POPUP` | `P3 / candidate-reviewed / transport-amended / 1/5` | [work](work/ACTION.BARS.FIELDKIT.V1.md)；attempt 1 raw `de25567f…b8ba`／canonical `623f29c5…a2419`；AutoBar `24` 主 Button、`4×6` 满容量、`1–12` popup、极端横竖布局、四格隔离、传输和美术全 pass，display `16/16`；当前 provider 仍 disabled | 等待用户明确接受；此前不得晋级 source／runtime，不执行 attempts 2–5，不启用 AutoBar |
| `AB.CONSUMABLE.GROUP` | `P3 / candidate-reviewed / 1/5` | 用户已确认推荐 profile 的 `1–8／9–16／17–24` 对应应急／增益／工具；attempt 1 的 filled C shell 与 D divider 在完整布局通过；三枚标题皮签与两条分隔仍不接收鼠标，AutoBar 无原生 `FLASK` 类别 | 与 Consumable Kit 共用 attempt 1 candidate；等待用户明确接受，接受前不写 profile、不创建 runtime FontString |
| `AB.TRINKET.DOCK` | `P3 / candidate-reviewed / 4/5` | [work](work/ACTION.BARS.FIELDKIT.V1.md)；attempt 4 raw `2e4efc1a…19e3a`／canonical `82dd2260…c012`；Prompt、四格隔离、传输、美术与真实排版全 pass，未使用第 5 次预算 | 等待用户明确接受；此前不得晋级 source／runtime，不改变 TrinketMenu SavedVariables |
| `AB.TRINKET.MENU` | `P3 / candidate-reviewed / 4/5` | C 为连续 filled matte center，D 为独立短连接扣；候选 `0／1／8／30`、自动五列、横竖及三十列等 `16/16 pass`、violations `0` | 与 Dock 共用 attempt 4 candidate；等待用户明确接受，不执行 attempt 5 |
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
- `AB.RAIL.V1` 正式候选统一由
  `tools/review_action_rail_candidate_v1.py` 按冻结 `1024²` 画布、
  `[160,160,864,864)` crop、`128／448／128` 九宫格和同一 8 场景生成 ignored
  指标／真实排版证据；opt-in canonical 审查先把完整 provider 画布归一到
  `1024²`，只在完整 alpha bbox 纵横误差不超过 `1%` 时把完整物件 fit 到冻结
  `704²` 盒，不裁边、不重绘、不掩盖美术失败；该工具不创建 source 或 runtime，
  也不修补候选语义。
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
- `AB.RAIL.V1` 最终 runtime exporter：
  `tools/build_action_rail_v1_runtime.py`（SHA `1f1a7662…0421`）；tracked display
  合同：`tools/specs/action_rail_v1_runtime_display_region.json`（SHA
  `c45dbfc9…0f9`）。最终 atlas、等比例组合板与 `1920×1080` 真实排版分别为
  `generated/actionbars/AB.RAIL/AB.RAIL.V1/runtime/V1/` 下
  `AB.RAIL.V1.runtime-v1.atlas.png`（SHA `b30da785…2727`）、
  `AB.RAIL.V1.runtime-v1.layouts.png`（SHA `3633fdbe…e2a3`）与
  `AB.RAIL.V1.runtime-v1.real-layout-1920x1080.png`（SHA `f599472f…fd5c`）。
  display 报告 SHA `34c9388d…4c91`，`8/8 pass`、violations `0`；fresh-checkout
  package 报告 SHA `058214a8…80e5`，`status=pass`、目标设备
  `build_required=false`。这些 ignored 预演／报告不是 source 或 runtime；目标设备
  只需 tracked addon。
- `AB.FIELDKIT.V1` 当前 specification：
  `tools/specs/action_fieldkit_v2_simulation.json`。
- production canonicalizer：`tools/canonicalize_action_fieldkit_candidate_v1.py`；
  只做获授权的全画布归一、逐 cell 边缘连通色键／完整 bbox 等比 fit／居中、
  straight Alpha 与透明 RGB 清零。candidate reviewer：
  `tools/review_action_fieldkit_candidate_v1.py`；canonical 路径必须匹配
  canonicalization report 的 component／attempt／raw SHA／canonical SHA。
  `tests/action_fieldkit_candidate_review_test.py` 覆盖 exact RGBA、旧失败棋盘审查、
  绿色传输、provenance 与横／竖极端九宫格。所有输出仍不是 source／runtime。
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
  输入；用户于 `2026-08-09` 接受具体 `AB-FIELDKIT-SIM-V2` 的文字化方向，
  两个最终 production body 已完成确认条款转写与完整性复核。
- Trinket attempt 1 raw：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.TRINKET.KIT.V1/attempt-01/raw/AB.TRINKET.KIT.V1.attempt-01.raw.png`
  （SHA `fe4b854e…c9e8d`，`1254×1254 RGB`）。review-only scene
  `926f23ca…875f`、supported layouts `1474ae4b…a268`、cell board
  `4a887dd6…2246`；display `16/16 pass`，candidate technical checks fail
  `raw_exact_1024_canvas／raw_rgba_mode／raw_has_true_transparency／80px margin`。
- Trinket attempt 2 raw：同一 production 根的
  `attempt-02/raw/AB.TRINKET.KIT.V1.attempt-02.raw.png`（SHA
  `85f3f6f0…50b7`，`1254×1254 RGB`）。review scene `c56aa652…6f3c`、
  supported layouts `edc8a8f9…4de0`、cell board `eb89ef94…f2dc`；display
  `16/16 pass`。A／B／C／D margin 为 `71／88／42／148 px`，C 中心全透明；
  technical 与 C 语义均 fail。
- Trinket attempt 3 raw：同一 production 根的
  `attempt-03/raw/AB.TRINKET.KIT.V1.attempt-03.raw.png`（SHA
  `0c6f0bc7…8048`，`1254×1254 RGB`）；deterministic canonical
  `attempt-03/canonical/AB.TRINKET.KIT.V1.attempt-03.canonical.png`（SHA
  `6a91a2b5…5e13`，exact `1024×1024 RGBA`）。visible green `0`、透明 RGB
  非零 `0`、最终 margin 全部 `80 px`；但 raw-normalized C 触碰右中线，D 同时
  含 `14397／1814 px` 两个显著组件，故在首个 scope fatal 层停止，不生成
  reviewer／display。
- Trinket attempt 4 raw：同一 production 根的
  `attempt-04/raw/AB.TRINKET.KIT.V1.attempt-04.raw.png`（SHA
  `2e4efc1a…19e3a`，`1254×1254 RGB`）；deterministic canonical
  `attempt-04/canonical/AB.TRINKET.KIT.V1.attempt-04.canonical.png`（SHA
  `82dd2260…c012`，exact `1024×1024 RGBA`）。四格各一显著组件、原始物件均不
  触边，visible green `0`、透明 RGB 非零 `0`、最终 margin 全部 `80 px`。
  review scene `6b59893d…53d5`、supported layouts `5b506d53…6da2`、cell board
  `1cd43ebb…c9f`；display `16/16 pass`、violations `0`。完整 checklist 内部 pass，
  现为 `candidate-reviewed / pending-user-acceptance / 4/5`，不执行 attempt 5。
- Consumable attempt 1 raw：同一 production 根的
  `AB.CONSUMABLE.KIT.V1/attempt-01/raw/AB.CONSUMABLE.KIT.V1.attempt-01.raw.png`
  （SHA `de25567f…b8ba`，`1254×1254 RGB`）；deterministic canonical
  `attempt-01/canonical/AB.CONSUMABLE.KIT.V1.attempt-01.canonical.png`（SHA
  `623f29c5…a2419`，exact `1024×1024 RGBA`）。四格各一显著组件、原始物件均不
  触边，visible green `0`、透明 RGB 非零 `0`、最终 margin 全部 `80 px`。
  review scene `057c45cb…150a`、supported layouts `e78b6dc5…9ae5`、cell board
  `cc56df10…9fd8`；display `16/16 pass`、violations `0`。完整 checklist 内部 pass，
  现为 `candidate-reviewed / pending-user-acceptance / 1/5`，不执行 attempts 2–5。

## 下一门禁

1. `AB.SLOT.BASE.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-SLOT-BASE-V1_TurtleWoW_P6_2026-08-08.png`
   （SHA `dc9615ac…4d5d`）与同目录 P6 evidence JSON（SHA `73a8f942…0d0b`）；
   静态截图与用户交互确认的证明范围保持分离。
2. `AB.FIELDKIT.V1` 已由 `simulation-confirmed / P2` 进入 `prompt-authorized / P3`。用户于 `2026-08-09`
   明确接受 `AB-FIELDKIT-SIM-V2` 的八项文字化方向，不接受两张模拟的任何像素；
   可见方向发生实质变化时必须返回新模拟版本。
3. `AB.TRINKET.KIT.V1` attempt 4 与 `AB.CONSUMABLE.KIT.V1` attempt 1 均已内部
   全门禁通过并按 pass 即停；两套 canonical 只进入用户复审，明确接受前不得晋级。
   提交 Consumable 记录后，请用户分别接受或拒绝。若拒绝，Trinket 只余 `1` 次、
   Consumable 只余 `4` 次，且每次均须先写完整 repair body 并提交；禁止 attempt 6。
4. `AB.RAIL.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-RAIL-V1_TurtleWoW_P6_2026-08-09.png`
   （SHA `5e89c6e5…12942`）与同目录 P6 evidence JSON（SHA
   `2d48b8fb…0be3`）；静态截图与用户对完整六项交互／布局清单的确认范围保持
   分离。runtime TGA、manifest、AEUI `0.8.0` adapter、display 与 package 身份
   均未改变，P5→P6 ImageGen `0`。
5. Rail 若要进入 `P6-C`，必须先在现存 work 中形成组件专属的精确 keep／delete
   inventory，排除共享 `ActionBars.lua`、Character V3 锁定基准及其他未完成
   Action Bars 组件依赖，并向用户展示、取得明确批准；当前不清理 ignored
   `generated`、work、失败候选或回退证据。
6. `AB.SLOT` 若要进入 `P6-C`，必须先在现存 work 中向用户展示精确保留／删除
   inventory 并取得明确批准；当前不得清理该组件的 ignored `generated`、work
   或其他专属中间证据。
7. `AB.SLOT.STATE` 与狮鹫继续各自形成独立合同并逐批授权。Bar `1–10` scoped
   visual adapter 不改变 pfUI 功能所有权；未登记 Bar 与第三方 provider 始终
   fail-open。
