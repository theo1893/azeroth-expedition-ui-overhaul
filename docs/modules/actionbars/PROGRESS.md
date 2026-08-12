# Action Bars 详细进度

## 当前结论

- 用户于 `2026-08-13` 提供最新实机截图（SHA `30816f21…c8d`），确认上一版虽然
  已把真实 AutoBar Button 挂到主动作条左侧，却在排版循环中把每个后续 Button
  都直接接到前一个 Button 的右侧，导致当前 `13` 格被错误展开为 `13×1`。AEUI
  `0.8.30`／`fieldkit-contract=2.8` 已把这一处错误循环替换为固定四列网格：第 1 行
  位于底部，外壳右缘以 `BOTTOMRIGHT → pfActionBarMain BOTTOMLEFT (-12,-20)`
  挂靠主栏；每满四格才新增一行并只向上增长，因而 `13` 格为自下而上
  `4／4／4／1`。AutoBar `SetupVisual／ButtonsUpdate` 后只在事件边界重施真实 Button
  Point，不再让 handle、provider docking 或自由坐标决定绑定态排版；`unbind`／关闭时
  恢复 provider 原 Button Point。单位框、姿态栏、饰品栏、popup 与物品行为均未改，
  位图字节不变，ImageGen `0/0`；当前为 `P5 / pending-game-validation`。
- 用户于 `2026-08-13` 提供 AEUI `0.8.28` 后实机截图（SHA `85ca1366…81a5`），确认
  AutoBar 视觉位置仍在左上。与前图逐帧比较后确认它已随 Bar 1 同步平移，失败不是根绑定，
  而是绑定偏移仍从尚未收敛的 24 个 Frame 状态／旧缓存取得，只有 3 个实际分配格时仍保留
  数百像素错误距离。AEUI `0.8.29` 改为直接复刻 AutoBar 1.31 的
  `AssignButtons + rows／columns／alignButtons + button size／gapping` 布局公式，以 provider
  实际分配数计算可见 union；正常路径不再读取 Button 世界坐标、`IsShown` 或旧锚缓存。
  专项 smoke 注入“实际 3 格、24 个 Frame 全部报告陈旧 shown”的真实失败条件，并断言
  handle 固定为 Bar 1 `BOTTOMLEFT (-220,36.6667)`（handle scale `0.6`，即未缩放
  `(-132,22)`）；provider 随后写自由 `(555,213)` 仍不能覆盖。当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-13` 再次实机确认 AEUI `0.8.27` 后 AutoBar 仍停在左上自由坐标；截图
  SHA `169d9da3…c1b3c` 同时证明姿态栏、饰品栏与隐藏拖拽点已生效，失败范围只剩
  AutoBar 根锚。与没有最终坐标回写的 TrinketMenu 不同，AutoBar provider 会在刷新末尾
  直接调用真实 handle 的 `ClearAllPoints／SetPoint`。AEUI `0.8.28` 因此在强绑定态锁定
  `AutoBarAnchorFrameHandle.SetPoint`：provider 的任何后续坐标都被转写为相对
  `pfActionBarMain` 的已计算锚点；`unbind` 或关闭 AEUI 时恢复原方法，不使用维护循环。
  Field Kit 专项 smoke 新增“绕过全部 AEUI 后置回调、直接执行 provider 原始
  `SetupVisual`”场景并通过；当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-12` 最新实机复测确认姿态栏与拖拽点已收敛，但 AutoBar 仍留在左上自由坐标。
  AEUI `0.8.27` 移除 Combat Deck 根绑定对 Button 世界坐标就绪的前置条件；provider
  `SetupVisual` 返回后始终进入绑定，并优先按 Button 相对真实
  `AutoBarAnchorFrameHandle` 的本地布局计算偏移，再把 handle 直接相对
  `pfActionBarMain` 定位。世界坐标只保留为未知 provider 布局的兜底，不再阻止正常
  AutoBar 进入组合。Lua 语法与 `git diff --check` 通过；当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-12` 提供新的 `1408×633 RGB` 战士实机截图（SHA
  `d1a94514…49bb`），确认上一轮修复后 AutoBar 仍飞到左上角，三枚姿态按钮也仍为
  小尺寸。只读 SavedVariables 证据为该角色 Combat Focus profile v14、
  `bars.bar11.icon_size="18"`、`pfActionBarStances.scale=0.7`；AutoBar 共享 display
  仍保存自由坐标约 `(409,514)`。AutoBar 1.31 的 `SetupVisual` 在末尾无条件
  `ClearAllPoints`，随后按 `display.docking` 或 `display.position` 重写真实 handle，证明
  AEUI 与 provider 竞争“最后一次 SetPoint”是反复跳位的根因。AEUI `0.8.25`／
  `fieldkit-contract=2.7` 改用 provider 原生 docking：注册 `pfActionBarMain` 为合法停靠
  Frame，在强绑定态把当前活动 display 的 `docking` 指向主栏，由每一次 provider
  `SetupVisual` 自己写出相同的主栏相对锚点；自由 `position` 保留但绑定态不参与渲染，
  `unbind`／关闭时精确恢复原 docking／shift，logout／reload 前移除仅运行时可用的
  AEUI docking token，避免 AutoBar 早于 pfUI 加载时引用未知 key。`focus-layout-contract=2.5`／
  profile v16 不再只改外层 scale，而是把真实 `bar11.icon_size` 从 `18` 改为 `25 UI`、
  scale 固定为 `1.0`，在一次性 apply 与 pfUI `UpdateConfig` 边界调用 provider 重建并重施；
  v14／v15 copied profile 只升级姿态合同，保留 Player 等其他手调坐标。Lua smoke 覆盖
  原生 docking 连续 `SetupVisual`／配置 OnShow／unbind／rebind／logout-reapply，以及姿态
  `18/0.7 → 25/1`、模拟三按钮 `97×33 UI` 和非姿态坐标不变。位图字节不变，
  ImageGen `0/0`。ActionBars SHA `e3887b7f…5c28b`、Bootstrap SHA
  `3019de4e…0de9`、TOC SHA `770d4c0a…f3a6` 已同步四份 runtime manifest；
  Field Kit display `19/19 pass`（report SHA `5261ccd4…edb1`）、Focus display
  `13/13 pass`（report SHA `0c01af25…26e8`），fresh-checkout package `pass`、
  violations `0`、report SHA `e1ca9054…0a35`、records `64`、tracked addon files
  `554`、目标设备无需构建。当前仍为 `runtime-exported / addon-integrated / P5 /
  pending-game-validation`。
- 用户于 `2026-08-12` 提供战士组合栏实机截图
  `1057×267 RGB`、SHA `bf05df85…76fe`，要求默认隐藏 AutoBar 红色拖拽点并放大
  三枚姿态按钮。AutoBar 1.31 XML 审计确认红点为真实
  `AutoBarAnchorFrameHandle`；provider 的早期 `HideHandle(AutoBarFrame)` 会查找不存在的
  `AutoBarFrameHandle`，而 `SetupVisual`／配置页初始化仍可能再次显示真实 handle。
  `fieldkit-contract=2.6` 因此在强绑定态的 Apply、`SetupVisual` 与完整
  `AutoBarConfig.OnShow` 返回前同步隐藏真实 handle，并在显式 `unbind` 或 AEUI 关闭时
  恢复 provider 的 `hideDragHandle` 偏好，不增加维护循环。`focus-layout-contract=2.4`／
  profile v15 保持姿态栏 `BOTTOM (0,255)` 与 provider 图标尺寸不变，只把 local scale
  从 `0.72` 提到 `1.0`，线性增大 `38.9%`；仅完整匹配旧几何／系统字体／姿态
  `0.72` 的 exact v14 profile 自动迁移，手调 scale 或坐标继续受保护。两项都只改
  runtime 布局／可见性，Action Bars source／TGA 字节不变，ImageGen `0/0`；当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-12` 提供两张执行 `/aeui autobar apply` 后的实机截图，确认卷袋会在
  两个位置间往返：`1264×511 RGB`、SHA `ddf6fbbc…2b61` 与 `1109×528 RGB`、
  SHA `cf5bb6dd…eb13`。审计 AutoBar 1.31 证明 `ProfileChanged` 会经配置 `OnShow`
  与 `ConfigChanged` 连续重跑 `SetupVisual`；provider 已把缩放为 `0.6` 的 handle
  写回自由坐标时，Button 的 `GetLeft／GetRight／GetBottom` 仍可能保留上一帧值。
  bridge-v2.4 随后把这组混合坐标计算出的错误锚点反向写入缓存，因此重复 apply 会
  在两套位置间振荡。`fieldkit-contract=2.5` 保留同事件回锚与零延迟刷新，但停靠包络
  改由每个可见 provider Button 相对 handle 的 `GetPoint`、真实宽高与 scale 直接
  计算，完全不依赖当前屏幕坐标；未知布局已有成功锚点时只恢复缓存，不再用不稳定
  world-space 结果覆盖。Lua smoke 以 handle `0.6`／Button `1.0` 的真实 scale 关系，
  注入两套相反的陈旧屏幕坐标并连续执行两次 apply，断言同步回锚与两次零延迟刷新
  后 x／y 均完全相同，`autobar-anchor-basis=provider-local`。四套 Action Bars runtime
  manifest 仅同步 adapter SHA `b861d7d9…6ffc`；source／TGA、profile 内容、popup、
  TrinketMenu 与 ArchiTotem 行为不变，ImageGen `0/0`。fresh-checkout package
  `status=pass`、violations `0`、report SHA `e1ca9054…0a35`，当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- `2026-08-12` 已把远端完成的 Unit Frames B1／Raid A2 P5 与本地插件入口合并。
  ActionBars Lua、位图、布局合同与 AEUI `0.8.24` 均未改变；仅共享 Bootstrap／
  TOC 增加 UnitFrames 模块与状态入口，三份仍在部署链中的 ActionBars runtime
  manifest 已更新对应 entrypoint SHA。合并后的 fresh-checkout package
  `status=pass`、violations `0`、runtime manifest records `64`、tracked addon
  files `554`，报告 SHA `e1ca9054…0a35`，目标设备无需构建。
