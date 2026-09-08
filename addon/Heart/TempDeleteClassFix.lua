-- 修复Heart_GUIDeleteClassButton的OnClick事件处理函数
-- 确保删除方案时也删除对应的_D、_S、_T方案
function Heart_GUIDeleteClassButton_OnClick()
    local classToDelete = Heart_current_class
    if classToDelete then
        Heart_Config["classes"][classToDelete] = nil
        -- 检查并删除对应的_D、_S、_T方案
        if not string.find(classToDelete, "_D$") and not string.find(classToDelete, "_S$") and not string.find(classToDelete, "_T$") then
            if Heart_Config["classes"][classToDelete.."_D"] then
                Heart_Config["classes"][classToDelete.."_D"] = nil
            end
            if Heart_Config["classes"][classToDelete.."_S"] then
                Heart_Config["classes"][classToDelete.."_S"] = nil
            end
            if Heart_Config["classes"][classToDelete.."_T"] then
                Heart_Config["classes"][classToDelete.."_T"] = nil
            end
        end
        Heart_current_class = nil
        Heart_ClassDropDownMenuInitialize()
        Heart_UpdateClassButtons()
    end
end