# Map 子模块定义

本文件只定义地图模块与 pfUI／原生对象的对齐。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 来源

| 文件 | 已证实职责 | 项目处理 |
|---|---|---|
| [`modules/map.lua`](../../../addon/pfUI/modules/map.lua) | WorldMap 布局、缩放／拖动及地图相关呈现 | 当前由 pfUI 正常加载；以后只在 Map 接管范围内替换外壳与控件 |
| [`modules/mapcolors.lua`](../../../addon/pfUI/modules/mapcolors.lua) | 地图颜色行为 | 保留数据／配置，不把颜色烘焙进外框 |
| [`modules/mapreveal.lua`](../../../addon/pfUI/modules/mapreveal.lua) | 未探索区域显示增强 | 保留功能，独立于外壳美术 |
| [`modules/minimap.lua`](../../../addon/pfUI/modules/minimap.lua) | `Minimap`、mask、缩放、区域、坐标、邮件与战场入口 | 当前由 pfUI 正常加载；未来 adapter 保留真实内容与行为 |
| [`modules/tracking.lua`](../../../addon/pfUI/modules/tracking.lua) | 追踪入口与状态 | 保留功能，按真实 Button 换肤 |
| [`modules/addonbuttons.lua`](../../../addon/pfUI/modules/addonbuttons.lua) | 扫描、移动、保存小地图插件按钮；`pfMinimapButtons`／`pfMinimapButton` | 可复用行为，重做动态锚点与溢出呈现 |
| [`modules/farmmode.lua`](../../../addon/pfUI/modules/farmmode.lua) | 小地图扩展使用模式 | 作为兼容状态，不能固化进罗盘母版 |
| [`skins/blizzard/battlefield_minimap.lua`](../../../addon/pfUI/skins/blizzard/battlefield_minimap.lua) | 战场小地图 skin | 独立系统面板，不与常驻罗盘背景合并 |

## 世界地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.WORLD.FRAME` | `WorldMapFrame`、pfUI `map.lua` | 围绕真实内容区的非交互羊皮卷外壳；卷杆、端帽、卷边按独立切片／九切片重排，不能拉伸整张图 |
| `MAP.WORLD.CONTENT` | `WorldMapButton` | 尺寸由运行时 `GetWidth／GetHeight` 读取；原始地图、`pfMapPin*`、`pfQuestRouteDrawLayer` 与 `pfQuestRouteDisplay` 保持动态并位于外壳之上 |
| `MAP.WORLD.TITLE` | `WorldMapFrameTitle` | Turtle 兼容层当前隐藏；首批不生产，不得在外壳中烘焙标题 |
| `MAP.WORLD.LEVELS` | `WorldMapContinentDropDown`、`WorldMapZoneDropDown`、可选 `WorldMapZoneMinimapDropDown` | 每个真实 Dropdown 独立换肤；可选对象必须 feature-detect，不生成固定网页 Tab |
| `MAP.WORLD.PFQUEST.FILTER` | `pfQuestMapDropdown` | 独立过滤 Dropdown，保持 provider 行为与层级，不并入静态图例 |
| `MAP.WORLD.BACK` | `WorldMapZoomOutButton` | 这是现有层级返回／缩小语义的唯一已证实 Button；四状态独立，禁止制作不存在的加号、滑块或缩放尺 |
| `MAP.WORLD.CLOSE` | `WorldMapFrameCloseButton` | 皮革扣／黄铜搭扣四状态；独立于外壳 |
| `MAP.WORLD.REVEAL` | `pfUI_mapreveal_onmap` | 真实 14×14 Checkbox 与动态文字；独立换肤，不改变地图外壳 |
| `MAP.WORLD.COORDS` | `pfWorldMapButtonCoords` | 动态坐标 FontString，layout-only，不烘焙数值 |
| `MAP.WORLD.COLORS` | `mapcolors.lua` | 行为 `N/A` 美术 |

`Ctrl+滚轮` 对 `WorldMapFrame` 的缩放与 `Shift+滚轮` 透明度继续作为 pfUI 手势，
不制造对应的静态假控件。世界地图完整内容区与 pfQuest 动态图层必须保留。

## 小地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.MINI.MASK` | `Minimap`、`SetMaskTexture` | 圆形内容遮罩；有效直径不低于总直径 70% |
| `MAP.MINI.COMPASS` | `MinimapBorder` 周围 adapter Texture | 内／外黄铜环与皮革外托；无按钮烘焙 |
| `MAP.MINI.NORTH` | 非交互装饰 Texture | 首批作为可独立定位的北针，不假定旋转行为 |
| `MAP.MINI.DIRECTIONS` | 非交互方向 Texture／atlas | 四向独立或 atlas；不接收插件按钮 |
| `MAP.MINI.ZOOM.IN` | `MinimapZoomIn` | 普通／悬停／按下／禁用的独立 Button |
| `MAP.MINI.ZOOM.OUT` | `MinimapZoomOut` | 普通／悬停／按下／禁用的独立 Button |
| `MAP.MINI.TRACKING` | `tracking.lua` 的真实入口 | 四状态及激活；保留追踪菜单 |
| `MAP.MINI.ZONE` | pfUI `pfMinimapZone`；原生 `MinimapZoneTextButton` 当前隐藏 | 动态区域名 layout；首批只生产空铭牌，不烘焙文字 |
| `MAP.MINI.TIME` | `GameTimeFrame` 当前隐藏 | 首批不生产；若以后恢复，动态时间不得烘焙数字 |
| `MAP.MINI.COORDS` | pfUI `pfMinimapCoord` | 动态坐标；可选 |
| `MAP.MINI.MAIL` | `MiniMapMailFrame` | 独立通知覆盖 |
| `MAP.MINI.BATTLEFIELD` | `MiniMapBattlefieldFrame` | 独立状态 Button，不并入罗盘环 |
| `MAP.MINI.PVP` | `pfUI.minimap.pvpicon` | 独立 16×16 状态覆盖，不并入罗盘环 |
| `MAP.MINI.PFQUEST.PINS` | `pfMiniMapPin*`／pfQuest drawlayer | 保持在 `Minimap` 动态内容层；farmmode 时随 provider 迁移 |
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
`pfQuestIcon` 作为真实插件入口由同一容器承载。默认 `rowsize=6`，4／6／10 个
入口按实际数量形成一行或 `6+4` 两行工具带，不生成空槽。`pfFarmMap 300×300`
是独立兼容态，只迁移 tracking／PVP／pfQuest 动态对象，不复制常驻罗盘外壳。
