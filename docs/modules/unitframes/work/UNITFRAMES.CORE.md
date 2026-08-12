# Unit Frames 主资源批次 UF-PRIMARY V4

## 元数据

- 模块：`unitframes`
- 当前组件：`UF.PLAYER.SHELL`、`UF.TARGET.SHELL`、
  `UF.BAR.HEALTH.FILL`、`UF.BAR.POWER.FILL`
- 后续组件：`UF.TARGETTARGET.SHELL`、`UF.FOCUS.SHELL`、`UF.STATE.*`
- 当前版本：`UF-PRIMARY-V4-CANDIDATE-V1 / source v1`／`UF-B1 V2 final.r2 / source v1 / runtime 1.0`
- 子状态：`UF-A1 V4 source-accepted / P4`；
  V3-A／V3-B 保持 `repair-budget-exhausted / candidate-rejected` 历史终态；
  UF-B1 保持 `source-accepted / runtime-exported`
- 项目阶段：Player／Target 外壳 `P4`；Health／Power `P5`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 当前操作：`exact-source promotion / SHA freeze`
- 生成前模拟：`UF-PRIMARY-V4-SIM-V1`，deterministic local geometry
- 模拟 ImageGen：`0/0`
- V4 确定性 candidate：`accepted / source-promoted`；首选路径只读复用已
  接受 Unit Frames 材料 sample，实际 ImageGen `0/0`。两张 exact PNG 已晋级
  P4；P5 runtime、状态派生与 addon 接入仍未授权。
- 历史 V3 正式生产：A `5/5`、B `5/5`；B1 `3/5 stopped-on-pass`。
- 流程错误：`4`（审查器首次物理连通扫描性能错误；attempt 4 child 在 provider
  已生成后尝试 Pillow RGB 转换但环境无 Pillow，随后确认原图本身已为 RGB 并
  用原样复制完成；B attempt 5 的首个 pre-generation commit 权限自动审核超时，
  重试后以相同内容成功；B1 attempt 1 在已完成 `sips` 正方形归一化后又尝试
  Pillow 模式确认但环境无 Pillow，随后用系统工具确认 `1024² RGB`；四者均未
  产生额外 provider 图，不占生图额度）
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 用户 V4 请求：`requested / 2026-08-12`。用户原文为“重开 Player／Target
  完整外壳的新生产架构。”
- V4 模拟用户结论：`confirmed / 2026-08-12`。用户原文为“接受
  UF-PRIMARY-V4-SIM-V1，并允许将 Raid A2 已验收材料样本作为 Player／Target
  新透明 candidate 的只读输入。”该确认不接受模拟像素，也不授权 P4 source、
  P5 runtime 或 addon 接入。
- V4 像素用户结论：`accepted / 2026-08-12`。用户在审阅
  `UF-PRIMARY-V4-CANDIDATE-V1` 后原文为“确认, 进入下一阶段”。该语境只接受
  Player SHA `331b353f…617b` 与 Target SHA `256086c1…f81` 的 exact pixels，
  并授权进入 P4；不授权 P5 导出或 addon 接入。
- 用户架构决定：`accepted / 2026-08-11`。用户接受“每个角色生成完整外壳，
  Python 负责精确工程化”，并新增生命／法力、怒气、集中值、能量等资源条
  材质改造。
- 当前模拟用户结论：`confirmed / 2026-08-11`
- 用户确认范围：接受 `UF-PRIMARY-V3-SIM-V1` 所表达的完整外壳、旧马鞍／
  盾带式粗犷皮革、Player／Target 非镜像关系、Health／Power 层级与四资源
  运行时乘色方向；不接受模拟像素，不构成 production 或 source 授权。
- 正式生产授权：用户于 `2026-08-11` 明确授权 `UF-A1 V3-A final`、
  `UF-A1 V3-B final` 与 `UF-B1 V2 final`，按 A→B→B1 顺序；每段最多
  `5` 次实际生成、最坏 `15` 次，流程错误不占额度。A／B 固定 Image 1／2，
  attempt 1 无 Image 3；后续仅允许同段紧邻前稿作有界 edit 输入。B1 首次无
  图片，后续仅允许同段紧邻前稿。禁止跨段及 V1／V2 失败像素复用。
- B1 用户接受：`accepted / 2026-08-11`。用户原文为“接受 B1 attempt 3 的运行时视觉”；
  接受范围只含 exact Health／Power candidates、已审阅的确定性
  `64×32`／`64×16` 外观和 pfUI 经典乘色，不含 A／B 外壳或 UF-A2。

本文件只保留当前 V4 下一门禁与既有 P5 Bars 所需事实。V1、V2 的逐稿正文
已经存在于 Git 历史；V3 的终态正文与失败证据暂时保留在下方，待 V4 完成
runtime、实机验收与组件收口后再按清理规则压缩。

## UF-PRIMARY V4 新生产架构（当前）

### 重开的原因

- V3 的完整物件与粗旧皮革方向成立，但让 ImageGen 同时承担笔触、材料、外
  轮廓、单开口与 `7/6 runtime px` 安全边界。Player attempt 5 仍有
  `6355` 个 hard-safe 侵入像素，左右结构各多 `23/26 source px`；Target
  attempt 5 仍有 `22649` 个侵入像素，并保留连续工业长边。两段均在 `5/5`
  后终止，证明继续增加坐标描述无法稳定获得像素级外壳几何。
- V4 不改变用户已确认的“完整外壳、粗犷行军身份牌、Player／Target 非镜像”
  可见方向，只改变生产职责。所有 V1／V2／V3 rejected shell pixels 继续禁止
  作为 reference、edit、source、runtime 或 builder 输入。

### 生产职责与最终粒度

- 最终粒度仍是一角色一张完整透明资源：Player 与 Target 各有独立
  `1284×252 RGBA` source，并各自导出一张完整 `214×42` runtime；不是端帽
  atlas，不把两角色放入同一 source，不镜像，不把多张生成图拼成完整外壳。
- ImageGen 不再拥有任何 UI 几何。首选路径中不调用 ImageGen；确定性 builder
  从已经用户接受的 Unit Frames Raid A2 四块材料 sample 取材，独占外轮廓、
  Alpha、安静内衬、接触光、维修 mask、安全区、透明 RGB 清零、source／runtime
  导出和真实排版。模型也不再负责端部厚度、中央孔、坐标或比例。
- builder 可以以 mask 组合既有 leather／liner／brass／thread 材料、做固定
  crop／cover-fit、低频乘光、透明清理和缩放；不得凭空生成新笔触、修复材料
  美术、复用失败外壳、烘焙动态内容或改变 pfUI 功能。
- 这仍符合游戏粒度：donor/sample 只是上游材料输入，永远不被 Lua 加载；
  runtime 仍是 `UF.PLAYER.SHELL` 与 `UF.TARGET.SHELL` 两个真实逻辑资产。

### source、动态区与三切片

- source 固定 `1284×252`（runtime 的 `6×`）；runtime 固定 `214×42`。
- provider live bed 固定 source `x 42..1242 / y 36..216`，runtime
  `x 7..207 / y 6..36`。烟褐 liner 可位于 Health／Power 下方，但所有有厚度
  的皮革、黄铜、线、铆钉与状态响应必须裁在外围，不得覆盖动态条、文字或
  Button。层序为：状态短边 → 完整外壳／liner → pfUI bar 背景与填充 → pfUI
  文字、图标、Aura 与反馈。
- 标准 `W=200` 只挂一张完整 `214×42` 纹理，内部接缝 `0`。变宽时从同一角色
  source 派生 source `192/900/192`、runtime `32/150/32` 横向三切片；两个
  `32px` 固定区容纳沿上／下缘展开的身份维修，中央 `150px` 保持安静。
  这不同于 V3 的 `7/200/7`：切片固定区可以横跨顶／底缘，但任何可见维修仍
  不得进入 `x 7..W+7 / y 6..36` 动态区。高度永远不独立拉伸。
- 统一 UI Scale 只整体缩放完整 Frame／Texture；预演覆盖 `75%/100%/125%/150%`。

### Player／Target 非镜像 mask

- Player：上左外缘承载歪斜短暗铜夹片；左侧边有两条不等粗缝；右下外缘只有
  一枚偏心暗钉。维修沿外围转角展开，不能形成整高端柱。
- Target：左上只有被磨亮的皮革折边；右下外缘承载一段断裂氧化暗铜压片与
  暗裂。没有敌对红、精英冠饰、整高亮板或 Player 镜像。
- Hover／Aggro 不生图，分别从接受壳体 Alpha 派生两三段暖白／暗红短边；
  禁止完整霓虹矩形。

### 材料输入与受控回退

首选输入是 Raid A2 已接受且已受 manifest 管理的四个 immutable sample：

| 角色 | 文件 | SHA-256 | V4 用途 |
|---|---|---|---|
| leather | `assets/source/unitframes/raid-a2/RaidMaterialLeather_SampleV1.png` | `2f0ed03d…c41e` | 主体旧马鞍／盾带皮与局部皮补 |
| liner | `assets/source/unitframes/raid-a2/RaidMaterialLiner_SampleV1.png` | `8204723f…27ef8` | 动态条下方烟褐安静承托 |
| brass | `assets/source/unitframes/raid-a2/RaidMaterialBrass_SampleV1.png` | `f55657bb…06c27` | Player 短夹片、Target 断裂压片与暗钉 |
| thread | `assets/source/unitframes/raid-a2/RaidMaterialThread_SampleV1.png` | `86699161…e3a1` | 少量不等修补线 mask |

这是一项新的 downstream 用途，不修改或重新解释 Raid A2 source/runtime。若
用这些已接受材料做出的透明 candidate 在主单位框尺度上显得过软、过暗或缺乏
粗厚香草块面，必须先把客观证据交给用户；只有用户另行授权，才能激活一个
primary-specific material-only donor 段。该备用段最多 `5` 次实际 ImageGen，
流程错误不占额度；当前状态 `inactive / not-authorized`。

### 生成前模拟 `UF-PRIMARY-V4-SIM-V1`

- specification：`tools/specs/unitframes_primary_v4_simulation_v1.json`，SHA-256
  `e05222b512c40d7dcbf54297fbec00a5135752025579173bb83483fb39d37ea2`。
- renderer：`tools/render_unitframes_primary_v4_simulation_v1.py`，SHA-256
  `bd77d463bf879d0540c84299f957c0d9fcaa351a24dbc6e78d13dc135adfef08`。
- scene：`generated/unitframes/primary/simulation/V4/unitframes-primary-v4-sim-v1.scene.png`，
  `1600×900 RGBA`，SHA-256
  `dd6bb3459488c012013ba39eab1e3c5da3a85b5864f5bc539ca97482218d4622`。
- review：`generated/unitframes/primary/simulation/V4/unitframes-primary-v4-sim-v1.review.png`，
  `1600×1050 RGBA`，SHA-256
  `574ee88da298a011ca507bc31bcdf72840063c430bfd2caf031599977f7d00aa`。
- 模拟只用简单几何图形表达 shell；不复制两张 locked Chat 图或四块 accepted
  material sample 的像素。为真实信息密度，Health／Power 使用现有 P5 runtime
  纹理；模拟输出永远不得成为 source、runtime、裁切或 production 输入。
- 实际 ImageGen `0/0`；本地渲染错误 `0`。macOS 使用
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`／`3.12.12`。

### 实际展示区域与内部审查

- 合同：`tools/specs/unitframes_primary_v4_simulation_display_region_v1.json`，
  SHA-256 `644df0a305e53611c4c31a554e6d90cc6f303598db64a7bff95c9c490cf03ba1`。
- 报告：`generated/unitframes/primary/simulation/V4/display-region-report.json`，
  SHA-256 `1ba15de81fdc6d513b9039531af69257b50bf9a0648fe810b47ae4389feb6a32`。
- Player Mana／Rage／Focus／Energy、Target Rage＋Aggro、Player `W=160` 与
  Target `W=240` 共 `7/7 pass`，violations `0`。
- 审查结论：`displayable / simulation-reviewed`。Player 左上／Target 右下
  身份沿顶底外缘展开，不占 Health／Power；标准宽度保持完整纹理，变宽不移动
  身份件；四种 UI Scale 只整体缩放。图中扁平棕色、轮廓锯齿、线条与高光均
  是非权威几何占位，不能用于评价最终材料笔触。
- 模拟内审时记录的下一门禁：等待用户确认 `UF-PRIMARY-V4-SIM-V1` 的职责拆分、完整外壳
  粒度、`32/150/32` 伸缩、Player／Target 维修位置与真实密度。确认后先从已
  接受材料 sample 确定性构造透明 candidate 并提交 exact-pixel 审查；不得直接
  P5 接入，也不需要 ImageGen 授权。

用户已于 `2026-08-12` 确认上述模拟与职责拆分，并只授权 Raid A2 四块已验收
sample 作为新候选的只读输入；本段模拟门禁已关闭。确认不接受模拟像素，
ImageGen `0/0`，也不构成 source／addon 授权。

### 确定性透明候选 `UF-PRIMARY-V4-CANDIDATE-V1`

- 合同：`tools/specs/unitframes_primary_v4_candidate_v1.json`，SHA-256
  `156e1400…5089`；display contract：
  `tools/specs/unitframes_primary_v4_candidate_display_region_v1.json`，SHA-256
  `ffff3879…4cdd`。
- builder：`tools/build_unitframes_primary_v4_candidates_v1.py`；reviewer：
  `tools/review_unitframes_primary_v4_candidates_v1.py`；SHA-256 分别为
  `69e22e9a…b8b2`、`635a68ce…3e42`。两者只写 ignored
  `generated/unitframes/primary/candidates/V4/candidate-01/`，不会写
  `assets/source/`、addon 媒体或 Lua。
- Player source：`1284×252 RGBA`，SHA-256
  `331b353f294ae2e658e010ea59763a48bb08ba574b88e150fe3f5a2416bd617b`；
  Target source：`1284×252 RGBA`，SHA-256
  `256086c128561fdfa0717740701581d156ab811d88282c0098f9d3b4595acf81`。
- 100% runtime review 分别为 Player SHA `3bedcae1…e5a4` 与 Target SHA
  `f07b5ef6…347e`，均为 `214×42 RGBA`；标准 `W=200` 直接使用完整纹理，
  不存在内部拼缝。`W=160/240` 才使用 `32/150/32` 派生装配。
- 四块 material 与两块既有 bar 输入 SHA 全部匹配。两角色透明 RGB、外轮廓外
  Alpha、perimeter relief 侵入和 identity repair 侵入均为 `0`；live bed liner
  coverage 均为 `1.0`。Player／Target 既不相同也非水平镜像，身份维修均落在
  冻结固定区。
- display-region 为 `10/10 pass`、violations `0`；覆盖 Player 四资源、Hover、
  低血量、Target 正常／Aggro、`W=160/240`。真实排版另覆盖完整 bar、文字、
  Aura／Cast 邻接及 `75%/100%/125%/150%` 整体 UI Scale。
- technical review SHA `d418d3c1…6975`；真实排版 SHA `ffe78e11…951c`；
  多场景审阅板 SHA `c2d980bd…da54`；review report SHA `47a88d1c…0c4`。
- 首个确定性视觉输出的几何门禁已通过；人工审查后在同一冻结合同内把 Target
  右下铜片缩短、打断和降亮，提高 Player 粗缝可读性，并修正技术板裁切后重跑。
  这不是 ImageGen retry，实际 ImageGen 仍为 `0/0`。
- 本地流程错误 `1`：reviewer 首次写 JSON 时误用小写 Python 布尔值 `false`，
  在 report 写出前以 `False` 修正；candidate 已存在且没有触发生成调用，因此
  不涉及生图额度。
- P3 审阅时结论为 `candidate-reviewed / user-acceptance-pending / P3`；该历史
  门禁已由用户的“确认, 进入下一阶段”关闭。review-only Hover／Aggro 仍不是
  source，也未因外壳接受而自动成为最终状态资产。

### P4 接受与 source 固化

- source manifest：
  `assets/source/unitframes/primary-v4/UF-PRIMARY-V4_SourceManifest_v1.json`。
  用户接受语句、候选／审阅 SHA、材料 provenance、组件映射、禁止用途和下一
  门禁均由该 manifest 固定。
- Player 母版：
  `assets/source/unitframes/primary-v4/UnitFramePlayerShell_MasterV1.png`，
  `1284×252 RGBA`，SHA-256
  `331b353f294ae2e658e010ea59763a48bb08ba574b88e150fe3f5a2416bd617b`。
- Target 母版：
  `assets/source/unitframes/primary-v4/UnitFrameTargetShell_MasterV1.png`，
  `1284×252 RGBA`，SHA-256
  `256086c128561fdfa0717740701581d156ab811d88282c0098f9d3b4595acf81`。
- `tools/promote_unitframes_primary_v4_source_v1.py` 从 immutable Raid A2 sample
  重建两角色像素，在写入前同时校验 candidate spec SHA、RGBA pixel SHA 和
  完整 PNG SHA；本机存在 ignored candidate 时还逐图验证 exact pixel equality。
  晋级报告为 `pass / P4`，两张 source 与已审阅 candidate 逐字节相同。
- 当前结论：`source-accepted / P4`。`generated/` 仍只是 ignored 中间区；跨
  设备权威已转为上述 tracked source、manifest、builder 与 tests。没有导出
  TGA、没有修改 Lua／TOC／pfUI，也没有把 P3 review-only 状态图晋级。

## 美术基准继承

### 固定参考

- Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
  `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`。
  只继承 2004 年香草位图绘制尺度、粗厚可读块面、短促暗铜高光和综合色重；
  忽略屏幕构图、圆形头像、书本结构及图中的单位框示意。
- Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
  `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`。
  只继承深胡桃材料深度、左上暖光、手工误差和可信磨损节奏；忽略书页、
  书脊、木柱、龙饰、完整书框和大面积金属建筑。
- Prompt provenance：`docs/GLOBAL_ART_BASELINE.md`、
  `docs/modules/unitframes/ART_BASELINE.md`、
  `docs/modules/unitframes/SUBMODULE_ART_BASELINES.md`。

### 权威顺序

1. 全局与 Unit Frames 模块／子模块 Prompt，以及用户明确的“粗犷、不工整、
   香草艾泽拉斯”要求。
2. `SUBMODULES.md` 的真实对象、动态安全区、运行时所有权与禁止烘焙合同。
3. 两张 Chat 锁定图的受限跨模块职责。
4. pfUI 当前媒体只提供对象接口、尺寸与回退，不提供现代视觉方向。
5. V1／V2 失败候选只提供负面证据，不得成为 V3 reference、edit 或像素来源。

### 必须继承的视觉 DNA

- 2004 年香草魔兽二维手绘位图，低分辨率仍能读出的粗厚色块与明确切面；
- 深胡桃旧皮革为主，烟褐内衬为辅，氧化黄铜只作短促不连续修补；
- 左上暖光、低饱和综合色、短高光和真实接触阴影；
- 不规则必须来自手工裁切、受力、磨损与维修，而不是均匀随机噪声；
- 动态文字与条形区安静，装饰集中在外缘和两端。

### V3 组件级转译

- 外壳像旧马鞍带、盾牌背带或帐篷捆扎皮被远征队拆下重用，而不是家具包边、
  奢侈皮具或工业产品。
- Player 与 Target 各生成一张完整外壳，以完整物件保证光照、材料和接触关系；
  不再要求模型画四个极窄端帽 atlas。
- Player 左端修补偏重，Target 右端损伤偏重；同族但从零绘制，禁止镜像。
- Health／Power 使用两张独立无色灰阶矿物颜料纹；Health 更粗，Power 更窄、
  更密、更安静。pfUI 继续提供生命、Mana、Rage、Focus、Energy 语义色。

### 明确排除与冲突裁决

- 不继承 Chat 的书页、书脊、频道签、木柱、龙饰、完整书框或大面积金边。
- 当前 profile `portrait=off`；锁定图中的圆形头像与真实 provider 冲突，故不
  生成假头像槽。
- Chat 的金属建筑感与单位框“行军身份牌”冲突；单位框只保留少量断续暗铜。
- 用户要求的粗犷感与 V2 均匀皮革压纹／规则方帽冲突；V3 明确禁止等距缝线、
  对称铆钉、连续橙色滚边、重复卵石纹和照片级毛孔。

## 组件合同

### provider 映射

- `UF.PLAYER.SHELL` → `pfUI.uf.player`／`pfPlayer`；HP `200×25`，Power
  `200×4`，完整外接 `214×42`。
- `UF.TARGET.SHELL` → `pfUI.uf.target`／`pfTarget`；HP `200×25`，Power
  `200×4`，完整外接 `214×42`。
- `UF.BAR.HEALTH.FILL` → 每个目标对象的 `f.hp.bar`／`bartexture`；runtime
  donor `64×32`。
- `UF.BAR.POWER.FILL` → 每个目标对象的 `f.power.bar`／`pbartexture`；runtime
  donor `64×16`。
- `SetStatusBarColor`、`UnitPowerType`、数值动画、背景、Frame、Button、文字、
  Aura、点击、拖动和 SavedVariables 全部仍由 pfUI 负责。

### 完整外壳 source → runtime

- V3-A 与 V3-B 各自一次调用只生成一个完整 shell；不得把 Player／Target 放在
  同一 production atlas，不得逐端帽生成或把多张独立生成图拼成完整外壳。
- 每张生产画布 `1536×1024 RGB`，均匀 `#00FF00`，恰有一个正视正交空外壳。
- 模型目标 visible bbox 为约 `1284×252`（`214:42`）；P4 transparent master
  确定性归一化为 `1284×252 RGBA`，P5 导出为 `214×42`。
