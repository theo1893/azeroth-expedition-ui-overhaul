# Action Bars 当前进度

## 当前运行时

- 饰品候选常驻：使用 TrinketMenu 原生 KeepOpen，关闭按 Shift 才显示；候选置于
  两个已装备饰品下方，两列从左上向下排列。袋内无饰品时由 provider 隐藏，换装、
  左右键 13／14 槽和战斗队列仍归 TrinketMenu。首次应用保存原设置，禁用 Action Bars
  时恢复；待实机核对常驻显示、背包变化、换装后候选补位与菜单高度。
  主栏与候选区统一使用 `0.88` 缩放、两列对齐，候选区在主栏下方留 `2 UI` 间隙，取消原生锁定时的向上叠靠，并启用 TrinketMenu 原生 Locked：隐藏缩放柄、
  禁止其拖动缩放／旋转；组合位置仍由 AEUI 主动作条带动。旧常驻配置自动补迁移，
  中止未结束的缩放操作，禁用 Action Bars 时恢复原缩放及锁定设置。

- Combination 紧凑布局已接入，待实机：左右补给／饰品改为与上动作条顶边对齐，
  两侧间距 `8 UI`；补给按钮 `30 UI`。姿态贴主条左下，间隔 `8 UI`。
  标记区 `2.4` 保持原 `4×2` 内容，以主条的 `80%` 有效缩放贴右下；坦克／一键按钮
  改为顶边对齐，宠物动作条可见时保留其完整行。解绑定恢复自由锚点。
  用户否定此前错位、松散的实机布局；本版先调整几何，沿用现有媒体。
  萨满实机再次反馈对齐偏差：当前改用缩放后按钮的实际右边界定位，名义宽度仅供
  首次布局未就绪时回退。图腾栏位于标记区左侧，间隔 `8 UI`；图腾、坦克／一键
  顶部与标记板外缘对齐，补给／饰品顶部参照动作条外壳，饰品扣除自带外壳偏移。
  `actionbars.architotem-art / P5` 已接入：四系主格与候选、一键、召回、预设按钮
  共用补给槽位 accepted 材质，保留 provider 图标语义色、冷却、点击与顺序；
  Action Bars 禁用或 route 缺失恢复原图标锚点、层序和原生 normal 外框。
  待实机复核整体对齐、展开候选、倒计时文字、可选按钮显隐及禁用回退。
  图腾剩余持续时间现为槽内底部浅金描边小字；技能 CD 为中央稍偏上的白色描边
  大字，取消旧 CD 黑底，避免两个读数重叠。原计时文字与显隐归 provider，方向
  切换后重新应用文字锚点；禁用恢复原位置、字体、颜色、层序与 CD 底图透明度。
  本机第三方 ArchiTotem 的 `Data/Core.lua` 已修正天赋计时：图腾掌握只对友方
  增益图腾增加 `20%` 持续时间；强化火焰图腾每级减少火焰新星激活延迟 `1 秒`，
  满级 `5→3 秒`，技能冷却不变。计算保留原始基础数据，天赋事件刷新等级。
  该修复位于客户端独立插件目录，未纳入仓库分发；重装或跨设备需同步此 provider 文件。
  本机 ArchiTotem `Presets.lua`／`Core.lua` 的召回也已修正：点击不再直接写入
  六秒冷却或清空图腾；冷却来自客户端 API，排除公共 CD，并在召回请求后出现新的
  实际技能冷却时清空记录。失败、重复点击与请求过期保留原有图腾，待实机复核。

- DDPS 外观试接入 `P5`：当前／预测／资源／坦克提示槽使用 Readout V1 细边与深棕底，
  时间线增加窄底轨；保持动态图标、状态色、预测动画和执行逻辑。`/aeui status`
  的 readout-art 行显示 `doite=active`，禁用 Action Bars 恢复 provider 外观。
  当前槽外缘贴合 `38 UI` 图标，状态色由底部细条表达。DoiteAuras 图标接入同一细边，
  保留分组位置、标题、冷却与触发特效，不接管其 Bar 或配置窗口。
  待实机验证推荐切换、触发／不可用色、资源、DoiteAuras 图标与禁用回退。
