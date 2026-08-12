# Unit Frames 模块详细进度

## 当前状态

- Player／Target 完整外壳已按用户于 `2026-08-12` 的要求重开；用户已确认
  `UF-PRIMARY-V4-SIM-V1`，并授权 Raid A2 已验收 sample 作为只读输入。当前
  `UF-PRIMARY-V4-CANDIDATE-V1` 为 `P4 / source-accepted / ImageGen 0/0`。
  用户审阅 exact candidate 后以“确认, 进入下一阶段”接受 Player SHA
  `331b353f…617b` 与 Target SHA `256086c1…f81`，并只授权 P4。两张同 SHA
  `1284×252 RGBA` 母版及 manifest 已写入
  `assets/source/unitframes/primary-v4/`；没有 runtime 或 addon 改动。V4
  只读复用已接受的 Raid A2
  leather／liner／brass／thread 材料 sample，由 Python 独占完整外壳几何、
  Alpha、安全区、维修 mask、`1284×252 → 214×42` 与 `32/150/32` 横向三切片；
  ImageGen 不再承担 UI 几何，首选路径也不需要新的 ImageGen。
- `2026-08-12` 合并审计已把远端完成的 B1 与 Raid A2 P5 媒体、adapter、
  pfUI scoped bridge 和 TOC 与本地 Action Bars 合入同一 addon。Player／Target
  V4 仍保持 P4：本地 Combat Focus 已确认几何为 `240×60`，而 V4 接受合同固定
  `214×42` 且禁止纵向拉伸；在建立并确认兼容合同前，不导出 runtime、不改写
  Combat Focus，也不把 P4 母版伪称为已接入。
- `UF-A1 V3-A final` Player 与 `UF-A1 V3-B final` Target 保持历史终态
  `P3 / repair-budget-exhausted / candidate-rejected / 5/5`；失败像素不得进入
  V4 reference、edit、source、runtime 或 builder。
- `UF-B1 V2 final` Health／Power 灰阶填充纹：
  `P5 / source-accepted / runtime-exported / addon-integrated / 3/5 stop`。
- `UF-A2` TargetTarget／Focus：继续暂停；既有物件身份方向不变，尚无正式
  source。Hover／Aggro 仍计划由接受外壳 Alpha 确定性派生。
- Raid 已保留 `UF-RAID-SIM-V1` 的无共享外框、薄皮革名条、四变体、低饱和
  配色与 40 人整体密度。旧 `UF-RAID-A1 V1 final` 终态仍为
  `P3 / repair-budget-exhausted / candidate-rejected / 5/5`；attempt 3 仅是
  最佳内部参考，attempt 5 比例误成约 `3.19:1`，没有 candidate、source、
  runtime 或 addon，且 A1 禁止第六次。
- 用户于 `2026-08-12` 选择新的 `UF-RAID-A2` 架构：ImageGen 未来只生成四块
  粗粝材质 donor，Python 独占精确外壳几何、Alpha、`592×296 → 74×37`、
  `48/496/48 → 6/62/6` 三切片及 A/B/C/D 四种维修差异。
  `UF-RAID-A2-SIM-V1` 已由用户于 `2026-08-12` 明确确认；用户同日另行精确
  授权 `UF-RAID-A2-DONOR V1`。五次生成预算已耗尽，用户随后接受 attempt 5
  的运行时视觉，并只豁免未消费外围 field bbox 最大 `19px` 偏差；固定 sample
  window、Python 外壳、A-D 维修、透明清理、source/runtime 尺寸、三切片和
  40 人排版合同均未改变。当前为
  `P5 / source-accepted / runtime-exported / addon-integrated / 5/5`；精确 attempt、
  流程错误和例外边界只在
  `work/UNITFRAMES.RAID.md` 维护，避免长期进度复制逐稿流水。
  最终展示区域 `7/7 pass`、violations `0`；四个 `512×288` sample、四张
  `592×296 RGBA` source 与四张独立 `74×37 RGBA TGA` 已受 manifest 管理。
  Lua 只接入 `pfRaid1..40`；标准宽度加载完整纹理，其他宽度使用同图
  `6/62/6` 三切片，高度偏离 `33px` 时局部回退 pfUI。第六次调用仍禁止。
  合并后的 fresh-checkout addon package 为 `pass`、violations `0`，报告 SHA
  `e1ca9054…0a35`；目标设备不需要运行 exporter。
