-- ล้างตารางเดิมทั้งหมด
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/
PURGE RECYCLEBIN;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';


-- 1. CATEGORY
CREATE TABLE Category (
    CatagoryID VARCHAR2(10) PRIMARY KEY,
    CatagoryName VARCHAR2(100)
);

-- 2. WMS (ระบบ WMS)
CREATE TABLE WMS(
    Address VARCHAR2(255) PRIMARY KEY,
    Counts NUMBER(10),
    RegisterDate DATE
);

-- 3.WAREHOUSE 
CREATE TABLE WareHouse (
    WareHouseID VARCHAR2(10) PRIMARY KEY,
    Address VARCHAR2(255),
    WMS_Address VARCHAR2(255),
    Latest_Check    DATE,
    Check_Approval  VARCHAR2(20),
    CONSTRAINT UQ_WareHouse_WMS UNIQUE (WMS_Address),
    CONSTRAINT FK_WareHouse_WMS FOREIGN KEY (WMS_Address)
        REFERENCES WMS(Address)
);

-- 4. DEPARTMENT
CREATE TABLE Department (
    DepartmentID VARCHAR2(10) PRIMARY KEY,
    DepartmentName VARCHAR2(100),
    MgrEmployeeID VARCHAR2(10),
    MgrDate DATE,
    CONSTRAINT UQ_Department_Mgr UNIQUE (MgrEmployeeID)
);

-- 5.EMPLOYEE
CREATE TABLE Employee (
    EmployeeId      VARCHAR2(10) PRIMARY KEY,
    FirstName       VARCHAR2(50),
    LastName        VARCHAR2(50),
    WorkStatus      VARCHAR2(20),
    Salary          NUMBER(10,2),
    StartDate       DATE,
    ResignDate      DATE,
    DepartmentId    VARCHAR2(10),
    WMSAddress      VARCHAR2(255),
    SupervisorId    VARCHAR2(10),
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentId)
        REFERENCES Department(DepartmentId),
    CONSTRAINT FK_Employee_WMS FOREIGN KEY (WMSAddress)
        REFERENCES WMS(Address),
    CONSTRAINT FK_Employee_Supervisor FOREIGN KEY (SupervisorId)
        REFERENCES Employee(EmployeeId)
);

-- 6.Item
CREATE TABLE Item (
    ItemID          VARCHAR2(10) PRIMARY KEY,
    Price           NUMBER(10, 2),
    ArrivalDate     DATE,
    CostPrice       NUMBER(10, 2),
    SalePrice       NUMBER(10, 2),
    Counts          NUMBER(10, 2),
    WareHouseID     VARCHAR2(10),
    CatagoryID    VARCHAR2(10),
    WMS_Address     VARCHAR2(255),
    CONSTRAINT FK_Item_Warehouse FOREIGN KEY (WareHouseID)
        REFERENCES WareHouse(WareHouseID),
    CONSTRAINT FK_Item_Catagory FOREIGN KEY (CatagoryID)
        REFERENCES Category(CatagoryID),
    CONSTRAINT FK_Item_WMS FOREIGN KEY (WMS_Address)
        REFERENCES WMS(Address)
);


-----------------------------
-- เพิ่ม Business Constraints
-----------------------------

-- 1. Category
ALTER TABLE Category MODIFY (CatagoryName VARCHAR2(100) NOT NULL);

-- 2. WMS
ALTER TABLE WMS MODIFY (RegisterDate DEFAULT SYSDATE NOT NULL);

-- 3. WAREHOUSE
ALTER TABLE WareHouse MODIFY (WMS_Address VARCHAR2(255) NOT NULL);
ALTER TABLE WareHouse 
    ADD CONSTRAINT CK_WareHouse_Approval
    CHECK (Check_Approval IN ('Pending','Approved','Rejected'));

-- 4. DEPARTMENT
ALTER TABLE Department MODIFY (DepartmentName VARCHAR2(100) NOT NULL); --Modify val of the col

-- 5. EMPLOYEE
ALTER TABLE Employee ADD (Check_EmpStatus VARCHAR2(100) NOT NULL); --Add new col into the table
ALTER TABLE Employee
    ADD CONSTRAINT CK_Employee_Status
    CHECK (Check_EmpStatus IN ('Arrival', 'Not_Arrival'));

ALTER TABLE Employee
    ADD CONSTRAINT CK_Employee_Salary
    CHECK (Salary > 0)
    ENABLE VALIDATE;

ALTER TABLE Employee
    ADD CONSTRAINT CK_Employee_ResignDate
    CHECK (RegisterDate IS NULL OR RegisterDate >= StartDate)
    ENABLE VALIDATE;

ALTER TABLE Employee
    ADD CONSTRAINT CK_WorkStatus
    CHECK (WorkStatus IN ('W', 'Q'));

-- กันพนักงาน เป็นหัวหน้าตัวเอง 
ALTER TABLE Employee
    ADD CONSTRAINT CK_Employee_Supervisor
    CHECK (SupervisorId IS NULL OR SupervisorId <> EmployeeId)
    ENABLE VALIDATE;



-- 6. Item
ALTER TABLE Item MODIFY (Price NUMBER(10, 2) NOT NULL);
ALTER TABLE Item
    ADD CONSTRAINT CK_Item_Counts
    CHECK (Counts >= 0)
    ENABLE VALIDATE;

ALTER TABLE Item
    ADD CONSTRAINT CK_Item_Price
    CHECK (Price > 0 AND CostPrice > 0 AND SalePrice > 0)
    ENABLE VALIDATE;


-------------------------------------------------------------
-- Derived Attribute: Department.Total_Employee (คำนวณจาก Employee)
-------------------------------------------------------------
CREATE OR REPLACE VIEW V_Department_Total AS
SELECT d.DepartmentID,
       d.DepartmentName,
       COUNT(e.EmployeeID) AS Total_Employee
FROM   Department d
LEFT JOIN Employee e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName;



COMMIT;