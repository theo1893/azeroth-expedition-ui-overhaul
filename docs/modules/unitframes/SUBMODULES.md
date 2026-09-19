# Unit Frames 子模块与 pfUI 对齐

`unitframes.raid-aura-rim` 仅接管 `pfUI.uf.raid[1..40].buffs/debuffs` 的真实
Button 外缘，复用 Raid A2 细边资源；provider 更新尺寸后刷新外观，保留排列、
显隐、类型色与交互。禁用恢复原 backdrop／shadow，不接管框内状态指示器。

本模块严格对应 `addon/pfUI/api/unitframes.lua` 创建的真实 UnitFrame，以及
`addon/pfUI/modules/nameplates.lua` 创建的世界姓名板。当前运行时接管登记过的
静态媒体及其挂载，并通过 `UF.PORTRAIT.DISABLE` 关闭所有 pfUI UnitFrame 动态
头像呈现；除下文明确登记的姓名板职责、目标仇恨显示与刷新策略外，不改变 Frame 锚点、尺寸、事件、点击、单位数据或状态逻辑。头像合同
只写入下文列出的精确配置值，原值保存在 AEUI SavedVariables 中并可完整回退；
其他 pfUI SavedVariables 不变。

## 当前四个单位框细边框试用

runtime `2.3` 通过 `unitframes.primary-thin-shell` 为真实 `pfUI.uf.player`、
`pfUI.uf.target`、`pfUI.uf.targettarget` 与 `pfUI.uf.focus` 分别复用 Raid A2
的 A／B／C／D 纹理。九切片为
`6/62/6 × 6/25/6`，边角不缩放，外扩 `2 UI`；只在 Frame 背景层挂载，不修改
状态条、命中、位置、尺寸、文字或第三方精英龙饰。团队本身仍走原三切片。
模块／route 禁用时恢复四框 pfUI chrome。下面 Player V5 与 Target V4 记录为
保留资产合同，当前厚外壳 route 均暂停；细边框视觉尚待用户实机确认。

## 主单位框与资源条批次

Unit Frames runtime `2.0` 会把全部 13 组真实配置强制为 `portrait = off`。下列逻辑尺寸来自
`addon/pfUI/env/profiles.lua` 与 `pfUI.uf:UpdateFrameSize()`；外壳只在真实 Frame
外增加不参与命中的透明装饰边，不改变 provider 几何。

| 组件 ID | pfUI 对象 | 动态内容区 | 资源外接尺寸 | 状态／所有权 |
|---|---|---:|---:|---|
| `UF.PLAYER.SHELL` | `pfUI.uf.player`／`pfPlayer` | 当前配置 `240×48`，`pheight=10 / pspace=-3 / border=3`，当前 provider `240×61` | 当前 `254×73` | V5 同一完整纹理以固定上下边切片适配高度；宽度保持 240，不改变 provider |
| `UF.TARGET.SHELL` | `pfUI.uf.target`／`pfTarget` | 当前 HP `240×48`；Power `240×10`，provider `240×61` | 当前 `254×73` | 独立 target-shell-v4 route 恢复 V4 九切片；不得烘焙目标类型、名称或等级 |
| `UF.TARGETTARGET.SHELL` | `pfUI.uf.targettarget`／`pfTargetTarget` | HP `100×20`；Power `100×1` | `112×34` | 一张简化静态外壳 |
| `UF.FOCUS.SHELL` | `pfUI.uf.focus`／`pfFocus` | HP `100×25`；Power `100×1` | `112×43` | 一张静态外壳；上 `10px`／下 `6px`；靛蓝猎踪布结是焦点识别件 |
| `UF.BAR.HEALTH.FILL` | 每个对象的 `f.hp.bar` | provider 裁切宽度 | `64×32` 可横向拉伸纹理 | 无色灰阶颜料纹；继续由 pfUI 着色与更新数值 |
| `UF.BAR.POWER.FILL` | 每个对象的 `f.power.bar` | provider 裁切宽度 | `64×16` 可横向拉伸纹理 | 无色灰阶窄颜料纹；继续由 pfUI 按资源类型着色 |
| `UF.STATE.HOVER.RIM` | `f.hoverglow` | 外壳边缘 | 由每张接受外壳 Alpha 确定性派生 | 暖白短边响应；不改变命中盒 |
| `UF.STATE.AGGRO.RIM` | `f.glow` | 外壳边缘 | 由每张接受外壳 Alpha 确定性派生 | 暗红／橙褐短边响应；继续使用 pfUI 状态逻辑 |

