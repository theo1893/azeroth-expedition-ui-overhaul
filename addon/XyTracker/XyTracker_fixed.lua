-- 完整的修复版本，包含正确缩进的职业菜单代码
-- 请将此文件内容复制到原始的XyTracker.lua文件中对应的位置

-- 修复后的职业菜单项代码：

										-- 然后显示9职业带染色
										local allClasses = {"战士", "圣骑士", "猎人", "盗贼", "牧师", "萨满祭司", "法师", "术士", "德鲁伊"};
										for _, class in ipairs(allClasses) do
												local classColor = XYT_GetClassColor(class);
												local coloredClass = class;
												if classColor then
														coloredClass = classColor .. class .. "\124r";
												end
												
												-- 为指定拾取下的职业添加鼠标悬停提示，显示该职业的所有角色名
												local menuLevel = UIDROPDOWNMENU_MENU_LEVEL;
												
												-- 先创建按钮
												UIDropDownMenu_AddButton({
														text = coloredClass,
														value = class,
														hasArrow = 1,
														notCheckable = 1,
														-- 保留func以便点击时也能工作
														func = function()
																-- 调试输出
																DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 打开指定拾取职业子菜单: " .. this.value);
																
																-- 关闭当前层级以上的菜单
																CloseDropDownMenus(UIDROPDOWNMENU_MENU_LEVEL);
																-- 打开下一层级的菜单，层级设置为2
																ToggleDropDownMenu(1, this.value, GroupLootDropDown, this:GetName(), 10, 0, nil, nil, 2);
																-- 确保子菜单获得焦点
																local subMenuFrame = getglobal("DropDownList"..(UIDROPDOWNMENU_MENU_LEVEL+1));
																if subMenuFrame then
																	subMenuFrame:SetFrameStrata("HIGH");
																	subMenuFrame:SetFrameLevel(100);
																end
														end,
														-- 移除自动悬停触发子菜单，避免菜单堆叠时的冲突
														OnEnter = function()
																-- 只显示工具提示，不自动打开子菜单
																local roleNames = "";
																local memberCount = GetNumRaidMembers();
																for i = 1, memberCount do
																		local name, _, _, _, unitClass = GetRaidRosterInfo(i);
																		if name and unitClass == class then
																				if roleNames ~= "" then
																						roleNames = roleNames .. ", ";
																				end
																				roleNames = roleNames .. name;
																		end
																end
																if roleNames ~= "" then
																		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
																		GameTooltip:SetText(class .. "角色：" .. roleNames);
																end
														end,
														OnLeave = function()
																GameTooltip:Hide();
														end
												}, UIDROPDOWNMENU_MENU_LEVEL);
										end