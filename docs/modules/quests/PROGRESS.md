# Quests 当前进度

## 当前运行时

- Quests contract：`1.27`；Quest Visual Theme：`1.10`。
- 用户已在游戏中确认 Quest Log 左页字体／字重、左右页布局、详情完整滚动、
  奖励区域几何及此前截断问题的修复。
- Quest Log 只替换明确登记的视觉和布局；任务数据、按钮脚本、Tooltip、动态图标、
  文字、确认弹窗和 pfQuest 数据仍由原 provider 持有。

| 组件 | 阶段 | 当前事实 |
|---|---:|---|
| `QL-A1/A2` 双页卷宗外壳 | `P6 user-confirmed` | `QuestLogShellV4.tga` 已接入，连续书页与中央页沟保持固定结构 |
| `QL-B1` 地区目录墨记／18 行排版 | `P6 user-confirmed` | 任务行使用 pfUI 默认字体 `12px`、无描边／shadow；行末追踪圈隐藏 |
| `QL-B2` 选择书签 | `P5 asset-retained / runtime-hidden` | accepted source 保留，但当前不显示；恢复前需重新确认 |
| `QL-B3` 类型／计时／状态章 | `paused` | 未完成，不接入、不占位 |
| `QL-C / QS-A1 / QS-B1` 火漆与闭合载体 | `P5` | 火漆固定在详情 ScrollChild 右上并随内容滚动；闭合载体已接入；七功能纹章／代理未完成，事务菜单 inactive，旧按钮保持可用 |
| `QL-D` 奖励槽 | `P5` | 用户选择的 V3 第 4 稿已导出四态 atlas 并接入；真实 Button、图标、名称、数量和双列几何不变 |
| pfQuest Tracker | `P5 temporary / display-region-blocked` | 当前使用大块纸面；用户否决外置书框和额外端帽，尚未按真实 live Frame 区域重新确认 |
| NPC Quest／Gossip | `P1` | 保持 pfUI／原生视觉与全部行为，尚未开始 overhaul |

## accepted source 与 runtime

- Quest Log shell：`assets/source/quests/ql-a1/` →
  `Media/Quests/QuestLogShellV4.tga`。
- 目录墨记：`assets/source/quests/ql-b1/` →
  `QuestLogDirectoryMarksV1.tga`。
- 隐藏选择书签：`assets/source/quests/ql-b2/` →
  `QuestLogSelectionBookmarkV1.tga`。
- 火漆与闭合载体：`assets/source/quests/qs-a1/`、`qs-b1/` →
  `QuestToolWaxSealStatesV1.tga`、`QuestLogSealPurityRibbonV1.tga`。
- 奖励槽：`assets/source/quests/ql-d/` →
  `QuestLogRewardSlotStatesV1.tga`。
- Tracker 临时纸面：`assets/source/quests/qt-a1/` →
  `QuestTrackerPaperV1.tga`。

所有 runtime 媒体位于 `addon/AzerothExpeditionUI/Media/Quests/`。

## 下一次实机验证

1. 检查 QL-D TGA 方向、normal／hover／pressed／disabled、pressed `1px`、
   图标／名称安全区，以及 0／1／2／4／6 奖励和长详情滚动。
2. 检查详情页右上火漆确实压在闭合载体上，随 ScrollChild 向下滚动而离开
   viewport；不得悬空、遮挡正文、跑到翻页或书封区域。
3. 菜单仍应 inactive，旧分享／放弃／退出／详情及 pfQuest 控件继续可见可用；
   放弃任务必须保留原确认流程。
4. Tracker 只验证当前 provider 功能与内容安全，不把临时纸面视为最终 P6。

## 后续设计门禁

- Tracker 是下一项需要重新设计的 Quest 范围。先读取真实
  `pfQuestMapTracker` live Frame 的宽高、内边距、动态条目和滚动／拖动边界，
  再用简单几何生成无外置边框预演；用户确认后才修改资产。
- 七个火漆功能必须作为独立纹章叠在可伸缩背景上，并逐项代理原 Button；只有
  七项功能、状态、Tooltip、显隐和 fail-open parity 都完成后，才能启用事务菜单
  或隐藏旧按钮。
- NPC Quest／Gossip、QL-B3 与 QL-B2 恢复均需新的范围确认。旧失败稿和调用
  流水不再作为下一轮输入。

## 回退

媒体、对象或 pfQuest 缺失时局部回退 provider；禁用 AEUI Quests 后保留原任务
数据与交互。任何未完成菜单代理都必须原子 fail-open，不能留下不可操作的火漆。