## 目标框架仇恨区

`UF.TARGET.THREAT`／`unitframes.target-threat` 只持有真实
`pfUI.uf.target.aeuiTargetThreatRail`，复用 Unit Frames 的姓名板职责和仇恨缓存。
轨道等宽紧接整个目标框底部、高 `12 UI`、不接收鼠标，百分比为 `10 UI` 字号；
有效比例时 Raid A2 细外缘向下延伸包住轨道，生命／资源、原框尺寸和龙饰锚点不变。

`aeuiBottomAuraInset = 12` 仅写在该目标框上，由 pfUI 创建／刷新下方 Buff、Debuff
时统一计入纵向偏移，上方 Aura 保持原位。预留只跟随功能开关，比例刷新和无数据
不移动 Aura；禁用清除该会话字段并恢复原锚点。图标、冷却、层数、筛选、顺序和
点击仍归 provider，既有层级高于第三方龙饰，不另外改写层级。

该显示依赖已启用的姓名板职责和目标细边框 route，不新增网络请求或独立计时器。
`/aeui threat off` 独立隐藏轨道并撤销预留，姓名板不受影响；模块／route／职责
关闭时同样回退。共享缓存的时效、GUID、承伤者校验及 MOCK 语义均沿用姓名板。

## 世界姓名板职责模式

`unitframes.nameplate-combat-mode` 只作用于 `pfUI.nameplates` 已创建的真实姓名板。
AEUI 保存每角色职责并提供纯显示策略；pfUI 保留单位识别、血量、施法、Aura、
点击和世界姓名板开关。策略通过 `SetCombatMode(mode, policy)` 即时应用，不改写
pfUI SavedVariables。模式为 `tank／healer／dps`，`off` 恢复 provider 配置。

三模式共用几何与标记；未选中友方只显示名字，选中友方显示血条，普通敌方均显示
血条。职责色只解释可靠的敌方当前承伤对象，不能作为仇恨数值；施法期间保持已知
分类。坦克来源只复用 pfUI 手动名单和团队坦克标记，不按职业猜测。

同一组原有 Aura Frame 以关键控制／免疫优先展示，目标敌方／非目标敌方／选中
友方／未选中友方上限为 `6／2／4／0`；关闭模式恢复 pfUI 原光环规则与排列。
不增加光环数据库、姓名板追踪器、危险技能推断或自动职责切换。模式及开关的
当前状态、命令和实机门禁见 `PROGRESS.md`。

仇恨细轨由 provider 在真实 `plate.health` 内创建 `plate.threatRail`，AEUI 的
`GetNameplateStyle` 第四返回值提供有效比例；轨道只负责显示，不持有或推断仇恨。
生命 StatusBar 高度不变，`plate.threatRail` 等宽紧接其底部、高 `8 UI`，只显示百分比。
`aeuiIdentity.bounds` 向下延伸包住两区，外缘／两端端口／选中铜夹共用整体高度；
等级保持生命区原位，施法及下方附属内容跟随整体底边。无有效比例、友方或职责关闭时
隐藏仇恨区并收回延伸，不修改生命区文字大小或生命值几何。

## 世界姓名板选中目标提示

`addon/pfUI/modules/nameplates.lua` 为每个 Blizzard 世界姓名板创建
`parent.nameplate`，并在中心更新循环中把可靠的当前目标判定写入
`nameplate.istarget`。AEUI 不重新扫描名称或猜测 Alpha，只通过精确 route
`unitframes.nameplate-target-cue` 读取这一 provider 状态。