- 战斗读数 `ReadoutArt 1.0 / P5` 已接入：玩家／目标／Focus 施法条、主／副手与远程攻击条
  使用 accepted 细轨 V1。玩家／目标与攻击条保持 `260×12 UI`，Focus 保留原尺寸和跟随位置，外框每边 `1 UI`；
  从上到下为目标施法条（底锚点 `316`）、玩家施法条（`300`）、Swing（`284`）。
  旧默认施法条坐标自动互换，自定义坐标保留。
  施法／攻击各用独立 2× 灰阶填充，颜色、进度、延迟区、Marker、文字与事件归 pfUI。
  技能图标作为独立框体挂细外缘。`/aeui actionbars` 禁用后恢复 provider 材质、
  backdrop 与 shadow；`/aeui status` 新增 `readout-art` 行。
- 本次需完整重启客户端加载新增 TGA。实机验证施法、引导、打断、显示／隐藏图标、
  长名称与计时、攻击 Marker 和副手／远程切换；相邻检查动作栏与 Aura，验证禁用回退。
  静态和资源检查不代表实机验收，阶段保持 P5。

- TargetTarget／Focus 的 Aura 显示配置随 Target 对齐：位置、
  偏移、数量上限与黑白名单一致，上 Buff／下 Debuff。图标大小按两框与 Target
  的有效缩放比换算，保持屏幕显示大小相同；每排最多跟随 Target 的 8 枚，按
  实际框宽和 pfUI 边框间距自动减列。当前 Focus `120 UI / 1.2` 对比 Target
  `240 UI / 0.8`，图标约 `15.33 UI`、每排 5 枚。
  两框保留原尺寸与位置，共用现有敌友筛选。原 Aura 配置按角色备份，禁用
  Action Bars 时恢复；仅配置变化时刷新 provider，不运行几何维护循环。
  实机检查两框敌友 Aura、上下排列与换目标，相邻回归 Player／Target，并验证禁用回退。

- AEUI 版本：`0.9.0`。
- 合同：Slot `1.0`、Rail `1.0`、Field Kit `3.0`、Supply `2.1`、Combat Focus `3.5`、
  Sidebar Group `1.0`、Target Markers `2.3`。
- AEUI Supply 独立持有背包拖入配置、精确 itemID、当前背包扫描、Button 与每角色配置；
  其他按钮脚本、分类、换装、分页、姿态和 SavedVariables 继续由各原 provider 持有。
- AutoBar 插件、AEUI 桥接、命令、状态与回退路径均已移除；Supply 是左侧唯一补给栏。
  下一次初始化会清除 AEUI 自身遗留的旧桥接键，外部备份文件不读取也不改写。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| `AB.SLOT` | `P6` | Bar 1–10 使用 accepted 逐槽底板，实机验收通过 |
