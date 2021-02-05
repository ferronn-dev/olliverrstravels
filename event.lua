local addonName, G = ...
assert(not G.Event)
G.Event = {}

local events = {}

function G.Event.Register()
  G.Core.RegisterEventHandlers(events)
end

function events.ADDON_LOADED(name)
  if name == addonName then
    G.State.LoadFromTable(OlliverrsTravelsPlayerData or {})
    OlliverrsTravelsPlayerData = nil
  end
end

function events.CHAT_MSG_SYSTEM(msg)
  local s = msg:match(ERR_LEARN_SPELL_S:gsub('%%s', '(.*)'))
  if s ~= nil then
    local name, rank = s:match('(.*) %(.*(%d+).*%)')
    G.State.AddSkillByName(name, rank)
  end
end

function events.CRAFT_SHOW()
  G.State.ClearSkills()
  for i = 1, GetNumCrafts() do
    local name, rankstr = GetCraftInfo(i)
    local rank = rankstr:match('(%d+)')
    G.State.AddSkillByName(name, rank)
  end
end

function events.PLAYER_LEVEL_UP(newLevel)
  if newLevel < 10 then
    return
  end
  local start, finish = newLevel, newLevel
  if newLevel == 10 then
    start = 1
  end
  local newSkills = {}
  for level = start, finish do
    for _, v in ipairs(G.DB.LevelData[level]) do
      local skill, rank = v[1], v[2]
      table.insert(newSkills, G.DB.AbilityNames[skill] .. ' ' .. rank)
    end
  end
  if #newSkills > 0 then
    table.sort(newSkills)
    print('New trainable skills: ' .. table.concat(newSkills, ', '))
  else
    print('No new trainable skills.')
  end
end

function events.PLAYER_LOGOUT()
  OlliverrsTravelsPlayerData = G.State.SerializeToTable()
end
