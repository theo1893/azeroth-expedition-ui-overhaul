SuperMacroPlus 1.0.0
====================

SuperMacroPlus is based on SuperMacro 3.19 and manages only Super macros.
It is intended as a replacement UI. Disable the original SuperMacro addon while
using SuperMacroPlus to avoid both addons installing the same WoW API hooks.
The original addon's files and SavedVariables are not modified.

Categories
----------

Common, Shaman, Mage, Paladin, Druid, Hunter, Priest, Rogue, Warlock, Warrior.
Each category stores up to 50 Super macros, for a total capacity of 500.
The grid displays 30 macros at once and scrolls to the remaining 20.

Usage
-----

/supermacroplus or /smp opens the window.
/macroplus <name> or /smacroplus <name> runs a Super macro by name.
/smp import retries migration from the original SuperMacro addon.

Select a category tab, then use New, Save, Edit, or Delete. The window title
shows the current category count as current/50. Macro names are unique across
all categories so action-bar references remain stable when switching tabs.

Native macros can be dragged from the macro window or an action bar onto any
empty category slot to copy them into the current category as Super macros.
Occupied slots are never overwritten. A SuperMacroPlus macro dragged to an
empty slot on another category tab is moved to that category.

Action bar
----------

Dragging a Super macro uses one native account macro named SMP_Carrier as an
internal carrier. The carrier is created lazily and reused by every Super macro;
the categorized macros themselves remain in SuperMacroPlus SavedVariables and
do not consume additional native macro slots.

Migration from SuperMacro
-------------------------

On the first load where both addons are enabled, SuperMacroPlus copies the
original addon's Super macros into Common, then copies native regular macros
into any slots still available there. Existing SuperMacroPlus macros win name
conflicts, and the Common tab remains capped at 50. Compatible per-character
action-bar mappings are copied too. No original macro or SavedVariables entry
is changed or deleted.

Because WoW does not load SavedVariables for a disabled addon, temporarily
enable both SuperMacro and SuperMacroPlus once and /reload. After the migration
message appears, disable the original SuperMacro again for normal play. Use
/smp import to retry a partial migration after freeing space or resolving a
name conflict.

Saved data
----------

SMP_SUPER stores macro name, icon, body, and category.
SMP_VARS stores the selected category and options.
SMP_ACTION_SUPER stores per-character action-bar mappings.

中文说明
--------

SuperMacroPlus 只管理超级宏，并按以下标签分类：
通用、萨满、法师、圣骑士、德鲁伊、猎人、牧师、盗贼、术士、战士。

建议启用 SuperMacroPlus 时停用原版 SuperMacro，避免两个插件同时挂接同一套
游戏 API。原插件目录和原有 SavedVariables 均不会被修改。

每个分类最多 50 个宏，总容量 500 个。界面一次显示 30 个，剩余宏通过
滚动条访问。窗口标题会显示当前分类的“已用数量/50”。

使用 /supermacroplus 或 /smp 打开界面；使用 /macroplus 宏名 或
/smacroplus 宏名执行指定超级宏。宏名在所有分类中保持唯一。

可把原生宏窗口或动作条上的已有宏拖到当前分类的空槽位，插件会将它复制为
超级宏；已有内容的槽位不会被覆盖。也可以拖起一个超级宏Plus宏，切换分类
后放到空槽位，将它移动到该分类。

首次迁移原版宏时，请在插件列表里临时同时启用 SuperMacro 和
SuperMacroPlus，然后输入 /reload。插件会优先把原版超级宏复制到“通用”，
再用剩余位置复制原版常规宏，并尽可能恢复动作条关联；同名宏和超过通用页
50 个上限的宏会跳过。迁移只复制数据，不会修改或删除原版宏。看到迁移
提示后，正常游戏时可再次停用原版 SuperMacro。释放位置或处理同名冲突后，
可用 /smp import 手动重试。

第一次把超级宏拖到动作条时，插件会按需创建并复用一个名为
SMP_Carrier 的原生账号宏。它只占一个原生宏槽，其他分类宏不会继续
占用原生宏槽。
