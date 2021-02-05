local _, G = ...
assert(not G.Lib)
G.Lib = {}

function G.Lib.CurrentZoneID()
  if IsInInstance() then
    return 'i' .. select(8, GetInstanceInfo())
  else
    return 'o' .. C_Map.GetBestMapForUnit('player')
  end
end

function G.Lib.ZoneName(zone)
  if zone:sub(1, 1) == 'i' then
    return GetRealZoneText(zone:sub(2))
  else
    return C_Map.GetMapInfo(zone:sub(2)).name
  end
end
