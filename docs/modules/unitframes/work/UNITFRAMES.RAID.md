# Unit Frames Raid 团队框架工作记录

## 元数据

- 模块：Unit Frames
- 组件 ID：`UF.RAID.*`
- 版本：`UF-RAID-SIM-V1`
- 子状态：`simulation-reviewed / user-confirmation-pending`
- 项目阶段：`P2`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前操作：`simulate`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 自动修复预算：正式生成后每段最多 5 次实际 ImageGen；当前未请求授权
- 当前实际生图：`0/0`
- 流程错误：`0`
- 多执行正文最坏实际生图数：`pending`；需在模拟确认和最终正文形成后冻结
- raw／candidate／source／runtime：无
- 锁定视觉基准：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
    只继承 2004 年位图尺度、材料厚度、暖光与粗糙磨损。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
    只继承深胡桃旧皮革、手工误差和克制的暗铜响应。
- 次级现有 runtime：`UnitFrameHealthFillV1.tga`／`UnitFramePowerFillV1.tga`；
  模拟按真实像素使用，但 addon 尚未把它们路由给 Raid。

## 美术基准继承

### 权威顺序

1. 上述两张 Chat 锁定图及其在 Unit Frames 主／子模块 Prompt 中声明的受限职责；
2. `docs/modules/unitframes/ART_BASELINE.md`；
3. `docs/GLOBAL_ART_BASELINE.md`；
4. `docs/modules/unitframes/SUBMODULES.md` 的真实对象、几何和动态所有权；
5. 已接受 Health／Power source，只负责条形颜料材质，不反向定义外壳。

### 必须继承的视觉 DNA

- 物件身份仍属于“远征队行军身份牌”：旧马鞍带、盾牌背带、帐篷捆扎皮被
  拆下重用，皮革承担结构，黄铜只作少量修补。
- 低饱和烟褐／深胡桃色、左上暖光、早期 WoW 宽块面和低频手工误差；不靠
  均匀毛孔、规则针脚或对称铆钉制造做旧。
- 粗犷感在 40 个对象组成的整体编队中成立；单个成员条必须轻薄，不能把每个
  `70×33` Button 变成一个厚重卡片。

### 本批组件级转译

- 每个成员是夹在远征点名册编队中的短皮革名条，不是独立书页、书签或缩小的
  Player／Target 外壳。
- 使用 `A/B/C/D` 四个完整外壳变体，按 `pfRaid` 槽位确定性分配；缺口、补针、
  暗铆钉和短修补位置不同，但综合色重相同。换人不改变槽位外观。
- 外夹边只在 Button 外露约 `2px`，中心由真实 Health／Power、名称与状态占据；
  40 人密度下不增加一圈共享书框、金属框或半透明底板。
- Hover／Aggro 只响应两三段破边；Range／Offline 继续由 pfUI Alpha 表达。

### 明确不继承

- 不继承 Chat 的书页、书脊、频道签、蜡封、立柱、龙纹或完整书框；
- 不继承主单位框的较厚端部、身份夹片比例或 `214×42` 轮廓；
- 不新增《暗黑破坏神 3》黑铁祭坛、现代玻璃卡片、整框霓虹或规则工业网格。

### 冲突审计

- 全局“厚重”与 40 人信息密度冲突：厚重由整组暗色材料和真实状态密度产生，
  单成员外夹边保持 2px；不得把重量误译为 40 个厚框。
- “不工整”与可读性冲突：只在外轮廓、染色、短补针和四变体分布中产生低频
  差异；Health／Power、安全区、名称中心与点击盒仍精确对齐。
- 原 pfUI 完整矩形 Glow 与本项目语言冲突：保留状态逻辑，未来只替换绘制层。

## provider 审计与边界

- `addon/pfUI/modules/raid.lua` 创建 `pfRaid1..pfRaid40`，每个均来自
  `pfUI.uf:CreateUnitFrame("Raid", i, C.unitframes.raid)`；全部是真实 Secure
  Button，并登记 ClickCast。
