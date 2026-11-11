# 📦 BA — ระบบจัดการคลังสินค้า (Stock Management + WMS)
> **S1G2 | สาขาวิชาวิศวกรรมซอฟต์แวร์**  
> เอกสาร Business Analyst (BA) สำหรับโครงการฐานข้อมูลบริหารคลังสินค้า

---

## 📋 สารบัญ

1. [ภาพรวมระบบ](#1-ภาพรวมระบบ)
2. [Business Needs & Intention](#2-business-needs--intention)
3. [ER Diagram — โครงสร้างตารางทั้งหมด](#3-er-diagram--โครงสร้างตารางทั้งหมด)
4. [DDL — การสร้างตารางและ Constraints](#4-ddl--การสร้างตารางและ-constraints)
5. [DML — ข้อมูลตัวอย่าง](#5-dml--ข้อมูลตัวอย่าง)
6. [PL/SQL — Stored Procedures](#6-plsql--stored-procedures)
7. [Views — Derived Attributes](#7-views--derived-attributes)
8. [คู่มือการรันระบบตั้งแต่ต้น](#8-คู่มือการรันระบบตั้งแต่ต้น)

---

## 1. ภาพรวมระบบ

### ชื่อโครงการ
**ระบบจัดการคลังสินค้า (Warehouse Management System — WMS)**

### วัตถุประสงค์
พัฒนาฐานข้อมูลเพื่อบริหารจัดการคลังสินค้าอย่างมีประสิทธิภาพ ตั้งแต่การรับสินค้า, การจัดเก็บ, การตรวจนับ, ไปจนถึงการปรับยอดสต็อก

### Business Needs
| ความต้องการ | รายละเอียด |
|------------|-----------|
| **Visibility & Real-time Data** | ระบบต้องแสดงจำนวนสินค้าคงคลังแบบ Real-time เพื่อลดความผิดพลาดในการตรวจสต็อก |
| **Process Automation** | ลดขั้นตอนที่ซ้ำซ้อนในคลังสินค้า เพื่อเพิ่มประสิทธิภาพการทำงาน |
| **Cost Reduction** | ลดต้นทุนการบริหารสินค้าคงคลังและลดความสูญเสียสินค้าเสียสภาพ |

### Business Goals/Objectives
- เพิ่มความแม่นยำในการบันทึกข้อมูลสินค้าคงคลัง
- ลดระยะเวลาในการค้นหาและจัดเก็บสินค้า
- ลดมูลค่าความสูญเสียสินค้าเสียสภาพหรือหมดอายุ
- ลดระยะเวลาในกระบวนการอนุมัติปรับยอดสต็อก

---

## 2. Business Needs & Intention

### Business Intention
- มีความสามารถในการตรวจสอบและค้นหาที่นั่งของสินค้าในคลัง โดยระบุตำแหน่งจัดเก็บ (Bin Location) ผ่านระบบคอมพิวเตอร์และเพิ่มประสิทธิภาพการค้นหาสินค้าในระยะยาว
- มีความสามารถในการบริหารสินค้าที่ใกล้หมดหรือหมดแล้ว เพื่อลดการสูญเสียทั้งด้านธุรกิจและสิ่งแวดล้อม

### Process Flow หลัก
#### กระบวนการที่ 1: การจัดเก็บสินค้า
1. **Activity 1**: ตรวจรับและบันทึกข้อมูลสินค้าที่เข้ามา — พนักงานคลังตรวจสอบสินค้าและนับจำนวน ส่งข้อมูลเข้าระบบ
2. **Activity 2**: นำสินค้าเข้าที่จัดเก็บ — ระบบ WMS จะระบุตำแหน่ง Bin Location โดยใช้หลัก FIFO
3. **Activity 3**: ยืนยันการจัดเก็บเข้าระบบ — WMS อัปเดตสถานะสินค้าและแจ้งตำแหน่งจัดเก็บ

#### กระบวนการที่ 2: การตรวจนับสต็อก
4. **Activity 4**: ตรวจนับและยืนยัน — ระบบสร้างงานตรวจนับ ส่งให้พนักงานคลัง (ทุก 30 วัน - 1 ชั่วโมง)
5. **Activity 5**: ตรวจสอบสินค้าและพบคลาดเคลื่อน — ตรวจสอบสต็อกจริงเทียบกับข้อมูลในระบบ
6. **Activity 6**: อนุมัติปรับยอดสต็อก — ผู้จัดการตรวจสอบและอนุมัติใน 24 ชั่วโมง

### Roles / ผู้ที่เกี่ยวข้อง
| Role | หน้าที่ |
|------|--------|
| พนักงานคลังสินค้า | ตรวจรับสินค้า, จัดเก็บสินค้า, สแกนยืนยันตำแหน่ง |
| เจ้าหน้าที่ควบคุมสต็อก | ตรวจสอบ Bin Location, ทำรายงาน |
| ผู้จัดการสาขา/ฝ่ายบัญชี | อนุมัติคำขอปรับยอดสต็อก |
| ระบบ WMS | จัดการข้อมูลสต็อกอัตโนมัติ |

---

## 3. ER Diagram — โครงสร้างตารางทั้งหมด

### ER Diagram ที่เขียนเอง (Original Design)
```
Setup Tables:
├── Category
├── WareHouse
└── Department

Master Tables:
├── ITEMS (สินค้า)
└── Employee (พนักงาน)

Transaction Tables:
├── ระบบ WMS
├── Change Status
├── Check
└── Update
```

### ER Diagram ที่ปรับปรุงแล้ว (AI-Suggested Design)
```
Setup Tables:
└── BIN_LOCATION (ตำแหน่งจัดเก็บ)

Master Tables:
├── SUPPLIER (ผู้จัดส่ง)
├── EMPLOYEE
└── PRODUCT

Transaction Tables:
├── GOODS_RECEIPT (ใบรับสินค้าเข้าคงคลัง)
├── PUTAWAY_RECORD (ใบกำหนดตำแหน่งจัดเก็บ)
├── STOCK_COUNT_REPORT (ใบรายงานผลการตรวจนับสต็อก)
├── DISCREPANCY_REQUEST (ความคลาดเคลื่อน/คำขอปรับยอด)
└── ACCOUNTING_VOUCHER (ใบสำคัญทางบัญชี)
```

### วิพากษ์ ER Diagram
| ด้าน | ER ที่เขียนเอง | ER จาก AI |
|------|---------------|-----------|
| **ข้อดี** | Cardinality ชัดเจน, ไม่มี many-to-many, มี Department+Supervision | ครอบคลุมกระบวนการจัดเก็บและปรับสต็อก, มี Bin Location |
| **ข้อเสีย** | ขาด Entity รองรับกระบวนการจริง (ใบรับ, ใบจัดเก็บ, ใบตรวจนับ) | มี many-to-many 2 เส้น ต้องแตกเป็นตารางกลาง |

---

## 4. DDL — การสร้างตารางและ Constraints

### 4.1 ล้างข้อมูลเก่า

```sql
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/
PURGE RECYCLEBIN;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

### 4.2 ตาราง Category (หมวดหมู่สินค้า)

```sql
CREATE TABLE Category (
    CatagoryID   VARCHAR2(10) PRIMARY KEY,
    CatagoryName VARCHAR2(100) NOT NULL
);
```

| Column | Type | Description |
|--------|------|-------------|
| `CatagoryID` | VARCHAR2(10) | รหัสหมวดหมู่ (PK) |
| `CatagoryName` | VARCHAR2(100) | ชื่อหมวดหมู่ |

### 4.3 ตาราง WMS (ระบบ WMS)

```sql
CREATE TABLE WMS (
    Address      VARCHAR2(255) PRIMARY KEY,
    Counts       NUMBER(10),
    RegisterDate DATE DEFAULT SYSDATE NOT NULL
);
```

| Column | Type | Description |
|--------|------|-------------|
| `Address` | VARCHAR2(255) | ที่อยู่ระบบ WMS (PK) |
| `Counts` | NUMBER(10) | จำนวนสินค้ารวมในระบบ |
| `RegisterDate` | DATE | วันที่ลงทะเบียนระบบ |

### 4.4 ตาราง WareHouse (คลังสินค้า)

```sql
CREATE TABLE WareHouse (
    WareHouseID    VARCHAR2(10)  PRIMARY KEY,
    Address        VARCHAR2(255),
    WMS_Address    VARCHAR2(255) NOT NULL,
    Latest_Check   DATE,
    Check_Approval VARCHAR2(20),
    CONSTRAINT UQ_WareHouse_WMS UNIQUE (WMS_Address),
    CONSTRAINT FK_WareHouse_WMS FOREIGN KEY (WMS_Address)
        REFERENCES WMS(Address),
    CONSTRAINT CK_WareHouse_Approval
        CHECK (Check_Approval IN ('Pending','Approved','Rejected'))
);
```

| Column | Type | Description |
|--------|------|-------------|
| `WareHouseID` | VARCHAR2(10) | รหัสคลัง (PK) |
| `Address` | VARCHAR2(255) | ที่อยู่คลัง |
| `WMS_Address` | VARCHAR2(255) | FK → WMS |
| `Latest_Check` | DATE | วันตรวจล่าสุด |
| `Check_Approval` | VARCHAR2(20) | สถานะ: `Pending`, `Approved`, `Rejected` |

> **ความสัมพันธ์:** WareHouse (1) → WMS (1) — คลังหนึ่งแห่งใช้ระบบ WMS หนึ่งระบบ

### 4.5 ตาราง Department (แผนก)

```sql
CREATE TABLE Department (
    DepartmentID   VARCHAR2(10) PRIMARY KEY,
    DepartmentName VARCHAR2(100) NOT NULL,
    MgrEmployeeID  VARCHAR2(10),
    MgrDate        DATE,
    CONSTRAINT UQ_Department_Mgr UNIQUE (MgrEmployeeID)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `DepartmentID` | VARCHAR2(10) | รหัสแผนก (PK) |
| `DepartmentName` | VARCHAR2(100) | ชื่อแผนก |
| `MgrEmployeeID` | VARCHAR2(10) | รหัสหัวหน้าแผนก (FK → Employee) |
| `MgrDate` | DATE | วันที่แต่งตั้งหัวหน้า |

### 4.6 ตาราง Employee (พนักงาน)

```sql
CREATE TABLE Employee (
    EmployeeId     VARCHAR2(10) PRIMARY KEY,
    FirstName      VARCHAR2(50),
    LastName       VARCHAR2(50),
    WorkStatus     VARCHAR2(20),   -- 'W' = ทำงาน, 'Q' = ลาออก
    Salary         NUMBER(10,2),
    StartDate      DATE,
    ResignDate     DATE,
    DepartmentId   VARCHAR2(10),
    WMSAddress     VARCHAR2(255),
    SupervisorId   VARCHAR2(10),
    Check_EmpStatus VARCHAR2(100) NOT NULL,  -- 'Arrival' / 'Not_Arrival'
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentId)
        REFERENCES Department(DepartmentId),
    CONSTRAINT FK_Employee_WMS FOREIGN KEY (WMSAddress)
        REFERENCES WMS(Address),
    CONSTRAINT FK_Employee_Supervisor FOREIGN KEY (SupervisorId)
        REFERENCES Employee(EmployeeId),
    CONSTRAINT CK_Employee_Status CHECK (Check_EmpStatus IN ('Arrival', 'Not_Arrival')),
    CONSTRAINT CK_Employee_Salary  CHECK (Salary > 0),
    CONSTRAINT CK_WorkStatus       CHECK (WorkStatus IN ('W', 'Q')),
    CONSTRAINT CK_Employee_Supervisor CHECK (SupervisorId IS NULL OR SupervisorId <> EmployeeId)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `EmployeeId` | VARCHAR2(10) | รหัสพนักงาน (PK) |
| `FirstName` / `LastName` | VARCHAR2(50) | ชื่อ-นามสกุล |
| `WorkStatus` | VARCHAR2(20) | `W` = ทำงานอยู่, `Q` = ลาออก |
| `Salary` | NUMBER(10,2) | เงินเดือน (> 0) |
| `StartDate` / `ResignDate` | DATE | วันเริ่ม / วันลาออก |
| `DepartmentId` | VARCHAR2(10) | FK → Department |
| `WMSAddress` | VARCHAR2(255) | FK → WMS |
| `SupervisorId` | VARCHAR2(10) | FK → Employee (self-join) |
| `Check_EmpStatus` | VARCHAR2(100) | `Arrival` / `Not_Arrival` |

> ⚠️ **Business Rule:** พนักงานไม่สามารถเป็นหัวหน้าตัวเองได้ (`SupervisorId <> EmployeeId`)

### 4.7 ตาราง Item (สินค้า)

```sql
CREATE TABLE Item (
    ItemID      VARCHAR2(10) PRIMARY KEY,
    Price       NUMBER(10,2) NOT NULL,
    ArrivalDate DATE,
    CostPrice   NUMBER(10,2),
    SalePrice   NUMBER(10,2),
    Counts      NUMBER(10,2),
    WareHouseID VARCHAR2(10),
    CatagoryID  VARCHAR2(10),
    WMS_Address VARCHAR2(255),
    CONSTRAINT FK_Item_Warehouse FOREIGN KEY (WareHouseID)
        REFERENCES WareHouse(WareHouseID),
    CONSTRAINT FK_Item_Catagory  FOREIGN KEY (CatagoryID)
        REFERENCES Category(CatagoryID),
    CONSTRAINT FK_Item_WMS       FOREIGN KEY (WMS_Address)
        REFERENCES WMS(Address),
    CONSTRAINT CK_Item_Counts    CHECK (Counts >= 0),
    CONSTRAINT CK_Item_Price     CHECK (Price > 0 AND CostPrice > 0 AND SalePrice > 0)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `ItemID` | VARCHAR2(10) | รหัสสินค้า (PK) |
| `Price` | NUMBER(10,2) | ราคา (ต้อง > 0) |
| `ArrivalDate` | DATE | วันที่รับสินค้า |
| `CostPrice` | NUMBER(10,2) | ราคาต้นทุน |
| `SalePrice` | NUMBER(10,2) | ราคาขาย |
| `Counts` | NUMBER(10,2) | จำนวนคงเหลือ (>= 0) |
| `WareHouseID` | VARCHAR2(10) | FK → WareHouse |
| `CatagoryID` | VARCHAR2(10) | FK → Category |
| `WMS_Address` | VARCHAR2(255) | FK → WMS |

---

## 5. DML — ข้อมูลตัวอย่าง

### 5.1 Category (5 หมวดหมู่)

```sql
INSERT INTO Category VALUES ('CT01','อาหารสด');
INSERT INTO Category VALUES ('CT02','อาหารแห้ง');
INSERT INTO Category VALUES ('CT03','เครื่องดื่ม');
INSERT INTO Category VALUES ('CT04','ขนมหวาน');
INSERT INTO Category VALUES ('CT05','อาหารแช่แข็ง');
```

### 5.2 WMS (3 ระบบ)

```sql
INSERT INTO WMS VALUES ('WMSID1', 930, TO_DATE('10/01/2023','DD/MM/YYYY'));
INSERT INTO WMS VALUES ('WMSID2', 610, TO_DATE('15/06/2023','DD/MM/YYYY'));
INSERT INTO WMS VALUES ('WMSID3', 255, TO_DATE('01/02/2024','DD/MM/YYYY'));
```

### 5.3 WareHouse (3 คลัง)

| WareHouseID | ที่ตั้ง | WMS | สถานะ |
|-------------|---------|-----|-------|
| WH01 | ลาดกระบัง, กรุงเทพฯ | WMSID1 | Approved |
| WH02 | บางพลี, สมุทรปราการ | WMSID2 | Approved |
| WH03 | คลองหลวง, ปทุมธานี | WMSID3 | Pending |

### 5.4 Department (4 แผนก)

| DepartmentID | ชื่อแผนก | หัวหน้า |
|-------------|----------|---------|
| D01 | คลังสินค้า | E001 |
| D02 | ควบคุมสต๊อก | E002 |
| D03 | จัดซื้อ | E003 |
| D04 | ไอทีและระบบ WMS | E004 |

### 5.5 Employee (11 คน)

```sql
-- หัวหน้าแผนก (ไม่มีหัวหน้า)
INSERT INTO Employee VALUES ('E001','วิชัย','สุขสวัสดิ์','W',52000,TO_DATE('15/01/2019','DD/MM/YYYY'),NULL,'D01','WMSID1',NULL,'Arrival');

-- พนักงานทั่วไป (มีหัวหน้า)
INSERT INTO Employee VALUES ('E005','กิตติพัฒน์','แก้วมณี','W',22000,TO_DATE('01/03/2022','DD/MM/YYYY'),NULL,'D01','WMSID1','E001','Arrival');

-- พนักงานที่ลาออก
INSERT INTO Employee VALUES ('E010','มนัสนันท์','คำสิงห์','Q',19500,TO_DATE('01/11/2023','DD/MM/YYYY'),TO_DATE('30/06/2025','DD/MM/YYYY'),'D01','WMSID3','E001','Not_Arrival');
```

### 5.6 Item (15 รายการ, จาก 3 คลัง)

| Warehouse | สินค้าตัวอย่าง |
|-----------|---------------|
| WH01 (ลาดกระบัง) | ยากิโซบะ, ทาโกยากิ, ซาชิมิปลาแซลมอน |
| WH02 (บางพลี) | น้ำปั่น, คาปูชิโน่เย็น, โมจิ |
| WH03 (คลองหลวง) | เสื้อวินเทจ, คาจูบาร์ฟี, ปานีปูรี |

---

## 6. PL/SQL — Stored Procedures

### 6.1 sp_add_category — เพิ่มหมวดหมู่

```sql
CREATE OR REPLACE PROCEDURE sp_add_category (
    p_catid   IN VARCHAR2,
    p_catname IN VARCHAR2
) AS
BEGIN
    INSERT INTO Category (CatagoryID, CatagoryName)
    VALUES (p_catid, p_catname);
    DBMS_OUTPUT.PUT_LINE('เพิ่มหมวดหมู่สินค้าเรียบร้อย: ' || p_catid);
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
EXEC sp_add_category('CT06', 'ของใช้ในบ้าน');
```

### 6.2 sp_register_wms — ลงทะเบียนระบบ WMS

```sql
CREATE OR REPLACE PROCEDURE sp_register_wms (
    p_address IN VARCHAR2,
    p_regdate IN DATE
) AS
BEGIN
    INSERT INTO WMS (Address, RegisterDate)
    VALUES (p_address, NVL(p_regdate, SYSDATE));
    DBMS_OUTPUT.PUT_LINE('ลงทะเบียนระบบ WMS เรียบร้อย: ' || p_address);
END;
/
```

### 6.3 sp_create_warehouse — เพิ่มคลังสินค้า

```sql
CREATE OR REPLACE PROCEDURE sp_create_warehouse (
    p_whid         IN VARCHAR2,
    p_address      IN VARCHAR2,
    p_wms_address  IN VARCHAR2,
    p_latest_check IN DATE,
    p_approval     IN VARCHAR2
) AS
BEGIN
    INSERT INTO WareHouse (WareHouseID, Address, WMS_Address, Latest_Check, Check_Approval)
    VALUES (p_whid, p_address, p_wms_address, p_latest_check, TRIM(p_approval));
    DBMS_OUTPUT.PUT_LINE('เพิ่มคลังสินค้าใหม่เรียบร้อย: ' || p_whid);
END;
/
```

### 6.4 sp_create_department — เพิ่มแผนก

```sql
CREATE OR REPLACE PROCEDURE sp_create_department (
    p_depid     IN VARCHAR2,
    p_depname   IN VARCHAR2,
    p_mgr_empid IN VARCHAR2,
    p_mgrdate   IN DATE
) AS
BEGIN
    INSERT INTO Department (DepartmentID, DepartmentName, MgrEmployeeID, MgrDate)
    VALUES (p_depid, p_depname, p_mgr_empid, p_mgrdate);
    DBMS_OUTPUT.PUT_LINE('เพิ่มแผนกใหม่เรียบร้อย: ' || p_depid);
END;
/
```

### 6.5 sp_add_employee — เพิ่มพนักงาน

```sql
CREATE OR REPLACE PROCEDURE sp_add_employee (
    p_empid        IN VARCHAR2,
    p_firstname    IN VARCHAR2,
    p_lastname     IN VARCHAR2,
    p_workstatus   IN VARCHAR2,
    p_salary       IN NUMBER,
    p_startdate    IN DATE,
    p_resigndate   IN DATE,
    p_depid        IN VARCHAR2,
    p_wmsaddress   IN VARCHAR2,
    p_supervisorid IN VARCHAR2,
    p_empstatus    IN VARCHAR2
) AS
BEGIN
    INSERT INTO Employee (EmployeeId, FirstName, LastName, WorkStatus, Salary, StartDate,
                          ResignDate, DepartmentId, WMSAddress, SupervisorId, Check_EmpStatus)
    VALUES (p_empid, p_firstname, p_lastname, TRIM(p_workstatus), p_salary, p_startdate,
            p_resigndate, p_depid, p_wmsaddress, p_supervisorid, TRIM(p_empstatus));
    DBMS_OUTPUT.PUT_LINE('เพิ่มพนักงานใหม่เรียบร้อย: ' || p_empid);
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
EXEC sp_add_employee(
    'E012', 'สมหมาย', 'ใจดี', 'W', 25000,
    TO_DATE('01/11/2026','DD/MM/YYYY'), NULL,
    'D01', 'WMSID1', 'E001', 'Arrival'
);
```

### 6.6 sp_add_item — เพิ่มสินค้า

```sql
CREATE OR REPLACE PROCEDURE sp_add_item (
    p_itemid      IN VARCHAR2,
    p_price       IN NUMBER,
    p_arrivaldate IN DATE,
    p_costprice   IN NUMBER,
    p_saleprice   IN NUMBER,
    p_counts      IN NUMBER,
    p_whid        IN VARCHAR2,
    p_catid       IN VARCHAR2,
    p_wms_address IN VARCHAR2
) AS
BEGIN
    INSERT INTO Item (ItemID, Price, ArrivalDate, CostPrice, SalePrice, Counts,
                      WareHouseID, CatagoryID, WMS_Address)
    VALUES (p_itemid, p_price, p_arrivaldate, p_costprice, p_saleprice, p_counts,
            p_whid, p_catid, p_wms_address);
    DBMS_OUTPUT.PUT_LINE('เพิ่มสินค้าใหม่เรียบร้อย: ' || p_itemid);
END;
/
```

### 6.7 sp_update_item_stock — ปรับจำนวนสินค้า

```sql
CREATE OR REPLACE PROCEDURE sp_update_item_stock (
    p_itemid IN VARCHAR2,
    p_amount IN NUMBER
) AS
BEGIN
    UPDATE Item
    SET Counts = Counts - p_amount
    WHERE ItemID = p_itemid;
    DBMS_OUTPUT.PUT_LINE('ปรับจำนวนสินค้าเรียบร้อย: ' || p_itemid);
END;
/
```

**ตัวอย่างการเรียกใช้:** (ลดสต็อก IT001 จำนวน 10 ชิ้น)
```sql
EXEC sp_update_item_stock('IT001', 10);
```

### 6.8 sp_approve_warehouse — อนุมัติ/ปฏิเสธคลัง

```sql
CREATE OR REPLACE PROCEDURE sp_approve_warehouse (
    p_whid     IN VARCHAR2,
    p_approval IN VARCHAR2
) AS
BEGIN
    UPDATE WareHouse
    SET Check_Approval = TRIM(p_approval),
        Latest_Check   = SYSDATE
    WHERE WareHouseID = p_whid;
    DBMS_OUTPUT.PUT_LINE('อัปเดตผลการตรวจคลังสินค้าเรียบร้อย: ' || p_whid);
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
EXEC sp_approve_warehouse('WH03', 'Approved');
```

### 6.9 sp_update_employee_status — อัปเดตสถานะพนักงาน

```sql
CREATE OR REPLACE PROCEDURE sp_update_employee_status (
    p_empid     IN VARCHAR2,
    p_empstatus IN VARCHAR2
) AS
BEGIN
    UPDATE Employee
    SET Check_EmpStatus = TRIM(p_empstatus)
    WHERE EmployeeId = p_empid;
    DBMS_OUTPUT.PUT_LINE('อัปเดตสถานะการเข้างานเรียบร้อย: ' || p_empid);
END;
/
```

### 6.10 sp_resign_employee — บันทึกการลาออก

```sql
CREATE OR REPLACE PROCEDURE sp_resign_employee (
    p_empid      IN VARCHAR2,
    p_resigndate IN DATE
) AS
BEGIN
    UPDATE Employee
    SET WorkStatus = 'Q',
        ResignDate = NVL(p_resigndate, SYSDATE)
    WHERE EmployeeId = p_empid;
    DBMS_OUTPUT.PUT_LINE('บันทึกการลาออกของพนักงานเรียบร้อย: ' || p_empid);
END;
/
```

### 6.11 sp_assign_department_manager — แต่งตั้งหัวหน้าแผนก

```sql
CREATE OR REPLACE PROCEDURE sp_assign_department_manager (
    p_depid     IN VARCHAR2,
    p_mgr_empid IN VARCHAR2
) AS
BEGIN
    UPDATE Department
    SET MgrEmployeeID = p_mgr_empid,
        MgrDate       = SYSDATE
    WHERE DepartmentID = p_depid;
    DBMS_OUTPUT.PUT_LINE('แต่งตั้งหัวหน้าแผนกเรียบร้อย: ' || p_depid);
END;
/
```

### สรุป Stored Procedures ทั้งหมด (BA)

| Procedure | หน้าที่ | ประเภท |
|-----------|---------|--------|
| `sp_add_category` | เพิ่มหมวดหมู่ | INSERT |
| `sp_register_wms` | ลงทะเบียน WMS | INSERT |
| `sp_create_warehouse` | เพิ่มคลังสินค้า | INSERT |
| `sp_create_department` | เพิ่มแผนก | INSERT |
| `sp_add_employee` | เพิ่มพนักงาน | INSERT |
| `sp_add_item` | เพิ่มสินค้า | INSERT |
| `sp_update_item_stock` | ปรับจำนวนสินค้า | UPDATE |
| `sp_approve_warehouse` | อนุมัติ/ปฏิเสธคลัง | UPDATE |
| `sp_update_employee_status` | อัปเดตสถานะพนักงาน | UPDATE |
| `sp_resign_employee` | บันทึกการลาออก | UPDATE |
| `sp_assign_department_manager` | แต่งตั้งหัวหน้าแผนก | UPDATE |

---

## 7. Views — Derived Attributes

### V_Department_Total — จำนวนพนักงานต่อแผนก

```sql
CREATE OR REPLACE VIEW V_Department_Total AS
SELECT d.DepartmentID,
       d.DepartmentName,
       COUNT(e.EmployeeID) AS Total_Employee
FROM   Department d
LEFT JOIN Employee e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName;
```

**การใช้งาน:**
```sql
SELECT * FROM V_Department_Total ORDER BY DepartmentID;
```

---

## 8. คู่มือการรันระบบตั้งแต่ต้น

### สิ่งที่ต้องเตรียม
- Oracle Database (แนะนำ 19c ขึ้นไป) หรือ Oracle 23ai
- SQL*Plus, SQL Developer, หรือ DBeaver
- สิทธิ์ CREATE TABLE, CREATE PROCEDURE, CREATE VIEW

### ขั้นตอนที่ 1 — เชื่อมต่อฐานข้อมูล

```bash
# SQL*Plus
sqlplus username/password@hostname:port/service_name

# หรือ
sqlplus username/password@//localhost:1521/XEPDB1
```

### ขั้นตอนที่ 2 — ตั้งค่า Session

```sql
SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

### ขั้นตอนที่ 3 — รัน DDL (สร้างตาราง)

```bash
# รันไฟล์ DDL
@DDL/BA.sql
```

หรือ copy-paste เนื้อหาทั้งหมดจากไฟล์ `DDL/BA.sql`

> ⚠️ **หมายเหตุ:** สคริปต์จะล้างตารางเก่าทั้งหมดก่อนสร้างใหม่ — ระวังถ้ามีข้อมูลสำคัญ!

### ขั้นตอนที่ 4 — รัน DML (ใส่ข้อมูลตัวอย่าง)

```bash
@DML/BA.sql
```

ลำดับการ INSERT ที่ถูกต้อง:
1. `Category` (ไม่มี FK)
2. `WMS` (ไม่มี FK)
3. `WareHouse` (FK → WMS)
4. `Department` (FK → Employee - ต้อง INSERT Employee ก่อน หรือ defer FK)
5. `Employee` — INSERT หัวหน้า (E001-E004) ก่อน
6. `Item` (FK → WareHouse, Category, WMS)

### ขั้นตอนที่ 5 — รัน PL/SQL (สร้าง Stored Procedures)

```bash
@PL/BA.sql
```

### ขั้นตอนที่ 6 — ทดสอบ

```sql
-- ทดสอบดูข้อมูลทั้งหมด
SELECT * FROM Category;
SELECT * FROM WMS;
SELECT * FROM WareHouse;
SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM Item;

-- ทดสอบ View
SELECT * FROM V_Department_Total;

-- ทดสอบ Procedure
SET SERVEROUTPUT ON

EXEC sp_add_category('CT99', 'ทดสอบ');
EXEC sp_approve_warehouse('WH03', 'Approved');
EXEC sp_resign_employee('E007', SYSDATE);

-- ตรวจสอบผล
SELECT * FROM WareHouse WHERE WareHouseID = 'WH03';
SELECT EmployeeId, WorkStatus, ResignDate FROM Employee WHERE EmployeeId = 'E007';
```

### ขั้นตอนที่ 7 — COMMIT และปิด

```sql
COMMIT;
```

### Troubleshooting

| ปัญหา | วิธีแก้ |
|-------|---------|
| `ORA-02291: integrity constraint violated` | ตรวจสอบลำดับการ INSERT ให้ถูกต้อง (Parent ก่อน Child) |
| `ORA-00001: unique constraint violated` | ข้อมูล ID ซ้ำ — เปลี่ยน ID ใหม่ |
| `ORA-02290: check constraint violated` | ค่าที่ใส่ไม่ตรงกับ constraint (เช่น WorkStatus ต้อง 'W' หรือ 'Q') |
| `ORA-01031: insufficient privileges` | ขอสิทธิ์เพิ่มจาก DBA |

---

*เอกสารนี้จัดทำโดย S1G2 | วิชา Database Systems | ปีการศึกษา 2566*
