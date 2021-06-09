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
         p.wiki_db AS wiki_db
      FROM wmf_raw.mediawiki_page p
      INNER JOIN namespaces ns
        ON (p.wiki_db = ns.wiki_db
            AND p.page_namespace = ns.page_namespace)
      WHERE
        p.snapshot = '{metrics_month}'
        AND NOT p.page_is_redirect
    )
    SELECT
        '{metrics_month_first_day}' AS month,
        COUNT(DISTINCT(wbc.eu_entity_id)) AS wikidata_items_being_reused
      FROM wmf_raw.mediawiki_wbc_entity_usage wbc
      INNER JOIN content_pages p
        ON (wbc.eu_page_id = p.page_id
            AND wbc.wiki_db = p.wiki_db)
      WHERE
        wbc.snapshot = '{metrics_month}'
        AND wbc.eu_aspect != 'S'
        AND wbc.eu_entity_id LIKE 'Q%'
