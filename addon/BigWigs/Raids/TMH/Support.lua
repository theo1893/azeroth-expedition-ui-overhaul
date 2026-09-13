-- Resolve this instance's live units instead of donor-specific spawn GUIDs.
function BigWigs.TimbermawUnit(name)
    if UnitName("target") == name then return "target" end
    for i = 1, GetNumRaidMembers() do
        local unit = "raid" .. i .. "target"
        if UnitName(unit) == name then return unit end
    end
end
