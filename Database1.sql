-- DDL

DROP TABLE Tickets CASCADE CONSTRAINTS;
DROP TABLE Donations CASCADE CONSTRAINTS;
DROP TABLE Staff CASCADE CONSTRAINTS;
DROP TABLE Utilities CASCADE CONSTRAINTS;
DROP TABLE Financial_Reports CASCADE CONSTRAINTS;
DROP TABLE Exhibits CASCADE CONSTRAINTS;
DROP TABLE Museum CASCADE CONSTRAINTS;


-- Create Museum Table
CREATE TABLE Museum (
    MuseumID NUMBER PRIMARY KEY, -- Unique identifier for the museum
    Name VARCHAR2(100) NOT NULL, -- Museum name
    Location VARCHAR2(50),      -- Location of the museum
    EstablishmentDate DATE,      -- Date when the museum was established
    AnnualBudget NUMBER          -- Annual budget for museum operations
);

-- Create Exhibits Table
CREATE TABLE Exhibits (
    ExhibitID NUMBER PRIMARY KEY,         -- Unique identifier for the exhibit
    MuseumID NUMBER NOT NULL,             -- Foreign key referencing Museum
    Name VARCHAR2(100) NOT NULL,          -- Exhibit name
    StartDate DATE,                       -- Start date of the exhibit
    EndDate DATE,                         -- End date of the exhibit
    MaintenanceCost NUMBER,               -- Maintenance cost for the exhibit
    RevenueGenerated NUMBER,              -- Revenue generated from the exhibit
    Description VARCHAR2(300),            -- Description of the exhibit
    CONSTRAINT FK_Exhibits_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID)
);



-- Create Tickets Table
CREATE TABLE Tickets (
    TicketID NUMBER PRIMARY KEY,          -- Unique identifier for the ticket
    ExhibitID NUMBER NOT NULL,            -- Foreign key referencing Exhibits
    Date DATE NOT NULL,                   -- Date of ticket purchase
    VisitorName VARCHAR2(100),            -- Name of the visitor
    TicketPrice NUMBER NOT NULL,          -- Price of a single ticket
    Quantity NUMBER NOT NULL,             -- Number of tickets purchased
    TotalAmount AS (TicketPrice * Quantity) VIRTUAL, -- Computed column for total amount
    CONSTRAINT FK_Tickets_Exhibits FOREIGN KEY (ExhibitID) REFERENCES Exhibits(ExhibitID)
);

-- Create Donations Table
CREATE TABLE Donations (
    DonationID NUMBER PRIMARY KEY,        -- Unique identifier for the donation
    MuseumID NUMBER NOT NULL,             -- Foreign key referencing Museum
    DonorName VARCHAR2(100),              -- Name of the donor
    DonationAmount NUMBER NOT NULL,       -- Donation amount
    DonationDate DATE NOT NULL,           -- Date of the donation
    Purpose VARCHAR2(300),                -- Purpose of the donation
    CONSTRAINT FK_Donations_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID)
);

-- Create Staff Table
CREATE TABLE Staff (
    StaffID NUMBER PRIMARY KEY,           -- Unique identifier for the staff member
    MuseumID NUMBER NOT NULL,             -- Foreign key referencing Museum
    Name VARCHAR2(100) NOT NULL,          -- Name of the staff member
    Role VARCHAR2(50),                    -- Role (e.g., Curator, Manager)
    Salary NUMBER NOT NULL,               -- Monthly salary of the staff member
     SupervisorID NUMBER,
     
                        
    CONSTRAINT FK_Staff_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID)
);
ALTER TABLE Staff
ADD HireDate DATE; -- Date of hiring

-- Create Utilities Table
CREATE TABLE Utilities (
    UtilityID NUMBER PRIMARY KEY,         -- Unique identifier for the utility expense
    MuseumID NUMBER NOT NULL,             -- Foreign key referencing Museum
    UtilityType VARCHAR2(50),             -- Type of utility (e.g., Electricity, Water)
    Cost NUMBER NOT NULL,                 -- Cost of the utility
    ExpenseDate DATE NOT NULL,            -- Date of the utility expense
    CONSTRAINT FK_Utilities_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID)
);

