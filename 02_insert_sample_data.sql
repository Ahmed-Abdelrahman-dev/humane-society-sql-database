/*
============================================================
Humane Society Database Management System
Author: Ahmed Abdelrahman
Date: September 2026

Purpose:
Populate the Humane Society database with sample data
used for testing queries, views, and triggers.

Notes:
- Sample data represents four HSO locations across Quebec.
- Animal counts are maintained automatically by triggers.
- Data is intended for demonstration and testing purposes.

Requires:
01_create_schema.sql
============================================================
*/


-- ===========================================================
-- Uncomment and use to clear the database and populate it with test data. 
-- ===========================================================


SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM Adoption;
DELETE FROM Admission;
DELETE FROM Manage;
DELETE FROM Employment;
DELETE FROM Animal;
DELETE FROM Adopter;
DELETE FROM Location;
DELETE FROM Employee;

SET FOREIGN_KEY_CHECKS = 1;


-- =========================================================
-- Employees
-- =========================================================
-- Employees working in various HSO locations.
-- Includes current managers and regular employees.

INSERT INTO Employee VALUES
(101, '111111111', 'Roger', 'McDonald',
 '12 Maple St', 'Montreal', 'H1A1A1', 'QC',
 '514-111-1111', 'roger@hso.ca'),

(102, '222222222', 'John', 'Smith',
 '45 King St', 'Laval', 'H2B2B2', 'QC',
 '514-222-2222', 'john@hso.ca'),

(103, '333333333', 'Sarah', 'Johnson',
 '78 Queen St', 'Laval', 'H3C3C3', 'QC',
 '514-333-3333', 'sarah@hso.ca'),

(104, '444444444', 'Emma', 'Brown',
 '90 Park Ave', 'Montreal', 'H4D4D4', 'QC',
 '514-444-4444', 'emma@hso.ca'),

(105, '555555555', 'Michael', 'Wilson',
 '11 Pine Rd', 'Longueuil', 'H5E5E5', 'QC',
 '514-555-5555', 'michael@hso.ca'),
 
(106, '666666666', 'David', 'Lee',
 '88 Oak St', 'Brossard', 'J4W1A1', 'QC',
 '514-666-6666', 'david@hso.ca'),

(107, '777777777', 'Olivia', 'Martin',
 '22 Birch Ave', 'Montreal', 'H2Y2Y2', 'QC',
 '514-777-7777', 'olivia@hso.ca'),

(108, '888888888', 'Daniel', 'Clark',
 '55 Elm St', 'Laval', 'H7A7A7', 'QC',
 '514-888-8888', 'daniel@hso.ca');
 
 
 
-- =========================================================
-- Locations
-- =========================================================
-- Humane Society locations operating across Quebec.

  INSERT INTO Location VALUES
(1, 'Montreal HSO', '100 Main St', 'Montreal','H1M1M1', 'QC'),
(2, 'Laval HSO', '200 Central St', 'Laval','H2L2L2', 'QC'),
(3, 'Longueuil HSO', '300 Riverside Dr', 'Longueuil', 'H3L3L3', 'QC'), 
(4, 'Brossard HSO', '400 South Blvd', 'Brossard', 'J4X4X4', 'QC');

-- =========================================================
-- Management Assignments
-- =========================================================
-- Defines the current manager for each location.
-- Each manager may manage only one location and
-- each location must have exactly one manager.

 INSERT INTO Manage VALUES
(101, 1),
(103, 2),
(105, 3),
(106, 4);

-- =========================================================
-- Employment History
-- =========================================================
-- Tracks employee work history including transfers between locations and re-employment periods.

INSERT INTO Employment VALUES
(101, 1, '2018-01-01', '2020-12-31'),
(101, 2, '2021-01-01', '2022-12-31'),
(101, 1, '2023-01-01', NULL),
(102, 2, '2022-03-01', NULL),
(103, 2, '2020-01-01', NULL),
(104, 1, '2021-06-01', NULL),
(105, 3, '2019-01-01', NULL),
(106, 4, '2021-03-01', NULL),
(107, 1, '2022-02-01', NULL),
(108, 2, '2023-01-15', NULL);

-- =========================================================
-- Animals
-- =========================================================
-- Animals admitted to the Humane Society.
-- Notes may contain medical information, behavioral observations, or special instructions.

