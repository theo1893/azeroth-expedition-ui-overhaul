# Action Bars 当前进度

## 当前运行时

- AEUI 版本：`0.8.32`。
- 合同：Slot `1.0`、Rail `1.0`、Field Kit `2.9`、Combat Focus `2.7`、
  Sidebar Group `1.0`、Target Markers `2.0`。
- provider 功能、按钮脚本、物品使用、换装、冷却、分页、姿态和 SavedVariables
  继续由 pfUI、AutoBar、TrinketMenu、DoiteDPS 与 ArchiTotem 持有。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| `AB.SLOT` | `P6` | Bar 1–10 使用 accepted 逐槽底板，实机验收通过 |
| `AB.RAIL` | `P6` | Bar 1–12 与合法 merged Bar 1／6 使用自适应外围 Rail，实机验收通过 |
| Consumable／AutoBar | `P5` | 可用真实 Button 固定四列；第 1 行在底部，只向上增加；右缘挂到主栏左侧 `12 UI`，底线低 `20 UI`；绑定态 popup 固定为卷袋左侧独立抽屉，不受职业槽／手工 item ID 签名影响 |
| TrinketMenu | `P5` | 双饰品挂到主栏右侧 `8 UI`；原候选菜单、左右键换槽和 Queue 保留 |
| Combat Focus | `P5` | Player／Target `240×60 / 0.8`，TargetTarget `240×60 / 0.68`；系统字体 `18 UI OUTLINE`；施法／Swing `260×12`；姿态真实 icon `25 UI / scale 1`；所有启用 DDPS 的角色统一 `TOPLEFT (650,-615)`，各自 scale／功能配置不变 |
| Sidebar Group | `P5` | Bar 2／4／5／3 组合为可逆 `2×2`，每块 `3×4`，只用一个 group mover |
| Target Markers | `P5` | 骷髅优先的固定 `4×2` 方阵已实机确认共用皮革底板方向；runtime `2.0` 保留空态中央 `30×30 UI` 大标记，占用态改为左下 `15×15 UI` 满亮标记、顶部两行自适应名字、右下血量和底部 `3 UI` 细血条，解决长怪物名覆盖中心水印的问题。目标死亡后仅让 AEUI 对应格立即退回空态并从本地活动计数移除，不调用 `SetRaidTarget`、不要求标记权限，也不改变世界中或其他插件看到的真实团队标记；标记重新指向存活目标时对应格恢复显示。八格继续复用 accepted `ActionConsumableKitV1` 的 C 九宫格，条件式一键 Button 复用同图集 B 薄皮口袋，不新增媒体。模块仍位于 `BACKGROUND`，低于 ArchiTotem 的 `LOW` 展开候选；一键 Button 继续调用可选 HDLRaidTools／SuperWoW provider，仅在完整就绪时显示，手动左右键语义不变 |

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

1. `/reload` 后确认 `/aeui status` 含 `version 0.8.32`、
   `fieldkit-contract=2.9`、`autobar-anchor-basis=button-grid-4col-up` 和
   `autobar-provider-dock=bypassed-button-grid`；另有 `markers contract=2.0`、
   `layout=4x2-square`、`style=shared-leather-board`、`strata=BACKGROUND`、`bulk=hdl-one-click`、
   `bulk-layout=conditional-in-frame-right`、`dead=local-clear-only`；provider 就绪时为 `bulk-ui=visible`，
   未就绪时为 `bulk-ui=provider-hidden`。
2. 在有标记权限的队伍／团队中确认八个透明命中位共用一块连续缝制皮革底板，
   不再形成八张独立规则卡片；空态为中央大图标，占用态为左下满亮小图标，
   `5–8` 字中文怪物名不得再遮住标记身份，右下血量与底部细血条不得和图标重叠，
   且没有额外黑色图标卡片。再验证空格、设标、
   同标记取消、`Shift+右键` 清标与左键选中；击杀一个已标记目标后，对应格应立即回到空态且不再计入 `active`，但目标头顶的真实团队标记不由该自动分支修改；无标记权限时也采用相同本地清空行为。八格顺序必须稳定，名字与血量变化正确，超出范围后
   回到空态不得留下 GRTT 式陈旧名字。
3. 启用 HDLRaidTools 与 SuperWoW 后，选中其表内怪群的未标记目标点击“一键标记”，
   确认同组按预设分配、原目标恢复且手动方阵立即更新；再分别验证已标记目标、
   未登记目标、无权限及缺少 provider 时只给出反馈而不误标。
4. 萨满确认方阵在 ArchiTotem 闭合主行下方，候选向下展开时完整显示在方阵上层、
   重叠区域能点选且不会串到方阵；候选收起后再确认相同位置的手动标记格仍可点击；
   非萨满／无姿态角色确认方阵直接占用预留职业栏位置。相邻回归只需复查主栏
   拖动与姿态／宠物 Button 命中区。
5. 当前 13 个 AutoBar 格应从下到上显示为 `4／4／4／1`；主栏移动、连续两次
   apply、开关 AutoBar 配置页后均不得跳回左上或自由坐标。
6. 悬停任一含多个物品的主格，候选必须固定出现在整个卷袋左侧独立抽屉，不能
   再从当前图标上方弹出；同时验证物品点击、职业槽、缺失物品后的动态行数，
   以及明确 unbind 后 provider 原布局恢复。
7. 验证 TrinketMenu 双槽、候选菜单、Queue、左右键换槽和 provider 缺失回退。
8. 所有角色的 DDPS 时间线与资源排应统一到 `TOPLEFT (650,-615)`，内部相对位置、
   各自 scale、锁定和战斗显隐不变；同时复查三条施法／攻击计时、Aura、
   Boss Debuff，以及战士姿态 `25 UI / scale 1` 的高亮、命中区和快捷键。
9. 解锁模式应只出现中央 Bar 1 mover 与右侧 group mover；`sidebars unbind` 后
   四栏能精确回到旧位置，再 bind／home 可逆。

## 回退与暂缓

- `/aeui focuslayout restore` 后 `/reload` 恢复 Combat Focus 前配置。
- `/aeui markers off` 只隐藏 AEUI 方阵；GRTT／Banana 保持独立且不会被改写。
- `/aeui autobar restore` 恢复 AutoBar 迁移前槽位；Field Kit 与 Sidebar Group
  也保留各自 bind／unbind／home 命令。
- `AB.SLOT.STATE`、可选双头狮鹫、Pet 细节与其他尚未单独验收的覆盖层保持暂停；
  不从旧失败稿继续生产。
