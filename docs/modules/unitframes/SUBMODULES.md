# Unit Frames 子模块与 pfUI 对齐

本模块严格对应 `addon/pfUI/api/unitframes.lua` 创建的真实对象。当前运行时接管
静态媒体及其挂载，并通过 `UF.PORTRAIT.DISABLE` 关闭所有 pfUI UnitFrame 动态
头像呈现；不改变 Frame 锚点、尺寸、事件、点击、单位数据或状态逻辑。头像合同
只写入下文列出的精确配置值，原值保存在 AEUI SavedVariables 中并可完整回退；
其他 pfUI SavedVariables 不变。

## 主单位框与资源条批次

Unit Frames runtime `1.2` 会把全部 13 组真实配置强制为 `portrait = off`。下列逻辑尺寸来自
`addon/pfUI/env/profiles.lua` 与 `pfUI.uf:UpdateFrameSize()`；外壳只在真实 Frame
外增加不参与命中的透明装饰边，不改变 provider 几何。

| 组件 ID | pfUI 对象 | 动态内容区 | 资源外接尺寸 | 状态／所有权 |
|---|---|---:|---:|---|
| `UF.PLAYER.SHELL` | `pfUI.uf.player`／`pfPlayer` | HP `200×25`；Power `200×4` | `214×42` | 一张静态外壳；玩家与目标不得镜像复用 |
| `UF.TARGET.SHELL` | `pfUI.uf.target`／`pfTarget` | HP `200×25`；Power `200×4` | `214×42` | 一张静态外壳；不得烘焙目标类型、名称或等级 |
| `UF.TARGETTARGET.SHELL` | `pfUI.uf.targettarget`／`pfTargetTarget` | HP `100×20`；Power `100×1` | `112×34` | 一张简化静态外壳 |
| `UF.FOCUS.SHELL` | `pfUI.uf.focus`／`pfFocus` | HP `100×25`；Power `100×1` | `112×39` | 一张静态外壳；靛蓝猎踪布结是焦点识别件 |
| `UF.BAR.HEALTH.FILL` | 每个对象的 `f.hp.bar` | provider 裁切宽度 | `64×32` 可横向拉伸纹理 | 无色灰阶颜料纹；继续由 pfUI 着色与更新数值 |
| `UF.BAR.POWER.FILL` | 每个对象的 `f.power.bar` | provider 裁切宽度 | `64×16` 可横向拉伸纹理 | 无色灰阶窄颜料纹；继续由 pfUI 按资源类型着色 |
| `UF.STATE.HOVER.RIM` | `f.hoverglow` | 外壳边缘 | 由每张接受外壳 Alpha 确定性派生 | 暖白短边响应；不改变命中盒 |
| `UF.STATE.AGGRO.RIM` | `f.glow` | 外壳边缘 | 由每张接受外壳 Alpha 确定性派生 | 暗红／橙褐短边响应；继续使用 pfUI 状态逻辑 |

## Raid 团队框架批次

`addon/pfUI/modules/raid.lua` 当前创建 `pfRaid1..pfRaid40` 共 40 个独立 Secure
Button；它不是一张整团背景。仓库 profile 的每个 Button 为 `70×33`，其中
Health `70×30`、Power `70×2`、间隔 `1px`，以 `10×4 / VERTICAL`、pitch
`77×40` 排列。包含外扩和 Raid Icon 的完整视觉包络为 `767×159`。

| 组件 ID | pfUI 对象 | 数量／尺寸 | 稳定边界 |
|---|---|---:|---|
| `UF.RAID.MEMBER.SHELL.A-D` | `pfRaid1..40` 背景层 | 4 个 source 变体／40 次重复；标准 `74×37` | 只在真实 Button 外扩 `2px`；不增加整团外框，不接管鼠标 |
| `UF.RAID.BAR.HEALTH.FILL` | 每个 `f.hp.bar` | 40；显示 `70×30` | 可在新合同接受后复用现有灰阶 Health donor；数值／颜色／裁切归 pfUI |
| `UF.RAID.BAR.POWER.FILL` | 每个 `f.power.bar` | 40；显示 `70×2` | 可复用现有 Power donor；资源语义色归 pfUI |
| `UF.RAID.STATE.RIM` | `f.hoverglow`／`f.glow` 的视觉替代层 | 每框按需 | 从接受外壳确定性派生断续边缘；不形成完整矩形 glow |
| `UF.RAID.STATE.PIP` | `f.combat` | 每框最多 1 | 小型破颜料角标；状态判定归 pfUI |
| `UF.RAID.AURA.RIM` | `f.hp.bar.icon[]`／`debuffindicators` | 每框最多 6＋驱散图标 | 只提供 1px 暗色承托；图标、层数、冷却和 Tooltip 保持动态 |
| `UF.RAID.GROUP.LABEL.BACKING` | slots `1,6,...,36` 的 `f.group` | 最多 8；当前隐藏 | 已登记但 production 暂停；动态 `Group N` FontString 不烘焙 |

