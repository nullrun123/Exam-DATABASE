# 🧪 SE — คู่มือการทดสอบระบบฐานข้อมูลแบบ Step-by-Step
> **แอปพลิเคชันบริหารการเงินส่วนบุคคล (Personal Finance Management)**  
> คู่มือการทดสอบความถูกต้องตั้งแต่โครงสร้าง DDL, ข้อมูล DML, Stored Procedures (PL/SQL), Views จนถึงการทดสอบ Negative Testing & Business Rules

---

## 📋 สารบัญขั้นตอนการทดสอบ

- [Step 0: เตรียม Environment ก่อนเริ่มทดสอบ](#step-0-เตรียม-environment-ก่อนเริ่มทดสอบ)
- [Step 1: ทดสอบการติดตั้งและโครงสร้างตาราง (DDL Verification)](#step-1-ทดสอบการติดตั้งและโครงสร้างตาราง-ddl-verification)
- [Step 2: ทดสอบการนำเข้าข้อมูลตัวอย่าง (DML Verification)](#step-2-ทดสอบการนำเข้าข้อมูลตัวอย่าง-dml-verification)
- [Step 3: ทดสอบ Stored Procedures (PL/SQL) ครบทั้ง 14 ฟังก์ชัน](#step-3-ทดสอบ-stored-procedures-plsql-ครบทั้ง-14-ฟังก์ชัน)
  - [3.1 หมวด Account & Tag Management](#31-หมวด-account--tag-management)
  - [3.2 หมวด Currency Plan (แผนงบประมาณ)](#32-หมวด-currency-plan-แผนงบประมาณ)
  - [3.3 หมวด Transaction & Tag Mapping](#33-หมวด-transaction--tag-mapping)
  - [3.4 หมวด Financial Analytics & Summaries (ระบบคำนวณและรายงาน)](#34-หมวด-financial-analytics--summaries)
- [Step 4: ทดสอบ Derived Attributes & View สรุปยอดเงิน](#step-4-ทดสอบ-derived-attributes--view-สรุปยอดเงิน)
- [Step 5: ทดสอบรายงานเชิงซ้อน (Complex Reports)](#step-5-ทดสอบรายงานเชิงซ้อน-complex-reports)
- [Step 6: ทดสอบข้อจำกัดทางธุรกิจ (Negative Testing / Error Cases)](#step-6-ทดสอบข้อจำกัดทางธุรกิจ-negative-testing--error-cases)
- [Step 7: Check-List สรุปผลการทดสอบ](#step-7-check-list-สรุปผลการทดสอบ)

---

## Step 0: เตรียม Environment ก่อนเริ่มทดสอบ

เปิด SQL*Plus, SQL Developer หรือ DBeaver แล้วรันคำสั่งเตรียมสภาพแวดล้อม:

```sql
-- เปิดการแสดงผลข้อความจาก Stored Procedure
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 250;
SET PAGESIZE 100;

-- กำหนดรูปแบบวันที่มาตรฐาน
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

> 💡 **หมายเหตุเรื่องชนิดข้อมูล RevenueFlag:**  
> คอลัมน์ `RevenueFlag` ใช้ชนิดข้อมูล `NUMBER(1)` (โดยส่งค่า `1` = รายรับ, `0` = รายจ่าย) เพื่อรองรับการทำงานกับ Oracle ทุกเวอร์ชัน

---

## Step 1: ทดสอบการติดตั้งและโครงสร้างตาราง (DDL Verification)

รันไฟล์ `DDL/SE.sql` เพื่อสร้างตาราง และตรวจสอบว่าสร้างตารางครบทั้ง 5 ตาราง:

### 1.1 ตรวจสอบรายชื่อตาราง
```sql
SELECT table_name 
FROM user_tables 
WHERE table_name IN ('USERCURRENCYDATA', 'CURRENCYPLAN', 'TRANSACTIONS', 'TAG', 'TAGLIST')
ORDER BY table_name;
```
* **ผลลัพธ์ที่ถูกต้อง:** ต้องมีครบทั้ง 5 ตาราง

### 1.2 ตรวจสอบความสมบูรณ์ของ Constraints
```sql
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('USERCURRENCYDATA', 'CURRENCYPLAN', 'TRANSACTIONS', 'TAG', 'TAGLIST')
ORDER BY table_name, constraint_type;
```
* **ผลลัพธ์ที่ถูกต้อง:** สถานะต้องเป็น `ENABLED` ทุกตัว

---

## Step 2: ทดสอบการนำเข้าข้อมูลตัวอย่าง (DML Verification)

รันไฟล์ `DML/SE.sql` จากนั้นตรวจนับจำนวนแถวข้อมูล:

```sql
SELECT 'UserCurrencyData' AS Table_Name, COUNT(*) AS Total_Rows FROM UserCurrencyData
UNION ALL
SELECT 'CurrencyPlan', COUNT(*) FROM CurrencyPlan
UNION ALL
SELECT 'Tag', COUNT(*) FROM Tag
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL
SELECT 'TagList', COUNT(*) FROM TagList;
```

* **ผลลัพธ์ที่ถูกต้องตาม Dataset มาตรฐาน:**
  - `UserCurrencyData`: **5 แถว** (ACC01 - ACC05)
  - `CurrencyPlan`: **9 แผน** (PL01 - PL09)
  - `Tag`: **9 หมวดหมู่** (TG01 - TG09)
  - `Transactions`: **18 รายการ** (TR001 - TR018)
  - `TagList`: **21 แถวความสัมพันธ์**

---

## Step 3: ทดสอบ Stored Procedures (PL/SQL) ครบทั้ง 14 ฟังก์ชัน

รันไฟล์ `PL/SE.sql` เพื่อคอมไพล์โปรซีเดอร์ทั้งหมด จากนั้นทดสอบตามแต่ละหมวดหมู่:

### 3.1 หมวด Account & Tag Management

#### 🧪 ทดสอบที่ 3.1.1: `sp_create_account` (สร้างบัญชีผู้ใช้)
```sql
-- สร้างบัญชีผู้ใช้ทดสอบ ACC99
EXEC sp_create_account('ACC99');
COMMIT;

-- ตรวจสอบผล
SELECT * FROM UserCurrencyData WHERE AccountID = 'ACC99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `สร้างบัญชีผู้ใช้เรียบร้อย: ACC99`
  - ตารางมีแถว `ACC99`

---

#### 🧪 ทดสอบที่ 3.1.2: `sp_add_tag` (สร้างแท็กใหม่)
```sql
-- สร้างแท็กค่าใช้จ่ายสัตว์เลี้ยง
EXEC sp_add_tag('TG99', 'สัตว์เลี้ยง');
COMMIT;

-- ตรวจสอบผล
SELECT * FROM Tag WHERE TagID = 'TG99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `สร้างแท็กเรียบร้อย: TG99`
  - ตาราง Tag มีรหัส `TG99` ชื่อ `'สัตว์เลี้ยง'`

---

#### 🧪 ทดสอบที่ 3.1.3: `sp_update_tag` (แก้ไขชื่อแท็ก)
```sql
-- เปลี่ยนชื่อแท็ก TG99 เป็น 'อาหารและอุปกรณ์สัตว์เลี้ยง'
EXEC sp_update_tag('TG99', 'อาหารและอุปกรณ์สัตว์เลี้ยง');
COMMIT;

-- ตรวจสอบผล
SELECT * FROM Tag WHERE TagID = 'TG99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `แก้ไขแท็กเรียบร้อย: TG99`
  - ชื่อแท็กถูกเปลี่ยนเป็น `'อาหารและอุปกรณ์สัตว์เลี้ยง'`

---

#### 🧪 ทดสอบที่ 3.1.4: `sp_delete_tag` (ลบแท็ก)
```sql
-- ลบแท็กชั่วคราว TG99
EXEC sp_delete_tag('TG99');
COMMIT;

-- ตรวจสอบผล (ต้องไม่พบข้อมูล)
SELECT * FROM Tag WHERE TagID = 'TG99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `ลบแท็กเรียบร้อย: TG99`
  - Query จะไม่พบแถวข้อมูลของ `TG99`

---

### 3.2 หมวด Currency Plan (แผนงบประมาณ)

#### 🧪 ทดสอบที่ 3.2.1: `sp_create_plan` (สร้างแผนการเงิน)
```sql
-- สร้างแผนการเงิน PL99 สำหรับ ACC99 งบ 5,000 บาท
BEGIN
    sp_create_plan(
        p_planid    => 'PL99',
        p_accountid => 'ACC99',
        p_planname  => 'งบอาหารประจำเดือน',
        p_plandesc  => 'จำกัดค่ากินรายเดือน',
        p_plandate  => TO_DATE('30/11/2026','DD/MM/YYYY'),
        p_amount    => 5000
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT PlanID, AccountID, PlanName, Amount, DateCreate FROM CurrencyPlan WHERE PlanID = 'PL99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `สร้างแผนการเงินเรียบร้อย: PL99`
  - มีแผน `PL99` ยอดเงิน 5,000 บาท พร้อมบันทึก `DateCreate` อัตโนมัติ

---

#### 🧪 ทดสอบที่ 3.2.2: `sp_update_plan` (แก้ไขแผนการเงิน)
```sql
-- ขยายงบประมาณเป็น 6,000 บาท
BEGIN
    sp_update_plan(
        p_planid    => 'PL99',
        p_planname  => 'งบอาหารประจำเดือน (ปรับปรุง)',
        p_plandesc  => 'เพิ่มงบพิเศษสำหรับจัดเลี้ยง',
        p_plandate  => TO_DATE('30/11/2026','DD/MM/YYYY'),
        p_amount    => 6000
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT PlanID, PlanName, Amount, DateEdit FROM CurrencyPlan WHERE PlanID = 'PL99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `แก้ไขแผนการเงินเรียบร้อย: PL99`
  - คอลัมน์ `Amount` เปลี่ยนเป็น `6000` และ `DateEdit` ถูกลงบันทึกเวลาปัจจุบัน

---

### 3.3 หมวด Transaction & Tag Mapping

#### 🧪 ทดสอบที่ 3.3.1: `sp_add_transaction` (บันทึกรายรับ-รายจ่าย)
```sql
-- บันทึกรายการที่ 1: รายรับเงินเดือน 30,000 บาท
BEGIN
    sp_add_transaction(
        p_transid   => 'TR901',
        p_accountid => 'ACC99',
        p_transname => 'เงินเดือนประจำเดือน',
        p_transdate => TO_DATE('01/11/2026','DD/MM/YYYY'),
        p_transtime => '09:00:00',
        p_amount    => 30000,
        p_isrevenue => 1,     -- 1 = รายรับ, 0 = รายจ่าย
        p_desc      => 'โอนเข้าบัญชีหลัก'
    );

-- บันทึกรายการที่ 2: รายจ่ายค่าอาหาร 1,200 บาท
    sp_add_transaction(
        p_transid   => 'TR902',
        p_accountid => 'ACC99',
        p_transname => 'ทานอาหารบุฟเฟต์',
        p_transdate => TO_DATE('05/11/2026','DD/MM/YYYY'),
        p_transtime => '19:30:00',
        p_amount    => 1200,
        p_isrevenue => 0,     -- 1 = รายรับ, 0 = รายจ่าย
        p_desc      => 'มื้อเย็นกับครอบครัว'
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT TransactionID, TransName, Amount, RevenueFlag, TransTime 
FROM Transactions WHERE AccountID = 'ACC99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `บันทึกรายรับเรียบร้อย: TR901` และ `บันทึกรายจ่ายเรียบร้อย: TR902`
  - ข้อมูลบันทึกทั้ง 2 รายการถูกต้อง

---

#### 🧪 ทดสอบที่ 3.3.2: `sp_tag_transaction` (ติดแท็กหมวดหมู่ให้รายการ)
```sql
-- ติดแท็ก TG07 (รายได้) ให้ TR901 และ TG01 (อาหาร) ให้ TR902
BEGIN
    sp_tag_transaction('TR901', 'TG07');
    sp_tag_transaction('TR902', 'TG01');
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT tl.TransactionID, t.TransName, tag.TagName, tl.LineNo
FROM TagList tl
JOIN Transactions t ON t.TransactionID = tl.TransactionID
JOIN Tag tag ON tag.TagID = tl.TagID
WHERE tl.TransactionID IN ('TR901', 'TR902');
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความแจ้งเตือนติดแท็กเรียบร้อย
  - Query แสดงว่า TR901 ผูกกับ 'รายได้' และ TR902 ผูกกับ 'อาหาร'

---

#### 🧪 ทดสอบที่ 3.3.3: `sp_update_transaction` (แก้ไขรายการ)
```sql
-- แก้ไขจำนวนเงินของ TR902 จาก 1,200 เป็น 1,500 บาท
BEGIN
    sp_update_transaction(
        p_transid   => 'TR902',
        p_transname => 'ทานอาหารบุฟเฟต์ (รวมเครื่องดื่ม)',
        p_transdate => TO_DATE('05/11/2026','DD/MM/YYYY'),
        p_transtime => '19:45:00',
        p_amount    => 1500,
        p_isrevenue => 0,     -- 1 = รายรับ, 0 = รายจ่าย
        p_desc      => 'รวมของหวานเพิ่ม'
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT TransactionID, TransName, Amount, TransTime FROM Transactions WHERE TransactionID = 'TR902';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อมูล `Amount` เปลี่ยนเป็น `1500`

---

#### 🧪 ทดสอบที่ 3.3.4: `sp_delete_transaction` (ลบรายการ)
```sql
-- ทดสอบลบรายการ TR902 (ต้องลบความสัมพันธ์ใน TagList อัตโนมัติด้วย)
EXEC sp_delete_transaction('TR902');
COMMIT;

-- ตรวจสอบผลทั้งใน Transactions และ TagList
SELECT COUNT(*) FROM Transactions WHERE TransactionID = 'TR902';
SELECT COUNT(*) FROM TagList WHERE TransactionID = 'TR902';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `ลบรายการเรียบร้อย: TR902`
  - ผลลัพธ์ทั้งสองตารางต้องได้ `COUNT = 0` (ไม่เหลือข้อมูลค้าง)

---

### 3.4 หมวด Financial Analytics & Summaries

ใส่รายการรายจ่ายเพิ่มเติมเพื่อให้ทดสอบฟังก์ชันสรุปยอดได้อย่างสมบูรณ์:
```sql
BEGIN
    sp_add_transaction('TR903', 'ACC99', 'ซื้อของใช้ในบ้าน', TO_DATE('10/10/2026','DD/MM/YYYY'), '14:00:00', 3000, 0, 'เดือน 10');
    sp_add_transaction('TR904', 'ACC99', 'ค่าอาหารกลางวัน',  TO_DATE('02/11/2026','DD/MM/YYYY'), '12:00:00',  500, 0, 'เดือน 11');
    sp_add_transaction('TR905', 'ACC99', 'ค่าเดินทาง BTS',   TO_DATE('04/11/2026','DD/MM/YYYY'), '08:30:00',  300, 0, 'เดือน 11');
    COMMIT;
END;
/
```

#### 🧪 ทดสอบที่ 3.4.1: `sp_monthly_summary` (สรุปยอดรายเดือน)
```sql
-- สรุปเดือน 11/2026 ของ ACC99 (รายรับ 30,000, รายจ่าย 500+300 = 800)
EXEC sp_monthly_summary('ACC99', 2026, 11);
```
* **ผลลัพธ์หน้าจอที่คาดหวัง:**
  ```text
  สรุปเดือน 11/2026 ของบัญชี ACC99
    รายรับรวม  : 30,000.00
    รายจ่ายรวม : 800.00
    คงเหลือ    : 29,200.00
  ```

---

#### 🧪 ทดสอบที่ 3.4.2: `sp_yearly_summary` (สรุปภาพรวมรายปีแจกแจงรายเดือน)
```sql
-- สรุปยอดทั้งปี 2026 ของ ACC99
EXEC sp_yearly_summary('ACC99', 2026);
```
* **ผลลัพธ์หน้าจอที่คาดหวัง:**
  ```text
  สรุปรายปี 2026 ของบัญชี ACC99
    เดือน 10 | รายรับ 0.00 | รายจ่าย 3,000.00
    เดือน 11 | รายรับ 30,000.00 | รายจ่าย 800.00
    รวมทั้งปี | รายรับ 30,000.00 | รายจ่าย 3,800.00 | คงเหลือ 26,200.00
  ```

---

#### 🧪 ทดสอบที่ 3.4.3: `sp_compare_months` (เปรียบเทียบค่าใช้จ่าย 2 เดือน)
```sql
-- เปรียบเทียบรายจ่ายเดือน 10/2026 (3,000 บาท) กับเดือน 11/2026 (800 บาท)
EXEC sp_compare_months('ACC99', 2026, 10, 2026, 11);
```
* **ผลลัพธ์หน้าจอที่คาดหวัง:**
  ```text
  เปรียบเทียบรายจ่าย 10/2026 กับ 11/2026
    10/2026 : 3,000.00
    11/2026 : 800.00
    ผลต่าง : -2,200.00 (-73.33%)
  ```

---

#### 🧪 ทดสอบที่ 3.4.4: `sp_check_plan` (ตรวจสอบการใช้จ่ายเทียบกับแผนงบ)
```sql
-- ตรวจสอบแผน PL99 (งบ 6,000 บาท ในเดือน 11/2026, ใช้ไป 800 บาท)
EXEC sp_check_plan('PL99');
```
* **ผลลัพธ์หน้าจอที่คาดหวัง:**
  ```text
  แผน PL99 | งบ 6,000.00 | ใช้ไป 800.00
    คงเหลือ 5,200.00
  ```

---

## Step 4: ทดสอบ Derived Attributes & View สรุปยอดเงิน

ตรวจสอบผลลัพธ์จาก View `V_UserCurrencySummary` ที่คำนวณเงินคงเหลือแบบ Real-time:

```sql
SELECT * FROM V_UserCurrencySummary WHERE AccountID = 'ACC99';
```

* **ผลลัพธ์ที่คาดหวัง:**
  - `AccountID`: `ACC99`
  - `UseableMoney` (เงินคงเหลือสุทธิ = รายรับ 30,000 - รายจ่าย 3,800): **26,200.00**
  - `OutcomeYearly` (รายจ่ายรวมปีปัจจุบัน): **3,800.00**

---

## Step 5: ทดสอบรายงานเชิงซ้อน (Complex Reports)

ทดสอบการดึงข้อมูลที่มีการ JOIN พร้อมคำนวณและจัดกลุ่มตามข้อกำหนดของระบบ:

```sql
-- รายงานรวมรายการธุรกรรมพร้อมแท็ก (LISTAGG)
SELECT 
    t.AccountID,
    t.TransactionID,
    t.TransName,
    t.Amount,
    LISTAGG(tag.TagName, ', ') WITHIN GROUP (ORDER BY tl.LineNo) AS Associated_Tags
FROM Transactions t
LEFT JOIN TagList tl ON t.TransactionID = tl.TransactionID
LEFT JOIN Tag tag ON tag.TagID = tl.TagID
WHERE t.AccountID = 'ACC01'
GROUP BY t.AccountID, t.TransactionID, t.TransName, t.Amount;
```
* **ผลลัพธ์ที่คาดหวัง:** แสดงรายการธุรกรรมของ `ACC01` พร้อมชื่อแท็กคั่นด้วยเครื่องหมายจุลภาคอย่างถูกต้อง

---

## Step 6: ทดสอบข้อจำกัดทางธุรกิจ (Negative Testing / Error Cases)

ทดสอบใส่ข้อมูลที่ผิดกฎเกณฑ์ทางธุรกิจ เพื่อยืนยันว่า Constraints ดักจับได้สมบูรณ์:

### ❌ กรณีที่ 6.1: ใส่จำนวนเงินในรายการเป็น 0 หรือติดลบ (`CK_Trans_Amount`)
```sql
INSERT INTO Transactions VALUES (
    'TR888', 'ACC01', 'ทดสอบเงินลบ', SYSDATE, '12:00:00', -100, 0, 'ทดสอบ'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ขึ้น Error **`ORA-02290: check constraint (...) violated`** (จำนวนเงินต้อง > 0)

---

### ❌ กรณีที่ 6.2: ใส่รูปแบบเวลาผิด Regex (`CK_Trans_Time`)
```sql
-- ใส่เวลาเป็น '25:70:00' (ชั่วโมงและนาทีเกินจริง)
INSERT INTO Transactions VALUES (
    'TR888', 'ACC01', 'ทดสอบเวลาผิด', SYSDATE, '25:70:00', 500, 0, 'ทดสอบ'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ขึ้น Error **`ORA-02290: check constraint (...) violated`** (เวลาต้องอยู่ในฟอร์แมต `HH24:MI:SS`)

---

### ❌ กรณีที่ 6.3: สร้างชื่อแท็กซ้ำกัน (`UQ_Tag_Name`)
```sql
-- ใน DML มีแท็กชื่อ 'อาหาร' อยู่แล้ว ลองสร้างซ้ำ
INSERT INTO Tag VALUES ('TG88', 'อาหาร');
```
* **ผลลัพธ์ที่คาดหวัง:** ขึ้น Error **`ORA-00001: unique constraint (...) violated`** (ชื่อแท็กห้ามซ้ำ)

---

### ❌ กรณีที่ 6.4: ติดแท็กเดิมซ้ำในรายการเดียวกัน (`UQ_TagList_TransTag`)
```sql
-- TR001 ติดแท็ก TG07 อยู่แล้ว ลอง INSERT คู่เดิมซ้ำ
INSERT INTO TagList VALUES ('TR001', 2, 'TG07');
```
* **ผลลัพธ์ที่คาดหวัง:** ขึ้น Error **`ORA-00001: unique constraint (...) violated`** (1 รายการติดแท็กซ้ำไม่ได้)

---

### ❌ กรณีที่ 6.5: ใส่วันที่แก้ไขแผนก่อนวันที่สร้างแผน (`CK_Plan_DateEdit`)
```sql
INSERT INTO CurrencyPlan VALUES (
    'PL888', 'ACC01', 'ทดสอบวันผิด', 'คำอธิบาย',
    SYSDATE, 5000,
    TO_DATE('10/11/2026','DD/MM/YYYY'), -- DateCreate
    TO_DATE('01/11/2026','DD/MM/YYYY')  -- DateEdit (ก่อน DateCreate)
);
```
* **ผลลัพธ์ที่คาดหวัง:** ขึ้น Error **`ORA-02290: check constraint (...) violated`** (DateEdit ต้อง >= DateCreate)

---

## Step 7: Check-List สรุปผลการทดสอบ

| ลำดับ | หัวข้อการทดสอบ | สถานะ (Pass / Fail) | หมายเหตุ |
|---|---|:---:|---|
| 1 | ตารางทั้ง 5 ตารางถูกสร้างครบถ้วน | [ ] | DDL/SE.sql |
| 2 | ข้อมูลตัวอย่าง DML เข้าครบทุกแถว | [ ] | DML/SE.sql |
| 3 | `sp_create_account` สร้างบัญชีสำเร็จ | [ ] | |
| 4 | `sp_add_tag` / `update` / `delete` จัดการแท็กได้ | [ ] | |
| 5 | `sp_create_plan` / `update` จัดการแผนงบประมาณได้ | [ ] | |
| 6 | `sp_add_transaction` บันทึกรายรับ/จ่ายได้ | [ ] | |
| 7 | `sp_tag_transaction` ผูกแท็กกับรายการได้ | [ ] | |
| 8 | `sp_update_transaction` แก้ไขรายการได้ | [ ] | |
| 9 | `sp_delete_transaction` ลบรายการและแท็กเชื่อมโยงได้ | [ ] | |
| 10 | `sp_monthly_summary` สรุปรายรับ-จ่ายรายเดือนถูกต้อง | [ ] | |
| 11 | `sp_yearly_summary` แจกแจงรายเดือนครบ 12 เดือน | [ ] | |
| 12 | `sp_compare_months` เปรียบเทียบ 2 เดือนและคิด % ได้ | [ ] | |
| 13 | `sp_check_plan` ตรวจงบประมาณและบอกสถานะเกิน/คงเหลือ | [ ] | |
| 14 | View `V_UserCurrencySummary` คำนวณ UseableMoney ตรง | [ ] | |
| 15 | Negative Test ดักจับ Regex เวลา และ Check Constraints ได้ | [ ] | |

---

*จบขั้นตอนการทดสอบส่วน SE (Personal Finance Management)*
