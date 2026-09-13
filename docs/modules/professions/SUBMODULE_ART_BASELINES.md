# 生产专业子组件美术基线

运行时目录：`addon/AzerothExpeditionUI/Media/Professions/`。
所有组件从已确认高清概念图的无文字区域提取；采样为 2 texels/UI，单边不超过 1024。
固定源区域与媒体校验值见 `WORKBENCH-V2_RuntimeManifest.json`。

| 组件 | 合同 |
|---|---|
| 木质外缘 | WoodTop／Bottom 为 128×16 UI 分段；WoodLeft／Right 为 16×128 UI 分段；末段只裁切 UV，不拉伸木纹 |
| 固定角料 | CornerTL／TR／BL／BR 为 16×16 UI；右上角从不含关闭按钮的右下角料垂直翻转，避免烘焙静态关闭按钮 |
| 标题 | 移除拼接牌，专业名称在木边下方独立居中，顶部偏移 24 UI；保留原生动态文本 |
| 内容底面 | WorkbenchLeatherV2 64×64 UI 平铺，低对比无花纹墙纸感 |
| 目录／详情边缘 | PanelRimV2；源 atlas 32×32，UV 0／4/32／28/32／1；独立 2 UI 边缘 |
| 按钮／输入 | ButtonRimV2、InputRimV2，独立 2 UI 边缘；保持真实点击区域与动态文字 |
| 滚动与箭头 | ThumbV2 固定 8×14 UI；上下箭头 10×10 UI，左右箭头 10×14 UI；有填充时使用对应有效 UV |
| 关闭 | CloseV2 10×10 UI 字形，真实 Button 持有点击 |
| 技能与选中 | 保留实时进度纹理并改为绿色；选中条使用低对比暖棕提示，不变更原生难度文字色 |

制造、取消、鼠标提示、筛选、数量和跨配方继续仍由现有代码持有。
