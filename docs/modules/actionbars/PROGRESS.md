# Action Bars 当前进度

## 当前运行时

- AEUI 版本：`0.9.0`。
- 合同：Slot `1.0`、Rail `1.0`、Field Kit `2.9`、Combat Focus `3.5`、
  Sidebar Group `1.0`、Target Markers `2.3`。
- provider 功能、按钮脚本、物品使用、换装、冷却、分页、姿态和 SavedVariables
  继续由 pfUI、AutoBar、TrinketMenu、DoiteDPS 与 ArchiTotem 持有。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| `AB.SLOT` | `P6` | Bar 1–10 使用 accepted 逐槽底板，实机验收通过 |
| `AB.RAIL` | `P6` | Bar 1–12 与合法 merged Bar 1／6 使用自适应外围 Rail，实机验收通过 |
| Consumable／AutoBar | `P5` | 可用真实 Button 固定四列；第 1 行在底部，只向上增加；右缘挂到主栏左侧 `12 UI`，底线低 `20 UI`；绑定态 popup 固定为卷袋左侧独立抽屉，不受职业槽／手工 item ID 签名影响 |
| TrinketMenu | `P5` | 双饰品挂到主栏右侧 `8 UI`；原候选菜单、左右键换槽和 Queue 保留 |
| Combat Focus | `P5` | Player／Target 保持 `240×48 / 0.8`、底锚点 `480 UI`，中心分别为 `-160／105`，完整框体之间保留 `73 UI`；`23 UI` Aura 每排 `8` 枚，上 Buff／下 Debuff。Player 仅显示技能书同名 Buff 与全部 Debuff；敌对 Target／TargetTarget／Focus 显示全部真实 Buff，Debuff 为自己施加与固定 `12` 项关键表的并集；友方显示已追踪为自己施加的 Buff 与全部 Debuff。TargetTarget 保持 `240×60 / 0.68`；策略先扫描全部 `32` 槽再压缩进 provider 现有 Button，并共享给姓名板的可选“聚焦光环显示”：Debuff 优先、Buff 填充剩余 `16` 格，关闭后恢复原前 `16` 个 Debuff。Action Bars 关闭或归属 provider 缺失时 fail-open。三框几何合同仍按角色版本应用并保存独立回退，施法／Swing、姿态及 DDPS 坐标不变 |
| DoiteDPS | `P5` | live provider `0.9.0`；战士目录只保留双手深武器单体／群体与防战单体／群体，旧战斗姿态武器战及狂暴战四套循环已删除，旧模式和按键绑定一次性迁移到对应双手武器战。单体以狂暴姿态为常驻姿态，普通阶段保持致死／旋风等就绪瞬发优先，每个白字周期最多一次猛击；“猛击最大卡条”默认 `0.17` 秒并按实际攻速动态计算，移动时不建议猛击；压制只在战术掌握可保留的 `25` 怒气内切姿态，英勇只在按“暴击加权伤害项＋固定基础速度项＋怒不可遏当前等级期望值”预测的下次白字将触及真实怒气上限时排队，双手武器下 5/5 怒不可遏贡献 `1.5` 期望怒气并随天赋变化即时刷新。斩杀阶段先保留高效率猛击：瞬发后仍能在白字前完成猛击与最低斩杀时，致死／旋风分别使用 `60／55` 怒气边界；猛击不可用、已用或无法落地时才回退到致死／斩杀 `45`、旋风／斩杀 `40`，并在周期后段清空余怒。可信 TTD 显示目标（包括 Boss）即将死亡时立即斩杀，期间不再新排英勇。群体以横扫准备、回狂暴姿态、旋风／致死／安全猛击为核心；顺劈默认 `95` 怒，只在计划技能后仍高怒或下次白字将封顶、核心怒气充足且不消耗留给旋风的横扫层数时排队，定时斩杀到点禁止顺劈；撕裂和破甲继续手动负责。怒气读取使用角色真实上限，支持无尽怒气的 `130` 上限；原精确近战候选与手动目标保护保持不变 |
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