- 标准 `W=200` 直接挂一张完整 `214×42` Texture，内部接缝 `0`。
- 只有 `W≠200` 才从同一接受 source 派生左 `7×42`、中央 `200×42`、右
  `7×42` 三切片；中央带两端各在端帽下方重叠 `1 logical px`。端帽身份细节
  不得落在切分边界或只依赖一个 runtime 像素。
- 固定动态安全区为 runtime `x 7..207 / y 6..36`；HP 为
  `x 7..207 / y 6..31`，Power 为 `x 7..207 / y 32..36`。外壳 Texture 不接管
  鼠标，透明外扩不改变 Frame 或移动边界。

### Python 确定性后处理

允许按固定顺序执行：

1. 边缘连通绿色键和中央孔连通绿色键；
2. connected-component 语义检查、绿溢色清理和透明 RGB 清零；
3. 提取完整外壳 bbox，记录原始尺寸；
4. 将完整 bbox 独立 X／Y 归一化为 `1284×252`；
5. 验证并清理固定 source 安全区 `x 42..1242 / y 36..216`；
6. 导出完整 `214×42`、可变宽度三切片、状态边缘和缩放／真实排版预演。

硬门禁：

- 原始 bbox 相对 `214:42` 的比例误差不得超过 `8%`；`sx=1284/w` 与
  `sy=252/h` 的相对各向异性不得超过 `8%`，并写入报告。
- 固定 mask 只允许清除深入动态区不超过 `6 source px = 1 runtime px` 的抗
  锯齿、绿溢色或软阴影。更深的 `alpha>=128` 结构侵入必须退回。
- Python 不得补画皮革、移动铆钉、复制缝线、重组两端、改变拓扑、锐化出新
  轮廓或用旧失败稿补洞。若后处理会改变物件语义，必须重新生成。

### Health／Power 材质

- 一次 `UF-B1 V2` 调用可在一张 sheet 上生成两个彼此隔离的逻辑 swatch；这不
  违反组件粒度，因为拆分后仍是两张独立 runtime texture，且没有交互状态。
- 两者所有 RGB 通道必须相等；不得包含生命绿、法力蓝、怒气红、集中橙或能量
  黄。平均明度必须足以承受 `SetVertexColor` 乘色，避免乘色后变黑。
- Health 使用稍粗、稍深的低频矿物颜料刷痕；Power 使用更窄、更密、更克制的
  横向色料堆积。不得像皮革、纸张、布料、金属、玻璃或科技纹理。
- 不得含文字、数值、端帽、中心热点、全宽划痕、重复斜纹、镜面高光、透明
  缺口或色相。

### B1 确定性候选门禁

- reviewer：`tools/review_unitframes_bars_v2_candidate.py`。输入必须为
  `1024×1024 RGB`；绿色键后必须恰有两个 `area>=2000` 的物理连通体，其他
  非绿材料合计不得超过 `128 px`。
- Health 必须完整位于上半区、Power 完整位于下半区，中间纯绿间隔至少
  `64 px`；六个外侧方向的纯绿隔离均至少 `64 px`。
- Health／Power source bbox 分别以 `2:1`／`4:1` 为目标，原始比例误差各不
  超过 `25%`，bbox 材料覆盖率各至少 `72%`；通过后才可分别归一化为
  `256×128`／`256×64` candidate donor。
- 为容纳生成抗锯齿，只在各连通体向内腐蚀 `2 px` 的 core 测残余色相：RGB
  最大通道差的 mean 不超过 `8`、q95 不超过 `18`。只有先通过该门禁，才允许
  用固定 Rec.709 luminance 把微小残余色相变成 equal-channel 灰阶；明显着色
  候选必须退回，不能用灰阶转换掩盖。
- core 平均明度必须在 `85..210`，runtime `64×32`／`64×16` 的中间四分之一
  与全体均值偏差不得超过 `18`；Health stddev 至少 `4`、Power 至少 `2`，且
  Power 不得比 Health 更喧闹。上述门禁防止过暗、中心热点和层级反转。
- reviewer 始终输出技术板和真实 `200×25 + 200×4` 排版；只有全部客观门禁
  通过才输出 `health-candidate.png`／`power-candidate.png`，二者仍不是
  source/runtime，必须等待用户视觉接受。

### 动态排除、层序与回退

- 禁止烘焙单位名、等级、数值、头像、职业／敌对颜色、资源类型、Buff／
  Debuff、Raid Icon、治疗预测、状态文本、Button 或配置控件。
- 层序：bar 背景 → Health／Power fill → 外壳 → 运行时文字／图标；Hover／
  Aggro 由接受外壳 Alpha 派生的短边响应承载。
- 任一媒体缺失、尺寸不符或 adapter 失败时，只对相应对象恢复 pfUI 当前
  backdrop／bar／glow，不影响其他单位框或非视觉功能。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-PRIMARY-V3-SIM-V1`
- 目标：确认完整外壳在游戏内仍保持香草信息密度，并同时确认 Health／Power
  新材质和 Mana／Rage／Focus／Energy 运行时乘色关系。
- 真实对象：一组 Player、Target、TargetTarget、Focus；Player／Target 使用
  `214×42`，紧凑框按 `112×34`／`112×39` 作为当前邻接方向。
- 真实动态内容：HP、Power、名称、数值、Target Aura、Aggro；另在审阅板列出
  四个互斥 Power mode。四模式板是支持模式对照，不冒充同时存在的游戏实例。
- 邻接 UI：几何化战地旧书 Chat 与双头狮鹫动作条；没有复制接受资产像素。
- 用户需要判断：完整外壳是否比端帽 atlas 更自然；旧马鞍／盾带式粗犷程度；
  Player／Target 非镜像关系；Health 与 Power 的材质层级；四种资源经典色是否
  仍清楚。
- 非权威：最终笔触、皮革／颜料微纹理、Alpha、生产像素、远端屏幕位置、
  TargetTarget／Focus 的最终生产 art。
- 禁止用途：模拟图不得成为 source、runtime、裁切、切片或生产 reference／
  edit 输入。

### 本地执行

- specification：`tools/specs/unitframes_primary_v3_simulation_v1.json`，SHA-256
  `64a3f6b356fefe08766541ab911c468104e82708025aaf730417723419308765`
- renderer：`tools/render_unitframes_primary_v3_simulation_v1.py`，SHA-256
  `0c3b3329d394a33e1c30a99d3719666c6ef86b6f556be167ba1cd0b10c61efe8`
- command：`conda run -n py312 python tools/render_unitframes_primary_v3_simulation_v1.py`
- scene：
  `generated/unitframes/primary/simulation/V3/unitframes-primary-v3-sim-v1.scene.png`，
  `1600×900 RGBA`，SHA-256
  `c74b23e0de68f61ba056f669effa60ef275633c698f2d97686d2ec6ae98b1649`
- review：
  `generated/unitframes/primary/simulation/V3/unitframes-primary-v3-sim-v1.review.png`，
  `1500×920 RGBA`，SHA-256
  `3a2a39b27e5b50231ad7213cfc92567ba24317c6fa5557221faa9ebad1ec61dd`
- ImageGen：`0/0`；本地渲染错误：`0`
- 内部首轮修正：初稿两端黄铜形成近整高工业包边；在同一几何模拟版本内把
  黄铜收缩为局部修补、让皮革承担端部结构后重新渲染。没有 provider 调用，
  不属于生产 retry。

### 实际展示区域

- 合同：`tools/specs/unitframes_primary_v3_simulation_display_region_v1.json`，
  SHA-256 `9e4ae16061e56d1ecc8b1908de3fe23c402b9d82df74e7323878432f68c571ef`
- validator：`conda run -n py312 python
  .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py
  tools/specs/unitframes_primary_v3_simulation_display_region_v1.json --report
  generated/unitframes/primary/simulation/V3/display-region-report.json`
- report：`generated/unitframes/primary/simulation/V3/display-region-report.json`，
  SHA-256 `625f4dc012c0dfcc248156f82a1659d10278fc7112a218943344694181219e3b`
- 场景：Player Mana／Rage／Focus／Energy、Target Rage、`W=160` Player、
  `W=240` Target，共 `7/7 pass`，violations `0`。
- 结论：`displayable`。真实 HP／Power／文字／Button 区均位于安全区；本报告
  只证明几何，不证明最终材料、后处理或客户端混合。

### 用户方向结论

- 具体版本：`UF-PRIMARY-V3-SIM-V1`
- 状态：`confirmed / 2026-08-11`
- 用户明确接受的可见方向：
  1. 标准 Player／Target 各自是一张连续完整外壳，运行时仍保持香草单位框的
     信息密度，不回到四端帽 atlas，也不膨胀成厚重战争圣龛。
  2. 旧马鞍带、盾牌背带和帐篷捆扎皮承担主体；粗犷来自低频手工裁切误差、
     不均染色、烟熏泥渍和少量受力修补，不能退化为工业皮具。
  3. 氧化黄铜只作局部短修补；Player 左端修补偏重，Target 右端损伤偏重，
     两者同族但独立绘制、不得镜像。
  4. Health 与 Power 是两张不同的中性灰阶颜料纹；Health 更粗、更深，
     Power 更窄、更密、更安静，文字和数值仍是视觉主体。
  5. Mana／Rage／Focus／Energy 共享 Power 材质并由 pfUI 乘经典语义色；
     四种状态在当前综合色重下仍需清楚可辨，不烘焙独立彩色纹理。
  6. 与战地旧书 Chat 和经典双头狮鹫动作条邻接时保持同一时代和综合色重，
     但不复制书本、木柱、狮鹫或其他模块轮廓。
- 明确未接受：模拟图像素、最终笔触／微纹理、生产 Alpha、source、runtime
  或 addon 接入。
- 确认失效条件：完整外壳身份、材料层级、非镜像关系、bar 粗细层级、经典
  乘色或综合色重发生实质变化；纯技术透明提取、归一化和三切片派生不使确认
  失效。
- 下一门禁：三段 final 授权已取得；提交 `prompt-authorized` 状态后执行
  `UF-A1 V3-A final` attempt 1。

## 执行记录

- 日期：`2026-08-11`
- 操作：本地确定性生成前模拟；没有启动固定 executor 或 provider。
- 输入：只读模块文档与真实 pfUI 几何；没有上传图片。
- 输出：本文件“生成前模拟实例图”列出的 scene／review／display report。
- 实际生图：`0/0`；流程错误：`0`；循环终态：`simulation-confirmed`。

### Attempt 1 — `UF-A1 V3-A final`

- 固定正文 commit：`831e7ca`；正文 SHA-256
  `681336fc77d57ef44433304a93153e8a5764b31407aef87834ea666c9ff33c12`；
  完整 child prompt SHA-256
  `7a130485f4cf71d32f2832888dc98906af39b9d6829a974c30f6b2573f2398a1`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`；按授权
  attempt 1 没有 Image 3。
- 固定执行器 session：`019fefa5-786e-7043-8245-5fff7149ce67`；provider
  result：`ig_00f6d701e163924d016a7aca2bde888191923f186ba2934a2c.png`。
- untouched raw：`generated/unitframes/primary/V3A/attempt-01/raw.png`，
  `1536×1024 RGB`，SHA-256
  `3533e8c6812db70563e9af55796df3a44a39a2b2d80b2d29a6a0e5b5b0a2d5c0`。
- child log：`generated/unitframes/primary/V3A/attempt-01/fixed-child.log`，SHA-256
  `2c31cb3f96bfb2c0ff47fed79e0e5b003fd5b213b9ed7dc9db6fae8a440c0e19`。
- 实际 ImageGen：`1`；A 段累计 `1/5`。provider 已返回图像，故必须计数。
- 确定性 reviewer：`tools/review_unitframes_primary_v3_candidate.py`；report
  `generated/unitframes/primary/V3A/attempt-01/review/review-report.json`，SHA-256
  `707fe568bafd030685dc7c4bf78bb4c1e40d8f1a25807e11780e70a16552eca7`。
- technical review SHA-256 `41979274…fcea4`；real-layout preview SHA-256
  `32914208…dbbb`。两者都是 ignored review evidence，不是 source/runtime。

### Attempt 2 — `UF-A1 V3-A final.r1`

