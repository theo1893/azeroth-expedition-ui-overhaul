# Map 详细进度

## 当前结论

- WorldMap A1 继续暂停，旧大地图问题未借本次 Minimap 修复重新启用。
- 常驻罗盘／信息托架、锁扣／楔片和状态插槽继续使用已验收 V3 媒体；插件工具卷
  已切换到 `MAP-MINI-V4-TRAY` source/runtime 与四向 TGA，runtime `4.0` 已接入
  `P5`。被实机否决的 V2 不再作为运行时回退；禁用 Map 时直接恢复 pfUI provider
  外观。
- 真实 140×140 `Minimap` 与独立圆形 mask 保持不变；220×264 常驻资源中的约
  204×204 罗盘只向外生长，地图、玩家箭头和 pfQuest 动态层不被压缩，也不能
  越过罗盘内圈。
- 实机图中的地图黑区已确认是角色位于地图边界、provider 没有对应地图块，不是
  圆形 mask 或外壳泄漏；adapter 不对此伪造地图内容。
- 区域名／坐标保持动态并分别占用托架上下两行；V3 中启用的坐标常驻下行，旧
  `pfPanelMinimap` 的动态文字、点击与 Tooltip 也会进入上部安全区，旧黑底不再从
  托架两侧漏出。tracking、邮件、战场和 PVP 保持真实对象并统一有效缩放。
- 插件面板保留 pfUI 扫描、缓存、父级恢复、点击、Tooltip、冷却、通知及原始
  scale；V3 把真实 toggle 重绘为实体锁扣，清除其 pfUI legacy 黑色 backdrop，
  V4 取消纯装饰 connector，让锁扣在更高层直接压住九切片工具卷连续受力边；
  bottom／top 密集入口最多三行并沿水平方向增长，不再形成向下拉长的挂轴。
  0 个入口隐藏锁扣和空工具卷。
- `pfMinimap` 的保存锚点和缩放继续由 pfUI 所有；V3 外壳若超出屏幕，仅按当前
  scale 应用一次最小临时内缩，不写 SavedVariables、不循环维护，禁用或进入
  FarmMode 时恢复原 point。
- `ToggleMinimap`、战斗隐藏和 FarmMode 已有同步路径；FarmMode 不复用或拉伸
  常驻罗盘、信息托架或工具卷；`/aeui map` 可整体恢复／启用 provider 外观。
- 插件工具卷不烘焙任何图标或空槽；预演中曾使用错误截图裁片的问题不进入
  production，游戏中继续显示每个插件自身的完整图标、状态、Tooltip、冷却和通知。
- V4 工具卷已按真实 `21×21` Button、九切片固定区与 0／4／6／30 密度预演；
  图标 padding 直接取自固定区。四向锁扣与工具卷矩形重叠 `4 UI`，扣除各自
  透明边后保留一行可见 Alpha 接触；独立 connector 不再创建或显示。

## 子模块状态

| ID | 阶段 | 当前状态 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.*` | `P4 / paused` | accepted A1 媒体保留，adapter 明确不启用 | 未来单独重开大地图结构修复 |
| `MAP.MINI.PROVIDER／MASK` | `P5` | 140×140 provider 与独立 `MapMiniMaskV3` 已接入；地图边界无地图块的黑区保持 provider 原样 | 实机验证不同尺寸／缩放下无额外泄漏或裁切 |
| `MAP.MINI.COMPASS／INFO.CRADLE` | `P5` | 外壳保持同心；屏幕边缘使用可恢复临时内缩；旧 `pfPanelMinimap` 黑底已移除并桥接其动态内容 | 实机验证右上完整轮廓、托架层序及 `/aeui map` 回退 |
| `MAP.MINI.ZONE／COORDS` | `P5` | 地图名固定居中于上栏，非 off 坐标固定居中于下栏；不再按两段文字互相校准 | 实机验证两个栏位各自居中、长地名、panel `zone` 和 `/aeui map` 后原对齐／hover 恢复 |
| `MAP.MINI.TRACKING／MAIL／BATTLEFIELD／PVP` | `P5` | B attempt 1 独立状态插槽已接入，provider 图标和行为保持动态 | 实机验证并发显隐、邮件闪烁及点击区域 |
| `MAP.MINI.ADDONS.TOGGLE` | `P5` | V3 锁扣 normal／hover／pressed 与四向楔片继续承载真实 Button；V4 将 Button 提到工具卷之上并直接搭接，独立 connector 已退出运行时；pfUI legacy 黑框可恢复 | 实机验证直接搭接、收起／展开、点击、悬停和战斗隐藏 |
| `MAP.MINI.ADDONS.TRAY` | `P5` | V4 source/runtime 与四向九切片已接入；固定区决定真实图标 padding；bottom／top 最多三行，30 入口为 `10+10+10` | 实机验证 0／4／6／10／30、四向展开、rowsize、spacing 与 provider scale |
| `MAP.MINI.VISIBILITY／FARMMODE` | `P5` | 全局显隐同步；FarmMode 恢复独立 pfUI provider，不复用 V3 媒体 | 实机验证迁移、退出恢复及 `/aeui map` 回退 |

## 下一步

在游戏设备执行聚焦验证：先检查 bottom 锁扣直接压住工具卷且不再出现 connector，
再检查 6 个入口单行与 30 个入口 `10+10+10` 的图标均不侵入固定边；相邻回归检查
托架动态文字和 pfQuest 图钉，最后用 `/aeui map` 与 FarmMode 验证原 point／panel／
provider 回退。WorldMap 继续暂停。
