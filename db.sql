CREATE OR REPLACE TEMPORARY TABLE tmp_abilities AS
SELECT
    CAST(spellname.id AS INT64) id,
    spellname.name_lang ability
FROM
    spell, spellname, skilllineability
WHERE
    skilllineability.skillline = "261" AND
    skilllineability.spell = spell.id AND
    skilllineability.spell = spellname.id AND
    spell.namesubtext_lang = "Rank 1";

CREATE OR REPLACE TEMPORARY TABLE tmp_zones AS
SELECT
    CONCAT('o', id) id,
    name_lang name
FROM uimap
UNION ALL
SELECT
    CONCAT('i', id) id,
    mapname_lang name
FROM map;

CREATE OR REPLACE TEMPORARY TABLE tmp_trainers AS
SELECT
    tmp_abilities.id ability, rank, npc, minlevel, maxlevel, zone
FROM
    tmp_abilities,
    (SELECT
        trainers.ability,
        trainers.rank,
        trainers.npc,
        trainers.minlevel,
        trainers.maxlevel,
        tmp_zones.id zone
    FROM
        petopia.trainers,
        tmp_zones
    WHERE
        trainers.zone = tmp_zones.name
    UNION ALL
    SELECT
        ranks.ability,
        ranks.rank,
        NULL AS npc,
        ranks.petlevel AS minlevel,
        ranks.petlevel AS maxlevel,
        NULL AS zone
    FROM
        petopia.ranks
    WHERE
        ranks.ability NOT IN (SELECT ability FROM petopia.trainers)) data
WHERE
    data.ability = tmp_abilities.ability;

-- AbilityNames
SELECT id, [ability]
FROM tmp_abilities
ORDER BY id;

-- LevelData
SELECT
    level,
    IFNULL(arr, [])
FROM
    UNNEST(GENERATE_ARRAY(1, 60)) level
LEFT JOIN
    (SELECT
        minlevel level,
        ARRAY_AGG(
            STRUCT(ability, rank)
            ORDER BY ability, rank) arr
    FROM
        (SELECT
            ability,
            rank,
            MIN(minlevel) minlevel
        FROM
            tmp_trainers
        GROUP BY ability, rank)
    GROUP BY level)
USING(level)
ORDER BY level;

-- ZoneLevelData
SELECT
    level,
    IFNULL(arr, [])
FROM
    UNNEST(GENERATE_ARRAY(1, 60)) level
LEFT JOIN
    (SELECT
        minlevel level,
        ARRAY_AGG(
            STRUCT(ability, rank, zone)
            ORDER BY ability, rank, zone) arr
    FROM
        (SELECT
            ability,
            rank,
            zone,
            MIN(minlevel) minlevel
        FROM
            tmp_trainers
        WHERE zone IS NOT NULL
        GROUP BY ability, rank, zone)
    GROUP BY level)
USING(level)
ORDER BY level;

-- ZoneData
SELECT
    zone,
    ARRAY_AGG(
        STRUCT(ability, rank, npc, minlevel, maxlevel)
        ORDER BY minlevel, ability, rank, maxlevel, npc)
FROM tmp_trainers
WHERE zone IS NOT NULL
GROUP BY zone
ORDER BY zone;

-- CreatureNames
SELECT creatures.id, [creatures.name]
FROM wowapi.creatures, tmp_trainers
WHERE creatures.id = tmp_trainers.npc
AND creatures.lang = 'en_US'
ORDER BY creatures.id;

DROP TABLE IF EXISTS tmp_trainers;
DROP TABLE IF EXISTS tmp_zones;
DROP TABLE IF EXISTS tmp_abilities;
