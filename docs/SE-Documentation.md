# 💰 SE — แอปพลิเคชันบริหารการเงินส่วนบุคคล (Personal Finance Manager)
> **S1G2 | สาขาวิศวกรรมซอฟต์แวร์**  
> เอกสาร Software Engineer (SE) สำหรับโครงการฐานข้อมูลบริหารการเงินส่วนบุคคล

---

## 📋 สารบัญ

1. [ภาพรวมระบบ](#1-ภาพรวมระบบ)
2. [ที่มาและความสำคัญ](#2-ที่มาและความสำคัญ)
3. [Functional & Non-Functional Requirements](#3-functional--non-functional-requirements)
4. [Architecture](#4-architecture)
5. [ER Diagram — โครงสร้างตารางทั้งหมด](#5-er-diagram--โครงสร้างตารางทั้งหมด)
6. [DDL — การสร้างตารางและ Constraints](#6-ddl--การสร้างตารางและ-constraints)
7. [DML — ข้อมูลตัวอย่าง](#7-dml--ข้อมูลตัวอย่าง)
8. [PL/SQL — Stored Procedures](#8-plsql--stored-procedures)
9. [Views — Derived Attributes](#9-views--derived-attributes)
10. [คู่มือการรันระบบตั้งแต่ต้น](#10-คู่มือการรันระบบตั้งแต่ต้น)

---

## 1. ภาพรวมระบบ

### ชื่อโครงการ
**แอปพลิเคชันบริหารการเงินส่วนบุคคล (Personal Finance Management Application)**

### วัตถุประสงค์
พัฒนาฐานข้อมูลเพื่อช่วยผู้ใช้งาน (นักศึกษาและวัยทำงาน) บันทึก ติดตาม และวิเคราะห์รายรับ-รายจ่ายส่วนบุคคล พร้อมวางแผนการเงินและตั้งเป้าหมายทางการเงิน

### เป้าหมายหลัก
- ช่วยผู้ใช้มองเห็นแนวโน้มการใช้จ่าย
- เปรียบเทียบยอดรายรับ-รายจ่ายระหว่างเดือน
- วางแผนและติดตามงบประมาณ

---

## 2. ที่มาและความสำคัญ

การบริหารจัดการการเงินส่วนบุคคลเป็นทักษะสำคัญที่ส่งผลต่อคุณภาพชีวิตของผู้ใช้งานในระยะยาว โดยเฉพาะกลุ่มนักศึกษาและวัยทำงานเริ่มต้นที่มีรายรับจำกัดและต้องบริหารค่าใช้จ่ายหลายด้านพร้อมกัน

ในปัจจุบันผู้ใช้จำนวนมากยังคงบันทึกรายรับ-รายจ่ายด้วยวิธีที่ไม่เป็นระบบ เช่น การจดบันทึกแบบกระดาษ หรือการใช้สเปรดชีตทั่วไปที่ไม่ได้ออกแบบมาเพื่อการติดตามภาพรวมทางการเงินโดยเฉพาะ ทำให้ยากต่อการมองเห็นแนวโน้มการใช้จ่าย

---

## 3. Functional & Non-Functional Requirements

### Functional Requirements (ความต้องการเชิงฟังก์ชัน)

| รหัส | ความต้องการ |
|------|-----------|
| **Req1** | ผู้ใช้ต้องสามารถบันทึกรายการรายรับ/รายจ่ายได้ พร้อมระบุ วันที่, จำนวนเงิน, หมวดหมู่ และหมายเหตุ |
| **Req2** | ผู้ใช้ต้องสามารถแก้ไขหรือลบรายการที่บันทึกไว้ได้ |
| **Req3** | ระบบต้องรองรับการสร้าง/แก้ไขหมวดหมู่รายรับ-รายจ่ายเองได้ |
| **Req4** | ระบบต้องรองรับรายการที่เกิดซ้ำอัตโนมัติ (รายเดือน/รายสัปดาห์) |
| **Req5** | ระบบต้องแสดงสรุปรายรับ-รายจ่ายรายเดือน/รายปี |
| **Req6** | ผู้ใช้ต้องสามารถเปรียบเทียบยอดใช้จ่ายระหว่างเดือนได้ |

### Non-Functional Requirements (ความต้องการเชิงคุณภาพ)

| ด้าน | รายละเอียด |
|------|-----------|
| **Performance** | หน้า Interface ต้องตอบสนองและแสดงผลทันที หรือเร็วที่สุด |
| **User Friendliness** | หน้า User Interface ต้องใช้งานง่าย เข้าใจง่าย และน่าใช้งาน |
| **Maintainability** | โครงสร้างของโค้ดต้องแยกออกเป็นส่วนๆ เพื่อง่ายต่อการซ่อมบำรุงหรือแก้ไขบัก |
| **Interoperability** | โปรแกรมต้องมีความสามารถในการทำงานร่วมกับโปรแกรมอื่นได้ เช่น ปฏิทิน |
| **Portability** | สามารถใช้งานโปรแกรมในระบบปฏิบัติการที่หลากหลายได้ เช่น iOS, Android, Website |

---

## 4. Architecture

### Architectural Overview
```
S1G2 - แอปพลิเคชันบริหารการเงินส่วนบุคคล
Reference: https://canva.link/z9wkyn0pjcuncmo

[Frontend Layer]        [Backend Layer]        [Database Layer]
  iOS / Android    →    REST API / BFF    →    Oracle Database
  Web Application  →    Business Logic    →    PL/SQL Procedures
                        Finance Engine         Views & Triggers
```

### Technology Stack (แนะนำ)
- **Database**: Oracle Database 23ai (รองรับ BOOLEAN native)
- **Backend**: REST API
- **Frontend**: Cross-platform (iOS, Android, Web)

---

## 5. ER Diagram — โครงสร้างตารางทั้งหมด

### ER Diagram ที่เขียนเอง (Original)
```
Setup Tables:
├── Category (รายรับ)
└── Category (รายจ่าย)

Master Tables:
├── user_currency_data (ข้อมูลการเงินของผู้ใช้)
└── currency_plan (แผนการเงิน)

Transaction Tables:
├── Revenue (รายรับ)
├── Expenses (รายจ่าย)
└── currency_goal (เป้าหมายทางการเงิน)
```

### ER Diagram ที่ปรับปรุงแล้ว (AI-Suggested / Final Design)
```
Setup Tables:
├── Category (หมวดหมู่)
└── Recurring_Setting (รายการประจำ) *

Master Tables:
├── User (ผู้ใช้งาน)
└── Budget (งบประมาณ)

Transaction Tables:
└── Transaction (รายการรายรับ-รายจ่าย)
```

### วิพากษ์ ER Diagram
| ด้าน | ER ที่เขียนเอง | ER จาก AI (Final) |
|------|---------------|------------------|
| **ข้อดี** | ใช้ weak entity, attribute ครบ | โครงสร้างกระชับ, รวม Income+Expense ไว้ใน Transaction เดียว |
| **ข้อเสีย** | Revenue+Expenses ซ้ำซ้อน, Category แยกสองกล่อง | ไม่มี attribute รายละเอียด, Recurring_Setting ไม่มี Req รองรับ |

### ตารางในการ Implementation จริง

```
UserCurrencyData ─────────┐
     │ (1)                │
     │ (N)                │ (N)
     ▼                    ▼
CurrencyPlan         Transactions ─── (N) ──► TagList ─── (N) ──► Tag
```

---

## 6. DDL — การสร้างตารางและ Constraints

### 6.1 ล้างข้อมูลเก่า

```sql
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
```

### 6.2 ตาราง UserCurrencyData (ข้อมูลบัญชีผู้ใช้)

```sql
CREATE TABLE UserCurrencyData (
    AccountID VARCHAR2(10) PRIMARY KEY
);
```

| Column | Type | Description |
|--------|------|-------------|
| `AccountID` | VARCHAR2(10) | รหัสบัญชีผู้ใช้ (PK) |

> **หมายเหตุ:** เป็นตารางกลางที่เชื่อม UserCurrencyData กับ CurrencyPlan และ Transactions

### 6.3 ตาราง CurrencyPlan (แผนการเงิน)

```sql
CREATE TABLE CurrencyPlan (
    PlanID          VARCHAR2(10) PRIMARY KEY,
    AccountID       VARCHAR2(10),
    PlanName        NVARCHAR2(100) NOT NULL,
    PlanDescription NVARCHAR2(255),
    PlanDate        DATE,
    Amount          NUMBER(12,2),
    DateCreate      DATE,
    DateEdit        DATE,
    CONSTRAINT FK_PlanUser FOREIGN KEY (AccountID)
        REFERENCES UserCurrencyData(AccountID),
    CONSTRAINT CK_Plan_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Plan_DateEdit CHECK (DateEdit IS NULL OR DateEdit >= DateCreate)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `PlanID` | VARCHAR2(10) | รหัสแผน (PK) |
| `AccountID` | VARCHAR2(10) | FK → UserCurrencyData |
| `PlanName` | NVARCHAR2(100) | ชื่อแผน (NOT NULL) |
| `PlanDescription` | NVARCHAR2(255) | รายละเอียดแผน |
| `PlanDate` | DATE | วันที่เป้าหมายของแผน |
| `Amount` | NUMBER(12,2) | งบประมาณของแผน (> 0) |
| `DateCreate` | DATE | วันที่สร้างแผน |
| `DateEdit` | DATE | วันที่แก้ไขล่าสุด (NULL ได้ ถ้ายังไม่เคยแก้ไข) |

### 6.4 ตาราง Tag (แท็ก/หมวดหมู่)

```sql
CREATE TABLE Tag (
    TagID   VARCHAR2(10) PRIMARY KEY,
    TagName NVARCHAR2(50) NOT NULL,
    CONSTRAINT UQ_Tag_Name UNIQUE (TagName)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `TagID` | VARCHAR2(10) | รหัสแท็ก (PK) |
| `TagName` | NVARCHAR2(50) | ชื่อแท็ก (NOT NULL, Unique) |

### 6.5 ตาราง Transactions (รายการรายรับ-รายจ่าย)

```sql
CREATE TABLE Transactions (
    TransactionID    VARCHAR2(10) PRIMARY KEY,
    AccountID        VARCHAR2(10),
    TransName        NVARCHAR2(100) NOT NULL,
    TransDate        DATE,
    TransTime        VARCHAR2(8),          -- รูปแบบ HH24:MI:SS
    Amount           NUMBER(12,2),
    RevenueFlag      NUMBER(1) NOT NULL,   -- 1 = รายรับ, 0 = รายจ่าย
    TransDescription VARCHAR2(255),
    CONSTRAINT FK_TransUser    FOREIGN KEY (AccountID)
        REFERENCES UserCurrencyData(AccountID),
    CONSTRAINT CK_Trans_Amount  CHECK (Amount > 0),
    CONSTRAINT CK_Trans_Revenue CHECK (RevenueFlag IN (0, 1)),
    CONSTRAINT CK_Trans_Time    CHECK (REGEXP_LIKE(TransTime, '^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$'))
);
```

| Column | Type | Description |
|--------|------|-------------|
| `TransactionID` | VARCHAR2(10) | รหัสรายการ (PK) |
| `AccountID` | VARCHAR2(10) | FK → UserCurrencyData |
| `TransName` | NVARCHAR2(100) | ชื่อรายการ (NOT NULL) |
| `TransDate` | DATE | วันที่รายการ |
| `TransTime` | VARCHAR2(8) | เวลา รูปแบบ `HH24:MI:SS` |
| `Amount` | NUMBER(12,2) | จำนวนเงิน (> 0) |
| `RevenueFlag` | NUMBER(1) | `1` = รายรับ, `0` = รายจ่าย |
| `TransDescription` | VARCHAR2(255) | หมายเหตุ |

> 💡 **หมายเหตุ:** `RevenueFlag` ใช้ชนิดข้อมูล `NUMBER(1)` โดยกำหนดให้ `1 = รายรับ` และ `0 = รายจ่าย` เพื่อให้ทำงานได้บน Oracle ทุกเวอร์ชัน

### 6.6 ตาราง TagList (ตารางเชื่อม Transaction-Tag)

```sql
CREATE TABLE TagList (
    TransactionID VARCHAR2(10),
    LineNo        NUMBER(5),
    TagID         VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_TagList       PRIMARY KEY (TransactionID, LineNo),
    CONSTRAINT FK_TagList_Trans FOREIGN KEY (TransactionID)
        REFERENCES Transactions(TransactionID),
    CONSTRAINT FK_TagList_Tag   FOREIGN KEY (TagID)
        REFERENCES Tag(TagID),
    CONSTRAINT UQ_TagList_TransTag UNIQUE (TransactionID, TagID)
);
```

| Column | Type | Description |
|--------|------|-------------|
| `TransactionID` | VARCHAR2(10) | FK → Transactions (PK ส่วนที่ 1) |
| `LineNo` | NUMBER(5) | ลำดับแท็กในรายการ (PK ส่วนที่ 2) |
| `TagID` | VARCHAR2(10) | FK → Tag |

> **Business Rule:** 1 รายการติดแท็กเดิมซ้ำไม่ได้ (Unique บน TransactionID + TagID)

---

## 7. DML — ข้อมูลตัวอย่าง

### 7.1 UserCurrencyData (5 บัญชี)

```sql
INSERT INTO UserCurrencyData VALUES ('ACC01');
INSERT INTO UserCurrencyData VALUES ('ACC02');
INSERT INTO UserCurrencyData VALUES ('ACC03');
INSERT INTO UserCurrencyData VALUES ('ACC04');
INSERT INTO UserCurrencyData VALUES ('ACC05');
```

### 7.2 CurrencyPlan (9 แผนการเงิน)

| PlanID | AccountID | ชื่อแผน | งบประมาณ |
|--------|----------|---------|---------|
| PL01 | ACC01 | ออมเงินซื้อโน้ตบุ๊ก | 36,000 |
| PL02 | ACC01 | ค่าเทอมภาคเรียนที่ 2 | 18,000 |
| PL03 | ACC02 | กองทุนฉุกเฉิน | 60,000 |
| PL04 | ACC02 | ท่องเที่ยวเชียงใหม่ | 12,000 |
| PL05 | ACC03 | ผ่อนรถจักรยานยนต์ | 3,200 |
| PL06 | ACC03 | ซื้อประกันสุขภาพ | 15,000 |
| PL07 | ACC04 | ซื้อหูฟังไร้สาย | 2,500 |
| PL08 | ACC05 | ดาวน์บ้าน | 300,000 |
| PL09 | ACC05 | ลงทุนกองทุนรวม | 5,000 |

### 7.3 Tag (9 แท็ก)

```sql
INSERT INTO Tag VALUES ('TG01','อาหาร');
INSERT INTO Tag VALUES ('TG02','เดินทาง');
INSERT INTO Tag VALUES ('TG03','ที่พัก');
INSERT INTO Tag VALUES ('TG04','ค่าน้ำค่าไฟ');
INSERT INTO Tag VALUES ('TG05','บันเทิง');
INSERT INTO Tag VALUES ('TG06','ช้อปปิ้ง');
INSERT INTO Tag VALUES ('TG07','รายได้');
INSERT INTO Tag VALUES ('TG08','การศึกษา');
INSERT INTO Tag VALUES ('TG09','สุขภาพ');
```

### 7.4 Transactions (18 รายการ)

| TransactionID | AccountID | ชื่อรายการ | ประเภท | จำนวนเงิน |
|--------------|----------|-----------|--------|---------|
| TR001 | ACC01 | เงินเดือนกันยายน | รายรับ | 25,000 |
| TR002 | ACC01 | ค่าข้าวกลางวัน | รายจ่าย | 85 |
| TR003 | ACC01 | ค่ารถไฟฟ้า BTS | รายจ่าย | 44 |
| TR004 | ACC01 | ค่าห้องพัก | รายจ่าย | 4,500 |
| TR005 | ACC02 | ค่าจ้างฟรีแลนซ์ | รายรับ | 8,000 |
| TR006 | ACC02 | ซื้อหนังสือเรียน | รายจ่าย | 650 |
| TR008 | ACC03 | เงินเดือนตุลาคม | รายรับ | 32,000 |
| TR015 | ACC05 | เงินเดือนตุลาคม | รายรับ | 28,000 |
| TR018 | ACC05 | โบนัสพิเศษ | รายรับ | 5,000 |

### 7.5 TagList — ตัวอย่างการติดแท็ก

```sql
INSERT INTO TagList VALUES ('TR001', 1, 'TG07');   -- เงินเดือน → รายได้
INSERT INTO TagList VALUES ('TR002', 1, 'TG01');   -- ข้าว → อาหาร
INSERT INTO TagList VALUES ('TR006', 1, 'TG08');   -- หนังสือ → การศึกษา
INSERT INTO TagList VALUES ('TR006', 2, 'TG06');   -- หนังสือ → ช้อปปิ้ง (2 แท็ก)
```

---

## 8. PL/SQL — Stored Procedures

> **หมายเหตุ:** ทุก procedure **ไม่ COMMIT เอง** — ผู้เรียกต้องสั่ง `COMMIT;` เอง

### 8.1 sp_create_account — สร้างบัญชีผู้ใช้

```sql
CREATE OR REPLACE PROCEDURE sp_create_account (
    p_accountid IN VARCHAR2
) AS
BEGIN
    INSERT INTO UserCurrencyData (AccountID)
    VALUES (p_accountid);
    DBMS_OUTPUT.PUT_LINE('สร้างบัญชีผู้ใช้เรียบร้อย: ' || p_accountid);
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
EXEC sp_create_account('ACC06');
```

### 8.2 sp_create_plan — สร้างแผนการเงิน

```sql
CREATE OR REPLACE PROCEDURE sp_create_plan (
    p_planid    IN VARCHAR2,
    p_accountid IN VARCHAR2,
    p_planname  IN VARCHAR2,
    p_plandesc  IN VARCHAR2,
    p_plandate  IN DATE,
    p_amount    IN NUMBER
) AS
BEGIN
    INSERT INTO CurrencyPlan (PlanID, AccountID, PlanName, PlanDescription,
                              PlanDate, Amount, DateCreate, DateEdit)
    VALUES (p_planid, p_accountid, p_planname, p_plandesc,
            p_plandate, p_amount, SYSDATE, NULL);
    DBMS_OUTPUT.PUT_LINE('สร้างแผนการเงินเรียบร้อย: ' || p_planid);
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
BEGIN
    sp_create_plan('PL10', 'ACC01', N'งบอาหาร', N'งบอาหารประจำเดือน',
                   DATE '2026-12-01', 5000);
    COMMIT;
END;
/
```

### 8.3 sp_update_plan — แก้ไขแผนการเงิน

```sql
CREATE OR REPLACE PROCEDURE sp_update_plan (
    p_planid   IN VARCHAR2,
    p_planname IN VARCHAR2,
    p_plandesc IN VARCHAR2,
    p_plandate IN DATE,
    p_amount   IN NUMBER
) AS
BEGIN
    UPDATE CurrencyPlan
       SET PlanName        = p_planname,
           PlanDescription = p_plandesc,
           PlanDate        = p_plandate,
           Amount          = p_amount,
           DateEdit        = SYSDATE
     WHERE PlanID = p_planid;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแผนการเงิน: ' || p_planid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('แก้ไขแผนการเงินเรียบร้อย: ' || p_planid);
    END IF;
END;
/
```

### 8.4 sp_add_transaction — เพิ่มรายการ

```sql
CREATE OR REPLACE PROCEDURE sp_add_transaction (
    p_transid   IN VARCHAR2,
    p_accountid IN VARCHAR2,
    p_transname IN VARCHAR2,
    p_transdate IN DATE,
    p_transtime IN VARCHAR2,   -- รูปแบบ HH24:MI:SS
    p_amount    IN NUMBER,
    p_isrevenue IN NUMBER,     -- 1 = รายรับ, 0 = รายจ่าย
    p_desc      IN VARCHAR2
) AS
BEGIN
    INSERT INTO Transactions (TransactionID, AccountID, TransName, TransDate,
                              TransTime, Amount, RevenueFlag, TransDescription)
    VALUES (p_transid, p_accountid, p_transname, p_transdate,
            p_transtime, p_amount, p_isrevenue, p_desc);

    IF p_isrevenue = 1 THEN
        DBMS_OUTPUT.PUT_LINE('บันทึกรายรับเรียบร้อย: ' || p_transid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('บันทึกรายจ่ายเรียบร้อย: ' || p_transid);
    END IF;
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
BEGIN
    sp_add_transaction('TR020', 'ACC01', N'เงินเดือน',
                       DATE '2026-11-25', '09:00:00',
                       25000, 1, 'เงินเดือน พ.ย.');
    COMMIT;
END;
/
```

### 8.5 sp_update_transaction — แก้ไขรายการ

```sql
CREATE OR REPLACE PROCEDURE sp_update_transaction (
    p_transid   IN VARCHAR2,
    p_transname IN VARCHAR2,
    p_transdate IN DATE,
    p_transtime IN VARCHAR2,
    p_amount    IN NUMBER,
    p_isrevenue IN NUMBER,     -- 1 = รายรับ, 0 = รายจ่าย
    p_desc      IN VARCHAR2
) AS
BEGIN
    UPDATE Transactions
       SET TransName        = p_transname,
           TransDate        = p_transdate,
           TransTime        = p_transtime,
           Amount           = p_amount,
           RevenueFlag      = p_isrevenue,
           TransDescription = p_desc
     WHERE TransactionID = p_transid;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบรายการ: ' || p_transid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('แก้ไขรายการเรียบร้อย: ' || p_transid);
    END IF;
END;
/
```

### 8.6 sp_delete_transaction — ลบรายการ

```sql
CREATE OR REPLACE PROCEDURE sp_delete_transaction (
    p_transid IN VARCHAR2
) AS
BEGIN
    -- ลบแท็กที่ผูกกับรายการก่อน
    DELETE FROM TagList WHERE TransactionID = p_transid;

    DELETE FROM Transactions WHERE TransactionID = p_transid;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบรายการ: ' || p_transid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('ลบรายการเรียบร้อย: ' || p_transid);
    END IF;
END;
/
```

### 8.7 sp_add_tag / sp_update_tag / sp_delete_tag — จัดการแท็ก

```sql
-- เพิ่มแท็ก
CREATE OR REPLACE PROCEDURE sp_add_tag (
    p_tagid   IN VARCHAR2,
    p_tagname IN VARCHAR2
) AS
BEGIN
    INSERT INTO Tag (TagID, TagName) VALUES (p_tagid, p_tagname);
    DBMS_OUTPUT.PUT_LINE('สร้างแท็กเรียบร้อย: ' || p_tagid);
END;
/

-- แก้ไขแท็ก
CREATE OR REPLACE PROCEDURE sp_update_tag (
    p_tagid   IN VARCHAR2,
    p_tagname IN VARCHAR2
) AS
BEGIN
    UPDATE Tag SET TagName = p_tagname WHERE TagID = p_tagid;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแท็ก: ' || p_tagid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('แก้ไขแท็กเรียบร้อย: ' || p_tagid);
    END IF;
END;
/

-- ลบแท็ก (ลบจาก TagList ก่อน)
CREATE OR REPLACE PROCEDURE sp_delete_tag (
    p_tagid IN VARCHAR2
) AS
BEGIN
    DELETE FROM TagList WHERE TagID = p_tagid;
    DELETE FROM Tag WHERE TagID = p_tagid;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแท็ก: ' || p_tagid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('ลบแท็กเรียบร้อย: ' || p_tagid);
    END IF;
END;
/
```

### 8.8 sp_tag_transaction — ติดแท็กให้รายการ

```sql
CREATE OR REPLACE PROCEDURE sp_tag_transaction (
    p_transid IN VARCHAR2,
    p_tagid   IN VARCHAR2
) AS
    v_line NUMBER;
BEGIN
    SELECT NVL(MAX(LineNo), 0) + 1
      INTO v_line
      FROM TagList
     WHERE TransactionID = p_transid;

    INSERT INTO TagList (TransactionID, LineNo, TagID)
    VALUES (p_transid, v_line, p_tagid);
    DBMS_OUTPUT.PUT_LINE('ติดแท็ก ' || p_tagid || ' ให้รายการ ' || p_transid || ' เรียบร้อย');
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
EXEC sp_tag_transaction('TR020', 'TG07');  -- ติดแท็ก "รายได้"
```

### 8.9 sp_monthly_summary — สรุปรายเดือน

```sql
CREATE OR REPLACE PROCEDURE sp_monthly_summary (
    p_accountid IN VARCHAR2,
    p_year      IN NUMBER,
    p_month     IN NUMBER
) AS
    v_income  NUMBER(14,2);
    v_expense NUMBER(14,2);
BEGIN
    SELECT NVL(SUM(CASE WHEN RevenueFlag = 1 THEN Amount END), 0),
           NVL(SUM(CASE WHEN RevenueFlag = 0 THEN Amount END), 0)
      INTO v_income, v_expense
      FROM Transactions
     WHERE AccountID = p_accountid
       AND EXTRACT(YEAR  FROM TransDate) = p_year
       AND EXTRACT(MONTH FROM TransDate) = p_month;

    DBMS_OUTPUT.PUT_LINE('สรุปเดือน ' || p_month || '/' || p_year || ' ของบัญชี ' || p_accountid);
    DBMS_OUTPUT.PUT_LINE('  รายรับรวม  : ' || TO_CHAR(v_income,  'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('  รายจ่ายรวม : ' || TO_CHAR(v_expense, 'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('  คงเหลือ    : ' || TO_CHAR(v_income - v_expense, 'FM999,999,990.00'));
END;
/
```

**ตัวอย่างการเรียกใช้:**
```sql
SET SERVEROUTPUT ON
EXEC sp_monthly_summary('ACC01', 2026, 10);
```

**ผลลัพธ์ตัวอย่าง:**
```
สรุปเดือน 10/2026 ของบัญชี ACC01
  รายรับรวม  : 25,000.00
  รายจ่ายรวม :  4,629.00
  คงเหลือ    : 20,371.00
```

### 8.10 sp_yearly_summary — สรุปรายปี

```sql
CREATE OR REPLACE PROCEDURE sp_yearly_summary (
    p_accountid IN VARCHAR2,
    p_year      IN NUMBER
) AS
    v_total_income  NUMBER(14,2) := 0;
    v_total_expense NUMBER(14,2) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('สรุปรายปี ' || p_year || ' ของบัญชี ' || p_accountid);

    FOR r IN (
        SELECT EXTRACT(MONTH FROM TransDate) AS m,
               NVL(SUM(CASE WHEN RevenueFlag = 1 THEN Amount END), 0) AS income,
               NVL(SUM(CASE WHEN RevenueFlag = 0 THEN Amount END), 0) AS expense
          FROM Transactions
         WHERE AccountID = p_accountid
           AND EXTRACT(YEAR FROM TransDate) = p_year
         GROUP BY EXTRACT(MONTH FROM TransDate)
         ORDER BY EXTRACT(MONTH FROM TransDate)
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('  เดือน ' || LPAD(r.m, 2, '0')
            || ' | รายรับ '  || TO_CHAR(r.income,  'FM999,999,990.00')
            || ' | รายจ่าย ' || TO_CHAR(r.expense, 'FM999,999,990.00'));
        v_total_income  := v_total_income  + r.income;
        v_total_expense := v_total_expense + r.expense;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('  รวมทั้งปี | รายรับ ' || TO_CHAR(v_total_income,  'FM999,999,990.00')
        || ' | รายจ่าย ' || TO_CHAR(v_total_expense, 'FM999,999,990.00')
        || ' | คงเหลือ ' || TO_CHAR(v_total_income - v_total_expense, 'FM999,999,990.00'));
END;
/
```

### 8.11 sp_compare_months — เปรียบเทียบรายจ่ายสองเดือน

```sql
CREATE OR REPLACE PROCEDURE sp_compare_months (
    p_accountid IN VARCHAR2,
    p_year1     IN NUMBER,
    p_month1    IN NUMBER,
    p_year2     IN NUMBER,
    p_month2    IN NUMBER
) AS
    v_exp1 NUMBER(14,2);
    v_exp2 NUMBER(14,2);
    v_diff NUMBER(14,2);
BEGIN
    SELECT NVL(SUM(Amount), 0) INTO v_exp1
      FROM Transactions
     WHERE AccountID = p_accountid AND RevenueFlag = 0
       AND EXTRACT(YEAR  FROM TransDate) = p_year1
       AND EXTRACT(MONTH FROM TransDate) = p_month1;

    SELECT NVL(SUM(Amount), 0) INTO v_exp2
      FROM Transactions
     WHERE AccountID = p_accountid AND RevenueFlag = 0
       AND EXTRACT(YEAR  FROM TransDate) = p_year2
       AND EXTRACT(MONTH FROM TransDate) = p_month2;

    v_diff := v_exp2 - v_exp1;

    DBMS_OUTPUT.PUT_LINE('เปรียบเทียบรายจ่าย ' || p_month1 || '/' || p_year1
        || ' กับ ' || p_month2 || '/' || p_year2);
    DBMS_OUTPUT.PUT_LINE('  ' || p_month1 || '/' || p_year1 || ' : '
        || TO_CHAR(v_exp1, 'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('  ' || p_month2 || '/' || p_year2 || ' : '
        || TO_CHAR(v_exp2, 'FM999,999,990.00'));

    IF v_exp1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ผลต่าง : ' || TO_CHAR(v_diff, 'FM999,999,990.00')
            || ' (เดือนแรกไม่มีรายจ่าย)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ผลต่าง : ' || TO_CHAR(v_diff, 'FM999,999,990.00')
            || ' (' || ROUND(v_diff / v_exp1 * 100, 2) || '%)');
    END IF;
END;
/
```

### 8.12 sp_check_plan — เช็คงบประมาณตามแผน

```sql
CREATE OR REPLACE PROCEDURE sp_check_plan (
    p_planid IN VARCHAR2
) AS
    v_account CurrencyPlan.AccountID%TYPE;
    v_budget  CurrencyPlan.Amount%TYPE;
    v_date    CurrencyPlan.PlanDate%TYPE;
    v_spent   NUMBER(14,2);
BEGIN
    SELECT AccountID, Amount, PlanDate
      INTO v_account, v_budget, v_date
      FROM CurrencyPlan
     WHERE PlanID = p_planid;

    SELECT NVL(SUM(Amount), 0)
      INTO v_spent
      FROM Transactions
     WHERE AccountID = v_account
       AND RevenueFlag = 0
       AND TRUNC(TransDate, 'MM') = TRUNC(v_date, 'MM');

    DBMS_OUTPUT.PUT_LINE('แผน ' || p_planid
        || ' | งบ ' || TO_CHAR(v_budget, 'FM999,999,990.00')
        || ' | ใช้ไป ' || TO_CHAR(v_spent, 'FM999,999,990.00'));

    IF v_spent > v_budget THEN
        DBMS_OUTPUT.PUT_LINE('  ⚠️ เกินงบ ' || TO_CHAR(v_spent - v_budget, 'FM999,999,990.00'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ✅ คงเหลือ ' || TO_CHAR(v_budget - v_spent, 'FM999,999,990.00'));
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแผนการเงิน: ' || p_planid);
END;
/
```

### สรุป Stored Procedures ทั้งหมด (SE)

| Procedure | หน้าที่ | ประเภท |
|-----------|---------|--------|
| `sp_create_account` | สร้างบัญชีผู้ใช้ | INSERT |
| `sp_create_plan` | สร้างแผนการเงิน | INSERT |
| `sp_update_plan` | แก้ไขแผนการเงิน | UPDATE |
| `sp_add_transaction` | เพิ่มรายการ | INSERT |
| `sp_update_transaction` | แก้ไขรายการ | UPDATE |
| `sp_delete_transaction` | ลบรายการ | DELETE |
| `sp_add_tag` | เพิ่มแท็ก | INSERT |
| `sp_update_tag` | แก้ไขแท็ก | UPDATE |
| `sp_delete_tag` | ลบแท็ก | DELETE |
| `sp_tag_transaction` | ติดแท็กให้รายการ | INSERT |
| `sp_monthly_summary` | สรุปรายเดือน | SELECT |
| `sp_yearly_summary` | สรุปรายปี | SELECT |
| `sp_compare_months` | เปรียบเทียบสองเดือน | SELECT |
| `sp_check_plan` | ตรวจสอบงบประมาณ | SELECT |

---

## 9. Views — Derived Attributes

### V_UserCurrencySummary — สรุปยอดเงินต่อบัญชี

```sql
CREATE OR REPLACE VIEW V_UserCurrencySummary AS
SELECT u.AccountID,
       -- เงินที่ใช้ได้ = รายรับทั้งหมด - รายจ่ายทั้งหมด
       NVL(SUM(CASE WHEN t.RevenueFlag = 1 THEN  t.Amount
                    WHEN t.RevenueFlag = 0 THEN -t.Amount END), 0) AS UseableMoney,
       -- รายจ่ายรายปี (ปีปัจจุบัน)
       NVL(SUM(CASE WHEN t.RevenueFlag = 0
                     AND EXTRACT(YEAR FROM t.TransDate) = EXTRACT(YEAR FROM SYSDATE)
                    THEN t.Amount END), 0) AS OutcomeYearly
FROM UserCurrencyData u
LEFT JOIN Transactions t ON t.AccountID = u.AccountID
GROUP BY u.AccountID;
```

**การใช้งาน:**
```sql
SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;
```

**ผลลัพธ์ตัวอย่าง:**
```
AccountID | UseableMoney | OutcomeYearly
----------|--------------|---------------
ACC01     |   20,371.00  |     4,629.00
ACC02     |    7,070.00  |       930.00
ACC03     |   30,570.00  |     3,020.00
ACC05     |   32,040.00  |       960.00
```

---

## 10. คู่มือการรันระบบตั้งแต่ต้น

### สิ่งที่ต้องเตรียม

| สิ่งที่ต้องการ | รายละเอียด |
|-------------|-----------|
| **Oracle Database** | 23ai (แนะนำ) สำหรับ BOOLEAN type หรือ 19c+ |
| **SQL Client** | SQL*Plus, SQL Developer, DBeaver, Toad |
| **สิทธิ์** | CREATE TABLE, CREATE PROCEDURE, CREATE VIEW, CREATE SESSION |

> ⚠️ **สำคัญมาก:** ถ้าใช้ Oracle ต่ำกว่า 23ai ให้เปลี่ยน `BOOLEAN` เป็น `NUMBER(1)` ใน Transactions table และใช้ `1` แทน `TRUE`, `0` แทน `FALSE`

### ขั้นตอนที่ 1 — เชื่อมต่อฐานข้อมูล

```bash
# SQL*Plus
sqlplus username/password@localhost:1521/XEPDB1

# หรือถ้าใช้ Oracle XE
sqlplus username/password@XE
```

### ขั้นตอนที่ 2 — ตั้งค่า Session

```sql
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

### ขั้นตอนที่ 3 — รัน DDL (สร้างตาราง)

```bash
# รันไฟล์
@DDL/SE.sql

# หรือ copy-paste ทีละส่วน
```

**ลำดับการสร้างตาราง (ต้องทำตามลำดับ):**
```
1. UserCurrencyData  (ไม่มี FK)
2. CurrencyPlan      (FK → UserCurrencyData)
3. Tag               (ไม่มี FK)
4. Transactions      (FK → UserCurrencyData)
5. TagList           (FK → Transactions + Tag)
```

> ⚠️ **หมายเหตุ:** ในไฟล์ DDL/SE.sql มีลำดับผิด (CurrencyPlan ถูกสร้างก่อน UserCurrencyData) อาจต้องสลับลำดับหรือ Defer FK constraint

### ขั้นตอนที่ 4 — รัน DML (ใส่ข้อมูลตัวอย่าง)

```bash
@DML/SE.sql
```

**ลำดับการ INSERT ที่ถูกต้อง:**
```
1. UserCurrencyData  → เพิ่มบัญชีผู้ใช้ก่อน
2. CurrencyPlan      → FK ต้องมี AccountID อยู่แล้ว
3. Tag               → อิสระ
4. Transactions      → FK ต้องมี AccountID อยู่แล้ว
5. TagList           → FK ต้องมี TransactionID + TagID อยู่แล้ว
```

### ขั้นตอนที่ 5 — รัน PL/SQL (สร้าง Stored Procedures)

```bash
@PL/SE.sql
```

### ขั้นตอนที่ 6 — ทดสอบ Procedures

```sql
SET SERVEROUTPUT ON

-- ทดสอบสร้างบัญชีและแผน
BEGIN
    sp_create_account('A001');
    sp_create_plan('P001', 'A001', N'งบอาหาร', N'งบอาหารประจำเดือน',
                   DATE '2026-11-30', 5000);
    sp_add_tag('T001', N'อาหาร');
    COMMIT;
END;
/

-- ทดสอบเพิ่มรายการและติดแท็ก
BEGIN
    sp_add_transaction('TR001', 'A001', N'เงินเดือน',
                       DATE '2026-11-01', '09:00:00', 30000, 1, 'เงินเดือน พ.ย.');
    sp_add_transaction('TR002', 'A001', N'ข้าวกลางวัน',
                       DATE '2026-11-02', '12:30:00', 120, 0, 'ร้านข้าวแกง');
    sp_add_transaction('TR003', 'A001', N'ค่ากาแฟ',
                       DATE '2026-11-05', '08:15:00', 450, 0, 'ร้านกาแฟ');
    sp_tag_transaction('TR002', 'T001');
    sp_tag_transaction('TR003', 'T001');
    COMMIT;
END;
/

-- ทดสอบ Report
BEGIN
    sp_monthly_summary('A001', 2026, 11);   -- สรุปเดือน 11/2026
    sp_yearly_summary('A001', 2026);        -- สรุปรายปี
    sp_compare_months('A001', 2026, 10, 2026, 11);  -- เปรียบเทียบ ต.ค. vs พ.ย.
    sp_check_plan('P001');                  -- เช็คงบ
END;
/

-- ทดสอบแก้ไขและลบ
BEGIN
    sp_update_transaction('TR002', N'ข้าวกลางวัน', DATE '2026-11-02', '12:30:00',
                          150, 0, 'ร้านข้าวแกง (ราคาอัปเดต)');
    sp_delete_transaction('TR003');
    sp_monthly_summary('A001', 2026, 11);  -- ดูผลหลังแก้ไข
    COMMIT;
END;
/
```

### ขั้นตอนที่ 7 — ตรวจสอบข้อมูลและ View

```sql
-- ดูข้อมูลทั้งหมด
SELECT * FROM UserCurrencyData;
SELECT * FROM CurrencyPlan ORDER BY AccountID;
SELECT * FROM Tag;
SELECT * FROM Transactions ORDER BY AccountID, TransDate;
SELECT * FROM TagList ORDER BY TransactionID, LineNo;

-- ดู View สรุป
SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;
```

### ขั้นตอนที่ 8 — COMMIT และปิด

```sql
COMMIT;
EXIT;
```

---

### Troubleshooting

| ปัญหา | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `ORA-00904: "BOOLEAN": invalid identifier` | Oracle version < 23ai | เปลี่ยน `BOOLEAN` เป็น `NUMBER(1)` |
| `ORA-02291: integrity constraint violated` | INSERT ผิดลำดับ | INSERT Parent ก่อน Child |
| `ORA-00001: unique constraint violated` | ID ซ้ำ | เปลี่ยน ID |
| `ORA-02290: check constraint violated` | ค่าไม่ผ่าน CHECK | ตรวจสอบค่าที่ใส่ให้ตรงกับ constraint |
| `ORA-20001: ...` | RAISE_APPLICATION_ERROR จาก Procedure | อ่าน error message ตาม procedure |

### ตัวอย่างการปรับ BOOLEAN สำหรับ Oracle < 23ai

```sql
-- แทนที่ BOOLEAN ด้วย NUMBER(1) ใน DDL
RevenueFlag NUMBER(1) NOT NULL,
CONSTRAINT CK_Trans_Revenue CHECK (RevenueFlag IN (0, 1))

-- แทนที่ TRUE/FALSE ด้วย 1/0 ใน DML
INSERT INTO Transactions VALUES ('TR001','ACC01','เงินเดือน',
    TO_DATE('25/09/2026','DD/MM/YYYY'),'09:00:00',25000, 1, 'เงินเดือน');

-- แทนที่ BOOLEAN parameter ด้วย NUMBER(1) ใน Procedure
p_isrevenue IN NUMBER  -- 1 = รายรับ, 0 = รายจ่าย
```

---

*เอกสารนี้จัดทำโดย S1G2 | วิชา Database Systems | ปีการศึกษา 2566*
