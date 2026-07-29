# Map 子模块定义

本文件只定义地图模块与 pfUI／原生对象的对齐。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 来源

| 文件 | 已证实职责 | 项目处理 |
|---|---|---|
| [`modules/map.lua`](../../../addon/pfUI/modules/map.lua) | WorldMap 布局、缩放／拖动及地图相关呈现 | 当前原生回退；以后只替换外壳与控件 |
| [`modules/mapcolors.lua`](../../../addon/pfUI/modules/mapcolors.lua) | 地图颜色行为 | 保留数据／配置，不把颜色烘焙进外框 |
| [`modules/mapreveal.lua`](../../../addon/pfUI/modules/mapreveal.lua) | 未探索区域显示增强 | 保留功能，独立于外壳美术 |
| [`modules/minimap.lua`](../../../addon/pfUI/modules/minimap.lua) | `Minimap`、mask、缩放、区域、坐标、邮件与战场入口 | 当前原生回退；未来 adapter 保留原生内容 |
| [`modules/tracking.lua`](../../../addon/pfUI/modules/tracking.lua) | 追踪入口与状态 | 保留功能，按真实 Button 换肤 |
| [`modules/addonbuttons.lua`](../../../addon/pfUI/modules/addonbuttons.lua) | 扫描、移动、保存小地图插件按钮；`pfMinimapButtons`／`pfMinimapButton` | 可复用行为，重做动态锚点与溢出呈现 |
| [`modules/farmmode.lua`](../../../addon/pfUI/modules/farmmode.lua) | 小地图扩展使用模式 | 作为兼容状态，不能固化进罗盘母版 |
| [`skins/blizzard/battlefield_minimap.lua`](../../../addon/pfUI/skins/blizzard/battlefield_minimap.lua) | 战场小地图 skin | 独立系统面板，不与常驻罗盘背景合并 |

## 世界地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.WORLD.FRAME` | `WorldMapFrame`、pfUI `map.lua` | 羊皮地图卷外壳；木杆、端帽、卷边必须独立切片 |
| `MAP.WORLD.CONTENT` | WorldMap detail／continent／zone 图层 | 原始地图内容与标记保持动态；只定义安全区与裁切 |
| `MAP.WORLD.TITLE` | WorldMap 标题 FontString，精确对象待实机 | layout-only；窄皮革铭牌不得烘焙文字 |
| `MAP.WORLD.LEVELS` | 世界／大陆／地区／副本导航对象待实机 | 每个真实入口独立状态；不生成固定网页 Tab |
| `MAP.WORLD.LEGEND` | 图例与过滤对象待实机 | 可收起窄纸；无真实对象前不生产 |
| `MAP.WORLD.ZOOM` | pfUI／原生缩放控件待实机列名 | 黄铜制图尺、滑块、减／加独立对象 |
| `MAP.WORLD.CLOSE` | WorldMap 关闭 Button 待 feature-detect | 皮革扣／黄铜搭扣四状态 |
| `MAP.WORLD.REVEAL` | `mapreveal.lua` | 行为 `N/A` 美术；不改变地图外壳 |
| `MAP.WORLD.COLORS` | `mapcolors.lua` | 行为 `N/A` 美术 |

世界地图完整内容区必须保留原生图层；所有按钮、图例、导航和标题在真实对象
确认后逐项拆分。

## 小地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.MINI.MASK` | `Minimap`、`SetMaskTexture` | 圆形内容遮罩；有效直径不低于总直径 70% |
| `MAP.MINI.COMPASS` | `MinimapBorder` 周围 adapter Texture | 内／外黄铜环与皮革外托；无按钮烘焙 |
| `MAP.MINI.NORTH` | 原生 north／rotation 语义待实机 | 独立北针；静态或旋转方式由客户端确认 |
| `MAP.MINI.DIRECTIONS` | 方向件 | 四向独立或 atlas；不接收插件按钮 |
| `MAP.MINI.ZOOM.IN` | `MinimapZoomIn` | 普通／悬停／按下／禁用的独立 Button |
| `MAP.MINI.ZOOM.OUT` | `MinimapZoomOut` | 普通／悬停／按下／禁用的独立 Button |
| `MAP.MINI.TRACKING` | `tracking.lua` 的真实入口 | 四状态及激活；保留追踪菜单 |
| `MAP.MINI.ZONE` | `MinimapZoneTextButton`／pfUI zone frame | 标题 layout；点击行为保留 |
| `MAP.MINI.TIME` | `GameTimeFrame` | 动态时间；窄铭牌不得烘焙数字 |
| `MAP.MINI.COORDS` | pfUI `pfMinimapCoord` | 动态坐标；可选 |
| `MAP.MINI.MAIL` | `MiniMapMailFrame` | 独立通知覆盖 |
| `MAP.MINI.BATTLEFIELD` | `MiniMapBattlefieldFrame` | 独立状态 Button，不并入罗盘环 |
| `MAP.MINI.ADDONS` | `addonbuttons.lua` | 动态插件 Button adapter，详见下节 |

## 插件按钮兼容

| 子组件 | pfUI 对象／职责 | 状态 |
|---|---|---|
| `MAP.MINI.ADDONS.ANCHORS` | 由 adapter 计算、不可见 | 无位图；避让北针、缩放、追踪和屏幕边缘 |
| `MAP.MINI.ADDONS.SOCKET` | 扫描到的真实插件 Button 外壳 | 普通／悬停／按下／激活／禁用 |
| `MAP.MINI.ADDONS.NOTICE` | 插件自己的通知语义 | 无／未读／警告独立覆盖 |
| `MAP.MINI.ADDONS.OVERFLOW` | `pfMinimapButton` 或替代真实 Button | 普通／悬停／按下／展开 |
| `MAP.MINI.ADDONS.STRAP` | `pfMinimapButtons` 容器 | 收起／展开；上／中／下三段式 |

保留插件原始左键、右键、拖动、Tooltip 与保存行为。默认罗盘底图不画空槽；
建议同时显示 4–6 个常用入口，多余入口进入可收起工具袋。
