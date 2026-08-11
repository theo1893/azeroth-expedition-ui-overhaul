# ACTION.BARS.FOCUS.V1 当前工作

## 当前状态

- 批次：`AB.FOCUS.LAYOUT.V1`
- 当前版本：`ACTION-BARS-CORE-SIM-V11 / focus runtime-v2.3 / sidebar runtime-v1.0`
- 子状态：`runtime-exported / addon-integrated / pending-game-validation`
- 项目阶段：`P5`
- 操作：`integrate`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`；本轮没有位图生产或
  修图，因此未调用执行器。
- ImageGen：`0/0`
- runtime：AEUI `0.8.21`／`focus-layout-contract=2.3`／
  `sidebar-group-contract=1.0`／`fieldkit-contract=2.1`。Field Kit v2.1 只修正
  AutoBar 配置兼容与后置刷新；V11 focus 几何不变并继续直接写 Turtle WoW
  原生 `UIParent` SetPoint 坐标，
  不读取屏幕尺寸、不乘 effective scale、不探针、不回读；Player／Target 为
  `240×60 / 0.8`，TargetTarget 保持 `240×60 / 0.68` 并依附 Target 右侧；三框的
  配置字段与 live health／power FontString 均使用客户端
  `STANDARD_TEXT_FONT / OUTLINE / 18 UI`，Player 另覆盖 top-center 文本，并在各框
  `UpdateConfig` 后置重施，避免 provider 刷新重新套回旧字形。
  三框 Aura 均为 `23 UI`，按 pfUI 真实 `size+7` 步进每行容纳 `8` 枚；玩家从左缘起、
  目标两框从右缘起，上 Buff／下 Debuff。Target 的 `16` 个 Boss Debuff 以两排
  验证且不压施法条。玩家施法、目标施法与 Swing 均为 `260×12 / 1.0`，以同一
  中轴从上到下排列。DoiteDPS 的时间线与资源两排作为一个 union 一起上移 `32 UI`。
  未被手动调整的 exact v7–v11 游戏坐标、仍使用旧全局 unit face／`14 UI` 的 exact
  v12 profile，以及完整匹配上一版系统字体／几何的 exact v13 profile，在 `/reload`
  一次性迁移为 v14；普通
  refresh 不维护绝对几何，只在 Apply／unlock 事件边界恢复已激活的相对锚。
  右侧 Bar 2／4／5／3 已按用户确认组合成 `2×2` 四块，每块 `3×4`、总体 `6×8`；
  组合态只显示一个 group mover，各栏内容配置保持独立，且支持按角色可逆 `unbind`。
  pfUI／ArchiTotem 行为和全部位图字节不变，ImageGen `0/0`。

## 美术基准继承

- 继续继承 [全局美术基线](../../../GLOBAL_ART_BASELINE.md)、
  [Action Bars 主模块基线](../ART_BASELINE.md) 与
  [子模块美术基线](../SUBMODULE_ART_BASELINES.md)。
- 本轮只修订真实 Frame 的游戏坐标、尺寸、局部字体和 Aura 排列，不生成、变换、
  切片或替换任何 source／TGA；既有 Slot、Rail、Field Kit accepted art 保持
  byte-exact，模拟像素不得晋级为运行时资产。

## 本次输入与结论

- 最新 focus／DDPS 截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-da973940-b259-4ca7-80e2-126e6274ba64.png`，
  `877×354 RGB`，SHA-256
  `06da838849592bcd3aab612e595f8455c86e79a343eb14f02241dff19b5328bf`；最新右侧四栏
  截图：`C:/Users/西奥/AppData/Local/Temp/codex-clipboard-6011e488-060f-4e43-b5df-002431877b10.png`，
  `822×806 RGB`，SHA-256
  `6abe43c76a50319c967d3bb7e1cf58c85b682ce585ebbf0365ccaeff0c556e11`。
  初次 SavedVariables 核对确认三框曾被 AEUI 固化为 pfUI
  `BigNoodleTitling.ttf / OUTLINE / 14`；四栏当前从左到右为
  `bar2 Paging／bar4 Vertical／bar5 Left／bar3 Right`，均为 `1×12`、icon `20`、
  spacing `1`、scale `1.2`。V11 把三框配置改为客户端系统字体 `18`，把 DoiteDPS 根和
  锚在其上方的资源栏整体上移 `32 UI`，并以确定性预览提出右侧四栏 `2×2` 组合。
- 用户随后明确“四栏组合按照这个执行”，并提供最新字体失败截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-55c36781-d3af-4ed9-a7b2-dbfeecb38360.png`，
  `657×291 RGB`，SHA-256
  `9858b619445fb03bd5c5c4637fa73fe9d6ee503511bb9688e3c6625c76c4c7e0`。此时游戏
  SavedVariables 已保存系统字体／`18`，但 Player 的 live 字形与大小仍明显错误，
  因而根因收敛为 provider `UpdateConfig` 后对实际 FontString 的重写，而非 profile
  字段未迁移。runtime-v2.3 直接设置三框实际文本对象并安装后置重施；同轮将已确认的
  四栏方案接入 sidebar runtime-v1.0，不改任何动作内容、按键或分页语义。
- 当前问题截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-0473244d-209c-468e-872c-a8d89b95bcc2.png`，
  `1000×619 RGB`，SHA-256
  `3e44c1bbb13f10a7fe8b0e19fb0ce06323d1277405b84b7399a3917093006325`。
  用户指出 Player 仍与消耗品框重叠、现有 Aura 一排不足八枚、Boss Debuff 第二排
  可能遮住施法条，并要求尽量保持相对位置。审计 `pfUI/api/unitframes.lua` 后确认
  当前 `default_border=3`、`force_blizz=0` 的实际 Aura 步进为
  `size + 1 + 2×border = size+7`，V9 的 `27 UI` 实际占
  `27 + 7×34 = 265 UI`，不是旧模拟误写的 `237 UI`。V10 因此只把 Aura 收为
  `23 UI`（八枚占 `233／240 UI`），单位族上移 `30 UI`，左右 Field Kit 底线共同
  下移 `20 UI`；计时栈、Combat Deck、姿态与 DoiteDPS 不动。确定性预览以
  Target `16` 个 Debuff 形成两排，第二排到 Player Cast 保留 `3 px` 净空。