| `AB.RAIL` | `P6` | Bar 1–12 与合法 merged Bar 1／6 使用自适应外围 Rail，实机验收通过 |
| AEUI Supply | `P5` | 原生 `24` 组补给栏已接入：每组可独立占用固定槽位，空位不压紧；管理页选中组后右键目标格可移动或交换，前移／后移也可进入空位。每组最多 `12` 个有序精确 itemID、可命名并可设固定主物品；不再配置或显示低库存阈值，主格、候选格和管理格的数量均在右下角，库存为 `0` 时保留红色数字与图标暗化，正库存统一为白色数量，主格左上不再显示组内告警数量。主格左键只使用固定主物品，悬停 `0.30s`／右键展开自有候选抽屉；候选左键只使用、右键只设主格，任何使用／库存／冷却变化都不自动改主格。配置只接受背包拖入；主格和候选均保留真实数量／冷却，Tooltip 为当前物品原生 Tooltip；旧单物品槽原位迁移，每角色 SavedVariables 保持隔离。无有效组或显式关闭时左侧补给位为空，不再回退外部消耗品栏 |
| TrinketMenu | `P5` | 双饰品挂到主栏右侧 `8 UI`；原候选菜单、左右键换槽和 Queue 保留 |
| Combat Focus | `P5` | Player／Target 保持 `240×48 / 0.8`、底锚点 `480 UI`，中心分别为 `-160／105`，完整框体之间保留 `73 UI`；`23 UI` Aura 每排 `8` 枚，上 Buff／下 Debuff。Player 仅显示技能书同名 Buff 与全部 Debuff；敌对 Target／TargetTarget／Focus 显示全部真实 Buff，Debuff 为自己施加与固定 `12` 项关键表的并集；友方三框显示全部真实 Buff／Debuff。TargetTarget 保持 `240×60 / 0.68`；策略先扫描全部 `32` 槽再压缩进 provider 现有 Button，并共享给姓名板的可选“聚焦光环显示”：Debuff 优先、Buff 填充剩余 `16` 格，关闭后恢复原前 `16` 个 Debuff。Action Bars 关闭或归属 provider 缺失时 fail-open。三框几何合同仍按角色版本应用并保存独立回退，施法／Swing、姿态及 DDPS 坐标不变 |
| DoiteDPS | `P5` | live provider `0.9.0`；战士目录只保留双手深武器单体／群体与防战单体／群体，旧战斗姿态武器战及狂暴战四套循环已删除，旧模式和按键绑定一次性迁移到对应双手武器战。单体以狂暴姿态为常驻姿态，普通阶段保持致死／旋风等就绪瞬发优先，每个白字周期最多一次猛击；“猛击最大卡条”默认 `0.17` 秒并按实际攻速动态计算，移动时仍可建议猛击；压制只在战术掌握可保留的 `25` 怒气内切姿态，英勇只在按“暴击加权伤害项＋固定基础速度项＋怒不可遏当前等级期望值”预测的下次白字将触及真实怒气上限、且当前白字剩余大于 `0.30` 秒时排队，双手武器下 5/5 怒不可遏贡献 `1.5` 期望怒气并随天赋变化即时刷新。斩杀阶段先保留高效率猛击：瞬发后仍能在白字前完成猛击与最低斩杀时，致死／旋风分别使用 `60／55` 怒气边界；猛击不可用、已用或无法落地时才回退到致死／斩杀 `45`、旋风／斩杀 `40`，并在周期后段清空余怒。“斩杀贴刀窗口”不再提供配置且旧值不再读取；普通定时斩杀固定只在白字剩余 `(0.20, 0.55]` 秒时成立。武器战循环不再使用目标实际血量、斩杀伤害估算或紧急斩杀，也不会主动中断正在读条的猛击；高怒不再触发任何额外斩杀分支。独立“战士手动斩杀宏”由 SuperMacroPlus 受管，按下时先停止当前读条，再尝试释放斩杀。插件不再采样血量趋势或计算 TTD。群体以横扫准备、回狂暴姿态、旋风／致死／安全猛击为核心；顺劈默认 `95` 怒，只在计划技能后仍高怒或下次白字将封顶、核心怒气充足、不消耗留给旋风的横扫层数且当前白字剩余大于 `0.30` 秒时排队，定时斩杀到点禁止顺劈；撕裂和破甲继续手动负责。怒气读取使用角色真实上限，支持无尽怒气的 `130` 上限；自动选目标只在没有有效手动敌对目标时生效，手动目标即使确认超出近战范围也不再自动切换；DDPS 自己取得的目标仍可按精确近战候选切换 |
| Sidebar Group | `P5` | Bar 2／4／5／3 组合为可逆 `2×2`，每块 `3×4`，只用一个 group mover |
| Target Markers | `P5` | 骷髅优先的固定 `4×2` 方阵已实机确认共用皮革底板方向；runtime `2.3` 保留空态中央 `30×30 UI` 大标记，占用态改为左下 `15×15 UI` 满亮标记、顶部两行自适应名字、右下血量和底部 `3 UI` 细血条，解决长怪物名覆盖中心水印的问题。目标死亡后仅让 AEUI 对应格立即退回空态并从本地活动计数移除，不调用 `SetRaidTarget`、不要求权限，也不改变世界中或其他插件看到的真实团队标记；标记重新指向存活目标时对应格恢复显示。八格继续复用 accepted `ActionConsumableKitV1` 的 C 九宫格，左右两个 Button 复用同图集 B 薄皮口袋，不新增媒体。左侧盾牌位于 Combination 真实宽度内的固定左槽并始终显示；DDPS 坦克 API 就绪时左键指定当前队伍／团队玩家、右键清除，未就绪时为红色不可用态，装饰或状态刷新异常时降级为基础可点击盾牌而不再隐藏。右侧一键 Button 继续按 HDLRaidTools／SuperWoW provider 条件显示。ArchiTotem 已相对旧居中位整体左移 `128 UI`，方阵反向补偿并保持既有位置，四元素向下候选列不再覆盖皮革 icon list；`BACKGROUND` strata 继续作为异常 scale 回退，手动左右键语义不变 |

