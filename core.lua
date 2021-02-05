local _, G = ...
assert(not G.Core)
G.Core = {}

-- Registering a slash command is funny business---it requires a globally
-- unique variable name and globally unique slash command names. For this
-- addon we just jump in head first and hope for the best.
function G.Core.RegisterSlashCommand(slashes, var, func)
  for i, slash in ipairs(slashes) do
    _G['SLASH_' .. var .. i] = slash
  end
  SlashCmdList[var] = func
end

-- Creats a frame that listens for events named for the members of [events],
-- and dispatches to those functions.
function G.Core.RegisterEventHandlers(events)
  local frame = CreateFrame('Frame')
  frame:SetScript('OnEvent', function(self, event, ...)
    events[event](...)
  end)
  for k, v in pairs(events) do
    frame:RegisterEvent(k)
  end
end