- 当前只处理资源重绘与精确媒体替换。B1 已接入 addon；没有修改另一台设备上
  的 Frame 位置、尺寸、点击、事件、数值、颜色逻辑或其他功能。
- 用户于 `2026-08-11` 接受“每个角色生成完整外壳，Python 负责精确工程化”
  的架构，并要求同时重绘生命与 Mana／Rage／Focus／Energy 等资源条材质。
- 新模拟 `UF-PRIMARY-V3-SIM-V1` 已本地完成并通过内部几何门禁；用户于
  `2026-08-11` 明确“接受”。已冻结完整外壳、旧马鞍／盾带式粗犷皮革、
  Player／Target 非镜像关系、Health／Power 层级、四资源经典乘色及与 Chat／
  动作条邻接但不复制轮廓的可见方向。确认不接受模拟像素。生成前模拟
  ImageGen `0/0`。
- 用户随后于 `2026-08-11` 明确授权上述三段 final，冻结 A→B→B1 顺序、
  A／B 固定 Image 1／2、同段紧邻前稿有界 edit、B1 首次无图片、每段
  `5` 次实际生成及最坏 `15` 次预算。流程错误不占额度；跨段与旧失败像素
  禁止复用。A attempts 1–5 与 B attempts 1–5 均已完成并耗尽；B1 attempts
  1–3 已完成并在通过后停止。
- 用户于 `2026-08-11` 明确“接受 B1 attempt 3 的运行时视觉”。两张 exact
  candidate 已逐字节固定为 source，确定性导出为 `64×32` Health 与 `64×16`
  Power TGA，并只接入 `player`、`target`、`targettarget`、`focus`。A／B 外壳
  与 UF-A2 不在本次接受范围内。

## V4 新生产架构与生成前模拟

- 用户原文：“重开 Player／Target 完整外壳的新生产架构。”用户随后确认
  `UF-PRIMARY-V4-SIM-V1` 并授权 Raid A2 sample 只读输入；随后以“确认,
  进入下一阶段”接受 exact Player／Target candidate，并只授权 P4 source。
- 最终资产粒度不变：Player／Target 各自仍是一张独立完整 source 和一张完整
  runtime；不是端帽 atlas、两角色合图或多图拼接。标准 `W=200` 使用完整
  `214×42` 纹理，内部接缝 `0`；变宽才从同一角色 source 派生
  `32px left / 150px quiet centre / 32px right`。
- source 固定 `1284×252`，live bed 固定 source
  `x42..1242/y36..216`、runtime `x7..207/y6..36`。烟褐 liner 可以在动态条
  下方，皮革 relief／暗铜／线／铆钉／状态边必须留在外围。统一 UI Scale
  可整体缩放；高度不独立拉伸。
- Player 身份移到左上外围短夹片＋左侧两条粗缝，Target 身份移到左上磨损折边
  与右下断裂暗铜压片；双方同族但不镜像。Hover／Aggro 后续从接受 Alpha
  确定性派生断续边，不单独生图。
- 首选材料输入为 Raid A2 已接受四 sample，原 SHA 与用途保持不变；这只是新的
  immutable downstream 用途，不修改 Raid source/runtime。若主框 candidate
  证明材料尺度不合适，备用 primary-specific donor 仍为
  `inactive / not-authorized`，不得自行调用；若激活需另行精确授权，最多五次。
- spec：`tools/specs/unitframes_primary_v4_simulation_v1.json`；renderer：
  `tools/render_unitframes_primary_v4_simulation_v1.py`。scene SHA
  `dd6bb345…d4622`；review SHA `574ee88d…00aa`。shell 只用本地简单几何，
  不复制 locked 或 accepted material sample 像素；现有 P5 Health／Power runtime
  只用于真实排版。模拟像素不得晋级。
- display contract：
  `tools/specs/unitframes_primary_v4_simulation_display_region_v1.json`；Player
  四 Power mode、Target Aggro、`W=160/240` 共 `7/7 pass`，violations `0`，
  报告 SHA `1ba15de8…6a32`。
