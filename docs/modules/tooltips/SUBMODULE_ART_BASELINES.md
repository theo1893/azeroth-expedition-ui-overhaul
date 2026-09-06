# Tooltips 子组件美术基线

- 主提示、比较、地图、链接与 AtlasLoot：ReadoutShellV1，逻辑采样
  `262×14`／容器 `512×16`，固定 `4 UI` 横向角，`1 UI` 上下沿和外扩，省略中心。
  阅读底使用低对比深棕，透明度遵循 pfUI tooltip alpha。
- 单位生命条：ReadoutShellV1 固定 `4 UI` 横向角和 `1 UI` 上下沿；
  UnitFrameHealthFillV1 灰阶填充保留动态生命颜色与原高度。

两种组件均直接引用原模块的 accepted runtime 和 manifest，不复制媒体。
