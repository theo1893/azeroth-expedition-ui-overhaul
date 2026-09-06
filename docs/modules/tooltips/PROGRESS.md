# Tooltips 当前进度

runtime `1.0 / P5`：六个明确提示框与单位生命条已接入现有 2× 细边资源。
用户实机否定 Raid A2 外壳的粗包边，现统一换为 ReadoutShellV1 的 1 UI 细缘，待复测。
仅装饰已有 provider 对象；AtlasLoot 可延迟发现。地图每次显示重建 pfUI 底框时
仍保留 Overhaul 外壳。ItemRef 关闭按钮的父框保持显示。

`/aeui tooltips` 独立切换并恢复 provider 底框、阴影和生命条填充；
归属 route 缺失也回退。`/aeui status` 的 tooltips 行显示接入框数。

pfUI 鼠标跟随模式下，团队成员单位提示改为避开全部可见团队框架，优先右侧、
其次左侧，空间不足时使用下方／上方。只在悬停显示后定位一次；其他单位和物品
保留鼠标跟随，非 cursor 模式不变。此行为属于 pfUI 定位逻辑，不依赖 AEUI 换肤开关。
首版实机未触发：已修复团队框架在单人／小队模式下使用 player／party token 时
漏判的问题，现按 provider 的 `cache_raid` 框架身份识别，等待实机复测。

用户实机反馈首版重启后无变化；已定位并修复初始化调用错误大小写的全局函数，
改用客户端原生 `getglobal`，等待复测生效。

待实机：`/reload` 后检查物品、技能、Aura、单位生命条、双装备比较、世界地图、
聊天链接关闭按钮与 AtlasLoot；重点核对长文本、单位颜色与鼠标跟随定位。
相邻回归背包物品操作，并验证 `/aeui tooltips` 禁用回退。未获用户实机验收。
