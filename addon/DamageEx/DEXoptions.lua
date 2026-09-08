-- 提供缺失的旧版 OptionsFrame 函数
if not NORMAL_FONT_COLOR then NORMAL_FONT_COLOR = { r = 1.0, g = 0.82, b = 0 } end
if not GRAY_FONT_COLOR then GRAY_FONT_COLOR = { r = 0.5, g = 0.5, b = 0.5 } end
if not HIGHLIGHT_FONT_COLOR then HIGHLIGHT_FONT_COLOR = { r = 1.0, g = 1.0, b = 1.0 } end

if not OptionsFrame_EnableCheckBox then
	function OptionsFrame_EnableCheckBox(checkBox, noColor)
		if not checkBox then return end
		if checkBox.Enable then checkBox:Enable() elseif checkBox.SetEnabled then checkBox:SetEnabled(true) end
		if ( not noColor ) then
			local text = getglobal(checkBox:GetName().."Text");
			if text then
				text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
		end
	end
end

if not OptionsFrame_DisableCheckBox then
	function OptionsFrame_DisableCheckBox(checkBox, noColor)
		if not checkBox then return end
		if checkBox.Disable then checkBox:Disable() elseif checkBox.SetEnabled then checkBox:SetEnabled(false) end
		if ( not noColor ) then
			local text = getglobal(checkBox:GetName().."Text");
			if text then
				text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
		end
	end
end

if not OptionsFrame_EnableSlider then
	function OptionsFrame_EnableSlider(slider)
		if not slider then return end
		if slider.Enable then slider:Enable() elseif slider.SetEnabled then slider:SetEnabled(true) end
		local name = slider:GetName();
		local text = getglobal(name.."Text");
		local low = getglobal(name.."Low");
		local high = getglobal(name.."High");
		if text then text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b); end
		if low then low:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b); end
		if high then high:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b); end
	end
end

if not OptionsFrame_DisableSlider then
	function OptionsFrame_DisableSlider(slider)
		if not slider then return end
		if slider.Disable then slider:Disable() elseif slider.SetEnabled then slider:SetEnabled(false) end
		local name = slider:GetName();
		local text = getglobal(name.."Text");
		local low = getglobal(name.."Low");
		local high = getglobal(name.."High");
		if text then text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b); end
		if low then low:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b); end
		if high then high:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b); end
	end
end

-- 选项界面控件定义
-- 从 localization 构建表格
DEXOptionsFrameCheckButtons = {};
for key, data in pairs(DEX_LANG_CHECKBOX) do
    DEXOptionsFrameCheckButtons[key] = { title = data.title, tooltipText = data.tooltip };
end