- 最新实机截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-bfd7c410-0231-4541-839e-562b3b9e69a7.png`，
  `987×622 RGB`，SHA-256
  `4e120794180b52de0da90879225376fdb6ed58cc245c09104536cef009e35a5d`；以及
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-e68667eb-5db2-4652-b662-fb9982c852c7.png`，
  `997×579 RGB`，SHA-256
  `2352facf5be69b35ebe2acc8ea16f5d293d5889998661a9b6935b1307b543509`。
  用户指出五项问题：Cast 与 Swing 未对齐；单位框文字偏小；Aura 仍偏小且应每行
  正好 `8` 枚；Cast／Swing 应更细更长；TargetTarget 位于 Target 上方会与 Aura
  重叠，应改到右侧。V8 精确覆盖这五项，不修改任何美术资产。

- 最新实机截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-640fd020-caf5-4381-8446-3532cdc72d8b.png`，
  `1066×662 RGB`，SHA-256
  `d7fe7e341e40705d17b8343ced872415ceaa562ec557da39971a61c469c1c250`。
  用户指出七项问题：Player 仍压住消耗品；玩家 Aura 起点没有从最左侧增长；Cast／
  Swing 应上下而非左右；DoiteDPS 上下两排会压单位框；Target 应与 Player 同尺寸；
  TargetTarget 应与 Target 同尺寸；Aura 图标需要放大。V7 精确覆盖这七项，不修改
  任何美术资产。

- V4 实机失败截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-5b64e0c0-3266-4f55-8aa8-8c1438ba88e4.png`
  ，`1304×1121 RGB`、SHA-256
  `350607ed463d5b0898333d428711505c066ed6eebe48c0400a11ce31d7ad990d`。
- 用户明确指出三项失败：施法栏与攻击栏重叠；战斗框架与动作甲板之间出现大面积
  未利用区域；Player／Target 过大并遮住人物主体。截图同时确认动作条、Field Kit、
  Trinket 与 ArchiTotem 本轮不需要改尺寸。
- 根因是 V4 把 Player／Target、双方施法、Swing、姿态和 DoiteDPS 一并从
  `0.75` 放大到 `0.82`，又把双单位框内缘从 `80 px` 压到 `34 px`，并沿用固定
  反向校准坐标；单项尺寸虽接近合适，组合后的层序、人物净空和甲板相对位置失稳。
- V5 将尺寸与位置解耦：Player／Target 和双方施法回到 `0.75`；Swing、姿态与
  DoiteDPS 保持 `0.82`；恢复 `80 px` 人物中线通道，并把 DoiteDPS → 攻击计时 →
  Aura → 单位框 → 双施法 → 姿态收成甲板相对的紧凑纵栈。用户已明确确认该
  可见方向并授权 runtime 接入；模拟像素本身仍不是 runtime 资产。
- V5 runtime-v1.4 实机失败截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-01b315bd-3703-4af2-858b-1b8e07caaea4.png`
  ，`1402×1206 RGB`、SHA-256
  `ed81a6c97ed2a21068054d97f60163298395e2d756cae4b8b171796811e93dd9`。
  截图显示主栏过低、Player／Target 整组向右下散开、Swing 偏到中右、DoiteDPS
  脱离中央纵栈；用户明确报告“界面的位置错乱了”。
- 同轮只读审计当前角色 SavedVariables：`pfActionBarMain y=149`、Player
  `x=54,y=362`、Target `x=502,y=362`、Swing `x=277,y=143`、姿态
  `x=277,y=-465`、DoiteDPS `x=830,y=-152`。`Config.wtf` 仍为
  `1920×1080 / uiScale=0.711111`，证明错位由 adapter 写入，而非用户拖动。
- 根因有两层：`ResetCombatDeckPosition` 用固定为 `768` 高的
  `UIParent:GetHeight()` 直接乘物理比例；焦点投影又用
  `UIParent:GetWidth／Height × GetEffectiveScale()` 充当屏幕根，并把目标 provider
  local／effective scale 混入同一除法。v1.4 的现代客户端 smoke mock 会随
  `SetScale` 改写 UIParent 尺寸，因此没有复现 1.12 行为并误报通过。
- runtime-v1.5 改为读取 `GetScreenWidth／Height` 的 normalized UI root，以
  `GetScreenHeight()/1080` 把冻结的 V5 reference pixels 投到 root；随后在每个真实
  Frame 上先置零、再向屏内探测 `1 UI` SetPoint，直接测出该 Frame 的 scaled anchor
  换算，最后一次性写入 pfUI／DoiteDPS 坐标及当前角色签名。主栏 home 使用同一
  校准。测试环境现固定为 768-high root，不再随 UI scale 伪造 1920×1080 UIParent。
- V5 runtime-v1.5 实机失败截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-823cdfd0-476c-4080-abbe-bcf0615900a3.png`
  ，`2251×1440 RGB`、SHA-256
  `b49b4415e131a2889b93d5b971a31ddb372986a569957ea6d623db42bb71be1`。截图显示主动作
  条、Field Kit、单位框与战斗读数被推到中右侧并相互脱节；用户明确报告“更乱了”，
  并要求按游戏坐标摆放。
- 最新落盘 SavedVariables 记录 v1.5 写入主栏 `x=325,y=246`、Player
  `x=222,y=637`、Target `x=820,y=637`、双方施法 `y=585`、Swing
  `x=476,y=126`、DoiteDPS `x=1487,y=-424`。客户端模式仍为 `1920×1080`，证明
  v1.5 错把 `GetScreenWidth／Height` 返回的物理分辨率当作 SetPoint 根；随后又用
  provider effective scale 和一单位探针二次换算，故所有原生 offset 被再次平移。