- 当前仓库 profile：`maxraid=40`、`raidlayout=10x4`、`raidfill=VERTICAL`、
  `raidpadding=5`、`border=1`、`width=70`、`height=30`、`pheight=2`、
  `pspace=-1`、`portrait=off`。
- `UpdateFrameSize()` 得到 Button `70×33`；HP 为 `70×30`，Power 为 `70×2`，
  中间 `1px`；布局 pitch 为 `77×40`。40 个 Button bbox 为 `763×153`；计入
  `2px` 外壳和最高 Raid Icon 后的视觉包络为 `767×159`。
- Cluster 固定从屏幕左下 `x=2` 开始；因此左侧外扩最多 `2px`，否则首列会被
  屏幕裁切。模拟使用 `74×37` 外壳，不修改 Cluster Point。
- `raidforgroup` 可把同一对象用于五人队，`selfinraid` 可用于单人；二者当前
  profile 均关闭。`raidgrouplabel` 当前关闭，但 provider 最多已有 8 个
  `Group N` FontString 对象。
- `addon/pfUI/modules/group.lua` 的 Party／PartyTarget／PartyPet 以及
  `modules/raidmarkers.lua` 的 Raid Marker 血条列表均不属于本批。

## 组件合同

| 逻辑对象 | runtime 数量 | 本批处理 | 动态所有权／禁止烘焙 |
|---|---:|---|---|
| `UF.RAID.MEMBER.SHELL.A-D` | 40 选 4 | 四个完整背景外壳；每个标准 art box `74×37` | 不烘焙名称、血量、职业色、状态、图标或点击 |
| `UF.RAID.BAR.HEALTH.FILL` | 40 | 模拟复用已接受 `64×32` donor；确认后再扩展 adapter scope | 数值、宽度、颜色、动画与治疗预测归 pfUI |
| `UF.RAID.BAR.POWER.FILL` | 40 | 模拟复用已接受 `64×16` donor；真实显示高 `2px` | Mana／Rage／Energy／Focus 色与裁切归 pfUI |
| `UF.RAID.STATE.RIM` | 每框按需 | 未来从接受外壳 Alpha 确定性派生短边 mask | Hover／Aggro／Combat 事件归 pfUI；禁止整框光圈 |
| `UF.RAID.STATE.PIP` | 每框最多 1 | provider 选项启用时使用小型破颜料角标；不单独 ImageGen | `squareaggro`／`squarecombat` 判定归 pfUI |
| `UF.RAID.AURA.RIM` | 每框最多 6＋驱散图标 | 只增加 1px 烟黑承托；图标本体不重绘 | Aura、层数、冷却、驱散类型与 Tooltip 归 pfUI |
| Vanilla 功能 glyph | 每框按需 | 队长、主拾取、Raid Target、复活保留动态身份 | 不烘焙进外壳；后续只允许增加暗色承托 |
| `UF.RAID.GROUP.LABEL.BACKING` | 最多 8 | 已审计，因当前关闭而暂停 production | `Group N` 文字继续是 FontString |

### 尺寸、拉伸与层序

- 标准外壳相对真实 Button 外扩 `left/right/top/bottom=2px`；外壳必须
  `EnableMouse(false)`，Button 命中盒仍为 `70×33`。
- 标准高度固定为 `33px`。整体 UI Scale 由共同 Parent 同步缩放，不会产生
  拼接错位；若用户只改变 Width，接受完整 source 可确定性派生横向三切片，
  唯一修补必须留在固定端部。Height 偏离当前合同则局部 fail-open，不纵向
  强拉美术。
- 层序由低到高：外壳／烟褐 liner → HP／Power 背景 → 动态 fill／治疗预测 →
  名称 → Buff／Debuff／Raid Icon／复活 → 短边状态响应。任何 art 不接管鼠标。
