# Group Finder 子模块定义

本模块是独立插件，不接管 pfUI、Blizzard LFT 或团队框架。服务器聊天系统持有
频道成员与发送者身份；插件只在客户端维护短期招募缓存、表单和申请队列。

| ID | 对象 | 功能所有权 |
|---|---|---|
| GF.CHANNEL | 自定义频道 `AEGF1` | 服务器负责投递与发送者身份；插件加入后从聊天框移除显示，用带版本协议发布、关闭和请求同步 |
| GF.DIRECT | `TW_CHAT_MSG_WHISPER<玩家>` | Turtle 服务器负责定向投递；插件只发送申请和 `PENDING／INVITED／REJECTED／CLOSED` 回执 |
| GF.LIST | `AzerothExpeditionGroupFinderFrame` 左栏 | 显示缓存内完整招募信息并分页；不向团长二次询问详情 |
| GF.DRAFT | 面板右上表单、`AzerothExpeditionGroupFinderDB.draft` | 团长持有团名、最低装等、T/N/D、职业上限、说明与装备竞争摘要；当前职业分布从真实队伍／团队只读生成 |
| GF.APPLICATIONS | 面板右下申请队列 | 团长客户端在线内存持有；邀请调用原生 `InviteByName()`，不自动组团或改团队权限 |

## MVP 不变量

- 普通频道消息中的团长只采用 `CHAT_MSG_CHANNEL` 发送者，定向申请中的玩家只采用
  `CHAT_MSG_ADDON` 发送者；协议正文不能声明身份。
- 招募每 60 秒续期，150 秒未收到续期即从本地目录过期；新客户端用一次同步请求让
  在线团长错峰重发。
- 装等由申请者客户端根据 17 个战斗装备槽计算并自报，团长仍应通过观察确认。
- 装备竞争首版是团长维护的“物品 当前/上限”摘要，不自动占位或阻止申请。
- `/aegf` 打开面板，`/aegf sync` 请求刷新，`/aegf close` 停止当前招募。
