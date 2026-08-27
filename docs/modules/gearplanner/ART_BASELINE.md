# Gear Planner 美术基线

Gear Planner 的稳定物件身份是“远征军需官的折叠配装案板”。它与 Character V3
共享香草年代、深胡桃旧皮革、暗哑氧化黄铜、暖赭烟熏纸、左上暖光和磨损尺度，
但不得复制 CharacterFrame 的纸娃娃轮廓，也不得退化为现代横向 Dashboard、第二本书
或半透明黑卡。

- 主视图保持 `560×555 UI` 角色伴随模式与 `760×555 UI` 独立回退；两种模式都让
  19 个装备槽和“当前／配装／变化”属性纸同时可见。外壳只在安全填充区平铺／拉伸，
  不直接缩放完整 donor。
- 外壳使用深胡桃旧皮革、八切片磨损框边和左侧三处实用折叠铰链。顶部为安静的长标题牌，
  保存是突出的氧化黄铜锁扣；导入、清空和方案管理是较安静的皮革工具签。
- 装备槽是窄型缝线皮革标签，保留独立方形 icon 插槽和低对比文字安全区。右侧为一张由
  黄铜钉固定的军需官统计纸，使用墨褐色高密度文字，而不是独立现代卡片。
- 动态方案名、页数、Button 文本、物品 icon／品质／名称、属性名／数值／差值和来源状态
  始终由运行时绘制。槽位差异只用固定黄铜夹签材质，未保存修订只用固定冷灰蓝缝带材质；
  状态切换、`差异／新增／未填` 与 `*` 仍完全动态，不得烘焙。
- AtlasLoot 查询／来源窗口、方案管理窗与 Inspect 伴随窄栏不属于 `GEAR-MAIN-V1`，
  继续保持 Provider／当前原生视觉。Character 伴随窄栏仍是独立运行时对象，但四个
  动态 Button 复用已验收控件 atlas 的空白深皮革工具签，并用运行时明暗表达
  hover／pressed／selected；文字与可用性不得烘焙。
- 禁止现代扁平按钮、玻璃、统一大圆角、精密工业网格、科技 HUD、持续霓虹、镜面黄金、
  巨型宝石、翼、龙头、骷髅、恶魔尖刺和黑红 Diablo 风格。装饰只放在外边、铰链、铆钉、
  锁扣和真实连接处。

accepted 美术权威为
`assets/source/gearplanner/main-v1/GearPlannerMainDonor_SourceV1.png` 与
`assets/source/gearplanner/slot-states-v1/GearPlannerSlotStatesDonor_SourceV1.png`；
运行时必须从对应高分辨率 source 确定性采样为 `2 texels / UI unit`，并按真实外壳、
填充、装饰、Button、槽位、状态 sprite 和属性纸对象拆分。单张 TGA 不得超过 `1024`。
