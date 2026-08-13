# Map 详细进度

## 当前结论

- Map runtime `1.1`；`MAP-SIM-V1` 几何预演已由用户验收。
- `MAP-WORLD-A1 V1 attempt 1` 与 `MAP-MINI-A1 V1 attempt 2` 已验收、提升为
  tracked source/runtime，并由 AEUI Map runtime `1.1` 接入，阶段 `P5`。
- 大地图只接管 `WorldMapButton` 周围的四件非交互羊皮卷外壳；内容、pfQuest
  pin／route、Dropdown、返回、关闭、复选框、坐标与滚轮行为仍由 provider 管理。
- 小地图接管常驻 `Minimap` 周围的罗盘环、方向件和空铭牌；区域名与坐标仍是
  动态文字，追踪、邮件、战场、PVP、缩放手势与插件按钮行为保持不变。
- 外壳尺寸运行时读取真实 provider 几何；不支持的几何、其他世界地图 provider、
  Farm mode 或 `/aeui map` 禁用时回退 pfUI，不把常驻罗盘复制到 `pfFarmMap`。
- 十张 accepted runtime 的逻辑像素保持不变；TGA 已透明补齐为 Turtle WoW 1.12
  可加载的 2 次幂容器，并以精确 UV 排除补齐区。实机已确认大地图外缘与小地图
  罗盘恢复可见，非 2 次幂容器导致的静默拒绝已解决。
- 当前实机缺陷转为布局问题：大地图上下卷杆和端帽超出屏幕，四角连接件叠压；
  小地图罗盘贴近右上边界而被裁切，原 provider 黑色条与新空铭牌同时存在，
  动态文字／相邻入口尚未落入正确承托区。阶段仍为 `P5`。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.FRAME` | `P5` | World attempt 1；上下卷杆与左右纸边独立 source/runtime；三切片已在实机加载 | 约束外框到可视区并修正四角连接，再验证 0.70／0.90 缩放与回退 |
| `MAP.WORLD.CONTENT` | `P5 contract` | `WorldMapButton` 真实尺寸驱动；地图与 pfQuest 动态层未烘焙、未改行为 | 实机验证 pin／route 不被边缘遮挡 |
| `MAP.WORLD.LEVELS／PFQUEST.FILTER／BACK／CLOSE／REVEAL` | `P2` contract | 真实对象名与所有权已确认；没有加号／滑尺 | 外壳通过后逐项生产四状态控件 |
| `MAP.MINI.MASK／COMPASS` | `P5` | Mini attempt 2；184 外壳／140 内容已在实机加载 | 修正右上屏幕安全边距，再验证常用尺寸和隐藏／显示 |
| `MAP.MINI.NORTH／DIRECTIONS` | `P5` | 北针与西／东／南方向件独立 runtime；无交互烘焙 | 实机验证小尺寸清晰度与相邻 provider 避让 |
| `MAP.MINI.ZONE／COORDS` | `P5 layout` | 空铭牌独立；实机仍出现 provider 条与铭牌双层承托 | 只保留正确承托并把动态区域名／坐标锚回铭牌 |
| `MAP.MINI.CONTROLS` | `P2 contract` | 真实 Button 尚未重绘，现有行为保持 | 罗盘实机通过后按需生产状态件 |
| `MAP.MINI.ADDONS` | `P2` | 收起吊牌与 4／6／10 动态工具带模拟已验收 | 后续生产吊牌、三段挂带与 socket 状态 |

## 已否决方向

- 大地图连续暗酒红厚皮背板、宽皮带和重型压夹。
- 小地图八槽永久插件环、密集徽章圈和额外加厚金属外圈。
- 把功能承载能力烘焙为默认空槽。

## 下一步

1. 先修大地图可视区约束与四角连接，以及小地图右上安全边距、双层承托和动态
   文字锚点；不重新生成已接受像素，不改变 provider 的交互所有权。
2. 实机验证大地图 0.70／0.90 缩放、pfQuest pin／route、返回与关闭；验证小地图
   常用尺寸、长地名／坐标、邮件／追踪／战场／插件入口相邻布局。
3. 切换 `pfFarmMap`，确认常驻罗盘隐藏且 provider 对象正常迁移；执行
   `/aeui map` 两次，确认 pfUI 背景与动态对象可回退并重新应用。
4. 外壳实机通过后再选择 `MAP.WORLD.*` 控件或 `MAP.MINI.ADDONS` 进入下一批，
   不因本批接入提前标记它们完成。