- pfUI 十二条逻辑 Bar、按钮状态、分页、姿态／宠物、合法行列、移动／缩放与
  当前目标设备 profile 已完成 `P1` 审计。
- 用户于 `2026-08-12` 要求把高度客制化后的 AutoBar 配置页收敛为职业槽编辑器。
  AEUI `0.8.24`／Field Kit bridge-v2.5 延续 v2.4，只保留原生“栏位／按钮”Tab，隐藏
  “动作条／弹出／设定”、综合只读预览、角色／共用／职业／基本层选择器、布局
  选择器与“重置为默认／还原”，保留“完成”；旧 SavedVariables 若选中隐藏 Tab，
  打开时回到“栏位”。“栏位”页直接显示唯一的职业层可编辑网格。首次加载会把
  当前实际生效的 24 槽完整复制到 AutoBar 原生 `_CLASS` profile，并把当前角色固定为
  `useClass=true / edit=3`；当前角色原槽、原 profile 与原职业层均保留可逆备份，同职业
  后续角色复用职业槽。`/aeui autobar restore` 恢复备份并让该角色退出自动迁移。
  AutoBar 1.31 没有职业级 display layout，因此保留的“按钮”Tab 仍按当前角色保存
  显示参数，类别／数字 item ID 槽位才按职业共享。v2.3 的配置打开同步回锚、零延迟
  稳定几何重算、空说明 fallback、动态 `4×6` 与 popup guard 全部延续；bridge-v2.5
  另以 provider-local Button 锚点消除 apply 期间的 world-space 二态振荡。不自动启用
  AutoBar，不改物品解析、点击、冷却或 popup 行为。Lua smoke 覆盖迁移、隐藏控件、
  隐藏 Tab 重定向、provider `OnShow` 重新显示后的再次裁剪、职业 apply 与双层 restore；
  两套 source／TGA 像素不变，ImageGen `0/0`，当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-12` 继续实机确认 bridge-v2.2 在“仅打开 AutoBar 配置页”时仍会
  把卷袋留在 provider 保存的自由坐标；证据为 `1020×926 RGB` 截图、SHA
  `f36cd308…ab5e`，对应当前 SavedVariables 的 `position=(555,213)`。根因是配置页
  `OnShow` 会完整重跑布局，而 v2.2 在同一事件内依赖尚未稳定的 Button 几何重算，
  同时没有覆盖整个配置初始化结束后的最终边界。AEUI `0.8.23`／Field Kit
  bridge-v2.3 保留七个 zhCN 缺失说明和未来未知空说明 fallback，并缓存最后一次成功
  计算的 Bar 1 相对锚点；`AutoBar_SetupVisual` 与整个 `AutoBarConfig.OnShow` 的后置
  钩子都先同步恢复该锚点，再把几何相关外壳／停靠重算排到下一次零延迟 AceEvent。
  Lua smoke 直接模拟配置初始化在嵌套 `SetupVisual` 后再次写入 `(555,213)`，并断言
  `OnShow` 返回前已经恢复 Bar 1 锚点，下一帧重算后仍稳定；独立 `ButtonsUpdate`、
  调度 API 缺失回退、重复 Apply 不重复 hook 均继续覆盖。无 AEUI `OnUpdate` 维护循环，
  profile、SavedVariables 与全部位图字节不变，ImageGen `0/0`；当前仍为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-11` 确认执行 V11 右侧四栏组合，并以最新截图继续指出 Player
  实际文字仍是旧字形／旧字号。AEUI `0.8.20` 现接入
  `sidebar-group-contract=1.0` 与 focus runtime-v2.3：Bar 2／4／5／3 按
  `Paging／Vertical／Left／Right` 组成 `2×2` 四个 `3×4` 分区（总体 `6×8`），
  初始 scale `1.2`、组间距 `6 UI`，只显示覆盖 union 的 Bar 2 mover。仅
  “大奶黑牛 - Basin of Stars”完整匹配原 `1×12` 四列坐标时自动迁移；绑定前
  formfactor／icon／spacing／scale／position 按角色备份，`unbind` 精确恢复，
  绑定期间各栏动作内容／按键／分页／显隐／autohide 仍独立。四个 movable 登记
  始终保留，不再触发 `drag=nil`，几何只在 Apply／UpdateConfig／unlock／拖动／缩放
  事件边界同步，无 `OnUpdate` 维护循环。Player／Target／TargetTarget 的配置仍为
  客户端 `STANDARD_TEXT_FONT / OUTLINE / 18 UI`，并新增对 live health／power
  FontString（Player 另含 top-center）的直接设置与 `UpdateConfig` 后置重施；exact
  v7–v13 profile 一次迁移为 v14，手动改过字体或坐标的签名不动。V11 的 DoiteDPS
  union `TOPLEFT (850,-615)`、Aura／计时栈／Field Kit／AutoBar 几何均不变。
  最新字体失败截图为 `657×291 RGB`、SHA `9858b619…c4c7e0`；位图字节不变，
  ImageGen `0/0`。当前为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-11` 以“大奶黑牛”的最新实机截图补充三项问题：Player 仍与
  消耗品框相交、当前 Aura 一排只能容纳七枚多、Boss 的第二排 Debuff 可能压到
  施法条。AEUI `0.8.18`／`ACTION-BARS-CORE-SIM-V10`／focus runtime-v2.1／
  Field Kit bridge-v2.0 已作最小重排：Player／Target 保持 `240×60 / 0.8` 与原 x，
  仅上移至 `BOTTOM (-160,485)／(105,485)`；TargetTarget 保持 `240×60 / 0.68`，
  fallback 同步为 `BOTTOM (393,576)`，live Frame 仍以
  `LEFT → Target RIGHT +8 UI` 中线依附。Aura 改为 `23 UI`；在当前
  `default_border=3`、`force_blizz=0` 下，pfUI 真实步进为 `size+7`，故每排八枚
  占 `233／240 UI`、余量 `7 UI`。V10 以 Target `16` 个 Debuff 验证两排展开，
  第二排到未移动的 Player Cast 仍有 `3 px` 预览净空。消耗品与饰品组保留原 x，
  底边共同下移 `20 UI`；玩家／目标 Cast、Swing、Combat Deck、姿态与 DoiteDPS
  坐标不变。AutoBar 继续保留 `24` 个逻辑类别、只显示当前可用类别并在最大
  `4×6` 内动态收缩。未被手动调整的 exact v7–v11 profile 在 `/reload` 一次迁移
  为 v12；V10 layout `60/60`、simulation／runtime display 均 `12/12 pass`，
  全部位图字节与 provider 行为不变，ImageGen `0/0`。
  当前仍为 `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-10` 继续提供实机截图并提出七项布局修订。AEUI `0.8.15`／
  `ACTION-BARS-CORE-SIM-V7`／focus runtime-v1.8／Field Kit bridge-v1.8 已接入：
  Player／Target／TargetTarget 均为 `240×60 / 0.68`；Player 改为游戏坐标
  `BOTTOM (-150,535)` 以退出卷袋占位，Target 保持 `BOTTOM (190,535)`，
  TargetTarget 以同宽同高依附 Target 上方 `56 UI`。三框 Aura 均放大为 `22 UI`，
  玩家从完整框架左缘起排，目标两框从右缘起排，上 Buff／下 Debuff。玩家／目标
  施法组成 `180×16 / 0.72` 上排，Swing 主手／ranged 组成同尺寸下排，副手再贴其下；
  DoiteDPS 的时间线与资源两排整体移至独立左上安全区 `TOPLEFT (850,-647)`。
  未被手动调整的 exact v7／v8 profile 在 `/reload` 一次性迁移为 v9；Bar 6／
  TargetTarget movable 登记及先建 drag 后隐藏的生命周期不变。全部位图字节不变，
  ImageGen `0/0`；当前 `runtime-exported / addon-integrated / P5 / pending-game-validation`。
- 用户于 `2026-08-08` 否决 `ACTION-BARS-CORE-SIM-V1` 的贴底动作条和分散、
  不同基线单位框；V2 完成上移与收拢后，用户继续要求纳入施法条、攻击条及
  DoiteDPS。用户已于 `2026-08-08` 以“依照这个设计继续进行”确认
  `ACTION-BARS-CORE-SIM-V3`，并于 `2026-08-09` 明确接受后又以实机截图否决
  `ACTION-BARS-CORE-SIM-V4` 的组合几何；同日用户回复“确认接入”接受
  `ACTION-BARS-CORE-SIM-V5` 方向；九项修订由 V6 接续、七项实机修订由 V7 接续，
  五项修订由 V8 接续，最新实机比例与 AutoBar 默认由 V9 接续，三项重叠修复由
  V10 接续，现已进入
  `runtime-exported / P5`。
- 推荐方向仍是“自适应远征战斗甲板＋炼金卷袋＋饰品双护套”。当前 V10 在中下
  战斗焦点使用左侧 Player、右侧 Target／TargetTarget 横向组与下方垂直计时栈；
  DoiteDPS 双排移至左上独立监控带，再衔接姿态／技能栏。完整焦点布局仍是一次性
  preset；Field Kit v2.3 把
  Bar 6、左卷袋、右双槽与检测到的 ArchiTotem 直接相对锚到 Bar 1，使整组共享
  一个移动根，但不使用维护循环重写位置或 scale。
- 目标客户端继续以 `1920×1080` 输出，当前显示截图为 `2560×1440`，存在
  `4/3` 显示放大；旧 pfUI `Small / tier 7` UI Scale 为
  `0.81269841269841`。当前使用习惯是两条 `12×1` 与若干 `4×3` 辅助栏。V3 沿用主栏外框
  `[713,827,1207,870]`，底边净空 `210 px`；玩家／目标框内缘间距 `80 px`。
- 用户于 `2026-08-09` 明确要求本期先完成玩家／目标、施法、攻击计时、
  DoiteDPS 等战斗框架的位置摆放，后期再分别重绘。AEUI `0.8.6` 新增
  `focus-layout-contract=1.0` 与显式一次性命令 `/aeui focuslayout apply`：在目标
  设备上把 Player／Target 保存为 `BOTTOM x=-196／196, y=468, scale=1.05`、
  `280×72 UI`，双方 Aura 分别从外肩 `TOPLEFT／TOPRIGHT` 以每行 `6` 个展开；
  双施法条保存为同 `x`、`y=433`、`280×22 UI`，Swing 主手／ranged 共用
  `CENTER x=0, y=-43` 的 `200×12 UI` 层，副手继续跟随主手；姿态栏保存为
  `TOP x=0, y=-915`。DoiteDPS 只更新 `TOPLEFT x=1022.5195,
  y=-632.4609`，保留启用、锁定、战斗显隐、Forecast、资源、冷却和 scale；
  Focus Castbar 继续跟随 Focus Frame。当前“大奶黑牛”SavedVariables 已写入
  这些等价 pfUI movable 坐标；`saved` 状态按当前角色 pfUI 坐标签名判定，不用
  账号级版本标记冒充其他角色已应用。代码只在显式命令时重放，不使用维护循环，
  也不重绘任何像素，本次 ImageGen `0`。
- 用户随后提供 `2560×1440 RGB` 实机截图 `de0fb8f7…1f3a3` 并指出还需考虑
  pfUI 已有 UI 缩放，要求调到肉眼舒适。截图与 `Config.wtf` 联合证明客户端仍以
  `1920×1080` 输出并被显示为 `2560×1440`：旧 tier 7 的屏幕有效尺寸约
  `0.812698×4/3=1.0836`，玩家框明显偏重并压到左卷袋，而聊天、小地图与动作区
  也损失视野。AEUI `0.8.7`／`focus-layout-contract=1.1` 新增显式
  `/aeui focuslayout comfort`：只把当前 pfUI profile 改为
  `Tiny PixelPerfect / tier 8 = 0.71111111111111`，屏幕有效尺寸约 `0.9481`；不改
  `1920×1080` 分辨率。Player／Target 与双施法条自身 scale 从 `1.05` 收敛为
  `1.00`，并按新 UIParent 保存为单位框 `BOTTOM x=-196／196, y=534`、施法条
  同 `x, y=495`、Swing `CENTER y=-49`、姿态 `TOP y=-1046`、主／副动作栏
  `BOTTOM y=295／328`。单位框在客户端约 `199 px` 宽，中心偏移约 `139.4 px`，
  因而继续保持约 `80 px` 内缘间距；DoiteDPS 更新为
  `TOPLEFT x=1168.59375, y=-722.8125`，TrinketMenu 当前角色 MainScale 归一为
  `1.0`。所有位置均由当前 UIParent 比例重算，其他角色不自动写入；无美术重绘，
  ImageGen `0`，当前为 `P5 / layout-v1.1 / pending-game-validation`。
- 用户启动 v1.1 后提供第二张 `2560×1440 RGB` 实机截图
  `3a726e58…678f0`，该次实机结论为 fail：tier 8 已正确缩小聊天、小地图与动作区，
  但玩家框蓝色主体实测 `[832,615,1206,729)`、即 `374×114 px`，仍覆盖左卷袋
  上部。根因不是 tier 8 失效，而是 `280 UI` 在 `1920×1080` client buffer 中为
  pixel-perfect，最后仍被显示链 `4/3` 拉伸；v1.1 又用 scale-dependent UIParent
  虚拟宽高重算锚点，错误地把 `0.711111` 当作最终屏幕尺寸乘数。AEUI `0.8.8`／
  `focus-layout-contract=1.2` 保留 tier 8，不再用 UIParent 虚拟尺寸推导这组坐标，
  只给 Player／Target、双方施法、Swing、姿态与 DoiteDPS 使用 `0.75` local display
  compensation。当前校准坐标为单位框 `BOTTOM x=-180／180, y=670`、施法条同
  `x, y=624`、Swing `CENTER y=-85`、姿态 `TOP y=-835`、DoiteDPS
  `TOPLEFT x=1121, y=-560`；DoiteDPS scale 同步为 `0.75`，但启用、锁定、战斗显隐
  与推荐行为不变。最终显示投影中两枚 `280 UI` 单位框各约 `280 px`，玩家框
  左缘约 `x=960`、目标框右缘约 `x=1600`、内缘间距 `80 px`；左卷袋右缘约
  `x=957`，不再相交。Combat Deck／Field Kit 的当前位置与美术不变，ImageGen
  `0`；当前为 `P5 / layout-v1.2 / pending-game-validation`。
- 用户随后提供 `1443×1067 RGB` 实机截图 `3c4eeee2…6dc9`：v1.2 已达到单位框
  与左卷袋不再相交的目标，但用户明确判定战斗核心“有点太小”，并要求把萨满
  图腾管理插件融入布局。因此 v1.2 保留为可回退 P5 runtime，状态改为
  `revision-requested`，不进入 P6。实机目录与 TOC 证明口述“atomchi”实际是
  ArchiTotem `1.7`；已审计其 `ArchiTotemFrame`、四元素当前 Button、Earth／Fire／
  Water 各最多 `5` 与 Air 最多 `7` 候选、独立 `20×20 UI` 拖动球、AllTotems、
  Recall、PresetManager 与独立 `350×450 UI` 对话框。当前角色实值为
  `scale=0.8`、`direction=up`、Recall 显示、PresetManager 主按钮隐藏、未锁定；
  真实闭合 union 为 `212×32 UI`，Air 最大展开为 `212×224 UI`。
- `ACTION-BARS-CORE-SIM-V4` 已完成确定性 P2 内审并获用户接受：保留 tier 8、Combat Deck、
  左 `4×6` 卷袋、右水平双饰品与 Bar 1 几何，只把 Player／Target、双方施法、
  Swing、姿态和 DoiteDPS 的 local display compensation 从 `0.75` 改为
  `0.82`（线性 `+9.33%`、面积约 `+19.54%`），同时把单位框中心内收，维持外侧
  总包络不增。ArchiTotem 作为职业卫星居中置于动作条／XP Rail 下方，显式 preset
  请求向下展开，绑定态随 Bar 1；
  provider 的施放、右键、hover、冷却、倒计时、锁定、方向与预设全部不接管。
  layout `54/54`、simulation display `7/7`、最终 runtime display `7/7`、
  violations `0`，ImageGen `0/0`。AEUI `0.8.9`／`focus-layout-contract=1.3` 已接入
  反向校准坐标；`fieldkit-contract=1.6` 只在事件／命令边界强绑定真实 provider 根。
  普通 refresh 不写方向，缺失、非萨满、隐藏或签名不匹配均 fail-open。当前为
  `runtime-exported / P5`，但后述新实机证据已把其可见几何改判为
  `revision-requested`。
- 用户于 `2026-08-09` 提供 `1304×1121 RGB` 新实机截图
  `350607ed…990d`，明确报告 V4 三项失败：施法栏与攻击栏重叠；战斗框架与动作
  甲板之间有大面积未利用区域；Player／Target 过大并遮住人物主体。根因收敛为
  V4 将全部战斗读数统一放大到 `0.82`、把单位框内缘从 `80 px` 压到 `34 px`，
  同时沿用固定反向校准坐标。`ACTION-BARS-CORE-SIM-V5` 已完成非 runtime 的确定性
  修订：单位框／对应施法使用 `0.75`，Swing／姿态／DoiteDPS 保持 `0.82`；恢复
  `80 px` 人物通道，攻击到施法层净空 `104 px`，战斗信息相邻层最大空隙
  `19 px`，整栈贴近主动作条。layout `59/59`、simulation display `8/8`、
  violations `0`，ImageGen `0/0`。AEUI `0.8.10`／`focus-layout-contract=1.4`
  随后接入该方向，但用户的新实机截图
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-01b315bd-3703-4af2-858b-1b8e07caaea4.png`
  （`1402×1206 RGB`，SHA `ed81a6c9…93dd9`）证明坐标传输失败：Combat Deck 被
  重置到 `y=149`，Player／Target、双方施法、Swing、姿态与 DoiteDPS 分散到错误
  屏区。目标角色 SavedVariables 同时记录 Player `x=54,y=362`、Target
  `x=502,y=362`、Swing `x=277,y=143`，确认不是用户拖动，而是 runtime 把
  1.12 固定 768-high `UIParent` 尺寸、normalized UI root 和 provider effective
  scale 混为同一空间；v1.4 改判 `game-geometry-failed`。
