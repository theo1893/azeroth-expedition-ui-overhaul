# 聊天模块 V3 源资源清单

本文件描述 `assets/source/chat/v3/` 中的生产母版和验收证据；源目录只保存
二进制资产，不再放置说明文档。

## 母版与职责

| 文件 | 组件 | 对象 |
|---|---|---|
| `ChatBookFrame_Master_v3.png` | `CHAT.FRAME` | 一张无控件的空战地旧书 |
| `ChatTabs_Master_v3.png` | `CHAT.TABS` | 一条承托带；普通、悬停、选中、禁用 Tab |
| `ChatControls_Master_v3.png` | `CHAT.INPUT`、`CHAT.UNREAD` | 两状态输入条；一个未读标记；旧底栏字段切片已停用 |

三张母版均为真 RGBA、高分辨率、无运行时文字。它们是已确认的 `P4` 生产源，
尚未升级为正式 runtime，也不会由游戏直接加载。

原始执行提示词：
[`聊天框模块化资源_执行提示词_v3.md`](../../prompts/chat/聊天框模块化资源_执行提示词_v3.md)。

## 验收证据

`previews/` 保存两张不可从截图文字描述替代的标准尺寸证据：

- `ChatLayout_Combined_Clean_v3.png`：输入普通与聚焦状态；重新生成时不得显示
  legacy 信息底栏。
- `ChatLayout_Combined_Debug_v3.png`：标出 `380 × 236` 正文安全区。

每个内框精确为 `440 × 320 UI px`。样例文字只存在于预览，没有进入母版。

## 状态

- A／B／C 美术与透明化完成。
- C 中曾确认的底栏字段因产品决策停用；保留母版只为输入条和未读标记溯源，
  exporter 不再裁切该字段。
- `440 × 320` 容量预演完成，可放 16 行 12px 中文。
- pfUI runtime 迁移尚未开始。
- 恢复时先在临时目录复核 `tools/build_chat_v3_runtime_assets.py`，再更新
  TGA、manifest、Lua 和 smoke test。

色键 raw、临时 crop、可再生 atlas 和调试导出不得放回
`assets/source/chat/v3/`；统一写入被 Git 忽略的 `generated/`。
