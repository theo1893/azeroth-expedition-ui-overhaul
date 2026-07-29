# Third-party material notice

本仓库当前包含：

- 游戏界面截图和结构参考。
- 基于既有游戏视觉语言生成的设计概念图。
- 与 Turtle WoW、pfUI 和其他插件相关的描述性设计资料。
- pfUI `8.1.0` 的 MIT 许可项目维护分支。
- 采用 SIL Open Font License 1.1 的第三方字体文件。

这些内容不自动获得开放源代码或商业分发许可。`World of Warcraft` 及相关名称、视觉元素与商标归其各自权利人所有；Turtle WoW、pfUI 和其他插件也可能拥有各自许可与署名要求。

在创建公开 GitHub 仓库、发布安装包或接受商业赞助前，应逐项确认：

1. 哪些参考图只能保留在私人设计仓库中。
2. 哪些生成图可以重新制作成原创运行时资源。
3. 原插件代码、字体、图标和贴图的许可证与署名要求。
4. 仓库整体应采用的代码许可证，以及视觉资产是否需要单独许可。

因此，本仓库暂不附带开源许可证。

## pfUI 项目维护分支

`addon/pfUI/` 保存 pfUI `8.1.0` 的可测试维护分支，来源提交
`fbc8fb608b79adf32049543ec12fcc020e0acd69`，按其 MIT License 保存。
完整许可见 `addon/pfUI/LICENSE`，上游状态与本地视觉差异说明见
[`PFUI_UPSTREAM_SNAPSHOT.md`](docs/pfui/PFUI_UPSTREAM_SNAPSHOT.md) 和
[`PFUI_FORK.md`](docs/pfui/PFUI_FORK.md)。

该许可只覆盖相应 pfUI 代码，不自动覆盖本项目生成的视觉资产、游戏截图、
商标、字体或将来新增的原创代码。

## 已纳入的第三方字体

以下字体随未来插件资源一并保存，但不自动适用本仓库未来可能采用的代码许可证：

- `LXGWWenKaiGB-Medium.ttf`
  - 上游：LXGW WenKai GB／霞鹜文楷 GB。
  - 状态：未经修改的官方静态 TTF。
  - 许可：SIL Open Font License 1.1；包含保留字体名称条款。
- `NotoSerifSC-SemiBold.ttf`
  - 上游：Google Fonts 中的 `NotoSerifSC[wght].ttf`。
  - 状态：使用 FontTools 将官方可变字体固定为 `wght=600` 的静态 TTF。
  - 许可：SIL Open Font License 1.1。
- `NotoSansSC-Medium.ttf`
  - 上游：Google Fonts 中的 `NotoSansSC[wght].ttf`。
  - 状态：使用 FontTools 将官方可变字体固定为 `wght=500` 的静态 TTF。
  - 许可：SIL Open Font License 1.1；包含 `Source` 保留字体名称条款。

完整许可、固定的上游提交、生成方式和校验值见 `third-party/fonts/`。

仓库不包含、也不得重新分发《魔兽世界》客户端自带字体。实现时如需保留香草英文标题、数字或战斗字体，只允许在用户本地客户端中按路径引用，并提供缺失时的回退方案。