- runtime-v1.6 删除整条 projection／probe／readback 路径，固定写入已由 1.12
  坐标模型与实值交叉确认的游戏坐标：主栏 `BOTTOM (0,175)`；Player／Target
  `BOTTOM (-212,492)／(213,492)`；双方施法 `BOTTOM (-212,454)／(213,454)`；
  Swing `CENTER (0,-67)`；姿态 `TOP (0,-919)`；DoiteDPS
  `TOPLEFT (1012,-647)`。显式 preset 首次执行前保存当前 profile；
  `/aeui focuslayout restore` 可恢复并提示 reload。
- 前一张 v1.2 实机截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-66323032-06ec-4a4d-bdfc-17358a2453e9.png`
  ，`1443×1067 RGB`、SHA-256
  `3c4eeee293c6eb2b2b140a94bab2542834acc4ff8a8b8529e9e9a2aa6a26dc9a`。
- v1.2 已证明 Player／Target 不再覆盖左侧卷袋，但用户明确判定当前战斗核心
  “有点太小”。因此 v1.2 只保留为可回退的 P5 runtime，不进入 P6。
- 截图中的底部独立六按钮＋拖动球对象来自已安装的 `ArchiTotem 1.7`；用户口述
  “atomchi”按真实目录、TOC 与全局 Frame 校正为该 provider，不据名称另造控件。
- V4 的缩放裁决 `0.75 → 0.82` 为线性 `+9.33%`、面积约 `+19.54%`；新实机
  证据否决的是统一缩放后的组合几何，不是否决攻击计时／DoiteDPS 的可读尺寸。
  因而 V5 不进入 `0.85–0.86`，也不把整组重新缩小。

## 组件合同

- 组件只覆盖已登记的 pfUI Player／Target／TargetTarget、玩家／目标 Castbar、
  SwingTimer、Bar 1／Bar 6、姿态栏，以及可选 DoiteDPS／ArchiTotem／AutoBar／
  TrinketMenu 的呈现连接；所有战斗数据、点击、Aura、施法、攻击计时与 provider
  行为继续由原对象负责。
- 所有新布局值写入 Turtle WoW 原生 `UIParent` 坐标；不读取屏幕物理分辨率、
  effective scale 或 Frame 回读值，不建立 `OnUpdate` 维护循环。仅 exact 旧合同
  自动迁移，手动调整的 profile 不覆盖；`restore` 必须恢复完整 pre-focus 配置。
- pfUI unlock 生命周期保持先创建 movable／`drag`，再隐藏绑定态冗余 mover；不得
  删除 Bar 6 或 TargetTarget 的 movable 登记。

### 真实 provider 审计

| 对象 | 真实来源 | 当前职责与边界 |
|---|---|---|
| `ArchiTotemFrame` | `Interface/AddOns/ArchiTotem/ArchiTotem.xml` | `280×80 UI` 初始根，Lua 按可见特殊按钮重算宽度；父框关闭鼠标，只有真实 Button 接收输入 |
| `ArchiTotemButton_Earth1／Fire1／Water1／Air1` | `ArchiTotem_ButtonTemplate`，每枚 `40×40 UI` | 四元素当前图腾；左键施放、右键跳过、悬停打开本元素真实候选 |
| 元素候选 | Earth／Fire／Water 各最多 `5`，Air 最多 `7` | 由 provider 按 `direction=up／down` 纵向展开；图标、顺序、倒计时和点击均不接管 |
| `ArchiTotemDragHandle` | 独立 `20×20 UI` Button | 左键拖动整个根、右键锁定、Shift+左键复位；handle 不随 `Apperance.scale` 缩放 |
| `ArchiTotemButton_AllTotems` | `40×40 UI` | 一键依次施放四元素；右键显示特殊按钮 |
| `ArchiTotemButton_Recall` | 可选 `40×40 UI` | provider 的召回与冷却；当前角色显示 |
| `ArchiTotemButton_PresetManager`／`ArchiTotemPresetFrame` | 可选 Button＋独立 `350×450 UI` 对话框 | 当前角色主栏按钮隐藏；管理对话框保持独立居中／拖动，不纳入战斗甲板强绑定 |

当前“大奶黑牛 - Basin of Stars”实值为 `scale="0.8"`、`direction="up"`、
`showrecallbutton=true`、`showpresetmanagerbutton=false`、`locked=false`。闭合可见
脚印按 provider 缩放后为四枚 `32 UI` 元素槽＋未缩放 `20 UI` handle＋一键与
召回两枚 `32 UI`，合计 `212×32 UI`；Air 最大展开态为 `212×224 UI`。provider
自身 `RecalculateWidth` 不计 handle，布局／命中审查必须使用真实可见 union，
不能只信根 Frame 宽度。

## 最终执行正文（无位图执行）

本轮不涉及 ImageGen，正式位图执行正文不适用。确定性实现正文为：在 AEUI
`0.8.21` 的 ActionBars adapter 内将 Player／Target 保持 `240×60 / 0.8`，
TargetTarget 保持 `240×60 / 0.68`，三框配置与 live FontString 改为客户端
`STANDARD_TEXT_FONT / OUTLINE / 18`，并在 unit `UpdateConfig` 后重施；
Aura 设为 `23 UI`、按真实 `size+7` 步进每行 `8`；Player／Target 写入
`BOTTOM (-160,485)／(105,485)`，TargetTarget fallback 写入 `BOTTOM (393,576)`，
并继续以 `LEFT → Target RIGHT +8 UI` 依附；
玩家 Cast／目标 Cast／Swing 设为 `260×12 / 1.0`，分别落在同一 `x=0` 中轴的
`y=316／300／284`，姿态保持 `0.72`；消耗品与饰品组共用 `-20 UI` 底部偏移；
DoiteDPS union 置于 `TOPLEFT (850,-615) / 0.82`。只迁移未被手动修改的 exact
v7–v11、仍完整匹配旧字形／字号的 v12，以及完整匹配上一版签名的 v13 profile 至
v14。Bar 2／4／5／3 以 `3×4` 四块组合为 `6×8` 右侧组，保留各自内容配置、备份
完整几何，并只暴露一个覆盖 union 的 mover；其余 provider、位图与交互合同不变。

## V4 runtime 与实机结论

### 已实机否决的战斗核心合同

- 全局 pfUI 继续保持 tier 8；不放大全屏、聊天、背包、小地图、Field Kit 或
  Combat Deck。
- 仅把 Player／Target、双方施法、主副手／远程攻击计时、姿态和 DoiteDPS 的
  local display compensation 从 `0.75` 改为 `0.82`，线性显示增加约 `9.3%`、
  面积增加约 `19.5%`。
- Player／Target 外侧总包络保持 V3／v1.2 宽度；两框中心内收，模拟内缘从
  `80 px` 变为 `34 px`，使增大的状态框不重新压住左卷袋。
- runtime 坐标采用反向校准，保持 v1.2 的物理基线：Player／Target
  `BOTTOM x=-153／153, y=613`；双施法 `x=-153／153, y=571`；Swing
  `CENTER y=-78`；姿态 `TOP y=-764`；DoiteDPS
  `TOPLEFT x=1012, y=-512, scale=0.82`。这些数值现由显式
  `/aeui focuslayout apply|comfort` 一次性写入当前角色 provider 配置。
- 左 `4×6` 消耗品卷袋、中央 `12×2` 动作条、右水平双饰品和 Bar 1 的位置／
  scale 完全保持，避免把“战斗信息偏小”错误修成整套 UI 再次遮挡视野。
- `2026-08-09` 新截图已否决以上单位框内收、统一 `0.82` 和固定坐标的组合；这些
  数值只描述当前可回退 runtime，不再作为下一版候选，也不得标记 game-validated。

### ArchiTotem 职业卫星栏

- 角色为萨满且 `ArchiTotemFrame` 存在时，把其真实可见脚印水平居中放在
  Bar 1／XP Rail 下方；不占 AutoBar 类别、不复制为 pfUI Action Button。
- 绑定态扩展现有 `fieldKitBound`：Bar 1 仍是唯一移动根；ArchiTotem 跟随，
  provider 拖动松手回到组合位。`unbind` 恢复首次捕获的自由锚点与原拖动。
- 显式 focus preset 才请求 provider `direction=down`，使候选从主栏向
  屏幕底部展开，不穿过动作格、施法条或单位框。普通 AEUI Apply／refresh 不写
  `ArchiTotem_Options`，用户以后手动改方向时以 provider 配置为准。
- 当前 `0.8` scale、四元素、一键、召回、拖动球、锁定、右键跳过、计时、预设、
  Tooltip 和施放顺序全部保持；预设管理对话框不绑定、不重绘。
- provider 缺失、非萨满、根隐藏或签名不匹配时不显示占位，不阻止 ActionBars
  其余 adapter。

## V5 已确认运行时合同

- 全局 pfUI tier 8、Combat Deck、Field Kit、Trinket 和 ArchiTotem 几何保持不变；
  本轮只重排 `AB.FOCUS.LAYOUT.V1` 的战斗信息栈。
- Player／Target 与对应施法条使用 local scale `0.75`；模拟显示框各
  `239×61 px`，两框外包络仍为 `[681,660,1239,721]`，内缘恢复为
  `[920,1000]` 之间 `80 px` 的人物通道。
- DoiteDPS 保持 `0.82`，显示区 `[819,540,1102,581]`；主／副手攻击计时同样
  保持 `0.82`，分别位于 `y=600–611` 与 `614–625`。攻击层底部到 Aura 顶部
  `8 px`，到施法层顶部 `104 px`，不再与施法条争用同一层。
- Aura 为 `y=633–652`，单位框为 `660–721`，双方施法条为 `729–749`，姿态条
  顶部为 `763`，主动作条顶部为 `827`。战斗信息相邻层最大空隙 `19 px`；姿态条
  距主动作条 `64 px`，既保留动作识别空间，也消除截图中的大块闲置区域。
- runtime-v1.4 原计划从 live Bar 1 投影上述参考关系，但实机证明它把
  `UIParent` 的 768-high Frame 尺寸与 provider effective scale 混为屏幕坐标，已
  改判 `game-geometry-failed`。runtime-v1.5 又把物理 `1920×1080` 屏幕返回值当作
  normalized root，并通过 provider scale、探针和回读二次换算，实机同样改判
  `game-geometry-failed`。runtime-v1.6 不再投影或测量，显式 preset 仅把冻结关系
  对应的游戏原生坐标一次性写入 pfUI／DoiteDPS；普通 refresh 不持续重写这些对象
  的 Parent、Point、Width 或 Height，只在完整 `game-native-v1` 坐标签名存在时
  恢复没有独立 movable 条目的副手 Swing `0.82` scale。
- 以上只定义几何方向；动态文字、图标、Aura、施法状态、Swing 进度、DoiteDPS
  推荐数据、单位框交互与 provider 行为全部保持真实运行时对象，不进入位图。

## V11 当前运行时合同

- V10 的全部游戏原生坐标、单位框尺寸／scale、Aura、计时纵栈、Field Kit 与
  Combat Deck 关系保持不变。
- Player／Target／TargetTarget 在各自 pfUI unit 配置中使用客户端
  `STANDARD_TEXT_FONT / OUTLINE / 18 UI`；并直接覆盖 live health／power
  FontString，Player 另覆盖 top-center 文本。每个 unit Frame 的 `UpdateConfig`
  结束后只重施这些字体，不维护其 Parent／Point／Width／Height；不改 pfUI 全局字体，
  `restore` 仍恢复 pre-focus 字体字段并暂停后置重施。
- DoiteDPS 根从 `TOPLEFT (850,-647)` 改为 `(850,-615)`，资源栏因其 provider 锚点
  `BOTTOMLEFT → root TOPLEFT (0,2)` 一起上移；内部 `318×46 + 178×22` 关系、scale
  `0.82`、锁定、显隐、Forecast、资源与冷却选项不变。
- exact v12 只有在三框仍为旧全局 unit face／style／`14 UI` 且全部 V10 几何精确
  匹配时才迁移；exact v13 只有完整匹配上一版系统字体／几何签名时才迁移。两者最终
  都一次升级为 v14；任意手动字体或坐标修改都保护 profile。
- 用户已确认右侧四栏组合：`Paging → Vertical → Left → Right` 对应
  Bar 2／4／5／3，并映射为 `2×2` 四块，每块 `3×4`、总体 `6×8`。初始 icon `20`、
  spacing `1`、scale `1.2`、块间 gap `6 UI`，目标显示脚印 `154×202 px`、右缘净空
  `28 px`。只有“大奶黑牛 - Basin of Stars”完整匹配旧 `1×12` 四列签名时自动绑定；
  首次绑定按角色备份 formfactor／icon／spacing／scale／position，`unbind` 精确恢复。
- 组合态仍保留四条 pfUI movable 登记，只把 Bar 2 drag 扩展为覆盖 union 的单一 mover，
  Bar 4／5／3 drag 在创建后隐藏；滚轮缩放和拖动同步四块，鼠标中键恢复组合 home。
  几何只在 Apply／UpdateConfig／unlock／拖动／缩放事件边界同步，无 `OnUpdate` 循环。
  每栏动作内容、按键、分页、显隐、autohide 与其他 provider 选项保持独立；命令为
  `/aeui sidebars bind|unbind|home|status`。

## V10 历史运行时合同

- 游戏原生坐标：主栏 `BOTTOM (0,175)`；Player／Target
  `BOTTOM (-160,485)／(105,485)`；TargetTarget fallback `BOTTOM (393,576)`；
  玩家施法、目标施法与 Swing 分别为 `BOTTOM (0,316)／(0,300)／(0,284)`；
  姿态 `BOTTOM (0,255)`；DoiteDPS `TOPLEFT (850,-647)`。不使用屏幕像素投影，
  也不读取 UIParent 尺寸。
- Player／Target 为 `240×60 UI / scale 0.8`，TargetTarget 保持
  `240×60 UI / scale 0.68`；三框只在各自 unit 配置中使用 `14` 号字体，不修改
  pfUI 全局字体。TargetTarget 运行时以
  `LEFT → Target RIGHT +8 UI` 依附，避免与 Target 上下 Aura 条带互相占位。
  未被手动调整的 exact v7／v8／v9／v10／v11 profile 一次性迁移为 v12；旧备份补齐
  TargetTarget 与局部字体原配置，`restore` 仍能恢复完整 pre-focus profile。
- Player Buff 在上、Debuff 在下，均从左向右；Target／TargetTarget Buff 在上、
  Debuff 在下，均从右向左。三框 Aura 大小统一为 `23 UI`、每行 `8`；按当前 pfUI
  `size + 1 + 2×border = size+7` 的真实步进，一行占 `233 UI`，在 `240 UI` 框宽内
  保留 `7 UI` 收边。Target 的 `16` 个 Boss Debuff 可形成两排且不进入施法条。
  真实 spell、层数、计时、过滤和 Tooltip 继续由 pfUI 负责。
- 玩家施法、目标施法与主手／ranged Swing 保持 `260×12 UI / scale 1.0`，
  以 `x=0` 同轴纵排；副手紧贴主手下方。V10 不移动计时栈。DoiteDPS 根与资源
  两排继续作为一个 union 退出单位框占位。
- Field Kit 左侧间距为 `12 UI`，TrinketMenu 右侧间距为 `8 UI`，ArchiTotem 垂直
  offset 为 `-39 UI`；消耗品与饰品底边共同比主栏低 `20 UI`。AutoBar 的三段文字
  不创建，旧 label Frame 若存在会被隐藏。
- pfUI unlock 仍先创建 Bar 6 与 TargetTarget 的 `drag`，AEUI 再隐藏绑定态独立 mover；
  不删除 movable 登记。unlock 退出后同一事件边界重施 Bar 6 → Bar 1 与
  TargetTarget → Target 锚，避免 `unlock.lua:527 drag=nil` 和坐标漂移；无 `OnUpdate`。

## V7 历史运行时合同

- 游戏原生坐标：主栏 `BOTTOM (0,175)`；Player／Target
  `BOTTOM (-150,535)／(190,535)`；TargetTarget fallback `BOTTOM (190,651)`；
  玩家／目标施法 `BOTTOM (-100,443)／(100,443)`；Swing `BOTTOM (0,421)`；
  姿态 `BOTTOM (0,255)`；DoiteDPS `TOPLEFT (850,-647)`。不再使用屏幕像素投影或
  读取 UIParent 尺寸。
- Player／Target／TargetTarget 统一为 `240×60 UI / scale 0.68`；TargetTarget
  运行时以 `BOTTOM → Target TOP +56 UI` 依附。v7／v8 profile 的旧备份会补齐
  TargetTarget 原配置／位置后迁移为 v9，`restore` 仍能恢复完整 pre-focus profile。
- Player Buff 在上、Debuff 在下，均从左向右；Target／TargetTarget Buff 在上、
  Debuff 在下，均从右向左。三框 Aura 大小统一为 `22 UI`，四个 Aura offset 明确
  置零，每行 `8`；真实 spell、层数、计时、过滤和 Tooltip 继续由 pfUI 负责。
- 玩家／目标施法统一为 `180×16 UI / scale 0.72` 上排；主手／ranged Swing 使用
  同尺寸下排，副手紧贴主手下方。DoiteDPS 根与资源两排作为一个 union 退出单位
  框占位；施法、攻击与监控互不重叠。
- Field Kit 左侧间距由 `48` 收为 `12 UI`，TrinketMenu 右侧间距由 `16` 收为
  `8 UI`，ArchiTotem 垂直 offset 由 `-47` 收为 `-39 UI`；AutoBar 的应急／增益／
  工具语义分隔保留，但三段文字不再创建，旧 label Frame 若存在会被隐藏。
- pfUI unlock 仍先创建 Bar 6 与 TargetTarget 的 `drag`，AEUI 再隐藏绑定态独立 mover；
  不删除 movable 登记。unlock 退出后同一事件边界重施 Bar 6 → Bar 1 与
  TargetTarget → Target 锚，避免 `unlock.lua:527 drag=nil` 和坐标漂移；无 `OnUpdate`。

## 执行记录

### 本地确定性模拟

- V11 specification：`tools/specs/action_bars_core_simulation_v11.json`，SHA
  `fbd169c9…d1d7`；scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V11/action_bars_core_sim_v11.png`，
  SHA `4586fa06…1d94`。layout report SHA `586d7602…e06e`，`68/68 pass`。
