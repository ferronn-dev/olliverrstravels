from collections import abc
from google.cloud import bigquery
import py2lua

def bq(tmps, selects):
    client = bigquery.Client('wow-ferronn-dev')
    script = client.query(
        job_config=bigquery.job.QueryJobConfig(
            default_dataset='wow-ferronn-dev.wow_tools_dbc_1_13_6_36935_enUS',
            use_legacy_sql=False),
        query=';\n'.join([
            *[f'CREATE OR REPLACE TEMPORARY TABLE {n} AS {q}' for n, q in tmps],
            *selects,
            *[f'DROP TABLE IF EXISTS {n}' for n, _ in reversed(tmps)],
        ]))
    script.result()
    return [
        job for job in sorted(
            client.list_jobs(parent_job=script.job_id),
            key=lambda j: int(j.job_id.split('_')[-1]))
        if job.statement_type == 'SELECT']

tmps = [
    ('tmp_abilities', '''
        SELECT
            CAST(spellname.id AS INT64) id,
            spellname.name_lang ability
        FROM
            spell, spellname, skilllineability
        WHERE
            skilllineability.skillline = "261" AND
            skilllineability.spell = spell.id AND
            skilllineability.spell = spellname.id AND
            spell.namesubtext_lang = "Rank 1"
    '''),
    ('tmp_zones', '''
        SELECT
            CONCAT('o', id) id,
            name_lang name
        FROM uimap
        UNION ALL
        SELECT
            CONCAT('i', id) id,
            mapname_lang name
        FROM map
    '''),
    ('tmp_trainers', '''
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
            data.ability = tmp_abilities.ability
    '''),
]

selects = [
    ('AbilityNames', '''
        SELECT id, ability
        FROM tmp_abilities
        ORDER BY id
    '''),
    ('LevelData', '''
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
        ORDER BY level
    '''),
    ('ZoneLevelData', '''
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
        ORDER BY level
    '''),
    ('ZoneData', '''
        SELECT
            zone,
            ARRAY_AGG(
                STRUCT(ability, rank, npc, minlevel, maxlevel)
                ORDER BY minlevel, ability, rank, maxlevel, npc)
        FROM tmp_trainers
        WHERE zone IS NOT NULL
        GROUP BY zone
        ORDER BY zone
    '''),
    ('CreatureNames', '''
        SELECT creatures.id, creatures.name
        FROM wowapi.creatures, tmp_trainers
        WHERE creatures.id = tmp_trainers.npc
        AND creatures.lang = 'en_US'
        ORDER BY creatures.id
    '''),
]

print(py2lua.addon_file({
    'DB': {
        name: {
            key: val if isinstance(val, str) else [v.values() for v in val]
            for key, val in job
        }
        for name, job in zip(
            [n for n, _ in selects],
            bq(tmps, [q for _, q in selects]))
    },
}))