- AEUI `0.8.11`／`focus-layout-contract=1.5` 也已由第三张实机截图
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-823cdfd0-476c-4080-abbe-bcf0615900a3.png`
  （`2251×1440 RGB`，SHA `b49b4415…be1`）判定 `game-geometry-failed`。落盘
  SavedVariables 显示主栏 `x=325,y=246`、Player `x=222,y=637`、Target
  `x=820,y=637`、Swing `x=476,y=126`、DoiteDPS `x=1487,y=-424`；根因是
  `GetScreenWidth／Height` 返回物理 `1920×1080`，而 pfUI／SetPoint 使用 1.12
  游戏坐标，v1.5 又通过 effective scale、探针与回读二次换算。
- AEUI `0.8.12`／`focus-layout-contract=1.6` 删除 projection／probe／readback，
  直接写 tier 8 下的游戏坐标：主栏 `(0,175)`、Player／Target
  `(-212,492)／(213,492)`、双方施法 `(-212,454)／(213,454)`、Swing
  `(0,-67)`、姿态 `(0,-919)`、DoiteDPS `(1012,-647)`。首次显式应用前保存
  profile，并提供 `/aeui focuslayout restore`。普通 refresh 仍不维护坐标；当前为
  `runtime-exported / addon-integrated / P5 / pending-game-validation`；无新位图，
  ImageGen `0/0`。
- 最新截图
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-aa446330-8b76-420c-b602-b7ea05f8e6d4.png`
  （SHA `de56051e…b5d4`）显示 v1.6 虽回到游戏坐标，但单位框仍与卷袋冲突、布局
  松散且缺少 TargetTarget。AEUI `0.8.14`／`focus-layout-contract=1.7` 将主栏保持
  `(0,175)`，Player／Target 改为 `(-190,500)／(190,500)` 与
  `240×60 / 0.68`；TargetTarget 以 `132×30 / 0.62` 依附 Target 右侧 `8 UI`；
  玩家施法／Swing／目标施法统一 `180×16 / 0.72`，游戏坐标为
  `(-196,430)／(0,430)／(196,430)`；姿态 `(0,255)`、DoiteDPS
  `(1012,-780)`。Aura 方向、旧备份补齐、v7→v8 迁移和 unlock 相对锚均已进入
  Lua smoke；普通维护循环仍不存在。
