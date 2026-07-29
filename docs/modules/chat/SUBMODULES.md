# Chat 子模块定义

本文件只定义聊天模块的真实对象、状态、所有权与资产粒度。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 与原生边界

| 来源 | 真实对象／职责 | 项目处理 |
|---|---|---|
| [`modules/chat.lua`](../../../addon/pfUI/modules/chat.lua) | `pfUI.chat.left/right`、`panelTop`、`ChatFrameN`、`ChatFrameNTab`、`pfUI.chat.editbox`、`ChatFrameEditBox`；聊天事件、停靠、滚动、历史、输入 | 只保留左侧主聊天书；右侧容器隐藏，其拾取／经验／荣誉／技能消息组回收到 `ChatFrame1` |
| `ChatFrameNTabFlash` | Tab 未读闪烁语义 | 绑定独立未读覆盖，不改变 Tab 几何 |
| `ChatMenu`、`EmoteMenu`、`LanguageMenu`、`VoiceMacroMenu` | 原生聊天弹出菜单实例 | 当前仍为过渡外观；未来复用一套 `CHAT.POPUP.SHELL`，不得生成四套不同物件 |
| [`modules/chatcopy.lua`](../../../addon/pfUI/modules/chatcopy.lua) | `pfChatCopyButton`、`ChatFrameScrollN`、`pfChatCopyBoxN` | 功能源码保留，默认不加载；完成组件资产后恢复 |
| [`modules/whisperproxy.lua`](../../../addon/pfUI/modules/whisperproxy.lua) | `pfWhisperProxy` 代理开关；调用共享 `CreateQuestionDialog` | 功能源码保留，默认不加载；Chat 只拥有代理开关，对话框归未来 System 公共弹窗 |
| [`modules/bubbles.lua`](../../../addon/pfUI/modules/bubbles.lua) | 聊天气泡呈现 | 不属于战地旧书主框，当前原生回退 |
| [`modules/panel.lua`](../../../addon/pfUI/modules/panel.lua) | 公会、背包、耐久、好友、延迟、时钟、金币等 legacy widgets | 源码保留但默认不加载；不属于聊天视觉 |
| [`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua) | AEUI 书框、Tab、输入和未读 adapter | 只换纹理、UV 和状态，不改聊天数据 |

## 稳定子模块

| ID | 绑定对象 | 逻辑资产与状态 | 几何／禁止项 |
|---|---|---|---|
| `CHAT.FRAME` | 左侧物理资产合同 | 空战地旧书九宫格 | 不含 Tab、文字、输入、滚动或固定槽 |
| `CHAT.FRAME.LEFT` | `pfUI.chat.left`／`pfChatLeft` | `CHAT.FRAME` 的左侧运行时实例 | 保留移动、尺寸和左侧停靠行为 |
| `CHAT.FRAME.RIGHT` | `pfUI.chat.right`／`pfChatRight` | 明确停用的兼容对象；`C.chat.right.enable=0` | 强制隐藏，不分配 AEUI 资产；源码保留以便关闭 overhaul 后对照 |
| `CHAT.TABS` | `pfUI.chat.left.panelTop`、左侧 `ChatFrameNTab` | 连续承托带；普通／悬停／选中／禁用 Tab，各自三段式 | 状态切换不改变点击框；Tab 文字运行时绘制 |
| `CHAT.UNREAD` | `ChatFrameNTabFlash` | 蜡封或布结显示／隐藏 | 独立覆盖，不参与 Tab 排列 |
| `CHAT.INPUT` | `pfUI.chat.editbox`、`ChatFrameEditBox` | 普通／聚焦输入纸带，各自左／中／右 | 两状态几何完全相同；不烘焙输入文字 |
| `CHAT.INPUT.LANGUAGE` | 可选 `ChatFrameEditBoxLanguage` | 普通／悬停／按下／禁用／当前语言 | 独立 Button，不画进输入纸带 |
| `CHAT.TEXT` | `ChatFrameN` | 无位图；字体、安全区和内边距 | 不生成行卡片、气泡或消息底色 |
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
| `CHAT.URLCOPY.SHELL` | `pfUI.chat.urlcopy`／`pfURLCopy` | 小型弹窗外壳待设计 | 不复用整张聊天书框 |
| `CHAT.URLCOPY.INPUT` | `pfUI.chat.urlcopy.text`／`pfURLCopyEditBox` | 可选中 URL 的 EditBox 待设计 | 文字与选择状态由 runtime 持有 |
| `CHAT.URLCOPY.CLOSE` | `pfUI.chat.urlcopy.close`／`pfURLCopyClose` | 四状态 Button 待设计 | 不烘焙“关闭”文字 |
| `CHAT.COPY.TOGGLE` | `pfChatCopyButton` | 关闭／开启、悬停、按下、禁用 | 独立 Button；不烘焙进 Tab 承托带 |
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
- 正文安全区：`x=30..410`、`y=44..280`，即 `380 × 236 UI px`。
- 最低容量：12px 字号、14px 行高时 16 行中文。
- Tab：约 `92 × 42 UI px`，四个共用底线与点击画布。
- 输入条：`380 × 25 UI px`。
- 未读覆盖：约 `16 × 16 UI px`。
- 还需检查 `540 × 420` 与常用 UI Scale；默认最小值不会产生 `400 × 300`。

## 功能不变量

- 保留聊天消息、频道、左侧停靠、拖动、滚动、历史、URL 复制、链接、输入
  焦点、可选语言切换与 Tab 点击。
- 右侧 Loot & Spam 容器停用时，`COMBAT_XP_GAIN`、`COMBAT_HONOR_GAIN`、
  `COMBAT_FACTION_CHANGE`、`SKILL` 与 `LOOT` 必须回收到 `ChatFrame1`，
  不能因隐藏右框而丢失。
- 周期维护不得持续重写 Parent、Point 或尺寸。
- 禁用 AEUI 后回退 pfUI 维护分支；对象缺失时局部回退。
- legacy 信息 panel 不得因聊天重构重新挂载。