- 固定正文 commit：`9ef7538`；正文 SHA-256
  `1993a08376ad49e764a1b206fb112c627015a766b9586bbbd390098d65b44940`；
  完整 child prompt SHA-256
  `020e39a5794cc30561dae8ec3e4e3987ebd0e8bcbdee0719f9e8b148fdd6c47e`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  attempt 1 raw `3533e8c…d5c0` 作为 Image 3；没有其他输入。
- 固定执行器 session：`019fefb1-b0ec-7be3-b960-79f8552f552c`；provider
  result：`ig_0bb1dbfd754076b7016a7acd4c1d6c8191b6c6ddaec1fc75af.png`。
- untouched raw：`generated/unitframes/primary/V3A/attempt-02/raw.png`，
  `1536×1024 RGB`，SHA-256
  `ebee9397837c9d1fac0b54ba63fecd109c4a14f0a49afb83e43708eb0ac3c7a5`。
- child log：`generated/unitframes/primary/V3A/attempt-02/fixed-child.log`，SHA-256
  `3fb488fbd5b02ae87af49450666549701cb1aa4155e50cfb79789001c1adaa8d`。
- 实际 ImageGen：`1`；A 段累计 `2/5`。没有新增流程错误。
- review report：`generated/unitframes/primary/V3A/attempt-02/review/review-report.json`，
  SHA-256 `6e21892ddbaf75ed31b063c234760451a28a110be1447651cab3aabfd70b5cbc`；
  technical `c8ca3fd…914b6`；real-layout `f7a53169…42465`。

### Attempt 3 — `UF-A1 V3-A final.r2`

- 固定正文 commit：`7d63ff3`；正文 SHA-256
  `517c4e48776d05f175b5717cf923424bdfe117e8bbfa3f093bec7d3889300d40`；
  完整 child prompt SHA-256
  `7a03207fa0bf81be2fadde715619b8199427a7aa04d7e23fad2d6e8293e5cd14`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  attempt 2 raw `ebee939…c7a5` 作为 Image 3；没有其他输入。
- 固定执行器 session：`019fefb6-a669-7d02-99aa-ef855c7ff1e1`；provider
  result：`ig_0fee659bf266c9bb016a7ace94d1248191bc2d190683b9d8b6.png`。
- untouched raw：`generated/unitframes/primary/V3A/attempt-03/raw.png`，
  `1536×1024 RGB`，SHA-256
  `ff4690d494e01be1b04269c60e4db57f7c7487bf44e9c2daf4e59e843bdc0d59`。
- child log SHA-256
  `c2a3fb11a9bff259e464e410c59b11924f69bf84de76b6e9e332995ce1816e54`；
  实际 ImageGen `1`，A 段累计 `3/5`；无新增流程错误。
- review report SHA-256
  `9d1f4b8fe2b3db515315f16fb3330ff8d95ffdc04bf79c44238f130638c228cf`；
  technical `35b7e3a8…b3da`；real-layout `8114da64…b148`。

### Attempt 4 — `UF-A1 V3-A final.r3`

- 固定正文 commit：`8c76a77`；正文 SHA-256
  `14bf9fd552ba16918162ddd5970e38a41d6b868b5165ed3c9d72f5c4788791e1`；
  完整 child prompt SHA-256
  `d28cd854665394647557800152865492249430ff5697cf173e90719dcf7977ab`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  attempt 3 raw `ff4690d…0d59` 作为 Image 3；没有其他输入。
- 固定执行器 session：`019fefbb-902e-7e90-8b4c-60d7d1631746`；provider
  result：`ig_03694fc1b493feda016a7acfd630c081919de0847e9166b394.png`。
- untouched raw：`generated/unitframes/primary/V3A/attempt-04/raw.png`，
  `1536×1024 RGB`，SHA-256
  `109e778b99dee913162661d46160d4809fb9bfcf70699eb3c0923cc178d68f58`；
  child log SHA-256 `b58bb7d9…08fc`。
- 实际 ImageGen `1`，A 段累计 `4/5`。child 在图像已经生成后尝试用系统
  `python3/Pillow` 转 RGB，因无 Pillow 失败；随后 `sips` 证明 provider 原图
  已为 RGB 并原样复制成功。该落盘流程错误单列为 `2`，没有新 provider 图，
  不额外计生图额度。
- review report SHA-256
  `1debfd9f18c23de5a5455aa843c2631f3abdc0d827a16e7d70d12e93448aefdf`；
  technical `bb29073f…0233`；real-layout `a7d3a1ac…3c9d`。

### Attempt 5 — `UF-A1 V3-A final.r4`

- 固定正文 commit：`ac05681`；正文 SHA-256
  `87b24ec2a305909f6f9a536c0f80b61c9aca219e0f44bca1f1c59e775fb57d1b`；
  完整 child prompt SHA-256
  `bf0796cc8d578085215b88e18837cb7e21cb82af8bc5745a16133e1ce060fa2e`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  attempt 4 raw `109e778…8f58` 作为 Image 3；没有其他输入。
- 固定执行器 session：`019fefc0-ee60-71e0-8c85-b6d3857f73af`；provider
  result：`ig_0038fc959084e354016a7ad14418e08191a5d1e642ffe4cce9.png`。
- untouched raw：`generated/unitframes/primary/V3A/attempt-05/raw.png`，
  `1536×1024 RGB`，SHA-256
  `8e3e426b146be2bd615a6ded53c91e561d5ccb0831e29f00d769000888ed147b`；
  child log SHA-256 `bc52d21a…bf55`。
- 实际 ImageGen `1`，A 段累计并封顶 `5/5`；无新增流程错误。
- review report SHA-256
  `b7bad109a54300fcf312b6af68be759a076eee0ddeaef05048a703c2eea2f568`；
  technical `7c4e9275…2cbf`；real-layout `8f0121c1…f19c`。

### Target attempt 1 — `UF-A1 V3-B final`

- 固定正文 commit：`02f5407`；正文 SHA-256
  `f3a0f72238cf952ea9c9d43b5973d18f501a8705508dc76fd5dad07531c324ea`；
  完整 child prompt SHA-256
  `213b9ead1f2963aece097558008b40c1534aed11487ead033673d9ff2e8d7e2f`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`；按授权
  attempt 1 无 Image 3，且没有 A／V1／V2 像素输入。
- 固定执行器 session：`019fefc6-604b-7b72-892d-2e31a7a0cf93`；provider
  result：`ig_0bc8087cddf6f91b016a7ad2c72b208191bc45b5c774b4eda4.png`。
- untouched raw：`generated/unitframes/primary/V3B/attempt-01/raw.png`，
  `1536×1024 RGB`，SHA-256
  `ec3cddd5d1950e27d360d2199d83cd6ca2e4c893b57aa62515b7d274bfdb9389`；
  child log SHA-256 `a66772ca…9457`。
- 实际 ImageGen `1`，B 段累计 `1/5`。启动期间远程插件／Apps MCP 重连告警
  造成延迟，但固定 child 最终同一 session 生成并落盘成功，不作为独立失败或
  额外调用计数。
- review report SHA-256
  `1f60b66969f87668a7659a525a39035b6307fc467805867c0f17aef7c441c6f9`；
  technical `bf42516b…a19a`；real-layout `cd0b9b27…bcc87`。

### Target attempt 2 — `UF-A1 V3-B final.r1`

- 固定正文 commit：`2aeedae`；正文 SHA-256
  `3844780656dc95c3a347566828847a67ecf817eba8d96f7aea636f71bb4895bd`；
  完整 child prompt SHA-256
  `de84596455b31e5321b0a872e25e62cee03458e0f4d6004d8a0277b259220a22`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  B attempt 1 raw `ec3cddd…9389` 作为 Image 3；没有 A 或旧失败像素。
- 固定执行器 session：`019fefce-caae-7bd2-ae95-7f7f6769efd0`；provider
  result：`ig_0d477bb97649362e016a7ad515df308191b33d462b0d324abb.png`。
- untouched raw：`generated/unitframes/primary/V3B/attempt-02/raw.png`，
  `1536×1024 RGB`，SHA-256
  `0bc83f85f786965782b167cfb3ef39f16b0e2849cea31b44f01843b4e8758f02`；
  child log SHA-256 `2caa7672…fdcb`。
- 实际 ImageGen `1`，B 累计 `2/5`。同一 child 在生成前经历 response stream
  重连，随后同一 session 成功生成；没有第二次 provider 调用，故只计一次。
- review report SHA-256
  `9ddfebecdc3b50dc73bc5c1ed209f532e2da9e461f079f0a084d95bcfe529593`；
  technical `3b743060…75a6`；real-layout `dbd7b3f6…846f`。

### Target attempt 3 — `UF-A1 V3-B final.r2`

- 固定正文 commit：`8ce628b`；正文 SHA-256
  `5c64d397489e2c29b20ee7162cbfbd839c9e6860dc17671dc69053d6305998aa`；
  完整 child prompt SHA-256
  `249966e214978c19da0101d72a3bf59ecf23122ac898a72ce4c3d0d10b89d277`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  B attempt 2 raw `0bc83f8…8f02` 作为 Image 3；没有 A 或旧失败像素。
- 固定执行器 session：`019fefd5-47d4-7242-a625-19f829d1a8d1`；provider
  result：`ig_0d84e6f2b6c053b1016a7ad67f851c8191903b4b9539ad9de9.png`。
- untouched raw：`generated/unitframes/primary/V3B/attempt-03/raw.png`，
  `1536×1024 RGB`，SHA-256
  `2727a2a7f8055dc82df45b66cafaee0a571abadac1c1e9a587ba5cb2a26d755c`；
  child log SHA-256 `05e777ae…d18d`。
- 实际 ImageGen `1`，B 累计 `3/5`；无新增流程错误。
- review report SHA-256
  `cf8a5c0dfba873de5ea2b7087a9d35f3a8a14aadaeb3e3f876fb8c763d1b0a2e`；
  technical `7b0a58d7…a769`；real-layout `d2f846e3…865a`。

### Target attempt 4 — `UF-A1 V3-B final.r3`

- 固定正文 commit：`8a64d44`；正文 SHA-256
  `e643c05d0c75af83adfebbca2c15a96c77b31f16b567c47ba8671a26dfb56f92`；
  完整 child prompt SHA-256
  `8ed90861fc6d56197373ee14e3b740b35e2cda687279645e50fea4515fccc8c1`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  B attempt 3 raw `2727a2a…755c` 作为 Image 3；没有 A 或旧失败像素。
- 固定执行器 session：`019fefdf-2e84-7581-8f91-d9278709779e`；provider
  result：`ig_01a9a94a1aa4d703016a7ad99746f48191b4404b978a1f66cd.png`。
- untouched raw：`generated/unitframes/primary/V3B/attempt-04/raw.png`，
  `1536×1024 RGB`，SHA-256
  `2d7bb28bc90de80afc4c75698cd65af81d737ee377cc60f569b9a27e21c7d18e`；
  child log SHA-256 `0e7b2713…212c`。
- 实际 ImageGen `1`，B 累计 `4/5`。同一固定 session 的 response stream
  重试至 `5/5` 后仍返回一张 provider 图；这属于一次调用，不是额外流程错误。
- review report SHA-256
  `85a4c0688853cf3f4914c17949932a9a97d81650c3215bb1e9c83f3048eeb349`；
  technical `4d97e267…db5ab`；real-layout `bfb3e331…81a0`。

### Target attempt 5 — `UF-A1 V3-B final.r4`

- 固定正文 commit：`2e63721`；正文 SHA-256
  `f4e06adb733378e14ab98ad4345d9b58c08e42e412e77c24ee6b53fc368b1464`；
  完整 child prompt SHA-256
  `26c06e742f34469b71f6a4971afd70851001a562611249b66c1ee835a32bb794`。
- 固定输入：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…ab8`、同段紧邻
  B attempt 4 raw `2d7bb28…7d18e` 作为 Image 3；没有 A 或旧失败像素。
- 固定执行器 session：`019fefef-71c0-72c2-8363-d3f5e93a076e`；provider
  result：`ig_02eb0d9a3794f48e016a7adda9cb508191a2aa2e74ee3f2d2b.png`。
- untouched raw：`generated/unitframes/primary/V3B/attempt-05/raw.png`，
  `1536×1024 RGB`，SHA-256
  `92a988959c7e14285e2e460b7b26418abfcf1084dc9533bf146692a615097231`；
  child log SHA-256 `0b12fc9b…a50c`。
- 实际 ImageGen `1`，B 累计 `5/5`。同一 session 的一次 sampling stream
  重连后返回唯一 provider 图，未产生第二次调用。
- review report SHA-256
  `983d564992956208f40273e1d12045b85b56cd25800be4fc23cd48fe0f34f5d7`；
  technical `1e6b0508…e31b`；real-layout `f442b04c…2beb`。

### Bars attempt 1 — `UF-B1 V2 final`

- 固定正文 commit：`fff2730`；正文 SHA-256
  `0bc5a43283e7dcca63b398a232a0d33ea84b994d41d8d54320bb999718f753d0`；
  完整 child prompt SHA-256
  `f37d26100b524549cd8fb758cea5268da0ad3e7c196ce2d8a862f2603264ca55`。
- 固定输入：首次 generate，不上传任何图片；没有 A／B／旧 UF-B1 像素。
- 固定执行器 session：`019ff008-3ace-73b0-aaf1-f8acc99ad61d`；provider
  result：`ig_01d7646c04e49d70016a7ae374d8808191a37172fb8ef5d841.png`。
- provider untouched raw：
  `generated/unitframes/bars/V2/attempt-01/provider-raw.png`，`1254×1254 RGB`，
  SHA-256 `30cb1ffb5b40f719c583a95fbe5403b2b8e26464281b513a1b850d6f2c61d691`。
- 合同允许的同轴正方形归一化审查输入：
  `generated/unitframes/bars/V2/attempt-01/raw.png`，`1024×1024 RGB`，SHA-256
  `748c81a4edd6fbfcc2ac96aaf2c48ac3daeab1082aed515fadcf8c20d72a7abc`；
  child log SHA-256 `396eb2c6…2ca4`。
- 实际 ImageGen `1`，B1 累计 `1/5`。归一化后 child 的 Pillow 模式确认缺依赖，
  但 `sips` 已成功完成且系统工具确认 `1024² RGB`；无第二张 provider 图。
- review report SHA-256
  `090354b64ea9ef2d16acc6b42b530b227daf888a5b649cb2fc3bfa4b2c9a882f`；
  technical `53a08f82…a561`；real-layout `a16abc28…3f2d`。

### Bars attempt 2 — `UF-B1 V2 final.r1`

- 固定正文 commit：`a8f6937`；正文 SHA-256
  `bd38faffb7d68c23bd4354183f42d53c2168faaad55b0391042b7fd82062dffa`；
  完整 child prompt SHA-256
  `dc999839ddd715e3b7633e2d567464668caffb09143ee6233a885bbe18af767f`。
- 固定输入：同段紧邻 B1 attempt 1 `1024²` raw `748c81a…a7abc` 作为唯一
  Image 1；没有 A／B／旧 UF-B1 像素。
- 固定执行器 session：`019ff018-ab52-73c1-a13c-d7a8229b5e87`；provider
  result：`ig_0a35b3d0acc01a61016a7ae7c739888191bb705d3beef27029.png`。
- provider untouched raw：
  `generated/unitframes/bars/V2/attempt-02/provider-raw.png`，`1254×1254 RGB`，
  SHA-256 `e39be441fb529f05dae3fe492028d8ca731a7f84becf638f7a5925b602e4ef7e`。
- 同轴正方形归一化审查输入：
  `generated/unitframes/bars/V2/attempt-02/raw.png`，`1024×1024 RGB`，SHA-256
  `de8a0f22170031593cd19a26cf84f7ef1b35bff42cbc252fc8fdb8d085157990`；
  child log SHA-256 `736283cd…f7d2c`。
- 实际 ImageGen `1`，B1 累计 `2/5`；同一 session 的采样重连后返回唯一图，
  无新增流程错误。
- review report SHA-256
  `f7b4d0eaed9f8138e466f801c17e36424ca5a22c8b29dcccd688edbb6ca3c930`；
  technical `7c026c29…b007f`；real-layout `ad03d52c…95119`。

### Bars attempt 3 — `UF-B1 V2 final.r2`

- 固定正文 commit：`03c65d6`；正文 SHA-256
  `5f3469d0bd85165014b5ce46df3e65f540b405977322510a9b7fefc1d486fe4f`；
  完整 child prompt SHA-256
  `738833a94d386516a1dc4086f5d7572b560b5b34b542c6e229bf56e662c86a6c`。
- 固定输入：同段紧邻 B1 attempt 2 `1024²` raw `de8a0f2…57990` 作为唯一
  Image 1；没有 A／B／旧 UF-B1 像素。
- 固定执行器 session：`019ff025-52ee-7482-82b8-d0ba19258c02`；provider
  result：`ig_0129cf2eb265054c016a7aeaee19188191a0c0fbee9153c245.png`。
