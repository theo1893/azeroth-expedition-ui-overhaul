# Map 详细进度

## 当前结论

- 大地图“远征制图师世界地图卷”：整体视觉 `P2`。
- 小地图“黄铜航向罗盘”：整体视觉 `P2`。
- pfUI／原生文件级对齐：`P1`。
- 组件级 production Prompt、透明 source、runtime：均未开始。
- 当前运行时：地图与小地图使用香草／Turtle WoW 原生回退。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.FRAME` | `P2` | [锁定图](../../../assets/locked/map/大地图羊皮卷_视觉基准_v1.png) | 实机几何，拆卷杆／端帽／卷边 |
| `MAP.WORLD.CONTENT` | `P2` | 原生 WorldMap 内容必须保留 | 记录安全区与裁切 |
| `MAP.WORLD.TITLE／LEVELS／LEGEND／ZOOM／CLOSE` | `P1` | pfUI／原生入口待逐项确认 | 每个真实 Button 与状态 |
| `MAP.MINI.MASK／COMPASS` | `P2` | [锁定图](../../../assets/locked/map/小地图黄铜罗盘_视觉基准_v1.png) | 实测 Minimap 直径与 mask |
| `MAP.MINI.NORTH／DIRECTIONS／CONTROLS` | `P1–P2` | 视觉方向已知，对象几何未完成 | feature-detect 与状态合同 |
| `MAP.MINI.ADDONS` | `P2` concept／`P1` pfUI | `addonbuttons.lua` 可复用扫描与保存行为 | 0／1／4／6／10 按钮实机布局 |

## 已否决方向

- 大地图连续暗酒红厚皮背板、宽皮带和重型压夹。
- 小地图八槽永久插件环、密集徽章圈和额外加厚金属外圈。
- 把功能承载能力烘焙为默认空槽。

## 下一步

1. 在目标客户端记录 `WorldMapFrame`、`Minimap` 及所有真实控件的全局名、
   尺寸、锚点、层级、命中区和状态。
2. 依据 [SUBMODULES.md](SUBMODULES.md) 完成稳定组件合同。
3. 分别为大地图结构、小地图罗盘和插件入口建立 `work/` 生产文件。
4. 只有具体版本 Prompt 获得授权后才生成组件资产。
