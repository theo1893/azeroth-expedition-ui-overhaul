# Tooltips 对象边界

`tooltips.shells` 仅登记 GameTooltip、ItemRefTooltip、ShoppingTooltip1／2、
WorldMapTooltip、可选 AtlasLootTooltip，以及 GameTooltipStatusBar 的视觉。
pfUI 和原 provider 保留文字、物品查询、比较、颜色、定位、尺寸、关闭按钮与事件。
内部扫描 Tooltip、其他第三方提示框与聊天气泡不接管。

外壳直接复用已接受 ReadoutShellV1 的 1 UI 细缘；生命条使用 ReadoutShellV1 与
UnitFrameHealthFillV1。全部使用现有 2× runtime，无新位图。