- V11 delta display contract SHA `5228f1cb…cdb6`，报告 SHA `bde30990…fcb0`，
  `3/3 pass`；focus runtime-v2.3 contract SHA `f7834b37…76f1`，报告 SHA
  `97475410…865d`，`12/12 pass`；sidebar runtime-v1.0 contract SHA
  `848d5f0c…9a79`，报告 SHA `71986166…b740`，`3/3 pass`；violations 均为 `0`。
- 当前 AEUI `0.8.21` entrypoints：ActionBars `24183cc3…d3e`、Bootstrap
  `08365cfc…659`、TOC `74c47c62…ce4`。四张既有 TGA 字节不变，ImageGen `0/0`。
- AEUI `0.8.21` fresh-checkout addon package `pass`、violations `0`、report
  `a6a4ec74…16b9`、runtime manifest records `49`、tracked addon files `547`，
  `build_required_on_target_device=false`；另一台设备无需构建或导出。
- 以下 V10 证据保留为上一轮历史基线：
- V10 specification：`tools/specs/action_bars_core_simulation_v10.json`，SHA
  `8b36dfb9…16d`；scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V10/action_bars_core_sim_v10.png`，
  SHA `54b0382d…5da6`。layout report SHA `957c9eea…18d2`，`60/60 pass`。
- V10 display contract SHA `bc771950…0ff3`，报告 SHA `2aba7a65…65d1`，
  `12/12 pass`；runtime-v2.1 contract SHA `1f7fafdf…ef4e`，报告 SHA
  `27234ae2…46d`，`12/12 pass`，violations 均为 `0`。
- 当前 AEUI `0.8.18` entrypoints：ActionBars `05a300e5…9b30`、Bootstrap
  `94bb20ed…291f`、TOC `aa9b2abc…9a16`。fresh-checkout package `pass`、violations
  `0`、report `a6a4ec74…16b9`、tracked addon files `547`、目标设备无需构建；
  四张既有 TGA 字节不变，ImageGen `0/0`。

- 以下 V9 证据保留为上一轮历史基线：
- V9 specification：`tools/specs/action_bars_core_simulation_v9.json`，SHA
  `7fe55794…fd33`；scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V9/action_bars_core_sim_v9.png`，
  SHA `fb2d286a…0443`。layout report SHA `2036f813…dd6`，`56/56 pass`。