-- Create Financial_Reports Table
CREATE TABLE Financial_Reports (
    ReportID NUMBER PRIMARY KEY,          -- Unique identifier for the financial report
    MuseumID NUMBER NOT NULL,             -- Foreign key referencing Museum
    Month DATE NOT NULL,                  -- Month and year of the report (store as DATE, truncate day)
    TotalRevenue NUMBER,                  -- Total revenue during the month
    TotalExpenses NUMBER,                 -- Total expenses during the month
    ProfitOrLoss AS (TotalRevenue - TotalExpenses) VIRTUAL, -- Computed column for profit or loss
    CONSTRAINT FK_FinancialReports_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID)
);

-- DML

INSERT INTO Museum (MuseumID, Name, Location,AnnualBudget) VALUES (1, 'National History Museum', 'New York', 2311);
INSERT INTO Museum (MuseumID, Name, Location, EstablishmentDate, AnnualBudget)
VALUES (2, 'Grigore Antipa National Museum of Natural History', 'Bucharest', TO_DATE('1999-11-23', 'YYYY-MM-DD'), 500000);

INSERT INTO Exhibits (ExhibitID, MuseumID, Name, MaintenanceCost, RevenueGenerated)
VALUES (1, 1, 'Dinosaur Fossils', 5000, 20000);

INSERT INTO Staff (StaffID, MuseumID, Name, Role, Salary, HireDate, SupervisorID) 
VALUES (1, 2,'Daniel Harton', 'Receptionist',3500,TO_DATE('2018-10-20','YYYY-MM-DD'),2);
INSERT INTO Staff (StaffID, MuseumID, Name, Role, Salary, HireDate, SupervisorID ) 
VALUES (2, 2,'Victor Dumitrescu', 'Manager',3500,TO_DATE('2018-10-20','YYYY-MM-DD'),NULL);

INSERT INTO Donations (DonationID, MuseumID, DonorName,DonationAmount,DonationDate)
VALUES (1,1,'Michael Johnson',1000,TO_DATE('2022-11-3','YYYY-MM-DD'));
INSERT INTO Donations (DonationID, MuseumID, DonorName,DonationAmount,DonationDate, Purpose)

VALUES (2,1,'Daniel Harton',350,TO_DATE('2013-08-2','YYYY-MM-DD'),'Mantaining existing items in good shape');
INSERT INTO Financial_reports (ReportID, MuseumID, Month,TotalRevenue,TotalExpenses)
VALUES (1,1,TO_DATE('2023-02','YYYY-MM'),2000,100);



UPDATE Exhibits
SET RevenueGenerated = 51000
WHERE ExhibitID != 2;

DELETE FROM Donations WHERE DonationID = 1;

MERGE INTO Financial_Reports FR
USING (SELECT MuseumID, SUM(RevenueGenerated) AS TotalRevenue FROM Exhibits GROUP BY MuseumID) ER
ON (FR.MuseumID = ER.MuseumID)
WHEN MATCHED THEN
    UPDATE SET FR.TotalRevenue = ER.TotalRevenue;




--1 Find exhibits that generate significant revenue
SELECT * FROM Exhibits WHERE RevenueGenerated > 10000;
--2 Identify moderate-level donations for analysis
SELECT * FROM Donations WHERE DonationAmount BETWEEN 100 AND 1000;
--3 Match exhibits to their respective museums for reporting or analysis.
SELECT E.Name AS ExhibitName, M.Name AS MuseumName
FROM Exhibits E
INNER JOIN Museum M ON E.MuseumID = M.MuseumID;
--4 Find museums that generate substantial revenue from their exhibits.
SELECT MuseumID, SUM(RevenueGenerated) AS TotalRevenue
FROM Exhibits GROUP BY MuseumID
HAVING SUM(RevenueGenerated) >= 50000;

