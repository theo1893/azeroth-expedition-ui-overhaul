# Tools

聊天框资源可通过以下两个脚本确定性重建：

- `build_chat_book_texture.py`：生成 1024 × 1024 主纹理和九宫格预览。
- `build_chat_component_textures.py`：生成 pfUI Tab、底栏、输入条与蜡封的
  2× 运行时 TGA。

主纹理的九宫格切线必须与 `Modules/Chat.lua` 中的 `BOOK_UV` 保持一致。

被否决的 imagegen-v4 资源不作为这两个脚本的输入。
