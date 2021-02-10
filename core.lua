local _, G = ...
assert(not G.Core)
G.Core = {}

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
