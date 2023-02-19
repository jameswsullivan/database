/* Top 10 Circulated Books in Date Range (by Collection Code and Item Type) */

/* Count checkout & renewal, filter by collection code. */
SELECT
	biblio.title,
	biblio.author,
	items.ccode,
	items.location,
	items.itype,
	COUNT(statistics.itemnumber) AS "checkout&renewal"
FROM statistics
LEFT JOIN items ON (statistics.itemnumber = items.itemnumber)
LEFT JOIN biblio ON (items.biblionumber = biblio.biblionumber)
WHERE
	statistics.datetime BETWEEN <<Transaction happened BETWEEN |date>> AND <<and |date>>
	AND statistics.type IN ('issue', 'renew')
	AND items.ccode = <<Collection Code |ccode>>
GROUP BY biblio.title
ORDER BY COUNT(statistics.itemnumber) DESC
LIMIT 10