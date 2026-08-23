# Map 详细进度

## 当前结论

- WorldMap A1 继续暂停；本批只提高已完成且正在挂载的 Minimap runtime 采样密度。
- 常驻罗盘、信息托架和状态插槽继续使用已验收 V3 媒体；独立圆形 mask 已重建为
  `512×512` 功能纹理。真实
  `140×140` 地图、玩家箭头、pfQuest 图钉、区域名、坐标和通知保持动态。
- bottom 已接入 `MAP-MINI-V7-A1` 一体式轻型收纳袋，runtime contract `7.6`、
  阶段 `P5`。同一张 `256×1024` 32-bit TGA 同时提供收起徽记和四档展开裁片；
  不再拼接 V5 扣座、活动皮舌、connector 或 bottom 九切片工具卷。
- V7 bottom 收纳袋原先已是 2×；本批将 left／top／right 的 V4 九切片托盘从
  accepted source 直接导出为 2×，所有逻辑切点、Button 排列与命中区保持不变。
- V3 罗盘／扣具／字形／插槽的 durable accepted source 只保留了与运行时同尺寸的
  1× exact pixels，原始高分辨率 provider 输出已经按验收清理流程删除。本批不对
  1× 像素做放大伪装；这一限制已在 V3 source/runtime manifest 登记为明确例外，
  后续若要消除例外必须另开资产生产与实机验收。
- exact pixels 继续来自 attempt 3；V7.3 只做确定性几何重排：移除 `48 UI` 中段
  绳索、母图锚点相对旧版左移 `17 UI`／下移 `24 UI`。徽记可见左缘在罗盘高度
  `y=182` 处与外壳右缘压接 `1 UI`，袋口同时左移 `17 UI`／上移 `24 UI`；真实
  插件 Button 在袋内相对基准左移 `4 UI`、下移 `6 UI`。徽记、绳索和袋身均未
  重画，正式 source 为
  `assets/source/map/mini-v7-addon-sling/MapMiniAddonSlingMaster_SourceV7.png`。
- 真实 `pfMinimapButton` 仍是唯一开关，命中区固定为徽记中央 `28×28 UI`；绳索
  和袋面 click-through。真实插件入口保持各自图标、状态、点击、Tooltip、冷却和
  通知，按 `21×21 UI`、3 UI 间距、每列 8 个从右向左排布。
- 0 个入口隐藏整个收纳附件；收起只显示同母图顶部徽记；展开按
  `1–8／9–16／17–24／25–30` 使用右锚 UV 裁切。left／top／right 继续使用
  V4／V3 回退，FarmMode、Map 禁用和 provider 缺失继续恢复 pfUI。
- `pfMinimap` 保存锚点与缩放仍由 pfUI 所有；adapter 不循环改写 provider，也不
  改变扫描、缓存、手动 add／del／reset、战斗隐藏或父级恢复逻辑。

## 子模块状态

| ID | 阶段 | 当前状态 | 下一门禁 |
|---|---:|---|---|
| `MAP.WORLD.*` | `P4 / paused` | accepted A1 媒体保留，adapter 不启用 | 未来单独重开大地图结构修复 |
| `MAP.MINI.PROVIDER／MASK` | `P5` | 140×140 provider 与 `512×512` 功能 mask 已接入 | 实机验证缩放下无额外泄漏或裁切 |
| `MAP.MINI.COMPASS／INFO.CRADLE` | `P5 / explicit 1× source exception` | V3 常驻外壳与动态文字托架保持运行；没有可直接导出的高分辨率 accepted source | 实机验证右上轮廓、两行文字及 `/aeui map` 回退 |
| `MAP.MINI.TRACKING／MAIL／BATTLEFIELD／PVP` | `P5 / explicit 1× art exception` | provider 图标和行为保持动态，使用 V3 状态插槽 | 实机验证并发显隐、邮件闪烁和点击区 |
| `MAP.MINI.ADDONS.BOTTOM` | `P5` | 2× V7 同母图短绳 closed/open UV 裁切已接入；徽记按透明边界左移至贴边，真实插件 Button 已在袋内左下微调且仍由 provider 持有 | 实机验证徽记压接、袋内四列／八行净空、0／收起／6／12／22／30、命中区、缩放、战斗隐藏和图标层序 |
| `MAP.MINI.ADDONS.NON_BOTTOM` | `P5 / fallback` | left／top／right 使用 2× V4 九切片；缺失时回退 V3 | 实机确认配置切换不残留 V7 纹理且 V4 切片无缝 |
| `MAP.MINI.VISIBILITY／FARMMODE` | `P5` | 全局显隐同步；FarmMode 使用独立 pfUI provider | 实机验证迁移、退出恢复和模块禁用回退 |

## 下一步

完整重启客户端后验证 contract 7.6：确认 V7 bottom 徽记与罗盘右下外缘自然压接，
并检查 left／top／right V4 2× 九切片无断边、拉伸或 UI 尺寸变化。袋内图标整体左下
微调后四周净空均衡；短绳和袋口继续不挡区域名／坐标；收起与展开时徽记不得跳位；
6、12、22、30 个真实图标应从右列向左增长并始终位于袋面
上方；只有徽记 `28×28 UI` 可点击。相邻回归检查 pfQuest 图钉、战斗隐藏、
FarmMode、非 bottom 配置和 `/aeui map` 回退。WorldMap 继续暂停。