| 组件 ID | pfUI 对象 | 展示尺寸 | 状态／所有权 |
|---|---|---:|---|
| `UF.NAMEPLATE.TARGET.CUE` | `parent.nameplate` 上的 AEUI 局部装饰 Frame | `24×24 UI`；`48×48` sampled region | 仅 `nameplate.istarget` 为真且姓名可见、非图腾时显示；目标识别、姓名板生命周期与点击继续归 pfUI |
| `UF.NAMEPLATE.TARGET.BRACKETS` | 目标指针 Frame 下的血条两端装饰 | 各 `10×20 UI`；`20×40` sampled，血条外留 `1 UI` | V2 手绘深皮革／短铜夹；随选中显隐且血条隐藏时隐藏；等级选中距血条 `14 UI`、取消／回退恢复 provider `5 UI`，仅状态切换改锚点。不修改血条、职责色或命中区 |
| `UF.NAMEPLATE.AURA.POLICY` | `nameplate.debuffs[1..16]` | provider 原 `16` 枚动态图标 | 职责模式开启时按上文 `6／2／4／0` 摘要；关闭模式后，pfUI“聚焦光环显示”开启且 Action Bars 策略可用时，敌对姓名板保留自己的／固定关键 Debuff 与全部真实 Buff，友方保留全部真实 Buff／Debuff；Debuff 优先占位。关闭配置或策略缺失时恢复原前 `16` 个 Debuff |
| provider 团队标记 | `nameplate.raidicon` | pfUI 配置尺寸 | 仍由 pfUI／游戏设置图标和显隐；只把 Parent 从可隐藏的 `nameplate.health` 改为 `nameplate`，不调用 `SetRaidTarget` |

个人目标标记默认以底边锚在姓名上方 `4 UI`；若 provider 团队标记已显示且其
配置位置包含 `TOP`，则改锚在团队标记上方 `4 UI`。锚点只在这两种堆叠状态
切换时更新，不运行维护循环持续改写。血条关闭时姓名、个人目标标记和团队
标记仍可独立显示；个人标记不覆盖姓名或血条，也不改变姓名板 Frame、命中区、
缩放、层级判定或 SavedVariables。模块／route 禁用时只隐藏并卸载个人标记
纹理，完整 pfUI 姓名板与团队标记继续运行。

聚焦光环只复用 provider 已有图标、位置、层数和冷却对象，不创建第二套姓名板
或光环数据库。它在同一 `16` 格内先压缩从 `32` 个源槽筛出的 Debuff，再用余位
放 Buff；原 Debuff 黑白名单和敌友显隐开关继续生效。

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

## UF-PLAYER V5 已接受 source 与已接入 runtime

- `UF-PLAYER-SHELL-V5-A1 attempt 3` exact source／runtime 已由用户接受并授权
  提升、导出和接入，当前为 `P5`；正式文件和清单位于
  `assets/source/unitframes/player-v5/`。
- source 为完整 `1524×462 RGBA` 外壳，runtime master 为同一完整物件的
  `254×77 RGBA` 逻辑像素；正式媒体只透明补齐为 `256×128` TGA，以 UV
  `(0, 254/256, 0, 77/128)` 读取，不重绘、不拼接、不九切片。
- 适配器只接管 `pfUI.uf.player`；2× runtime 按 `7/240/7 × 16/55/6`
  逻辑切片采样同一完整纹理。宽度固定 `240 UI`，上下边与维修片不缩放，
  只适配侧边中段高度；art box 为 provider `width+14 / height+12`。
- 非 `240 UI` 宽度、过小高度、模块禁用或 route 缺失时恢复 Player 的 pfUI
  backdrop／shadow。Bars、文字、颜色、Aura、图标、Hover／Aggro、点击和事件
  继续由 pfUI 持有。
- Target 使用自己的 `unitframes.target-shell-v4` route 和 V4 像素，不复用
  Player V5。TargetTarget、Focus 与旧共享 route 继续暂停。

## UF-PRIMARY V4 历史 source／暂停 runtime