- candidate contract：`tools/specs/unitframes_primary_v4_candidate_v1.json`；
  builder／reviewer 为 `tools/build_unitframes_primary_v4_candidates_v1.py` 与
  `tools/review_unitframes_primary_v4_candidates_v1.py`。Player／Target source
  SHA 分别为 `331b353f…617b`、`256086c1…f81`；100% runtime review SHA 为
  `3bedcae1…e5a4`、`f07b5ef6…347e`。输入 SHA、透明清理、安全区与身份 mask
  全部通过，display-region `10/10 pass`、violations `0`；多场景真实排版覆盖
  四资源、低血量、Hover／Aggro、`W=160/240` 与四档统一 UI Scale。
- P4 manifest：
  `assets/source/unitframes/primary-v4/UF-PRIMARY-V4_SourceManifest_v1.json`；
  `tools/promote_unitframes_primary_v4_source_v1.py` 已验证重建结果与两张接受
  candidate 的 PNG SHA、pixel SHA 均相同后固化 source。
- 当前下一门禁：先解决本地主框 `240×60` 与 V4 固定 `214×42`、禁止纵向
  拉伸之间的兼容合同并取得确认；随后才可执行 P5 runtime／状态边确定性导出、
  真实排版与 display-region 复核、addon 接入和 fresh-checkout package 校验。
  本次 P4 接受不授权 P5；执行前保持 Player／Target shell 的 `addon/` 不变。

## V3 历史结构合同

- Player／Target 各自生成一张完整高分辨率空外壳，不放入同一 production
  atlas，不镜像，不逐端帽生成，不拼接多张生成图。
- P4 母版目标 `1284×252 RGBA`，P5 标准 runtime 为完整 `214×42` 单纹理；
  `W≠200` 时才从同一母版确定性派生 `7 + center + 7` 三切片和装饰角 `1px`
  下压重叠。
- Python 可执行色键、bbox 提取、透明清理、完整外壳归一化、固定安全区清理、
  切片／atlas／缩放与真实排版；不得补画、移动装饰、复制维修或改变拓扑。
- 外 bbox 相对 `214:42` 的比例误差和独立 X／Y 归一化各向异性均不得超过
  `8%`。动态安全区内深入超过 `1 runtime px` 的结构性 Alpha 必须退回。
- `UF.BAR.HEALTH.FILL`／`UF.BAR.POWER.FILL` 是两张独立中性灰阶资产，runtime
  分别 `64×32`／`64×16`。pfUI 的 `SetStatusBarColor` 与 `UnitPowerType` 继续
  提供生命、Mana、Rage、Focus、Energy 经典色，动态颜色不烘焙进贴图。

## 生成前模拟

- 版本：`UF-PRIMARY-V3-SIM-V1`
- specification：`tools/specs/unitframes_primary_v3_simulation_v1.json`
- renderer：`tools/render_unitframes_primary_v3_simulation_v1.py`
- scene：
  `generated/unitframes/primary/simulation/V3/unitframes-primary-v3-sim-v1.scene.png`，
  SHA `c74b23e0…b1649`
- review：
  `generated/unitframes/primary/simulation/V3/unitframes-primary-v3-sim-v1.review.png`，
  SHA `3a2a39b2…61dd`
