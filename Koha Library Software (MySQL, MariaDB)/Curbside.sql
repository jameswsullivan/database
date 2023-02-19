/* Curbside Plugin */

/*
Describe curbside_pickups database table.
The curbside_pickups table is not shown in the database schema at the time of the report was written
and "DESCRIBE" keyword was not supported.
*/

SELECT *
FROM curbside_pickups
LIMIT 1

/* Curbside Pickup Appointments Lookup */
SELECT
    CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=',curbside_pickups.borrowernumber,'\">', CONCAT(patronTable.firstname, ' ', patronTable.surname), '</a>') AS "Patron",
    patronTable.cardnumber AS "CardNumber",
    curbside_pickups.branchcode AS "Branch",
    curbside_pickups.scheduled_pickup_datetime AS "ScheduledPickupTime",
    curbside_pickups.staged_datetime AS "StagedTime",
    CONCAT(stagedByTable.firstname, ' ', stagedByTable.surname) AS "StagedBy",
    curbside_pickups.arrival_datetime AS "ArrivalTime",
    curbside_pickups.delivered_datetime AS "DeliveredTime",
    CONCAT(deliveredByTable.firstname, ' ', deliveredByTable.surname) AS "DeliveredBY",
    curbside_pickups.notes AS "Notes"
FROM curbside_pickups
LEFT JOIN borrowers patronTable ON (patronTable.borrowernumber = curbside_pickups.borrowernumber)
LEFT JOIN borrowers stagedByTable ON (stagedByTable.borrowernumber = curbside_pickups.staged_by)
LEFT JOIN borrowers deliveredByTable ON (deliveredByTable.borrowernumber = curbside_pickups.delivered_by)
WHERE
    curbside_pickups.scheduled_pickup_datetime BETWEEN <<Scheduled between: |date>> AND <<and: |date>>
    AND curbside_pickups.branchcode = <<At which branch? |branches>>
ORDER BY curbside_pickups.scheduled_pickup_datetime DESC