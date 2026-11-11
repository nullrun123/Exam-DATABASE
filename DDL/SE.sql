-- ล้างตารางเดิมทั้งหมด
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/
BEGIN
    FOR v IN (SELECT view_name FROM user_views) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;
END;
/
PURGE RECYCLEBIN;
 
-- create table

-- 1.ข้อมูลการเงินของผู้ใช้
CREATE TABLE UserCurrencyData (
    AccountID   VARCHAR2(10) PRIMARY KEY
);

-- 2. แผนการเงิน
CREATE TABLE CurrencyPlan (
    PlanID          VARCHAR2(10) PRIMARY KEY,
    AccountID       VARCHAR2(10),
    PlanName        NVARCHAR2(255),
    PlanDescription NVARCHAR2(255),
    PlanDate        DATE,
    Amount          NUMBER(12,2),
    DateCreate      DATE,
    DateEdit        DATE,
    CONSTRAINT FK_PlanUser FOREIGN KEY (AccountID)
        REFERENCES UserCurrencyData(AccountID)
);


-- 3.TRANSACTIONS  
CREATE TABLE Transactions (
    TransactionID   VARCHAR2(10) PRIMARY KEY,
    AccountID       VARCHAR2(10),
    TransName       VARCHAR2(255),
    TransDate       DATE,
    TransTime       VARCHAR2(8),          -- รูปแบบ HH24:MI:SS
    Amount          NUMBER(12,2),
    RevenueFlag     NUMBER(1) NOT NULL,              -- T = รายรับ, F = รายจ่าย
    TransDescription VARCHAR2(255),
    CONSTRAINT FK_TransUser FOREIGN KEY (AccountID)
        REFERENCES UserCurrencyData(AccountID)
);


-- 4.TAG
CREATE TABLE Tag (
    TagID       VARCHAR2(10) PRIMARY KEY,
    TagName     VARCHAR2(50)
);

-- TAGLIST  
CREATE TABLE TagList (
    TransactionID   VARCHAR2(10),
    LineNo          NUMBER(5),
    TagID           VARCHAR2(10),
    CONSTRAINT PK_TagList PRIMARY KEY (TransactionID, LineNo),
    CONSTRAINT FK_TagList_Trans FOREIGN KEY (TransactionID)
        REFERENCES Transactions(TransactionID),
    CONSTRAINT FK_TagList_Tag FOREIGN KEY (TagID)
        REFERENCES Tag(TagID)
);

-----------------------------
-- เพิ่ม Business Constraints
-----------------------------

-- 1) CURRENCYPLAN
----------------------------
-- ชื่อแผนต้องไม่เป็นค่าว่าง
ALTER TABLE CurrencyPlan MODIFY (PlanName NVARCHAR2(100) NOT NULL);
 
-- จำนวนเงินในแผนต้องมากกว่า 0
ALTER TABLE CurrencyPlan
  ADD CONSTRAINT CK_Plan_Amount
  CHECK (Amount > 0)
  ENABLE VALIDATE;
 
-- วันที่แก้ไขต้องไม่ก่อนวันที่สร้าง 
ALTER TABLE CurrencyPlan
  ADD CONSTRAINT CK_Plan_DateEdit
  CHECK (DateEdit IS NULL OR DateEdit >= DateCreate)
  ENABLE VALIDATE;
 

-- 3) TRANSACTIONS

-- ชื่อรายการต้องไม่เป็นค่าว่าง
ALTER TABLE Transactions MODIFY (TransName NVARCHAR2(255) NOT NULL);

-- จำนวนเงินต้องมากกว่า 0
ALTER TABLE Transactions
  ADD CONSTRAINT CK_Trans_Amount
  CHECK (Amount > 0)
  ENABLE VALIDATE;

-- Revenue T/F : T = รายรับ, F = รายจ่าย
ALTER TABLE Transactions
  ADD CONSTRAINT CK_Trans_Revenue
  CHECK (RevenueFlag IN (0, 1))
  ENABLE VALIDATE;

-- เวลา ต้องอยู่ในรูปแบบ HH24:MI:SS
ALTER TABLE Transactions
  ADD CONSTRAINT CK_Trans_Time
  CHECK (REGEXP_LIKE(TransTime, '^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'))
  ENABLE VALIDATE;


-- 4) TAG
-- ชื่อแท็กต้องไม่เป็นค่าว่าง และห้ามซ้ำ
ALTER TABLE Tag MODIFY (TagName NVARCHAR2(50) NOT NULL);
 
ALTER TABLE Tag
  ADD CONSTRAINT UQ_Tag_Name UNIQUE (TagName);


-- 5) TAGLIST
-- TagID ต้องไม่เป็นค่าว่าง
ALTER TABLE TagList MODIFY (TagID VARCHAR2(10) NOT NULL);
 


-- 1 รายการ (Transaction) ห้ามติดแท็กเดิมซ้ำ
ALTER TABLE TagList
  ADD CONSTRAINT UQ_TagList_TransTag UNIQUE (TransactionID, TagID);




COMMIT;



