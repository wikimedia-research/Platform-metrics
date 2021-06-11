SELECT
    '{metrics_month_first_day}' AS month,
    COUNT(DISTINCT(page_id)) AS wikidata_items
FROM wmf_raw.mediawiki_page
WHERE
    snapshot = '{metrics_month}'
    AND NOT page_is_redirect
    AND wiki_db = 'wikidatawiki'
    AND page_namespace = 0