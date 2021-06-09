--Structured data used (uptake) across wikis

WITH namespaces AS (
      SELECT
        dbname AS wiki_db,
        namespace AS page_namespace
      FROM wmf_raw.mediawiki_project_namespace_map
      WHERE
        snapshot = '{metrics_month}'
        AND namespace_is_content = 1
        AND dbname <> 'wikidatawiki'
    ),
    content_pages AS (
      SELECT
         p.page_id AS page_id,
         p.wiki_db AS wiki_db,
         p.page_namespace AS namespace
      FROM wmf_raw.mediawiki_page p
      INNER JOIN namespaces ns
        ON (p.wiki_db = ns.wiki_db
            AND p.page_namespace = ns.page_namespace)
      WHERE
        p.snapshot = '{metrics_month}'
        AND NOT p.page_is_redirect
    ),
    num_content_pages AS (
      SELECT
        wiki_db,
        namespace,
        COUNT(DISTINCT(page_id)) as num_content_pages
      FROM content_pages
      GROUP BY
        wiki_db,
        namespace
    ),
    num_pages_using_wikidata AS (
      SELECT
        wbc.wiki_db AS wiki_db,
        p.namespace AS namespace,
        COUNT(DISTINCT(wbc.eu_page_id)) AS num_pages_use_wikidata
      FROM wmf_raw.mediawiki_wbc_entity_usage wbc
      INNER JOIN content_pages p
        ON (wbc.eu_page_id = p.page_id
            AND wbc.wiki_db = p.wiki_db)
      WHERE
        wbc.snapshot = '{metrics_month}'
        AND wbc.eu_aspect != 'S'
      GROUP BY
        wbc.wiki_db,
        p.namespace
    )

SELECT           
    '{metrics_month_first_day}' AS month,
    SUM(COALESCE(w.num_pages_use_wikidata, 0)) AS structured_data_used
FROM num_content_pages p
LEFT JOIN num_pages_using_wikidata w
ON (p.wiki_db = w.wiki_db AND p.namespace = w.namespace)

