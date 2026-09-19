# 外部插件参考快照

本目录仅用于比较其他维护分支的实现，为后续优化提供参考。这里的插件不属于
`addon/` 运行时，不安装到客户端 `Interface/AddOns/`，也不进入 AddOns 分发。

## BigWigs

- 参考源码：[BigWigs/](BigWigs/)。
- 来源：用户提供的 `C:\Users\西奥\Desktop\BigWigs`，由另一位开发者维护的另一分支。
- 导入日期：`2026-09-20`。
- 源 TOC 标识：`Version: 2.0.0`、`X-Fork: Golden`、`X-Revision: 30139`、
  `Interface: 11200`；这些是插件自报信息，未提供对应 Git 分支名或提交号。
- 原目录完整保留，共 `326` 个文件，含 `.workbuddy/`、`documentation/` 与
  `outputs/`；所有文件已逐一校验与来源一致。随附开发说明也仅作参考。
- 当前运行版本仍为 [`addon/BigWigs/`](../../addon/BigWigs/)，本次未替换其中内容。

后续优化从此快照比较、选择所需实现，再在项目运行版本中单独接入与验证；
参考快照本身保留原样，源文件中的作者和许可声明继续保留。
