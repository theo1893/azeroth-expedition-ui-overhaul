# Chat 子模块定义

本文件只定义聊天模块的真实对象、状态、所有权与资产粒度。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 与原生边界

| 来源 | 真实对象／职责 | 项目处理 |
|---|---|---|
| [`modules/chat.lua`](../../../addon/pfUI/modules/chat.lua) | `pfUI.chat.left/right`、`panelTop`、`ChatFrameN`、`ChatFrameNTab`、`pfUI.chat.editbox`、`ChatFrameEditBox`；聊天事件、停靠、滚动、历史、输入 | 保留行为与生命周期，替换视觉及必要布局 |
| `ChatFrameNTabFlash` | Tab 未读闪烁语义 | 绑定独立未读覆盖，不改变 Tab 几何 |
| [`modules/chatcopy.lua`](../../../addon/pfUI/modules/chatcopy.lua) | 复制／滚动辅助 | 未确认可见对象前保持原生或不挂载视觉 |
| [`modules/whisperproxy.lua`](../../../addon/pfUI/modules/whisperproxy.lua) | 独立密语入口与转发 | 可见入口未拆分，当前不加载 |
| [`modules/bubbles.lua`](../../../addon/pfUI/modules/bubbles.lua) | 聊天气泡呈现 | 不属于战地旧书主框，当前原生回退 |
| [`modules/panel.lua`](../../../addon/pfUI/modules/panel.lua) | 公会、背包、耐久、好友、延迟、时钟、金币等 legacy widgets | 源码保留但默认不加载；不属于聊天视觉 |
| [`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua) | AEUI 书框、Tab、输入和未读 adapter | 只换纹理、UV 和状态，不改聊天数据 |

## 稳定子模块

| ID | 绑定对象 | 逻辑资产与状态 | 几何／禁止项 |
|---|---|---|---|
| `CHAT.FRAME` | 共享物理资产合同 | 空战地旧书九宫格 | 不含 Tab、文字、输入、滚动或固定槽 |
| `CHAT.FRAME.LEFT` | `pfUI.chat.left`／`pfChatLeft` | `CHAT.FRAME` 的左侧运行时实例 | 保留移动、尺寸和左侧停靠行为 |
| `CHAT.FRAME.RIGHT` | `pfUI.chat.right`／`pfChatRight` | `CHAT.FRAME` 的右侧运行时实例 | 可隐藏；不能把右框烘焙进左框 |
| `CHAT.TABS` | `pfUI.chat.left.panelTop`、`pfUI.chat.right.panelTop`、`ChatFrameNTab` | 连续承托带；普通／悬停／选中／禁用 Tab，各自三段式 | 状态切换不改变点击框；Tab 文字运行时绘制 |
| `CHAT.UNREAD` | `ChatFrameNTabFlash` | 蜡封或布结显示／隐藏 | 独立覆盖，不参与 Tab 排列 |
| `CHAT.INPUT` | `pfUI.chat.editbox`、`ChatFrameEditBox` | 普通／聚焦输入纸带，各自左／中／右 | 两状态几何完全相同；不烘焙输入文字 |
| `CHAT.INPUT.LANGUAGE` | 可选 `ChatFrameEditBoxLanguage` | 普通／悬停／按下／禁用／当前语言 | 独立 Button，不画进输入纸带 |
| `CHAT.TEXT` | `ChatFrameN` | 无位图；字体、安全区和内边距 | 不生成行卡片、气泡或消息底色 |
| `CHAT.SCROLL.UP` | `ChatFrameNUpButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.SCROLL.DOWN` | `ChatFrameNDownButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.SCROLL.BOTTOM` | `ChatFrameNBottomButton` | 当前被 pfUI 隐藏 | 未来若恢复，必须独立四状态 |
| `CHAT.MENU` | `ChatFrameMenuButton` | 当前被 pfUI 隐藏 | 不在主框上伪造菜单入口 |
| `CHAT.RESIZE` | `ChatFrameNResizeBottom` 等原生 resize 对象 | 当前由 pfUI owner 布局取代并隐藏 | 不生成假拖拽角；实机恢复时单独映射 |
| `CHAT.URLCOPY.SHELL` | `pfUI.chat.urlcopy`／`pfURLCopy` | 小型弹窗外壳待设计 | 不复用整张聊天书框 |
| `CHAT.URLCOPY.INPUT` | `pfUI.chat.urlcopy.text`／`pfURLCopyEditBox` | 可选中 URL 的 EditBox 待设计 | 文字与选择状态由 runtime 持有 |
| `CHAT.URLCOPY.CLOSE` | `pfUI.chat.urlcopy.close`／`pfURLCopyClose` | 四状态 Button 待设计 | 不烘焙“关闭”文字 |
| `CHAT.WHISPER` | `whisperproxy.lua` 实际入口待映射 | 尚未定义 | 不伪造输入、关闭或目标控件 |

`pfChatArrange`、`pfUI.chat.mouseovertab` 与内部 `who_query` 是无可见资产的
布局／事件对象，记录为行为所有者但不分配美术。可选
`CombatLogQuickButtonFrame_Custom` 属于客户端／外部对象，当前只影响左框
正文锚点；取得其真实子对象前保持原生。

## 标准几何

- 左框基准容器：`440 × 320 UI px`；右框尺寸继续服从
  `C.chat.right.width/height`，共享九宫格但不是同一个 Frame。
- 正文安全区：`x=30..410`、`y=44..280`，即 `380 × 236 UI px`。
- 最低容量：12px 字号、14px 行高时 16 行中文。
- Tab：约 `92 × 42 UI px`，四个共用底线与点击画布。
- 输入条：`380 × 25 UI px`。
- 未读覆盖：约 `16 × 16 UI px`。
- 还需检查 `400 × 300` 与 `540 × 420`。

## 功能不变量

- 保留聊天消息、频道、左右停靠、拖动、滚动、历史、URL 复制、链接、输入
  焦点、可选语言切换与 Tab 点击。
- 周期维护不得持续重写 Parent、Point 或尺寸。
- 禁用 AEUI 后回退 pfUI 维护分支；对象缺失时局部回退。
- legacy 信息 panel 不得因聊天重构重新挂载。