## 已接受资产

- Slot source／manifest：`assets/source/actionbars/ab-slot/`；runtime：
  `addon/AzerothExpeditionUI/Media/ActionBars/ActionSlotBaseV1.tga`。
- Rail source／manifest：`assets/source/actionbars/ab-rail/`；runtime：
  `addon/AzerothExpeditionUI/Media/ActionBars/ActionRailV1.tga`。
- Consumable 与 Trinket source／manifest：
  `assets/source/actionbars/ab-consumable-kit/`、
  `assets/source/actionbars/ab-trinket-kit/`；runtime 位于同一 addon Media 目录。
- manifest 只固定不可变 source/runtime 媒体；ActionBars.lua、Bootstrap 和 TOC
  不再使用会随普通修复失效的 SHA 合同。

## 下一次实机验证

1. 完整退出客户端并重启后确认插件列表不再出现 AutoBar，且 `/aeui status` 含 `version 0.9.0`、
   `fieldkit-contract=3.0`、`focus-layout-contract=3.5`、
   `supplies-contract=2.1`、
   `focus-unit-default-version=5`、`focus-unit-default=profile-applied` 或
   `profile-saved`、`focus-layout-unit-size=240x48`、
   `focus-layout-unit-y=470`、`focus-layout-primary-gap=73`、
   `focus-layout-aura-per-row=8`、
   `focus-layout-targettarget-aura-per-row=8`、
   `focus-layout-aura-growth=player-right+target-left`、
   `focus-layout-aura-policy=active` 和
   `architotem-dock=bottom-left-separated`；另有 `markers contract=2.3`、
   `anchor=architotem-separated-row`、
   `layout=4x2-square`、`style=shared-leather-board`、`strata=BACKGROUND`、`bulk=hdl-one-click`、
   `bulk-layout=conditional-in-frame-right`、`tank=ddps-assist`、
   `tank-layout=fixed-in-frame-left`、`dead=local-clear-only`；盾牌应始终为
   `tank-ui=visible`，DDPS 坦克 API 就绪时为 `tank-provider=ready`，未就绪时由
   `tank-provider` 报告缺失原因；HDL provider 仍反映在 `bulk-ui`。同时确认 Player
   只保留技能书同名 Buff 而 Debuff 不漏；敌对 Target／TargetTarget／Focus 保留全部
   真实 Buff、自己的 Debuff 及固定 `12` 项关键 Debuff；友方三框保留全部真实
   Buff／Debuff。再关闭 Action Bars 验证 pfUI
   原 Aura 完整回退；姓名板开启“聚焦光环显示”时同步符合上述敌友策略，关闭后
   恢复原前 `16` 个 Debuff。最后登录另一角色确认 v5 三框布局只应用一次。