- provider untouched raw：
  `generated/unitframes/bars/V2/attempt-03/provider-raw.png`，`1254×1254 RGB`，
  SHA-256 `54e3f9bf86b44c2cafd962ddd6608147e1f4c48341397cc827118f9078936060`。
- 同轴正方形归一化审查输入：
  `generated/unitframes/bars/V2/attempt-03/raw.png`，`1024×1024 RGB`，SHA-256
  `161910f75db4f809b2669491b91a3c8077b6d50b22453feeecf7729284f514e1`；
  child log SHA-256 `978e62bf…2748`。
- 实际 ImageGen `1`，B1 累计 `3/5`；返回唯一 provider 图，无新增流程错误。
- review report SHA-256
  `6e19b234032843ea9f35ea39bfff8ddc258d5814b70faa35365dde3f032cf798`；
  technical `05c9e513…1adc`；real-layout `e9848b61…02ca`。
- 通过后候选：Health `health-candidate.png` SHA-256
  `8d19ffe95d5314b463d88be793568667aa555460a955364a636e6ddc76508e1f`；
  Power `power-candidate.png` SHA-256
  `0668eddbb6c7644312eecc3c1d03f555b937d5307e48444ca520a6674cb387f1`。

## 审查记录

- 语义／物理：Player／Target 是各自完整的连续外壳；Health／Power 是独立
  动态纹理角色，颜色、数值与状态未烘焙。
- 透视／图层：正视正交；bar 背景 → fill → 外壳 → 文字／图标的层序明确。
- 美术一致性：内部首轮发现整高黄铜包边并已收缩；当前几何图以旧皮革承担
  结构、黄铜只作局部修补。最终笔触与微纹理仍非权威。
- 对象／状态：真实 Player／Target，加紧凑框邻接；Power 支持 Mana／Rage／
  Focus／Energy 四种互斥运行时状态。
- 装配／尺寸：标准完整 `214×42`；可变 `W=160/240` 的动态区合同通过。
- 实际展示区域：`7/7 pass`，violations `0`，报告与 SHA 见上。
- 结论：`displayable / simulation-confirmed`；可准备最终 production 授权，
  仍不允许 source、runtime 或正式生图。
- 用户结论：`accepted UF-PRIMARY-V3-SIM-V1 / 2026-08-11`；只接受可见方向。

### Attempt 1 内审 — `UF-A1 V3-A final`

- 可保留：深胡桃粗旧马鞍皮、左上暖光、粗厚香草块面、左端粗缝线与局部
  暗铜夹片身份、右端偏心暗铆钉；完整物件的视觉整体性成立。
- 第一失败门禁：`one-connected-opening`。检测到 `2` 个大型封闭绿色开口：
  上部 `1004×83 / 80567 px`，下部 `1000×29 / 27390 px`；两者之间存在完整
  横向皮革分隔条。Health／Power 必须是同一绿色开口内的运行时层，不允许由
  source 外壳分成双槽。
- 物理连通：主材料 `1` 个连通体，`pass`。
- bbox：`1425×224`，相对 `214:42` 比例误差 `24.853972%`；独立归一化
  各向异性 `19.906433%`，均超过 `8%`。
- 动态安全区：hard core 内 `alpha>=128` 为 `90627` px，`fail`；主要来自
  双槽分隔条、过宽左夹片和端部结构，不允许由 Python 擦除。
- 隔离 L/T/R/B：`56/403/55/397`，左右小于 `80`，`fail`。
- 结论：`candidate-rejected / repairable`；未产出 `candidate.png`，不得进入
  source/runtime。下一稿只在同段紧邻 raw 上有界 edit，保留上述材料与身份，
  删除双槽拓扑、收窄端部、把 bbox 修为约 `1284×252` 并清空固定安全区。

### Attempt 2 内审 — `UF-A1 V3-A final.r1`

- 已修复：大型封闭绿色开口从 `2` 个变为 `1` 个且包含 canvas center；材料
  仍为 `1` 个物理连通体。bbox `1358×255`，比例误差 `4.518966%`、各向异性
  `4.323585%`；隔离 L/T/R/B `85/386/93/383`。上述五项均通过合同。
- 第一且唯一客观失败：`dynamic-safe-core`，hard core 内 `alpha>=128` 仍有
  `57077 px`。单开口 raw 仅约 `980×157`；归一化后左右端板和上下内唇仍深入
  应当留给 HP／Power／文字的 `1200×180` 动态区。
- 可见美术问题与同一失败同源：左端仍是大面积整高黄铜支架／缝线板，右端
  仍是宽大压纹端板；长轨存在近连续等距缝线和圆绳式包边，显得比 Chat 更像
  工业皮具。
- 保留：单开口拓扑、正确总体比例、粗旧深胡桃皮、暖光、左右不镜像身份。
  修复：把开口扩至 source safe `x42..1242/y36..216`，把端部身份压进真实
  `42 source px = 7 runtime px`，打断长轨规则缝线，禁止 Python 删除结构。
- 结论：`candidate-rejected / repairable`；仍无 candidate/source/runtime。

### Attempt 3 内审 — `UF-A1 V3-A final.r2`

- 保持通过：单一开口、单一物理连通体、ratio、anisotropy。bbox
  `1415×282`，比例误差与各向异性均为 `1.521177%`。
- 显著改善：hard safe core 从 attempt 2 的 `57077` 降到 `11360 px`；单一
  raw 开口扩大为 `1236×212`。归一化后上下轨已经接近合格，残余侵入主要在
  左右端部内脸。
- 第一失败仍为 `dynamic-safe-core`。估算归一化开口约从 x `74` 到 `1196`，
  仍未覆盖必须的 x `42..1242`；需要再从左端让出约 `32 source px`、从右端
  让出约 `46 source px`，等价约 `5/8 runtime px`。
- 次级失败：bbox 左右绿色隔离 `62/59`，低于审查器最低 `80`；整体应当等比
  缩小并居中到约 `1284×252`，不能只横向压扁。
- 美术审查：端板已经明显收窄，但长边仍有连续绳状高光／重复细点，整体轮廓
  略显工整；下一稿只允许打断边缘节奏和添加低频手裁误差，不改变已通过拓扑。
- 结论：`candidate-rejected / repairable`；无 candidate/source/runtime。

### Attempt 4 内审 — `UF-A1 V3-A final.r3`

- 保持通过：单一开口、单一物理连通体、ratio、anisotropy。bbox
  `1392×281`，比例误差／各向异性 `2.777131%`。
- hard safe core 从 `11360` 降为 `9061 px`，但仍非软边级残留，不能由 Python
  清除；归一化开口约 x `71..1206`，左右仍需再让约 `29/36 source px`。
- 隔离 L/T/R/B `70/377/74/366`，左右仍低于 `80`；整体 occupancy 仍约
  `90.6%` canvas width，没有达到目标 `83.6%`。
- 视觉上顶部／底部边缘节奏有所破损，不再完全等距缝合；材料与单开口方向可
  保留。端部依旧比横轨厚，仍像窄端帽而不是同厚度薄皮环。
- 结论：`candidate-rejected / final-repair-available`；A 只剩 `1` 次。最终 r4
  只允许等比缩小和把两条竖边减至与横轨同厚，不再同时追求其他变化。

### Attempt 5 内审 — `UF-A1 V3-A final.r4`

- 通过：单一开口、单一物理连通体、bbox ratio、归一化 anisotropy、绿色
  isolation。bbox `1298×249`，比例误差 `2.308299%`、各向异性
  `2.256218%`；隔离 L/T/R/B `119/395/119/380`。
- 第一且唯一客观失败仍为 `dynamic-safe-core`：`alpha>=128` 为 `6355 px`。
  归一化开口约 x `65..1216`；相对必须的 x `42..1242`，左右竖边仍各深入
  约 `23/26 source px = 3.8/4.3 runtime px`。这不是 `≤6 source px` 的抗
  锯齿或软影，Python 清除会改变物件结构，合同禁止。
- 视觉：完整单开口、粗旧深胡桃皮与非镜像端部在真实 `214×42` 排版中可读，
  但两端依然比横轨明显更宽，且整体仍较规整；可作为用户审查证据，不能成为
  candidate/source/runtime。
- 结论：`repair-budget-exhausted / candidate-rejected`。A `5/5`，禁止第六次
  调用。按用户授权，A 终态不阻止独立 B／B1 继续；最终统一向用户呈现 A 的
  失败边界及 B／B1 的终态。

### Target attempt 1 内审 — `UF-A1 V3-B final`

- 可保留：单一绿色开口、单一物理连通体、深胡桃粗旧皮、左侧安静磨损折痕、
  右侧独立黄铜损伤身份；与 Player 非镜像且没有跨段像素复用。
- 第一失败：`bbox-ratio`。bbox `1354×305`，source ratio `4.439344`，相对
  `214:42` 误差 `12.872683%`；归一化各向异性同为 `12.872683%`，均超过
  `8%`。
- 动态安全区：raw 单开口约 `1039×165`；hard core `alpha>=128` 为
  `66780 px`。左右端块、上下厚轨和右侧近整高亮黄铜板都深入动态区，不能由
  Python 清除。
- 画布 isolation `84/356/98/363` 通过；比例与安全区修复时仍应把 bbox 收到
  约 `1284×252`，不能继续占满画布。
- 美术：材料和不对称关系成立；等距长轨系带与亮黄铜整高板偏工业／轻浮。
  r1 保留 Target 身份但把它们压进 `42 source px`，轨道压进 `36 source px`，
  开口扩为至少 `1200×180`。
- 结论：`candidate-rejected / repairable`；无 candidate/source/runtime。

### Target attempt 2 内审 — `UF-A1 V3-B final.r1`

- 已修复：bbox ratio `6.366135%`、归一化 anisotropy `5.985115%` 均回到
  `≤8%`；单一开口和单一物理连通体继续通过。
- 第一失败：`dynamic-safe-core=27311`。bbox `1382×255`；归一化开口约
  x `88..1200/y47..203`，相对 required x `42..1242/y36..216`，四边仍分别
  侵入约 `46/42/11/13 source px`。
- 次级失败：isolation L/R `81/73`，右侧低于 `80`。整体等比收至约
  `1284×252` 后可恢复充足绿色，不需要改变 topology。
- 美术：Target 左磨损、右损伤黄铜和粗旧皮层次仍成立；右端仍偏整高，需随
  竖边一起压入最后 `42 source px`，不能成为亮板。
- 结论：`candidate-rejected / repairable`；无 candidate/source/runtime。

### Target attempt 3 内审 — `UF-A1 V3-B final.r2`

- 保持通过：单一开口、单一物理连通体。hard safe core 从 `27311` 降到
  `10860 px`，开口进一步扩大。
- 回归失败：bbox `1380×246`，ratio error `10.098017%`、anisotropy
  `9.171843%`，重新超过 `8%`；物件过宽且略矮。
- 归一化开口约 x `80..1208/y37..212`。上下轨已接近合同；残余 safe 主要在
  左右端，需再让 `38/34 source px`，底边只需约 `4 px`。
- 次级 isolation L/R `79/77`，整体收宽到 `1284` 并居中即可恢复，不需要
  改变材料或身份。
- 结论：`candidate-rejected / repairable`；r3 只修 bbox ratio 和左右端厚度，
  不再动已经接近正确的上轨。无 candidate/source/runtime。

### Target attempt 4 内审 — `UF-A1 V3-B final.r3`

- 保持通过：恰有一个包含画布中心的连通绿色开口，材料仍是一个物理连通体；
  没有烘焙生命、资源、名称或图标。
- 几何回归：bbox 扩为 `1454×247`，source ratio `5.886640`，ratio error
  `15.532181%`、anisotropy `13.444030%`，明显超过 `8%`。左右绿色隔离仅
  `43/39`，也低于 `80`。
- 归一化开口约 x `69..1213/y38..213`；hard safe core 内仍有
  `7979` 个 `alpha>=128` 像素。上下轨接近，但两端各约多出 `27/29 source
  px` 的结构，不能由允许的 `≤6 px` 清理删除。
- 美术回归：完整外壳可读，但长边变成连续压纹滚边，左侧等距系带、右侧近
  整高黄铜板和规整圆角共同形成工业皮具观感；综合色也比锁定 Chat 基准偏亮、
  偏红。最终 r4 需保留 Target 左静右损身份，改回烟熏深胡桃、断续维修和
  手裁低频误差。
- 结论：`candidate-rejected / final-repair-available`；B 只剩 `1` 次。r4 使用
  画布绝对坐标冻结外 bbox 与纯绿内矩形，避免再次依赖比例描述。无
  candidate/source/runtime。

### Target attempt 5 内审 — `UF-A1 V3-B final.r4`

- 通过：单一连通开口、单一物理连通外壳、bbox ratio 与归一化 anisotropy。
  bbox `1396×261`，ratio error `4.973681%`、anisotropy `4.738027%`，均在
  `8%` 内。
- 第一失败：`dynamic-safe-core=22649`。raw 开口为 `1200×170`，归一化后约
  x `87..1191/y43..208`，仍没有覆盖必须的 x `42..1242/y36..216`；两端和
  上下内唇都是结构性侵入，远超过可清理的 `≤6 source px`。
- 次级失败：绿色 isolation L/R `68/72`，低于 `80`。这不是单纯透明软边，
  不能在 P4 通过 bbox-fit 或色键修复。
- 美术：综合色比 attempt 4 更深、更接近烟熏胡桃；但连续压纹长边、规则左侧
  系带、宽圆角和近整高右黄铜板仍像工业皮具。真实 `214×42` 排版可读，但
  不满足冻结的粗犷非工整方向和动态安全区。
- 结论：`repair-budget-exhausted / candidate-rejected`。B `5/5`，禁止第六次；
  未生成 `candidate.png`，不得进入 source/runtime/addon。按授权继续独立 B1，
  最终再由用户决定 A／B 是否重开合同。

### Bars attempt 1 内审 — `UF-B1 V2 final`

- 已通过 `8/9` 门禁：恰好两个连通 swatch、其他材料 `0 px`；Health 在上、
  Power 在下，中间隔离 `277 px`；全部外侧隔离至少 `167 px`；两块覆盖率
  `99.52%/98.55%`。
- 中性与乘色通过：Health core chroma mean/q95 `3.24/6`、Power
  `3.63/7`；平均明度 `119.04/120.15`。中心偏差仅 `1.02/1.01`，runtime
  stddev `8.39/7.02`，Health 较粗、Power 较静的层级成立。
- 唯一失败为 `swatch-ratios`。Health bbox `582×207 = 2.811594:1`，相对
  `2:1` 误差 `40.579710%`；Power bbox `689×76 = 9.065789:1`，相对 `4:1`
  误差 `126.644737%`。直接独立归一化会过度扭曲笔触，超过冻结的 `25%`
  source 门禁，不能作为 candidate。
- 视觉：灰阶矿物颜料、无框无标签、低频 Health 与克制 Power 在真实四资源
  乘色排版中方向成立；下一稿只把两块重绘到绝对 `512×256`／`512×128`，
  保留当前明度、灰阶、笔触与隔离。
- 结论：`candidate-rejected / repairable`；B1 `1/5`，无 candidate/source/
  runtime。attempt 2 只用同段紧邻 `1024²` raw 作唯一 Image 1。

### Bars attempt 2 内审 — `UF-B1 V2 final.r1`

- 继续通过：恰好两对象、其他材料 `0 px`、上下顺序、绿色隔离、覆盖率、中性
  灰阶、明度、中心偏差和 Health／Power 层级。外侧隔离均至少 `137 px`，
  中间 gap `272 px`。
- Health 已修复：bbox `664×315 = 2.107937:1`，相对 `2:1` 误差仅
  `5.396825%`，通过 `25%` source 门禁；core value `120.27`、runtime
  stddev `7.37`，可冻结。
- 唯一失败仍为 `swatch-ratios` 中的 Power：bbox
  `664×124 = 5.354839:1`，相对 `4:1` 误差 `33.870968%`。其 neutral、value、
  centre 与 hierarchy 均通过，不需要重画材料语言。
- 下一稿冻结 Health bbox 与所有纹理，只把 Power 的同宽矩形从 `124 px` 增高
  到约 `166 px`，绝对目标 x `180..844/y680..846`；保留纯绿 gap 和无框结构。
- 结论：`candidate-rejected / repairable`；B1 `2/5`，无 candidate/source/
  runtime。attempt 3 只用同段紧邻 attempt 2 `1024²` raw 作为唯一 Image 1。

### Bars attempt 3 内审 — `UF-B1 V2 final.r2`

- 客观结果：`9/9 pass`，`first_failure=null`。恰好两个连通 swatch、其他材料
  `0 px`、Health 在上、Power 在下；mid gap `249 px`，六向 isolation 最低
  `101 px`，覆盖率 `99.61%/99.72%`。
- 比例：Health bbox `664×316 = 2.101266:1`，误差 `5.063291%`；Power bbox
  `664×221 = 3.004525:1`，误差 `24.886878%`。二者均在预先冻结的 `25%`
  source 门禁内，可按合同确定性归一化为 `256×128`／`256×64` candidate。
