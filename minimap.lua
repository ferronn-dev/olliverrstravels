local _, G = ...
assert(not G.Minimap)
G.Minimap = {}

local DATA_NAME = 'OlliverrsTravelsMinimapIconData'
local ICON_NAME = 'OlliverrsTravelsMinimapIcon'

function G.Minimap.Register()
  local ldb = LibStub('LibDataBroker-1.1')
  local dbi = LibStub('LibDBIcon-1.0')
  local data = ldb:NewDataObject(DATA_NAME, {
    type = 'launcher',
    label = 'Olliverr\'s Travels',
    icon = 'Interface\\Icons\\Ability_Hunter_BeastCall02',
    OnTooltipShow = function(tooltip)
      tooltip:AddLine('Olliverr\'s Travels')
      local data = G.DB.ZoneData[G.Lib.CurrentZoneID()]
      if data == nil then
        tooltip:AddLine('No data for this map', 0.4, 0.4, 0.4)
      else
        for _, v in ipairs(data) do
          local skill, rank, beast, lo, hi = unpack(v)
          local lvls = lo == hi and lo or lo .. '-' .. hi
          local r, g, b = nil, nil, nil
          if G.State.HasSkill(skill, rank) then
            r, g, b = 0.4, 0.4, 0.4
          elseif UnitLevel('player') < lo then
            r, g, b = 1.0, 0.0, 0.0
          end
          tooltip:AddDoubleLine(
            string.format('%s (%s)', G.DB.CreatureNames[beast], lvls),
            string.format('%s %s', G.DB.AbilityNames[skill], rank),
            r,
            g,
            b,
            r,
            g,
            b
          )
        end
      end
      tooltip:AddLine('---------------------')
      local missing = {}
      local keys = {}
      for i = 1, UnitLevel('player') do
        for _, v in ipairs(G.DB.ZoneLevelData[i]) do
          local skill, rank, zone = unpack(v)
          if not G.State.HasSkill(skill, rank) then
            local key = G.DB.AbilityNames[skill] .. ' ' .. rank
            if missing[key] == nil then
              missing[key] = {}
              table.insert(keys, key)
            end
            table.insert(missing[key], G.Lib.ZoneName(zone))
          end
        end
      end
      table.sort(keys)
      for _, k in ipairs(keys) do
        table.sort(missing[k])
        tooltip:AddDoubleLine(table.concat(missing[k], ', '), k)
      end
    end,
  })
  dbi:Register(ICON_NAME, data, { hide = false })
  dbi:ShowOnEnter(ICON_NAME, false)
end