INSERT INTO Animal
(AID, type, gender, chipNo, notes)
VALUES
(201, 'Dog', 'Male', 'CH001', NULL),
(202, 'Cat', 'Female', 'CH002', NULL),
(203, 'Dog', 'Female', 'CH003', NULL),
(204, 'Rabbit', 'Male', 'CH004', NULL),
(205, 'Cat', 'Female', 'CH005', NULL),
(206, 'Other', 'Male', 'CH006', 'Snake, Vaccinated'),
(207, 'Dog', 'Female', 'CH007', 'German Shepherd, Vaccinated'),
(208, 'Bird', 'Male', 'CH008', 'Parakeet, Friendly'),
(209, 'Cat', 'Male', 'CH009', 'Requires Special Diet'),
(210, 'Rabbit', 'Female', 'CH010', 'Very Friendly'),
(211, 'Dog', 'Male', 'CH011', 'Senior Dog'),
(212, 'Hamster', 'Female', 'CH012', 'Highly Active');

-- =========================================================
-- Adopters
-- =========================================================
-- Individuals who adopt animals from the organization.
-- animalsCount is maintained automatically through adoption triggers.

INSERT INTO Adopter VALUES
('900111111', 'Alfred Simpson', '10 Adoption St', 'Montreal',
 'H1X1X1', 'QC', '514-900-1111', 2),

('900222222', 'Mary Green', '20 Pet Rd', 'Laval', 
 'H2X2X2', 'QC', '514-900-2222',1),

('900333333', 'Robert White', '30 Animal Ave', 'Longueuil',
 'H3X3X3', 'QC', '514-900-3333', 0),

('900444444', 'Lisa Carter', '15 River Rd', 'Brossard',
 'J4W4W4', 'QC', '514-900-4444', 0),

('900555555', 'James Hall', '50 Lake Dr', 'Montreal',
 'H3P3P3', 'QC', '514-900-5555', 0),

('900666666', 'Sophie Turner', '72 Garden St', 'Laval',
 'H7R7R7', 'QC', '514-900-6666', 0),
 
('900777777','Emily Parker','123 Wellington St',
'Ottawa','K1A0A1','ON','613-777-7777', 0),

('900888888','Ryan Cooper','456 University Ave',
'Toronto','M5G1V2','ON','416-888-8888', 0);
 
-- =========================================================
-- Admissions
-- =========================================================
-- Records when an animal is admitted to a location, including the employee that processed the admission
-- and the previous owner's SSN.

INSERT INTO Admission VALUES
(201, 1, 104, '2020-05-01', '555001111'),
(202, 2, 102, '2020-06-01', '555002222'),
(203, 2, 102, '2021-01-10', '555003333'),
(204, 1, 104, '2021-05-20', '555004444'),
(205, 3, 105, '2021-11-15', '555005555'),
(206, 3, 105, '2022-01-10', '555006666'),
(207, 1, 104, '2022-03-01', '555007777'),
(208, 2, 108, '2022-04-12', '555008888'),
(209, 4, 106, '2022-05-22', '555009999'),
(210, 1, 107, '2022-06-15', '555010101'),
(211, 2, 102, '2022-08-01', '555011111'),
(212, 4, 106, '2022-09-20', '555012121');

-- =========================================================
-- Adoptions
-- =========================================================
-- Records completed adoptions.
-- Triggers automatically:
--   • Validate adoption dates
--   • Update adopter animal counts


INSERT INTO Adoption VALUES
(201, '900111111', 104, '2021-01-05'), 
(202, '900222222', 103, '2021-02-10'),
(203, '900111111', 102, '2021-03-15'),
(204, '900333333', 104, '2021-06-20'),
(206, '900444444', 105, '2022-02-15'),
(207, '900555555', 104, '2022-04-10'),
(208, '900666666', 108, '2022-05-01'),
(209, '900444444', 106, '2022-06-01'),
(210,'900777777',107,'2022-07-01'),
(211,'900888888',102,'2022-08-10'),
(202, '900111111', 103, '2021-07-01'), -- Cat
(204, '900111111', 104, '2021-07-02'), -- Rabbit
(208, '900111111', 108, '2022-06-01'), -- Bird
(212, '900111111', 106, '2022-10-01'), -- Hamster
(206, '900111111', 105, '2022-03-01'); -- Other
