# Chat 当前进度

## 当前运行时

- AEUI Chat contract：`1.22 / P5 / pending-game-validation`。
- 唯一活动聊天窗口为左框 `pfChatLeft`；右框隐藏。拾取、经验、荣誉、声望和
  技能消息回收到左框。
- 左右聊天信息 Panel 隐藏，小地图 Panel 保留。
- AEUI 只接管外观与布局；目标客户端、pfUI 与 ChatMOD 的经典消息颜色、链接、
  Alpha 和消息载荷原样透传。

| 组件 | 阶段 | Runtime |
|---|---:|---|
| Full V1 暖黑战地旧书主框 | `P5` | `Media/Chat/ChatBookFrameFullV1.tga` |
| Dark V2 粗糙旧皮 Tab／承托带 | `P5` | `ChatTabAtlasDarkV2.tga`、`ChatTabShelfDarkV2.tga` |
| Dark V1 暖烟草输入条 | `P5` | `ChatInputDarkV1.tga` |
| 未读蜡封 | `P5` | `ChatUnreadSealV3.tga` |

accepted source 与 manifest 位于 `assets/source/chat/frame-full-v1/`、
`input-dark-v1/`、`tabs-dark-v2/` 和 `v3/`。V3 主框、Tab 与输入媒体当前只作
tracked 回退，不是活动视觉。

## 下一次实机验证

1. `/reload` 后确认 `/aeui status` 含 `chat-runtime=1.22` 与
   `chat-color=classic-provider`。
2. 检查主框没有现代透明方块或正文压光；右框和两条聊天 Panel 始终隐藏。
3. 验证普通／悬停／选中／禁用 Tab、五 Tab 压缩、文字居中，以及拖动、局部
   Scale 和全局 UI Scale 后不会回到浅色旧 Tab。
4. 验证输入框普通／聚焦状态、光标、IME、频道头、历史和键盘事件。
5. 分别观察公共、系统、公会、小队、团队、密语、警告、职业色、物品品质、
   URL 与第三方内嵌颜色，确认没有被 AEUI 改写。
6. 验证滚动、未读、链接和消息回收到左框；禁用 AEUI Chat 时 pfUI 行为可用。

## 暂缓

Chat Copy、URL Copy、语言按钮、Popup、Whisper Toggle 与当前隐藏的滚动／菜单
控件均未锁定，不加载新 runtime，也不保留旧尝试流水。恢复时从真实对象和新的
简单预演开始。
