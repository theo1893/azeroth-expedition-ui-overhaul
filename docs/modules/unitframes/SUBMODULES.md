# Unit Frames 子模块与 pfUI 对齐

本模块严格对应 `addon/pfUI/api/unitframes.lua` 创建的真实对象。当前批次只替换
静态媒体及其挂载，不改变另一台设备上的 Frame 锚点、尺寸、事件、点击、
SavedVariables、单位数据或状态逻辑。

## 当前资源批次

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

## 已登记但不在当前批次

| pfUI 配置／对象 | 后续逻辑 ID | 当前处理 |
|---|---|---|
| `focustarget` | `UF.FOCUSTARGET.*` | 暂缓；继续 pfUI 默认视觉 |
| `pet`／`ptarget` | `UF.PET.*`／`UF.PETTARGET.*` | 暂缓 |
| `tttarget` | `UF.TARGETTARGETTARGET.*` | 暂缓 |
| `group`／`grouptarget`／`grouppet` | `UF.PARTY.*` | 暂缓；后续按真实重复数量设计 |
| `raid` | `UF.RAID.*` | 暂缓；不得从主单位框简单缩放复制 |
| `fallback` | `UF.FALLBACK.*` | 保持 pfUI 回退 |
| `portrait = bar/left/right` | `UF.PORTRAIT.*` | 当前 profile 为 `off`；未取得新合同前不制作假头像槽 |
| Buff／Debuff Buttons | `UF.AURA.*` | 当前不重绘 |

## 接入边界

未来 P5 只允许在 `addon/AzerothExpeditionUI` 增加 Unit Frames 媒体与一个作用域
adapter，或在 `addon/pfUI/api/unitframes.lua` 增加等价的精确媒体挂点。不得修改
Frame 的 Point、Width、Height、事件、点击、Secure 模板、状态刷新或配置值；
媒体缺失时局部回退 pfUI 原始 backdrop／bar／glow。
