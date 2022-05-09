CREATE OR REPLACE TEMPORARY TABLE tmp_abilities AS
SELECT
  spellname.name_lang AS ability,
  CAST(spellname.id AS INT64) AS id
FROM
  spell, spellname, skilllineability
WHERE
  skilllineability.skillline = "261"
  AND skilllineability.spell = spell.id
  AND skilllineability.spell = spellname.id
  AND spell.namesubtext_lang = "Rank 1";

CREATE OR REPLACE TEMPORARY TABLE tmp_zones AS
SELECT
  CONCAT("o", id) AS id,
  name_lang AS zonename
FROM uimap
UNION ALL
SELECT
  CONCAT("i", id) AS id,
  mapname_lang AS zonename
FROM map;

CREATE OR REPLACE TEMPORARY TABLE tmp_trainers AS
SELECT
  tmp_abilities.id AS ability,
  d.rank,
  d.npc,
  d.minlevel,
  d.maxlevel,
  d.zoneid
FROM
  tmp_abilities,
  (SELECT
    trainers.ability,
    trainers.rank,
    trainers.npc,
    trainers.minlevel,
    trainers.maxlevel,
    tmp_zones.id AS zoneid
    FROM
      petopia.trainers,
      tmp_zones
    WHERE
      trainers.zone = tmp_zones.zonename
    UNION ALL
    SELECT
      ranks.ability,
      ranks.rank,
      NULL AS npc,
      ranks.petlevel AS minlevel,
      ranks.petlevel AS maxlevel,
      NULL AS zoneid
    FROM
      petopia.ranks
    WHERE
      ranks.purchasable) AS d
WHERE
  d.ability = tmp_abilities.ability;

-- AbilityNames
SELECT
  id,
  [ability] AS abilities
FROM tmp_abilities
ORDER BY id;

-- LevelData
WITH prep_1 AS (SELECT
    minlevel AS level,
    ARRAY_AGG(
      STRUCT(ability, rank)
      ORDER BY ability, rank) AS arr
  FROM
    (SELECT
        ability,
        rank,
        MIN(minlevel) AS minlevel
      FROM
        tmp_trainers
      GROUP BY ability, rank)
  GROUP BY level
)

SELECT
  level,
  COALESCE(arr, []) AS ability_ranks
FROM
  UNNEST(GENERATE_ARRAY(1, 60)) AS level
LEFT JOIN
  prep_1
  USING (level)
ORDER BY level;

-- ZoneLevelData
WITH prep_1 AS (SELECT
    minlevel AS level,
    ARRAY_AGG(
      STRUCT(ability, rank, zoneid)
      ORDER BY ability, rank, zoneid) AS arr
  FROM
    (SELECT
        ability,
        rank,
        zoneid,
        MIN(minlevel) AS minlevel
      FROM
        tmp_trainers
      WHERE zoneid IS NOT NULL
      GROUP BY ability, rank, zoneid)
  GROUP BY level
)

SELECT
  level,
  COALESCE(arr, []) AS ability_rank_zones
FROM
  UNNEST(GENERATE_ARRAY(1, 60)) AS level
LEFT JOIN
  prep_1
  USING (level)
ORDER BY level;

-- ZoneData
SELECT
  zoneid,
  ARRAY_AGG(
    STRUCT(ability, rank, npc, minlevel, maxlevel)
    ORDER BY minlevel, ability, rank, maxlevel, npc) AS zone_data
FROM tmp_trainers
WHERE zoneid IS NOT NULL
GROUP BY zoneid
ORDER BY zoneid;

-- CreatureNames
SELECT
  creatures.id,
  [creatures.name] AS creature_names
FROM wowapi.creatures, tmp_trainers
WHERE creatures.id = tmp_trainers.npc
  AND creatures.lang = "en_US"
ORDER BY creatures.id;

DROP TABLE IF EXISTS tmp_trainers;
DROP TABLE IF EXISTS tmp_zones;
DROP TABLE IF EXISTS tmp_abilities;
