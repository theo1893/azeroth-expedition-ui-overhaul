# Chat 子模块定义

本文件只定义聊天模块的真实对象、状态、所有权与资产粒度。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 与原生边界

| 来源 | 真实对象／职责 | 项目处理 |
|---|---|---|
| [`modules/chat.lua`](../../../addon/pfUI/modules/chat.lua) | `pfUI.chat.left/right`、`panelTop`、`ChatFrameN`、`ChatFrameNTab`、`pfUI.chat.editbox`、`ChatFrameEditBox`；聊天事件、停靠、滚动、历史、输入 | 只保留左侧主聊天书；右侧容器隐藏，其拾取／经验／荣誉／技能消息组回收到 `ChatFrame1`；在 pfUI 完成解析和历史存储后、调用 provider `HookAddMessage` 前，直接调用 AEUI 的显示色板桥 |
| 外部 `ChatMOD 1.1` | `S_AddMessage` 在消息中注入时间戳、职业名、等级难度、URL、自身高亮等内嵌颜色，并依据加载顺序经 pfUI `HookAddMessage` 或直接调用 Frame 的 `ORG_AddMessage`；其功能、配置与 SavedVariables 仍由 ChatMOD 持有 | 不修改 ChatMOD 文件或配置；同时守卫 pfUI 最终输出、受管 Hook 与 ChatMOD `ORG_AddMessage`，不再依赖 `S_AddMessage` 函数身份；已读颜色保留 Vanilla 身份，未知低对比色只向白色最小提升，已经可读的值与链接载荷原样保留 |
| `ChatFrameNTabFlash` | Tab 未读闪烁语义 | 绑定独立未读覆盖，不改变 Tab 几何 |
| `ChatMenu`、`EmoteMenu`、`LanguageMenu`、`VoiceMacroMenu` | 原生聊天弹出菜单实例 | 当前仍为过渡外观；未来复用一套 `CHAT.POPUP.SHELL`，不得生成四套不同物件 |
| [`modules/chatcopy.lua`](../../../addon/pfUI/modules/chatcopy.lua) | `pfChatCopyButton`、`ChatFrameScrollN`、`pfChatCopyBoxN` | 功能源码保留，默认不加载；完成组件资产后恢复 |
| [`modules/whisperproxy.lua`](../../../addon/pfUI/modules/whisperproxy.lua) | `pfWhisperProxy` 代理开关；调用共享 `CreateQuestionDialog` | 功能源码保留，默认不加载；Chat 只拥有代理开关，对话框归未来 System 公共弹窗 |
| [`modules/bubbles.lua`](../../../addon/pfUI/modules/bubbles.lua) | 聊天气泡呈现 | 不属于战地旧书主框，当前原生回退 |
| [`modules/panel.lua`](../../../addon/pfUI/modules/panel.lua) | 公会、护甲、好友、帧率／延迟、时间、金币与小地图等 legacy widgets | provider 与配置页由 pfUI 正常加载；Chat 只隐藏贴附左右聊天框的 `pfUI.panel.left/right`，不改槽位／脚本／SavedVariables，`pfUI.panel.minimap` 保留 |
| [`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua) | AEUI 书框、Tab、输入、未读与最终显示 adapter | 只换纹理、UV、状态和受管显示颜色，不改聊天事件、历史、链接载荷或 provider 配置 |

## 稳定子模块

| ID | 绑定对象 | 逻辑资产与状态 | 几何／禁止项 |
|---|---|---|---|
| `CHAT.FRAME` | 左侧物理资产合同 | 空战地旧书九宫格；`CHAT.FRAME.FULL.V1.r1 attempt 2` 已导出为 `ChatBookFrameFullV1.tga`，runtime `1.19 / P5` | 不含 Tab、文字、输入、滚动或固定槽；`1608 × 978` source 不得整图直接加载或拉伸 |
| `CHAT.FRAME.LEFT` | `pfUI.chat.left`／`pfChatLeft` | `CHAT.FRAME` 的唯一运行时实例；九个 texture slice 使用新 Full V1 atlas，旧 V3 主框只作 P6-C 前回退 | 保留移动、尺寸和左侧停靠行为 |
| `CHAT.FRAME.RIGHT` | `pfUI.chat.right`／`pfChatRight` | 明确停用的兼容对象；`C.chat.right.enable=0` | 强制隐藏，不分配 AEUI 资产；源码保留以便关闭 overhaul 后对照 |
| `CHAT.TABS` | `pfUI.chat.left.panelTop`、左侧 `ChatFrameNTab`／`ChatFrameNTabText` | 连续承托带；普通／悬停／选中／禁用 Tab，各自三段式；运行时文字居中 | 普通布局事件后按需恢复共同几何；`pfChatLeft.OnMove` 中检测真实局部 Scale 边沿并立即强制重放一次，现有维护节拍只检测 EffectiveScale 边沿作为全局缩放兜底；登录后只做一次延迟终局装配；普通状态维护只换 UV |
| `CHAT.UNREAD` | `ChatFrameNTabFlash` | 蜡封或布结显示／隐藏 | 独立覆盖，不参与 Tab 排列 |
| `CHAT.INPUT` | `pfUI.chat.editbox`、`ChatFrameEditBox` | 普通／聚焦暖烟草抄写纸条，各自左／中／右 | 两状态几何完全相同；不烘焙输入文字；现行 V3 atlas 保持到新 source 被接受并导出 |
| `CHAT.INPUT.LANGUAGE` | 可选 `ChatFrameEditBoxLanguage` | 普通／悬停／按下／禁用／当前语言 | 独立 Button，不画进输入纸带 |
| `CHAT.TEXT` | `ChatFrameN` | 无新增位图；pfUI 配置字体、无描边／无阴影、安全区、内边距、`3px` 行距；暖黑纸面使用熟悉的 Vanilla 明亮语义色，小队蓝紫与团队焦橙独立；基础目标约 `>=4.5:1` | 接管当前 Parent 为左书的全部正文最终显示参数，包括被 pfUI 启发式标为 `pfCombatLog` 的窗口；不改全局 `ChatTypeInfo`、ChatMOD／pfUI 配置、历史存储或链接载荷；未知色仅在低于 `4.8:1` 时向白色最小提升，已达标则逐字节保留；不生成连续压光、行卡片、气泡或逐行底色 |
| `CHAT.SCROLL.UP` | `ChatFrameNUpButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.SCROLL.DOWN` | `ChatFrameNDownButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.SCROLL.BOTTOM` | `ChatFrameNBottomButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.MENU.BUTTON` | `ChatFrameMenuButton` | 当前被 pfUI 隐藏 | 不在主框上伪造菜单入口 |
| `CHAT.RESIZE` | `ChatFrameNResizeBottom` 等原生 resize 对象 | 当前由 pfUI owner 布局取代并隐藏 | 不生成假拖拽角；实机恢复时单独映射 |
| `CHAT.POPUP.SHELL` | 四个原生聊天弹出菜单的共享物理资产合同 | 外壳、列表行悬停与必要滚动状态待实机拆分 | 只共享资产，不合并四个真实 Frame |
| `CHAT.POPUP.CHAT` | `ChatMenu` | 主聊天配置菜单实例 | 动态条目由原生 runtime 绘制 |
| `CHAT.POPUP.EMOTE` | `EmoteMenu` | 表情菜单实例 | 动态条目由原生 runtime 绘制 |
| `CHAT.POPUP.LANGUAGE` | `LanguageMenu` | 语言菜单实例 | 与语言 Button 分离 |
| `CHAT.POPUP.VOICE` | `VoiceMacroMenu` | 语音宏菜单实例 | 不把语音内容烘焙进外壳 |
| `CHAT.URLCOPY.SHELL` | `pfUI.chat.urlcopy`／`pfURLCopy` | 一态的窄横向抄录便笺 shell | 固定 `270 × 65`，`UIParent CENTER`，`FULLSCREEN` strata；保留左键拖动；不复用整张聊天书框，不烘焙 input／close |
| `CHAT.URLCOPY.INPUT` | `pfUI.chat.urlcopy.text`／`pfURLCopyEditBox` | normal／focus 两态三段式输入纸带 | 固定 `250 × 20`，锚到 shell 顶部 `0,-10`；URL、全选、选择与光标由 runtime 持有 |
| `CHAT.URLCOPY.CLOSE` | `pfUI.chat.urlcopy.close`／`pfURLCopyClose` | normal／hover／pushed／disabled 四状态 Button | 固定 `70 × 18`，锚到 shell 右下 `-10,10`；不烘焙本地化“关闭”文字 |
| `CHAT.COPY.TOGGLE` | `pfChatCopyButton` | 关闭／开启两种持久纹理；悬停沿用同一纹理并由 runtime 调整 Alpha | 当前 pfUI 无独立按下／禁用纹理；独立 Button，不烘焙进 Tab 承托带 |
| `CHAT.COPY.SURFACE` | `ChatFrameScrollN` | 显示／隐藏的可滚动复制纸面 | 每个聊天 Frame 独立实例，可共享物理九宫格 |
| `CHAT.COPY.TEXT` | `pfChatCopyBoxN` | 可选择的多行 EditBox | 无消息行位图；选择与光标由 runtime 持有 |
| `CHAT.WHISPER.TOGGLE` | `pfWhisperProxy` | 关闭／开启、悬停、按下、禁用 | Chat 只拥有代理开关 |
| `CHAT.WHISPER.DIALOG` | `CreateQuestionDialog` 返回的共享弹窗 | provider 已知，子对象待 System 模块统一映射 | 不在 Chat 内伪造输入／确认／取消资产 |

`pfChatArrange`、`pfUI.chat.mouseovertab` 与内部 `who_query` 是无可见资产的
布局／事件对象，记录为行为所有者但不分配美术。可选
`CombatLogQuickButtonFrame_Custom` 属于客户端／外部对象，当前只影响左框
正文锚点；取得其真实子对象前保持原生。

## 标准几何

- 唯一聊天书基准容器：`440 × 320 UI px`；`pfChatRight` 不参与布局或资产。
- 正文安全区：`x=30..410`、`y=32..280`，即 `380 × 248 UI px`。
- 最低容量：12px 字号加 `3px` `SetSpacing`，形成约 15px 行高与 16 行中文；
  用户字号、字体配置和消息内容仍由原生／pfUI 持有，AEUI 仅为受管正文移除
  全描边与文字阴影，并把基础频道色映射为适配暖黑纸面的 Vanilla 语义色；
  小队保持蓝紫、团队保持焦橙，已可读的职业／内嵌色原样保留，过暗未知色
  只做达到 `4.8:1` 所需的最小提亮；
  书页上不增加连续压光层。
- Tab：四枚基准为 `92 × 30 UI px`、间距 `3px`、顶部下移 `2px`，共用
  底线与点击画布；承托带高 `16px`、顶部下移 `18px`；超过四枚时只在
  停靠事件后等宽收缩。
- Tab 命中区：视觉与 Button 高度仍为 `30px`，只把底部命中边界向下扩展
  `8px`，覆盖皮革主体，不改变纹理比例或相邻 Tab 排列。
- Tab 文字：以真实 Button 的 `CENTER` 为唯一锚点，水平各留 `6px`、文字区高
  `18px`，水平 `CENTER`／垂直 `MIDDLE`；pfUI 不再覆盖受管文字几何。
- UI Scale：逻辑尺寸仍为上述 UI px。pfUI 解锁界面的缩放路径直接对
  `pfChatLeft:SetScale` 并随后调用 `pfChatLeft.OnMove`，不会可靠触发
  `UI_SCALE_CHANGED`；因此在 `OnMove` 返回后只于 LocalScale／
  EffectiveScale 真正变化时立即强制重放一次 panel、四枚 Tab、TabText、
  正文锚点与命中区。现有维护节拍只比较 EffectiveScale 边沿，用于捕获
  `UIParent:SetScale` 等无事件路径；数值未变的普通拖动不得重放几何。
- 输入条：`380 × 25 UI px`。
- 未读覆盖：约 `16 × 16 UI px`。
- URL Copy：shell `270 × 65 UI px`；input `250 × 20 UI px`；
  close `70 × 18 UI px`。三个对象保持 provider 现有 Parent、Point 和
  显示／关闭时序。
- 还需检查 `540 × 420` 与常用 UI Scale；默认最小值不会产生 `400 × 300`。

## 功能不变量

- 保留聊天消息、频道、左侧停靠、拖动、滚动、历史、URL 复制、链接、输入
  焦点、可选语言切换与 Tab 点击。
- URL Copy 必须保留 `_G.SetItemRef` 对 `url:` 的截取、其他链接转发、
  `CopyText`、显示后全选、Escape／失焦／按钮关闭和 shell 左键拖动。
- 右侧 Loot & Spam 容器停用时，`COMBAT_XP_GAIN`、`COMBAT_HONOR_GAIN`、
  `COMBAT_FACTION_CHANGE`、`SKILL` 与 `LOOT` 必须回收到 `ChatFrame1`，
  不能因隐藏右框而丢失。
- 周期维护不得持续重写 Parent、Point 或尺寸。
- `PLAYER_ENTERING_WORLD`／刷新后的 `0.5s` 终局装配只允许执行一次；用于
  吸收 pfUI／原生登录时序，不得退化为周期几何抢写。
- `pfUI.chat.RefreshChat`、`FCF_SelectDockFrame`、`FCF_DockUpdate` 与
  `FCF_SaveDock` 如果改变 Tab 或正文锚点，只在事件返回后恢复偏离合同的
  对象；拖动锁期间记一枚 pending 标志，解锁后的下一帧恢复一次。几何已
  正确时不得重复改写。
- 缩放边沿是唯一例外：pfUI owner 的真实 Scale 变化立即执行一次强制
  reflow；`UI_SCALE_CHANGED` 保留为事件兜底，现有维护节拍只在
  EffectiveScale 数值变化时触发一次。无缩放的普通拖动和后续周期维护均
  不得重写几何。
- 禁用 AEUI 后回退 pfUI 维护分支；对象缺失时局部回退。
- legacy 信息 provider 由 pfUI 独立拥有；Chat adapter 只允许隐藏
  `pfUI.panel.left/right` 并安装幂等 `OnShow` guard，不得重挂或改写其
  Parent、Point、尺寸、槽位、Button 脚本和 SavedVariables；小地图 Panel
  不得隐藏。
- ChatMOD 的时间戳、彩色玩家名、等级难度、自身高亮与 URL 功能保持启用；
  AEUI 在 pfUI 解析完成后的直接桥、受管 `HookAddMessage` 链和 ChatMOD
  `ORG_AddMessage` 最终出口上幂等替换已审计的八位颜色码，以兼容两种加载
  顺序与包装函数；作用域只要求 Frame 当前 Parent 为 `pfUI.chat.left`，包括
  被 pfUI 按消息类型数量启发式标为 `pfCombatLog` 的窗口，不依赖瞬时
  `isDocked`。不修改 ChatMOD 源码／SavedVariables，
  不剥离 `|H...|h` 链接；未知第三方颜色只有在暖黑纸面低于 `4.8:1` 时才向
  白色做最小提升，已经可读的值原样保留。现有维护节拍只负责
  发现晚出现的 provider 并安装一次 wrapper，不重写消息、几何或插件配置。