2. 在有标记权限的队伍／团队中确认八个透明命中位共用一块连续缝制皮革底板，
   不再形成八张独立规则卡片；盾牌 Button 始终位于整块标记栏左侧且与
   Combination 一起移动；空态为中央大图标，占用态为左下满亮小图标，
   `5–8` 字中文怪物名不得再遮住标记身份，右下血量与底部细血条不得和图标重叠，
   且没有额外黑色图标卡片。再验证空格、设标、
   同标记取消、`Shift+右键` 清标与左键选中；击杀一个已标记目标后，对应格应立即回到空态且不再计入 `active`，但目标头顶的真实团队标记不由该自动分支修改；无标记权限时也采用相同本地清空行为。八格顺序必须稳定，名字与血量变化正确，超出范围后
   回到空态不得留下 GRTT 式陈旧名字。
3. 选中队伍／团队中的坦克后左键盾牌，确认提示已指定且状态色／Tooltip 更新；
   选中普通敌对目标继续手动输出，再在没有手动敌对目标时按 DDPS 输出键，确认只在
   按键时跟随坦克当前敌对目标；右键盾牌后确认清除。旧版／缺失 DDPS 时盾牌保持
   红色不可用态且点击只给反馈。
   另启用 HDLRaidTools 与 SuperWoW，选中其表内怪群的未标记目标点击“一键标记”，
   确认同组按预设分配、原目标恢复且手动方阵立即更新；再分别验证已标记目标、
   未登记目标、无权限及缺少 provider 时只给出反馈而不误标。
4. 萨满确认 ArchiTotem 闭合主行整体左移而皮革 icon list 留在原位；依次悬停
   Earth／Fire／Water／Air，所有向下候选列都不得覆盖八格皮革板，鼠标移向标记格时
   不得误触图腾。再分别确认候选图腾与手动标记格仍可点击；
   非萨满／无姿态角色确认方阵直接占用预留职业栏位置。相邻回归只需复查主栏
   拖动、Supply 左侧卷袋与姿态／宠物 Button 命中区。
5. `/aeui supplies` 中把多个背包物品拖到同一组，命名并设置固定主物品；再创建
   第二组，选中第一组后右键第 `4` 格，确认它可越过空位直接移动；再右键第二组所在格，
   确认两组交换。槽位前移／后移也应允许进入空位，重载后空位、组位置、名称、组内顺序
   和显式主物品均保持；拖入物品都先回到原背包，同组重复 itemID 不会复制；将同一赞扎药剂分别加入治疗组与 DPS 组，重载后两组均应保留，删除一组的该成员不得影响另一组。主格左键只能使用固定主物品；悬停
   `0.30s` 或右键应展开 `1–6` 单列／`7–12` 双列候选，候选左键使用后不得改主格，
   右键只改主格且不得消耗。固定主物品缺货时，主格左键不得自动使用其他候选，
   只展开抽屉。主格与候选 Tooltip 都只能是各自当前物品的原生 Tooltip。
6. 移走／耗尽成员后确认主格与候选数量都在右下角，红色 `0` 常驻，任意正库存均为白色，主格左上没有额外
   告警数字且候选顺序不变；CD 应落在实际使用物品上。删除成员、删除整组后不得残留幽灵格。`/aeui supplies selfcheck`
   应通过，`/aeui status` 应报告 `supplies=available`、正确的
   `configured／items／zero／popup` 与 `supplies-dock=left`。重载另一角色确认隔离。
