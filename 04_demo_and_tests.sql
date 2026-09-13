/*
============================================================
Humane Society Database Management System
Author: Ahmed Abdelrahman
Date: September 2026

Purpose:
Demonstrate and validate the functionality of:

1. AvailableAnimals View
2. AdoptionHistory View
3. Adoption Count Trigger
4. Adoption Date Validation Trigger

Prerequisites:
1. 01_create_schema.sql
2. 02_insert_sample_data.sql
============================================================
*/

-- =========================================================
-- VIEW DEMONSTRATION #1
-- Available Animals
-- =========================================================

-- These animals have not been adopted and are therefore considered available.

SELECT *
FROM AvailableAnimals;


-- =========================================================
-- VIEW DEMONSTRATION #2
-- Adoption History
-- =========================================================

-- Displays historical adoption information along with the employee who processed the adoption.

SELECT *
FROM AdoptionHistory;



-- =========================================================
-- TRIGGER DEMONSTRATION #1
-- Automatic Animal Count Update
-- =========================================================

-- Before inserting a new adoption.

SELECT
    SSN,
    name,
    animalsCount
FROM Adopter
WHERE SSN = '900555555';

-- Expected:
-- animalsCount should increase by 1

INSERT INTO Adoption
VALUES
(
    210,
    '900555555',
    107,
    '2022-07-01'
);

-- After inserting a new adoption.

SELECT
    SSN,
    name,
    animalsCount
FROM Adopter
WHERE SSN = '900555555';



-- =========================================================
-- CLEANUP
-- =========================================================

-- Remove test record so the script can be executed repeatedly.

DELETE FROM Adoption
WHERE AID = 210
AND adopterSSN = '900555555';

-- Manually restore count because the current database only contains an AFTER INSERT trigger.

UPDATE Adopter
SET animalsCount = animalsCount - 1
WHERE SSN = '900555555';


-- =========================================================
-- TRIGGER DEMONSTRATION #2
-- Adoption Date Validation
-- =========================================================

-- First verify the admission date of animal 205.

SELECT
    AID,
    admissionDate
FROM Admission
WHERE AID = 205;

-- Animal 205 admission date:
-- 2021-11-15

-- The following adoption uses:
-- 2020-01-01

-- Since the adoption occurs BEFORE the animal was admitted, the trigger should reject it.

INSERT INTO Adoption
VALUES
(
    205,
    '900333333',
    105,
    '2020-01-01'
);

-- Expected Error:
--
-- Adoption date cannot be earlier than admission date