- 后续实机截图
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-640fd020-caf5-4381-8446-3532cdc72d8b.png`
  （SHA `d7fe7e34…c250`）证明 v1.7 仍有七项问题：Player 继续压入卷袋、玩家 Aura
  起点被卷袋遮挡、Cast 与 Swing 应纵向分层、DoiteDPS 双排会进入单位框占位、
  Target 与 Player 尺寸不一致、TargetTarget 过小、Aura 图标偏小。AEUI `0.8.15`／
  `focus-layout-contract=1.8` 以 `ACTION-BARS-CORE-SIM-V7` 修复：三框统一
  `240×60 / 0.68`，TargetTarget 改挂 Target 上方；Aura 统一 `22 UI` 并把四个
  offset 明确置零；Cast 上排、Swing 下排；DoiteDPS 双排整体移至
  `TOPLEFT (850,-647)`。只迁移 exact v7／v8 签名，手动调整不覆盖。
- 透明度与输入合同同时冻结：关键单位状态、施法、攻击计时、DoiteDPS 与技能
  CD 不做整组淡化，继续使用各 provider 原生半透明背景；只允许非核心辅助栏按
  用户设置脱战淡出。AEUI Rail、连接片、口袋／护套等纯装饰 Frame 必须
  `EnableMouse(false)`，DoiteDPS 锁定态继续由 provider 关闭根 Frame 鼠标；不创建
  覆盖中央视野的大型透明命中层，只有可见 Button、单位框和确有用途的 AutoBar
  联合悬停通道接收鼠标。
- pfUI 施法条与 SwingTimer 已按真实对象审计：玩家／目标／Focus Castbar 均可
  独立移动；主手、副手与 ranged 行为仍归 provider。V9 把玩家施法、目标施法、
  主手／ranged 统一为 `260×12 UI / 1.0` 并以 `x=0` 三排同轴纵置，副手同尺寸紧贴主手；没有
  改施法识别、延迟、可打断、攻速、Marker 或 range 行为。
- 目标设备已安装 DoiteDPS；真实根 Frame 为 `318×46 UI`，Ready 槽 `46 UI`、
  Forecast `34 UI`、资源框 `178×22 UI`，现有 scale `1.0`。V3 只提出中心落位
  与以后可选的低重量视觉桥接，不改其推荐逻辑、锁定、显隐或保存值。
- 目标客户端另已安装 TrinketMenu 与 AutoBar。饰品桥接优先保留正在使用的
  TrinketMenu；当前“大奶黑牛”已主动启用并配置两者。AutoBar 为精确 24 类
  profile，但 `showEmptyButtons／showCategoryIcon` 均关闭，只显示当前有物品的
  类别并按最大 `4×6` 动态收缩；AEUI 仍不自动启用 provider。
- `AB.FIELDKIT.V1` 已完成 provider 级审计、`AB-FIELDKIT-SIM-V2` 方向确认与两套
  production review。TrinketMenu 主栏保持水平 `92×52 UI`／垂直 `52×92 UI`、
  两枚 `36×36 UI` 已装备 Button、`18×18 UI` Queue inset；候选保持 `0–30` 个
  `36 UI` Button、步距 `40 UI`。AutoBar 推荐 profile 保持完整 `24` 个逻辑类别，
  但默认仅实例化当前可用的 `1–24` 个主 Button，最大 `4×6`；满 24 格时连续
  `1–8／9–16／17–24` 可用分隔带区分，分类内仍由最多
  `12` 个四向 popup 展开真实物品；provider 当前禁用状态没有改变。
  用户于 `2026-08-09` 接受 Trinket 第4稿与 Consumable 第1稿，并随后以“下一步”
  独立授权 P4→P5。两张 `1024² RGBA` source SHA `82dd2260…c012`／
  `623f29c5…a2419` 保持 byte-exact；确定性 exporter 对完整 A／B／C／D 物件做一次
  premultiplied-alpha 等比缩放，D 另有一份 `90°` 旋转副本，分别打包为两张
  `512²` 32-bit TGA。Trinket runtime 文件 SHA `3614d9a8…f455`、像素 SHA
  `0961d750…aef`；Consumable 文件 SHA `c48f6292…320e`、像素 SHA
  `658f826f…e30d`。两张 atlas 均为 visible green `0`、透明 RGB `0`。
  `ActionBars` 只给 AutoBar `24+12` 与 TrinketMenu `2+30` 既有 Button／Frame
  添加非交互视觉层，并在 provider 完成布局／更新后刷新装饰。用户首次实机检查
  发现 AutoBar 数量仍显示但多枚物品图标缺失，TrinketMenu 两枚已装备图标也只剩
  空护套；两张截图共同证明 A／B 装饰与 ActionButtonTemplate 动态 Icon 同处
  `BACKGROUND` 且后创建装饰覆盖 Icon。`fieldkit-contract=1.1` 把全部主格、popup、
  已装备槽和候选格的口袋纹理移入以真实 Button 为父、FrameLevel 低 `1` 的独立
  非交互 Frame；后续实机复测已确认 Icon／Count／Cooldown／按下反馈正常。
  同时新增显式、可逆的当前角色配置入口：`/aeui autobar open` 打开原配置页，
  `/aeui autobar apply` 备份后一次性应用已确认的 24 类、库存自适应／最大 `4×6`
  profile，`/aeui autobar restore` 恢复；该版普通刷新不写类别 profile，也不自动启用 AutoBar。
  bridge-v1.9 只对持有 AEUI pre-apply 备份且仍精确匹配旧 AEUI 满格显示的角色，
  一次性关闭空槽／缺货类别图标并隐藏拖动把手；其他角色与自定义配置不变，也不
  替代 TrinketMenu 行为。bridge-v2.0 只让绑定态消耗品与饰品底边共同比主栏低
  `20 UI`，其余 v1.9 profile、popup 与 provider 行为不变；bridge-v2.1 修正
  AutoBar 配置 Tooltip 缺失说明与嵌套布局回调的持久错位，但 `0.05s` 延迟仍产生
  一帧可见跳动；bridge-v2.2 改为独立更新零延迟排队、`SetupVisual` 同事件立即
  收敛，但实机发现配置页打开边界仍会留下自由坐标；bridge-v2.3 先同步恢复缓存的
  已验证锚点，再于零延迟事件按稳定几何重算，不改变可见几何。bridge-v2.4 根据
  用户确认把当前有效槽一次迁入原生职业 profile，并把配置页裁为仅“栏位／按钮”、
  单一职业编辑网格与“完成”；角色原槽和职业原槽均保留可逆备份，显示 layout 仍按
  AutoBar 原生能力保存在当前角色。bridge-v2.5 不改该配置／profile 合同，只把停靠
  重算改为 provider Button 相对 handle 的局部锚点包络，避免 apply 生命周期中的
  陈旧屏幕坐标覆盖已验证缓存。
  用户随后提供 `376×427 RGB` 截图
  `4d29a262…e942`，指出 AutoBar 原生向左线性 popup 穿过并遮挡主格，并授权修改；
  同时要求考虑消耗品袋与饰品袋吸附。AEUI `0.8.2`／`fieldkit-contract=1.2` 只在
  exact `24 / 4×6 / 推荐 profile` 使用卷袋外置抽屉：候选 `1–6` 单列、`7–12`
  列优先双列，`AUTO` 在吸附态向左、自由态按屏幕余量选择；支持 `LEFT／RIGHT／
  NATIVE`，不匹配即恢复 provider 原生布局。消耗品默认软吸附主栏左侧 `48 UI`，
  饰品默认吸附右侧 `16 UI`，阈值均为 `32 UI`；两侧可独立拖离／回吸附，AEUI 只
  保存自己的布尔状态，没有维护循环。`AB-FIELDKIT-SIM-V3` 布局 `89/89`、display
  `19/19`；runtime display `9/9`＋`10/10`、violations `0`，fresh-checkout package
  `pass`、目标设备无需构建。用户随后提供 `416×415 RGB` 右抽屉截图
  `be080504…f1ee3`：抽屉已正确外置，但鼠标从主格穿过空隙时会提前关闭。审计确认
  AutoBar 原 `PopupMouseover` 每秒只接受 `AutoBarFrame／AutoBarPopupFrame` 的
  直接子级，XML Frame `OnLeave` 也仍按原边界直接隐藏。AEUI `0.8.3`／
  `fieldkit-contract=1.3` 在外置态加入一个覆盖卷袋全高、直接隶属
  `AutoBarPopupFrame` 的透明鼠标通道，右侧宽 `10 UI`、分组左侧宽 `52 UI`；只在
  外置态延后 Frame `OnLeave`，实际关闭仍归 provider 计时器，所有原生回退恢复
  原脚本并隐藏通道。用户复测后明确报告：“鼠标一旦移动到别的格子上，弹出栏就
  消失了”。进一步审计确认，内侧主格到右抽屉的路径会穿过同一行其他主格；每个
  主格的 XML `OnEnter` 都立即调用 `AutoBar:SetPopupButton`，无 popup 的格子会隐藏、
  其他格子会替换当前抽屉，外缘通道无法覆盖这段路径。AEUI `0.8.4`／
  `fieldkit-contract=1.4` 保留通道与 provider 关闭计时器，并只在 exact 外置抽屉已显示
  时对“不同主格”加入 `0.30s` 意图停留：跨格离开即保持原抽屉，停留才调用捕获的
  AutoBar 原 `SetPopupButton`；NATIVE、非 exact、关闭态、非鼠标调用或调度 API 缺失
  都立即委托原方法，不建立逐帧维护。用户随后提供当前完整 UI 截图，要求把动作条、
  消耗品栏和饰品栏“强绑定”并按最初构图重排。审计目标 SavedVariables 发现两侧旧
  软吸附都为 `false`，主栏仍在 `x=-31／y=35` 底边旧坐标，AutoBar 漂到人物右上，
  TrinketMenu 为右下垂直双槽。AEUI `0.8.5`／`fieldkit-contract=1.5` 改用唯一
  `fieldKitBound`：Bar 6、左侧 `4×6` 卷袋和右侧双槽直接锚到 Bar 1；绑定态拖动
  provider 松手即回位，`unbind` 才恢复自由位置，`home` 恢复物理底边净空 `210 px`
  的中心中下布局。当前“大奶黑牛”已写入主栏 `x=0／y=258`、上栏 `x=0／y=291`
  与水平饰品双槽。v1.4 popup guard、accepted art 与 TGA 像素不变。当前保持
  `runtime-exported / P5 / pending-retest`；P4→本次修复 ImageGen
  `0`，原生产循环仍终止于 `4/5` 与 `1/5`。
- AEUI `0.8.9` 引入的 `fieldkit-contract=1.6` 完整保留 v1.5 的 AutoBar、TrinketMenu
  几何与交互，只把已审计的 ArchiTotem `1.7` 根加入同一 `fieldKitBound`。绑定态
  使用 Bar 1 唯一移动根；provider 拖动松手回位，`unbind` 恢复首次捕获的自由
  锚点。普通 refresh 不调用 `ArchiTotem_SetDirection`；只有显式 focus preset
  请求 `down`，并继续保留 provider scale、锁定、施放、候选、Recall 与预设行为。
- 用户随后实机报告退出 pfUI 解锁时
  `modules/unlock.lua:527: attempt to index field 'drag' (a nil value)`。根因是 v1.6
  在绑定态直接从 `pfUI.movables` 删除 Bar 6，而 pfUI 解锁期间的 actionbar
  `UpdateConfig()` 又把它登记回来；OnShow 未创建 drag，OnHide 却按新登记访问。
  AEUI `0.8.13`／`fieldkit-contract=1.7` 保持 Bar 6 登记稳定，在 pfUI 完成 OnShow
  并创建 drag 后仅隐藏绑定态 mover；`unbind` 显示它。actionbar 配置刷新与解锁
  退出后都在事件边界重施 Bar 6 → Bar 1 锚点。新增 Lua smoke 精确覆盖
  OnShow → UpdateConfig → bind／unbind → OnHide，并确认无空 drag、只有 Bar 1
  可移动、无逐帧维护；Field Kit／ArchiTotem 几何、图集与 provider 行为不变。
- `AB.SLOT.BASE.V1` 有界生产循环已在 `5/5` 停止；用户于 `2026-08-08` 明确
  “接受 AB.SLOT.BASE.V1 第5稿”，随后以“进行下一步”授权 P4→P5。exact source
  RGBA `6d4a4d16…7dc0` 已按冻结 `[200,200,824,824)` crop 确定性导出为
  `128×128` 32-bit TGA `ActionSlotBaseV1.tga`，SHA `5c49a1db…23ca`，像素 SHA
  `e527c038…c35c` 与已验收 attempt 5 runtime review 完全一致。当前 AEUI `0.8.12`
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
- V3 邻接的 runtime-v1.2 把 pfUI Player／Target 统一为
  `280×72 UI / local scale 0.75 / tier 8 / y=670`，保存 `x=-180／180`；该 local
  scale 只抵消目标机器 `1920→2560` 的 `4/3` 最终显示拉伸，最终单位框宽约
  `280 px`、两框内缘约 `80 px`，玩家框左缘与卷袋右缘约留 `3 px`。Action Bars
  只在显式 preset 写入当前角色位置，不接管其视觉。
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
- AutoBar／TrinketMenu 存在时只做 feature-detect 视觉桥接，不复制其数据表；
  只在 provider 自身布局／更新方法完成后以 `hooksecurefunc` 刷新 AEUI 装饰，不装
  物品使用／换装竞争 hook。任一 provider 缺失或未加载时 V1 不显示、不占位；
  原生装备槽／钉选 fallback 若需要，必须以后另立功能合同。
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
| `AB.STANCE／PET` | `P1–P5` | Bar `11／12` 与 provider 状态已审计；stance 的 focus runtime-v2.5 保持 `BOTTOM (0,255)`，真实 `bar11.icon_size` 为 `25 UI`、local scale `1.0`，姿态内容／点击仍归 pfUI；Pet 仍为 P1 | 战士 `/reload` 确认三姿态真实按钮与命中区同步放大且不压中央栏；再覆盖职业最少／最多姿态数量与宠物自动施法排版 |
| `AB.CONSUMABLE.RACK／POCKET／POPUP／CONFIG` | `P5 / runtime-asset-v1.5 / bridge-v2.8 / pending-game-validation / 1/5` | [source](../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)／[runtime manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json)／[work](work/ACTION.BARS.FIELDKIT.V1.md)；TGA `c48f6292…320e`、像素 `658f826f…e30d` 不变；24 个逻辑类别、当前可用类别动态显示；绑定态固定 `4` 列、行数随数量变化、第 1 行在底部且只向上增长，外壳右缘距主栏左缘 `12 UI`、底边低 `20 UI`。v2.8 延续配置裁剪、职业槽、空说明与 handle 隐藏；真实 Button 四列根绕过 provider handle／docking／自由坐标 | `/reload` 确认当前 13 格自下而上为 `4／4／4／1`，第 1 行右缘固定挂到主栏左侧；status 为 `autobar-anchor-basis=button-grid-4col-up`、`autobar-provider-dock=bypassed-button-grid`；再开关配置页确认不跳位 |
| `AB.CONSUMABLE.GROUP` | `P5 / runtime-asset-v1.5 / bridge-v2.8 / pending-game-validation / 1/5` | 仅精确 `24 Button / 4×6 / 推荐 profile` 显示三组分隔，不创建三段文字；少于 24 个当前主格时隐藏分隔但保留 external drawer；v2.8 只修正当前真实 Button 的四列向上排版，不改变职业层与分组合同 | 实机确认库存变化时外壳按固定四列动态增减行、无文字且少于 24 格无错误分隔；验证职业槽、item ID、抽屉与非 exact 原生回退 |
| `AB.TRINKET.DOCK` | `P5 / runtime-asset-v1.5 / bridge-v2.8 / pending-game-validation / 4/5` | [source](../../../assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png)／[runtime manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json)／[work](work/ACTION.BARS.FIELDKIT.V1.md)；TGA `3614d9a8…f455`、像素 `0961d750…aef` 不变；主栏右侧 `8 UI` 强绑定并与消耗品共用低 `20 UI` 的底线，Queue／换装／候选不变；v2.8 不改 TrinketMenu | `/reload` 验证双槽位置、候选、横／竖／scale 与 Queue 行为保持；不执行 attempt 5 |
| `AB.TRINKET.MENU` | `P5 / runtime-asset-v1.5 / bridge-v2.8 / pending-game-validation / 4/5` | C 九宫格与 B 候选插页像素不变；候选 `0／1／8／30` display `9/9 pass`、换装与动态层仍归 provider；v2.8 不替代 TrinketMenu 行为 | 实机验证候选图标、左右键换槽、Queue、菜单向右外展、独立 scale／方向及 provider 缺失 fail-open |
| `AB.FOCUS.UNITFRAMES` | `P5 / runtime-v2.5 / pending-game-validation` | runtime-v2.5 只新增姿态尺寸修复；Player／Target `240×60 / 0.8`、TargetTarget `240×60 / 0.68`、系统字体 `OUTLINE / 18 UI`、Aura `23 UI`／每排 `8` 均不变 | `/reload` 验证既有三框、字体、长名字、卷袋净空、TargetTarget、Aura 八枚与 Boss 双排 |
| `AB.FOCUS.CASTBAR` | `P5 / runtime-v2.5 / pending-game-validation`；v1.4／v1.5 `game-geometry-failed` | 玩家／目标／Focus 真实对象；玩家／目标施法仍为 `260×12 / 1.0`，共用 `x=0`，分别落在 `y=316／300`；Focus 仍跟随自身 Frame | 实机验证读数、延迟区、可打断状态、与 Swing 同轴且三排不重叠、Boss Debuff 净空 |
| `AB.FOCUS.SWING` | `P5 / runtime-v2.5 / pending-game-validation`；v1.4／v1.5 `game-geometry-failed` | 主手／副手／ranged 真对象；主手／ranged 仍为 `260×12 / 1.0`、`BOTTOM (0,284)`，副手以 `2 UI` 间距紧贴其下；无维护循环 | 实机验证近战双条、远程复用、攻速变化、同轴与中央视野 |
| `AB.FOCUS.STANCE` | `P5 / runtime-v2.5 / pending-game-validation` | `pfActionBarStances` 保持 `BOTTOM (0,255)`；真实 `bar11.icon_size 18 → 25 UI`、local scale `0.7／0.72 → 1.0`。v14／v15 copied profile 一次升级到 v16，仅改姿态合同并保留其他手调坐标；pfUI `UpdateConfig` 后重施 | 战士 `/reload` 确认三枚按钮约 `97×33 UI` union、状态高亮／点击／快捷键正常，并与主栏及计时栈保持净空 |
| `AB.DOITEDPS.TIMELINE` | `P5 / runtime-v2.5 / pending-game-validation`；v1.4／v1.5 `game-geometry-failed` | `318×46 UI` provider 根与 `178×22 UI` 资源排保持 `0.82`，union 仍位于 `TOPLEFT (850,-615)`；v2.5 不改其行为 | 实机验证上下两排与 Player Buff 净空、锁定态、显隐和 fail-open |
| `AB.TOTEM.ARCHITOTEM` | `P5 / bridge-v2.8 / pending-game-validation` | [work](work/ACTION.BARS.FOCUS.V1.md)；真实闭合 `212×32 UI`、Air 最大 `212×224 UI` union；绑定态随 Bar 1、offset `-39 UI`；v2.8 不改 ArchiTotem | 与 V11 同轮实机复测施放、右键、hover、候选、拖动／锁定、Recall、预设、bind／unbind 与 fail-open |
| `AB.MOVER／CONFIG` | `P5 / sidebar-group-v1.0 / pending-game-validation` | pfUI `UpdateMovable`／unlock 生命周期已接入；组合态不删除 Bar 2／4／5／3 movable，只在 drag 创建后把 Bar 2 扩展为 union mover并隐藏其余三把手；Bar 6／TargetTarget 原逻辑不变 | 实机开关 unlock、滚轮缩放、拖动、居中复位与退出，确认单 mover、无 `drag=nil`、其他 mover 不退化 |
| `AB.SIDEBARS.GROUP` | `P5 / runtime-v1.0 / pending-game-validation` | 用户已确认 V11：Bar 2／4／5／3 按 `Paging → Vertical → Left → Right` 映射为 `2×2` 四块，每块 `3×4`、总体 `6×8`，icon `20`、spacing `1`、初始 scale `1.2`、gap `6 UI`；只对“大奶黑牛 - Basin of Stars”exact 四列签名自动迁移，按角色备份并可逆恢复；内容配置仍逐栏独立；runtime display `3/3 pass` | `/reload` 验证右侧高度、右缘净空、四栏阅读顺序和 48 个原动作；unlock 只见一个 group mover，滚轮／拖动同步；`/aeui sidebars unbind` 精确恢复旧四列，再 `bind／home` 验证可逆性 |

## 已接受方向与运行时证据

- AEUI `0.8.25`／Field Kit bridge-v2.7／Combat Focus runtime-v2.5：新实机截图
  `1408×633 RGB`（SHA `d1a94514…49bb`）与目标角色只读 SavedVariables 共同证明上一轮
  P5 未通过。AutoBar provider 源码审计确认 `SetupVisual` 最终写者；新的原生 docking
  smoke 覆盖连续刷新、配置页、unbind／rebind 与 logout-reapply。Focus smoke 覆盖
  `bar11.icon_size=25`、scale `1`、provider rebuild、三按钮 `97×33 UI` 及 copied v14
  非姿态坐标保护。位图与现有 runtime-v2.4 display 像素合同均未改，ImageGen `0/0`；
  当前等待同设备 `/reload` 验证，不得标记 P6。
- AEUI `0.8.24`／Field Kit bridge-v2.6／Combat Focus runtime-v2.4：战士实机证据
  定位真实 `AutoBarAnchorFrameHandle` 与姿态 scale `0.72`。Field Kit Lua smoke 让
  provider 在每次 `SetupVisual` 主动 `Show()` handle，并验证初始 Apply、连续
  `SetupVisual`、完整配置 `OnShow` 与重停靠后都为 `hidden-bound`；显式 `unbind`
  恢复 provider 可见态，重新 `bind` 再隐藏。Focus Lua smoke 覆盖当前 `1.0` live／
  SavedVariables、exact v14 `0.72 → v15 / 1.0` 一次迁移，以及手调 `0.8` 不自动覆盖。
  runtime display v2.4 将当前战士 `icon 25 / border 3 / spacing 1` 的三按钮
  `97×33 UI` 脚印纳入第十三个场景，`13/13 pass`、violations `0`；contract SHA
  `b1fa6faa…e1ba`、report SHA `0c01af25…26e8`。source／TGA 字节、TOC 与 Bootstrap
  均未改变。ActionBars SHA `f7d676ac…867b` 已同步进四份 runtime manifest；
  fresh-checkout package `status=pass`、violations `0`、report SHA
  `e1ca9054…0a35`、records `64`、tracked addon files `554`，目标设备无需构建。
- AEUI `0.8.24`／Field Kit bridge-v2.5：ActionBars SHA
  `b861d7d9…6ffc`、Bootstrap SHA `417592bc…b4f5`、TOC SHA
  `1e2f05e6…9a45`。Field Kit Lua smoke 模拟 AutoBar 真实
  `ButtonsUpdate → provider handle restore → SetupVisual post-hook` 顺序，以及配置页在
  嵌套 `SetupVisual` 后再次写入自由坐标的完整 `AutoBarConfig.OnShow` 边界；两条后置
  钩子返回前都确认已同步恢复缓存的 Bar 1 锚点；零延迟事件以 Button 相对 handle 的
  局部点、尺寸和独立 scale 重算停靠，不读取可能陈旧的屏幕坐标。smoke 另注入两套
  相反 world-space 值并连续执行两次 apply，最终锚点保持完全相同。
  独立 `ButtonsUpdate` 的零延迟下一事件路径也单独通过。职业槽迁移、角色／职业双备份、
  仅显示 Slots／Buttons、隐藏 Tab 回到 Slots、provider `OnShow` 后重新隐藏控件与
  restore 恢复原生配置页均进入 smoke。七个 zhCN 缺失说明、一个未知空说明与原生非空说明
  的 Tooltip 拼接回归继续通过。Action Bars 四个 Lua smoke、Field Kit runtime
  `9/9＋10/10`、Action Slot／Rail／Sidebar contracts 与 repository contract 均
  pass。fresh-checkout package `status=pass`、violations `0`、report SHA
  `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files `547`、
  `build_required_on_target_device=false`。Action Slot、Rail、Consumable 与 Trinket
  TGA 字节不变，本轮 ImageGen `0/0`。
