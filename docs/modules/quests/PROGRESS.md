# Quests 当前进度

## 当前运行时

- Quests contract：`1.30`；Quest Visual Theme：`1.13`。
- 顶部“任务日志”标题与任务计数左侧的追踪勾选按钮隐藏，后者同时移除点击区域；任务计数、追踪数据及列表操作保留，`/reload` 后待实机确认。目录以 `2×12 UI` 细墨线标识真实选中行；计数及奖励金额保持纸面墨色，正文增加行距。pfQuest 语言／ID 的后续文字刷新统一去除内联亮色，中文语言名缩写；底部原按钮移入书体，字号统一，地图操作与详情开合明确标注，放弃保留原确认并使用警示色。火漆降低视觉权重，继续无鼠标装饰。
- 用户已实机确认长任务滚动、奖励显示和按钮操作正常；选中墨线与金额的新样式已生效。底部八个原按钮挂载 QL-ACTIONS V1 短皮革签，`64／58／50×20 UI` 三种尺寸各自由高分辨率 donor 等比导出为 2×；顶部语言／ID 分别复用 `64／58×20 UI`，距书体顶部 `40 UI`，间隔 `4 UI`。语言去掉方括号，文字统一暖骨色；普通／悬停／按下／禁用复用同一 atlas，按下视觉与文字下沉 `1 UI`。原语言下拉与 ID 资料入口保留，缺失素材时回退旧按钮皮肤；顶部接入与新美术待实机确认。
- 已完成且正在挂载的 Quest Log 外壳、目录墨记、奖励槽、闭合载体均从 accepted
  source 直接导出为 `2 texels / UI unit`；火漆四态原先已经是 2×。逻辑尺寸、
  锚点、滚动区、Button 与命中区均未改变。
- Quest Log 只替换明确登记的视觉和布局；任务数据、按钮脚本、Tooltip、动态图标、
  文字、确认弹窗和 pfQuest 数据仍由原 provider 持有。

| 组件 | 阶段 | 当前事实 |
|---|---:|---|
| `QL-A1/A2` 双页卷宗外壳 | `P6 geometry / 2× refresh P5` | 两张 2× half texture 在原 `676×464 UI` 书体内重组；连续书页与中央页沟保持固定结构 |
| `QL-B1` 地区目录墨记／18 行排版 | `P6 geometry / 2× refresh P5` | 四态墨记改为 2× atlas；任务行仍使用 pfUI 默认字体 `12px`、无描边／shadow，行末追踪圈隐藏 |
| `QL-B2` 选择书签 | `P5 asset-retained / runtime-hidden` | accepted source 保留且不挂载；当前选择反馈由真实行上的独立细墨线承担 |
| `QL-B3` 类型／计时／状态章 | `paused` | 未完成，不接入、不占位 |
| 日志排版／原按钮交互 | `P6 behavior` | 用户确认长任务滚动、奖励显示和按钮操作正常，业务逻辑与点击对象保持 |
| `QL-ACTIONS V1` 皮革工具签 | `P5` | 底部八按钮与顶部语言／ID 共用三种尺寸、四态、2× atlas；顶部收紧为 `64／58×20 UI`，动态文字、ID、确认与点击脚本保留，新材质待实机确认 |
| `QL-C / QS-A1 / QS-B1` 火漆与闭合载体 | `P5` | 火漆与闭合载体均以 2× runtime 挂载；火漆固定在详情 ScrollChild 右上并随内容滚动；七功能纹章／代理未完成，事务菜单 inactive，旧按钮保持可用 |
| `QL-D` 奖励槽 | `P5` | 用户选择的 V3 第 4 稿已直接导出为 2× 四态 atlas；真实 Button、图标、名称、数量和双列几何不变 |
| pfQuest Tracker | `P5 temporary / display-region-blocked` | 当前使用大块纸面；用户否决外置书框和额外端帽，尚未按真实 live Frame 区域重新确认 |
| NPC Quest／Gossip | `P1` | 保持 pfUI／原生视觉与全部行为，尚未开始 overhaul |

## accepted source 与 runtime

- Quest Log shell：`assets/source/quests/ql-a1/` →
  `Media/Quests/QuestLogShellLeftV4.tga`、`QuestLogShellRightV4.tga`；旧
  `QuestLogShellV4.tga` 仅作未挂载的 1× 历史回退。
- 目录墨记：`assets/source/quests/ql-b1/` →
  `QuestLogDirectoryMarksV1.tga`。
- 隐藏选择书签：`assets/source/quests/ql-b2/` →
  `QuestLogSelectionBookmarkV1.tga`。
- 火漆与闭合载体：`assets/source/quests/qs-a1/`、`qs-b1/` →
  `QuestToolWaxSealStatesV1.tga`、`QuestLogSealPurityRibbonV1.tga`。
- 奖励槽：`assets/source/quests/ql-d/` →
  `QuestLogRewardSlotStatesV1.tga`。
- 底部及顶部工具皮革签：`assets/source/quests/ql-actions/` → `QuestLogActionTabsV1.tga`；同目录 `QL-ACTIONS_RuntimeManifest_v1.json` 固定 source、采样变换及十二个 UV。
- Tracker 临时纸面：`assets/source/quests/qt-a1/` →
  `QuestTrackerPaperV1.tga`。

所有 runtime 媒体位于 `addon/AzerothExpeditionUI/Media/Quests/`。

## 下一次实机验证

1. 顶部语言／ID 复用已加载素材，`/reload` 后检查贴边、文字净空和悬停／按下反馈，切换任务与语言后仍保持短文字；验证语言下拉和 ID 资料入口。底部素材的首次加载仍需完整重启，检查与封皮的连接、三种宽度的净空及四态；原任务操作、确认与地图工具继续一一对应。`/aeui status` 应包含 `frame=1.30`、`theme=1.13` 与 `footer=leather-tabs-v1-2x`。
2. 长任务滚动和奖励显示已通过；后续按钮美术接入时仅作相邻回归，不重新扩大为整模块审计。
3. 检查详情页右上火漆确实压在闭合载体上，随 ScrollChild 向下滚动而离开
   viewport；不得悬空、遮挡正文、跑到翻页或书封区域。
4. 菜单仍应 inactive，旧分享／放弃／退出／详情及 pfQuest 控件继续可见可用；
   放弃任务必须保留原确认流程。
5. Tracker 只验证当前 provider 功能与内容安全，不把临时纸面视为最终 P6。

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
