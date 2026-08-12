# Unit Frames 子模块与 pfUI 对齐

本模块严格对应 `addon/pfUI/api/unitframes.lua` 创建的真实对象。当前批次只替换
静态媒体及其挂载，不改变另一台设备上的 Frame 锚点、尺寸、事件、点击、
SavedVariables、单位数据或状态逻辑。

## 主单位框与资源条批次

当前 profile 使用 `portrait = off`。下列逻辑尺寸来自
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

Leader／Master Looter／Raid Target／Resurrection、Buff／Debuff、Incoming Heal、
名称、离线／距离 Alpha、仇恨与战斗状态继续由 pfUI 动态提供，不得烘焙。Party
框架在 `modules/group.lua`，Raid Marker 血条列表在 `modules/raidmarkers.lua`，
二者都不是 `UF.RAID.*`。

## UF-A1 V3 完整外壳 source → runtime 合同

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

- 用户于 `2026-08-11` 接受 B1 attempt 3 的运行时视觉。Health exact source
  为 `assets/source/unitframes/bars-v2/UnitFrameHealthFill_Master_v1.png`，
  SHA-256 `8d19ffe9…08e1f`；Power exact source 为同目录
  `UnitFramePowerFill_Master_v1.png`，SHA-256 `0668eddb…87f1`。
- `tools/build_unitframes_bars_v2_runtime.py` 只执行整图 LANCZOS 缩放、透明 RGB
  清零和无损 32-bit RGBA TGA 写入，分别导出
  `UnitFrameHealthFillV1.tga`（`64×32`）与 `UnitFramePowerFillV1.tga`
  （`64×16`）；不裁切、不重画、不混入外框像素。
- AEUI adapter 只给 `player`、`target`、`targettarget`、`focus` 写入两项媒体
  marker；pfUI 的 `api/unitframes.lua` 在既有 StatusBar 创建点读取 marker。
  Party、Raid、Pet、FocusTarget 与 fallback 继续使用各自 pfUI 配置媒体。
- 禁用模块或作用域路由时，adapter 通过各 Frame 的 `bartexture`／
  `pbartexture` 恢复 pfUI 媒体。不得改动 `SetStatusBarColor`、Frame 几何、
  数值动画、事件、点击区域、文字、图标或 SavedVariables。

## 已登记但不在当前批次

| pfUI 配置／对象 | 后续逻辑 ID | 当前处理 |
|---|---|---|
| `focustarget` | `UF.FOCUSTARGET.*` | 暂缓；继续 pfUI 默认视觉 |
| `pet`／`ptarget` | `UF.PET.*`／`UF.PETTARGET.*` | 暂缓 |
| `tttarget` | `UF.TARGETTARGETTARGET.*` | 暂缓 |
| `group`／`grouptarget`／`grouppet` | `UF.PARTY.*` | 暂缓；后续按真实重复数量设计 |
| `raid` | `UF.RAID.*` | 已启动 `UF-RAID-SIM-V1 / P2`；40 个真实对象，不从主单位框缩放复制 |
| `fallback` | `UF.FALLBACK.*` | 保持 pfUI 回退 |
| `portrait = bar/left/right` | `UF.PORTRAIT.*` | 当前 profile 为 `off`；未取得新合同前不制作假头像槽 |
| Buff／Debuff Buttons | `UF.AURA.*` | 当前不重绘 |

## 接入边界

未来 P5 只允许在 `addon/AzerothExpeditionUI` 增加 Unit Frames 媒体与一个作用域
adapter，或在 `addon/pfUI/api/unitframes.lua` 增加等价的精确媒体挂点。不得修改
Frame 的 Point、Width、Height、事件、点击、Secure 模板、状态刷新或配置值；
媒体缺失时局部回退 pfUI 原始 backdrop／bar／glow。
