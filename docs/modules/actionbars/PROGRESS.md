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
  双施法条 → 姿态／技能栏。完整焦点栈仍是一次性 preset；Field Kit v1.5 则把
  Bar 6、左卷袋与右双槽直接相对锚到 Bar 1，使三部分共享一个移动根，但不使用
  维护循环重写位置或 scale。
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
- `ACTION-BARS-CORE-SIM-V4` 已完成确定性 P2 内审：保留 tier 8、Combat Deck、
  左 `4×6` 卷袋、右水平双饰品与 Bar 1 几何，只把 Player／Target、双方施法、
  Swing、姿态和 DoiteDPS 的 local display compensation 从 `0.75` 提议为
  `0.82`（约 `+9.3%`），同时把单位框中心内收，维持外侧总包络不增。ArchiTotem
  作为职业卫星居中置于动作条／XP Rail 下方，提议向下展开，绑定态随 Bar 1；
  provider 的施放、右键、hover、冷却、倒计时、锁定、方向与预设全部不接管。
  layout `54/54`、display `7/7`、violations `0`，ImageGen `0/0`。当前为
  `simulation-reviewed / P2 / pending-user-confirmation`，尚未改 addon、pfUI、
  ArchiTotem 或 SavedVariables。
- 透明度与输入合同同时冻结：关键单位状态、施法、攻击计时、DoiteDPS 与技能
  CD 不做整组淡化，继续使用各 provider 原生半透明背景；只允许非核心辅助栏按
  用户设置脱战淡出。AEUI Rail、连接片、口袋／护套等纯装饰 Frame 必须
  `EnableMouse(false)`，DoiteDPS 锁定态继续由 provider 关闭根 Frame 鼠标；不创建
  覆盖中央视野的大型透明命中层，只有可见 Button、单位框和确有用途的 AutoBar
  联合悬停通道接收鼠标。
- pfUI 施法条与 SwingTimer 已按真实对象审计：玩家／目标／Focus Castbar 均可
  独立移动；攻击条为 `200×12 UI` 主手、随主手锚定副手及独立 ranged。V3
  v1.1 舒适缩放后的双施法条约 `199×16` 客户端像素，近战双计时约
  `142×9` 客户端像素；经 `4/3` 显示放大后仍保持可读。
- 目标设备已安装 DoiteDPS；真实根 Frame 为 `318×46 UI`，Ready 槽 `46 UI`、
  Forecast `34 UI`、资源框 `178×22 UI`，现有 scale `1.0`。V3 只提出中心落位
  与以后可选的低重量视觉桥接，不改其推荐逻辑、锁定、显隐或保存值。
- 目标客户端另已安装 TrinketMenu 与 AutoBar。饰品桥接优先保留正在使用的
  TrinketMenu；当前“大奶黑牛”已主动启用并配置两者，AutoBar 为精确 `4×6 / 24`
  profile；AEUI 仍不自动启用 provider。
