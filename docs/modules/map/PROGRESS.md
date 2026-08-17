# Map 详细进度

## 当前结论

- WorldMap A1 继续暂停，旧大地图问题未借本次 Minimap 修复重新启用。
- `MAP-MINI-OVERHAUL-V2` 已达到 `P5`：exact pixels 已验收，九件 Vanilla 安全
  TGA、source/runtime manifest 与 `Map.runtimeContract = 2.0` adapter 已接入。
- 小地图是原生 140×140 `Minimap` 加独立圆形 mask，外侧叠加 184×184 罗盘；
  地图、玩家箭头和 pfQuest 动态层共享被裁剪 provider，不能越过罗盘内圈。
- 区域名／坐标保持动态并回到地图内部；tracking、邮件、战场和 PVP 保持真实
  对象，只统一 socket 与避让位置。
- 插件面板保留 pfUI 扫描、缓存、父级恢复、点击、Tooltip、冷却与通知；仅替换
  真实 toggle、九切片 tray、socket 和四向排版。0 个入口不显示空工具带。
- `ToggleMinimap`、战斗隐藏和 FarmMode 已有同步路径；FarmMode 不复用或拉伸
  常驻罗盘。
- 轻量检查已通过；当前设备无客户端，行为结论仍需 `P6` 实机确认。

## 子模块状态

| ID | 阶段 | 当前状态 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.*` | `P4 / paused` | accepted A1 媒体保留，adapter 明确不启用 | 未来单独重开大地图结构修复 |
| `MAP.MINI.PROVIDER／MASK／FRAME` | `P5` | 圆形硬遮罩、184 外壳、≥24 UI 安全距已接入 | 实机确认不同尺寸／缩放无泄漏或裁切 |
| `MAP.MINI.ZONE／COORDS` | `P5` | 动态文字位于地图内，保留 pfUI 显示配置 | 实机验证长地名和四角坐标 |
| `MAP.MINI.TRACKING／MAIL／BATTLEFIELD／PVP` | `P5` | 独立真实对象复用透明 socket | 实机验证并发通知和显隐 |
| `MAP.MINI.ADDONS` | `P5` | 四向 toggle、九切片 tray、动态 socket 已接入 | 实机验证数量、状态与原始交互 |
| `MAP.MINI.VISIBILITY／FARMMODE` | `P5` | 全局显隐同步；FarmMode 使用独立方形 provider 与返回短签 | 实机验证迁移和退出恢复 |

## 下一步

在游戏设备直接拉取仓库并进行 `CURRENT.md` 中五项 P6 检查。未通过时只修正对应
运行时对象；不要重新打开已验收像素，也不要顺带启用 WorldMap。