- V9 display contract SHA `84829972…2b9f`，报告 SHA `408a97ec…1f4f`，
  `10/10 pass`；runtime-v2.0 contract SHA `24ca41fb…8b2c`，报告 SHA
  `6807d038…0753`，`10/10 pass`，violations 均为 `0`。
- 当时 AEUI `0.8.17` entrypoints：ActionBars `6cfc0ac9…0a22`、Bootstrap
  `833b2603…4abb`、TOC `438b3448…9215`；fresh-checkout package `pass`、violations
  `0`、report `a6a4ec74…16b9`、tracked addon files `547`、目标设备无需构建。

- 以下 V8 证据保留为上一轮历史基线：
- V8 specification：`tools/specs/action_bars_core_simulation_v8.json`，SHA
  `690487a4…ab2`；scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V8/action_bars_core_sim_v8.png`，
  SHA `d7c2b84f…4f3`。该 ignored 预览只验证布局，不是 source／runtime 资产。
- V8 layout report：同目录 `layout_report.json`，SHA `1ed657db…f0c`，
  `56/56 pass`、violations `0`；覆盖三框同尺寸与局部字号、TargetTarget 右侧依附、
  三条计时同轴、Aura `27 UI`／每行 `8` 枚／两种增长方向及全部净空。
- V8 display contract：`tools/specs/action_bars_core_simulation_v8_display_region.json`，
  SHA `d11d4f28…147`；同目录报告 SHA `c2b9f164…c85`，`9/9 pass`、violations `0`。
- runtime-v1.9 display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `09d973d2…78d`；ignored 报告
  `generated/actionbars/ACTION-BARS-CORE/runtime-v1.9/display-region-report.json`，SHA
  `42559f26…1de`，`9/9 pass`、violations `0`。
- 当前 entrypoints：ActionBars SHA `8ba6b1e9…00a1`、Bootstrap SHA
  `524ad593…37bf`、TOC SHA `18e09fa5…e9d`；四份 Action Bars runtime manifest
  已同步共享 adapter／入口哈希与 AEUI `0.8.16`，accepted TGA 与像素哈希不变。
- AEUI `0.8.16` fresh-checkout package validator：`status=pass`、violations `0`、
  runtime manifest records `49`、tracked addon files `547`、
  `build_required_on_target_device=false`；报告 SHA `a6a4ec74…16b9`。

- 以下 V7 证据保留为上一轮历史基线：
- V7 specification：`tools/specs/action_bars_core_simulation_v7.json`，SHA
  `6aeddc50…f764`；scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V7/action_bars_core_sim_v7.png`，
  SHA `be7d4c83…bdeb`。该 ignored 预览只验证本轮布局，不是 source／runtime 资产。
