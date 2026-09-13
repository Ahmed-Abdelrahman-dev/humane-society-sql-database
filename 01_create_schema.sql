/*
============================================================
Humane Society Database Management System
Author: Ahmed Abdelrahman
Date: September 2026

Purpose:
Creates the database schema for the Humane Society database, 
including tables, constraints, views, and triggers.

Execution Order:
1. 01_create_schema.sql
2. 02_insert_sample_data.sql
3. 03_queries.sql
4. 04_demo_and_tests.sql
============================================================
*/

-- =========================================================
-- Drop Existing Database Objects
-- =========================================================

DROP TRIGGER IF EXISTS trg_incrementAnimalCount;
DROP TRIGGER IF EXISTS trg_checkAdoptionDate;

DROP VIEW IF EXISTS AdoptionHistory;
DROP VIEW IF EXISTS AvailableAnimals;

DROP TABLE IF EXISTS Adoption;
DROP TABLE IF EXISTS Admission;
DROP TABLE IF EXISTS Manage;
DROP TABLE IF EXISTS Employment;
DROP TABLE IF EXISTS Animal;
DROP TABLE IF EXISTS Adopter;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Employee;

-- =========================================================
-- Core Entity Tables
-- =========================================================

-- Stores employee information for all HSO locations.
CREATE TABLE Employee (
    EID INT PRIMARY KEY,
    SSN VARCHAR(20) NOT NULL UNIQUE,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    city VARCHAR(50),
    postalCode VARCHAR(20),
    province VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Stores information about Humane Society locations.
CREATE TABLE Location (
    LID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100),
    city VARCHAR(50),
    postalCode VARCHAR(20),
    province VARCHAR(50)
);

-- =========================================================
-- Relationship Tables
-- =========================================================

-- Stores the current manager assigned to each location.
-- Business Rule:
--  • Each location has exactly one manager.
--  • A manager can manage only one location.
CREATE TABLE Manage (
    EID INT PRIMARY KEY,
    LID INT UNIQUE,

    CONSTRAINT fk_manage_employee
        FOREIGN KEY (EID)
        REFERENCES Employee(EID),

    CONSTRAINT fk_manage_location
        FOREIGN KEY (LID)
        REFERENCES Location(LID)
);

-- Stores employee work history.
-- Employees may work at multiple locations and may return to a location at a later date.
CREATE TABLE Employment (
    EID INT,
    LID INT,
    startDate DATE,
    endDate DATE,

    PRIMARY KEY (EID, LID, startDate),

    CONSTRAINT fk_employment_employee
        FOREIGN KEY (EID)
        REFERENCES Employee(EID),

    CONSTRAINT fk_employment_location
        FOREIGN KEY (LID)
        REFERENCES Location(LID),

    CONSTRAINT chk_employment_dates
        CHECK (
            endDate IS NULL
            OR endDate >= startDate
        )
);

-- =========================================================
-- Animal Management Tables
-- =========================================================

-- Stores information about animals admitted to the HSO.
CREATE TABLE Animal (
    AID INT PRIMARY KEY,

    type ENUM(
        'Dog',
        'Cat',
        'Rabbit',
        'Bird',
        'Hamster',
        'Other'
    ) NOT NULL,

    gender ENUM(
        'Male',
        'Female'
    ) NOT NULL,

    chipNo VARCHAR(50) UNIQUE,

    -- Optional notes such as breed,
    -- medical conditions, or behavior.
    notes VARCHAR(500)
);

-- Stores adopter information.
CREATE TABLE Adopter (
    SSN VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100),
    city VARCHAR(50),
    postalCode VARCHAR(20),
    province VARCHAR(50),
    phone VARCHAR(20),

    animalsCount INT DEFAULT 0,

    CONSTRAINT chk_animals_count
        CHECK (animalsCount >= 0)
);

-- =========================================================
-- Transaction Tables
-- =========================================================

-- Records animal admissions to HSO locations.
-- An animal may be admitted multiple times throughout its lifetime, but only once on a specific date.
CREATE TABLE Admission (
    AID INT,
    LID INT,
    EID INT,
    admissionDate DATE,
    prevOwnerSSN VARCHAR(20),

    PRIMARY KEY (AID, admissionDate),

    CONSTRAINT fk_admission_animal
        FOREIGN KEY (AID)
        REFERENCES Animal(AID),

    CONSTRAINT fk_admission_location
        FOREIGN KEY (LID)
        REFERENCES Location(LID),

    CONSTRAINT fk_admission_employee
        FOREIGN KEY (EID)
        REFERENCES Employee(EID)
);

-- Records animal adoption events.
-- The composite key prevents the same adopter from adopting the same animal more than once.
CREATE TABLE Adoption (
    AID INT,
    adopterSSN VARCHAR(20),
    EID INT,
    adoptionDate DATE,

    PRIMARY KEY (AID, adopterSSN),

    CONSTRAINT fk_adoption_animal
        FOREIGN KEY (AID)
        REFERENCES Animal(AID),

    CONSTRAINT fk_adoption_adopter
        FOREIGN KEY (adopterSSN)
        REFERENCES Adopter(SSN),

    CONSTRAINT fk_adoption_employee
        FOREIGN KEY (EID)
        REFERENCES Employee(EID)
);

-- =========================================================
-- Views
-- =========================================================

-- Returns animals that have never been adopted.
-- Animal return tracking is not implemented in the current database design.
CREATE VIEW AvailableAnimals AS
SELECT
    a.AID,
    a.type,
    a.gender,
    a.chipNo,
    a.notes
FROM Animal a
WHERE NOT EXISTS (
    SELECT 1
    FROM Adoption ad
    WHERE ad.AID = a.AID
);

-- Provides a business-friendly summary of all animal adoption transactions.
CREATE VIEW AdoptionHistory AS
SELECT
    a.AID,
    a.type,
    ap.name AS adopterName,
    ad.adoptionDate,
    CONCAT(e.firstName, ' ', e.lastName) AS processedBy
FROM Adoption ad
JOIN Animal a
    ON ad.AID = a.AID
JOIN Adopter ap
    ON ad.adopterSSN = ap.SSN
JOIN Employee e
    ON ad.EID = e.EID;

-- =========================================================
-- Triggers
-- =========================================================

-- Automatically updates an adopter's animal count whenever a new adoption record is inserted.
DELIMITER $$

CREATE TRIGGER trg_incrementAnimalCount
AFTER INSERT ON Adoption
FOR EACH ROW
BEGIN

    UPDATE Adopter
    SET animalsCount = animalsCount + 1
    WHERE SSN = NEW.adopterSSN;

END$$

DELIMITER ;

-- Prevents an adoption from being recorded before the animal's most recent admission date.
DELIMITER $$

CREATE TRIGGER trg_checkAdoptionDate
BEFORE INSERT ON Adoption
FOR EACH ROW
BEGIN

    DECLARE admittedDate DATE;

    SELECT MAX(admissionDate)
    INTO admittedDate
    FROM Admission
    WHERE AID = NEW.AID;

    IF NEW.adoptionDate < admittedDate THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Adoption date cannot be earlier than admission date';

    END IF;

END$$

DELIMITER ;