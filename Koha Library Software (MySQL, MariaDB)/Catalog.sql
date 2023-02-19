/* Lost items */
SELECT 
	items.barcode,
	SUM(ABS(items.replacementprice))
FROM items
WHERE
	items.itemlost = <<Lost status |LOST>>

SELECT 
	items.barcode,
	items.replacementprice
FROM items
WHERE
	items.itemlost = <<Lost status |LOST>>

/* 2018 Camp Fire Reports */
/* Report 1: Checked out date from Jan 1 - End of Dec, 2018, checked out by paradise patrons, item status as Long Overdue Lost. */
SELECT
	biblio.title,
	biblio.author,
	items.barcode,
	items.dateaccessioned,
	items.replacementprice,
	items.homebranch,
	items.holdingbranch,
	borrowers.borrowernotes
FROM items
LEFT JOIN biblio ON (biblio.biblionumber = items.biblionumber)
LEFT JOIN issues ON (items.itemnumber = issues.itemnumber)
LEFT JOIN borrowers ON (issues.borrowernumber = borrowers.borrowernumber)
WHERE
	issues.issuedate BETWEEN '2018-01-01' AND '2018-12-31'
	AND items.itemlost = '2'
	AND borrowers.borrowernotes LIKE '%PARADISE%'
ORDER BY biblio.author ASC

/* Report 2: Columns: Title, Barcode, Accessiondate, replacement price, author, items home branch, current branch, shelving location + 
collection code + Item Type, check out date between July 26th and Nove 8th AND still checked out. */
SELECT
	biblio.title,
	biblio.author,
	items.barcode,
	items.dateaccessioned,
	items.replacementprice,
	items.homebranch,
	items.holdingbranch,
	issues.issuedate,
	issues.date_due,
	items.itype,
	items.ccode,
	items.location,
	items.onloan
FROM items
LEFT JOIN biblio ON (biblio.biblionumber = items.biblionumber)
LEFT JOIN issues ON (items.itemnumber = issues.itemnumber)
WHERE
	items.location = <<Shelving location |loc>>
	AND items.ccode = <<Collection Code |ccode>>
	AND items.itype = <<Item Type |itemtypes>>
	AND issues.issuedate BETWEEN '2018-07-26' AND '2018-11-08'
	AND items.onloan IS NOT NULL
ORDER BY biblio.author ASC

/* Report 3: Paradise lost book report: items checked out at Paradise branch + items checked out by patrons who 
have Paradise (Paradise, Magalia) addresses + by due date range + still checked out to them */
SELECT
	biblio.title,
	biblio.author,
	items.barcode,
	items.dateaccessioned,
	items.replacementprice,
	items.homebranch,
	items.holdingbranch,
	issues.issuedate,
	issues.date_due,
	items.itype,
	items.ccode,
	items.location,
	items.onloan,
	issues.branchcode,
	borrowers.city	
FROM items
LEFT JOIN biblio ON (biblio.biblionumber = items.biblionumber)
LEFT JOIN issues ON (items.itemnumber = issues.itemnumber)
LEFT JOIN borrowers ON (issues.borrowernumber = borrowers.borrowernumber)
WHERE
	issues.branchcode = 'PARADISE'
	AND borrowers.city IN ('PARADISE', 'MAGALIA')
	AND issues.date_due BETWEEN <<Due dates between |date>> AND <<and |date>>
	AND items.onloan IS NOT NULL
ORDER BY issues.date_due ASC

/* Books that have ON ORDER status */
SELECT
    biblio.biblionumber,
    CONCAT('<a href=\"/cgi-bin/koha/catalogue/detail.pl?biblionumber=',biblio.biblionumber,'\">',biblio.title,'</a>') AS 'Title',
    biblio.author,
    biblio.datecreated
FROM
    (SELECT
        biblio_metadata.biblionumber,
        ExtractValue(biblio_metadata.metadata,'//datafield[@tag="245"]/subfield[@code="b"]') AS '245B'
    FROM biblio_metadata ) AS 245BList1
LEFT JOIN biblio ON (245BList1.biblionumber = biblio.biblionumber)
WHERE 245BList1.245B LIKE '%ON ORDER%'
ORDER BY biblio.datecreated ASC
HAVING total_credits < 0

/* Catalog cleanup, Weeding reports */

/* By date acquired and last checked out date */
SELECT
	biblio.title AS 'Title',
	biblio.author AS 'Author',
	items.itemcallnumber AS 'Call Number',
	items.barcode AS 'Barcode',
	items.dateaccessioned AS 'Accession Date',
	items.datelastborrowed,
	items.issues AS 'Checkouts'
FROM biblio
LEFT JOIN items USING (biblionumber)
WHERE
	items.homebranch=<<Branch|branches>>
	AND items.location=<<Shelving location|LOC>>
	AND items.itype = <<Item Type |itemtypes>>
	AND items.dateaccessioned BETWEEN <<Date acquired BETWEEN (yyyy-mm-dd)|date>> AND <<and (yyyy-mm-dd)|date>>
	AND items.datelastborrowed BETWEEN <<Date last checked out BETWEEN (yyyy-mm-dd)|date>> AND <<and (yyyy-mm-dd)|date>>
ORDER BY items.itemcallnumber ASC

/* DVD Weeding */
SELECT
	biblio.title,
	biblio.author,
	items.barcode,
	COUNT(items.barcode) AS 'Checkouts'
FROM biblio
LEFT JOIN items USING (biblionumber)
LEFT JOIN statistics USING (itemnumber)
WHERE
	items.itype = 'DVD'
	AND statistics.type IN ('issue', 'renew')
	AND statistics.datetime BETWEEN '2017-01-01' AND '2017-03-01'
GROUP BY items.barcode

/* Catalog records that have no cover image/thumbnail */
SELECT
	CONCAT('<a href=\"/cgi-bin/koha/catalogue/detail.pl?biblionumber=',biblionumber,'\">',biblio.title,'</a>') AS "Title"
FROM biblio
LEFT JOIN biblioimages USING (biblionumber)
LEFT JOIN items USING (biblionumber)
WHERE
	biblioimages.mimetype IS NULL
	AND items.itype = <<Item Type |itemtypes>>