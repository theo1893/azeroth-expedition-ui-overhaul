# Chat 子模块美术基线 Prompt

所有条款继承 [ART_BASELINE.md](ART_BASELINE.md) 与
[全局美术基线](../../GLOBAL_ART_BASELINE.md)。本文件只保留稳定视觉规则；
当前 runtime 与实机门禁见 [PROGRESS.md](PROGRESS.md)。

## `CHAT.FRAME`

聊天框是一册在长期远征中反复翻阅的厚重战地旧书：深胡桃旧皮革、低亮暗铜、
粗缝线、磨圆页角、厚页叠和明确书脊共同形成重量。材料边界需要自然错位、
磨损不均且略显手工，不能像工业产品、现代面板或暗黑式金属祭坛。

活动 Full V1 使用暖黑烟熏 rag-paper 阅读面：近黑但仍能看见纸浆纤维、局部
熏痕和页层，不是透明黑玻璃或纯色矩形。纸、皮革、黄铜、缝线、页叠和接触
阴影必须属于同一光照与同一物件，不能像后贴的独立图层。

accepted source 为
[`ChatBookFrame_Full_V1_r1.png`](../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png)；
runtime 为 `ChatBookFrameFullV1.tga` 九宫格。只显示左框；不烘焙 Tab、输入、
文字、频道、滚动状态、按钮或固定图标。旧 V3 主框暂作实机回退。

## `CHAT.TABS`

Tab 是从旧书页上沿探出的深色旧皮签，不是整齐的现代页签。沿用旧 V3 的斜梯形、
外撇端部与粗手切轮廓，使用深胡桃烟褐皮革、断续缝线和不均磨边；同组之间保持
家族一致，但不得完全等宽、镜像或机械对齐。

normal 保持最低亮度；hover 只增加短暖光和边缘响应；selected 像被压进书页夹层，
综合色更深且接触阴影更明确；disabled 退灰但仍可辨。四态不能改变命中区、文字
几何或总体轮廓。承托带是低亮、连续、粗旧的书页上沿材料，不形成现代工具栏。

accepted source 为
[`ChatTabs_Dark_V2_A.png`](../../../assets/source/chat/tabs-dark-v2/ChatTabs_Dark_V2_A.png)；
runtime 为 `ChatTabAtlasDarkV2.tga` 与 `ChatTabShelfDarkV2.tga`。文字始终由
FontString 动态居中，Tab 与 shelf 不得烘焙名称、未读或频道状态。旧 V3 媒体
暂作实机回退。

## `CHAT.INPUT`

输入框是夹在书页下沿的一条暖烟草抄写纸条：两层薄而旧的烟熏 rag-paper，
边缘轻微起伏、页层接触暗部和克制磨损。它必须属于战地旧书，而不是现代
进度条、发光输入框、完整金边、卷轴横幅或独立平板。

normal 使用低亮暖烟草；focus 只通过纸浆局部响应、短暖光和稍深接触阴影表达，
不能出现连续外发光。两态共享完全相同 Alpha 和三段横向伸缩几何；左／中／右
切片不得烘焙输入文字、光标、IME、频道头或历史。

accepted source 为
[`ChatInput_Dark_V1_r3.png`](../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_r3.png)；
runtime 为 `ChatInputDarkV1.tga`。旧 V3 输入媒体暂作实机回退。

## `CHAT.UNREAD`

未读提示是一枚小型暗酒红蜡封：低饱和、边缘略扩散、压印粗浅，像夹在旧书
上的实体标记。禁止荧光、脉冲、宝石、现代 badge 数字和金属勋章。它是独立
覆盖层，不改变 Tab 命中区，也不烘焙进 Tab atlas。

## `CHAT.TEXT`

正文直接排在暖黑纸面上，不增加逐行底色、矩形压光、边框或半透明背景。使用
pfUI 当前客户端字体和用户字号；`12px` 基线增加约 `3px` 行距，移除全方向
`OUTLINE`，shadow 透明且零偏移，禁止复制第二层字形。

AEUI 不接管消息颜色。目标客户端 `ChatTypeInfo`、pfUI、ChatMOD 与第三方
`|cAARRGGBB` 是唯一颜色权威；说话、频道、系统、公会、小队、团队、密语、
警告、表情、职业、物品品质、URL、等级和时间戳原样透传。纸面可读性只通过
材质、字号、行距和无描边字体解决，不安装颜色 wrapper 或全局色表写入。

霞鹜文楷仅适合短频道签，不用于长聊天正文。输入和 Tab 文字仍是运行时动态
FontString。

## 尚未锁定的真实控件

`CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*`、`CHAT.WHISPER.TOGGLE`、Chat Copy 与
URL Copy 当前暂停，没有 accepted source 或可执行 Prompt。pfUI 当前隐藏的
滚动按钮、菜单和 resize grip 不生产占位资产。未来恢复时必须先确认真实对象、
状态与命中区，再使用一份临时 `CURRENT.md`；不得从旧失败稿直接裁切。
