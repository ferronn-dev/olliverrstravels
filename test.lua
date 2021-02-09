-- Testing environment
local T = {}

function T.Reset()
  T.crafts = {
    {'Bite', '(Rank 1)'},
    {'Natural Armor', '(Rank 5)'},
    {'Growl', '(Rank 3)'},
    {'Bite', '(Rank 2)'},
  }
  T.printed = ''
  T.handlers = {}
  T.inInstance = false
  T.bestMap = 1
  T.playerLevel = 23
  T.locale = 'enUS'
end

function T.SendEvent(ev, ...)
  for _, h in ipairs(T.handlers[ev] or {}) do
    h:GetScript('OnEvent')(h, ev, ...)
  end
end

-- Globals as used by the addon
C_Map = {}

function C_Map.GetBestMapForUnit(unit)
  return T.bestMap
end

function C_Map.GetMapInfo(id)
  return {['name'] = 'o' .. id}
end

local UNIMPLEMENTED = function(...) end

function CreateFrame(className, name, parent)
  local hierarchy = {
    Alpha = {
      inherits = {'Animation'},
      api = {
        SetFromAlpha = UNIMPLEMENTED,
        SetToAlpha = UNIMPLEMENTED,
      },
    },
    Animation = {
      inherits = {'ScriptObject', 'UIObject'},
      api = {
        SetDuration = UNIMPLEMENTED,
        SetOrder = UNIMPLEMENTED,
        SetStartDelay = UNIMPLEMENTED,
      },
    },
    AnimationGroup = {
      inherits = {'Region', 'ScriptObject'},
      api = {
        CreateAnimation = function(self, animType, ...)
          return CreateFrame(animType, nil, self)
        end,
        SetToFinalAlpha = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
    },
    Button = {
      inherits = {'Frame'},
      api = {
        Click = function(self, ...)
          local script = self:GetScript('OnClick')
          if script then
            script(self, ...)
          end
        end,
        Enable = UNIMPLEMENTED,
        GetHighlightTexture = function(self, ...)
          return self.highlightTexture
        end,
        GetNormalTexture = function(self, ...)
          return self.normalTexture
        end,
        GetPushedTexture = function(self, ...)
          return self.pushedTexture
        end,
        RegisterForClicks = UNIMPLEMENTED,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = function(self, ...)
          self.highlightTexture = self:CreateTexture()
        end,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = function(self, ...)
          self.normalTexture = self:CreateTexture()
        end,
        SetPushedTexture = function(self, ...)
          self.pushedTexture = self:CreateTexture()
        end,
        SetText = UNIMPLEMENTED,
      },
    },
    FontInstance = {
      api = {
        SetJustifyH = UNIMPLEMENTED,
        SetJustifyV = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
    },
    FontString = {
      inherits = {'FontInstance', 'LayeredRegion'},
      api = {
        SetText = UNIMPLEMENTED,
      },
    },
    Frame = {
      inherits = {'Region', 'ScriptObject'},
      api = {
        CreateFontString = function(self, ...)
          return CreateFrame('FontString', nil, self)
        end,
        CreateTexture = function(self, ...)
          return CreateFrame('Texture', nil, self)
        end,
        EnableMouse = UNIMPLEMENTED,
        EnableMouseWheel = UNIMPLEMENTED,
        RegisterEvent = function(self, ev)
          if T.handlers[ev] == nil then
            T.handlers[ev] = {}
          end
          table.insert(T.handlers[ev], self)
        end,
        RegisterForDrag = UNIMPLEMENTED,
        SetBackdrop = UNIMPLEMENTED,
        SetBackdropBorderColor = UNIMPLEMENTED,
        SetBackdropColor = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
        SetFrameStrata = UNIMPLEMENTED,
        SetMinResize = UNIMPLEMENTED,
        SetMovable = UNIMPLEMENTED,
        SetResizable = UNIMPLEMENTED,
        SetToplevel = UNIMPLEMENTED,
      },
    },
    GameTooltip = {
      inherits = {'Frame'},
      data = {'lines'},
      api = {
        AddDoubleLine = function(self, l, r, lr, lg, lb, rr, rg, rb)
          table.insert(self.lines, {
              l = l, r = r,
              lr = lr, lg = lg, lb = lb,
              rr = rr, rg = rg, rb = rb
          })
        end,
        AddLine = function(self, s, r, g, b)
          self:AddDoubleLine(s, nil, r, g, b, nil, nil, nil)
        end,
        SetOwner = UNIMPLEMENTED,
      },
    },
    LayeredRegion = {
      inherits = {'Region'},
      api = {
        SetVertexColor = UNIMPLEMENTED,
      },
    },
    Minimap = {
      inherits = {'Frame'},
    },
    Region = {
      inherits = {'UIObject', 'ScriptObject'},
      api = {
        ClearAllPoints = UNIMPLEMENTED,
        CreateAnimationGroup = function(self, ...)
          return CreateFrame('AnimationGroup', nil, self)
        end,
        GetCenter = UNIMPLEMENTED,
        GetHeight = function(self)
          return self.height or 10
        end,
        GetWidth = UNIMPLEMENTED,
        Hide = function(self, ...)
          local script = self:GetScript('OnHide')
          if script then
            script(self, ...)
          end
        end,
        IsShown = UNIMPLEMENTED,
        SetAllPoints = UNIMPLEMENTED,
        SetHeight = function(self, value)
          self.height = value
        end ,
        SetParent = UNIMPLEMENTED,
        SetPoint = UNIMPLEMENTED,
        SetSize = UNIMPLEMENTED,
        SetWidth = UNIMPLEMENTED,
        Show = function(self, ...)
          local script = self:GetScript('OnShow')
          if script then
            script(self, ...)
          end
        end,
      },
    },
    ScriptObject = {
      data = {'scripts'},
      api = {
        GetScript = function(self, name)
          return self.scripts[name]
        end,
        HookScript = UNIMPLEMENTED,
        SetScript = function(self, name, script)
          self.scripts[name] = script
        end,
      }
    },
    ScrollFrame = {
      inherits = {'Frame'},
      api = {
        SetScrollChild = UNIMPLEMENTED,
      },
    },
    Slider = {
      inherits = {'Frame'},
      api = {
        SetMinMaxValues = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
        SetValueStep = UNIMPLEMENTED,
      },
    },
    Texture = {
      inherits = {'LayeredRegion'},
      api = {
        GetTexture = UNIMPLEMENTED,
        GetVertexColor = UNIMPLEMENTED,
        SetBlendMode = UNIMPLEMENTED,
        SetColorTexture = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
      },
    },
    UIObject = {
      api = {
        GetParent = function(self)
          return self.parent
        end,
        SetAlpha = UNIMPLEMENTED,
      },
    },
  }
  local toProcess = {className}
  local classes = {}
  while #toProcess > 0 do
    local p = table.remove(toProcess)
    assert(hierarchy[p] ~= nil, 'unknown class ' .. p)
    classes[p] = hierarchy[p]
    for _, c in ipairs(hierarchy[p].inherits or {}) do
      table.insert(toProcess, c)
    end
  end
  local frame = {}
  for _, class in pairs(classes) do
    for _, v in ipairs(class.data or {}) do
      frame[v] = {}
    end
    for k, v in pairs(class.api or {}) do
      frame[k] = v
    end
  end
  frame.parent = parent
  frame._type = className
  return frame
end

ERR_LEARN_SPELL_S = 'You have learned a new spell: %s.'

function GetCraftInfo(n)
  return table.unpack(T.crafts[n])
end

function GetInstanceInfo()
  return 0,0,0,0,0,0,0,48
end

function GetLocale()
  return T.locale
end

function GetNumCrafts()
  return #T.crafts
end

function GetRealZoneText(id)
  return 'i' .. id
end

function InterfaceOptions_AddCategory(...)
end

function InterfaceOptionsFrame_OpenToCategory(...)
end

function IsInInstance()
  return T.inInstance
end

Minimap = CreateFrame('Minimap')

T.print = print
function print(str)
  T.printed = T.printed .. str .. '\n'
end

function SetDesaturation(texture, desaturation)
  texture:SetDesaturated(desaturation)
end

SlashCmdList = {}

strmatch = string.match

function UnitClass(unit)
  assert(unit == 'player')
  return 'Hunter', 'HUNTER', 3
end

function UnitLevel(unit)
  assert(unit == 'player')
  return T.playerLevel
end

unpack = table.unpack

function wipe(t)
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

local function assertEquals(want, got, ctx)
  ctx = ctx or '_'
  assert(
      type(want) == type(got),
      'in ' .. ctx .. '\nwant ' .. type(want) .. '\ngot ' .. type(got))
  if type(want) == 'table' then
    local wantKeys, gotKeys = {}, {}
    for k, _ in pairs(want) do
      table.insert(wantKeys, k)
    end
    for k, _ in pairs(got) do
      table.insert(gotKeys, k)
    end
    assertEquals(#wantKeys, #gotKeys, '#tablekeys ' .. ctx)
    table.sort(wantKeys)
    table.sort(gotKeys)
    for i = 1, #wantKeys do
      assertEquals(wantKeys[i], gotKeys[i], 'tablekeys ' .. ctx)
    end
    for i = 1, #wantKeys do
      local key = wantKeys[i]
      assertEquals(want[key], got[key], 'table[' .. key .. '] ' .. ctx)
    end
  else
    assert(want == got, 'in ' .. ctx .. '\nwant ' .. want .. '\ngot ' .. got)
  end
end

function T.assertPrinted(want)
  assertEquals(want, T.printed)
end

-- Stay in sync with the .toc file.
T.addonFiles = {}
for line in io.lines('OlliverrsTravels.toc') do
  line = line:sub(1, -2)
  if line:sub(1, 2) ~= '##' then
    table.insert(T.addonFiles, assert(loadfile(line)))
  end
end

function T.RunTests(tests)
  local failed = 0
  for i, test in ipairs(tests) do
    T.Reset()
    _G['LibStub'] = nil
    local G = {}
    for _, file in ipairs(T.addonFiles) do
      file('moo', G)
    end
    local success, err = pcall(test, G)
    if not success then
      failed = failed + 1
      T.print(i .. ': ' .. err)
    end
  end
  local passed = #tests - failed
  T.print('passed ' .. passed .. ' of ' .. #tests .. ' tests')
  if failed > 0 then
    os.exit(1)
  end
end

T.RunTests({
  function(G)
    T.SendEvent('CHAT_MSG_SYSTEM', 'hello')
    assert(G.State.NumSkills() == 0)
  end,
  function(G)
    T.SendEvent('CHAT_MSG_SYSTEM', 'You have learned a new spell: Shell Shield (Rank 5).')
    assert(G.State.NumSkills() == 1)
    assert(G.State.HasSkill(26065, 5))
  end,
  function(G)
    T.SendEvent('CHAT_MSG_SYSTEM', 'You have learned a new spell: Aimed Shot (Rank 3).')
    assert(G.State.NumSkills() == 0)
  end,
  function()
    T.SendEvent('PLAYER_LEVEL_UP', 1)
    T.assertPrinted('')
  end,
  function()
    T.SendEvent('PLAYER_LEVEL_UP', 9)
    T.assertPrinted('')
  end,
  function()
    T.SendEvent('PLAYER_LEVEL_UP', 10)
    T.assertPrinted('New trainable skills: Bite 1, Bite 2, Charge 1, Claw 1, Claw 2, Cower 1, Furious Howl 1, Great Stamina 1, Growl 1, Growl 2, Natural Armor 1, Scorpid Poison 1\n')
  end,
  function()
    T.SendEvent('PLAYER_LEVEL_UP', 59)
    T.assertPrinted('No new trainable skills.\n')
  end,
  function()
    T.SendEvent('PLAYER_LEVEL_UP', 60)
    T.assertPrinted('New trainable skills: Arcane Resistance 5, Charge 6, Fire Resistance 5, Frost Resistance 5, Great Stamina 10, Growl 7, Lightning Breath 6, Natural Armor 10, Nature Resistance 5, Shadow Resistance 5\n')

  end,
  function()
    -- Just ensure the function works for all levels.
    for i = 1, 60 do
      T.SendEvent('PLAYER_LEVEL_UP', i)
    end
  end,
  function(G)
    OlliverrsTravelsPlayerData = {['26065,1'] = true}
    T.SendEvent('ADDON_LOADED', 'Wrong Addon')
    assert(G.State.NumSkills() == 0)
  end,
  function(G)
    OlliverrsTravelsPlayerData = {['26065,1'] = true}
    T.SendEvent('ADDON_LOADED', 'moo')
    assert(G.State.NumSkills() == 1)
    assert(OlliverrsTravelsPlayerData == nil)
    T.SendEvent('PLAYER_LOGOUT')
    assert(OlliverrsTravelsPlayerData['26065,1'])
  end,
  function(G)
    OlliverrsTravelsPlayerData = nil
    T.SendEvent('ADDON_LOADED', 'moo')
    assert(G.State.NumSkills() == 0)
    G.State.AddSkillByName('Shell Shield', 1)
    T.SendEvent('PLAYER_LOGOUT')
    assert(OlliverrsTravelsPlayerData['26065,1'])
  end,
  function()
    local icon = LibStub('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      icon:GetMinimapButton(name):Click('LeftButton')
    end
    T.assertPrinted('')
  end,
  function()
    local icon = LibStub('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      icon:GetMinimapButton(name):Click('RightButton')
    end
    T.assertPrinted('')
  end,
  function()
    local icon = LibStub('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      local button = icon:GetMinimapButton(name)
      button:Click('MiddleButton')
      button:Click('Button4')
      button:Click('Button5')
      button:Click('random text')
    end
    T.assertPrinted('')
  end,
  function()
    T.inInstance = true
    table.insert(T.crafts, {'Bite', '(Rank 3)'})
    table.insert(T.crafts, {'Shell Shield', '(Rank 1)'})
    T.SendEvent('CRAFT_SHOW')
    local icon = LibStub('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      local button = icon:GetMinimapButton(name)
      button:GetScript('OnEnter')(button)
      want = {
        { l = 'Olliverr\'s Travels' },
        { l = 'Skittering Crustacean (22-23)', r = 'Claw 3' },
        { l = 'Snapping Crustacean (23-24)', r = 'Claw 3' },
        { l = 'Aku\'mai Fisher (23-24)', r = 'Bite 3',
          lr = 0.4, lg = 0.4, lb = 0.4, rr = 0.4, rg = 0.4, rb = 0.4 },
        { l = 'Aku\'mai Fisher (23-24)', r = 'Shell Shield 1',
          lr = 0.4, lg = 0.4, lb = 0.4, rr = 0.4, rg = 0.4, rb = 0.4 },
        { l = 'Barbed Crustacean (25-26)', r = 'Claw 4',
          lr = 1.0, lg = 0.0, lb = 0.0, rr = 1.0, rg = 0.0, rb = 0.0 },
        { l = 'Ghamoo-ra (25)', r = 'Bite 4',
          lr = 1.0, lg = 0.0, lb = 0.0, rr = 1.0, rg = 0.0, rb = 0.0 },
        { l = 'Ghamoo-ra (25)', r = 'Shell Shield 1',
          lr = 0.4, lg = 0.4, lb = 0.4, rr = 0.4, rg = 0.4, rb = 0.4 },
        { l = 'Aku\'mai Snapjaw (26-27)', r = 'Bite 4',
          lr = 1.0, lg = 0.0, lb = 0.0, rr = 1.0, rg = 0.0, rb = 0.0 },
        { l = 'Aku\'mai Snapjaw (26-27)', r = 'Shell Shield 1',
          lr = 0.4, lg = 0.4, lb = 0.4, rr = 0.4, rg = 0.4, rb = 0.4 },
        { l = '---------------------' },
        { l = 'o1411, o1412, o1426, o1429, o1432, o1438', r = 'Charge 1' },
        { l = 'o1432, o1433, o1436', r = 'Charge 2' },
        { l = 'o1411, o1426, o1438', r = 'Claw 1' },
        { l = 'o1411, o1421, o1426, o1429, o1438, o1439', r = 'Claw 2' },
        { l = 'i48, o1424, o1432, o1436, o1439, o1440', r = 'Claw 3' },
        { l = 'o1411, o1412, o1413, o1420, o1426, o1438, o1439', r = 'Cower 1' },
        { l = 'o1413, o1424, o1439, o1442', r = 'Cower 2' },
        { l = 'o1412, o1421, o1436, o1440', r = 'Furious Howl 1' },
        { l = 'o1413', r = 'Lightning Breath 2' },
        { l = 'o1411, o1413', r = 'Scorpid Poison 1' },
        { l = 'o1436', r = 'Screech 1' },
      }
      assertEquals(want, icon.tooltip.lines, 'tooltip')
      button:GetScript('OnLeave')(button)
    end
  end,
})


