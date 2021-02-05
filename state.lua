local _, G = ...
assert(not G.State)
G.State = {}

local skillNameToID = {}
for id, name in pairs(G.DB.AbilityNames) do
  skillNameToID[name] = id
end

local skills = {}

local function key(skill, rank)
  assert(skill)
  assert(rank)
  return skill .. ',' .. rank
end

function G.State.AddSkillByName(skillName, rank)
  local skill = skillNameToID[skillName]
  if skill ~= nil then
    skills[key(skill, rank)] = true
  end
end

function G.State.ClearSkills()
  skills = {}
end

function G.State.HasSkill(skill, rank)
  return skills[key(skill, rank)] ~= nil
end

function G.State.LoadFromTable(t)
  skills = t
end

function G.State.NumSkills()
  local n = 0
  for _ in pairs(skills) do
    n = n + 1
  end
  return n
end

function G.State.SerializeToTable()
  return skills
end
