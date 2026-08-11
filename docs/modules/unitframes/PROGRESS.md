# Unit Frames 模块详细进度

## 当前状态

- 主模块：`P3`；`UF-PRIMARY-SIM-V1` 已于 `2026-08-11` 获用户方向确认，
  `UF-A1 V1`、`UF-A2 V1`、`UF-B1 V1` 已获得正式生产授权，当前子状态为
  `prompt-authorized`。方向确认不接受模拟像素，生产授权不构成候选接受。
- 当前只覆盖 `player`、`target`、`targettarget`、`focus` 的资源外观；不修改
  另一台设备的 Frame 位置、尺寸与功能。
- 当前仓库／远端 `main` 尚未包含用户在游戏设备完成的布局 overhaul；本批次
  因只使用现有 pfUI 资源尺寸，不把屏幕位置作为生产合同。
- 生成前模拟 ImageGen：`0/0`；正式生产为 `0/15`。A1／A2 固定上传两张已哈希
  Chat 锁定参考，B1 首次无输入图；固定执行器尚未启动，没有 source 或 addon
  runtime。

## 已完成的对象审计

| 批次 | 对象 | provider 几何 | 当前结论 |
|---|---|---|---|
| `UF-A1` | Player／Target 两张独立大外壳 | `200×25 + 200×4`，外接 `214×42` | 同族非镜像；深胡桃皮革主结构，断续黄铜 |
| `UF-A2` | TargetTarget／Focus 两张独立紧凑外壳 | `100×20 + 100×1`／`100×25 + 100×1`；外接 `112×34`／`112×39` | 紧凑件不直接缩放大框；Focus 使用靛蓝猎踪布结 |
| `UF-B1` | Health／Power 共享填充纹 | `64×32`／`64×16` runtime donor | 灰阶哑光颜料纹，由 pfUI 动态着色 |
| deterministic | Hover／Aggro rim | 由接受外壳 Alpha 派生 | 不消耗 ImageGen，不形成连续霓虹 |

## 生成前模拟

- 版本：`UF-PRIMARY-SIM-V1`。
- 规格：`tools/specs/unitframes_primary_simulation_v1.json`。
- 渲染器：`tools/render_unitframes_primary_simulation_v1.py`。
- 展示区域合同：`tools/specs/unitframes_primary_simulation_display_region_v1.json`。
- 输出：
  `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.scene.png` 与
  `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.zoom.png`。
- 输出 SHA-256：scene
  `107b2a71cf29938bf69f8a871c8fcdcae50a561a9b438a929f2a7d684264861c`；zoom
  `d5e76afef373c96a93571ddf9d6a1116e6428a1aec86b53046c8cb73ac1a4e48`。
- 展示区域报告：
  `generated/unitframes/primary/simulation/V1/display-region-report.json`，SHA
  `9d22e5e2c50e0c25b7ad0dbb5dfb11562f71b2e097a730285458c281de7b82ad`；
  Player normal、Target aggro、TargetTarget normal、Focus hover 共 `4/4 pass`，
  violations `0`。
- 目的：确认行军身份牌隐喻、非镜像不规则轮廓、皮革／断续黄铜层级、靛蓝
  Focus 标记、综合色重和与经典动作条／战地旧书的邻接关系。
- 非权威：微纹理、手绘笔触、Alpha、切片、最终贴图接缝与远端布局位置。
- 内部结论：`displayable`。动态条、文字与 Button hitbox 均留在安静区；
  Target 仇恨和 Focus hover 仅使用断续短边，不形成现代连续发光框。
- 用户确认的可见方向：深胡桃旧皮革为主、烟褐内衬为辅、氧化黄铜只作断续
  短夹件；Player 左端修补偏重、Target 右端损伤偏重且不得镜像；紧凑框采用
  减法；Focus 靛蓝布结必须被皮革与暗铜钉真实压住；低频歪斜和不等端帽来自
  维修，不使用规则金框、假头像槽或连续霓虹。
- 正式生产正文：`UNITFRAMES.CORE.md` 中 `UF-A1 V1`、`UF-A2 V1`、
  `UF-B1 V1` 已把上述结论写入并通过自包含完整性复审，当前均为
  `production-final / unauthorized`。

## 下一门禁

按用户授权顺序先执行 `UF-A1 V1` 的固定 ImageGen 五次内自主循环；每个实际
候选完成语义、物理、美术、技术、真实 runtime 排版与展示区域检查，通过即停。
随后同样处理 `UF-A2 V1` 与 `UF-B1 V1`。最坏合计十五次，流程错误不计入生图
额度；任何内部通过只达到 `candidate-reviewed / P3`，仍需用户单独接受才可
进入 P4。