- V7 layout report：同目录 `layout-report.json`，SHA `a81b81fd…69c0`，
  `44/44 pass`、violations `0`；覆盖三框同尺寸、Aura 尺寸／方向／边缘起点、
  TargetTarget 上方依附、Cast→Swing 纵栈、DoiteDPS 双排 union 与全部净空。
- V7 display contract：`tools/specs/action_bars_core_simulation_v7_display_region.json`，
  SHA `7dbb841c…f8af`；同目录报告 SHA `e3342b03…d890`，`7/7 pass`、violations `0`。
- runtime-v1.8 display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `3e28fbc2…d9a4`；ignored 报告
  `generated/actionbars/ACTION-BARS-CORE/runtime-v1.8-display-region-report.json`，SHA
  `4195f373…f4db`，`8/8 pass`、violations `0`。
- 当前 entrypoints：ActionBars SHA `7bf1e74e…49a0`、Bootstrap SHA
  `300651cf…66af`、TOC SHA `5b297213…8cbd`；四份 Action Bars runtime manifest
  已同步共享 adapter／入口哈希与 AEUI `0.8.15`，accepted TGA 与像素哈希不变。
- AEUI `0.8.15` fresh-checkout package validator：`status=pass`、violations `0`、
  runtime manifest records `49`、tracked addon files `547`、
  `build_required_on_target_device=false`。