- 中性与乘色：Health core chroma mean/q95 `7.77/11`、Power `6.18/9`；
  明度 `119.47/123.16`。runtime 中心偏差 `0.70/0.86`，stddev
  `7.65/5.68`，Health 更粗、Power 更静；四资源真实乘色保持清楚。
- 视觉内审：两块都是无框、无标签的哑光灰阶矿物颜料；无中心热点、玻璃光、
  斜纹或现代进度条效果。真实 `200×25 + 200×4` 排版中纹理可见但不压过名称、
  数值和经典资源色，符合已确认方向。
- 当时内审结论：`candidate-ready / internal-pass / user-review`。循环按通过即停
  终止于 B1 `3/5`；attempt 4/5 不调用。
- 用户随后于 `2026-08-11` 接受该运行时视觉；两张 exact candidate 已逐字节
  晋升为 source 并完成 P4/P5。该接受不会改变 A／B 的拒绝终态。

## B1 P4／P5 接受与插件接入

- exact source：Health
  `assets/source/unitframes/bars-v2/UnitFrameHealthFill_Master_v1.png`，
  `256×128 RGBA`，SHA-256
  `8d19ffe95d5314b463d88be793568667aa555460a955364a636e6ddc76508e1f`；
  Power `UnitFramePowerFill_Master_v1.png`，`256×64 RGBA`，SHA-256
  `0668eddbb6c7644312eecc3c1d03f555b937d5307e48444ca520a6674cb387f1`。
  二者与用户接受的 attempt 3 candidate 字节完全一致。
- source manifest：
  `assets/source/unitframes/bars-v2/UF-B1-V2_SourceManifest_v1.json`；固定用户原文、
  provider／prompt／review provenance、组件映射、禁止用途与 runtime export。
- exporter：`tools/build_unitframes_bars_v2_runtime.py`；使用 macOS
  `conda run -n py312 python`，只作各自整图 LANCZOS 缩放、透明 RGB 清零和
  32-bit RGBA TGA 写入，不裁切、不镜像、不重画、不混入外壳像素。
- runtime Health：
  `addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga`，
  `64×32`，文件 SHA `bdee918674484be3a70ef1f64b3db9f326b0045560ce52234015ca1ba7836cd8`，
  pixel SHA `22d610c4…b572`，mean/stddev `119.586914/7.651801`。
- runtime Power：
  `addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga`，
  `64×16`，文件 SHA `8fbf0797e4b3562a02ed3b7f19e7b7e100c832cf1c02b6fd172fc06317314cd0`，
  pixel SHA `411c54d8…02f0`，mean/stddev `123.204102/5.681517`。两者均为
  equal-channel，visible green spill 与 transparent RGB nonzero 均为 `0`。
- runtime manifest：
  `assets/source/unitframes/bars-v2/UF-B1-V2_RuntimeManifest_v1.json`；合同 `1.0`。
  AEUI `Modules/UnitFrames.lua` 只给 `player`、`target`、`targettarget`、`focus`
  设置媒体 marker；pfUI `api/unitframes.lua` 只在原 StatusBar 媒体读取点消费。
  Party／Raid／Pet／FocusTarget／fallback 不属于本批次。
- 动态所有权不变：Health／reaction 与 Mana／Rage／Focus／Energy 颜色、数值、
  裁切、动画、背景、文字、图标、事件、点击区域和 SavedVariables 继续由 pfUI
  提供。关闭模块或作用域路由时恢复每个 Frame 配置的 pfUI bar media。
- 真实排版：`generated/unitframes/bars/V2/runtime/real-layout-preview.png`，SHA
  `00ce1084ca7d317f976c6048cde97fd7502a3e58f807d26b6d458b25ef09d247`；
  按 `1 image px = 1 UI px` 覆盖四资源 Player、Target、TargetTarget、Focus 和
  宽度变化。展示区域合同 `9/9 pass`、violations `0`，报告 SHA
  `40171cf9dde327882a9a9c0365c8911fcb2ac21b95af8377ad317a25bed25f48`。
- 目标设备直接使用仓库内 `addon/pfUI` 与 `addon/AzerothExpeditionUI`，不需要
  再运行生成、exporter 或补丁。fresh-checkout addon package 为 `pass`、
  violations `0`，报告 SHA-256
  `48e109a495bc702f7c5d63993577c4e46ef0d3765a05c6a1b4b18dd6e167131c`。
  P6 Turtle WoW 实机验证仍待进行。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `UF-PRIMARY-V3-SIM-V1` | 本地 scene／review；ImageGen `0/0`；display `7/7 pass`；用户于 `2026-08-11` 确认 | `simulation-confirmed` | 三段 final 已另行授权；进入 A attempt 1 |
| `UF-A1 V3-A final` attempt 1 | session `019fefa5…ce67`；raw `3533e8c…d5c0`；review `707fe568…ca7`；ImageGen `1/5` | `candidate-rejected / repairable`；第一失败为双开口；无 candidate/source/runtime | `final.r1` 删除分隔条并形成单一开口；bbox 约 `1284×252`；端部与轨道退出 hard safe core；保留粗旧皮革及左右身份 |
| `UF-A1 V3-A final.r1` attempt 2 | session `019fefb1…552c`；raw `ebee939…c7a5`；review `6e21892…5cbc`；A `2/5` | 单开口、物理连通、ratio、anisotropy、isolation 通过；`dynamic-safe-core=57077` 失败；无 candidate/source/runtime | `final.r2` 扩开口至 `1200×180`，把端板／轨道压进 `42/36 source px`，缩小夹片／铆钉并打断工业式缝线 |
| `UF-A1 V3-A final.r2` attempt 3 | session `019fefb6…f1e1`；raw `ff4690d…0d59`；review `9d1f4b8…28cf`；A `3/5` | safe intrusion 降至 `11360`；单开口／物理／ratio／anisotropy 通过；isolation `62/59` 次级失败；无 candidate/source/runtime | `final.r3` 等比缩到约 `1284×252`，只把端部内脸再向外让 `32/46 source px`，保持薄轨并打断连续绳边 |
| `UF-A1 V3-A final.r3` attempt 4 | session `019fefbb…1746`；raw `109e778…8f58`；review `1debfd9…efdf`；A `4/5` | safe intrusion `9061`；ratio/aniso 通过，isolation `70/74` 失败；无 candidate/source/runtime | 最终 `r4` 仅等比缩至 `1284×252`，把竖边做成与横轨同厚并将内脸精确移至 x `42/1242` |
| `UF-A1 V3-A final.r4` attempt 5 | session `019fefc0…73af`；raw `8e3e426…147b`；review `b7bad10…f568`；A `5/5` | 除 `dynamic-safe-core=6355` 外全部通过；竖边仍深 `23/26 source px`；`repair-budget-exhausted`；无 candidate/source/runtime | 禁止第六次；保留终态 review，继续已授权独立 B／B1，最终等待用户决定 A 是否改合同或开新授权 |
| `UF-A1 V3-B final` attempt 1 | session `019fefc6…cf93`；raw `ec3cddd…9389`；review `1f60b66…c6f9`；B `1/5` | 单开口／物理／isolation 通过；ratio/aniso `12.872683%`、safe `66780` 失败；无 candidate/source/runtime | `final.r1` 收至约 `1284×252` 薄皮环，开口至少 `1200×180`，右黄铜损伤压进极端 `42 px`，打断规则系带 |
| `UF-A1 V3-B final.r1` attempt 2 | session `019fefce…efd0`；raw `0bc83f8…8f02`；review `9ddfebe…9593`；B `2/5` | ratio/aniso 通过；safe `27311`、右 isolation `73` 失败；无 candidate/source/runtime | `final.r2` 四边分别让出 `46/42/11/13 source px`，收至 `1284×252` 并保持 Target 身份 |
| `UF-A1 V3-B final.r2` attempt 3 | session `019fefd5…a8d1`；raw `2727a2a…755c`；review `cf8a5c0…0a2e`；B `3/5` | safe 降至 `10860`；ratio `10.098017%`、aniso `9.171843%`、isolation `79/77` 失败；无 candidate/source/runtime | `final.r3` 宽减 `96`、高增 `6`，左右内脸让 `38/34 px`，保留上下薄轨 |
| `UF-A1 V3-B final.r3` attempt 4 | session `019fefdf…779e`；raw `2d7bb28…7d18e`；review `85a4c06…eb349`；B `4/5` | 单开口／物理连通通过；bbox `1454×247`，ratio `15.532181%`、aniso `13.444030%`、safe `7979`、isolation `43/39` 失败；无 candidate/source/runtime | 最终 `r4` 用绝对坐标把 bbox 锁到 x `126..1410/y386..638`，开口覆盖 x `168..1368/y422..602`，并恢复粗旧非工业 Target 材料 |
| `UF-A1 V3-B final.r4` attempt 5 | session `019fefef…076e`；raw `92a9889…97231`；review `983d564…4f5d7`；B `5/5` | ratio/aniso 通过；safe `22649`、isolation `68/72` 失败，工业式长边／端部仍在；`repair-budget-exhausted`；无 candidate/source/runtime | 禁止第六次；保留终态 review，继续独立 B1；最终等待用户决定是否为 A/B 重开合同 |
| `UF-B1 V2 final` attempt 1 | session `019ff008…d61d`；provider raw `30cb1ff…1d691`；1024² raw `748c81a…a7abc`；review `090354b…a882f`；B1 `1/5` | `8/9` 通过；唯一失败为 Health `2.81:1`、Power `9.07:1` 的 source ratio；无 candidate/source/runtime | `final.r1` 只把两块重绘到 x `256..768`、Health y `128..384`、Power y `640..768`；冻结灰阶、明度、材质和隔离 |
| `UF-B1 V2 final.r1` attempt 2 | session `019ff018…5e87`；provider raw `e39be44…4ef7e`；1024² raw `de8a0f2…57990`；review `f7b4d0e…3c930`；B1 `2/5` | Health ratio `5.40%` 通过；唯一失败为 Power `5.355:1`、误差 `33.87%`；其他 `8/9` 门禁继续通过；无 candidate/source/runtime | `final.r2` 冻结 Health，只把 Power 保持宽 `664` 并增高为约 `166`，目标 x `180..844/y680..846` |
| `UF-B1 V2 final.r2` attempt 3 | session `019ff025…8c02`；provider raw `54e3f9b…36060`；1024² raw `161910f…514e1`；review `6e19b23…cf798`；B1 `3/5` | `9/9 pass`；Health／Power candidate `8d19ffe…08e1f`／`0668edd…87f1`；用户接受 exact pixels；`P5 runtime-exported / addon-integrated` | 通过即停，不调用 attempt 4/5；下一门禁为 Turtle WoW P6 |

## 最终执行正文

以下正文均为 `production / authorized / 2026-08-11`。它们已吸收
`UF-PRIMARY-V3-SIM-V1` 的用户确认结论并通过自包含完整性复核；attempt 1
必须逐字使用对应正文，不得在传输时改写。

### `UF-A1 V3-A final` — Player 完整外壳

```text
Create one complete empty Player unit-frame shell as a single production bitmap
for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul. Return one 1536 by 1024
RGB image containing exactly one front-facing orthographic horizontal shell on
a perfectly uniform pure #00FF00 background. Do not create an atlas, separate
caps, multiple outputs, a complete HUD screenshot, or any additional object.

The shell will surround a live 200 by 25 health bar and a live 200 by 4 power
bar and will be exported to 214 by 42 runtime pixels. Aim for one large centred
visible bbox close to 1284 by 252, approximately 5.10:1, with broad green
isolation. Keep one connected physical perimeter and a large connected green
central opening. The long top and bottom rails remain thin and calm; the two
ends remain narrow. Identity detail stays at the extreme ends so a later
deterministic variable-width three-slice can stretch the quiet centre without
moving unique repairs. Draw no bar fill or liner across the green opening.

At the confirmed 214 by 42 in-game scale, preserve Vanilla information density:
the shell must feel materially substantial like an old carried object, yet it
must remain visually subordinate to live health, power, names and numbers. Let
leather carry the structure and keep brass local. The result must sit beside a
worn field-book chat frame and the classic gryphon action bar as the same era
and painted weight, without copying a book, column, gryphon or neighbouring
silhouette.

The written requirements outrank the images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its complete screen,
portraits, text and book geometry. Use Image 2 only for deep-walnut material
depth, warm upper-left light, believable wear and hand-made error. Ignore its
pages, spine, columns, dragons, book silhouette and broad metal construction.

Make the object a rugged expedition field badge built from discarded saddle
leather, a shield strap or tent-binding leather. Deep-walnut old leather is the
main structure, a narrow soot-brown liner supplies contact depth, and oxidized
brass appears only as a few short repair pieces. The hide is unevenly dyed,
smoke-darkened and locally mud-worn. Use a few low-frequency hand-cut deviations,
unequal thickness and sparse load-bearing stitches. Do not use repeated pores,
uniform pebble grain, equal stitch spacing, symmetric rivets, continuous orange
bevels, furniture upholstery, luxury leatherwork or industrial product edges.

The Player identity is heavier on the left: one small crooked dull-brass clamp
and two or three coarse uneven stitches pulled through the leather. The right
end is mostly worn leather with one off-centre dark rivet. Do not mirror the
ends. Keep the centre quiet and subordinate to combat information.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid continuous gold trim, perfect rounded
cards, glass, modern bevels, industrial grids, black-iron shrines, skulls,
horns, crests, book parts, wax seals, gemstones, neon and photoreal antiques.
Every pixel outside the shell and inside its opening remains pure #00FF00.
Before returning, verify that the image contains exactly one complete Player
shell, one connected green opening, leather-led structure, only short local
brass repair, asymmetric ends, quiet rails and no baked live content.
```

### `UF-A1 V3-A final.r1` — Player attempt 2 自包含有界修复

```text
Edit Image 3 into one corrected complete empty Player unit-frame shell as a
single production bitmap for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul.
Return one 1536 by 1024 RGB image containing exactly one front-facing
orthographic horizontal shell on a perfectly uniform pure #00FF00 background.
Do not create an atlas, separate caps, multiple outputs, a HUD screenshot or
any additional object. This is a bounded repair of the immediately previous
Player candidate only; it is not a new design direction.

The shell will surround a live 200 by 25 health bar and a live 200 by 4 power
bar and will be exported to 214 by 42 runtime pixels. Correct Image 3's measured
1425 by 224 overly long bbox: aim for one centred visible bbox close to 1284 by
252, approximately 5.10:1, with about 126 green pixels at the left and right of
the 1536 canvas and broad green above and below. Do not retain a bbox wider than
about 1340 or shorter than about 240. The repaired object must be visibly less
long-and-thin than Image 3 while keeping Vanilla information density.

Create exactly one connected physical perimeter and exactly one large connected
green central opening. Image 3's two separate green slots and the full-width
leather divider between them are the primary failure: remove that anatomy
completely. Health and Power are separate live runtime layers placed later
inside the same opening; draw no second opening, inner shelf, divider, separator,
bar trough or full-width strip for them. The entire central opening is one
uninterrupted field of pure #00FF00 from its upper inner edge to its lower inner
edge.

Treat the final 1284 by 252 shell bbox as an engineering grid. Within that bbox,
all pixels in the inner rectangle from x 42 through x 1241 and y 36 through y
215 must be pure #00FF00. Keep the top rail entirely within the upper 36 pixels,
the bottom rail entirely within the lower 36 pixels, the left end entirely
within the left 42 pixels and the right end entirely within the right 42 pixels,
apart from at most a soft one-pixel-equivalent antialias edge. No leather,
stitch, clamp, rivet, shadow, liner or brass may project deeper into that inner
rectangle. Keep unique identity detail at the extreme ends so a deterministic
variable-width three-slice can stretch the quiet centre without moving it.

At the confirmed 214 by 42 in-game scale, the shell must feel materially
substantial like an old carried object but remain subordinate to live health,
power, names and numbers. Let leather carry the structure and keep brass local.
It must sit beside a worn field-book chat frame and the classic gryphon action
bar as the same era and painted weight without copying a book, column, gryphon
or neighbouring silhouette.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its complete screen,
portraits, text and book geometry. Use Image 2 only for deep-walnut material
depth, warm upper-left light, believable wear and hand-made error. Ignore its
pages, spine, columns, dragons, book silhouette and broad metal construction.
Use Image 3 only to preserve its successful deep rough saddle-leather material,
warm upper-left lighting, dark contact depth, left-side coarse stitches, small
crooked dull-brass repair identity and off-centre dark right rivet. Do not
preserve Image 3's two-slot anatomy, central divider, oversized left clamp,
overly wide end masses, 1425 by 224 proportion or insufficient side isolation.

Make the object a rugged expedition field badge built from discarded saddle
leather, a shield strap or tent-binding leather. Deep-walnut old leather is the
main structure, a narrow soot-brown contact edge supplies depth, and oxidized
brass appears only as short local repair. The hide is unevenly dyed,
smoke-darkened and locally mud-worn. Use a few low-frequency hand-cut
deviations, unequal thickness and sparse load-bearing stitches. Do not use
repeated pores, uniform pebble grain, equal stitch spacing, symmetric rivets,
continuous orange bevels, furniture upholstery, luxury leatherwork or
industrial product edges.

The Player identity remains heavier on the left, but compress it into the
extreme 42-pixel end band: one small crooked dull-brass clamp and two or three
coarse unequal stitches, never a broad vertical brace reaching into live
content. The right extreme end is mostly worn leather with one off-centre dark
rivet. Do not mirror the ends. Keep both long rails thin, quiet and irregular,
with no continuous decorative stitch line competing with the bars.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid continuous gold trim, perfect rounded
cards, glass, modern bevels, industrial grids, black-iron shrines, skulls,
horns, crests, book parts, wax seals, gemstones, neon and photoreal antiques.
Every pixel outside the shell and throughout its one central opening remains
pure #00FF00. Before returning, verify one complete Player shell, one connected
physical perimeter, exactly one uninterrupted green opening, a bbox near 1284
by 252, thin rails, narrow ends, no central divider, no safe-area intrusion,
leather-led rough expedition craft, local asymmetric repairs and no baked live
content.
```

