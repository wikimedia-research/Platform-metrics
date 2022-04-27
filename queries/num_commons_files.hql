set hive.mapred.mode=nonstrict;

WITH

    wiki_content_namespaces as (
        select
            dbname,
            namespace
        FROM
            wmf_raw.mediawiki_project_namespace_map
        WHERE
            namespace_is_content = 1
            AND snapshot = '{metrics_month}'
    )

   
        SELECT
            '{metrics_month_first_day}' AS month,
            COUNT(DISTINCT il_to) AS num_commons_files_used_content_pages
        FROM
            wmf_raw.mediawiki_imagelinks as m
            INNER JOIN wiki_content_namespaces AS ns
                ON ( ns.namespace = m.il_from_namespace)
                AND ns.dbname = m.wiki_db
        WHERE
            m.snapshot = '{metrics_month}'