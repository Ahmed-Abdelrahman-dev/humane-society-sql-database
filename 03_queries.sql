
/*
============================================================
Humane Society Database Management System
Author: Ahmed Abdelrahman
Date: September 2026

Purpose:
Contains SQL queries developed for the Humane Society
Database project.

Demonstrated Concepts:
- Joins
- Aggregation
- GROUP BY
- HAVING
- Subqueries
- EXISTS / NOT EXISTS
- Relational Division
============================================================
*/

select distinct type
from animal;

-- =========================================================
-- Query A
-- Employees Living in Laval
-- =========================================================
--
-- List all employees (including managers) whose city of residence is Laval.
-- Returns:
-- EID, SSN, First Name, Last Name, Address
-- =========================================================

SELECT
    EID,
    SSN,
    firstName,
    lastName,
    address
FROM Employee
WHERE city = 'Laval';


-- =========================================================
-- Query B
-- Animals Received by Employee
-- =========================================================
--
-- For every location and every employee working at that location, 
-- display the total number of animals received through admissions.
-- LEFT JOIN ensures employees with no admissions are still displayed.
-- =========================================================

SELECT
    l.name AS locationName,
    emp.EID,
    CONCAT(emp.firstName," ",emp.lastName) AS employeeName ,
    COUNT(a.AID) AS totalAnimalsReceived
    
FROM Employment e
JOIN Employee emp
    ON e.EID = emp.EID
JOIN Location l
    ON e.LID = l.LID
LEFT JOIN Admission a
    ON a.EID = e.EID
   AND a.LID = e.LID
   
GROUP BY
    l.name,
    emp.EID,
    emp.firstName,
    emp.lastName

ORDER BY
    l.name,
    emp.lastName;



-- =========================================================
-- Query C
-- Employment History of Roger McDonald
-- =========================================================
--
-- Displays Roger McDonald's employment history across all locations.
--
-- Results are sorted by:
-- 1. Start Date
-- 2. End Date
-- =========================================================

SELECT
    l.name AS locationName,
    e.startDate,
    e.endDate
FROM Employee emp

JOIN Employment e
    ON emp.EID = e.EID

JOIN Location l
    ON e.LID = l.LID

WHERE emp.firstName = 'Roger'
  AND emp.lastName = 'McDonald'

ORDER BY
    e.startDate ASC,
    e.endDate ASC;



-- =========================================================
-- Query D
-- Manager Contact Information
-- =========================================================
--
-- Find the manager responsible for the location
-- where Alfred Simpson adopted an animal on
-- January 5, 2021.
--
-- Returns:
-- Manager First Name
-- Manager Last Name
-- Phone
-- Email
-- =========================================================

SELECT
    mng.firstName,
    mng.lastName,
    mng.phone,
    mng.email
FROM Adopter a

JOIN Adoption ad
    ON a.SSN = ad.adopterSSN

JOIN Admission adm
    ON ad.AID = adm.AID

JOIN Manage m
    ON adm.LID = m.LID

JOIN Employee mng
    ON m.EID = mng.EID

WHERE a.name = 'Alfred Simpson'
  AND ad.adoptionDate = '2021-01-05';


  
  -- =========================================================
--  Query E
-- Adoptions Between Two Dates
-- =========================================================
--
-- Displays animal details, location, and adopter information for animals 
-- adopted between 2021-01-05 and 2022-02-15.
-- =========================================================

SELECT
    a.type,
    a.gender,
    l.name AS locationName,
    ap.name AS adopterName
FROM Adoption ad
JOIN Animal a
    ON ad.AID = a.AID
JOIN Adopter ap
    ON ad.adopterSSN = ap.SSN
JOIN Employment e
    ON ad.EID = e.EID
   AND ad.adoptionDate >= e.startDate
   AND (
        e.endDate IS NULL
        OR ad.adoptionDate <= e.endDate
       )
JOIN Location l
    ON e.LID = l.LID

WHERE ad.adoptionDate BETWEEN '2021-01-05' AND '2022-02-15';



-- =========================================================
--  Query F
-- Animals Adopted By At Least 3 Adopters
-- =========================================================
--
-- Displays animals that have been adopted by three or more distinct adopters.
-- =========================================================

SELECT
    a.AID,
    a.type,
    a.gender,
    a.chipNo
    
FROM Animal a
JOIN Adoption ad
    ON a.AID = ad.AID
    
GROUP BY
    a.AID,
    a.type,
    a.gender,
    a.chipNo

HAVING COUNT(DISTINCT ad.adopterSSN) >= 3;



-- =========================================================
--  Query G
-- Adopters Living In Different Provinces
-- =========================================================
--
-- Returns adopters whose province differs from the province of the location where the adoption occurred.
-- =========================================================

SELECT DISTINCT
    ap.name,
    ap.phone
    
FROM Adopter ap
JOIN Adoption ad
    ON ap.SSN = ad.adopterSSN
JOIN Admission adm
    ON ad.AID = adm.AID
JOIN Location l
    ON adm.LID = l.LID

WHERE ap.province <> l.province;



-- =========================================================
--  Query H
-- Adopters Who Adopted Only Female Animals
-- =========================================================
--
-- Returns adopters that have adopted female animals and have never adopted a male animal.
-- =========================================================

SELECT DISTINCT
    ap.name,
    ap.phone
    
FROM Adopter ap

WHERE NOT EXISTS
(
    SELECT *
    
    FROM Adoption ad
    JOIN Animal a
        ON ad.AID = a.AID

    WHERE ad.adopterSSN = ap.SSN
      AND a.gender = 'Male'
);





-- =========================================================
--  Query I
-- Adopters Who Adopted All Animal Types
-- =========================================================
--
-- Relational Division Query
--
-- Returns adopters who have adopted at least one animal from every animal type that exists in the Animal table.
-- the demo data doesn't have that case for now 
-- =========================================================

SELECT
-- outer loop, loops for every adoptor 
    ap.name,
    ap.phone
    
FROM Adopter ap

WHERE NOT EXISTS
(
    -- middle loop, loops for every animal type
    SELECT DISTINCT a.type
    
    FROM Animal a

    WHERE NOT EXISTS
    (
		-- inner loop, loops for every adoptino event 
        SELECT *
        
        FROM Adoption ad
        JOIN Animal a2
            ON ad.AID = a2.AID

        WHERE ad.adopterSSN = ap.SSN
          AND a2.type = a.type
    )
);


