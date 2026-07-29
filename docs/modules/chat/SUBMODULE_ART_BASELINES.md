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

已接受源：
[ChatBookFrame_Master_v3.png](../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)。
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

生成普通与聚焦两个无字输入纸带状态，几何完全相同，均由左右端帽和可横向
延展的安静中段组成。普通状态为轻压痕与浅墨线；聚焦状态只增加局部纸面提亮、
墨线加深和极少暖金反光。不得出现黑色输入框、搜索图标、现代边框或发光。

已接受源：
[ChatControls_Master_v3.png](../../../assets/source/chat/v3/ChatControls_Master_v3.png)。

## `CHAT.UNREAD`

生成一枚独立、小型、真透明的暗酒红蜡封或布结覆盖层。轮廓在 16px 左右仍
清楚，反馈依靠厚度、裂纹和短高光，不包含数字、感叹号、红点气泡或常亮光。
它只能覆盖真实 `ChatFrameNTabFlash` 语义，不能改变 Tab 排列。

已接受源同 `CHAT.INPUT`。

## `CHAT.TEXT`

不生成位图。正文使用客户端高可读字体、紧凑行距和经典频道色；文字直接落在
纸面。霞鹜文楷只用于短频道签，不用于长聊天正文。

## 尚未锁定的真实控件

`CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*` 与 `CHAT.WHISPER.TOGGLE` 已登记真实
对象，但没有经过用户视觉验收，因此没有可执行美术 Prompt。
`CHAT.URLCOPY.*` 的当前合同与 shell production draft 位于
[`CHAT.URLCOPY.V1.md`](work/CHAT.URLCOPY.V1.md)，尚未授权生成；
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
