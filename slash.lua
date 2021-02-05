local _, G = ...
assert(not G.Slash)
G.Slash = {}

-- Registers the dispatch on /olli.
function G.Slash.Register()
  G.Core.RegisterSlashCommand({'/olli'}, 'OLLIVERRSTRAVELS', function(msg)
    if msg ~= 'Register' and G.Slash[msg] ~= nil then
      G.Slash[msg]()
    else
      print('Type "/olli help" for usage.')
    end
  end)
end

-- Prints a help message.
function G.Slash.help()
  print('Olliverr\'s Travels in Classic WoW')
  print(' help - this help message')
  print(' here - beasts worth taming in this zone')
  print(' all - all zones with abilities to learn')
end

-- Prints the tameable beasts in this zone.
function G.Slash.here()
  local data = G.DB.ZoneData[G.Lib.CurrentZoneID()]
  if data == nil then
    print('No data for this map.')
  else
    local k = 0
    for _, v in ipairs(data) do
      local skill, rank, beast, lo, hi = unpack(v)
      if not G.State.HasSkill(skill, rank) then
        local lvls = lo == hi and lo or lo .. '-' .. hi
        print(string.format('%s (%s): %s %s',
            G.DB.CreatureNames[beast], lvls, G.DB.AbilityNames[skill], rank))
        k = k + 1
      end
    end
    if k == 0 then
      print('You are done in this zone.')
    end
  end
end

-- Prints the zones with tameable beasts.
function G.Slash.all()
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
    print(k .. ': ' .. table.concat(missing[k], ', '))
  end
end
