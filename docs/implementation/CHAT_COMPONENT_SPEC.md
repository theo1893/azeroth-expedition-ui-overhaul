# 聊天模块组件与资产契约

## 当前结论

- 功能底座：pfUI。
- 重构方式：`adapter`；复用 pfUI 的聊天行为与 Frame 生命周期，重做视觉层和
  必要布局。
- 当前运行时：插件 `0.4.0`，仍加载无信息底栏的 legacy 独立 TGA。
- 当前候选源资产：V3 A／B／C 透明母版，已完成 `440 × 320` 预演，尚未导出
  或接入游戏。
- 生产提示词：
  [`聊天框模块化资源_执行提示词_v3.md`](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md)。
- 进度事实来源：
  [`OVERHAUL_TRACKER.md`](OVERHAUL_TRACKER.md)。

`P4 V3` 只表示源资产已确认，不等于 runtime 或实机验收完成。

## 运行时对象边界

| 组件 ID | pfUI／原生对象 | 逻辑资产 | 状态／实例 | 几何职责 |
|---|---|---|---|---|
| `CHAT.FRAME` | `pfUI.chat.left` | 书框九宫格 | 9 个逻辑切片 | 只跟随 owner 位置和尺寸 |
| `CHAT.TABS` | `pfUI.chat.left.panelTop`、`ChatFrameNTab` | 连续承托带；Tab 左／中／右 | 4 个状态 × 3 切片 | 状态切换不得改变点击框 |
| `CHAT.UNREAD` | `ChatFrameNTabFlash` | 蜡封／布结覆盖 | 显示／隐藏 | 不参与 Tab 排列 |
| `CHAT.INPUT` | `pfUI.chat.editbox`、`ChatFrameEditBox` | 输入条左／中／右 | 普通、聚焦 | 两状态共用完全相同几何 |
| `CHAT.TEXT` | `ChatFrameN` | 无位图 | 动态文字 | 只定义安全区和内边距 |
| `CHAT.SCROLL` | pfUI chat／chatcopy 可见控件待核实 | 未定义 | 待实机测量 | 找到真实 Frame 后才能生产 |

不得把频道名、消息、输入文字、固定 Tab 槽或滚动按钮画进主书框。
物理图集可以合并逻辑切片，但必须用 manifest 和 UV 精确恢复以上边界。

`pfUI.panel` 的 widget 代码继续保留，但公会、背包空间、耐久、好友、延迟、
时钟、金币和区域等输出槽默认为 `none`。它们不是聊天模块的视觉组件，不得
恢复为强制常驻三联底栏。

## V3 源资产

| 文件 | 承担的组件 | 已包含对象 |
|---|---|---|
| [`ChatBookFrame_Master_v3.png`](../../assets/source/chat/v3/ChatBookFrame_Master_v3.png) | `CHAT.FRAME` | 一张空战地旧书主框 |
| [`ChatTabs_Master_v3.png`](../../assets/source/chat/v3/ChatTabs_Master_v3.png) | `CHAT.TABS` | 一条承托带；普通、悬停、选中、禁用 Tab |
| [`ChatControls_Master_v3.png`](../../assets/source/chat/v3/ChatControls_Master_v3.png) | `CHAT.INPUT`、`CHAT.UNREAD` | 两个输入状态、一个未读标记；旧字段切片停用 |

V3 母版是组件生产源，不是整张可直接贴入游戏的背景图。源图坐标由
`tools/build_chat_v3_runtime_assets.py` 锁定；改动坐标时必须同步本文、
exporter manifest 和 Lua UV。

## 标准运行尺寸

- 最小聊天容器：`440 × 320 UI px`。
- 正文安全区：`x=30..410`、`y=44..280`，即 `380 × 236 UI px`。
- 容量目标：12px 字号、14px 行高时至少 16 行中文。
- 四个 Tab：共同画布约 `92 × 42 UI px`，共用底线和点击几何。
- 输入条：`380 × 25 UI px`。
- 未读标记：约 `16 × 16 UI px`。

还必须预演紧凑 `400 × 300` 与展开 `540 × 420`。预演通过不能代替目标
客户端实机验证。

## 物理运行时资源计划

V3 exporter 计划生成：

| 文件 | 画布 | 内容 |
|---|---:|---|
| `ChatBookFrameV3.tga` | `1024 × 1024` | 主框九宫格图集 |
| `ChatTabAtlasV3.tga` | `512 × 512` | 四状态 Tab 图集 |
| `ChatTabShelfV3.tga` | `1024 × 64` | 连续承托带 |
| `ChatInputAtlasV3.tga` | `1024 × 256` | 普通／聚焦输入条 |
| `ChatUnreadSealV3.tga` | `64 × 128` | 未读覆盖 |

这些文件目前不属于正式 runtime。导出脚本只能把可再生预览和 manifest 写入
Git 忽略的产物目录；`assets/source/` 只保存用户确认的透明母版和必要验收
证据。

## 当前 legacy runtime

`addon/AzerothExpeditionUI/Media/Chat/` 中以下文件仍由 `Modules/Chat.lua`
加载，因此在 V3 迁移完成前必须保留：

- `ChatBookFrame.tga`
- `ChatTabNormal.tga`
- `ChatTabHover.tga`
- `ChatTabSelected.tga`
- `ChatTabShelf.tga`
- `ChatInputStrip.tga`
- `ChatWaxSeal.tga`

legacy 主框可由 `assets/source/chat/ChatBookFrame_Master_v1.png` 和现有两个
legacy builder 重建。V3 迁移提交必须同时更新 Lua、runtime 媒体、smoke
test、本文和 tracker，不能先删除可回退资产。

## V3 迁移验收门

1. 在临时目录运行 exporter，验证所有图集为 RGBA、2 的幂、包含真 Alpha。
2. 人工复核 crop 坐标、4px 防渗色边距、九宫格接缝与三段式端帽。
3. 让 Lua 只交换纹理或 UV；Tab 周期维护不修改 Parent、Point 或尺寸。
4. smoke test 覆盖五张 V3 纹理、四个 Tab 状态、两种输入状态和 legacy
   panel 隐藏状态。
5. 游戏内验证拖动、停靠、滚动、Tab 闪烁、输入焦点、三种窗口尺寸及常见
   UI Scale。
6. 用户确认实机效果后，tracker 才能从 `P5` 升至 `P6`，随后才可移除
   legacy builder 与资源。
