# 乾坤袋对象边界

Provider：客户端 Bagshui 1.5.15／Interface 11200。BagshuiData、分类、排序、
自动整理、容器映射、离线角色缓存和物品交互全部由 Bagshui 持有。

| 组件 | 真实对象 | 展示合同 |
|---|---|---|
| BAG.FRAME | components.Bags／Bank／Keyring.uiFrame | 自适应窗口，固定角／边切片，连续布料底 |
| BAG.GROUP | inventory.ui.frames.groups；bagshuiData.labelFrame／text | 动态分组，轻缝线与独立纸签；编辑模式保留拖放目标 |
| BAG.SLOT | inventory.ui.buttons.itemSlots／bagSlots；buttonComponents | 原生 ItemButtonTemplate 的图标、数量、冷却、品质、库存与任务标记保持动态 |
| BAG.TOOLBAR | inventory.ui.buttons.toolbar | 原按钮顺序与交互不变，增加皮革控制件底材 |
| BAG.SEARCH | inventory.ui.frames.searchBox | 动态展开／收起，原搜索与目录查询不变 |
| BAG.FOOTER | bagSlots、金币、状态和停靠区域 | provider 继续排布，独立下缘材质承托 |

Inventory:UpdateWindow、UpdateBagBar、UpdateToolbar 与 InventoryUi:SetGroupColors
负责动态展示；不得通过 OnUpdate 持续重写几何。实例会复用分组和物品 Button，
因此必须按对象创建／更新接入，不能只在首次打开时覆盖背景。

当前截图仅提供屏幕像素参考，不当作 UI 逻辑尺寸。provider 的 itemSize 默认为
35，可在 20–60 间调整；保持真实尺寸、命中区和现有 RIGHT 对齐。左对齐设置
在 provider 中隐藏且注明未完善，不启用。皮肤全角色统一，物品／规则数据不合并。