- `AB.FIELDKIT.V1` 已完成 provider 级审计、`AB-FIELDKIT-SIM-V2` 方向确认与两套
  production review。TrinketMenu 主栏保持水平 `92×52 UI`／垂直 `52×92 UI`、
  两枚 `36×36 UI` 已装备 Button、`18×18 UI` Queue inset；候选保持 `0–30` 个
  `36 UI` Button、步距 `40 UI`。AutoBar 推荐 profile 保持完整 `24` 个主 Button
  的 `4×6`，连续 `1–8／9–16／17–24` 分为应急／增益／工具，分类内仍由最多
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
  `/aeui autobar apply` 备份后一次性应用已确认的 `4×6`／24 类 profile，
  `/aeui autobar restore` 恢复；普通刷新仍不写 profile，也不自动启用 AutoBar、
  不改其他角色或替代 TrinketMenu 行为。用户随后提供 `376×427 RGB` 截图
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
- `AB.SLOT.BASE.V1` 有界生产循环已在 `5/5` 停止；用户于 `2026-08-08` 明确
  “接受 AB.SLOT.BASE.V1 第5稿”，随后以“进行下一步”授权 P4→P5。exact source
  RGBA `6d4a4d16…7dc0` 已按冻结 `[200,200,824,824)` crop 确定性导出为
  `128×128` 32-bit TGA `ActionSlotBaseV1.tga`，SHA `5c49a1db…23ca`，像素 SHA
  `e527c038…c35c` 与已验收 attempt 5 runtime review 完全一致。当前 AEUI `0.8.8`
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
| `AB.STANCE／PET` | `P1` | Bar `11／12` 与 provider 状态已审计 | 职业最少／最多数量和自动施法实机排版 |
| `AB.CONSUMABLE.RACK／POCKET／POPUP` | `P5 / runtime-v1.5 / pending-retest / 1/5` | [source](../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)／[source manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json)／[runtime manifest](../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json)／[work](work/ACTION.BARS.FIELDKIT.V1.md)；TGA `c48f6292…320e`、像素 `658f826f…e30d` 不变；v1.4 external drawer／联合悬停／`0.30s` 意图保持；v1.5 以 Bar 1 为唯一根，左侧固定 `48 UI`、底边对齐，拖动松手回位；smoke、display `10/10`、package pass | `/reload` 确认左卷袋—中央 `12×2`—右双槽整体跟随 Bar 1；再复测候选 `1／6／7／12` 跨格保持、停留切换、NATIVE 与非 exact 回退 |
| `AB.CONSUMABLE.GROUP` | `P5 / runtime-v1.5 / pending-retest / 1/5` | 精确 `24 Button / 4×6 / 推荐 profile` 才显示三组、启用 external drawer、hover bridge 与 popup switch intent guard；`/aeui autobar apply／restore` 仍为当前角色备份式显式配置，普通刷新只读且不启用 provider | 实机确认“应急／增益／工具”、绑定态向左展开、跨格保持、停留切换、手动数字 item ID、非 exact profile 原生回退 |
| `AB.TRINKET.DOCK` | `P5 / runtime-v1.5 / pending-retest / 4/5` | [source](../../../assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png)／[source manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_SourceManifest_v1.json)／[runtime manifest](../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json)／[work](work/ACTION.BARS.FIELDKIT.V1.md)；TGA `3614d9a8…f455`、像素 `0961d750…aef` 不变；v1.5 在主栏右侧 `16 UI` 强绑定，当前角色一次性改为水平双槽；Queue／换装／候选不变 | `/reload` 验证双槽位于主栏右端、拖动松手回位、候选向外、横／竖／scale 与 Queue 行为保持；不执行 attempt 5 |
| `AB.TRINKET.MENU` | `P5 / runtime-v1.5 / pending-retest / 4/5` | C 九宫格与 B 候选插页像素不变；候选 `0／1／8／30` display `9/9 pass`、换装与动态层仍归 provider；v1.5 只改变主栏位置归属，不替代 TrinketMenu 行为 | 实机验证候选图标、左右键换槽、Queue、菜单向右外展、独立 scale／方向及 provider 缺失 fail-open |
| `AB.FOCUS.CASTBAR` | v1.2 `P5 / revision-requested`；V4 `P2 / simulation-reviewed` | 玩家／目标／Focus 真实对象；当前 AEUI `0.8.8` runtime 保留 tier 8 与 local scale `0.75` 作为回退。V4 提议 `0.82`，玩家／目标双条继续贴各自单位框，Focus 仍跟随自身 Frame；尺寸、状态和动态层不重绘 | 用户接受或修订 V4；接受后实现并实机验证增大后的玩家延迟区、目标可打断状态、独立移动、卷袋净空与 provider 缺失 fail-open |
| `AB.FOCUS.SWING` | v1.2 `P5 / revision-requested`；V4 `P2 / simulation-reviewed` | 主手／副手／ranged 真对象；当前回退 local scale `0.75`。V4 提议 `0.82`、主／ranged 反向校准为 `CENTER y=-78`，副手仍锚到主手；无维护循环 | 用户接受或修订 V4；接受后验证近战双条、远程复用、攻速变化、读数尺寸与中央视野 |
| `AB.DOITEDPS.TIMELINE` | v1.2 `P5 / revision-requested`；V4 `P2 / simulation-reviewed` | 已安装 provider 的 `318×46 UI` 根 Frame；当前回退为 `TOPLEFT 1121,-560 / scale 0.75`。V4 提议 `TOPLEFT 1012,-512 / scale 0.82`，启用、锁定、战斗显隐、Forecast、资源和冷却行为不变 | 用户接受或修订 V4；接受后验证可读性、位置、锁定态鼠标穿透、显隐与 provider 缺失 fail-open |
| `AB.TOTEM.ARCHITOTEM` | `P2 / simulation-reviewed / pending-user-confirmation` | [work](work/ACTION.BARS.FOCUS.V1.md)；ArchiTotem `1.7` 全部真实 Button／候选／特殊按钮已审计。V4 使用真实闭合 `212×32 UI` 与 Air 最大 `212×224 UI` union，提议在动作条下方居中、向下展开并随 Bar 1；layout `54/54`、display `7/7` | 用户接受或修订 V4；确认前不改 addon 或 provider SavedVariables，确认后再实现并复测施放、右键、hover、七层候选、拖动／锁定、Recall、预设与 fail-open |
| `AB.MOVER／CONFIG` | `P1` | pfUI `UpdateMovable` 与 unlock 已审计 | 设计只在 unlock 出现的把手和一次性预设入口 |