- V11 specification：`tools/specs/action_bars_core_simulation_v11.json`，SHA
  `fbd169c9…d1d7`；确定性预览
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V11/action_bars_core_sim_v11.png`，
  SHA `4586fa06…1d94`；layout report SHA `586d7602…e06e`，`68/68 pass`。
- V11 delta display contract SHA `5228f1cb…cdb6`，报告 SHA `bde30990…fcb0`，
  `3/3 pass`；focus runtime-v2.3 display contract SHA `f7834b37…76f1`，报告 SHA
  `97475410…865d`，`12/12 pass`；sidebar runtime-v1.0 display contract SHA
  `848d5f0c…9a79`，报告 SHA `71986166…b740`，`3/3 pass`；violations 均为 `0`。
  新 focus／DDPS 截图 SHA `06da8388…28bf`、四栏截图 SHA `6abe43c7…6e11`、
  最新 live 字体失败截图 SHA `9858b619…c4c7e0`；只作只读几何／失败证据。
- AEUI `0.8.20` entrypoints：ActionBars SHA `3e62c88b…3ac6`、Bootstrap SHA
  `a97b8bf5…e35e`、TOC SHA `32fc7039…e4bd`。Action Slot、Rail、Consumable 与
  Trinket TGA 仍分别为 `5c49a1db…23ca`、`1e5cca09…0a3d`、`c48f6292…320e`、
  `3614d9a8…f455`；本轮无位图变化，ImageGen `0/0`。
- AEUI `0.8.20` fresh-checkout addon package：`status=pass`、violations `0`、
  report SHA `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files
  `547`、`build_required_on_target_device=false`；目标设备只需拉取并安装 addon。
