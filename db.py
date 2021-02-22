from collections import abc
from pathlib import Path
from google.cloud import bigquery
import py2lua

def bq(query):
    client = bigquery.Client('wow-ferronn-dev')
    script = client.query(
        job_config=bigquery.job.QueryJobConfig(
            default_dataset='wow-ferronn-dev.wow_tools_dbc_1_13_6_36935_enUS',
            use_legacy_sql=False),
        query=query)
    script.result()
    return [
        job for job in sorted(
            client.list_jobs(parent_job=script.job_id),
            key=lambda j: int(j.job_id.split('_')[-1]))
        if job.statement_type == 'SELECT']

print(py2lua.addon_file({
    'DB': {
        name: {
            key: val if isinstance(val, str) else [v.values() for v in val]
            for key, val in job
        }
        for name, job in zip(
            [
                'AbilityNames',
                'LevelData',
                'ZoneLevelData',
                'ZoneData',
                'CreatureNames',
            ],
            bq(Path('db.sql').read_text()))
    },
}))
