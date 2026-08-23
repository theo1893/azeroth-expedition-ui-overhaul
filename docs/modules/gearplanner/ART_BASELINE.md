# Gear Planner 美术基线

当前阶段只锁定功能与布局，不生产独立位图，也不形成 ImageGen 生产 Prompt。

- 默认作为 CharacterFrame 右侧可收起伴随视图，但不改变 CharacterFrame 自身
  几何，也不增加 Character Tab；宿主不受支持时使用独立窗口回退。
- InspectFrame 只挂独立窄栏与第三方只读 Provider，不展开完整配装外壳；“存”仅作
  动态桥接动作，不把目标装备或属性烘焙进观察页。
- 动态物品图标、名称、品质、数值、来源和掉率始终由运行时绘制。
- 首版使用 pfUI／Blizzard 原生 Tooltip 边框、Button 与字体，保证功能实机
  验证可以独立于美术生产进行。
- 后续开始美术前，需依据全局美术基线重新锁定 Gear 伴随外壳、槽位、
  方案控件、属性纸及小型选入 Button 合同；AtlasLoot 搜索框、分页和来源行
  保持原生边界，不进入 Gear 资产生产。不得把任何动态装备内容烘焙进背景。