## 当前方向预演

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
- V3 仍是用户已确认的原始构图基线；V4 只修订战斗核心可读性与 ArchiTotem
  位置，尚待用户确认，未改变 V3 的 accepted art 或 runtime。
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
2. `AB.FIELDKIT.V1` 保持 `runtime-exported / P5`，当前修复版为
   `fieldkit-contract=1.5 / pending-retest`。Trinket／Consumable source
   SHA `82dd2260…c012`／`623f29c5…a2419` 继续保持 exact；runtime TGA 文件 SHA
   `3614d9a8…f455`／`c48f6292…320e`，最终 display `9/9`＋`10/10`、package 与
   静态回归均 pass。v1.2 增加 exact profile 外置抽屉与两侧软吸附；
   v1.3 的透明通道保留，但实机证明它没有阻止穿越其他主格时发生的立即切换；
   v1.4 只在 exact 外置态加入 `0.30s` 分类切换意图，跨格时保持当前抽屉，明确停留
   才调用 AutoBar 原方法；v1.5 把旧双布尔软吸附收敛为 Bar 1 唯一根的强绑定，
   Bar 6、左 `4×6` 卷袋与右水平双槽整体跟随，仍不改 accepted art／TGA 像素、
   物品使用或候选顺序；P4→当前
   ImageGen `0`，原循环仍止于 `4/5` 与 `1/5`。
3. 舒适缩放与位置层 v1.1 已由第二张实机截图判定失败；v1.2 又由最新实机截图
   判定为“位置避让通过、战斗核心偏小”，两者都不能作为 P6 验收依据。当前下一
   门禁是用户明确接受或修订 `ACTION-BARS-CORE-SIM-V4`：只确认 combat focus
   local scale `0.82`、单位框外包络不增、Combat Deck／Field Kit 不缩放，及
   ArchiTotem 位于主栏下方、候选向下、绑定态随 Bar 1 的方向。确认前不得把提议
   坐标或 `direction=down` 写入 addon／pfUI／ArchiTotem SavedVariables。接受后才
   实现下一版 focus layout contract，并分别验证满血／掉血、有／无目标、双方施法、
   近战双持、远程计时、Aura 超过 `6`、DoiteDPS 锁定／解锁，以及 ArchiTotem
   四元素施放、右键跳过、Air 七层候选、拖动／锁定、Recall、缺失／非萨满
   fail-open 与强绑定回位；本阶段继续不进入 UI 重绘。
4. Field Kit 的同轮 P6 复测先确认 `/aeui status` 含
   `fieldkit-contract=1.5`、`fieldkit-binding=bound` 与
   `actionbar-stack=12x2-bound`。先确认主栏已从底边上移到中心中下，构图为
   “左侧 `4×6` 消耗品—中央 `12×2` 动作条—右侧水平双饰品”，三者底边对齐；用
   pfUI unlock 拖动 Bar 1 时整体跟随，拖动任一 provider 松手必须回位，`unbind`
   后才各自自由，`bind` 恢复组合，`home` 恢复已确认位置。再检查 AutoBar 主格／popup 的物品图标和数量、
   TrinketMenu 双槽／候选的饰品图标、冷却与 Queue 全部位于皮革装饰之上。
   再执行 `/aeui autobar apply`，确认当前角色成为精确 `4×6` 三组、24 格、
   外置 popup `1–6` 单列、`7–12` 双列且不遮主格；从内侧分类打开抽屉后横穿同一行
   其他主格进入左右抽屉，穿越时原抽屉不得关闭或换类；在另一分类主格持续停留约
   `0.30s` 应正常切换到该类，离开主格、透明通道和候选后应正常关闭；
   `/aeui autobar popup` 四模式与
   `/aeui autobar restore` 应正确回退。随后验证 `/aeui fieldkit bind／unbind／home／status`、
   AutoBar 缩放／显隐，以及 TrinketMenu 横／竖、
   `0／1／8／30` 候选、左右键换槽、Queue、八向停靠。`/aeui actionbars` 关闭应
   恢复 provider 原生视觉。普通刷新不得写 profile；任何命令都不得启用 AutoBar、
   在普通刷新中修改 TrinketMenu 方向／Queue SavedVariables 或接管动态图标／行为。
5. `AB.RAIL.V1` 已达到 `game-validated / P6`。长期证据为
   `assets/references/actionbars/p6/AB-RAIL-V1_TurtleWoW_P6_2026-08-09.png`
   （SHA `5e89c6e5…12942`）与同目录 P6 evidence JSON（SHA
   `2d48b8fb…0be3`）；静态截图与用户对完整六项交互／布局清单的确认范围保持
   分离。Rail runtime TGA、display、功能合同与 P6 证据均未改变；manifest 只同步
   共享 AEUI `0.8.8` adapter／bootstrap／TOC 哈希，P5→P6 ImageGen `0`。
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