### `UF-A1 V3-A final.r2` — Player attempt 3 自包含有界修复

```text
Edit Image 3 into one corrected complete empty Player unit-frame shell as a
single production bitmap for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul.
Return one 1536 by 1024 RGB image containing exactly one front-facing
orthographic horizontal shell on a perfectly uniform pure #00FF00 background.
Do not create an atlas, separate caps, multiple outputs, a HUD screenshot or
any additional object. This is the next bounded repair of the immediately
previous Player candidate, not a new design direction.

Preserve Image 3's successful single connected physical perimeter, exactly one
connected central green opening, approximately correct 5.10:1 overall ratio,
deep rough walnut saddle leather, warm upper-left light and asymmetric Player
identity. Do not reintroduce the old second slot or central divider. The current
failure is that Image 3 leaves very broad decorated end plaques and thick rails,
so material extends far into the live-content safe core. Correct that geometry
without changing the component identity.

The shell will surround one live 200 by 25 health bar and one live 200 by 4
power bar inside the same uninterrupted opening, then export to 214 by 42
runtime pixels. Aim for one centred visible bbox close to 1284 by 252,
approximately 5.10:1, with broad pure-green canvas isolation. Keep the bbox
between about 1230 and 1335 pixels wide and between about 242 and 262 pixels
tall. Do not make it longer, thinner or heavier than Image 3.

Treat the shell bbox itself as a strict 1284 by 252 engineering grid. The one
pure-green opening must span at least x 42 through x 1241 and y 36 through y
215 inside that bbox. In other words, at least the central 1200 by 180 region is
uninterrupted pure #00FF00. The left structural end is only the first 42 pixels,
the right structural end only the final 42 pixels, the top rail only the first
36 pixels and the bottom rail only the final 36 pixels. Apart from a soft
one-pixel-equivalent antialias fringe, no leather, brass, stitch, rivet, shadow,
liner or bevel may cross those boundaries. Health and Power are runtime layers;
draw no inner shelf, separator, trough, divider or second opening.

Image 3's current green opening is much too small, about 980 by 157 inside a
1358 by 255 visible object. Expand the same opening strongly on all four sides:
remove roughly three quarters of the wide left and right leather plaques and
shave the thick inner faces of both long rails until the opening reaches the
strict safe rectangle. The opening should visually occupy almost the entire
length and most of the height of the shell. Do not merely erase the centre;
redraw the perimeter as a thin continuous hand-cut leather outline with four
narrow corner joins and no broad end blocks.

At 214 by 42 runtime scale, the left and right structural bands are only about
7 pixels each, and the top and bottom rails only about 6 pixels each. Compress
the Player identity into those true end bands. On the left retain only a tiny
crooked dull-brass repair tab plus two or three short coarse unequal stitch
marks, all clipped to the extreme end; remove Image 3's large full-height brass
brace and wide stitched leather slab. On the right retain mostly a narrow worn
leather turn with one small off-centre dark rivet, entirely in the extreme end;
remove the broad embossed end plaque. Do not mirror the ends.

Keep both long rails quiet and irregular. Image 3's nearly continuous evenly
spaced edge stitches and rope-like rounded moulding look manufactured: break
that rhythm. Use only a few short stitch clusters near actual repairs, leave
long stretches without stitching, vary the hand-cut rail thickness subtly and
use broken matte highlights rather than continuous piping. The silhouette
remains readable as early-WoW painted bitmap art, not a smooth modern product.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its complete screen,
portraits, text and book geometry. Use Image 2 only for deep-walnut material
depth, warm upper-left light, believable wear and hand-made error. Ignore its
pages, spine, columns, dragons, book silhouette and broad metal construction.
Use Image 3 only for its accepted one-opening topology, rough dark saddle-hide
material, light direction, local wear and the reduced Player identity described
above. Do not preserve its broad end plaques, oversized brass brace, repeated
long-rail stitches, thick inner lips or safe-area intrusion.

Make the object a rugged expedition field badge cut from discarded saddle,
shield-strap or tent-binding leather. Deep-walnut hide carries the structure;
a very narrow soot-brown contact edge provides depth; oxidized brass appears
only as one tiny broken repair. Use uneven dye, smoke-darkening, local mud wear,
low-frequency hand-cut deviations and sparse load-bearing stitches. Forbid
repeated pores, uniform pebble embossing, equal stitch spacing, symmetric
rivets, continuous orange bevels, upholstered furniture, luxury leatherwork,
industrial rounded cards and polished product geometry.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid continuous gold trim, glass, modern bevels,
industrial grids, black-iron shrines, skulls, horns, crests, book parts, wax
seals, gemstones, neon and photoreal antiques. Every pixel outside the shell
and throughout its one opening remains pure #00FF00. Before returning, verify
one complete Player shell, one physical perimeter, exactly one uninterrupted
green opening of at least the declared 1200 by 180 safe region, a bbox near
1284 by 252, true 42-pixel end bands, true 36-pixel rails, no safe-core
intrusion, no broad plaques, broken hand-made stitch rhythm, rough leather-led
Vanilla craft and no baked live content.
```

### `UF-A1 V3-A final.r3` — Player attempt 4 自包含有界修复

```text
Edit Image 3 into one final corrected complete empty Player unit-frame shell as
a single production bitmap for Turtle WoW 1.18.1 and a Vanilla-era pfUI
overhaul. Return one 1536 by 1024 RGB image containing exactly one front-facing
orthographic horizontal shell on a perfectly uniform pure #00FF00 background.
Do not create an atlas, separate caps, multiple outputs, a HUD screenshot or
any additional object. This is a narrowly bounded geometry-and-craft repair of
the immediately previous Player candidate, not a redesign.

Preserve Image 3's successful single connected perimeter, exactly one
uninterrupted central green opening, correct overall 5.10:1 family ratio, thin
top and bottom rails, rough deep-walnut saddle leather, warm upper-left light
and small non-mirrored end identities. Never reintroduce a second slot, central
divider, inner shelf or separate bar trough. Do not change the component into
metalwork, a book, shrine, plaque or modern rounded card.

The shell will surround one live 200 by 25 health bar and one live 200 by 4
power bar inside the same opening, then export to 214 by 42 runtime pixels.
Image 3 measures 1415 by 282 and nearly fills the horizontal canvas. Uniformly
reduce and recentre the whole object to a visible bbox close to 1284 by 252,
approximately x 126 through 1409 and y 386 through 637, leaving about 126 pure
green pixels at both canvas sides and broad pure green above and below. Keep the
ratio close to 5.10:1; do not stretch only one axis.

After that reduction, treat the shell bbox as a strict 1284 by 252 engineering
grid. The one central pure-green opening must fully contain x 42 through x 1241
and y 36 through y 215. The top rail is confined to the first 36 pixels, the
bottom rail to the last 36 pixels, the left end to the first 42 pixels and the
right end to the last 42 pixels. No leather, brass, stitch, rivet, shadow,
liner, bevel or antialiased opaque structure may enter the hard interior from
x 48 through x 1235 and y 42 through y 209.

Image 3 is already vertically close: preserve its thin top and bottom rails.
Its remaining objective failure is horizontal. In normalized coordinates the
green opening begins around x 74 instead of x 42 and ends around x 1196 instead
of x 1242. Move only the inner face of the left end outward by about 32 pixels
and only the inner face of the right end outward by about 46 pixels. This means
cutting away roughly another five runtime pixels from the left end and eight
runtime pixels from the right end. The final opening must span at least 1200
pixels of the 1284-pixel shell width. Do not shrink the opening, thicken the
rails or add any inner material.

Compress all Player identity into the true 42-pixel extreme end bands. The
left end contains one tiny crooked dull-brass patch, one dark off-centre rivet
and at most two very short coarse unequal stitches; none may project right of
the 42-pixel band. The right end is predominantly narrow worn leather with one
small dark off-centre rivet; none may project left of the final 42-pixel band.
Do not create broad leather end plaques, full-height braces, posts, emblems or
mirrored ends. Four narrow corner joins keep the physical perimeter connected.

Preserve rough hand-painted material but make construction less regular than
Image 3. Its remaining continuous cord-like edge line and evenly repeated tiny
marks feel manufactured. Break each long highlight into several unequal matte
fragments separated by bare dark leather. Use at most two short stitch clusters
near real repairs, not a stitched border. Introduce only low-frequency hand-cut
waviness: a slightly pinched top-left join, a shallow worn dip along one bottom
section and unequal corner thickness. Keep these deviations outside the live
safe region and readable at 214 by 42; do not add random noisy serration.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its full screen,
portraits, text and book geometry. Use Image 2 only for deep-walnut material
depth, warm upper-left light, believable wear and hand-made error. Ignore its
pages, spine, columns, dragons, book silhouette and broad metal construction.
Use Image 3 only for its accepted one-opening topology, current thin rails,
rough saddle-hide palette, light direction and small end identity. Do not
preserve its 1415 by 282 canvas occupation, remaining 74/88-pixel end depth,
safe-core intrusion or continuous manufactured edge rhythm.

The object is a rugged expedition field badge cut from discarded saddle,
shield-strap or tent-binding leather. Deep-walnut hide carries the structure;
a narrow soot-brown contact edge supplies depth; oxidized brass is only a tiny
broken repair. Use uneven dye, smoke-darkening, local mud wear, low-frequency
hand-cut error and sparse load-bearing stitches. Forbid repeated pores, uniform
pebble embossing, equal stitch spacing, symmetric rivets, continuous orange
bevels, upholstery, luxury leatherwork, polished industrial product geometry,
glass, modern bevels and complete gold trim.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid black-iron shrines, skulls, horns, crests,
book parts, wax seals, gemstones, neon and photoreal antiques. Every pixel
outside the shell and throughout its one opening remains pure #00FF00. Before
returning, verify exactly one complete Player shell, one connected perimeter,
one uninterrupted opening spanning at least x 42..1241 and y 36..215 of the
shell bbox, no alpha-bearing structure in the hard core, a centred bbox near
1284 by 252, true narrow ends, thin rails, broken hand-made edge rhythm, rough
leather-led Vanilla craft and no baked live content.
```

### `UF-A1 V3-A final.r4` — Player attempt 5 最终有界修复

```text
Edit Image 3 into one corrected complete empty Player unit-frame shell as one
1536 by 1024 RGB production bitmap for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Keep exactly one front-facing orthographic horizontal object on
a perfectly uniform pure #00FF00 background. Do not create an atlas, separate
parts, multiple outputs, a HUD screenshot or any additional object. This final
bounded edit changes only overall occupancy and the thickness of the two
vertical end bands; do not redesign the accepted shell.

Preserve Image 3's one connected physical perimeter, exactly one uninterrupted
green opening, thin top and bottom rails, rough deep-walnut saddle leather,
warm upper-left light, broken hand-cut edge rhythm and small non-mirrored Player
identity. Preserve the current material, colour, lighting and wear. Never add a
second opening, divider, inner shelf, bar trough, broad plaque, brace or post.

First, uniformly scale down and recenter the complete object. Image 3's bbox is
1392 by 281; the corrected visible bbox must be close to 1284 by 252, about
83.6 percent of the canvas width, with approximately 126 pixels of pure green
on both the left and right. Keep its ratio near 5.10:1. Do not fill 90 percent
of the canvas width again, do not crop any edge and do not stretch one axis
independently.

Second, make the two vertical sides as visually thin as the top and bottom
rails. The shell is a thin continuous leather ring, not a frame with end caps.
At the final 1284 by 252 bbox, each vertical side is at most 42 pixels thick,
approximately the same perceived thickness as each 36-pixel horizontal rail.
The central pure-green opening therefore occupies at least 93.5 percent of the
shell width and fully covers x 42 through x 1241 and y 36 through y 215.

Image 3's normalized opening currently begins around x 71 and ends around
x 1206. Erase and redraw only the inward-facing excess: move the left inner
edge 29 pixels farther left, from x 71 to x 42 or less, and move the right inner
edge 36 pixels farther right, from x 1206 to x 1242 or more. These are visible
structural edits, not shadows. Replace the removed end material with uniform
pure #00FF00 connected to the existing opening. Do not change the already thin
top or bottom inner edges. No alpha-bearing leather, brass, stitch, rivet,
shadow, liner or bevel may remain inside hard core x 48..1235 and y 42..209.

The left identity must fit entirely inside the first 42 pixels of the shell:
one tiny worn brass stain or patch, one dark off-centre rivet and no more than
two very short coarse stitches. The right identity must fit entirely inside the
last 42 pixels: mostly narrow worn leather and one small dark off-centre rivet.
The unique marks may overlap the thin vertical leather sides but may not make
those sides wider. Four tiny corner joins maintain one connected perimeter.
Do not mirror the ends.

This is an early-WoW hand-painted expedition field badge cut from discarded
saddle, shield-strap or tent-binding leather. Deep-walnut hide carries the
structure; soot-brown contact depth is narrow; oxidized brass is only a tiny
broken repair. Keep uneven dye, smoke-darkening, local mud wear, broken matte
highlights and low-frequency hand-cut error. Do not make the result cleaner,
more symmetric or more industrial than Image 3. Forbid continuous stitched
borders, equal stitches, repeated pores, uniform pebble embossing, symmetric
rivets, orange piping, luxury upholstery, polished product geometry, glass,
modern bevels and complete gold trim.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale and low-resolution readability; ignore its screen,
portraits, text and books. Use Image 2 only for deep-walnut depth, warm light,
believable wear and hand-made error; ignore pages, spine, columns, dragons and
book construction. Use Image 3 only for the accepted topology, thin horizontal
rails, rough material, lighting and tiny end identities. Do not preserve its
1392 by 281 occupation, its x71/x1206 inner edges or its thick vertical sides.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid skulls, horns, crests, book parts, wax
seals, gemstones, neon and photoreal antiques. Every pixel outside the shell
and throughout its one opening remains pure #00FF00. Before returning, verify
one complete connected Player shell, one uninterrupted green opening, bbox
near 1284 by 252, green isolation near 126 pixels on each side, vertical sides
no thicker than 42 pixels, horizontal rails no thicker than 36 pixels, zero
structure in the hard safe core, preserved rough Vanilla leather craft and no
baked live content.
```

### `UF-A1 V3-B final` — Target 完整外壳

```text
Create one complete empty Target unit-frame shell as a single production bitmap
for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul. Return one 1536 by 1024
RGB image containing exactly one front-facing orthographic horizontal shell on
a perfectly uniform pure #00FF00 background. Do not create an atlas, separate
caps, multiple outputs, a complete HUD screenshot, or any additional object.

The shell will surround a live 200 by 25 health bar and a live 200 by 4 power
bar and will be exported to 214 by 42 runtime pixels. Aim for one large centred
visible bbox close to 1284 by 252, approximately 5.10:1, with broad green
isolation. Keep one connected physical perimeter and a large connected green
central opening. The long rails remain thin and calm and the ends remain
narrow. Keep unique identity marks at the extreme ends so the quiet centre can
be deterministically stretched for variable width. Draw no live bar material
or dynamic content in the opening.

At the confirmed 214 by 42 in-game scale, preserve Vanilla information density:
the shell must feel materially substantial but remain subordinate to live
health, power, names and numbers. It shares the Player shell's expedition-era
painted weight while remaining independently built and visibly non-mirrored.
It must sit beside a worn field-book chat frame and the classic gryphon action
bar without copying their book, column, gryphon or other silhouettes.

The written requirements outrank the images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its screen composition,
portraits, text and books. Use Image 2 only for deep-walnut depth, warm upper-
left light, believable wear and hand-made error. Ignore its pages, spine,
columns, dragons, book silhouette and broad metal construction. Do not copy or
mirror a Player candidate; this Target shell is painted independently.

Use the same expedition craft language: discarded saddle, shield-strap or tent
binding leather, with deep-walnut hide as the main structure, a soot-brown
recess and only tiny interrupted oxidized-brass repairs. Uneven dye, smoke and
mud wear, low-frequency hand-cut edges, unequal thickness and sparse repairs
create ruggedness. Avoid repeated pores, pebble embossing, equal stitches,
symmetric rivets, continuous orange bevels, furniture leather and industrial
product geometry.

The Target identity is quieter at the left, with one rubbed polished leather
fold and almost no metal. Its right end carries one short damaged oxidized
brass compression strip with an uneven attachment and a small dent or split.
The strip is subordinate to leather and never becomes a post, plaque, emblem
or full-height trim. Add no enemy red, faction mark, elite crown, skull or horn.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid complete gold outlines, perfect rounded
cards, glass, modern bevels, industrial grids, black-iron shrines, book parts,
wax seals, gemstones, neon and photoreal antiques. Every pixel outside the
shell and inside its opening remains pure #00FF00.
Before returning, verify that the image contains exactly one complete Target
shell, one connected green opening, leather-led structure, a short subordinate
right-end brass repair, non-mirrored ends, quiet rails and no baked live
content.
```

