# Chat runtime media

`ChatBookFrame.tga` 是 Turtle WoW 运行时使用的 32 位 TGA。

- 画布：1024 × 1024。
- 有效画面：顶部 586 像素。
- Lua 使用同一张纹理的九组 UV 构成九宫格，避免宽高拉伸造成边框变形。
- 高分辨率透明母版：
  `assets/source/chat/ChatBookFrame_Master_v1.png`。
- 运行时预览：
  `assets/source/chat/ChatBookFrame_RuntimePreview_v2.png`。
- 九宫格预览：
  `assets/source/chat/ChatBookFrame_NineSlicePreview_v2.png`。
- 重建脚本：`tools/build_chat_book_texture.py`。

不要把频道名或聊天文字烘焙进此纹理；全部文字由游戏 UI 层渲染。

组件级资源由 `tools/build_chat_component_textures.py` 生成：

- `ChatTabNormal.tga`
- `ChatTabHover.tga`
- `ChatTabSelected.tga`
- `ChatTabShelf.tga`
- `ChatPanelSegment.tga`
- `ChatInputStrip.tga`
- `ChatWaxSeal.tga`

这些 pfUI 组件资源以 2× 分辨率输出，分别对应控件状态，不能再合并回
单张聊天框背景。目录中遗留的频道与 WIM 试验资源当前不会被 Lua 加载。

imagegen-v4 因风格过度工整、上下边界不对称且与 pfUI Tab 几何冲突，已从
运行时和正式资源中移除；反例只保存在被 Git 忽略的
`generated/chat_pfui_hq/rejected_imagegen_v4/`。