--5 create a list of all individuals associated with the museum, whether as staff members or donors, without duplication.
SELECT Name FROM Staff
UNION
SELECT DonorName FROM Donations;
--6 Retrieve all exhibits for a specific museum:
SELECT ExhibitID, Name, MuseumID, RevenueGenerated
FROM Exhibits
WHERE MuseumID = 1;
--7 Retrieve museums with budgets greater than $1,000,000:
SELECT MuseumID, Name, Location, AnnualBudget
FROM Museum
WHERE AnnualBudget > 100090;
--8 Find exhibits with revenue between $10,000 and $50,000:
SELECT ExhibitID, Name, RevenueGenerated
FROM Exhibits
WHERE RevenueGenerated BETWEEN 9000 AND 52000;
--9 List all staff members whose names start with "A":
SELECT StaffID, Name, Role
FROM Staff
WHERE Name LIKE 'D%';
--10 Total revenue generated by each museum:
SELECT MuseumID, SUM(RevenueGenerated) AS TotalRevenue
FROM Exhibits
GROUP BY MuseumID;
--11 Count the total number of exhibits in each museum:
SELECT MuseumID, COUNT(*) AS ExhibitCount
FROM Exhibits
GROUP BY MuseumID;
--12 Total donations received for each purpose:
SELECT Purpose, SUM(DonationAmount) AS TotalDonations
FROM Donations
GROUP BY Purpose;
--13 List all exhibits with their museum names:
SELECT E.ExhibitID, E.Name, M.Name AS MuseumName, E.RevenueGenerated
FROM Exhibits E
JOIN Museum M ON E.MuseumID = M.MuseumID;
--14 Inner Join Display all staff members and the museums they work for:
SELECT S.StaffID, S.Name AS StaffName, M.Name AS MuseumName
FROM Staff S
JOIN Museum M ON S.MuseumID = M.MuseumID;
--15 Inner Join Retrieve financial reports with total expenses and total revenue:
SELECT FR.ReportID, M.Name AS MuseumName, FR.TotalRevenue, FR.TotalExpenses
FROM Financial_Reports FR
JOIN Museum M ON FR.MuseumID = M.MuseumID;
--16 Left Outer Join
SELECT S.StaffID, S.Name AS StaffName, M.Name AS MuseumName
FROM Staff S
LEFT JOIN Museum M ON S.MuseumID = M.MuseumID;

--17 Show current date
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS CurrentDate FROM DUAL;
--18 Show the first 5 characters of every exhibit name
SELECT SUBSTR(Name, 1, 5) AS ShortName FROM Exhibits;
--19 Extracts the year from the DateEstablished column in the Museum table
SELECT Name AS MuseumName, EXTRACT(YEAR FROM EstablishmentDate) AS EstablishmentYear
FROM Museum;
--20 If Role = 'Manager', it outputs 'Head of Department', otherwise it outputs 'Staff'.
SELECT Name AS StaffName, DECODE(Role, 'Manager', 'Head of Department', 'Staff') AS RoleDescription
FROM Staff;
--21 Categorizes exhibits based on their revenue
SELECT Name AS ExhibitName,
       CASE 
         WHEN RevenueGenerated > 5000 THEN 'High Revenue'
         WHEN RevenueGenerated BETWEEN 1000 AND 5000 THEN 'Moderate Revenue'
         ELSE 'Low Revenue'
       END AS RevenueCategory
FROM Exhibits;
--22 nvl
SELECT DonorName AS Name, NVL(Purpose, 'No Purpose Provided') AS Purpose
FROM Donations;
--23 minus - Lists museums that have no associated staff
SELECT Name AS MuseumName
FROM Museum
MINUS
SELECT DISTINCT M.Name
FROM Museum M
JOIN Staff S ON M.MuseumID = S.MuseumID;
--24 Lists names that appear in both the Staff table and the Donations table
SELECT Name AS StaffName
FROM Staff
INTERSECT
SELECT DonorName
FROM Donations;
--25 is null
SELECT Name AS ExhibitName
FROM Exhibits
WHERE StartDate IS NULL;
--26 in - Lists all exhibits belonging to museums with IDs 1, 2, or 3.

SELECT Name AS ExhibitName
FROM Exhibits
WHERE MuseumID IN (1, 2, 3);
--27 Lists exhibits whose revenue is greater than the smallest total revenue of museum 1.
SELECT Name AS ExhibitName
FROM Exhibits
WHERE RevenueGenerated > ANY (
  SELECT TotalRevenue
  FROM Financial_Reports
  WHERE MuseumID = 1
);
--28 all
SELECT Name AS ExhibitName
FROM Exhibits
WHERE RevenueGenerated > ALL (
  SELECT TotalRevenue
  FROM Financial_Reports
  WHERE MuseumID = 1
);
--29 hierarchical query
SELECT LEVEL AS HierarchyLevel,
       SYS_CONNECT_BY_PATH(Name, ' -> ') AS ReportingPath,
       Name AS StaffName,
       Role
FROM Staff
CONNECT BY PRIOR StaffID = SupervisorID
START WITH SupervisorID IS NULL;