- renderer：`tools/render_action_bars_simulation.py`
- specification：`tools/specs/action_bars_core_simulation_v5.json`，SHA
  `790746a5…07cb2`
- display contract：
  `tools/specs/action_bars_core_simulation_v5_display_region.json`，SHA
  `70d1f4fa…9bbd`
- Python：`D:/Softwares/miniconda3/python.exe`，Python `3.13.5`
- 命令：

  ```text
  D:/Softwares/miniconda3/python.exe tools/render_action_bars_simulation.py tools/specs/action_bars_core_simulation_v5.json --repo-root . --layout-report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/layout-report.json
  D:/Softwares/miniconda3/python.exe .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_bars_core_simulation_v5_display_region.json --report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/display-region-report.json
  D:/Softwares/miniconda3/python.exe tests/action_focus_simulation_test.py
  ```

- scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/action_bars_core_sim_v5.png`，
  `1920×1080`，SHA `4ab387a5…8797`。
- layout report：同目录 `layout-report.json`，SHA `72636dd3…f345`，
  `59/59 pass`、violations `0`；覆盖人物净空左右边、`80 px` 通道、攻击到施法
  `104 px` 分层、相邻信息层最大 `19 px` 与 ArchiTotem 最大向下展开。
- display report：同目录 `display-region-report.json`，SHA
  `ec5fecae…2ea1`，`8/8 pass`、violations `0`；新增独立的 Player／Target、
  双施法、Swing、DoiteDPS 场景，保留 ArchiTotem 四态。
- 回归测试 `tests/action_focus_simulation_test.py` pass。测试锁定 split scale
  `0.75／0.82`、单位框内缘 `80 px`、人物通道边界、`59` 项布局检查与 `8` 个
  display 场景。
- V5 runtime-v1.6 最终 display contract 为
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `405500e2…9ead`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.6/display-region-report.json`，
  SHA `999a7063…2d9d`，`8/8 pass`、violations `0`。场景覆盖单位框、双方施法、
  Swing、DoiteDPS 与 ArchiTotem 四态；`final_runtime=true`，并登记 v1.4／v1.5
  两次实机坐标失败及 `game-native-v1` 修复。
- runtime entrypoints 已升级为 AEUI `0.8.12`：
  `addon/AzerothExpeditionUI/Modules/ActionBars.lua` SHA `30af188e…b38a`，
  `Core/Bootstrap.lua` SHA `86e34d2c…af9e`，TOC SHA `a6441513…fec`。
  四份既有 Action Bars runtime manifest 只同步共享 adapter／bootstrap／TOC 哈希和
  addon 版本；所有 P6 Action Slot／Rail 与 P5 Field Kit 像素、导出合同和 provider
  行为保持不变。三个确定性 exporter 同时改为从 TOC 读取 addon 版本，并在重导出
  时保留已有 P6 evidence，避免 Slot／Rail 被错误降级。部署目录仍为
  `addon/AzerothExpeditionUI` 与必需的 `addon/pfUI`；ArchiTotem `1.7` 是可选
  provider，缺失时 fail-open。
