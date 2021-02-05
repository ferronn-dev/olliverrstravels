-- Addons are loaded with two arguments: addon name, and addon table.
-- We use the addon table to share data across lua files within the addon
-- without polluting the global environment.
local _, G = ...

-- Don't bother loading further if the character is not a hunter.
if select(3, UnitClass('player')) ~= 3 then
  return
end

G.Slash.Register()
G.Event.Register()
G.Minimap.Register()