- 原 `CreateBackdrop` 透明方块与 `glow2` 只会在 P5 adapter 成立后针对 Raid
  隐藏／替换；其他 UnitFrame 保持原状。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-RAID-SIM-V1`
- 目标场景：当前 profile 的完整 40 人团队、真实屏幕锚点、Chat／经典动作条／
  罗盘邻接；审阅板另含四变体、状态层、可选 Group Label 与 100% 重复密度。
- 真实对象数量：`40`；不是稀疏 contact sheet。
- 状态分布：Hover、Aggro、Range、Offline、Dead、Incoming Heal、Resurrection、
  Buff、Magic／Poison、Leader、Master Looter 与三个 Raid Marker。
- 当前 accepted/runtime：Health／Power 使用 addon 内现有 TGA 的真实像素；
  新外壳、状态边缘与相邻 UI 均为简单几何占位。
- 用户需要确认：不增加共享外框；薄皮革点名名条隐喻；四变体力度；暗色配色；
  单框与 40 人整体的重量；状态是否清楚且不过度现代。
- 非权威：最终笔触、Alpha、source extraction、production canvas、atlas packing、
  Group Label 成品和目标设备 SavedVariables。
- 禁止用途：模拟像素不得成为 source/runtime，不得作为生产 edit/reference 输入。

### 本地模拟规格与执行

- specification：`tools/specs/unitframes_raid_simulation_v1.json`
- renderer：`tools/render_unitframes_raid_simulation_v1.py`
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 命令：`conda run -n py312 python tools/render_unitframes_raid_simulation_v1.py`
- scene：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.scene.png`，
  SHA-256 `41468266052da80579f1194f028a83adf7dc81afce6f458d617a0ea246325519`。
- review：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.review.png`，
  SHA-256 `10158347dd9ba002cb07f3519d8a42174547340ee79ff176fce9e9608e08eca2`。
- ImageGen：`0/0`；本地渲染错误：`0`。
- 内部结论：`displayable`。40 人密度、四变体分布、已接受条纹理、状态层和
  相邻 UI 可共同读取；没有额外共享外框。

### 实际展示区域门禁

- 合同：`tools/specs/unitframes_raid_simulation_display_region_v1.json`
- 报告：`generated/unitframes/raid/simulation/V1/display-region-report.json`，
  SHA-256 `ddb3fc51b7c3ef2e1590ecc145b4668ed3d23c5e627600dfa2d0a424a8ce6dd0`。
- 结果：`7/7 pass`，violations `0`，first failure `null`。
- 覆盖：单成员普通／重状态、40 人 Vertical／Horizontal、20 人、五人复用、
  `width=90` 横向变化；Height 变更明确不在本合同内并 fail-open。

### 用户方向结论

- 具体模拟版本：`UF-RAID-SIM-V1`
- 用户结论：`pending`
- 模拟像素接受：`false`
- 正式生产授权：`false`
- 下一门禁：用户确认或退回本模拟的布局、物件隐喻、材质层级、配色、重量和
  整合关系；确认后才形成自包含 production prompt 与逐段五次预算。

## 生产正文完整性预检

- 当前结论：`blocked-before-final-prompt`。
- 已知：真实对象、数量、状态、Canvas 方向、runtime 几何、安全区、动态排除、
  参考职责、四变体关系、拉伸边界与反模式。
- 未知：用户对 `UF-RAID-SIM-V1` 的方向结论，以及由此冻结的一次或多段正式
  production packaging。未确认前不得撰写为可授权正文、上传参考或调用模型。

## 自主修复循环

- 当前未启动；实际 ImageGen `0/0`。
- 模拟确认后，每段仍须单独冻结完整正文、参考 SHA、首次上传职责、允许的
  同段 edit 边界和最多 5 次实际生成；流程错误不计额度。
- 必须重新确认：新增共享外框、改变成员物件隐喻、减少／增加四个 source
  变体、把动态状态烘焙、修改 provider Button 几何或把 Party／RaidMarker
  混入本批。