1. `/reload` 后确认 `/aeui status` 含 `version 0.9.0`、
   `fieldkit-contract=2.9`、`focus-layout-contract=3.5`、
   `focus-unit-default-version=5`、`focus-unit-default=profile-applied` 或
   `profile-saved`、`focus-layout-unit-size=240x48`、
   `focus-layout-unit-y=480`、`focus-layout-primary-gap=73`、
   `focus-layout-aura-per-row=8`、
   `focus-layout-targettarget-aura-per-row=8`、
   `focus-layout-aura-growth=player-right+target-left`、
   `focus-layout-aura-policy=active`、
   `autobar-anchor-basis=button-grid-4col-up`、
   `autobar-provider-dock=bypassed-button-grid` 和
   `architotem-dock=bottom-left-separated`；另有 `markers contract=2.3`、
   `anchor=architotem-separated-row`、
   `layout=4x2-square`、`style=shared-leather-board`、`strata=BACKGROUND`、`bulk=hdl-one-click`、
   `bulk-layout=conditional-in-frame-right`、`tank=ddps-assist`、
   `tank-layout=fixed-in-frame-left`、`dead=local-clear-only`；盾牌应始终为
   `tank-ui=visible`，DDPS 坦克 API 就绪时为 `tank-provider=ready`，未就绪时由
   `tank-provider` 报告缺失原因；HDL provider 仍反映在 `bulk-ui`。同时确认 Player
   只保留技能书同名 Buff 而 Debuff 不漏；敌对 Target／TargetTarget／Focus 保留全部
   真实 Buff、自己的 Debuff 及固定 `12` 项关键 Debuff；友方三框只保留本次
   登录后追踪到由自己施加的 Buff，Debuff 全部保留。再关闭 Action Bars 验证 pfUI
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
   拖动、AutoBar 左侧卷袋与姿态／宠物 Button 命中区。
5. 当前 13 个 AutoBar 格应从下到上显示为 `4／4／4／1`；主栏移动、连续两次
   apply、开关 AutoBar 配置页后均不得跳回左上或自由坐标。
6. 悬停任一含多个物品的主格，候选必须固定出现在整个卷袋左侧独立抽屉，不能
   再从当前图标上方弹出；同时验证物品点击、职业槽、缺失物品后的动态行数，
   以及明确 unbind 后 provider 原布局恢复。
7. 验证 TrinketMenu 双槽、候选菜单、Queue、左右键换槽和 provider 缺失回退。
8. 所有角色的 DDPS 时间线与资源排应统一到 `TOPLEFT (650,-615)`，内部相对位置、
   各自 scale、锁定和战斗显隐不变；同时复查三条施法／攻击计时、Aura、
   Boss Debuff，以及战士姿态 `25 UI / scale 1` 的高亮、命中区和快捷键。战士设置页
   应只列双手武器战与防战各自的单体／群体入口，旧武器／狂暴按键应迁移到对应双手
   武器战。Boss 普通阶段验证致死／旋风保持就绪优先、每白字最多一次猛击、“猛击最大
   卡条”默认 `0.17` 秒且按实际攻速生效、移动时不建议猛击，以及压制只在 `25`
   怒气内切姿态；斩杀阶段验证安全窗口内 `60` 怒走
   致死／猛击／斩杀、`55` 怒走旋风／猛击／斩杀，`45／40` 怒改走猛击／斩杀；猛击
   已用或无法落地时再验证 `45` 怒致死／斩杀与 `40` 怒旋风／斩杀。Boss 短命时应
   立即斩杀且不新排英勇，无尽怒气角色应按真实 `130` 上限判断溢出；切换怒不可遏等级后
   白字预测应无需重载即时刷新。群体验证横扫准备、回狂暴姿态、旋风／致死／安全猛击，
   顺劈默认 `95` 怒且只在计划技能后仍高怒或下次白字将封顶时排队；横扫末层应留给旋风，
   定时斩杀到点不得被顺劈替代。相邻回归防战循环、精确近战换目标和无可信候选时保留原目标的红色“远”。
9. 解锁模式应只出现中央 Bar 1 mover 与右侧 group mover；`sidebars unbind` 后
   四栏能精确回到旧位置，再 bind／home 可逆。

## 回退与暂缓

- `/aeui focuslayout restore` 后 `/reload` 恢复 Combat Focus 前配置。
- `/aeui markers off` 只隐藏 AEUI 方阵；GRTT／Banana 保持独立且不会被改写。
- `/aeui autobar restore` 恢复 AutoBar 迁移前槽位；Field Kit 与 Sidebar Group
  也保留各自 bind／unbind／home 命令。
- `AB.SLOT.STATE`、可选双头狮鹫、Pet 细节与其他尚未单独验收的覆盖层保持暂停；
  不从旧失败稿继续生产。