- V10 specification：`tools/specs/action_bars_core_simulation_v10.json`，SHA
  `8b36dfb9…16d`；确定性预览
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V10/action_bars_core_sim_v10.png`，
  SHA `54b0382d…5da6`；layout report SHA `957c9eea…18d2`，`60/60 pass`。
- V10 simulation display contract SHA `bc771950…0ff3`，报告 SHA
  `2aba7a65…65d1`，`12/12 pass`；focus runtime-v2.1 display contract SHA
  `1f7fafdf…ef4e`，报告 SHA `27234ae2…46d`，`12/12 pass`；violations 均为 `0`。
  新实机问题截图 SHA `3e44c1bb…6325`；ignored 预览／报告只证明几何与显示合同，
  不是 addon 资产。
- AEUI `0.8.18` entrypoints：ActionBars SHA `05a300e5…9b30`、Bootstrap SHA
  `94bb20ed…291f`、TOC SHA `aa9b2abc…9a16`。Action Slot、Rail、Consumable 与
  Trinket TGA 仍分别为 `5c49a1db…3ca`、`1e5cca09…a3d`、`c48f6292…320e`、
  `3614d9a8…f455`；本轮无任何位图写入，ImageGen `0/0`。
- AEUI `0.8.18` fresh-checkout addon package：`status=pass`、violations `0`、
  report SHA `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files
  `547`、`build_required_on_target_device=false`。目标设备只需 `/reload`。
