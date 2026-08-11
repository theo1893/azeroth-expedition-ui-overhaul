# Unit Frames 模块详细进度

## 当前状态

- `UF-A1 V3-A` Player 完整外壳：`P2 / simulation-reviewed / 0/5`。
- `UF-A1 V3-B` Target 完整外壳：`P2 / simulation-reviewed / 0/5`。
- `UF-B1 V2` Health／Power 灰阶填充纹：`P2 / simulation-reviewed / 0/5`。
- `UF-A2` TargetTarget／Focus：继续暂停；既有物件身份方向不变，尚无正式
  source。Hover／Aggro 仍计划由接受外壳 Alpha 确定性派生。
- 当前只处理资源重绘、后处理合同与未来替换路径；没有修改另一台设备上的
  Frame 位置、尺寸、点击、事件、数值或其他功能，也没有 addon runtime 变更。
- 用户于 `2026-08-11` 接受“每个角色生成完整外壳，Python 负责精确工程化”
  的架构，并要求同时重绘生命与 Mana／Rage／Focus／Energy 等资源条材质。
- 新模拟 `UF-PRIMARY-V3-SIM-V1` 已本地完成并通过内部几何门禁，等待用户确认
  可见方向。ImageGen `0/0`；三段 production 均未授权。

## V3 结构合同

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

## 展示区域门禁

- 合同：`tools/specs/unitframes_primary_v3_simulation_display_region_v1.json`
- 报告：`generated/unitframes/primary/simulation/V3/display-region-report.json`，
  SHA `625f4dc0…19e3b`
- 结果：Player Mana／Rage／Focus／Energy、Target Rage、Player `W=160`、Target
  `W=240` 共 `7/7 pass`，violations `0`。
- 本结果只证明 source／shell／live region／Button 安全区合同，不能证明最终
  笔触、材质或 Turtle WoW 混合。

## 正式生产草案与预算

- `UNITFRAMES.CORE.md` 只保留当前 V3 合同、三段自包含 draft、历史终态摘要和
  下一门禁；V1／V2 的逐稿全文继续由 Git 历史保存。
- `UF-A1 V3-A`、`UF-A1 V3-B`、`UF-B1 V2` 每段拟议最多 `5` 次实际
  `imagegen-0-143-0`，最坏合计 `15` 次；当前全部 `0/5 / not-authorized`。
- 流程错误无生成证据时单独记录，不占额度。旧 V1／V2 失败像素禁止作为新段
  reference、edit、source 或 runtime。

## 历史终态

- `UF-A1 V1`：`5/5 / candidate-rejected / user-rejected`；最终端柱侵入动态
  安全区，用户明确拒绝例外。
- `UF-A1 V2-A V1`：`5/5 / repair-budget-exhausted`；端帽比例／隔离失败。
- `UF-A1 V2-A V2`：`5/5 / repair-budget-exhausted`；最终四件
  `139–142×798–799`、比例误差 `4.380476%–6.766917%`，等比 fit 仅
  `7×39–40`。没有 source、runtime 或 addon 改动。
- V2-B、UF-A2、旧 UF-B1 均未调用；历史额度 `0/5`。

## 下一门禁

等待用户确认或否决 `UF-PRIMARY-V3-SIM-V1` 的完整外壳、旧马鞍／盾带式
粗犷方向、Player／Target 非镜像关系、Health／Power 材质层级和四资源乘色
观感。确认后才可把结论写回三段 final production 正文并请求正式授权；当前
禁止调用 ImageGen、创建 source/runtime、修改 addon 或复用旧失败像素。
