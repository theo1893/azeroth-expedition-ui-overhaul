# Map 详细进度

## 当前结论

- WorldMap A1 继续暂停，旧大地图问题未借本次 Minimap 修复重新启用。
- `MAP-MINI-OVERHAUL-V2` 保持 `P5`：exact pixels 已验收，九件 Vanilla 安全
  TGA、source/runtime manifest 与 `Map.runtimeContract = 2.4` adapter 已接入。
- 小地图是原生 140×140 `Minimap` 加独立圆形 mask，外侧叠加 184×184 罗盘；
  地图、玩家箭头和 pfQuest 动态层共享被裁剪 provider，不能越过罗盘内圈。
- 区域名／坐标保持动态并回到地图内部；tracking、邮件、战场和 PVP 保持真实
  对象，只统一 socket 与避让位置。
- 插件面板保留 pfUI 扫描、缓存、父级恢复、点击、Tooltip、冷却、通知及原始
  scale；adapter 只替换九切片 tray 与四向排版，不再叠加统一逐图标 socket。
  0 个入口不显示空工具带。
- `pfMinimap` 的保存锚点和缩放继续由 pfUI 所有；adapter 不再为屏幕安全距反复
  重写 provider point，外壳与工具带只跟随真实 provider。
- `ToggleMinimap`、战斗隐藏和 FarmMode 已有同步路径；FarmMode 不复用或拉伸
  常驻罗盘。
- 轻量检查已通过；插件入口现保留 provider scale，并按入口相对工具带的有效
  scale 补偿锚点坐标。当前 30 入口 bottom 展开场景仍阻塞 `P6`：地图名／坐标栏
  被相邻结构遮挡，收纳开关与罗盘连接歪斜，展开工具带的连接和整体轮廓也未与
  罗盘形成统一组件。

## 子模块状态

| ID | 阶段 | 当前状态 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.*` | `P4 / paused` | accepted A1 媒体保留，adapter 明确不启用 | 未来单独重开大地图结构修复 |
| `MAP.MINI.PROVIDER／MASK／FRAME` | `P5` | 圆形硬遮罩、184 外壳已接入；provider 保存锚点／缩放不再被 adapter 覆盖 | 实机确认拖动、重载位置及不同尺寸／缩放无泄漏或裁切 |
| `MAP.MINI.ZONE／COORDS` | `P5` | 动态 provider 保留；当前地图名／坐标栏被相邻结构遮挡 | 恢复完整可读区，再验证长地名和四角坐标 |
| `MAP.MINI.TRACKING／MAIL／BATTLEFIELD／PVP` | `P5` | 独立真实对象复用透明 socket | 实机验证并发通知和显隐 |
| `MAP.MINI.ADDONS` | `P5` | 无逐图标外框的 provider 入口与 scale-aware 锚点已接入；toggle／tray 连接与整体融合未通过实机 | 校正 toggle 对位，并统一展开 tray 与罗盘的连接和轮廓 |
| `MAP.MINI.VISIBILITY／FARMMODE` | `P5` | 全局显隐同步；FarmMode 使用独立方形 provider 与返回短签 | 实机验证迁移和退出恢复 |

## 下一步

下一轮只处理 `CURRENT.md` 记录的三个实机阻塞：先核对地图名／坐标真实对象的
锚点与层序，再校正 toggle 对位，最后统一展开 tray 的连接和整体轮廓。先判断是
布局问题还是需要新像素；不要顺带启用 WorldMap。
