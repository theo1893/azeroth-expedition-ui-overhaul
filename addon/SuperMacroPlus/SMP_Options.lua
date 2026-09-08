SuperMacroPlusOptionsFrameCheckButtons = { };
SuperMacroPlusOptionsFrameCheckButtons["SMP_HIDE_ACTION"] = { index = 1, var = "hideAction"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_MACRO_TIP_1"] = { index = 2, var = "macroTip1"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_MACRO_TIP_2"] = { index = 3, var = "macroTip2"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_MINIMAP"] = { index = 4, var = "minimap"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_REPLACE_ICON"] = { index = 5, var = "replaceIcon"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_CHECK_COOLDOWN"] = { index = 6, var = "checkCooldown"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_SHOW_MENU"] = { index = 7, var = "showMenu"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_WORDWRAP"] = { index = 8, var = "wordWrap"};
SuperMacroPlusOptionsFrameCheckButtons["SMP_MONO_FONT"] = { index = 9, var = "monoFont"};
SuperMacroPlusOptionsFrameColorSwatches = { };
SuperMacroPlusOptionsFrameColorSwatches["SMP_PRINT_COLOR"] = { index = 1, var = "printColor", exampleText=SMP_PRINT_COLOR_EXAMPLE_TEXT};
SuperMacroPlusOptionsFrameEditBoxes = { };
SuperMacroPlusOptionsFrameEditBoxes["SMP_WINDOW_WIDTH"] = { index = 1, var = "windowWidth"};
SuperMacroPlusOptionsFrameEditBoxes["SMP_WINDOW_HEIGHT"] = { index = 2, var = "windowHeight"};
SuperMacroPlusOptionsFrameEditBoxes["SMP_EDITBOX_FONT_SIZE"] = { index = 3, var = "editBoxFontSize"};

function SuperMacroPlusOptionsFrame_OnShow()
	SuperMacroPlusOptionsFrame:ClearAllPoints()
	SuperMacroPlusOptionsFrame:SetPoint("CENTER", nil, "CENTER", 0, 0)

	SuperMacroPlusFrameText:ClearFocus();
	SuperMacroPlusFrameSuperText:ClearFocus();

	PlaySound("igMainMenuOption")

	-- Disable Buttons
	SuperMacroPlusEditButton:Disable();
	SuperMacroPlusDeleteButton:Disable();
	SuperMacroPlusNewAccountButton:Disable();
	SuperMacroPlusNewCharacterButton:Disable();

  	for k, v in SuperMacroPlusOptionsFrameCheckButtons do
  		local button = getglobal("SuperMacroPlusOptionsFrameCheckButton"..v.index);
  		local string = getglobal("SuperMacroPlusOptionsFrameCheckButton"..v.index.."Text");
  		local checked;
  		checked = SMP_VARS[v.var];
  		button:SetChecked(checked);
  		string:SetText(TEXT(getglobal(k)));
  	end
	
	for k, v in SuperMacroPlusOptionsFrameColorSwatches do
		local button = getglobal("SuperMacroPlusOptionsFrameColorSwatch"..v.index);
		button.var = v.var;
		local string = getglobal("SuperMacroPlusOptionsFrameColorSwatch"..v.index.."Text");
		string:SetText(TEXT(getglobal(k)));
		button.r = SMP_VARS[v.var].r;
		button.g = SMP_VARS[v.var].g;
		button.b = SMP_VARS[v.var].b;
		getglobal(button:GetName().."NormalTexture"):SetVertexColor( button.r, button.g, button.b );
		button.opacity = 1;
		local example = getglobal("SuperMacroPlusOptionsFrameColorSwatch"..v.index.."ExampleText");
		if ( v.exampleText ) then
			example:SetText(v.exampleText);
			example:SetTextColor(button.r, button.g, button.b);
		end
	end

	for k, v in SuperMacroPlusOptionsFrameEditBoxes do
  		local button = getglobal("SuperMacroPlusOptionsFrameEditBox"..v.index);
  		local string = getglobal("SuperMacroPlusOptionsFrameEditBox"..v.index.."Text");
  		local text = SMP_VARS[v.var];
  		button:SetText(text);
  		string:SetText(TEXT(getglobal(k)));
  	end
end

function SuperMacroPlusOptionsFrame_OnHide()
	PlaySound("igMainMenuOptionCheckBoxOff")
	SuperMacroPlusEditButton:Enable();
	SuperMacroPlusDeleteButton:Enable();
	SuperMacroPlusNewAccountButton:Enable();
	SuperMacroPlusNewCharacterButton:Enable();
	SuperMacroPlusUpdateConfig()
end

function SuperMacroPlusOptionsFrameColorSwatch_OnLoad()
end

function SuperMacroPlusOptions_OpenColorPicker(this)
	ColorPickerFrame.func = function() 
		SMP_VARS[this.var].r, SMP_VARS[this.var].g, SMP_VARS[this.var].b = ColorPickerFrame:GetColorRGB();
		SuperMacroPlusOptionsFrame:Hide();
	end
	ColorPickerFrame.hasOpacity = this.hasOpacity;
	ColorPickerFrame.opacityFunc = function ()
		SuperMacroPlusOptionsFrame:Show()
	end
	ColorPickerFrame.opacity = this.opacity;
	ColorPickerFrame:SetColorRGB(this.r, this.g, this.b);
	ColorPickerFrame.previousValues = {r = this.r, g = this.g, b = this.b, opacity = this.opacity};
	ColorPickerFrame.cancelFunc = function()
		SMP_VARS[this.var].r, SMP_VARS[this.var].g, SMP_VARS[this.var].b = ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b;
		SuperMacroPlusOptionsFrame:Show()
	end
	ShowUIPanel(ColorPickerFrame);
end

function SMP_HideActionText()
	local func=ActionButton1Name.Show;
	if ( SMP_VARS.hideAction == 1 ) then
		func = ActionButton1Name.Hide;
	elseif ( SMP_VARS.hideAction == 0 ) then
		func = ActionButton1Name.Show;
	end
	for i = 1,12 do
		if ( getglobal("ActionButton"..i) ) then
			func(getglobal("ActionButton"..i.."Name"));
		else
			break;
		end
		if ( getglobal("BonusActionButton"..i.."Name")) then
			func(getglobal("BonusActionButton"..i.."Name"));
		end
		if ( getglobal("MultiBarBottomLeftButton"..i.."Name") ) then
			func(getglobal("MultiBarBottomLeftButton"..i.."Name"));
			func(getglobal("MultiBarBottomRightButton"..i.."Name"))
			func(getglobal("MultiBarLeftButton"..i.."Name"));
			func(getglobal("MultiBarRightButton"..i.."Name"));
		end
	end
	for i = 1,72 do
		if ( getglobal("FUActionButton"..i) ) then
			func(getglobal("FUActionButton"..i.."Name"));
		else
			break;
		end
	end
	for i = 1,120 do
		if ( getglobal("DiscordActionButton"..i.."Name")) then
			func(getglobal("DiscordActionButton"..i.."Name"));
		else
			break;
		end
	end
end

function SMP_ToggleMenu()	
		if ( SMP_VARS.showMenu == 1 ) then
			GameMenuButtonSuperMacroPlus:Show();
		else
			GameMenuButtonSuperMacroPlus:Hide();
		end
end

function SMP_ToggleWordWrap()
	if ( not SuperMacroPlusFrameSuperText.SetNonSpaceWrap ) then
		SMP_WORDWRAP = "DOESN'T WORK YET";
		return;
	end
	if ( SMP_VARS.wordWrap == 1 ) then
		SuperMacroPlusFrameText:SetNonSpaceWrap(1);
		SuperMacroPlusFrameSuperText:SetNonSpaceWrap(1);
	else
		SuperMacroPlusFrameText:SetNonSpaceWrap(0);
		SuperMacroPlusFrameSuperText:SetNonSpaceWrap(0);
	end
end
