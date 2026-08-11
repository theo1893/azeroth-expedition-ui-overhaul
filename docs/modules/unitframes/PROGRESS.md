# Unit Frames 模块详细进度

## 当前状态

- 主模块：UF-A1 当前进入
  `UF-A1 V2-A V2 / P3 / prompt-authorized`。旧 V2-A V1 为
  `P3 / candidate-rejected / repair-budget-exhausted`。用户于 `2026-08-11` 明确授权
  `UF-A1 V2-A V1`／`UF-A1 V2-B V1` 按 A→B 执行，每段最多五次实际
  ImageGen、固定 Image 1／2、同段紧邻前稿有界 edit、流程错误不占额度、
  禁止跨段复用像素，并允许合同内确定性拆分、色键、等比 bbox-fit、真实排版
  与缩放预演。V2-A 已实际执行 `5/5` 且无合格候选；V2-B 因 A→B 顺序保持
  `0/5 / sequence-blocked`。用户随后明确否决逐端帽独立生成，要求新版本继续
  由一次调用输出一张四端帽 atlas，并只通过更详尽的正文约束结果。该决定没有
  改变八件 source、标准单 shell、可变宽度三切片、固定高度或可见方向，因此
  `UF-A1-V2-SIM-V2` 的确认继续有效；新 `UF-A1 V2-A V2` 已于
  `2026-08-11` 按固定 Image 1／2、attempt 1 无 Image 3、同循环紧邻前稿仅限
  整图有界 edit、最多五次实际调用、流程错误不占额度及确定性审查合同获得
  正式生产授权，当前 `0/5`；
  `UF-PRIMARY-SIM-V1` 已于 `2026-08-11` 获用户方向确认。`UF-A1 V1` 已完成
  五次实际 ImageGen，终态为
  `candidate-rejected / repair-budget-exhausted / user-rejected`；用户于
  `2026-08-11` 明确表示“不接受例外”。`UF-A2 V1`、`UF-B1 V1` 仍为
  `prompt-authorized / paused`。没有候选获得用户接受。
- 当前只覆盖 `player`、`target`、`targettarget`、`focus` 的资源外观；不修改
  另一台设备的 Frame 位置、尺寸与功能。
- 当前仓库／远端 `main` 尚未包含用户在游戏设备完成的布局 overhaul；本批次
  因只使用现有 pfUI 资源尺寸，不把屏幕位置作为生产合同。
- 新 V2 生成前模拟 ImageGen：`0/0`；历史正式生产为 A1 V1 `5/5`，A2／B1
  各 `0/5`。V2-A V1 已用满 `5/5`，新 V2-A V2 为 `0/5`，V2-B 未启动且为
  `0/5`。A1 V1 有
  两次无生成证据的流程错误，
  不占额度。attempt 5 的 Player／
  Target 比例误差 `0.071891%`／`0.448322%` 均通过，但真实动态走廊仍有
  `872`／`818` 个 Alpha 像素被端柱侵入，横向隔离只有 `68–78px`，低于
  `96px`；因此没有 source 或 addon runtime。

## UF-A1 V2 缩放安全结构模拟

- 当前版本：`UF-A1-V2-SIM-V2`；只使用本地 Pillow 几何，ImageGen `0/0`，
  没有上传范围、provider 会话、production source/runtime 或 addon 改动，也
  没有复用任一 V1 失败稿像素。
- source 粒度不变：每角色四件——左／右端帽各 `7×42`，上／下轨各
  `200×6`。V2-SIM.V1 的直接四纹理挂载被缩放风险取代，只保留为八件 source
  互斥和动态区零覆盖的证据。
- 默认 `W=200` 时，确定性 builder 把每角色四件预合成为一张 `214×42` RGBA
  shell，运行时只挂载一张 Texture，内部 Texture 接缝为 `0`。
- 只有可变宽度才使用三切片：中央带同时承载上下轨和透明中部，在左右各
  向固定端帽下方伸入 `1 logical px`；重叠只在装饰角，动态安全区仍为
  `x 7..W+7 / y 6..36`。高度固定 `42`，禁止纵向拉伸。
- 标准路径在 `0.64/0.71/0.80/0.90/1.00/1.15×` 全部通过：每角色 runtime
  Texture `1`、内部接缝 `0`、安全区不透明装饰侵入 `0`。可变宽度
  `W=160/200/240` 在 `0.71/1.00×` 的接头空洞与安全区侵入均为 `0px`。
- 展示区域报告 `6/6 pass`、violations `0`；连续两次本地重建的缩放矩阵、
  装配板、几何报告与展示区域报告 SHA 完全一致。
- 规格：`tools/specs/unitframes_a1_v2_simulation_v2.json`；渲染器：
  `tools/render_unitframes_a1_v2_simulation_v2.py`；展示区域合同：
  `tools/specs/unitframes_a1_v2_simulation_display_region_v2.json`。
- 缩放矩阵 SHA `6040d50d…cd0d`；source → runtime／三切片板 SHA
  `81d45b0b…95e5`；几何报告 SHA `59fae38d…521e`；展示区域报告 SHA
  `759316cf…775`。bilinear 只是客户端过滤近似，不替代 Turtle WoW P6。
- 用户于 `2026-08-11` 在看到缩放矩阵、装配板与校验结果后原文“确认”。现已
  冻结八个独立 source、标准单 shell、可变宽度三切片、共同取整、装饰角
  `1px` extrusion／overlap 和 `42px` 固定高度；确认不接受模拟像素。
- 稳定结构已写入 `SUBMODULES.md`；work 中旧 `UF-A1 V2-A V1` 四端帽与
  `UF-A1 V2-B V1` 四横轨最终生产正文、builder 合同及两段修复边界已经通过
  自包含预检。正式生产已授权；V2-A 五稿均未通过，最终 attempt 5 的四件 bbox
  为 `99–100×954–955px`，比例误差 `37.106918–37.801047%`，上下隔离只有
  `34–36px`。用户已否决逐端帽独立调用；新 `UF-A1 V2-A V2` 保留同一单图
  四列画布和四件 source，只把布局优先级、等分关系、端部接触、视觉重量不得
  通过增宽表达及逐项末检写得更完整。生产规格为
  `tools/specs/unitframes_a1_v2a_production_v2.json`，当前已授权、`0/5`。没有
  production source/runtime 或 addon 改动。

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
  `UF-B1 V1` 已把上述结论写入并获生产授权。A1 的 `V1` 至 `V1.r4` 和五次
  完整审查均在同一 work／Git 历史；A2／B1 尚未调用。

## 下一门禁

先提交已授权的 `UF-A1 V2-A V2` 单图四格正文与规格基线，再执行 attempt 1；
随后完成固定四列拆分、边缘连通色键、透明 RGB 清零、等比 bbox-fit、真实排版
与缩放审查。内部通过即停止；否则只在冻结边界内自主修复，最多累计五次实际
调用，流程错误不占额度。它不是旧 V2-A V1 的第六次调用。V2-A V2 内部通过
后才恢复 V2-B；用户接受前不产出 tracked source/runtime、不接入 addon。
A2／B1 继续暂停，额度均为 `0/5`。
