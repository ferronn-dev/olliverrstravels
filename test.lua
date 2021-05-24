local T = require('testing')

T.RunTests({
  before = function(state)
    state.player.class = 3
  end,
  function(state, _, G)
    state:SendEvent('CHAT_MSG_SYSTEM', 'hello')
    T.assertEquals(0, G.State.NumSkills())
  end,
  function(state, _, G)
    state:SendEvent('CHAT_MSG_SYSTEM', 'You have learned a new spell: Shell Shield (Rank 5).')
    T.assertEquals(1, G.State.NumSkills())
    T.assertEquals(true, G.State.HasSkill(26065, 5))
  end,
  function(state, _, G)
    state:SendEvent('CHAT_MSG_SYSTEM', 'You have learned a new spell: Aimed Shot (Rank 3).')
    T.assertEquals(0, G.State.NumSkills())
  end,
  function(state)
    state:SendEvent('PLAYER_LEVEL_UP', 1)
    T.assertEquals('', state.printed)
  end,
  function(state)
    state:SendEvent('PLAYER_LEVEL_UP', 9)
    T.assertEquals('', state.printed)
  end,
  function(state, _, _, _G)
    local abilities = ({
      [_G.WOW_PROJECT_CLASSIC] = {
        'Bite 1',
        'Bite 2',
        'Charge 1',
        'Claw 1',
        'Claw 2',
        'Cower 1',
        'Furious Howl 1',
        'Great Stamina 1',
        'Growl 1',
        'Growl 2',
        'Natural Armor 1',
        'Scorpid Poison 1',
      },
      [_G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = {
        'Bite 1',
        'Bite 2',
        'Charge 1',
        'Claw 1',
        'Claw 2',
        'Cower 1',
        'Fire Breath 1',
        'Furious Howl 1',
        'Gore 1',
        'Gore 2',
        'Great Stamina 1',
        'Growl 1',
        'Growl 2',
        'Natural Armor 1',
        'Scorpid Poison 1',
      },
    })[_G.WOW_PROJECT_ID]
    state:SendEvent('PLAYER_LEVEL_UP', 10)
    T.assertEquals('New trainable skills: ' .. table.concat(abilities, ', ') .. '\n', state.printed)
  end,
  function(state)
    state:SendEvent('PLAYER_LEVEL_UP', 59)
    T.assertEquals('No new trainable skills.\n', state.printed)
  end,
  function(state, _, _, _G)
    local abilities = ({
      [_G.WOW_PROJECT_CLASSIC] = {
        'Arcane Resistance 5',
        'Charge 6',
        'Fire Resistance 5',
        'Frost Resistance 5',
        'Great Stamina 10',
        'Growl 7',
        'Lightning Breath 6',
        'Natural Armor 10',
        'Nature Resistance 5',
        'Shadow Resistance 5',
      },
      [_G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = {
        'Arcane Resistance 5',
        'Avoidance 2',
        'Charge 6',
        'Fire Resistance 5',
        'Frost Resistance 5',
        'Gore 8',
        'Great Stamina 10',
        'Growl 7',
        'Lightning Breath 6',
        'Natural Armor 10',
        'Nature Resistance 5',
        'Poison Spit 3',
        'Shadow Resistance 5',
      },
    })[_G.WOW_PROJECT_ID]
    state:SendEvent('PLAYER_LEVEL_UP', 60)
    T.assertEquals('New trainable skills: ' .. table.concat(abilities, ', ') .. '\n', state.printed)
  end,
  function(state)
    -- Just ensure the function works for all levels.
    for i = 1, 60 do
      state:SendEvent('PLAYER_LEVEL_UP', i)
    end
  end,
  function(state, _, G, _G)
    _G['OlliverrsTravelsPlayerData'] = {['26065,1'] = true}
    state:SendEvent('ADDON_LOADED', 'Wrong Addon')
    T.assertEquals(0, G.State.NumSkills())
  end,
  function(state, _, G, _G)
    _G['OlliverrsTravelsPlayerData'] = {['26065,1'] = true}
    state:SendEvent('ADDON_LOADED', 'moo')
    T.assertEquals(1, G.State.NumSkills())
    T.assertEquals(nil, _G['OlliverrsTravelsPlayerData'])
    state:SendEvent('PLAYER_LOGOUT')
    T.assertEquals(true, _G['OlliverrsTravelsPlayerData']['26065,1'])
  end,
  function(state, _, G, _G)
    _G['OlliverrsTravelsPlayerData'] = nil
    state:SendEvent('ADDON_LOADED', 'moo')
    T.assertEquals(0, G.State.NumSkills())
    G.State.AddSkillByName('Shell Shield', 1)
    state:SendEvent('PLAYER_LOGOUT')
    T.assertEquals(true, _G['OlliverrsTravelsPlayerData']['26065,1'])
  end,
  function(state, _, _, _G)
    local icon = _G['LibStub']('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      icon:GetMinimapButton(name):Click('LeftButton')
    end
    T.assertEquals('', state.printed)
  end,
  function(state, _, _, _G)
    local icon = _G['LibStub']('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      icon:GetMinimapButton(name):Click('RightButton')
    end
    T.assertEquals('', state.printed)
  end,
  function(state, _, _, _G)
    local icon = _G['LibStub']('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      local button = icon:GetMinimapButton(name)
      button:Click('MiddleButton')
      button:Click('Button4')
      button:Click('Button5')
      button:Click('random text')
    end
    T.assertEquals('', state.printed)
  end,
  function(state, _, _, _G)
    if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then
      return
    end
    state.player.level = 23
    state.instanceId = 48
    state.crafts = {
      { 'Bite', '(Rank 1)' },
      { 'Bite', '(Rank 2)' },
      { 'Bite', '(Rank 3)' },
      { 'Growl', '(Rank 3)' },
      { 'Natural Armor', '(Rank 5)' },
      { 'Shell Shield', '(Rank 1)' },
    }
    state:SendEvent('CRAFT_SHOW')
    local icon = _G['LibStub']('LibDBIcon-1.0')
    for _, name in ipairs(icon:GetButtonList()) do
      local button = icon:GetMinimapButton(name)
      button:GetScript('OnEnter')(button)
      local want = {
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
        { l = 'i43, o1413', r = 'Lightning Breath 2' },
        { l = 'o1411, o1413', r = 'Scorpid Poison 1' },
        { l = 'o1436', r = 'Screech 1' },
      }
      T.assertEquals(want, icon.tooltip.lines, 'tooltip')
      button:GetScript('OnLeave')(button)
    end
  end,
})