- ImageGen：`0/0`；Python
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`／`3.12.12`；本地错误 `0`。
- 模拟使用真实 Player／Target `214×42`、紧凑框邻接、HP／Power、文字、Aura
  和 Aggro；审阅板另覆盖 Mana／Rage／Focus／Energy 四个互斥支持模式。
- 初稿黄铜近整高包边在内部审查时被退回；当前图已收缩为局部修补，端部主体
  恢复为不规则旧皮革。该迭代没有 ImageGen 调用。
- 非权威：最终手绘笔触、微纹理、Alpha、生产像素、远端屏幕位置和紧凑框
  production art。

### Raid `UF-RAID-SIM-V1`／`UF-RAID-A2-SIM-V1`

- specification：`tools/specs/unitframes_raid_simulation_v1.json`；renderer：
  `tools/render_unitframes_raid_simulation_v1.py`。
- scene SHA `41468266…5519`；review SHA `10158347…eca2`；ImageGen `0/0`，
  本地渲染错误 `0`。
- 模拟覆盖 40 个真实对象、四个确定性粗糙外壳变体、已接受 Health／Power
  runtime 纹理、Hover／Aggro／Range／Offline／Dead／Heal／Res／Aura／
  Leader／Loot／Raid Icon，以及当前 Chat／动作条／罗盘邻接。
- display-region `7/7 pass`、violations `0`，报告 SHA `ddb3fc51…6dd0`；覆盖
  单框、40 人 Vertical／Horizontal、20 人、五人复用和 `width=90`。
- 用户于 `2026-08-12` 确认该方向；模拟像素不接受为 source。正式机器合同为
  `tools/specs/unitframes_raid_production_v1.json`，执行正文为
  `UF-RAID-A1 V1 final`。正式 ImageGen 已 `5/5` 耗尽并终止于
  `candidate-rejected`；attempt 3 仅为最佳内部视觉参考，attempt 5 仅为终态诊断。
  两者均未进入 P4，addon 变更仍为 0。
- 用户随后选择 A2：模型只供 `leather/liner/brass/thread` 四块连续材料，donor
  不含任何 UI 几何且不被 runtime 加载；
  `tools/build_unitframes_raid_donor_shells_v1.py` 确定性构造四张完整外壳与四种
  维修 mask。规格为 `tools/specs/unitframes_raid_donor_simulation_v1.json`，
  production 草案为 `tools/specs/unitframes_raid_donor_production_v1.json`。
- A2 scene SHA `5697dcbb…5932`，review SHA `ff2467d3…0f95`，source preview SHA
  `ce084d35…0205`。模拟使用固定 seed 的本地占位材质，只确认几何、维修位置、
  运行时密度与动态层序；不确认材质笔触或任何模拟像素。ImageGen `0/0`。
- 用户于 `2026-08-12` 原文确认 `UF-RAID-A2-SIM-V1`。已把上述可见结论写入
  `UF-RAID-A2-DONOR V1` 的最终执行正文并重新完成 `pass-final` 完整性审计；
  用户随后精确授权该正文、固定 SHA Image 1／2、同循环紧邻前稿有界 edit、
  最多五次实际生图及合同内确定性后处理。五次额度已全部使用，授权状态已
  关闭。用户已接受 attempt 5，并授权 `sample-window-only` 单一例外进入 P4/P5；
  当前为 `accepted-by-sample-window-only-exception / P5`。严格外围 field bbox
  失败事实保留，未消费外围像素未晋级；精确证据见唯一 Raid work。

## 展示区域门禁

- 合同：`tools/specs/unitframes_primary_v3_simulation_display_region_v1.json`
- 报告：`generated/unitframes/primary/simulation/V3/display-region-report.json`，
  SHA `625f4dc0…19e3b`
- 结果：Player Mana／Rage／Focus／Energy、Target Rage、Player `W=160`、Target
  `W=240` 共 `7/7 pass`，violations `0`。
- 本结果只证明 source／shell／live region／Button 安全区合同，不能证明最终
  笔触、材质或 Turtle WoW 混合。

## 正式生产正文与预算

- `UNITFRAMES.CORE.md` 只保留当前 V3 合同、三段自包含 final、历史终态摘要和
  下一门禁；V1／V2 的逐稿全文继续由 Git 历史保存。
- `UF-A1 V3-A`、`UF-A1 V3-B`、`UF-B1 V2` 每段最多 `5` 次实际
  `imagegen-0-143-0`，最坏合计 `15` 次；当前 A `5/5`、B `5/5`、B1
  `3/5 stopped-on-pass`。
- Raid `UF-RAID-A1 V1 final` 的独立 `5` 次预算也已全部使用；流程错误 `2`
  不占额度且都没有产生额外 provider 图。终态为
  `repair-budget-exhausted / candidate-rejected`，禁止第六次。
- Raid A2 是新架构而不是 A1 attempt 6。`UF-RAID-A2-DONOR V1` 的 `5/5` 已
  耗尽，`production_authorized=false`，流程错误 `2` 不占额度；禁止第六次。
  attempt 5 已按 `sample-window-only` 单一例外接受并完成 P4/P5；生成合同仍
  关闭，下一门禁只剩 Turtle WoW P6。
- 三段 final 已吸收用户确认的可见结论并通过 `pass-final` 自包含预检；
  正式生产授权已独立取得，按 A→B→B1 顺序执行。
- 流程错误无生成证据时单独记录，不占额度。旧 V1／V2 失败像素禁止作为新段
  reference、edit、source 或 runtime。
- A attempt 1 raw `3533e8c…d5c0` 的材料方向成立，但 deterministic reviewer
  检出两个大型绿色开口，第一失败为 `one-connected-opening`；bbox
  `1425×224`，比例误差 `24.853972%`、各向异性 `19.906433%`，hard safe
  core 侵入 `90627 px`，左右隔离 `56/55`。无 candidate/source/runtime。
- `UF-A1 V3-A final.r1` 已作为 attempt 2 自包含有界 edit 正文：只保留同段
  前稿的粗旧皮革、左端粗缝线／局部夹片和右端偏心铆钉，明确删除双槽与
  横向分隔条并收敛到单开口、约 `1284×252` 与固定安全区。
- A attempt 2 已把开口收敛为单一连通孔；物理连通、bbox ratio、归一化
  anisotropy 和 isolation 均通过。但 hard safe core 仍侵入 `57077 px`，左右
  端板与上下内唇远宽于真实 `7/6 runtime px`，同时近连续等距缝线过于工业。
  无 candidate/source/runtime。
- `UF-A1 V3-A final.r2` 已作为 attempt 3 自包含有界正文：保持 attempt 2 的
  单开口、比例和粗旧皮革，把开口扩为至少 `1200×180`，端部／轨道压入
  `42/36 source px`，缩小两端身份并打断规则缝线。
- A attempt 3 把 hard safe core 从 `57077` 降到 `11360 px`，raw 单开口扩大
  到 `1236×212`；单开口、物理连通、ratio 和 anisotropy 保持通过。残余侵入
  主要来自左右内脸；bbox `1415×282` 的左右隔离 `62/59` 亦未过 `80`。
- `UF-A1 V3-A final.r3` 已作为 attempt 4 自包含有界正文：等比缩小并居中到
  约 `1284×252`，只把端部内脸再向外让约 `32/46 source px`，保持薄轨和
  单开口，同时打断连续绳状边缘节奏。
- A attempt 4 保持四项结构门禁通过，hard safe core 进一步降到 `9061 px`，
  但归一化开口仍约 x `71..1206`，左右应再让 `29/36 source px`；bbox
  `1392×281`、isolation `70/74` 仍未过。无 candidate/source/runtime。
- `UF-A1 V3-A final.r4` 是 A 段最后一次有界正文，只保留 topology／材料，
  要求整体等比缩至 `1284×252`，把左右竖边做成与横轨同厚并精确把内脸移至
  x `42/1242`。不再同时引入其他美术变化。
- A attempt 5 的 bbox `1298×249`、ratio `2.308299%`、anisotropy
  `2.256218%`、isolation `119/119` 均通过；唯一失败为 hard safe core
  `6355 px`。归一化开口约 x `65..1216`，竖边仍多 `23/26 source px`，不能
  按 `≤6 source px` 软边清理合同由 Python 删除。A `5/5`，禁止第六次；无
  candidate/source/runtime。
- B attempt 1 独立生成，没有 A／旧失败像素。单开口、物理连通和 isolation
  通过；bbox `1354×305` 的 ratio／anisotropy 均 `12.872683%`，hard safe
  core `66780 px`，故无 candidate/source/runtime。Target 的磨损左折痕与
  右黄铜损伤身份可保留。
- `UF-A1 V3-B final.r1` 已作为 attempt 2 自包含有界正文：收敛成约
  `1284×252` 的薄连续皮环，把开口扩为至少 `1200×180`，把右黄铜损伤压入
  极端 `42 source px` 并打断规则长轨系带。
- B attempt 2 已令 ratio `6.366135%`、anisotropy `5.985115%` 通过；单开口
  与物理连通继续通过。残余 safe `27311 px`，归一化四边约多
  `46/42/11/13 source px`；右 isolation `73` 次级失败。无 candidate/source/
  runtime。
- `UF-A1 V3-B final.r2` 已作为 attempt 3 自包含有界正文：只把四边内脸移动
  到 x `42/1242/y36/216`，整体收至约 `1284×252`，保持 Target 左磨损／右
  暗黄铜身份。
- B attempt 3 把 safe 降到 `10860 px`，但 bbox `1380×246` 过宽矮，ratio
  `10.098017%`、anisotropy `9.171843%` 回归失败；isolation `79/77`。
  归一化开口约 x `80..1208/y37..212`，上下轨已接近正确。
- `UF-A1 V3-B final.r3` 已作为 attempt 4 自包含正文：总宽减约 `96`、高增约
  `6`，左右内脸再让 `38/34 source px`，仅向下扩开口 `4px`，保留薄上轨。
- B attempt 4 仍保持单开口和单一物理连通体，但几何回归到 bbox
  `1454×247`，ratio `15.532181%`、anisotropy `13.444030%`；左右 isolation
  仅 `43/39`，hard safe core `7979 px`。连续压纹、规则系带、偏亮红皮和
  近整高右黄铜板也偏回工业皮具。无 candidate/source/runtime。
- `UF-A1 V3-B final.r4` 是 B 段最后一次正文：直接以画布绝对坐标锁定外 bbox
  x `126..1410/y386..638` 与单一纯绿开口 x `168..1368/y422..602`，同时恢复
  烟熏深胡桃、断续维修和非镜像 Target 身份；只用 B attempt 4 raw 作 Image 3。
- B attempt 5 令 bbox ratio `4.973681%`、anisotropy `4.738027%` 重新通过，
  但归一化开口仅约 x `87..1191/y43..208`，hard safe core `22649 px`，左右
  isolation `68/72`；工业式连续长边和整高右黄铜仍在。B `5/5`，禁止第六次；
  无 candidate/source/runtime。
- reviewer 首次逐 fleck flood 性能错误已改为线性 scanline run union-find；
  A attempt 4 child 在 provider 图已存在后缺 Pillow，退回 `sips` 确认原图为
  RGB 并复制；B 最终正文的首次 pre-generation commit 权限审核超时，重试后
  以相同内容成功；B1 attempt 1 在 `sips` 已完成正方形归一化后又尝试缺失的
  Pillow 做模式确认，随后以系统工具确认结果。四项作为流程错误 `4` 单列，
  没有额外 provider 图，不占额度。
- B1 attempt 1 的两对象、上下顺序、隔离、覆盖率、中性灰阶、明度、中心偏差
  和 Health／Power 层级全部通过。唯一失败是 source ratio：Health
  `582×207 = 2.81:1`，Power `689×76 = 9.07:1`，超过目标 `2:1/4:1` 的
  `25%` 门禁；无 candidate/source/runtime。
- `UF-B1 V2 final.r1` 只把两块重绘到绝对坐标：Health x `256..768/y128..384`
  的 `512×256`，Power x `256..768/y640..768` 的 `512×128`；保留 attempt 1
  灰阶材质、明度、隔离和层级，只用同段紧邻 `1024²` raw 作 Image 1。
- B1 attempt 2 已令 Health bbox `664×315 = 2.108:1`、误差 `5.40%` 通过；
  Power 从 `9.07:1` 收敛到 `664×124 = 5.355:1`，但误差 `33.87%` 仍超过
  `25%`。其余八项门禁继续通过；无 candidate/source/runtime。
- `UF-B1 V2 final.r2` 冻结 Health 与全部已通过属性，只把 Power 保持
  x `180..844` 的 `664 px` 宽并扩为 y `680..846` 的 `166 px` 高，即 `4:1`；
  attempt 3 只用同段紧邻 attempt 2 `1024²` raw 作为 Image 1。
- B1 attempt 3 已通过 `9/9` 门禁并按通过即停：Health `664×316`、ratio error
  `5.063291%`；Power `664×221`、ratio error `24.886878%`，均在冻结的
  `25%` 内。其他材料 `0 px`，min isolation `101 px`，mid gap `249 px`；
  中性、明度、中心与 Health-coarser／Power-calmer 层级均通过。
- candidate Health SHA `8d19ffe9…08e1f`、Power SHA `0668eddb…87f1`；真实
  排版 SHA `e9848b61…02ca`。这是进入用户审阅时的历史结论；用户接受后，
  exact candidate 已成为同 SHA source，attempt 4/5 未调用。

## B1 P4／P5 source、runtime 与接入

- source：`assets/source/unitframes/bars-v2/UnitFrameHealthFill_Master_v1.png`
  SHA `8d19ffe9…08e1f`；`UnitFramePowerFill_Master_v1.png` SHA
  `0668eddb…87f1`。`UF-B1-V2_SourceManifest_v1.json` 固定接受语句、生成来源、
  组件映射与禁止用途。
- runtime：`addon/AzerothExpeditionUI/Media/UnitFrames/`
  `UnitFrameHealthFillV1.tga` 为 `64×32`／SHA `bdee9186…6cd8`；
  `UnitFramePowerFillV1.tga` 为 `64×16`／SHA `8fbf0797…14cd0`。两张均为
  equal-channel 灰阶，透明 RGB 与可见绿溢色为 `0`。
- 确定性导出器：`tools/build_unitframes_bars_v2_runtime.py`；只做整图 LANCZOS
  缩放、透明清理与 32-bit RGBA TGA 写入。runtime manifest 为
  `assets/source/unitframes/bars-v2/UF-B1-V2_RuntimeManifest_v1.json`。
- adapter：`addon/AzerothExpeditionUI/Modules/UnitFrames.lua`，合同 `1.0`；pfUI
  bridge 只在 `api/unitframes.lua` 的两处 StatusBar 媒体读取点消费 marker。
  关闭 `/aeui unitframes` 或关闭作用域路由会恢复 Frame 配置的 pfUI 媒体。
- 真实排版：`generated/unitframes/bars/V2/runtime/real-layout-preview.png`，SHA
  `00ce1084…d247`；覆盖四种 Player 资源色、Target、TargetTarget、Focus 与
  宽度变化。外壳仍为非权威 pfUI fallback。展示区域合同 `9/9 pass`、
  violations `0`，报告 SHA `40171cf9…5f48`。
- 静态门禁：runtime 确定性像素、TGA round-trip、乘色中性、作用域应用／
  回退、pfUI ownership 与 repository contract 均由 tests 覆盖。fresh checkout
  package 为 `pass`、violations `0`，报告 SHA `48e109a4…131c`；仓库直接包含
  addon 媒体与 Lua，不需要目标设备运行 exporter。

## 历史终态

- `UF-A1 V1`：`5/5 / candidate-rejected / user-rejected`；最终端柱侵入动态
  安全区，用户明确拒绝例外。
- `UF-A1 V2-A V1`：`5/5 / repair-budget-exhausted`；端帽比例／隔离失败。
- `UF-A1 V2-A V2`：`5/5 / repair-budget-exhausted`；最终四件
  `139–142×798–799`、比例误差 `4.380476%–6.766917%`，等比 fit 仅
  `7×39–40`。没有 source、runtime 或 addon 改动。
- V2-B、UF-A2、旧 UF-B1 均未调用；历史额度 `0/5`。

## 下一门禁

Raid 的原 A1 合同已经终止，下一门禁不是 attempt 6。`UF-RAID-A2-DONOR V1`
已完成 `5/5`，attempt 5 已通过 `sample-window-only` 单一例外进入 P4/P5。
下一门禁是 Turtle WoW `1.18.1` P6：验证 40 框 A-D 分配、TGA 方向、标准
`70×33` 完整纹理、非标准宽度 `6/62/6`、Health／Power 经典乘色、Raid Icon／
Aura／距离／离线／复活层序、`33px` 高度失配回退及模块禁用回退。禁止第六次。

B1 下一门禁是 Turtle WoW `1.18.1` P6：验证 TGA 方向、Player／Target／
TargetTarget／Focus 的生命与 Mana／Rage／Focus／Energy 乘色、低血量裁切、
缩放、禁用回退和旧 SavedVariables。通过前保持 P5，`generated/unitframes/`
继续作为 ignored 中间证据。A／B 外壳仍为 `5/5` rejected，禁止第六次；是否
重开新合同另行决定。UF-A2 继续暂停。