用户于 `2026-08-12` 要求重开 Player／Target 完整外壳的新生产架构，并已确认
`UF-PRIMARY-V4-SIM-V1` 与 Raid A2 sample 的只读输入职责。用户随后以“确认,
进入下一阶段”接受 `UF-PRIMARY-V4-CANDIDATE-V1` 两张 exact candidate。两张
source 曾确定性导出；当前 Player 已被 V5 替代；Target V4 已通过独立 route 恢复，旧共享
`unitframes.primary-shell` route 仍暂停。以下 V4 结构只应用于 Target，不能覆盖 V5。

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
- 每个角色只导出一张完整 `214×42` base TGA；overlay rim 与 Hover／Aggro
  只由同图 Alpha 确定性派生。Lua 以 `32/150/32 × 8/26/8` 九切片采样这些
  完整纹理，显示 art box 始终为 provider Frame 的 `width+14 / height+12`，其中
  `7px / 6px` 透明开口精确映射真实 Frame。不得把完整位图整体纵向拉伸；身份
  端、上下实体厚度固定，只有中央安全跨度随 provider 几何扩展。
- Player 的重修补位于左上外围；Target 的损伤位于右下外围，同族但非镜像。
  Hover／Aggro 从接受 Alpha 确定性派生断续短边，不单独生成。
- 接受 source 分别为
  `assets/source/unitframes/primary-v4/UnitFramePlayerShell_MasterV1.png`
  SHA `331b353f…617b` 与
  `assets/source/unitframes/primary-v4/UnitFrameTargetShell_MasterV1.png`
  SHA `256086c1…f81`；manifest 为同目录
  `UF-PRIMARY-V4_SourceManifest_v1.json`。source 不能被 Lua 直接加载。
- runtime manifest 为同目录 `UF-PRIMARY-V4_RuntimeManifest_v1.json`；addon 媒体
  为 `UnitFramePlayer*V1.tga` 与 `UnitFrameTarget*V1.tga` 共八张 base／rim／
  Hover／Aggro 派生。禁用模块、route 或媒体缺失时只恢复对应 pfUI backdrop、
  glow 与 shadow，不影响 Frame、条、文字、Aura、事件或点击。
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
| 四个主框 Buff／Debuff Buttons | `UF.AURA.*` | `unitframes.primary-aura-rim` 复用各自 Raid A2 细边框；尺寸、排列、图标、冷却与事件归 pfUI，Debuff 类型色透传；禁用恢复原 backdrop |

`UF.PORTRAIT.DISABLE` 只使用 scoped route `unitframes.dynamic-portraits`。原始 13 组
`portrait` 值与 `raidmarkershowportrait` 按 pfUI profile 保存在
`AzerothExpeditionUIDB.unitframes.portraitConfigBackups[profile]`；pfUI 配置页应用期间若用户
选择新值，该值会成为之后的回退值，但本模块启用时仍保持 `off`。关闭
`/aeui unitframes` 或关闭该 route 后恢复原值、live Frame 与两套追踪布局。
`CharacterFrame`、`InspectFrame`、`DressUpFrame` 的角色预览模型不属于 UnitFrame
动态头像，本合同不接管。

## 接入边界

Unit Frames P5 只允许在 `addon/AzerothExpeditionUI` 的作用域 adapter、
`addon/pfUI/api/unitframes.lua` 的精确挂点，或
`addon/pfUI/modules/nameplates.lua` 的团队标记 Parent 修正及上述职责模式接点内实现。除明确登记的姓名板显示模式、更新节流和模式切换布局外，不得修改
provider Frame 的 Point、Width、Height、事件、点击、Secure 模板或状态语义；
配置写入只允许上述 13 组 `portrait` 与 `raidmarkershowportrait`，并必须可逆。
媒体或 route 缺失时局部回退 pfUI 原始 portrait／backdrop／bar／glow，姓名板
只撤下 AEUI 个人目标标记。

四框 Aura 细边框挂在真实 Button 的背景层，四边外扩 `2 UI`，使用同图九切片；
provider `UpdateConfig` 完成后通过已有框体视觉回调接入，不通过维护循环重写
几何。Debuff 更新只向边框传递颜色，不重新布局。团队、姓名板 Aura 不在此 route 内。

## pfUI 独立 Buff／Debuff 面板