- V5 runtime-v1.6 fresh-checkout package：
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.6/addon-package-report.json`，
  SHA `a6a4ec74…16b9`，`status=pass`、violations `0`、
  `build_required_on_target_device=false`。目标设备只需拉取并安装 tracked addon，
  不需要 Python、exporter、补丁或再改 Lua。
- 静态回归已通过：`tests/action_focus_layout_module_smoke.lua`、
  `tests/action_sidebars_group_module_smoke.lua`、
  `tests/action_focus_simulation_test.py`、`tests/repository_contract_test.py`、
  `tests/action_sidebars_group_runtime_test.py`、
  `tests/actionbars_runtime_test.py`、`tests/action_rail_runtime_test.py`、
  `tests/actionbars_module_smoke.lua`、`tests/action_fieldkit_module_smoke.lua` 与
  `tests/action_fieldkit_runtime_test.py`。Lua smoke 验证 split scale、原生固定坐标、
  对 `GetScreenWidth／Height` 零调用、10/10 配置／live 对象、19 个 live FontString、
  provider refresh 后置重施、pre-apply profile 恢复、DoiteDPS 非布局配置保留、
  ArchiTotem 绑定／解绑／方向及缺省无 Alpha 写入；sidebar smoke 覆盖 exact 自动
  迁移、单 mover、内容保留、同步拖动／缩放、home、可逆恢复、逐角色隔离和无效
  12 格签名的零写入失败；Field Kit 联合悬停与强绑定回归保持通过。
- 本次只读取用户截图和已由游戏落盘的 SavedVariables 作为失败证据，没有上传、
  变换或写回它们；没有调用 ImageGen，计数保持 `0/0`，也没有新增或修改位图
  source／runtime atlas。本机未加载游戏。`generated/` 模拟像素和验证报告继续是 ignored 证据，
  不能切片、晋级、上传或作为以后生产输入。

## 审查记录

- 范围／身份：pass。V11 只修改已审计的三框 live 字体、DoiteDPS 根坐标与用户已
  确认的 Bar 2／4／5／3 几何组合。没有制造单位状态、Aura、动作、倒计时或推荐数据。
- 几何／展示区：layout `68/68`、simulation display `3/3`、focus runtime display
  `12/12`、sidebar runtime display `3/3` 均 pass，violations `0`。DoiteDPS 两排
  union 到 Player Buff 的确定性预览净空由 `22 px` 增为 `51 px`；四栏 runtime
  脚印为 `154×202 px`、右缘净空 `28 px`。
- 综合色与视线：pass for user review。三框几何不变，仅以系统字体角色和更大字号
  提升读数；右侧四栏由高 `4×12` 视觉墙压为均衡 `6×8` 组合。
- 交互：static pass / game pending。Lua smoke 覆盖 exact v7–v13→v14 迁移、
  live FontString 与 provider refresh 后置重施、字体／坐标手动调整保护、旧备份补齐、
  TargetTarget 右侧相对锚、Aura
  方向／offset／大小、同轴纵向等尺寸读数、
  Bar 6／TargetTarget mover 生命周期、四栏 exact 绑定／单 mover／同步拖动缩放／home／
  可逆 unbind、`restore` 与 provider 缺失 fail-open；仍需 Turtle WoW 实机确认后才能
  进入 P6。
- 美术：未改任何 source／TGA；本地预览只是确定性布局证据，不能晋级为资产。

## 尝试摘要

| 版本 | 证据与结果 | 结论／后续 |
|---|---|---|
| `ACTION-BARS-CORE-SIM-V11 / focus runtime-v2.3 / sidebar runtime-v1.0` | “大奶黑牛”DDPS／Player Buff 风险、live 系统字体修正与用户确认的四侧栏组合；layout `68/68`、simulation display `3/3`、focus runtime display `12/12`、sidebar runtime display `3/3`、两组 Lua smoke pass；ImageGen `0/0` | 当前 `P5 / pending-game-validation`；字体后置重施、DDPS 与四栏组合均已接入，等待目标客户端实机验证 |
| `ACTION-BARS-CORE-SIM-V10 / runtime-v2.1` | “大奶黑牛”三项重叠问题；Aura 真实步进修正、16 Debuff 双排、两侧共下移；layout `60/60`、simulation display `12/12`、runtime display `12/12`、Lua smoke pass；ImageGen `0/0` | 历史基线；V11 保留全部 V10 几何，只改字体与 DDPS 安全区 |
| `ACTION-BARS-CORE-SIM-V9 / runtime-v2.0` | “大奶黑牛”舒适缩放与精简 AutoBar；layout `56/56`、simulation display `10/10`、runtime display `10/10`、Lua 与仓库合同 pass；ImageGen `0/0` | 历史基线；V10 修正其错误的 Aura 步进假设并保留尺度与中央计时栈 |
| `ACTION-BARS-CORE-SIM-V8 / runtime-v1.9` | 用户两张实机失败证据；layout `56/56`、simulation display `9/9`、runtime display `9/9`、Lua 与仓库合同 pass；ImageGen `0/0` | 历史基线；由 V9 接续，保留局部字体、Aura 八枚满行、TargetTarget 右侧依附与同轴计时栈 |
| `ACTION-BARS-CORE-SIM-V7 / runtime-v1.8` | layout `44/44`、simulation display `7/7`、runtime display `8/8`；实机指出五项后续问题 | 历史基线；由 V8 接续，不回退其卷袋净空、三框同尺寸、Aura 方向及 unlock 修复 |
| `runtime-v1.4 / runtime-v1.5` | 两次实机坐标错乱 | `game-geometry-failed`；禁止恢复屏幕像素投影／探针／回读路径 |

## 下一门禁

在目标 Turtle WoW `/reload` 后，未被手动调整的 exact v7–v11 游戏坐标 profile、
仍完整匹配旧全局 unit face／`14 UI` 的 exact v12 profile，以及完整匹配上一版系统
字体／几何签名的 exact v13 profile 会一次性迁移为 v14；无需先执行命令。确认状态
包含 `version 0.8.21`、`focus-layout-contract=2.3`、
`sidebar-group-contract=1.0`、`sidebar-group-binding=bound`、
`focus-layout-anchor=ui-parent+target-dependent`、
`focus-layout-coordinate-space=game-native-v1`、
`focus-layout-unit-scale=0.8`、`focus-layout-targettarget-scale=0.68`、
`focus-layout-unit-font-size=18`、`focus-layout-unit-font=system`、
`focus-layout-readout-scale=1`、
`focus-layout-stance-scale=0.72`、`focus-layout-unit-font-live=19`、
`fieldkit-contract=2.1` 与 `fieldkit-binding=bound`。先开关一次 pfUI unlock，确认无
`unlock.lua:527`、中央组合只有 Bar 1 mover、右侧组合只有一个 Bar 2 group mover、
Bar 6 不跳位且 TargetTarget 始终贴在 Target 右侧。随后确认：
Player 与共同下移 `20 UI` 的卷袋／饰品组不再相交；Player／Target 比 TargetTarget
大一阶；三段卷袋文字消失；玩家 Buff 上／Debuff 下并从完整左缘起排；
Target／TargetTarget Buff 上／Debuff 下且从右缘起排；Aura 为 `23 UI`，真实每行
刚好 `8` 枚，Target `16` 个 Boss Debuff 换成两排后仍不压 Player Cast；三框均为
系统字形、字号明显变大且长名字不破坏读数；玩家 Cast、目标 Cast 与 Swing 同轴
从上到下排列且均为 `260×12`；DoiteDPS 上下两排随根一起上移 `32 UI`，不压
Player Buff；
Field Kit、动作条、饰品、单位框、姿态与 ArchiTotem 形成紧凑组合。再覆盖满血／
掉血、有／无目标、双方施法、近战双持、远程计时、Aura `8／9／16`、DoiteDPS
锁定／解锁，以及
ArchiTotem 施放、右键、Air 七层、拖动／锁定、Recall、`unbind／bind` 和 fail-open。
再确认右侧 48 个原动作按 `Paging／Vertical／Left／Right` 保持在四个 `3×4` 分区，
内容／按键／分页／显隐不变；拖动和滚轮缩放四块同步，中键 `home` 回到接受位置，
`/aeui sidebars unbind` 精确恢复旧四列，随后 `bind／home` 可逆返回组合态。
若需要回退，执行 `/aeui focuslayout restore` 后 `/reload`；若仍有偏差，使用新的
实机截图只修订上述游戏原生坐标，不再引入屏幕像素投影，不进入位图重绘，
ImageGen 继续保持 `0/0`。