DEXOptionsFrameSliders = {
    ["DEX_Font"] = { title = DEX_LANG_SLIDER["DEX_Font"].title, minValue = 1, maxValue = 3, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_Font"].min, maxText = DEX_LANG_SLIDER["DEX_Font"].max, tooltipText = DEX_LANG_SLIDER["DEX_Font"].tooltip },
    ["DEX_FontSize"] = { title = DEX_LANG_SLIDER["DEX_FontSize"].title, minValue = 12, maxValue = 55, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_FontSize"].min, maxText = DEX_LANG_SLIDER["DEX_FontSize"].max, tooltipText = DEX_LANG_SLIDER["DEX_FontSize"].tooltip },
    ["DEX_OutLine"] = { title = DEX_LANG_SLIDER["DEX_OutLine"].title, minValue = 1, maxValue = 5, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_OutLine"].min, maxText = DEX_LANG_SLIDER["DEX_OutLine"].max, tooltipText = DEX_LANG_SLIDER["DEX_OutLine"].tooltip },
    ["DEX_Speed"] = { title = DEX_LANG_SLIDER["DEX_Speed"].title, minValue = 50, maxValue = 300, valueStep = 5, minText = DEX_LANG_SLIDER["DEX_Speed"].min, maxText = DEX_LANG_SLIDER["DEX_Speed"].max, tooltipText = DEX_LANG_SLIDER["DEX_Speed"].tooltip },
    ["DEX_ScrollHeight"] = { title = DEX_LANG_SLIDER["DEX_ScrollHeight"].title, minValue = 5, maxValue = 20, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_ScrollHeight"].min, maxText = DEX_LANG_SLIDER["DEX_ScrollHeight"].max, tooltipText = DEX_LANG_SLIDER["DEX_ScrollHeight"].tooltip },
    ["DEX_LOGLINE"] = { title = DEX_LANG_SLIDER["DEX_LOGLINE"].title, minValue = 20, maxValue = 100, valueStep = 5, minText = DEX_LANG_SLIDER["DEX_LOGLINE"].min, maxText = DEX_LANG_SLIDER["DEX_LOGLINE"].max, tooltipText = DEX_LANG_SLIDER["DEX_LOGLINE"].tooltip },
    ["DEX_AnimHeight"] = { title = DEX_LANG_SLIDER["DEX_AnimHeight"].title, minValue = 100, maxValue = 800, valueStep = 10, minText = DEX_LANG_SLIDER["DEX_AnimHeight"].min, maxText = DEX_LANG_SLIDER["DEX_AnimHeight"].max, tooltipText = DEX_LANG_SLIDER["DEX_AnimHeight"].tooltip },
    ["DEX_NameplateOffsetX"] = { title = DEX_LANG_SLIDER["DEX_NameplateOffsetX"].title, minValue = -200, maxValue = 200, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_NameplateOffsetX"].min, maxText = DEX_LANG_SLIDER["DEX_NameplateOffsetX"].max, tooltipText = DEX_LANG_SLIDER["DEX_NameplateOffsetX"].tooltip },
    ["DEX_NameplateOffsetY"] = { title = DEX_LANG_SLIDER["DEX_NameplateOffsetY"].title, minValue = -200, maxValue = 200, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_NameplateOffsetY"].min, maxText = DEX_LANG_SLIDER["DEX_NameplateOffsetY"].max, tooltipText = DEX_LANG_SLIDER["DEX_NameplateOffsetY"].tooltip },
    ["DEX_TrajectoryOutgoing"] = { title = DEX_LANG_SLIDER["DEX_TrajectoryOutgoing"].title, minValue = 1, maxValue = 7, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_TrajectoryOutgoing"].min, maxText = DEX_LANG_SLIDER["DEX_TrajectoryOutgoing"].max, tooltipText = DEX_LANG_SLIDER["DEX_TrajectoryOutgoing"].tooltip },
    ["DEX_TrajectoryIncoming"] = { title = DEX_LANG_SLIDER["DEX_TrajectoryIncoming"].title, minValue = 1, maxValue = 7, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_TrajectoryIncoming"].min, maxText = DEX_LANG_SLIDER["DEX_TrajectoryIncoming"].max, tooltipText = DEX_LANG_SLIDER["DEX_TrajectoryIncoming"].tooltip },
    ["DEX_TrajectorySideDir"] = { title = DEX_LANG_SLIDER["DEX_TrajectorySideDir"].title, minValue = 1, maxValue = 5, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_TrajectorySideDir"].min, maxText = DEX_LANG_SLIDER["DEX_TrajectorySideDir"].max, tooltipText = DEX_LANG_SLIDER["DEX_TrajectorySideDir"].tooltip },
    ["DEX_TrajectoryEnergize"] = { title = DEX_LANG_SLIDER["DEX_TrajectoryEnergize"].title, minValue = 1, maxValue = 7, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_TrajectoryEnergize"].min, maxText = DEX_LANG_SLIDER["DEX_TrajectoryEnergize"].max, tooltipText = DEX_LANG_SLIDER["DEX_TrajectoryEnergize"].tooltip },
    ["DEX_TargetLineSize"] = { title = DEX_LANG_SLIDER["DEX_TargetLineSize"].title, minValue = 1, maxValue = 8, valueStep = 1, minText = DEX_LANG_SLIDER["DEX_TargetLineSize"].min, maxText = DEX_LANG_SLIDER["DEX_TargetLineSize"].max, tooltipText = DEX_LANG_SLIDER["DEX_TargetLineSize"].tooltip },
};

DEXOptionsColorPickerEx = {};
for key, data in pairs(DEX_LANG_COLORPICKER) do
    DEXOptionsColorPickerEx[key] = { title = data };
end

-- 颜色设置回调函数
local DEXOptionsFrame_SetColorFunc = {
    ["DEX_ColorNormal"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorNormal") end,
    ["DEX_ColorNormalSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorNormalSe") end,
    ["DEX_ColorSkill"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorSkill") end,
    ["DEX_ColorSkillSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorSkillSe") end,
    ["DEX_ColorPeriodic"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorPeriodic") end,
    ["DEX_ColorPeriodicSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorPeriodicSe") end,
    ["DEX_ColorHealth"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorHealth") end,
    ["DEX_ColorHealthSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorHealthSe") end,
    ["DEX_ColorSpec"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorSpec") end,
    ["DEX_ColorSpecSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorSpecSe") end,
    ["DEX_ColorMana"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorMana") end,
    ["DEX_ColorManaSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorManaSe") end,
    ["DEX_ColorPet"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorPet") end,
    ["DEX_ColorPetSe"] = function(x) DEXOptionsFrame_SetColor("DEX_ColorPetSe") end,
    ["DEX_TargetLineColor"] = function(x) DEXOptionsFrame_SetColor("DEX_TargetLineColor") end,
};  

local DEXOptionsFrame_CancelColorFunc = {
    ["DEX_ColorNormal"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorNormal",x) end,
    ["DEX_ColorNormalSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorNormalSe",x) end,
    ["DEX_ColorSkill"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorSkill",x) end,
    ["DEX_ColorSkillSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorSkillSe",x) end,
    ["DEX_ColorPeriodic"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorPeriodic",x) end,
    ["DEX_ColorPeriodicSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorPeriodicSe",x) end,
    ["DEX_ColorHealth"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorHealth",x) end,
    ["DEX_ColorHealthSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorHealthSe",x) end,
    ["DEX_ColorSpec"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorSpec",x) end,
    ["DEX_ColorSpecSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorSpecSe",x) end,
    ["DEX_ColorMana"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorMana",x) end,
    ["DEX_ColorManaSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorManaSe",x) end,
    ["DEX_ColorPet"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorPet",x) end,
    ["DEX_ColorPetSe"] = function(x) DEXOptionsFrame_CancelColor("DEX_ColorPetSe",x) end,
    ["DEX_TargetLineColor"] = function(x) DEXOptionsFrame_CancelColor("DEX_TargetLineColor",x) end,
};  

-- 刷新复选框状态
function DEX_RefreshCheckButton(name)
    local button = getglobal(name);
    if not button then return; end

    local str = getglobal(name.."Text");
    local checked;

    if ( DEX_Get(name) == 1 ) then
        checked = 1;
    else
        checked = 0;
    end 
    OptionsFrame_EnableCheckBox(button);
    button:SetChecked(checked);
    str:SetText(DEXOptionsFrameCheckButtons[name].title);
    button.tooltipText = DEXOptionsFrameCheckButtons[name].tooltipText;   
    DEX_CheckButtonLink(name);
end

-- 复选框联动逻辑
function DEX_CheckButtonLink(name)
    if name == "DEX_ShowSpellName" then      
        if DEX_Get(name) == 1 then
            OptionsFrame_EnableCheckBox(getglobal("DEX_ShowNameOnCrit"));
            DEX_RefreshCheckButton("DEX_ShowNameOnCrit");
            OptionsFrame_EnableCheckBox(getglobal("DEX_ShowNameOnMiss"));
            DEX_RefreshCheckButton("DEX_ShowNameOnMiss");
        else
            OptionsFrame_DisableCheckBox(getglobal("DEX_ShowNameOnCrit"));
            OptionsFrame_DisableCheckBox(getglobal("DEX_ShowNameOnMiss"));
        end
    end

    if name == "DEX_ShowWithMess" then      
        if DEX_Get(name) == 1 then
            OptionsFrame_DisableSlider(getglobal("DEX_LOGLINE"));
            OptionsFrame_DisableSlider(getglobal("DEX_Speed"));
            OptionsFrame_DisableSlider(getglobal("DEX_AnimHeight"));
            OptionsFrame_DisableSlider(getglobal("DEX_ScrollHeight"));
            local attachCheck = getglobal("DEX_AttachNameplate")
            if attachCheck then
                OptionsFrame_DisableCheckBox(attachCheck);
                attachCheck:SetChecked(0);
            end
            DEX_Set("DEX_AttachNameplate", 0);
            OptionsFrame_DisableSlider(getglobal("DEX_NameplateOffsetX"));
            OptionsFrame_DisableSlider(getglobal("DEX_NameplateOffsetY"));
            OptionsFrame_DisableSlider(getglobal("DEX_TrajectoryEnergize"));
        else
            OptionsFrame_EnableSlider(getglobal("DEX_LOGLINE"));
            DEX_RefreshFrameSliders("DEX_LOGLINE");
            OptionsFrame_EnableSlider(getglobal("DEX_Speed"));
            DEX_RefreshFrameSliders("DEX_Speed");
            OptionsFrame_EnableSlider(getglobal("DEX_AnimHeight"));
            DEX_RefreshFrameSliders("DEX_AnimHeight");
            OptionsFrame_EnableSlider(getglobal("DEX_ScrollHeight"));
            DEX_RefreshFrameSliders("DEX_ScrollHeight");
            local attachCheck = getglobal("DEX_AttachNameplate")
            if attachCheck then
                OptionsFrame_EnableCheckBox(attachCheck);
                DEX_RefreshCheckButton("DEX_AttachNameplate");
            end
            if DEX_Get("DEX_AttachNameplate") == 1 then
                OptionsFrame_EnableSlider(getglobal("DEX_NameplateOffsetX"));
                OptionsFrame_EnableSlider(getglobal("DEX_NameplateOffsetY"));
            else
                OptionsFrame_DisableSlider(getglobal("DEX_NameplateOffsetX"));
                OptionsFrame_DisableSlider(getglobal("DEX_NameplateOffsetY"));
            end
            if DEX_Get("DEX_ShowEnergize") == 1 then
                OptionsFrame_EnableSlider(getglobal("DEX_TrajectoryEnergize"));
                DEX_RefreshFrameSliders("DEX_TrajectoryEnergize");
            else
                OptionsFrame_DisableSlider(getglobal("DEX_TrajectoryEnergize"));
            end
        end
    end
    if name == "DEX_AttachNameplate" then
        local sliderX = getglobal("DEX_NameplateOffsetX")
        local sliderY = getglobal("DEX_NameplateOffsetY")
        if DEX_Get("DEX_AttachNameplate") == 1 and DEX_Get("DEX_ShowWithMess") == 0 then
            if sliderX then OptionsFrame_EnableSlider(sliderX); DEX_RefreshFrameSliders("DEX_NameplateOffsetX"); end
            if sliderY then OptionsFrame_EnableSlider(sliderY); DEX_RefreshFrameSliders("DEX_NameplateOffsetY"); end
        else
            if sliderX then OptionsFrame_DisableSlider(sliderX); end
            if sliderY then OptionsFrame_DisableSlider(sliderY); end
        end
    end

    if name == "DEX_ShowEnergize" then
        local slider = getglobal("DEX_TrajectoryEnergize");
        if DEX_Get(name) == 1 and DEX_Get("DEX_ShowWithMess") == 0 then
            OptionsFrame_EnableSlider(slider);
            DEX_RefreshFrameSliders("DEX_TrajectoryEnergize");
        else
            OptionsFrame_DisableSlider(slider);
        end
    end
end

-- 配置颜色选择器
function DEX_ConfigColorPicker(name)
    local frame,swatch,sRed,sGreen,sBlue,sColor;

    frame = getglobal(name);
    if not frame then return; end

    swatch = getglobal(name.."_ColorSwatchNormalTexture");

    sColor = DEX_Get(name);
    if not sColor then return; end

    sRed = sColor[1];
    sGreen = sColor[2];
    sBlue = sColor[3];

    frame.r = sRed;
    frame.g = sGreen;
    frame.b = sBlue;
    frame.swatchFunc = DEXOptionsFrame_SetColorFunc[name];
    frame.cancelFunc = DEXOptionsFrame_CancelColorFunc[name];
    swatch:SetVertexColor(sRed,sGreen,sBlue);
end

function DEX_RefreshColorPickerEx(name)
    local str = getglobal(name.."_Text");
    str:SetText(DEXOptionsColorPickerEx[name].title);
    DEX_ConfigColorPicker(name);    
end

-- 刷新滑块
function DEX_RefreshFrameSliders(name)
    local slider = getglobal(name);
    if not slider then return end

    local str = getglobal(name.."Text");
    local low = getglobal(name.."Low");
    local high = getglobal(name.."High");

    local value = DEXOptionsFrameSliders[name];
    if not value then return end

    OptionsFrame_EnableSlider(slider);
    slider:SetMinMaxValues(value.minValue, value.maxValue);
    slider:SetValueStep(value.valueStep);
    slider:SetValue( DEX_Get(name) );
    str:SetText(value.title);
    low:SetText(value.minText);
    high:SetText(value.maxText);
    slider.tooltipText = value.tooltipText;

    DEX_OptionsSliderRefreshTitle(name);
end

-- 选项界面显示时刷新所有控件
function DEXOptionsFrame_OnShow()
    for key, value in DEXOptionsFrameCheckButtons do      
        DEX_RefreshCheckButton(key);
    end

    for key, value in DEXOptionsFrameSliders do
        DEX_RefreshFrameSliders(key);
    end

    for key, value in DEXOptionsColorPickerEx do
        DEX_RefreshColorPickerEx(key);
    end   

    -- 设置动态文本
    local colorModeLabel = getglobal("DEXOptionsDropDownCatsLabel");
    if colorModeLabel then colorModeLabel:SetText(DEX_LANG_COLORMODE_LABEL); end

    local preBoxTitle = getglobal("DEX_PreBox_Title");
    if preBoxTitle then preBoxTitle:SetText(DEX_LANG_PREBOX_OUTGOING); end

    local incomingPreBoxTitle = getglobal("DEX_IncomingPreBox_Title");
    if incomingPreBoxTitle then incomingPreBoxTitle:SetText(DEX_LANG_PREBOX_INCOMING); end

    local closeButton = getglobal("DEXOptionsSave");
    if closeButton then closeButton:SetText(DEX_LANG_CLOSE); end

    local resetButton = getglobal("DEXOptionsReset");
    if resetButton then resetButton:SetText(DEX_BUTTON_RESET_LABEL); end

    local title = getglobal("DEXOptionsTitle");
    if title then title:SetText(DEX_MAIN_OPTION); end
end

-- 设置颜色值
function DEXOptionsFrame_SetColor(name)
    local r,g,b = ColorPickerFrame:GetColorRGB();
    local swatch,frame;
    swatch = getglobal(name.."_ColorSwatchNormalTexture");
    frame = getglobal(name);
    swatch:SetVertexColor(r,g,b);
    frame.r = r;
    frame.g = g;
    frame.b = b;
    DEX_Set(name, {r, g, b})
end

-- 取消颜色选择
function DEXOptionsFrame_CancelColor(name, prev)
    local r = prev.r;
    local g = prev.g;
    local b = prev.b;
    local swatch, frame;
    swatch = getglobal(name.."_ColorSwatchNormalTexture");
    frame = getglobal(name);
    swatch:SetVertexColor(r, g, b);
    frame.r = r;
    frame.g = g;
    frame.b = b;
    DEX_Set(name, {r, g, b})
end

-- 更新滑块标题显示
function DEX_OptionsSliderRefreshTitle(name)
    local slider = getglobal(name);
    if not slider then return end

    local str = getglobal(name.."Text");
    local txt;
    local val = slider:GetValue();
    if name == "ANIMATIONSPEED" then
        txt = format("0.0%d",val * 1000);
    elseif name == "DEX_LOGLINE" then
        txt = format(DEX_LANG_LOGLINE_FORMAT, val / 10);
    elseif name == "DEX_TrajectoryOutgoing" or name == "DEX_TrajectoryIncoming" or name == "DEX_TrajectoryEnergize" then
        txt = DEX_LANG_TRAJECTORY_NAMES[val] or val;
    elseif name == "DEX_TrajectorySideDir" then
        txt = DEX_LANG_SIDEDIR_NAMES[val] or val;
    else
        txt = val;
    end 
    str:SetText(DEXOptionsFrameSliders[name].title..": "..txt);
end

-- 滑块值改变时保存
function DEX_OptionsSliderOnValueChanged(name)
    local slider = getglobal(name);
    local value = slider:GetValue();
    DEX_Set(name, value);

    if name == "DEX_FontSize" or name == "DEX_Font" or name == "DEX_OutLine" then
        DEX_TEXTSIZE = DEX_Get("DEX_FontSize");
        DEX_aniInit();
    end

    if name == "DEX_TargetLineSize" and TargetLine_UpdateStyle then
        TargetLine_UpdateStyle()
    end

    if name == "DEX_TargetLineColor" and TargetLine_UpdateStyle then
        TargetLine_UpdateStyle()
    end

    DEX_OptionsSliderRefreshTitle(name);
end

-- 复选框点击事件
function DEX_OptionsCheckButtonOnClick(name)
    local button = getglobal(name);
    local val = button:GetChecked() and 1 or 0

    DEX_Set(name,val);
    DEX_CheckButtonLink(name);
end

-- 打开颜色选择器
function DEX_OpenColorPicker(button)
    CloseMenus();
    if ( not button ) then
        button = this;
    end
    ColorPickerFrame.func = button.swatchFunc;
    ColorPickerFrame:SetColorRGB(button.r, button.g, button.b);
    ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity};
    ColorPickerFrame.cancelFunc = button.cancelFunc;
    ColorPickerFrame:Show();
end

-- 鼠标事件：用于移动预览框
function DEX_MouseUp()   
    if ( this.isMoving ) then
        this:StopMovingOrSizing();
        this.isMoving = false;      
    end
end

function DEX_MouseDown(button)    
    if button == "LeftButton" then
        this:StartMoving();
        this.isMoving = true;       
    end
end

function DEX_preMouseUp()   
    if ( this.isMoving ) then
        this:StopMovingOrSizing();
        this.isMoving = false;
        local x,y = this:GetCenter();
        x = x - GetScreenWidth() / 2;
        y = y - GetScreenHeight() / 2;
        DEX_Set("DEX_PosX",x);
        DEX_Set("DEX_PosY",y);  
    end
end

function DEX_preMouseDown(button)
    if button == "LeftButton" then
        this:StartMoving();
        this.isMoving = true;       
    end
end

function DEX_incomingPreMouseUp()   
    if ( this.isMoving ) then
        this:StopMovingOrSizing();
        this.isMoving = false;
        local x,y = this:GetCenter();
        x = x - GetScreenWidth() / 2;
        y = y - GetScreenHeight() / 2;
        DEX_Set("DEX_IncomingPosX",x);
        DEX_Set("DEX_IncomingPosY",y);  
    end
end

function DEX_incomingPreMouseDown(button)
    if button == "LeftButton" then
        this:StartMoving();
        this.isMoving = true;       
    end
end

-- 显示设置界面
function DEX_showMenu()
    PlaySound("igMainMenuOpen");
    ShowUIPanel(DEXOptions);    

    local pre = getglobal("DEX_PreBox");
    pre:ClearAllPoints();
    pre:SetPoint("CENTER", "UIParent", "CENTER", DEX_Get("DEX_PosX"), DEX_Get("DEX_PosY"));
    pre:Show();

    local incomingPre = getglobal("DEX_IncomingPreBox");
    incomingPre:ClearAllPoints();
    incomingPre:SetPoint("CENTER", "UIParent", "CENTER", DEX_Get("DEX_IncomingPosX"), DEX_Get("DEX_IncomingPosY"));
    incomingPre:Show();

    DEX_CheckButtonLink("DEX_ShowSpellName");
    DEX_CheckButtonLink("DEX_ShowWithMess");
end

-- 隐藏设置界面
function DEX_hideMenu()
    PlaySound("igMainMenuClose");
    HideUIPanel(DEXOptions);

    local pre = getglobal("DEX_PreBox");
    pre:Hide();

    local incomingPre = getglobal("DEX_IncomingPreBox");
    incomingPre:Hide();

    if(MYADDONS_ACTIVE_OPTIONSFRAME == DEXOptions) then
        ShowUIPanel(myAddOnsFrame);
    end
    DEX_aniInit();
    DEX_staticInit();
end

-- 颜色模式下拉菜单初始化
function DEXOptionsFrameDropDownCats_Initialize()
    local info;
    for i = 1, 4 do
        info = {
            text = DEXOptionsDropDown[i];
            func = DEXOptionsFrameDropDownCats_OnClick;
        };
        UIDropDownMenu_AddButton(info);
    end
end

function DEXOptionsFrameDropDownCats_OnShow()
    UIDropDownMenu_Initialize(DEXOptionsDropDownCats, DEXOptionsFrameDropDownCats_Initialize)
    UIDropDownMenu_SetSelectedID(DEXOptionsDropDownCats, DEX_Get("DEX_ColorMode"))
    UIDropDownMenu_SetWidth(100, DEXOptionsDropDownCats)
end

function DEXOptionsFrameDropDownCats_OnClick()
    local thisID = this:GetID()
    UIDropDownMenu_SetSelectedID(DEXOptionsDropDownCats, thisID)
    DEX_Set("DEX_ColorMode", thisID)
end