`unitframes.standalone-aura-rim` 只接管 `pfUI.buff.buffs.buttons`、
`pfUI.buff.debuffs.buttons` 与 `pfUI.buff.wepbuffs.buttons` 的边框、阴影替代
及图标层序；复用 Raid A2 A／B 媒体和 `2 UI` 外扩。`modules/buff.lua` 继续
持有图标、附魔状态、计时、层数、染色、布局、事件、Tooltip 与取消操作。
在 provider 配置更新结束时更新边框几何；Buff 刷新只传递颜色，不维护几何。
禁用模块／route 后恢复原 backdrop、shadow 与图标 DrawLayer。

## 屏幕中心距离读数

`unitframes.distance-indicator` 只作用于 `pfUI.distanceIndicator`（`pfDistanceIndicator`）的
原始 `text`、`icon`。AEUI 三切片皮签挂在同一 Frame 的 BACKGROUND 层，锚到主文本
最后一行；默认 `72×18 UI`、横向 `11/47/14` 三切片，长数字与用户字体尺寸按实际
文字区域适配，几何只在测量尺寸或配置变化时更新。眼睛按用户配置宽度的 85% 显示，默认 `17×11.9 UI`，完整位于
皮签内；用户原图标尺寸的 85% 用作宽度，高度按 `.7` 比例。没有主读数时隐藏皮签。

`addon/pfUI/modules/unitxp.lua` 继续计算距离、视线、近战／盲区与宠物状态，继续
持有颜色、声音、刷新、拖动和保存设置。通过可选 `pfUI.aeuiDistanceIndicatorSkin`
传递视线素材及样式回调；AEUI 开启时只隐藏“打脸”前缀，红色与声音不变，其他
前缀和宠物读数保留。未组队且仅组队播音时只跳过声音，不提前结束显示刷新。
禁用 Unit Frames／route 后撤下皮签，恢复原眼睛 UV、尺寸与锚点，provider 恢复
原生前缀与材质；AEUI 或 UnitXP 缺失时不产生新的测距入口。

距离签整体锚到玩家框 `TOPRIGHT` 与目标框 `TOPLEFT` 之间的无交互参考 Frame，
底边高出 `15 UI`；皮签完整宽度参与居中，原主文本底部锚定使前缀向上展开。
锚点仅在接管、文本几何或主框对象变化时设置，不运行坐标轮询维护。
原 Frame／文本锚点单独保存在运行时，模块禁用或主框缺失时恢复；不改写位置配置。

## 姓名板血条填充

`unitframes.nameplate-health-fill` 仅接管 `pfUI.nameplates` 的真实 `nameplate.health`
StatusBar 纹理，复用 `ActionBars/Readouts/CastFillV1`。借用已有 OnCreate／
OnConfigChange 挂点与模块应用遍历，不对 OnUpdate 增加填充工作。颜色、数值、
方向、动态裁切和姓名板施法条继续归 provider；血条 backdrop／阴影隐藏，
空血量底色由锚定真实 health 的 BACKGROUND 纹理保留，不扩大命中区。pfUI 配置重建后重新记录
当前原生纹理，`/aeui plates off`、Unit Frames／route 禁用时恢复该纹理及原 backdrop／阴影显隐。

姓名板职责模式启用且血条 route 有效时，provider 的配置布局使用 `18 UI` 血条，
同时计算占位、glow 和施法图标；退出模式恢复 `C.nameplates.heighthealth`。
AEUI 复用 `ReadoutShellV1`，四边外扩 `1 UI`，上下沿总高 `20 UI` 对齐铜夹。
深烟褐空血底不透明，暗色填充按 RGB 等比提升亮度峰值至 `.65`，不改色相／Alpha。
选中铜夹沿用原像素及 `10×20 UI` 几何，仅降低乘色亮度。

## 行军身份条布局

沿用 `unitframes.nameplate-health-fill` route。`nameplate.aeuiIdentity.bounds` 是真实
health 的无交互附属区域，宽度含等级位；真实 StatusBar 宽度为完整身份条减等级位及
5 UI 分隔净空，中心右移半个 inset，使整体位置保持居中。等级字号乘 .85，
等级位为字宽加 4 UI、最低 12 UI；禁用恢复原 Parent 与字体。
身份条以配置宽度为下限，使用无宽度约束的 FontString 测量完整血量读数，
血量区至少为读数字宽加 12 UI，接管期间保留最大读数宽度以避免抖动。

