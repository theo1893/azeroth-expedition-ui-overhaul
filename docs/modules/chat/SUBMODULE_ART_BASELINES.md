# Chat 子模块美术基线 Prompt

以下条款全部继承 [Chat 主模块 Prompt](ART_BASELINE.md) 与
[全局 Prompt](../../GLOBAL_ART_BASELINE.md)。它们是稳定基线，不是一次
ImageGen 调用记录。

## `CHAT.FRAME`

生成一张无文字、无控件、真透明背景的战地旧书主框源资产。轮廓必须略微弯曲
且不对称：深胡桃厚封皮、两至四层错落毛边纸页、下沿清楚的页叠截面、局部
装订阴影和少量不同形状的暗哑黄铜修补。中央阅读区连续、平整、低对比，
只保留低频烟熏斑驳和极轻纤维。四角、边、填充区必须可确定性拆成九宫格；
不可拉伸细节只放在角和边。不得包含 Tab、输入、未读、滚动按钮、文字或
legacy 信息底栏。

当前已接受源：
[ChatBookFrame_Dark_Master_v1.png](../../../assets/source/chat/dark-v1/ChatBookFrame_Dark_Master_v1.png)。
V3 亮纸源保留为本地回退，不再由当前 runtime 挂载。
`CHAT.FRAME.LEFT` 是唯一运行时实例。`CHAT.FRAME.RIGHT` 已按产品决策隐藏，
不得为它复制、镜像或重新生成第二本书。

## `CHAT.TABS`

生成一条连续书页承托带，以及普通、悬停、选中、禁用四枚无字皮革索引签。
四状态外接尺寸与点击几何相同，均可拆为左端帽、可横向延展中段和右端帽。
普通状态后退且偏暗；悬停仅在边缘出现短暖光；选中状态向前抬起并自然压住
承托带；禁用状态降低对比但保持轮廓。选中签文字由 runtime 使用亮暖金，
并以每枚真实 Tab 的视觉中心为锚点，不得因 pfUI 默认底边锚点向上偏移，也
不得因状态切换变成贴近皮革底色的黑褐字。不得做成网页 Tab、矩形卡片、
胶囊按钮或独立金属牌。

已接受源：
[ChatTabs_Master_v3.png](../../../assets/source/chat/v3/ChatTabs_Master_v3.png)。

## `CHAT.INPUT`

生成普通与聚焦两个无字深胡桃输入带状态，几何完全相同，均由左右端帽和可
横向延展的安静中段组成。普通状态保持暗哑皮革／纸带与细金属压边；聚焦状态
只增加局部暖色提亮。不得出现搜索图标、现代边框或发光。

已接受源：
[ChatInputStrip_Dark_Master_v1.png](../../../assets/source/chat/dark-v1/ChatInputStrip_Dark_Master_v1.png)。
该 source 提供普通态；聚焦态只由 exporter 对相同像素执行固定
`R/G/B=110%/108%/105%` 暖色提升，Alpha 与几何不变。

## `CHAT.UNREAD`

生成一枚独立、小型、真透明的暗酒红蜡封或布结覆盖层。轮廓在 16px 左右仍
清楚，反馈依靠厚度、裂纹和短高光，不包含数字、感叹号、红点气泡或常亮光。
它只能覆盖真实 `ChatFrameNTabFlash` 语义，不能改变 Tab 排列。

已接受源仍为 V3
[ChatControls_Master_v3.png](../../../assets/source/chat/v3/ChatControls_Master_v3.png)；
Dark V1 不修改未读资产。

## `CHAT.TEXT`

不生成新增位图。正文恢复并沿用 pfUI 当前配置的客户端字体，保留用户字号，
在 12px 基线下使用 `3px` 额外行距；移除全方向 `OUTLINE` 并把文字阴影设为
透明、零偏移，不允许复制出第二层字形。正文安全区不得增加连续压光、半透明
色块、边框或逐行底色，必须直接保留书页纹理。受管聊天框的最终显示入口使用
统一暗纸语义色板必须优先继承 Vanilla 原色相：说话暖纸白、公共频道浅粉、
系统黄、公会绿、小队蓝紫、团队焦橙、密语洋红、警告红、表情橙；小队与团队
不得合并。香草九职业使用各自原始 RGB，战士保持棕褐／青铜而非铁锈红，
牧师保持白色，其他七职业同样不得换到陌生色域；萨满蓝只为通过暗纸对比
轻微提亮。在代表书页色 `#18120D` 上以 `4.8:1` 作为基础频道／职业静态
对比下限，不使用发光、描边或阴影补偿。

经审计的 ChatMOD 1.1、pfUI 与原生精确颜色码使用确定性目标值；未知第三方
`|cAARRGGBB` 若低于 `4.8:1`，只向白色提升到刚好通过并尽量保留色相，Alpha
保持；已经足够清楚的未知色必须原样保留。消息内容和 `|H...|h` 链接载荷始终原样
转发，不得写全局 `ChatTypeInfo` 或外部插件配置。霞鹜文楷只用于短频道签，
不用于长聊天正文。

## 尚未锁定的真实控件

`CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*` 与 `CHAT.WHISPER.TOGGLE` 已登记真实
对象，但没有经过用户视觉验收，因此没有可执行美术 Prompt。
`CHAT.URLCOPY.*` 的当前合同与 shell production draft 位于
[`CHAT.URLCOPY.V1.md`](work/CHAT.URLCOPY.V1.md)，并已由用户暂缓；
`CHAT.COPY.*` 的失败证据保留在
[`CHAT.COPY.V1.md`](work/CHAT.COPY.V1.md)，并已由用户暂缓。两者都没有用户
接受的 source，不能在此凝结为稳定条款或恢复新 runtime。其余对象暂时保持
原生／不加载；取得实机几何并锁定方向后，才能在本文件增加稳定条款。
`CHAT.WHISPER.DIALOG` 归未来 System 公共弹窗，不在 Chat 中独立生成。

`CHAT.SCROLL.UP`、`CHAT.SCROLL.DOWN`、`CHAT.SCROLL.BOTTOM`、
`CHAT.MENU.BUTTON` 与 `CHAT.RESIZE` 当前由 pfUI 明确隐藏，不生产占位资产。
若未来恢复，必须按各自真实 Button／拖拽对象单独设计，不能画进
`CHAT.FRAME`。

## 接受资产 provenance

- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`。
- 接受日期：`2026-07-29`。
- V3 主框源尺寸：`1608 × 978` RGBA。
- V3 Tab 源尺寸：`1774 × 887` RGBA。
- V3 控件源尺寸：`1536 × 1024` RGBA。
- V3 source 接受时的 `440 × 320` 合成验证使用 `380 × 236` 正文安全区；
  runtime contract v1.2 压缩 Tab 后把正文扩展为 `380 × 248`，不改变 source。
- 当前只允许一个左侧运行时聊天书；右侧框无资产。
- 已停用的底栏字段即使仍存在于控件母版，也不得由 exporter 裁切或 runtime
  挂载。
- 历史完整执行正文与失败尝试保留在 Git 历史；当前树以本文件、确认源资产
  和模块进度为准。
- Dark V1 接受日期：`2026-08-03`；主框由固定执行器 attempt 2 的完整书体
  候选整体晋级，只清除 `alpha <= 1` 的不可见色键残留；输入 strip 从同步的
  固定候选无重绘转为 RGBA source。精确 SHA、session、provenance gap 与
  runtime 依赖见
  [ChatDarkV1_SourceManifest_v1.json](../../../assets/source/chat/dark-v1/ChatDarkV1_SourceManifest_v1.json)。
