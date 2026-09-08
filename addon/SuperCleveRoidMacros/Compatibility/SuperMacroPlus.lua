-- SuperMacroPlus compatibility for CleveRoidMacros (WoW 1.12.1 / Lua 5.0).
--
-- SuperMacroPlus has its own line runner and categorized macro store, so the
-- original SuperMacro compatibility module cannot see or execute Plus-only
-- macros.  Keep this hook separate so both addons may be enabled together.

do
  local _G = _G or getfenv(0)
  local CRM = _G.CleveRoids or {}
  _G.CleveRoids = CRM
  CRM.Hooks = CRM.Hooks or {}

  local INTERCEPT = {
    cast=true, castsequence=true, use=true,
    startattack=true, stopattack=true, stopcasting=true, stopmacro=true,
    skipmacro=true, firstaction=true, nofirstaction=true,
    target=true, retarget=true, cancelaura=true, unbuff=true,
    unqueue=true, unshift=true, equip=true, equipmh=true, equipoh=true,
    petattack=true, petfollow=true, petpassive=true,
    petaggressive=true, petdefensive=true, petwait=true,
    quickheal=true, qh=true,
    castpet=true, cleartarget=true,
    applymain=true, applyoff=true,
    ["equip11"]=true, ["equip12"]=true,
    ["equip13"]=true, ["equip14"]=true,
  }

  local function has_handler(cmd)
    local list = _G.SlashCmdList
    return cmd and list and type(list[string.upper(cmd)]) == "function"
  end

  local function reset_macro_flags()
    CRM.stopMacroFlag = false
    CRM.skipMacroFlag = false
    CRM.stopOnCastFlag = false
  end

  local function clear_plus_cache(name, oldName)
    -- Parsed native/Plus macros may contain nested macro references, so a
    -- targeted entry eviction is not sufficient. Clear both lightweight
    -- caches and let the normal action-bar queries rebuild them lazily.
    CRM.Macros = {}
    CRM.Actions = {}

    if type(CRM.QueueActionUpdate) == "function" then
      CRM.QueueActionUpdate()
    end
  end

  -- Called by SuperMacroPlus whenever a Plus macro or its spell cache changes.
  CRM.OnSuperMacroPlusChanged = clear_plus_cache

  local function install_supermacroplus_hook()
    if CRM.SMP_RunLineHooked then return end
    if type(_G.SMP_RunLine) ~= "function" then return end

    local orig_SMP_RunLine = _G.SMP_RunLine
    CRM.Hooks.SMP_RunLine = CRM.Hooks.SMP_RunLine or orig_SMP_RunLine

    _G.SMP_RunLine = function(...)
      local text = arg and arg[1]
      local inspectText = text

      -- SMP_RunLine normally applies the low-priority alias chain before
      -- dispatching a slash command. Do the same for lines CRM intercepts;
      -- keep the original text for the fallback runner to avoid double work.
      if type(text) == "string" and type(_G.SMP_ReplaceAlias) == "function" then
        local ok, replaced = pcall(_G.SMP_ReplaceAlias, text, -1)
        if ok and type(replaced) == "string" then inspectText = replaced end
      end

      -- SuperMacroPlus supports Lua-style comment lines; leave them untouched.
      if type(inspectText) == "string" and string.find(inspectText, "^%s*%-%-") then
        return orig_SMP_RunLine(text)
      end

      -- /nofirstaction must be allowed to clear the stop state created by
      -- /firstaction before the generic stop check below.
      if type(inspectText) == "string" then
        local _, _, nofirstactionArgs = string.find(inspectText, "^%s*/nofirstaction%s*(.*)")
        if nofirstactionArgs then
          local wasFirstActionActive = CRM.stopOnCastFlag
          if type(CRM.DoNoFirstAction) == "function" then
            pcall(CRM.DoNoFirstAction, nofirstactionArgs or "")
          end
          if wasFirstActionActive and CRM.stopMacroFlag then
            CRM.stopMacroFlag = false
          end
          return true
        end
      end

      if CRM.stopMacroFlag or CRM.skipMacroFlag then
        return true
      end

      if type(inspectText) == "string" then
        local b, _, rest = string.find(inspectText, "^%s*/castsequence%s*(.*)")
        if b then
          if type(CRM.DoCastSequence) == "function" then
            pcall(CRM.DoCastSequence, rest or "")
            return true
          end
          local fn = _G.SlashCmdList and _G.SlashCmdList["CASTSEQUENCE"]
          if type(fn) == "function" then
            pcall(fn, rest or "")
            return true
          end
        else
          local _, _, raw, msg = string.find(inspectText, "^%s*/(%S+)%s*(.*)$")
          if raw then
            local cmd = string.lower(raw)
            if cmd == "unbuff" then cmd = "cancelaura" end
            if INTERCEPT[cmd] and has_handler(cmd) then
              pcall(_G.SlashCmdList[string.upper(cmd)], msg or "")
              return true
            end
          end

          local hooks = { cast=CRM.DoCast, target=CRM.DoTarget, use=CRM.DoUse }
          for command, fn in pairs(hooks) do
            if type(fn) == "function" then
              local beginAt, endAt = string.find(inspectText, "^%s*/" .. command .. "%s+[!%[%{%?~]")
              if beginAt then
                local msg2 = string.gsub(string.sub(inspectText, endAt), "^%s+", "")
                pcall(fn, msg2)
                return true
              end
            end
          end
        end
      end

      return orig_SMP_RunLine(text)
    end

    CRM.SMP_RunLineHooked = true

    if type(_G.SuperMacroPlus_RunMacro) == "function" then
      local originalRegular = _G.SuperMacroPlus_RunMacro
      CRM.Hooks.SuperMacroPlus_RunMacro = CRM.Hooks.SuperMacroPlus_RunMacro or originalRegular

      local function hooked_regular(index)
        reset_macro_flags()
        return originalRegular(index)
      end

      _G.SuperMacroPlus_RunMacro = hooked_regular
      if _G.MacroPlus == originalRegular then
        _G.MacroPlus = hooked_regular
      end
    end

    if type(_G.RunSuperMacroPlus) == "function" then
      local originalSuper = _G.RunSuperMacroPlus
      CRM.Hooks.RunSuperMacroPlus = CRM.Hooks.RunSuperMacroPlus or originalSuper

      _G.RunSuperMacroPlus = function(index)
        reset_macro_flags()
        return originalSuper(index)
      end
    end
  end

  local SMP_LOADED, CRM_LOADED = false, false
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:RegisterEvent("PLAYER_LOGIN")

  local function note_loaded(name)
    if name == "SuperMacroPlus" then
      SMP_LOADED = true
    elseif name == "SuperCleveRoidMacros" or name == "CleveRoidMacros" then
      CRM_LOADED = true
    end
  end

  local function both_loaded()
    if SMP_LOADED and CRM_LOADED then return true end
    local plusOK = type(_G.SMP_RunLine) == "function" and
      (type(_G.RunSuperMacroPlus) == "function" or type(_G.SuperMacroPlus_RunMacro) == "function")
    local crmOK = _G.CleveRoids and _G.SlashCmdList and
      type(_G.SlashCmdList.CAST) == "function"
    return plusOK and crmOK
  end

  local function try_install()
    if both_loaded() then install_supermacroplus_hook() end
  end

  frame:SetScript("OnEvent", function()
    local evt = event
    local addon = arg1
    if evt == "ADDON_LOADED" then
      if type(addon) == "string" then note_loaded(addon) end
      try_install()
    elseif evt == "PLAYER_LOGIN" then
      try_install()
    end
  end)

  -- Covers late-loading/reloading scenarios where both APIs already exist.
  try_install()
end