四个外壳变体按 `pfRaid` 槽位固定分配，Roster 换人不改变外观。整体 UI Scale
随 Parent 同步缩放；宽度变化可由接受完整 source 确定性派生横向三切片。当前
合同冻结 provider 高度 `33px`；Height 偏离时局部回退 pfUI，不强拉资源。

`UF-RAID-A2` 已把生成与工程职责进一步分离：ImageGen 只提供一张开发期材质
donor，且 donor 永远不是 source、runtime 或 addon 资产；
`tools/build_unitframes_raid_donor_shells_v1.py` 从四个固定 sample window 取材，
确定性构造四张逻辑粒度不变的完整 `UF.RAID.MEMBER.SHELL.A-D` source。外轮廓、
Alpha、`592×296 → 74×37`、provider inset、`48/496/48 → 6/62/6` 三切片以及
A/B/C/D 四种维修 mask 全部归 builder，不再要求模型像素级定位。由此改变的是
资产生产方式，不是游戏对象粒度；最终仍是四张完整外壳供 40 个真实 Button
按槽位重复，不能把 donor 或整团预演图挂入游戏。accepted source 只持久化
四个固定 sample window，未消费
外围 field bbox 像素仍被排除；四张 source 和四张独立 TGA 由 manifest 固定。

Leader／Master Looter／Raid Target／Resurrection、Buff／Debuff、Incoming Heal、
名称、离线／距离 Alpha、仇恨与战斗状态继续由 pfUI 动态提供，不得烘焙。Party
框架在 `modules/group.lua`，Raid Marker 血条列表在 `modules/raidmarkers.lua`，
二者都不是 `UF.RAID.*`。

## UF-PRIMARY V4 已接受 source 与待导出 runtime

用户于 `2026-08-12` 要求重开 Player／Target 完整外壳的新生产架构，并已确认
`UF-PRIMARY-V4-SIM-V1` 与 Raid A2 sample 的只读输入职责。用户随后以“确认,
进入下一阶段”接受 `UF-PRIMARY-V4-CANDIDATE-V1` 两张 exact candidate；当前为
`P4 / source-accepted`，但尚未导出 runtime 或接入 addon。以下定义真实对象、
已接受 source 与未来 P5 职责。

- 最终组件粒度不变：`UF.PLAYER.SHELL` 与 `UF.TARGET.SHELL` 各自是一张独立
  完整 `1284×252 RGBA` source 和一张完整 `214×42` runtime。不得两角色合图、
  镜像、逐端帽生成或把多张生成图拼成一个逻辑壳。
- ImageGen 不拥有外轮廓、开口、Alpha、safe area、端部厚度、维修位置或切片
  几何。首选路径直接复用已接受 Raid A2 leather／liner／brass／thread material
  sample；确定性 builder 从这些 immutable input 构造两张完整外壳。sample
  本身永远不是游戏组件，Lua 只加载最终两张完整 runtime。
- provider live bed 固定 source `x42..1242/y36..216`、runtime
  `x7..207/y6..36`。liner 可在 bar 下方；皮革 relief、金属、线、铆钉和状态
  边不得盖住 live bed。名字、数值、状态色、Aura、事件、点击和 SavedVariables
  全部仍由 pfUI 提供。
- 标准 `W=200` 使用一张完整 `214×42` Texture，内部接缝 `0`。宽度变化时从
  同一角色 source 派生 `32/150/32` 横向三切片；固定区允许身份沿顶／底外缘
  展开，但不得侵入动态区。高度固定 `42`，只允许整体 UI Scale。
- Player 的重修补位于左上外围；Target 的损伤位于右下外围，同族但非镜像。
  Hover／Aggro 从接受 Alpha 确定性派生断续短边，不单独生成。
- 接受 source 分别为
  `assets/source/unitframes/primary-v4/UnitFramePlayerShell_MasterV1.png`
  SHA `331b353f…617b` 与
  `assets/source/unitframes/primary-v4/UnitFrameTargetShell_MasterV1.png`
  SHA `256086c1…f81`；manifest 为同目录
  `UF-PRIMARY-V4_SourceManifest_v1.json`。source 不能被 Lua 直接加载。
