# Map 详细进度

## 当前结论

- `MAP-SIM-V1` 几何预演已由用户验收。
- `MAP-WORLD-A1 V1 attempt 1` 与 `MAP-MINI-A1 V1 attempt 2` 已验收、提升为
  tracked source/runtime，并由 AEUI Map runtime `1.0` 接入，阶段 `P5`。
- 大地图只接管 `WorldMapButton` 周围的四件非交互羊皮卷外壳；内容、pfQuest
  pin／route、Dropdown、返回、关闭、复选框、坐标与滚轮行为仍由 provider 管理。
- 小地图接管常驻 `Minimap` 周围的罗盘环、方向件和空铭牌；区域名与坐标仍是
  动态文字，追踪、邮件、战场、PVP、缩放手势与插件按钮行为保持不变。
- 外壳尺寸运行时读取真实 provider 几何；不支持的几何、其他世界地图 provider、
  Farm mode 或 `/aeui map` 禁用时回退 pfUI，不把常驻罗盘复制到 `pfFarmMap`。
- 静态资产包装检查已通过；当前设备没有游戏客户端，因此尚未达到 `P6`。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.FRAME` | `P5` | World attempt 1；上下卷杆与左右纸边独立 source/runtime；三切片接入 | 实机验证 0.70／0.90 缩放、边缘层级及禁用回退 |
| `MAP.WORLD.CONTENT` | `P5 contract` | `WorldMapButton` 真实尺寸驱动；地图与 pfQuest 动态层未烘焙、未改行为 | 实机验证 pin／route 不被边缘遮挡 |
| `MAP.WORLD.LEVELS／PFQUEST.FILTER／BACK／CLOSE／REVEAL` | `P2` contract | 真实对象名与所有权已确认；没有加号／滑尺 | 外壳通过后逐项生产四状态控件 |
| `MAP.MINI.MASK／COMPASS` | `P5` | Mini attempt 2；184 外壳／140 内容，统一缩放接入 | 实机验证常用尺寸、屏幕边缘和隐藏／显示 |
| `MAP.MINI.NORTH／DIRECTIONS` | `P5` | 北针与西／东／南方向件独立 runtime；无交互烘焙 | 实机验证小尺寸清晰度与相邻 provider 避让 |
| `MAP.MINI.ZONE／COORDS` | `P5 layout` | 空铭牌独立；两段文字仍由 pfUI 动态绘制并保持原显隐规则 | 实机验证中文长地名与坐标排版 |
| `MAP.MINI.CONTROLS` | `P2 contract` | 真实 Button 尚未重绘，现有行为保持 | 罗盘实机通过后按需生产状态件 |
| `MAP.MINI.ADDONS` | `P2` | 收起吊牌与 4／6／10 动态工具带模拟已验收 | 后续生产吊牌、三段挂带与 socket 状态 |

## 已否决方向

- 大地图连续暗酒红厚皮背板、宽皮带和重型压夹。
- 小地图八槽永久插件环、密集徽章圈和额外加厚金属外圈。
- 把功能承载能力烘焙为默认空槽。

## 下一步

1. 在游戏设备验证：大地图 0.70／0.90 缩放、pfQuest pin／route、返回与关闭；
   小地图常用尺寸、长地名／坐标、邮件／追踪／战场／插件入口相邻布局。
2. 切换 `pfFarmMap`，确认常驻罗盘隐藏且 provider 对象正常迁移；执行
   `/aeui map` 两次，确认 pfUI 背景与动态对象可回退并重新应用。
3. 外壳实机通过后再选择 `MAP.WORLD.*` 控件或 `MAP.MINI.ADDONS` 进入下一批，
   不因本批接入提前标记它们完成。
