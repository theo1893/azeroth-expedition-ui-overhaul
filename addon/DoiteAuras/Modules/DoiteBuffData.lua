local DoiteBuffData = {
  -- 使用 spellId 作为键，以避免必须查找 UNIT_CASTEVENT 法术名称

  -- 在此列出修改其他 BUFF 层数的法术。同一法术的层数增加已处理。
  -- 如果法术添加/创建/刷新另一个增益，请务必包含一个持续时间。
  stackModifiers = {
    -- 法师 --
    [11366] = { -- 炎爆术 rk 1
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12505] = {  -- 炎爆术 rk 2
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12522] = {  -- 炎爆术 rk 3
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12523] = {  -- 炎爆术 rk 4
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12524] = {  -- 炎爆术 rk 5
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12525] = {  -- 炎爆术 rk 6
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [12526] = {  -- 炎爆术 rk 7
      modifiedBuffName = "法术连击",
      stackChange = -5
    },
    [18809] = {  -- 炎爆术 rk 8
      modifiedBuffName = "法术连击",
      stackChange = -5
    },

    -- 萨满 --
    [51387] = {  -- 闪电打击 rk 1
      modifiedBuffName = "闪电之盾",
      stackChange = -1
    },
    [52420] = {  -- 闪电打击 rk 2
      modifiedBuffName = "闪电之盾",
      stackChange = -1
    },
    [52422] = {  -- 闪电打击 rk 3
      modifiedBuffName = "闪电之盾",
      stackChange = -1
    },

    -- 德鲁伊 --
    [5176] = {  -- 愤怒 rk 1
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [5177] = {  -- 愤怒 rk 2
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [5178] = {  -- 愤怒 rk 3
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [5179] = {  -- 愤怒 rk 4
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [5180] = {  -- 愤怒 rk 5
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [6780] = {  -- 愤怒 rk 6
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [8905] = {  -- 愤怒 rk 7
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [9912] = {  -- 愤怒 rk 8
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [45967] = {  -- 愤怒 rk 9
      modifiedBuffName = "自然恩赐",
      stackChange = -1
    },
    [2912] = {  -- 星火术 rk 1
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [8949] = {  -- 星火术 rk 2
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [8950] = {  -- 星火术 rk 3
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [8951] = {  -- 星火术 rk 4
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [9875] = {  -- 星火术 rk 5
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [9876] = {  -- 星火术 rk 6
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
    [25298] = {  -- 星火术 rk 7
      modifiedBuffName = "星界恩赐",
      stackChange = -1
    },
  }
}
_G["DoiteBuffData"] = DoiteBuffData