- 若已接受 material sample 在主框尺度上经透明 candidate 审查证明不合适，
  才能另开 primary-specific material-only donor；当前备用段未授权，不能调用。

## UF-A1 V3 历史完整外壳 source → runtime 合同

用户于 `2026-08-11` 接受从“四端帽 atlas”改为“每个逻辑角色生成一张完整
外壳，并由 Python 负责精确工程化”的 V3 架构。该决定冻结生产粒度与后处理
职责；用户随后于同日确认 `UF-PRIMARY-V3-SIM-V1` 的完整外壳粗犷方向、
Player／Target 非镜像身份、Health／Power 层级和四资源乘色，只接受文字化
方向，不接受任何模拟像素。

- Player 与 Target 各自使用一次独立 ImageGen 调用生成一张完整空外壳；不得
  把两个角色放入同一 production atlas，也不得把一张外壳镜像成另一张。
- 默认内容宽度 `W=200` 时，运行时直接使用该角色完整 `214×42` RGBA shell；
  内部 Texture 接缝为 `0`。
- 只有 `W≠200` 时，确定性 builder 才从同一完整 source 派生三切片：固定
  左端 `7×42`、中央 `200×42`、固定右端 `7×42`。中央带在左右装饰角各伸入
  端帽下方 `1 logical px`；重叠不得进入 `x 7..W+7 / y 6..36` 内容／交互
  安全区。派生切片不是新的视觉 source。
- 所有物理切片从同一逻辑原点取整；装饰盒向外取整，安全区向内取整。runtime
  atlas 至少保留 `2px` padding，中央带端点做 `1px` extrusion；关键识别细节
  不得只依赖单个 runtime 像素。
- UF-A1 逻辑高度固定为 `42`，禁止纵向拉伸；若 provider 需要其他逻辑高度，
  必须建立独立组件规格。整体 UI Scale 可以统一缩放最终 Frame／Texture，
  不能把完整外壳拆成多张无重叠 Texture 直接挂载。

### 确定性后处理边界

- 模型只负责完整物件的粗犷轮廓、材料、磨损和非镜像身份；像素精度由 macOS
  `py312` 下的确定性 pipeline 负责。
- pipeline 只允许边缘连通色键、中央孔连通色键、绿溢色清理、透明 RGB 清零、
  connected-component bbox 提取、完整外壳归一化、固定安全区清理、三切片
  派生、缩放预演和真实排版。
- 候选外 bbox 相对 `214:42` 的纵横比误差不得超过 `8%`；独立 X／Y 归一化的
  各向异性也不得超过 `8%`，必须记录缩放因子。超过阈值必须重新生成。
- Python 不得补画缺失皮革、移动铆钉、复制修补、改变拓扑或凭空生成美术。
  进入动态安全区的结构性不透明物超过 `1 runtime px` 时必须退回；固定 mask
  只清理边缘抗锯齿／色键残留，不能挽救错误解剖。

逻辑 Frame 的高度仍由 provider 公式
`height + pspace * GetPerfectPixel() + pheight + 2 * border` 计算。外壳锚到最终
Frame 中心；透明外扩不能参与 Frame 宽高、点击区域或移动边界。

## 保留为运行时动态内容

- `hpLeftText`、`hpCenterText`、`hpRightText`、三处 Power 文本；
- `combat`、`ressIcon`、`leaderIcon`、`lootIcon`、`pvpIcon`、`raidIcon`、
  `restIcon`、命中反馈与治疗预测；
- Buff／Debuff 图标、层数、冷却、Tooltip 和右键取消；
- 生命／能量颜色、离线／距离 Alpha、仇恨／战斗／悬停状态；
- 整个真实 UnitFrame Button、点击施法、安全模板、拖动和配置行为。

这些内容不得烘焙进外壳或条纹源资产。

## 生命与 Power 材质合同

- `f.hp.bar` 继续由 `bartexture` 指向 `UF.BAR.HEALTH.FILL`，`f.power.bar` 继续
  由 `pbartexture` 指向 `UF.BAR.POWER.FILL`；不改变 `CreateStatusBar`、动画、
  裁切、数值或背景逻辑。
- 两张填充纹都是中性灰阶、完全不含状态色。`SetStatusBarColor` 继续负责生命
  颜色；`UnitPowerType` 的 `0/1/2/3` 继续分别使用 pfUI 的 Mana／Rage／Focus／
  Energy 经典配色。因此法力、怒气、集中值、能量及同等资源共享 Power 材质，
  但保留游戏语义色。