### `UF-A1 V3-B final.r1` — Target attempt 2 自包含有界修复

```text
Edit Image 3 into one corrected complete empty Target unit-frame shell as one
1536 by 1024 RGB production bitmap for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Keep exactly one front-facing orthographic horizontal object on
a perfectly uniform pure #00FF00 background. Do not create an atlas, separate
caps, multiple outputs, a HUD screenshot or any additional object. This is a
bounded repair of the immediately previous Target candidate only; it must not
reuse or resemble any Player candidate.

Preserve Image 3's successful one connected physical perimeter, exactly one
connected central green opening, rugged deep-walnut saddle-hide material, warm
upper-left light, quiet rubbed left identity and damaged right-side brass
identity. The first candidate is too tall and has broad end blocks and thick
rails. Correct that engineering geometry while retaining its independent Target
craft language and avoiding a mirror of Player.

The shell will surround one live 200 by 25 health bar and one live 200 by 4
power bar inside the same uninterrupted opening, then export to 214 by 42
runtime pixels. Image 3's bbox is 1354 by 305, ratio 4.44:1. Redraw and recenter
the complete object near 1284 by 252, ratio approximately 5.10:1, with at least
about 100 pixels of pure green at each canvas side and broad green above and
below. Make it clearly longer-and-thinner than Image 3 without becoming a
delicate modern line.

Treat the corrected 1284 by 252 bbox as a strict engineering grid. The single
pure-green opening must fully cover x 42 through x 1241 and y 36 through y 215:
at least 1200 by 180 pixels, or about 93.5 percent of shell width and 71 percent
of shell height. The left vertical side exists only in the first 42 pixels, the
right vertical side only in the last 42 pixels, the top rail only in the first
36 pixels and the bottom rail only in the last 36 pixels. No leather, brass,
stitch, shadow, liner or bevel may enter hard core x 48..1235/y 42..209.

Image 3's opening is only about 1039 by 165 inside a 1354 by 305 object. Expand
the same opening strongly in all four directions. Remove most of both broad end
blocks and shave both thick inner rail faces. Redraw the perimeter as a thin
continuous hand-cut leather ring whose vertical sides have almost the same
perceived thickness as its horizontal rails. Do not leave an end cap, post,
plaque, inner shelf, separator, second opening or separate power trough.

Compress the Target identities into the true extreme 42-pixel bands. At left,
retain one shallow rubbed leather fold and at most two short irregular repair
stitches; use almost no metal and no broad stitched panel. At right, retain one
short damaged oxidized-brass compression tab with an uneven attachment and one
small split. It must be dark, worn and subordinate to leather, entirely inside
the final 42 pixels; remove Image 3's bright full-height gold plate and broad
right block. The ends stay visibly non-mirrored, with four narrow corner joins
maintaining one connected perimeter.

Keep both long rails quiet. Image 3 uses evenly repeated small ties along the
rails; retain at most two unequal stitch clusters near real repairs and leave
long bare leather stretches. Use broken matte highlights and subtle
low-frequency hand-cut waviness, not continuous piping or industrial rounded
geometry. At 214 by 42, live bars, names and values remain dominant.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, short broken dull
brass highlights and restrained dark weight. Ignore its screen, portraits,
text and books. Use Image 2 only for deep-walnut depth, warm upper-left light,
believable wear and hand-made error. Ignore pages, spine, columns, dragons,
book silhouette and broad metal construction. Use Image 3 only for its Target
material, lighting, single-opening topology, rubbed left fold and damaged-right
identity. Do not preserve its 1354 by 305 proportion, broad ends, thick rails,
1039 by 165 opening, regular rail ties or bright full-height plate.

Use discarded saddle, shield-strap or tent-binding leather. Deep-walnut hide
carries the structure, a narrow soot-brown contact edge supplies depth, and
oxidized brass is only the short right repair. Uneven dye, smoke and mud wear,
unequal hand-cut thickness and sparse repairs create ruggedness. Forbid repeated
pores, pebble embossing, equal stitches, symmetric rivets, orange piping,
furniture leather, luxury leatherwork, industrial cards, glass, modern bevels,
black-iron shrines, enemy red, faction marks, elite crowns, skulls and horns.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Forbid book parts, wax seals, gemstones, neon and
photoreal antiques. Every pixel outside the shell and throughout its one
opening remains pure #00FF00. Before returning, verify exactly one complete
Target shell, one connected perimeter, one uninterrupted opening at least
1200 by 180 within a bbox near 1284 by 252, true 42-pixel ends and 36-pixel
rails, zero hard-safe-core structure, a dark short right brass repair,
non-mirrored rough Vanilla craft and no baked live content.
```

### `UF-A1 V3-B final.r2` — Target attempt 3 自包含有界修复

```text
Edit Image 3 into one corrected complete empty Target unit-frame shell as one
1536 by 1024 RGB production bitmap for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Keep exactly one front-facing orthographic horizontal object on
a perfectly uniform pure #00FF00 background. Do not create an atlas, multiple
objects, a HUD screenshot or separate parts. This bounded edit changes only
canvas occupancy and the thickness of the four sides; do not redesign the
independent Target identity and do not use any Player pixels.

Preserve Image 3's successful one connected perimeter, exactly one connected
green opening, accepted ratio family, deep rough walnut saddle hide, warm
upper-left light, quiet worn left end and damaged oxidized-brass right identity.
Never add a second opening, divider, inner shelf, separate power trough, broad
plaque, post or mirrored Player-like end.

The shell surrounds one live 200 by 25 health bar and one live 200 by 4 power
bar inside the same opening, then exports to 214 by 42 runtime pixels. Image 3
measures 1382 by 255. Recenter and reduce the complete object to a bbox close to
1284 by 252, about x 126..1409 and y 386..637, leaving around 126 pixels of pure
green at both canvas sides. Keep source ratio near 5.10:1 and keep normalization
anisotropy below 8 percent.

Treat that 1284 by 252 bbox as a strict grid. The one green opening must fully
contain x 42..1241 and y 36..215. The left and right vertical sides are each at
most 42 pixels; the top and bottom rails are each at most 36 pixels. No visible
leather, brass, stitch, shadow, liner or bevel may enter hard core
x 48..1235/y 42..209.

Image 3's normalized opening currently begins around x 88 and ends around
x 1200, while its top and bottom inner edges sit around y 47 and y 203. Expand
the same opening without changing topology: move the left inner edge about 46
pixels left to x 42 or less; move the right inner edge about 42 pixels right to
x 1242 or more; move the top inner edge about 11 pixels upward to y 36 or less;
move the bottom inner edge about 13 pixels downward to y 216 or more. Replace
all removed inward-facing material with uniform pure #00FF00 connected to the
existing opening. The final opening is at least 1200 by 180.

The result is a thin continuous hand-cut leather ring. Its vertical sides have
approximately the same perceived thickness as its horizontal rails. Compress
the quiet rubbed left fold and at most two short irregular stitches into the
first 42 pixels. Compress the dark damaged right brass tab, its uneven mount
and one small split into the last 42 pixels. The brass stays oxidized, dull and
subordinate; it never becomes a full-height bright plate or broad block. Four
narrow unequal corner joins keep one physical perimeter. Do not mirror ends.

Keep the long rails quiet and rough. Use only a couple of short unequal stitch
clusters near repairs, long bare stretches, broken matte highlights and subtle
low-frequency waviness. Avoid regular ties, continuous piping, furniture
leather and polished industrial geometry. At 214 by 42, live bars, names and
values remain dominant.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability and restrained dark
weight; ignore its screen, portraits, text and books. Use Image 2 only for deep
walnut depth, warm light, believable wear and hand-made error; ignore pages,
spine, columns, dragons and broad metal construction. Use Image 3 only for its
accepted Target topology, material, lighting and non-mirrored end identities.
Do not preserve its 1382 by 255 occupancy, x88/x1200/y47/y203 inner edges,
oversized end depth or right-edge canvas crowding.

Use discarded saddle, shield-strap or tent-binding leather with a narrow
soot-brown contact edge and only the short right oxidized-brass repair. Uneven
dye, smoke, mud wear, unequal cut thickness and sparse repairs create
ruggedness. Forbid repeated pores, pebble embossing, equal stitches, symmetric
rivets, orange piping, luxury leatherwork, modern bevels, glass, black-iron
shrines, enemy red, faction marks, elite crowns, skulls, horns, book parts, wax
seals, gemstones, neon and photoreal antiques.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Every pixel outside the shell and throughout its
single opening remains pure #00FF00. Before returning, verify one complete
Target shell, one connected perimeter, one uninterrupted green opening at
least 1200 by 180, bbox near 1284 by 252, true 42-pixel ends and 36-pixel rails,
zero hard-core structure, dark short right repair, rough non-mirrored Vanilla
craft and no baked live content.
```

### `UF-A1 V3-B final.r3` — Target attempt 4 自包含有界修复

```text
Edit Image 3 into one corrected complete empty Target unit-frame shell as one
1536 by 1024 RGB production bitmap for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Keep exactly one front-facing orthographic horizontal object on
a perfectly uniform pure #00FF00 background. Do not create an atlas, multiple
objects, a HUD screenshot or separate parts. This bounded edit changes only
overall bbox proportion and the two vertical side thicknesses; do not redesign
the accepted Target shell and do not use Player pixels.

Preserve Image 3's one connected perimeter, one connected green opening, thin
top and bottom rails, deep rough walnut saddle leather, warm upper-left light,
quiet worn left end and dark damaged right brass identity. Preserve current
rail height and opening height. Never add a divider, second slot, shelf, power
trough, broad plaque, post or mirrored Player-like end.

The shell surrounds one live 200 by 25 health bar and one live 200 by 4 power
bar inside the same opening, then exports to 214 by 42 runtime pixels. Image 3
measures 1380 by 246 and is too wide and slightly too short. Redraw, shrink
horizontally and recenter it to a bbox close to 1284 by 252: reduce total width
by about 96 pixels while increasing total height by only about 6 pixels. Aim
for x 126..1409 and y 386..637 on the canvas, with about 126 pure-green pixels
at both sides. Final ratio is about 5.10:1; do not output another 5.61:1 shell.

Treat the final 1284 by 252 bbox as a strict grid. Preserve the already-near-
correct vertical opening, but ensure the one pure-green opening fully contains
x 42..1241 and y 36..215. Each vertical side is at most 42 pixels; each
horizontal rail is at most 36 pixels. No leather, brass, stitch, shadow, liner
or bevel may enter hard core x 48..1235/y 42..209.

Image 3's normalized opening currently spans about x 80..1208 and y 37..212.
Move only the two inward vertical faces: move the left inner edge about 38
pixels left to x 42 or less and the right inner edge about 34 pixels right to
x 1242 or more. Also extend the bottom green edge about 4 pixels to y 216, but
do not thicken, redesign or move the already-good top rail. Replace removed
inward-facing end material with uniform pure #00FF00 connected to the opening.
The final opening is at least 1200 by 180.

The two vertical sides must look no thicker than the horizontal rails. Compress
the left rubbed fold and at most two short uneven stitches entirely into the
first 42 pixels. Compress the dark oxidized-brass right repair, uneven mount and
small split entirely into the last 42 pixels; it may not widen that side or
become a bright full-height plate. Four narrow unequal corner joins maintain
one physical perimeter. Do not mirror the ends.

Keep Image 3's rough, low-frequency, hand-cut material and quiet long rails.
Use broken matte highlights, long unstitched stretches and only sparse repair
marks. Do not add continuous piping, equal ties, pebble embossing, industrial
rounded geometry or modern gloss. At 214 by 42, live bars, names and values are
the visual subject.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale and low-resolution readability; ignore its screen,
portraits, text and books. Use Image 2 only for deep-walnut depth, warm light,
believable wear and hand-made error; ignore pages, spine, columns, dragons and
broad metal construction. Use Image 3 only for accepted Target topology,
material, lighting, thin horizontal rails and non-mirrored identities. Do not
preserve its 1380 by 246 bbox, 5.61:1 ratio, x80/x1208 inner edges or oversized
vertical sides.

Use discarded saddle, shield-strap or tent-binding leather, narrow soot-brown
contact depth and one short right oxidized-brass repair. Uneven dye, smoke, mud
wear, unequal cut thickness and sparse repairs create ruggedness. Forbid
repeated pores, equal stitches, symmetric rivets, orange piping, upholstery,
luxury leather, glass, modern bevels, black-iron shrines, enemy red, faction
marks, elite crowns, skulls, horns, books, wax seals, gemstones and neon.

Draw no health colour, power colour, name, level, number, portrait, icon, aura,
status, button, glow or text. Every pixel outside the shell and throughout its
one opening remains pure #00FF00. Before returning, verify one complete Target
shell, one perimeter, one opening at least 1200 by 180, bbox near 1284 by 252,
ratio near 5.10:1, true 42-pixel vertical sides, preserved thin rails, zero hard
safe-core structure, dark short right repair, rough Vanilla craft and no baked
live content.
```

### `UF-A1 V3-B final.r4` — Target attempt 5 最终有界修复

```text
Edit Image 3 into one corrected complete empty Target unit-frame shell as one
1536 by 1024 RGB production bitmap for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Return exactly one front-facing orthographic horizontal object
on a perfectly uniform pure #00FF00 background. Do not create an atlas,
separate pieces, a HUD screenshot, guide marks, text or any second object. This
is a bounded final repair of the immediately previous Target image only. Do
not use, copy or reconstruct Player pixels, V1/V2 pixels or any other failed
segment.

Written geometry outranks Image 3. Use two invisible absolute-coordinate
rectangles on the 1536 by 1024 canvas. The complete outer material bbox must be
approximately x 126 through 1409 and y 386 through 637: 1284 by 252 pixels,
centred with about 126 pure-green pixels at both left and right. Do not let any
material approach the canvas edges. Do not preserve Image 3's 1454 by 247 bbox,
x 43..1496 span, 5.8866:1 ratio or tiny 43/39-pixel side isolation.

Inside that outer bbox, one uninterrupted pure-green opening must fully cover
absolute canvas rectangle x 168 through 1367 and y 422 through 601. The even
stricter absolute hard core x 174 through 1361 and y 428 through 595 must be
completely pure #00FF00: no leather, brass, stitch, lining, bevel, highlight,
shadow or antialiased solid structure. This produces at most 42-pixel vertical
ends and at most 36-pixel horizontal rails. The opening is at least 1200 by
180 pixels and remains connected to itself as one hole. Four narrow unequal
corner joins keep the surrounding material one physically connected perimeter.

Rebuild the two end bands rather than merely scaling the current broad ends.
The left inner edge must sit at x 168 or farther left and the right inner edge
at x 1368 or farther right. The upper inner edge must sit at y 422 or higher;
the lower inner edge at y 602 or lower. Never add a divider, second slot, shelf,
power trough, plaque, post, portrait socket or internal ornament. The future
live 200 by 25 Health bar and 200 by 4 Power bar, names and values all occupy
this single green opening after export to 214 by 42.

Preserve only Image 3's successful topology and Target identity: one connected
ring, a quieter rubbed left end, a more damaged right end, thin rails and warm
upper-left lighting. Replace its industrial finish. The material is scavenged
expedition leather cut from an old saddle, shield strap or tent binding: deep
soot-dark walnut and smoke brown, low saturation, broad hand-painted 2004-era
WoW value blocks, matte broken highlights, dirt packed into irregular creases,
and a few believable pressure scars. It must feel heavy, repaired and used in
Azeroth, never precision-made.

Make the long rails subtly hand-cut, with slow unequal thickness changes and
long quiet stretches. Break every continuous raised lip. Remove the current
repeating pebble embossing, regular braided border, equal-distance stitches,
symmetrical rounded corners and bright red-orange piping. Use no more than two
short crooked stitch groups, with unequal spacing and missing holes; keep both
outside the absolute green opening. Irregularity must come from use, tension,
cuts and repairs, not random noise or a wavy silhouette.

At the left end retain only a narrow rubbed fold and one small dull fastener,
all inside x 126..167. At the right end retain one short cracked oxidized-brass
repair and one dark split, all inside x 1368..1409. The brass is tarnished
umber, not bright gold, and occupies only a local fragment rather than a
full-height plate. Do not mirror the two ends. At 214 by 42 the end identities
must remain readable without becoming wider than the horizontal rails.

The written requirements outrank all images. Use Image 1 only for circa-2004
Vanilla WoW painted scale, chunky low-resolution readability and restrained
warm contrast; ignore its screen, portraits, text and book content. Use Image
2 only for deep-walnut depth, left-upper warm light, believable wear and hand-
made error; ignore pages, spine, columns, dragons and broad book construction.
Use Image 3 only for its same-segment one-opening topology, thin-rail intent,
Target left/right identity and lighting. Explicitly discard Image 3's geometry,
continuous embossed border, regular lacing, bright reddish leather and tall
right brass plate.

Forbid upholstery, luxury leather goods, industrial rounded moulding, repeated
pores, machine embossing, equal ties, symmetric rivets, modern bevels, gloss,
glass, black-iron shrines, enemy red, faction marks, elite crowns, skulls,
horns, books, wax seals, gemstones and neon. Draw no health colour, power
colour, name, level, number, portrait, icon, aura, status, button or glow.
Every pixel outside the shell and throughout the one opening remains pure
#00FF00.

Before returning, verify all of these visibly: exactly one Target shell; outer
bbox near x126..1409/y386..637; at least 126 green pixels at both canvas sides;
one opening covering x168..1367/y422..601; absolute hard core
x174..1361/y428..595 pure green; one physical perimeter; ends no thicker than
42 pixels; rails no thicker than 36 pixels; dark rough hand-cut Vanilla craft;
short local right repair; no industrial repetition; no baked live content.
```

