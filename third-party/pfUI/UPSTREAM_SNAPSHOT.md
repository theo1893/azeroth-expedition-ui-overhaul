# pfUI 开发快照说明

- 快照日期：2026-07-29
- 来源：
  `D:\Softwares\TurtleWoWTest\Interface\AddOns\pfUI`
- 客户端接口：`11200`
- `pfUI.toc` 版本：`8.1.0`
- 来源仓库 HEAD：`fbc8fb608b79adf32049543ec12fcc020e0acd69`
- 来源仓库未配置 Git remote

复制时来源工作树包含以下本机修改，当前快照保存的是测试客户端实际运行
内容，而不是纯净 HEAD：

- `pfUI.lua`
- `libs\libtotem.lua`

嵌套的 `.git` 目录没有复制，避免在主项目内形成嵌套仓库。原项目许可证
保留在同目录的 `LICENSE`。

此目录默认只用于：

- 阅读 pfUI 的真实聊天框生命周期和对象关系；
- 在其他机器上检索、编写测试夹具和完成兼容开发；
- 对照 TurtleWoWTest 的实际版本排查行为差异。

项目功能应写入 `addon\AzerothExpeditionUI`。除非明确更新快照，不要直接
修改此目录，也不要从这里部署 pfUI 到测试客户端。
