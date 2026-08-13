# Action Bars 当前进度

## 当前运行时

- AEUI 版本：`0.8.31`。
- 合同：Slot `1.0`、Rail `1.0`、Field Kit `2.8`、Combat Focus `2.6`、
  Sidebar Group `1.0`。
- provider 功能、按钮脚本、物品使用、换装、冷却、分页、姿态和 SavedVariables
  继续由 pfUI、AutoBar、TrinketMenu、DoiteDPS 与 ArchiTotem 持有。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| `AB.SLOT` | `P6` | Bar 1–10 使用 accepted 逐槽底板，实机验收通过 |
| `AB.RAIL` | `P6` | Bar 1–12 与合法 merged Bar 1／6 使用自适应外围 Rail，实机验收通过 |
| Consumable／AutoBar | `P5` | 可用真实 Button 固定四列；第 1 行在底部，只向上增加；右缘挂到主栏左侧 `12 UI`，底线低 `20 UI` |
| TrinketMenu | `P5` | 双饰品挂到主栏右侧 `8 UI`；原候选菜单、左右键换槽和 Queue 保留 |
| Combat Focus | `P5` | Player／Target `240×60 / 0.8`，TargetTarget `240×60 / 0.68`；系统字体 `18 UI OUTLINE`；施法／Swing `260×12`；姿态真实 icon `25 UI / scale 1`；DDPS 两排整体左移 `200 UI` 至 `TOPLEFT (650,-615)` |
| Sidebar Group | `P5` | Bar 2／4／5／3 组合为可逆 `2×2`，每块 `3×4`，只用一个 group mover |

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

1. `/reload` 后确认 `/aeui status` 含 `version 0.8.31`、
   `fieldkit-contract=2.8`、`autobar-anchor-basis=button-grid-4col-up` 和
   `autobar-provider-dock=bypassed-button-grid`。
2. 当前 13 个 AutoBar 格应从下到上显示为 `4／4／4／1`；主栏移动、连续两次
   apply、开关 AutoBar 配置页后均不得跳回左上或自由坐标。
3. 验证 popup、物品点击、职业槽、缺失物品后的动态行数，以及明确 unbind
   后 provider 原布局恢复。
4. 验证 TrinketMenu 双槽、候选菜单、Queue、左右键换槽和 provider 缺失回退。
5. DDPS 时间线与资源排应整体左移到 `TOPLEFT (650,-615)`，内部相对位置、
   `0.82` scale、锁定和战斗显隐不变；同时复查三条施法／攻击计时、Aura、
   Boss Debuff，以及战士姿态 `25 UI / scale 1` 的高亮、命中区和快捷键。
6. 解锁模式应只出现中央 Bar 1 mover 与右侧 group mover；`sidebars unbind` 后
   四栏能精确回到旧位置，再 bind／home 可逆。

## 回退与暂缓

- `/aeui focuslayout restore` 后 `/reload` 恢复 Combat Focus 前配置。
- `/aeui autobar restore` 恢复 AutoBar 迁移前槽位；Field Kit 与 Sidebar Group
  也保留各自 bind／unbind／home 命令。
- `AB.SLOT.STATE`、可选双头狮鹫、Pet 细节与其他尚未单独验收的覆盖层保持暂停；
  不从旧失败稿继续生产。