### `UF-B1 V2 final` — Health／Power 灰阶颜料纹

```text
Create one production sheet containing exactly two separate neutral grayscale
StatusBar material swatches for Turtle WoW 1.18.1. Return one 1024 by 1024 RGB
image on a perfectly uniform pure #00FF00 background. The upper half contains
only the Health fill donor as one isolated plain horizontal rectangle near a
2:1 ratio. The lower half contains only the Power fill donor as one isolated
plain horizontal rectangle near a 4:1 ratio. Draw no third object, frame, cap,
label, number, icon, colour key or presentation panel.

Both swatches are matte hand-painted mineral pigment, not physical leather.
Every material pixel is neutral grayscale with equal red, green and blue
channels, because pfUI applies health, reaction, Mana, Rage, Focus and Energy
colours at runtime. Keep the value range bright enough for multiplicative tint
without becoming white or glossy. Health is slightly coarser and deeper, with
three or four broad low-frequency horizontal brush drags and small unequal
pigment accumulation. Power is narrower, denser and calmer, with fewer and
smaller value changes so it survives at four or one runtime pixels high.

At 100 percent runtime size, preserve the confirmed hierarchy: Health reads
coarser, deeper and more materially present, while Power reads narrower,
denser and quieter. After multiplicative tint, Mana blue, Rage red, Focus
orange-brown and Energy yellow must remain equally clear semantic states; do
not encode or favour any one of those colours in the grayscale pixels. Neither
texture may compete with live text or turn the unit frame into a modern glossy
meter.

The surface must read as an early-WoW hand-painted bar texture after export to
64 by 32 for Health and 64 by 16 for Power. Keep the whole width statistically
quiet: no centre emblem, hotspot, unique end mark or long scratch. Forbid
colour tint, diagonal stripes, repeated chevrons, leather grain, parchment,
fabric weave, brushed metal, glass, gradient gloss, modern bevel, procedural
noise carpet, transparent hole and mirrored shine. Outside the two swatches
every pixel remains pure #00FF00.
Before returning, verify exactly two isolated swatches, Health above and Power
below, neutral equal-channel grayscale throughout, no third object, no colour,
no centre hotspot and broad uniform green isolation.
```

### `UF-B1 V2 final.r1` — Bars attempt 2 自包含比例修复

```text
Edit Image 1 into one corrected production sheet containing exactly two
separate neutral-grayscale StatusBar material swatches for Turtle WoW 1.18.1.
Return one 1024 by 1024 RGB bitmap on a perfectly uniform pure #00FF00
background. Keep Health as the only object in the upper half and Power as the
only object in the lower half. Do not add a third object, frame, border, cap,
label, number, icon, colour key, guide or presentation panel.

This bounded edit changes only the two source rectangle proportions and their
canvas positions. Preserve Image 1's successful matte grey mineral-pigment
material, quiet horizontal hand-painted brush drags, neutral value around 120,
clean green isolation, no centre hotspot, and the hierarchy in which Health is
slightly coarser while Power is slightly calmer. Do not turn either swatch into
leather, paper, fabric, metal, glass or a modern glossy meter.

Use exact invisible canvas rectangles. Repaint the Health material as one
connected 512 by 256 rectangle occupying x 256 through 767 and y 128 through
383. Repaint the Power material as one connected 512 by 128 rectangle
occupying x 256 through 767 and y 640 through 767. These are source shapes,
not visible guides: draw no outline or coordinate marks. Every pixel outside
the two rectangles is pure #00FF00, including the 256-pixel vertical gap
between them. Add no drop shadow, halo, detached fleck or antialias haze beyond
their bboxes.

Do not preserve Image 1's wrong proportions. Its Health is approximately 582
by 207 or 2.81:1 and must become 2:1. Its Power is approximately 689 by 76 or
9.07:1 and must become 4:1. Correct both by repainting the material into the
specified bboxes; do not merely place the current narrow strips inside a larger
green or transparent box. Each entire rectangle must remain visibly filled by
one continuous pigment surface with no transparent hole.

Every material pixel is neutral grayscale with equal red, green and blue
channels because pfUI applies Health, reaction, Mana, Rage, Focus and Energy
colours at runtime. Preserve moderate tintable brightness: neither swatch may
be near black, white, brown, blue, red or green. Keep broad low-frequency value
changes rather than high-frequency procedural noise. Health has three or four
softly unequal horizontal brush accumulations and slightly deeper variation.
Power has smaller, denser, quieter changes that survive at 64 by 16 and at four
runtime pixels high. Preserve Image 1's successful lack of a centre emblem,
hotspot, unique end mark or full-width scratch.

At runtime Health exports to 64 by 32 and Power to 64 by 16, then stretches
under live 200 by 25 and 200 by 4 bars. Keep the whole width statistically
quiet so live names and values remain dominant. Forbid colour tint, diagonal
stripes, repeated chevrons, leather grain, parchment, fabric weave, brushed
metal, glass, gradient gloss, bevel, mirrored shine, text and UI chrome.

Before returning, verify exactly two connected filled rectangles and nothing
else: Health bbox x256..767/y128..383 at exactly 512 by 256 and 2:1; Power bbox
x256..767/y640..767 at exactly 512 by 128 and 4:1; pure green outside; broad
green separation; equal-channel grayscale; moderate value; Health coarser;
Power calmer; no hotspot, frame, shadow, label or colour.
```

### `UF-B1 V2 final.r2` — Bars attempt 3 仅 Power 比例修复

```text
Edit Image 1 into one corrected 1024 by 1024 RGB production sheet for Turtle
WoW 1.18.1. Keep exactly two separate neutral-grayscale StatusBar material
swatches on a perfectly uniform pure #00FF00 background: Health above and
Power below. This bounded repair changes only the Power rectangle height and
vertical position. Preserve the Health object, all accepted material qualities
and the existing canvas; do not add any third object, frame, label or guide.

Freeze Image 1's Health swatch exactly as the accepted upper object. Its bbox
is approximately x 180 through 843 and y 137 through 451, or 664 by 315 and
2.108:1. Do not resize, repaint, move, crop, brighten, darken or restyle it.
Keep its one connected rectangle, matte grey mineral-pigment brushwork,
moderate value near 120, slight coarse variation, neutral channels, clean green
isolation and lack of a centre hotspot.

Repair only the lower Power swatch. Keep its width and horizontal placement at
exactly x 180 through 843, a width of 664 pixels. Repaint and extend its filled
material vertically to y 680 through 845, a height of 166 pixels and exact
4:1 ratio. The target is 664 by 166 pixels and exact 4:1 ratio. The current
Image 1 Power is only about 664 by 124 or 5.355:1; do
not preserve that narrow strip and do not place it inside a larger empty box.
The entire 664 by 166 target rectangle must be one continuously filled pigment
surface with no green or transparent hole.

Every pixel outside the frozen Health rectangle and repaired Power rectangle
remains pure #00FF00. Preserve at least 228 green pixels between Health's lower
edge and Power's upper edge, at least 176 green pixels below Power, and about
180 green pixels at both sides. Add no drop shadow, halo, detached fleck,
antialias haze, outline or coordinate mark outside either bbox.

Preserve Image 1's successful neutral equal-channel grey and tintable value.
Power remains matte hand-painted mineral pigment, not leather, parchment,
fabric, metal, glass or a glossy meter. Keep Power quieter than Health, with
small dense horizontal value changes that remain readable after export to 64
by 16 and at four runtime pixels high. Do not introduce colour, a centre
emblem, hotspot, unique end mark, full-width scratch, gradient gloss,
diagonal stripe, repeated chevron, text, UI chrome or mirrored shine.

pfUI applies Health, reaction, Mana, Rage, Focus and Energy colours at runtime;
draw none of those colours into either source. At runtime Health exports to 64
by 32 and Power to 64 by 16, then stretches beneath live text. Keep the full
width statistically quiet and preserve Image 1's accepted Health-coarser,
Power-calmer hierarchy.

Before returning, verify exactly two objects and nothing else: unchanged
Health at about x180..843/y137..451; repaired Power exactly
x180..843/y680..845 at 664 by 166 and 4:1; pure green everywhere outside;
equal-channel grayscale; moderate value; no hotspot, frame, shadow, label,
colour or third object.
```

## 生产正文完整性预检

| 门禁 | V3 final 证据 | 结论 |
|---|---|---|
| 身份、范围、对象数量与动态排除 | V3-A／B 各一张完整空外壳；B1 两个独立 swatch；逐项排除动态内容 | pass-final |
| 图片职责与冲突 | A1 两张固定图分别限制时代尺度和材料；文字合同优先；旧候选禁止输入；B1 无参考图 | pass-final |
| Canvas、方向、比例、隔离与层序 | A1 `1536×1024` 单对象、约 `1284×252`；B1 `1024²` 上下两对象；均正视纯绿 | pass-final |
| 逐对象轮廓、材料与关系 | Player 左修补、Target 右损伤；旧马鞍／盾带皮；Health／Power 粗细差异；用户确认的综合色重已入正文 | pass-final |
| safe area、stretch、slice 与 repeat | A1 中央孔、安静长轨、未来三切片；B1 StatusBar 拉伸和低焦点分布 | pass-final |
| 美术 DNA、反模式、色键与末检 | 香草块面、低频维修、灰阶乘色、纯绿色键、与 Chat／动作条邻接但不复制及逐段最终自检 | pass-final |

- 未知但执行必需的值：无。
- 完整性结论：`pass-final`。用户确认的布局、材质层级、轮廓、配色、视觉
  重量与整合关系均已写回三段正文；三段正文已于 `2026-08-11` 获精确授权。

## V3 历史自主修复循环

### 授权与不可变边界

- `UF-A1 V3-A`：最多 `5` 次实际 ImageGen；固定 Image 1／2；attempt 1 无
  edit input；后续只允许同段紧邻完整前稿作为 Image 3。
- `UF-A1 V3-B`：独立最多 `5` 次；固定 Image 1／2；不得使用 Player 候选、
  失败稿或跨段像素。
- `UF-B1 V2`：独立最多 `5` 次；首次不上传图片；后续仅可使用同段紧邻完整
  前稿作为 edit input。
- 最坏合计 `15` 次实际 ImageGen；流程、传输、上传、权限和落盘错误若无生成
  证据则另记，不占额度。
- 允许自主修复：同段内调整占用率、外轮廓低频误差、材料粗细、磨损／修补
  位置、绿色隔离、颜料频率与明度；可在 regenerate／有界 edit 间选择。
- 不可变：对象身份／数量、参考职责、Canvas、完整外壳粒度、runtime 几何、
  `8%` 后处理阈值、动态排除、纯绿色键、综合色方向和五次上限。
- 必须重新授权：改回端帽 atlas、把 Player／Target 合图、增加参考、跨段复用、
  改变 canvas／runtime／安全区、允许 Python 补画或改变可见方向。

### 当前循环账本

| 段 | 当前子状态 | 实际生成 | 流程错误 | 下一动作 |
|---|---|---:|---:|---|
| `UF-A1 V3-A final.r4` | `repair-budget-exhausted / candidate-rejected` | `5/5` | `2` | 已关闭；V4 禁止使用其像素 |
| `UF-A1 V3-B final.r4` | `repair-budget-exhausted / candidate-rejected` | `5/5` | `1` | 已关闭；V4 禁止使用其像素 |
| `UF-B1 V2 final.r2` | `source-accepted / runtime-exported / addon-integrated` | `3/5 stop` | `1` | 不调用 attempt 4/5；等待 Turtle WoW P6 |

每次实际候选的 session／result、raw／candidate／真实排版路径与 SHA、第一失败
门禁、保留区和下一正文都继续写入本文件；无生成证据的流程错误另表记录。

| 流程错误 | 段／正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 1 | `UF-A1 V3-A final` attempt 1 review／`831e7ca` | 无 provider session | 初版 reviewer 对大量微型材料 fleck 逐个全画布 flood，性能不可接受；主动终止，未调用 provider、未产生新图 | 改为 scanline run union-find，一次线性扫描精确保留面积、bbox、edge 和 center 语义；重跑成功 | 不占生图额度 |
| 2 | `UF-A1 V3-A final.r3` attempt 4 post-copy／`8c76a77` | `019fefbb…1746` | provider 图已经存在；child 尝试用系统 `python3/Pillow` 强制 RGB 时缺少 Pillow，未生成第二张图 | child 退回 `sips` 检查，确认原图 `1536×1024 RGB / no alpha` 后原样复制 | 不额外占生图额度；attempt 4 仍只计一次 |
| 3 | `UF-A1 V3-B final.r4` pre-generation commit／工作树基于 `8a64d44` | 无 provider session | 自动权限审核在执行 `git add && git commit` 前超时；Git 历史与工作树均未被该调用改变，也没有启动 ImageGen | 以相同文件和相同正文重试一次，成功固定为 commit `2e63721` | 不占生图额度；B attempt 5 仍只计后续唯一 provider 调用 |
| 4 | `UF-B1 V2 final` attempt 1 post-normalize／`fff2730` | `019ff008…d61d` | provider 已返回唯一 `1254² RGB` 图；child 已用 `sips` 成功归一化为 `1024²` 后，又以系统 Python/Pillow 做模式确认但环境无 Pillow | 保留 provider raw；系统 `file`／`sips` 确认归一化结果为 `1024² RGB / no alpha`，以该结果审查 | 不额外占生图额度；B1 attempt 1 仍只计一次 |

## 历史终态摘要

- `UF-A1 V1`：整壳两对象 atlas，ImageGen `5/5`；最终外比通过但端柱侵入动态
  走廊，用户明确“不接受例外”；`candidate-rejected / user-rejected`。
- `UF-A1 V2-A V1`：单张四端帽 atlas，ImageGen `5/5`；最终 bbox
  `99–100×954–955`，比例／隔离失败；`repair-budget-exhausted`。
- `UF-A1 V2-A V2`：更完整的单张四端帽正文，ImageGen `5/5`；最终 bbox
  `139–142×798–799`、比例误差 `4.380476%–6.766917%`，等比 fit 仅
  `7×39–40`；`repair-budget-exhausted`。没有 source、runtime 或 addon 改动。
- V2-B 横轨、UF-A2 紧凑框、旧 UF-B1 均未调用，历史额度 `0/5`。V3 是新合同，
  不把任何旧失败稿作为参考、edit、source 或 runtime。

## 下一门禁

Player／Target 的当前下一门禁是独立的 P5：从两张已接受 source 确定性导出
完整 `214×42` runtime、`32/150/32` 变宽装配与状态边，完成真实排版、display
region、addon 接入和 fresh-checkout package 校验。本次“确认, 进入下一阶段”
只授权并完成 P4，不应被解释为 P5 或实机验收授权。P5 仍不得复用 V1／V2／V3
失败像素，也不得改变 Frame 几何、动态内容或交互所有权。

B1 与 Raid A2 的独立下一门禁仍为 Turtle WoW `1.18.1` P6。UF-A2 继续暂停；
V3 A／B 仍禁止第六次调用，其失败像素永久排除于 V4。
