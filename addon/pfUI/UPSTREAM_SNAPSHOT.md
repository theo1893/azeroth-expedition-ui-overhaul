# pfUI 上游基线说明

- 快照日期：2026-07-29
- 来源：
  `D:\Softwares\TurtleWoWTest\Interface\AddOns\pfUI`
- 客户端接口：`11200`
- `pfUI.toc` 版本：`8.1.0`
- 来源仓库 HEAD：`fbc8fb608b79adf32049543ec12fcc020e0acd69`
- 来源仓库未配置 Git remote

最初复制时来源工作树包含以下本机修改，因此项目基线保存的是测试客户端实际
运行内容，而不是纯净 HEAD：

- `pfUI.lua`
- `libs\libtotem.lua`

嵌套的 `.git` 目录没有复制，避免在主项目内形成嵌套仓库。原项目许可证
保留在同目录的 `LICENSE`。

此目录现位于 `addon/pfUI/`，是可直接部署的项目维护分支，不再是只读参考。
上游 MIT 许可仍保留；项目修改清单、回退开关与功能边界见
[`AEUI_FORK.md`](AEUI_FORK.md)。
