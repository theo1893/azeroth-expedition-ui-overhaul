-- 简单的测试命令，确保命令系统正常工作

-- 首先检查pfUI是否存在
if not pfUI then
  pfUI = {}
end

-- 创建简单的测试命令
SLASH_PFTEST1 = "/pftest"
SlashCmdList["PFTEST"] = function(msg)
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "== pfUI 测试命令成功加载 ==")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "命令参数: " .. (msg or "无"))
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "框架buff/debuff过滤功能已优化，支持中文名称识别")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "使用 /pfittest 命令测试详细功能")
end

-- 详细的功能测试命令
SLASH_PFILTERTEST1 = "/pfittest"
SlashCmdList["PFILTERTEST"] = function(msg)
  local target = "player" -- 默认测试玩家自己
  local limit = 5 -- 默认只显示前5个buff
  
  -- 解析命令参数
  if not msg then
    msg = ""
  end
  
  if string.find(msg, "target") then
    target = "target"
  elseif string.find(msg, "raid") then
    target = "raid1"
  end
  
  -- 解析显示数量参数（无论是什么目标都适用）
  local count = tonumber(string.match(msg, "(%d+)"))
  if count then
    limit = count
  end
  
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "== pfUI 过滤功能详细测试 ==")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "目标单位: " .. target)
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "显示前 " .. limit .. " 个buff信息:")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "------------------------------------------------------------------")
  
  -- 测试多个buff
  local found = 0
  for i = 1, 40 do
    if found >= limit then break end
    
    -- 使用GameTooltip获取中文名称
    GameTooltip.SetOwner(GameTooltip, UIParent, "ANCHOR_NONE")
    GameTooltip.SetUnitBuff(GameTooltip, target, i)
    local tooltipName = GameTooltipTextLeft1 and GameTooltipTextLeft1.GetText(GameTooltipTextLeft1) or nil
    GameTooltip.Hide(GameTooltip)
    
    -- 获取UnitBuff返回值 (按照1.12 API的正确顺序)
    local name, rank, icon, count, duration, timeleft, caster = UnitBuff(target, i)
    
    -- 如果有信息，则显示
    if tooltipName then
      found = found + 1
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "Buff #" .. i .. ":")
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  中文名称(GameTooltip): " .. tooltipName)
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  技能名称(UnitBuff): " .. (name or "[空]") .. "")
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  图标路径: " .. (icon or "[空]"))
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  施法者: " .. (caster or "[空]"))
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  用于过滤名单的关键词: " .. tooltipName)
      DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "------------------------------------------------------------------")
    end
  end
  
  -- 如果没找到buff
  if found == 0 then
    DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "未找到任何buff信息。请确保目标单位有活跃的增益效果。")
  end
  
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "使用方法示例:")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  /pfittest           - 测试自己的前5个buff")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  /pfittest target    - 测试目标的前5个buff")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  /pfittest raid      - 测试团队第一个成员的前5个buff")
  DEFAULT_CHAT_FRAME.AddMessage(DEFAULT_CHAT_FRAME, "  /pfittest 10        - 测试自己的前10个buff")
end