- V9 specification：`tools/specs/action_bars_core_simulation_v9.json`，SHA
  `7fe55794…fd33`；ignored scene SHA `fb2d286a…0443`。layout report SHA
  `2036f813…dd6`，`56/56 pass`、violations `0`。
- V9 simulation display contract：
  `tools/specs/action_bars_core_simulation_v9_display_region.json`，SHA
  `84829972…2b9f`；报告 SHA `408a97ec…1f4f`，`10/10 pass`、violations `0`。
- focus runtime-v2.0 display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `24ca41fb…8b2c`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime-v2.0/display-region-report.json`，
  SHA `6807d038…0753`，`10/10 pass`、violations `0`。“大奶黑牛”当前截图 SHA
  `fe0dc65e…04d1`；ignored 预览／报告只证明几何与显示合同，不是 addon 资产。
- AEUI `0.8.17` entrypoints：ActionBars SHA `6cfc0ac9…0a22`、Bootstrap SHA
  `833b2603…4abb`、TOC SHA `438b3448…9215`；四份 Action Bars runtime manifest 已
  同步。Slot／Rail／Field Kit source 与 TGA 字节、P6 证据和 provider 行为不变；
  ImageGen `0/0`。
- AEUI `0.8.17` fresh-checkout addon package：`status=pass`、violations `0`、
  report SHA `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files
  `547`、`build_required_on_target_device=false`。目标设备只需 `/reload`。

- V8 specification：`tools/specs/action_bars_core_simulation_v8.json`，SHA
  `690487a4…8ab2`；ignored scene SHA `d7c2b84f…a4f3`。layout report SHA
  `1ed657db…1f0c`，`56/56 pass`、violations `0`。
- V8 simulation display contract：
  `tools/specs/action_bars_core_simulation_v8_display_region.json`，SHA
  `d11d4f28…1147`；报告 SHA `c2b9f164…5c85`，`9/9 pass`、violations `0`。
- focus runtime-v1.9 display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `09d973d2…178d`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime-v1.9/display-region-report.json`，
  SHA `42559f26…1de`，`9/9 pass`、violations `0`。两张用户实机失败证据 SHA 为
  `4e120794…a5d`／`2352facf…3509`；ignored 预览／报告只证明几何完整，不是 addon 资产。
- AEUI `0.8.16` entrypoints：ActionBars SHA `8ba6b1e9…0a1`、Bootstrap SHA
  `524ad593…7bf`、TOC SHA `18e09fa5…3e9d`；四份 Action Bars runtime manifest 已
  同步。Slot／Rail／Field Kit source 与 TGA 字节、P6 证据和 provider 行为不变；
  ImageGen `0/0`。
- AEUI `0.8.16` fresh-checkout addon package：`status=pass`、violations `0`、
  report SHA `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files
  `547`、`build_required_on_target_device=false`。目标设备只需 `/reload`，无需生成、
  导出或应用补丁。

- V7 specification：`tools/specs/action_bars_core_simulation_v7.json`，SHA
  `6aeddc50…f764`；ignored scene SHA `be7d4c83…bdeb`。layout report SHA
  `a81b81fd…69c0`，`44/44 pass`、violations `0`。
- V7 simulation display contract：
  `tools/specs/action_bars_core_simulation_v7_display_region.json`，SHA
  `7dbb841c…f8af`；报告 SHA `e3342b03…d890`，`7/7 pass`、violations `0`。
- focus runtime-v1.8 display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `3e28fbc2…d9a4`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime-v1.8-display-region-report.json`，
  SHA `4195f373…f4db`，`8/8 pass`、violations `0`。这些 ignored 预览／报告只证明
  几何完整，不是 addon 资产。
- 历史 AEUI `0.8.15` entrypoints：ActionBars SHA `7bf1e74e…49a0`、Bootstrap SHA
  `300651cf…66af`、TOC SHA `5b297213…8cbd`；四份 Action Bars runtime manifest 已
  同步。Slot／Rail／Field Kit source 与 TGA 字节、P6 证据和 provider 行为不变；
  ImageGen `0/0`。
- 历史 AEUI `0.8.15` fresh-checkout addon package：`status=pass`、violations `0`、
  runtime manifest records `49`、tracked addon files `547`、
  `build_required_on_target_device=false`。目标设备只需 `/reload`，无需生成、导出或
  应用补丁。

- V5 已由用户确认接入；specification：`tools/specs/action_bars_core_simulation_v5.json`，SHA
  `790746a5…07cb2`；本地渲染
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/action_bars_core_sim_v5.png`，
  SHA `4ab387a5…8797`。
- V5 display-region 合同：
  `tools/specs/action_bars_core_simulation_v5_display_region.json`，SHA
  `70d1f4fa…9bbd`；ignored 报告 SHA `ec5fecae…2ea1`，`8/8 pass`、
  violations `0`。精确布局报告 SHA `72636dd3…f345`，`59/59 pass`、
  violations `0`。这些模拟证据只证明几何完整；用户接受事实与最终 runtime 证据
  分别记录，不把模拟像素当作 addon 资产。
- specification：`tools/specs/action_bars_core_simulation_v4.json`，SHA
  `54d05cc2…ee21`
- 本地渲染：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/action_bars_core_sim_v4.png`，
  SHA `3307359c…a1867`
- display-region 合同：
  `tools/specs/action_bars_core_simulation_v4_display_region.json`
- 报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/display-region-report.json`；
  ArchiTotem 四种状态与三项战斗读数 `7/7 pass`、violations `0`，SHA
  `24600000…fbd6`
- 精确布局报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/layout-report.json`；
  `54/54 pass`、violations `0`，SHA `f7b666d9…ae11`
- V5 runtime-v1.6 最终 display 合同：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `405500e2…9ead`；ignored 报告
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.6/display-region-report.json`，
  SHA `999a7063…2d9d`，`8/8 pass`、violations `0`。
