# Map 详细进度

## 当前结论

- WorldMap A1 继续暂停，旧大地图问题未借本次 Minimap 修复重新启用。
- `MAP-MINI-V3` 的 A attempt 2、B attempt 1、C attempt 4 exact pixels 已验收，
  source/runtime、27 份细粒度 TGA 与 runtime `3.0` adapter 已接入 `P5`。被实机
  否决的 V2 不再作为运行时回退；禁用 Map 时直接恢复 pfUI provider 外观。
- 真实 140×140 `Minimap` 与独立圆形 mask 保持不变；220×264 常驻资源中的约
  204×204 罗盘只向外生长，地图、玩家箭头和 pfQuest 动态层不被压缩，也不能
  越过罗盘内圈。
- 区域名／坐标保持动态，迁移到罗盘下方的一体式制图信息托架；tracking、邮件、
  战场和 PVP 保持真实对象，使用随对象显隐的独立状态插槽。
- 插件面板保留 pfUI 扫描、缓存、父级恢复、点击、Tooltip、冷却、通知及原始
  scale；V3 把真实 toggle 重绘为实体锁扣，并在锁扣和九切片工具卷之间增加
  四向连接件，不再叠加统一逐图标 socket。0 个入口隐藏锁扣、连接件和空工具卷。
- `pfMinimap` 的保存锚点和缩放继续由 pfUI 所有；adapter 不再为屏幕安全距反复
  重写 provider point，外壳与工具带只跟随真实 provider。
- `ToggleMinimap`、战斗隐藏和 FarmMode 已有同步路径；FarmMode 不复用或拉伸
  常驻罗盘、信息托架或工具卷；`/aeui map` 可整体恢复／启用 provider 外观。
- 插件工具卷不烘焙任何图标或空槽；预演中曾使用错误截图裁片的问题不进入
  production，游戏中继续显示每个插件自身的完整图标、状态、Tooltip、冷却和通知。

## 子模块状态

| ID | 阶段 | 当前状态 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.*` | `P4 / paused` | accepted A1 媒体保留，adapter 明确不启用 | 未来单独重开大地图结构修复 |
| `MAP.MINI.PROVIDER／MASK` | `P5` | 140×140 provider 与独立 `MapMiniMaskV3` 已接入；外壳 Alpha 不承担裁剪 | 实机验证不同尺寸／缩放下无泄漏或裁切 |
| `MAP.MINI.COMPASS／INFO.CRADLE` | `P5` | A attempt 2 已提升为 220×264 常驻外壳，中央硬净空与 provider 同心 | 实机验证顶部／右侧屏幕边距和层序 |
| `MAP.MINI.ZONE／COORDS` | `P5` | 两个动态 FontString 已迁入托架独立安全区；旧坐标方位只映射左右对齐 | 实机验证长地名、on／off／hover 与坐标完整性 |
| `MAP.MINI.TRACKING／MAIL／BATTLEFIELD／PVP` | `P5` | B attempt 1 独立状态插槽已接入，provider 图标和行为保持动态 | 实机验证并发显隐、邮件闪烁及点击区域 |
| `MAP.MINI.ADDONS.TOGGLE／CONNECTOR` | `P5` | 锁扣 normal／hover／pressed 与四向楔片／连接件已接真实 Button | 实机验证收起／展开、点击、悬停和战斗隐藏 |
| `MAP.MINI.ADDONS.TRAY` | `P5` | C attempt 4 已导出四向九切片；8 px 内边距承载真实 0／多插件布局 | 实机验证 0／4／6／10／30、rowsize、spacing 与 provider scale |
| `MAP.MINI.VISIBILITY／FARMMODE` | `P5` | 全局显隐同步；FarmMode 恢复独立 pfUI provider，不复用 V3 媒体 | 实机验证迁移、退出恢复及 `/aeui map` 回退 |

## 下一步

在游戏设备执行聚焦验证：先检查默认右上位置是否完整显示罗盘外延与信息托架，
再检查 140×140 圆形地图、长地名／坐标、真实插件图标、0／多入口和四向展开；
最后进入／退出 FarmMode，并用 `/aeui map` 验证 pfUI 回退。WorldMap 继续暂停。