7. 执行 `/aeui supplies off` 或删除全部组后确认左侧补给位为空，`/aeui status`
   不再含外部消耗品栏状态；重新启用并恢复组后 Supply 回到原位置。
   `fieldkit unbind` 后 Supply 保持当前位置并可 `Shift+拖动`，重新 bind 后回到主栏左侧。
8. 验证 TrinketMenu 双槽、候选菜单、Queue、左右键换槽和 provider 缺失回退。
9. 所有角色的 DDPS 时间线与资源排应统一到 `TOPLEFT (650,-615)`，内部相对位置、
   各自 scale、锁定和战斗显隐不变；萨满风怒额外攻击已实机确认按真实主／副手攻击
   事件立即重置，pfUI 不再满条卡住；再检查 Aura、
   Boss Debuff，以及战士姿态 `25 UI / scale 1` 的高亮、命中区和快捷键。战士设置页
   应只列双手武器战与防战各自的单体／群体入口，旧武器／狂暴按键应迁移到对应双手
   武器战。Boss 普通阶段验证致死／旋风保持就绪优先、每白字最多一次猛击、“猛击最大
   卡条”默认 `0.17` 秒且按实际攻速生效、移动时仍可建议猛击，以及压制只在 `25`
   怒气内切姿态；设置页不应再出现“斩杀贴刀窗口”。斩杀阶段验证普通定时斩杀只在
   白字剩余 `(0.20, 0.55]` 秒成立，并在安全窗口内以 `60` 怒走
   致死／猛击／斩杀、`55` 怒走旋风／猛击／斩杀，`45／40` 怒改走猛击／斩杀；猛击
   已用或无法落地时再验证 `45` 怒致死／斩杀与 `40` 怒旋风／斩杀。把 Boss 压到最后一点
   血时，武器战循环仍不得因目标实际血量提前斩杀，也不得主动取消正在读条的猛击；手动按
   “战士手动斩杀宏”时应立即中断猛击并尝试斩杀。英勇与顺劈在
   白字剩余等于或小于 `0.30` 秒时都不得排队。
   无尽怒气角色应按真实 `130` 上限判断溢出；切换怒不可遏等级后
   白字预测应无需重载即时刷新。群体验证横扫准备、回狂暴姿态、旋风／致死／安全猛击，
   顺劈默认 `95` 怒且只在计划技能后仍高怒或下次白字将封顶时排队；横扫末层应留给旋风，
   定时斩杀到点不得被顺劈替代。相邻回归防战循环；再手动选中超距存活敌人确认不切换，清空目标后确认可自动取得近战候选，且 DDPS 自己取得的目标超距后仍可切到可信候选；无可信候选时保留原目标的红色“远”。
10. 解锁模式应只出现中央 Bar 1 mover 与右侧 group mover；`sidebars unbind` 后
   四栏能精确回到旧位置，再 bind／home 可逆。

## 回退与暂缓

- `/aeui focuslayout restore` 后 `/reload` 恢复 Combat Focus 前配置。
- `/aeui markers off` 只隐藏 AEUI 方阵；GRTT／Banana 保持独立且不会被改写。
- Field Kit 与 Sidebar Group 保留各自 bind／unbind／home 命令。
- `AB.SLOT.STATE`、可选双头狮鹫、Pet 细节与其他尚未单独验收的覆盖层保持暂停；
  不从旧失败稿继续生产。

## 战斗读数 accepted source

`assets/source/actionbars/readouts-v1/` 保存完整透明外壳、两张灰阶填充、固定皮革
样本及 source/runtime manifest。`tools/build_readouts_v1_runtime.py` 验证 accepted
哈希并导出2× runtime：外壳524×28装入1024×32 TGA；两张填充均128×32。
运行时媒体位于 `Media/ActionBars/Readouts/`，`ReadoutArt.lua` 只接管精确 route
`actionbars.readout-art`，不修改施法或攻击计时逻辑。