- fresh-checkout package：
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.6/addon-package-report.json`，
  SHA `a6a4ec74…16b9`，`status=pass`、violations `0`、目标设备无需构建。
- V3 仍是用户已确认的原始构图基线；V4 曾获方向确认并由 AEUI `0.8.9` 接入，
  但新实机截图已否决其战斗核心几何。V5 经用户明确“确认接入”后由 AEUI
  `0.8.10`／`focus-layout-contract=1.4` 首次集成，但实机判定坐标传输失败。AEUI
  `0.8.11`／`focus-layout-contract=1.5` 的逐 Frame 校准也已实机失败。AEUI
  `0.8.12`／`focus-layout-contract=1.6` 改为固定游戏原生坐标；ActionBars adapter
  SHA `30af188e…b38a`、Bootstrap SHA `86e34d2c…af9e`、TOC SHA
  `a6441513…fec`。V5 只修订该几何，V3 accepted art、
  Combat Deck、Field Kit atlas 与 ArchiTotem bridge 均未改变；ImageGen `0/0`。
- AEUI `0.8.13`／`fieldkit-contract=1.7` 只修复 pfUI unlock mover 生命周期；
  ActionBars adapter SHA `b55e3d31…832cf`、Bootstrap SHA `5a1ffe10…ce74`、TOC SHA
  `2cef99a6…cb6a`。四份 runtime manifest 已同步共享入口哈希与 addon 版本；Slot／Rail／
  Field Kit TGA 字节、display 合同、P6 证据与 focus runtime-v1.6 坐标均未改变。
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
  绿色传输、provenance 与横／竖极端九宫格。`generated/` 内 raw／canonical／review
  仍只是 provenance；用户接受后的 byte-exact tracked copies 继续是 P4 source，
  客户端只加载后述 P5 TGA，不加载 raw／canonical／review 像素。
- Field Kit 最终 exporter：`tools/build_action_fieldkit_v1_runtime.py`（SHA
  `40ef49cc…5484`）。它按每格完整 visible bbox 取 A／B／C／D，A／B／C 使用一次
  premultiplied-alpha LANCZOS，细 D 使用一次 premultiplied-alpha HAMMING 以避免
  低 Alpha 绿色 overshoot；D 再确定性旋转 `90°`。不重绘、不镜像、不重着色，
  transparent RGB 清零，两个原生产预算均不重置。
- Trinket runtime 为
  `addon/AzerothExpeditionUI/Media/ActionBars/ActionTrinketKitV1.tga`，文件 SHA
  `3614d9a8…f455`、像素 SHA `0961d750…aef`；runtime manifest 位于
  `assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json`。
  Consumable runtime 为同一媒体目录的 `ActionConsumableKitV1.tga`，文件 SHA
  `c48f6292…320e`、像素 SHA `658f826f…e30d`；runtime manifest 位于
  `assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json`。
  两张 TGA 都是 `512² RGBA / 32-bit`，visible green 与透明 RGB 非零值均为 `0`。
- tracked display 合同为
  `tools/specs/action_trinket_kit_v1_runtime_display_region.json`（SHA
  `fd2e2c58…791c`）与 `tools/specs/action_consumable_kit_v1_runtime_display_region.json`
  （SHA `6bef6214…7dd`）。最终运行时场景分别 `9/9`、`7/7` pass，violations `0`；
  fresh-checkout package 报告 SHA `a6a4ec74…16b9`，`status=pass`、目标设备
  `build_required=false`。runtime 预览／报告仍是 ignored 证据，不进入 addon。
- `ActionBars.lua` 的 Field Kit contract 为 `1.1`：AutoBar bridge 监听
  `AutoBar_SetupVisual`、`ButtonsUpdate`、`UpdatePopupButtons` 完成态；TrinketMenu
  bridge 监听 `OrientWindows`、`BuildMenu` 完成态。钩子仅刷新低一 FrameLevel 的
  子纹理／装饰 Frame，不调用 provider 配置函数，不改 Button 几何、脚本、命中区
  或 SavedVariables。只有用户主动执行 `/aeui autobar apply／restore` 时才通过
  AutoBar `1.31` profile API 写入／恢复当前角色配置。
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
  用户接受后 exact canonical 已晋级为
  [P4 source](../../../assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png)／
  [manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_SourceManifest_v1.json)，
  `source-accepted / 4/5`；不执行 attempt 5。
- Consumable attempt 1 raw：同一 production 根的
  `AB.CONSUMABLE.KIT.V1/attempt-01/raw/AB.CONSUMABLE.KIT.V1.attempt-01.raw.png`
  （SHA `de25567f…b8ba`，`1254×1254 RGB`）；deterministic canonical
  `attempt-01/canonical/AB.CONSUMABLE.KIT.V1.attempt-01.canonical.png`（SHA
  `623f29c5…a2419`，exact `1024×1024 RGBA`）。四格各一显著组件、原始物件均不
  触边，visible green `0`、透明 RGB 非零 `0`、最终 margin 全部 `80 px`。
  review scene `057c45cb…150a`、supported layouts `e78b6dc5…9ae5`、cell board
  `cc56df10…9fd8`；display `16/16 pass`、violations `0`。完整 checklist 内部 pass，
  用户接受后 exact canonical 已晋级为
  [P4 source](../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)／
  [manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json)，
  `source-accepted / 1/5`；不执行 attempts 2–5。

## 下一门禁

1. `AB.SLOT.BASE.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-SLOT-BASE-V1_TurtleWoW_P6_2026-08-08.png`
   （SHA `dc9615ac…4d5d`）与同目录 P6 evidence JSON（SHA `73a8f942…0d0b`）；
   静态截图与用户交互确认的证明范围保持分离。
2. `AB.FIELDKIT.V1` 保持 `runtime-exported / P5`，当前为
   `fieldkit-contract=2.8 / pending-game-validation`。两张视觉 runtime manifest 仍为
   `runtime-asset-v1.5`；source SHA `82dd2260…c012`／`623f29c5…a2419` 与 runtime
   TGA SHA `3614d9a8…f455`／`c48f6292…320e` 均未改变。bridge-v2.8 延续
   popup guard 与 mover 生命周期，并把 AutoBar 默认显示改为保留 24 类逻辑槽、
   仅展示当前可用类别；外置抽屉不再要求 24 个主格同时可见，并让消耗品与饰品
   底边共同落在主栏底边下 `20 UI`；只为缺失分类说明提供运行时兼容文本。独立
   `SetupVisual／ButtonsUpdate` 在同一事件边界把当前真实 Button 固定排为四列：第 1 行
   在底部，外壳右缘挂到主栏左侧，后续行只向上增长；`13` 格应为 `4／4／4／1`。
   绑定态不再依赖 provider handle、docking 或自由 position。显式 `unbind`／AEUI 关闭时
   恢复 provider 原 Button Point 与 handle 偏好。配置页只保留
   “栏位／按钮”，槽位固定为原生职业层并带角色／职业双备份；“动作条／弹出／设定”、
   综合预览、层选择器及默认重置／还原均隐藏，“完成”保留。TrinketMenu Queue／
   换装、ArchiTotem 行为均不替代。P4→当前 ImageGen `0`，原循环仍止于 `4/5` 与 `1/5`。
3. Combat Focus 当前共享 AEUI `0.8.30` entrypoint，为
   `focus-layout-contract=2.5`／profile v16。
   `/reload` 会把仍匹配完整旧签名的 v7／v8／v9／v10／v11 游戏坐标 profile、
   仍使用旧全局 unit face／`14 UI` 的 exact v12 profile，以及完整匹配上一版系统
   字体／几何签名的 exact v13 profile 继续一次性迁移；目标设备现存 copied v14／v15
   profile 则只把姿态 `bar11.icon_size` 改为 `25 UI`、scale 改为 `1.0`，Player 等
   非姿态手调坐标保持不变。显式 apply 仍可覆盖完整 preset。
   `/aeui focuslayout restore` 仍恢复完整 pre-focus profile。Lua smoke、V11 layout
   `68/68`、simulation display `3/3` 与 focus runtime display `13/13` 均 pass。
   下一门禁是
   目标客户端实机确认 Player 与下移后的卷袋完全分离，Player／Target 为
   `240×60 / 0.8`、TargetTarget 保持 `240×60 / 0.68`，三框实际 FontString 均使用
   客户端系统字体、`OUTLINE / 18 UI`，并在 `/pfui` 应用／unlock 后仍保持；
   TargetTarget 依附 Target 右侧并不越屏，`23 UI` Aura 真实每排容纳 `8` 枚，
   Boss 的 `16` 个 Target Debuff 换成两排后仍不压玩家施法条；
   Player Cast／Target Cast／Swing 全部同轴、依次纵排且均为 `260×12 / 1.0`，
   DoiteDPS 上下两排作为整体上移 `32 UI` 后不压 Player Buff。
4. Field Kit、Combat Focus 与已确认的四栏组合在 V11 同轮复测：先确认
   `/aeui status` 含 `version 0.8.30`、`fieldkit-contract=2.8`、
   `autobar-slot-scope=class-only`、`autobar-config-ui=class-only`、
   `autobar-config-descriptions=repaired`、
   `autobar-config-description-fixes=7`、`autobar-anchor-basis=button-grid-4col-up`、
   `autobar-provider-dock=bypassed-button-grid`、
   `autobar-drag-handle=hidden-bound`、
   `focus-layout-contract=2.5`、`focus-layout-unit-font-live=19`、
   `sidebar-group-contract=1.0`、`sidebar-group-binding=bound`、
   `focus-layout-coordinate-space=game-native-v1`、`focus-layout-unit-scale=0.8`、
   `focus-layout-targettarget-scale=0.68`、`focus-layout-readout-scale=1`、
   `focus-layout-stance-scale=1`、`focus-layout-stance-icon-size=25`、
   `focus-layout-readout-size=260x12`、`focus-layout-unit-font-size=18`、
   `focus-layout-unit-font=system`、
   `fieldkit-binding=bound` 与 `actionbar-stack=12x2-bound`。开关一次 pfUI unlock，
   确认无 `unlock.lua:527`、中央绑定态只有 Bar 1 mover、右侧组合只有 Bar 2 group
   mover，Bar 6 与 TargetTarget 均不跳位；战士三枚姿态按钮清晰放大且点击／状态正常。
   再确认左侧库存自适应卷袋—中央 `12×2` 动作条—右水平双饰品保持原 x，左右
   两组共同下移 `20 UI` 且底边对齐；消耗品第 1 行右缘固定挂到主栏左侧；
   “大奶黑牛”当前应只显示 13 个有物品类别并排成自下而上 `4／4／4／1`，库存变化时
   固定四列、只增减向上的行，
   且无三段文字；AutoBar 配置页只应显示“栏位／按钮”两个 Tab、一个
   “职业栏位（左键编辑）”网格与“完成”，不应再显示综合预览、四层选择、
   “重置为默认／还原”或隐藏的三个 Tab。确认当前有效槽（含手动数字 item ID）
   已迁入职业层，同职业角色复用，角色原槽仍可由 `/aeui autobar restore` 恢复。
   连续开关配置页，确认打开动作本身不会把卷袋留在 provider 自由坐标；再逐类悬停
   确认不再出现 `AutoBarConfig.lua:211`，并连续点击多个可见配置控件，确认卷袋始终停在主动作条
   左侧，既不交替错位，也不再出现先跳出、后回位的可见闪动；验证 popup `1／6／7／12`、跨格保持／
   `0.30s` 切换、四种 popup mode、
   TrinketMenu `0／1／8／30` 候选、左右键换槽、Queue、ArchiTotem 施放／候选／
   Recall／拖动以及 `bind／unbind／home／restore`。确认 Bar 2／4／5／3 的 48 个原动作
   按 `Paging／Vertical／Left／Right` 保留在四个 `3×4` 分区，拖动／滚轮同步、中键
   回到 home；`/aeui sidebars unbind` 精确恢复旧四列，再 `bind／home` 可逆返回。
   普通刷新不得写 provider 内容配置。
5. `AB.RAIL.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-RAIL-V1_TurtleWoW_P6_2026-08-09.png`
   （SHA `5e89c6e5…12942`）与同目录 P6 evidence JSON（SHA
   `2d48b8fb…0be3`）；静态截图与用户对完整六项交互／布局清单的确认范围保持
   分离。Rail runtime TGA、display、功能合同与 P6 证据均未改变；manifest 只同步
   共享 AEUI `0.8.25` adapter／bootstrap／TOC 哈希，P5→P6 ImageGen `0`。
6. Rail 若要进入 `P6-C`，必须先在现存 work 中形成组件专属的精确 keep／delete
   inventory，排除共享 `ActionBars.lua`、Character V3 锁定基准及其他未完成
   Action Bars 组件依赖，并向用户展示、取得明确批准；当前不清理 ignored
   `generated`、work、失败候选或回退证据。
7. `AB.SLOT` 若要进入 `P6-C`，必须先在现存 work 中向用户展示精确保留／删除
   inventory 并取得明确批准；当前不得清理该组件的 ignored `generated`、work
   或其他专属中间证据。
8. `AB.SLOT.STATE` 与狮鹫继续各自形成独立合同并逐批授权。Bar `1–10` scoped
   visual adapter 不改变 pfUI 功能所有权；未登记 Bar 与第三方 provider 始终
   fail-open。
