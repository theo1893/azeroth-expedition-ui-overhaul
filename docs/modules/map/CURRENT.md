# Map 当前接入

阶段：`P5`。Minimap V2 已完成像素验收、正式媒体导出、addon 接入与轻量包装
检查；当前被地图信息栏遮挡及插件工具带融合问题阻塞，尚未达到 `P6`。

## 已冻结批次

- 批次：`MAP-MINI-OVERHAUL-V2`。
- 用户验收：接受 exact pixels，并授权提升 source/runtime、导出媒体和接入 addon；
  小地图必须为圆形，动态地图不得越过罗盘内圈。
- ImageGen 实际调用：Frame `3/5`、Hardware `2/5`、Tray `1/5`，均通过即停；
  流程错误不计额度。
- Source manifest：
  `assets/source/map/mini-v2/MAP-MINI-OVERHAUL-V2_SourceManifest_v1.json`。
- Runtime manifest：
  `assets/source/map/mini-v2/MAP-MINI-OVERHAUL-V2_RuntimeManifest_v1.json`。
- 重建工具：`tools/build_map_mini_v2_runtime.py`。

稳定美术 Prompt 已收敛到 `ART_BASELINE.md` 与 `SUBMODULE_ART_BASELINES.md`；
本文件不再重复提示词或尝试记录。

## 当前运行时合同

- `Map.runtimeContract = 2.4`；WorldMap 继续 `paused`，Minimap 单独启用。
- 原生 `Minimap` 保持动态图层所有权，并使用独立 256×256 圆形 Alpha mask；
  mask 半径外 Alpha 为 0，184×184 罗盘的中央保护区也强制 Alpha 为 0。
- 地图块、玩家箭头、pfQuest pin、区域名和坐标均未烘焙进外壳；区域名与坐标
  位于圆形地图内部。
- `pfMinimapButton` 使用独立 body／四向 glyph；`pfMinimapButtons` 使用九切片
  工具带；真实插件 Button 不叠加 AEUI 外框，保留 provider 图标、点击、Tooltip、
  冷却与通知。
- `pfMinimap` 的 parent／point／scale 与保存位置继续由 pfUI 所有；adapter 不再
  重写 provider 锚点。插件入口保留 pfUI 的真实 scale，并按每个入口相对工具带
  的有效 scale 补偿排版坐标；工具带支持
  bottom／left／top／right、动态 rowsize、0／4／6／10／30 及更多入口、战斗隐藏
  与 `ToggleMinimap` 同步显隐。
- FarmMode 不拉伸常驻罗盘；保留独立 300×300 `pfFarmMap`，隐藏罗盘／工具带，
  返回入口改为工具带同材质短签。
- `conda run -n py312 python tools/check.py assets --module map`：通过。

## 当前实机阻塞

当前 30 入口、bottom 展开场景需要保留以下三个未解决结论：

1. 显示当前地图名和坐标的栏被相邻结构遮挡，动态信息无法完整读取。
2. 收纳开关对位歪斜，与罗盘下缘没有形成自然、居中的连接。
3. 展开的插件工具带与开关、罗盘在连接方式和整体轮廓上彼此割裂。

下一轮先确认地图名／坐标真实对象的锚点、frame level 与安全区，再校正 toggle
锚点，最后判断 tray 仅需布局调整还是需要重做连接像素。未经确认不重新生成资产。

## P6 实机门禁

1. 确认地图、玩家箭头和 pfQuest pin 始终被圆形 mask 裁剪，不越过罗盘内圈。
2. 拖动 `pfMinimap` 后 `/reload`，确认位置不回到屏幕中央；再验证常用 Minimap
   尺寸、UI Scale、长区域名及四角坐标配置。
3. 确认地图名／坐标栏无遮挡，toggle 与罗盘居中连接，展开 tray 与整体轮廓融合；
   再检查 0／4／6／10／30 的比例、四向展开、战斗隐藏和原始点击行为。
4. 验证 tracking、邮件、战场、PVP 不互相遮挡；全局收起后没有独立漂浮对象。
5. 验证 `/farm` 的 300×300 地图、对象迁移、返回短签与退出后的完整恢复。