未选中皮革端口各 8×20 UI，选中铜夹锚到同一 bounds。名字承托 64×10 UI，
按名字宽度以 6/52/6 三切片伸缩；2× 采样。分隔 source 仍为 2×14 UI，runtime 取有效 UV 显示为 3×16 UI；名字承托
按实际字宽加 12 UI、字高加 6 UI 设置，文字仍独立绘制。
施法条、首个 Aura、团队标记等原先锚到 health 的装饰改锚到完整 bounds，退出时
恢复；后续 Aura 创建同样使用 bounds。原始 OnDataChanged 后仅在等级／名字宽度
改变时更新布局。配置重建前恢复原几何再捕获新配置；名字模式撤下全部身份装饰。

## 当前目标聚焦

姓名板职责模式开启时使用真实 GUID／provider 目标判定强制显示当前目标完整血条，
包括图腾与原本仅名字类别。整体 `nameplate` 按原 Scale 的 1.15 倍显示，不使用
逐帧 Width／Height 缩放；取消／切换恢复原 Scale。已有目标时非目标普通 Alpha
上限 .45，施法／团队标记／危险承伤上限 .65，目标为 1；无目标恢复职责 Alpha。

`UpdateTargetVisibility` 临时开放原本关闭的目标类别，只允许目标呈现，其他新增
provider 对象隐藏；取消或模式关闭恢复之前的敌友开关，并识别期间的手动开关变更。
作用于客户端可创建的世界姓名板，不创建远距离或屏外替代框，不改 SavedVariables。

## 姓名板施法与辅助外观

`unitframes.nameplate-details` 接管真实 `castbar` 的填充、背景细边、技能名／时间
布局，以及 `castbar.icon`、`debuffs[1..16]`、`totem` 的外缘。复用已接受的
Readouts V1 与 Raid A2 资源，不接管计时、图标内容、冷却、光环筛选、施法判定。
Provider 配置阶段使用 12 UI 施法条，禁用恢复配置高度；时间在右侧预留 32 UI，
技能名限制在剩余区域。创建／配置／新增图标时设置外观，相同尺寸缓存不重复布局。

`combopoints[1..5].tex/backdrop` 隐藏并叠加现有铜刻痕，原五个 Frame 的显隐继续
表达数量；关闭恢复原纹理显隐。`cluster` 仅调整净空，不重画任务符号；`guild`
仅重排到姓名或个人目标指针上方。辅助文字和图标均记录原始布局／字体／层序供回退。
施法结束时首个底部 Aura 锚回完整身份条 bounds，避免误用缩窄的血量区。

测距签方向针为独立 OVERLAY Texture，读取 `DistanceDirectionV1.tga` 的 108 帧图集
（32×32 每帧、16 列、512×256 容器），仅改变 UV，不改写 pfQuest 路由／任务数据。以 SuperWoW
UnitPosition 的平面方位减玩家朝向，转换为帧号；朝向优先 GetPlayerFacing，回退
pfQuestCompat.GetPlayerFacing。读取失败或坐标重合则隐藏，沿用 unitxp 原刷新节流。
图标 16×16 UI，距离右侧保留 20 UI 区域，禁用恢复原无方向布局。
官方接口范围参考：https://github.com/balakethelock/SuperWoW/wiki/Features

## 姓名板服务器仇恨输入

Unit Frames 持有临时 TWT／TMT 请求、短期快照与职责颜色策略；pfUI 继续持有真实
姓名板、GUID、生命值、施法与承伤对象判断。TWT 只用于当前目标，TMT 的完整 GUID
只对应自己的坦克群怪追赶者摘要，不表示每只怪对自己的绝对仇恨。
ShaguDPS 保留统计窗口与 TPS，仅在 AEUI 请求器活动时让出重复请求，并剥离 TMT 后缀。
不写仇恨 SavedVariables，不按怪名合并，不改目标，也不调用逐怪切换轮询。