- Health runtime donor 为 `64×32`，Power 为 `64×16`；二者可被 StatusBar
  横向缩放和按当前值改变显示宽度。不得烘焙端帽、数值、色相、中心热点、
  斜纹或玻璃高光。

### `UF-B1 V2` 已接受 source 与运行时映射

- Health accepted source
  为 `assets/source/unitframes/bars-v2/UnitFrameHealthFill_Master_v1.png`，
  SHA-256 `8d19ffe9…08e1f`；Power exact source 为同目录
  `UnitFramePowerFill_Master_v1.png`，SHA-256 `0668eddb…87f1`。
- `tools/build_unitframes_bars_v2_runtime.py` 只执行整图 LANCZOS 缩放、透明 RGB
  清零和无损 32-bit RGBA TGA 写入，分别导出
  `UnitFrameHealthFillV1.tga`（`64×32`）与 `UnitFramePowerFillV1.tga`
  （`64×16`）；不裁切、不重画、不混入外框像素。
- B1 媒体接管只给 `player`、`target`、`targettarget`、`focus` 写入两项媒体
  marker；pfUI 的 `api/unitframes.lua` 在既有 StatusBar 创建点读取 marker。
  Party、Raid、Pet、FocusTarget 与 fallback 继续使用各自 pfUI 配置媒体。
- 禁用模块或作用域路由时，adapter 通过各 Frame 的 `bartexture`／
  `pbartexture` 恢复 pfUI 媒体。不得改动 `SetStatusBarColor`、Frame 几何、
  数值动画、事件、点击区域、文字或图标。

## 已登记但不在当前批次

| pfUI 配置／对象 | 后续逻辑 ID | 当前处理 |
|---|---|---|
| `focustarget` | `UF.FOCUSTARGET.*` | 暂缓；继续 pfUI 默认视觉 |
| `pet`／`ptarget` | `UF.PET.*`／`UF.PETTARGET.*` | 暂缓 |
| `tttarget` | `UF.TARGETTARGETTARGET.*` | 暂缓 |
| `group`／`grouptarget`／`grouppet` | `UF.PARTY.*` | 暂缓；后续按真实重复数量设计 |
| `raid` | `UF.RAID.*` | `P5 source-accepted / runtime-exported / addon-integrated`；A2 使用 material-only donor＋Python 精确造壳，四张独立 `74×37` TGA 服务 40 个真实对象；待 Turtle WoW 实机 |
| `fallback` | `UF.FALLBACK.*` | 保持 pfUI 回退 |
| `player`／`target`／`focus`／`focustarget`／`group`／`grouptarget`／`grouppet`／`raid`／`ttarget`／`pet`／`ptarget`／`fallback`／`tttarget` 的 `portrait` | `UF.PORTRAIT.DISABLE` | runtime `1.2 / P5` 统一写为 `off`；不制作假头像槽，不运行 2D／3D 动态头像 |
| `raidmarkershowportrait` | `UF.PORTRAIT.TRACKER.DISABLE` | 同时关闭 `raidmarkers` 与 `marktracking` 两套追踪头像，并收回头像占用宽度 |
| Buff／Debuff Buttons | `UF.AURA.*` | 当前不重绘 |

`UF.PORTRAIT.DISABLE` 只使用 scoped route `unitframes.dynamic-portraits`。原始 13 组
`portrait` 值与 `raidmarkershowportrait` 按 pfUI profile 保存在
`AzerothExpeditionUIDB.unitframes.portraitConfigBackups[profile]`；pfUI 配置页应用期间若用户
选择新值，该值会成为之后的回退值，但本模块启用时仍保持 `off`。关闭
`/aeui unitframes` 或关闭该 route 后恢复原值、live Frame 与两套追踪布局。
`CharacterFrame`、`InspectFrame`、`DressUpFrame` 的角色预览模型不属于 UnitFrame
动态头像，本合同不接管。

## 接入边界

Unit Frames P5 只允许在 `addon/AzerothExpeditionUI` 的作用域 adapter 或
`addon/pfUI/api/unitframes.lua` 的精确挂点内实现。不得修改 Frame 的 Point、
Width、Height、事件、点击、Secure 模板或状态语义；配置写入只允许上述 13 组
`portrait` 与 `raidmarkershowportrait`，并必须可逆。媒体或 route 缺失时局部回退
pfUI 原始 portrait／backdrop／bar／glow。
