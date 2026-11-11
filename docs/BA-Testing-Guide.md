# 🧪 BA — คู่มือการทดสอบระบบฐานข้อมูลแบบ Step-by-Step
> **ระบบจัดการคลังสินค้า (Warehouse Management System — WMS)**  
> คู่มือการทดสอบความถูกต้องตั้งแต่โครงสร้าง DDL, ข้อมูล DML, Stored Procedures (PL/SQL) จนถึงการทดสอบเงื่อนไขข้อจำกัดทางธุรกิจ (Negative Testing)

---

## 📋 สารบัญขั้นตอนการทดสอบ

- [Step 0: เตรียม Environment ก่อนเริ่มทดสอบ](#step-0-เตรียม-environment-ก่อนเริ่มทดสอบ)
- [Step 1: ทดสอบการติดตั้งและโครงสร้างตาราง (DDL Verification)](#step-1-ทดสอบการติดตั้งและโครงสร้างตาราง-ddl-verification)
- [Step 2: ทดสอบการนำเข้าข้อมูลตัวอย่าง (DML Verification)](#step-2-ทดสอบการนำเข้าข้อมูลตัวอย่าง-dml-verification)
- [Step 3: ทดสอบ Stored Procedures (PL/SQL) ครบทุกฟังก์ชัน](#step-3-ทดสอบ-stored-procedures-plsql-ครบทุกฟังก์ชัน)
  - [3.1 หมวด Master / Setup Data (Category, WMS, Warehouse, Department, Employee, Item)](#31-หมวด-master--setup-data)
  - [3.2 หมวด Business Transactions & Updates](#32-หมวด-business-transactions--updates)
- [Step 4: ทดสอบ Derived Attribute & Views](#step-4-ทดสอบ-derived-attribute--views)
- [Step 5: ทดสอบรายงานเชิงซ้อน (Complex Reports)](#step-5-ทดสอบรายงานเชิงซ้อน-complex-reports)
- [Step 6: ทดสอบข้อจำกัดทางธุรกิจ (Negative Testing / Error Case)](#step-6-ทดสอบข้อจำกัดทางธุรกิจ-negative-testing--error-case)
- [Step 7: Check-List สรุปผลการทดสอบ](#step-7-check-list-สรุปผลการทดสอบ)

---

## Step 0: เตรียม Environment ก่อนเริ่มทดสอบ

เปิด SQL*Plus, SQL Developer หรือ DBeaver แล้วรันคำสั่งตั้งค่าหน้าจอให้แสดงผลลัพธ์ของ `DBMS_OUTPUT`:

```sql
-- เปิดการแสดงผลของ Stored Procedure
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 250;
SET PAGESIZE 100;

-- ตั้งค่ารูปแบบวันที่ให้ตรงกับระบบ
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

---

## Step 1: ทดสอบการติดตั้งและโครงสร้างตาราง (DDL Verification)

รันไฟล์ `DDL/BA.sql` แล้วตรวจสอบว่าตารางทั้ง 6 ตารางถูกสร้างขึ้นครบถ้วนและสมบูรณ์

### 1.1 ตรวจสอบรายชื่อตาราง
```sql
SELECT table_name 
FROM user_tables 
WHERE table_name IN ('CATEGORY', 'WMS', 'WAREHOUSE', 'DEPARTMENT', 'EMPLOYEE', 'ITEM')
ORDER BY table_name;
```
* **ผลลัพธ์ที่ถูกต้อง:** ต้องแสดงครบทั้ง 6 ตาราง

### 1.2 ตรวจสอบ Constraints (PK, FK, Check, Unique)
```sql
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('CATEGORY', 'WMS', 'WAREHOUSE', 'DEPARTMENT', 'EMPLOYEE', 'ITEM')
ORDER BY table_name, constraint_type;
```
* **ผลลัพธ์ที่ถูกต้อง:** สถานะของทุกลำดับ Constraint ต้องเป็น `ENABLED`

---

## Step 2: ทดสอบการนำเข้าข้อมูลตัวอย่าง (DML Verification)

รันไฟล์ `DML/BA.sql` จากนั้นตรวจสอบจำนวน Record เพื่อยืนยันว่าไม่มีแถวข้อมูลหลุดหาย

### 2.1 นับจำนวนข้อมูลทุกตาราง
```sql
SELECT 'Category' AS Table_Name, COUNT(*) AS Total_Rows FROM Category
UNION ALL
SELECT 'WMS', COUNT(*) FROM WMS
UNION ALL
SELECT 'WareHouse', COUNT(*) FROM WareHouse
UNION ALL
SELECT 'Department', COUNT(*) FROM Department
UNION ALL
SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL
SELECT 'Item', COUNT(*) FROM Item;
```

* **ผลลัพธ์ที่ถูกต้องตาม Dataset มาตรฐาน:**
  - `Category`: **5 แถว** (CT01 - CT05)
  - `WMS`: **3 แถว** (WMSID1 - WMSID3)
  - `WareHouse`: **3 แถว** (WH01 - WH03)
  - `Department`: **4 แถว** (D01 - D04)
  - `Employee`: **11 แถว** (E001 - E011)
  - `Item`: **15 แถว** (IT001 - IT015)

---

## Step 3: ทดสอบ Stored Procedures (PL/SQL) ครบทุกฟังก์ชัน

รันไฟล์ `PL/BA.sql` เพื่อคอมไพล์โปรซีเดอร์ จากนั้นทำการทดสอบทีละโปรซีเดอร์ตามลำดับ:

### 3.1 หมวด Master / Setup Data

#### 🧪 ทดสอบที่ 3.1.1: `sp_add_category` (เพิ่มหมวดหมู่สินค้า)
```sql
-- ทดสอบการเรียกใช้งาน
EXEC sp_add_category('CT90', 'อุปกรณ์บรรจุภัณฑ์');

-- ตรวจสอบผลในตาราง
SELECT * FROM Category WHERE CatagoryID = 'CT90';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - มีข้อความขึ้น: `เพิ่มหมวดหมู่สินค้าเรียบร้อย: CT90`
  - ตาราง Category ปรากฏแถวข้อมูล `CT90` ชื่อ `อุปกรณ์บรรจุภัณฑ์`

---

#### 🧪 ทดสอบที่ 3.1.2: `sp_register_wms` (ลงทะเบียนระบบ WMS ใหม่)
```sql
-- ทดสอบการเรียกใช้งาน (กำหนดวันปัจจุบันอัตโนมัติเมื่อเป็น NULL)
EXEC sp_register_wms('WMSID99', NULL);

-- ตรวจสอบผลในตาราง
SELECT * FROM WMS WHERE Address = 'WMSID99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `ลงทะเบียนระบบ WMS เรียบร้อย: WMSID99`
  - คอลัมน์ `RegisterDate` ได้ค่าเป็นวันปัจจุบัน

---

#### 🧪 ทดสอบที่ 3.1.3: `sp_create_warehouse` (สร้างคลังสินค้าใหม่)
```sql
-- ทดสอบการเรียกใช้งาน
EXEC sp_create_warehouse('WH99', 'คลังสินค้าสำรอง สุวรรณภูมิ', 'WMSID99', TO_DATE('11/11/2026','DD/MM/YYYY'), 'Pending');

-- ตรวจสอบผลในตาราง
SELECT * FROM WareHouse WHERE WareHouseID = 'WH99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `เพิ่มคลังสินค้าใหม่เรียบร้อย: WH99`
  - ข้อมูลคลัง WH99 เชื่อมโยงกับ WMSID99 และมีสถานะ `Pending`

---

#### 🧪 ทดสอบที่ 3.1.4: `sp_create_department` (สร้างแผนกใหม่)
```sql
-- ทดสอบการเรียกใช้งาน
EXEC sp_create_department('D99', 'แผนกตรวจสอบคุณภาพ', NULL, NULL);

-- ตรวจสอบผลในตาราง
SELECT * FROM Department WHERE DepartmentID = 'D99';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `เพิ่มแผนกใหม่เรียบร้อย: D99`

---

#### 🧪 ทดสอบที่ 3.1.5: `sp_add_employee` (เพิ่มพนักงานใหม่)
```sql
-- ทดสอบเพิ่มพนักงานรหัส E099 สังกัดแผนก D99 ภายใต้หัวหน้า E001
BEGIN
    sp_add_employee(
        p_empid        => 'E099',
        p_firstname    => 'สมศักดิ์',
        p_lastname     => 'กล้าหาญ',
        p_workstatus   => 'W',
        p_salary       => 28000,
        p_startdate    => TO_DATE('01/11/2026','DD/MM/YYYY'),
        p_resigndate   => NULL,
        p_depid        => 'D99',
        p_wmsaddress   => 'WMSID1',
        p_supervisorid => 'E001',
        p_empstatus    => 'Arrival'
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT EmployeeId, FirstName, LastName, WorkStatus, Salary, Check_EmpStatus 
FROM Employee WHERE EmployeeId = 'E099';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `เพิ่มพนักงานใหม่เรียบร้อย: E099`
  - ตาราง Employee มีข้อมูลครบทุกคอลัมน์ถูกต้อง

---

#### 🧪 ทดสอบที่ 3.1.6: `sp_add_item` (เพิ่มรายการสินค้าใหม่)
```sql
-- เพิ่มสินค้า IT099 ผูกกับคลัง WH01 หมวดหมู่ CT01
BEGIN
    sp_add_item(
        p_itemid      => 'IT099',
        p_price       => 50.00,
        p_arrivaldate => TO_DATE('10/11/2026','DD/MM/YYYY'),
        p_costprice   => 30.00,
        p_saleprice   => 50.00,
        p_counts      => 100,
        p_whid        => 'WH01',
        p_catid       => 'CT01',
        p_wms_address => 'WMSID1'
    );
    COMMIT;
END;
/

-- ตรวจสอบผล
SELECT ItemID, Counts, Price, WareHouseID, CatagoryID FROM Item WHERE ItemID = 'IT099';
```
* **ผลลัพธ์ที่คาดหวัง:** 
  - ข้อความ: `เพิ่มสินค้าใหม่เรียบร้อย: IT099`
  - ข้อมูลสินค้ามีจำนวนคงเหลือเริ่มต้น 100 ชิ้น

---

### 3.2 หมวด Business Transactions & Updates

#### 🧪 ทดสอบที่ 3.2.1: `sp_update_item_stock` (ปรับยอดสต็อกสินค้า)
```sql
-- เบิกจ่ายสินค้า IT099 ออกไป 20 ชิ้น (จากเดิม 100 ต้องเหลือ 80)
EXEC sp_update_item_stock('IT099', 20);

-- ตรวจสอบผล
SELECT ItemID, Counts FROM Item WHERE ItemID = 'IT099';
```
* **ผลลัพธ์ที่คาดหวัง:**
  - ข้อความ: `ปรับจำนวนสินค้าเรียบร้อย: IT099`
  - ค่า `Counts` ลดลงจาก 100 เหลือ **80**

---

#### 🧪 ทดสอบที่ 3.2.2: `sp_approve_warehouse` (อนุมัติผลตรวจคลังสินค้า)
```sql
-- ปรับสถานะคลัง WH99 จาก Pending เป็น Approved
EXEC sp_approve_warehouse('WH99', 'Approved');

-- ตรวจสอบผล
SELECT WareHouseID, Check_Approval, Latest_Check FROM WareHouse WHERE WareHouseID = 'WH99';
```
* **ผลลัพธ์ที่คาดหวัง:**
  - ข้อความ: `อัปเดตผลการตรวจคลังสินค้าเรียบร้อย: WH99`
  - ค่า `Check_Approval` เปลี่ยนเป็น `'Approved'` และ `Latest_Check` เป็นวันเวลาปัจจุบัน

---

#### 🧪 ทดสอบที่ 3.2.3: `sp_update_employee_status` (เปลี่ยนสถานะการเข้างาน)
```sql
-- ปรับสถานะพนักงาน E099 เป็น Not_Arrival
EXEC sp_update_employee_status('E099', 'Not_Arrival');

-- ตรวจสอบผล
SELECT EmployeeId, Check_EmpStatus FROM Employee WHERE EmployeeId = 'E099';
```
* **ผลลัพธ์ที่คาดหวัง:**
  - ข้อความ: `อัปเดตสถานะการเข้างานเรียบร้อย: E099`
  - `Check_EmpStatus` เปลี่ยนเป็น `'Not_Arrival'`

---

#### 🧪 ทดสอบที่ 3.2.4: `sp_assign_department_manager` (แต่งตั้งหัวหน้าแผนก)
```sql
-- แต่งตั้ง E099 ให้เป็นหัวหน้าแผนก D99
EXEC sp_assign_department_manager('D99', 'E099');

-- ตรวจสอบผล
SELECT DepartmentID, DepartmentName, MgrEmployeeID, MgrDate FROM Department WHERE DepartmentID = 'D99';
```
* **ผลลัพธ์ที่คาดหวัง:**
  - ข้อความ: `แต่งตั้งหัวหน้าแผนกเรียบร้อย: D99`
  - `MgrEmployeeID` อัปเดตเป็น `'E099'`

---

#### 🧪 ทดสอบที่ 3.2.5: `sp_resign_employee` (บันทึกการลาออกของพนักงาน)
```sql
-- บันทึกว่า E099 ลาออก
EXEC sp_resign_employee('E099', TO_DATE('11/11/2026','DD/MM/YYYY'));

-- ตรวจสอบผล
SELECT EmployeeId, WorkStatus, ResignDate FROM Employee WHERE EmployeeId = 'E099';
```
* **ผลลัพธ์ที่คาดหวัง:**
  - ข้อความ: `บันทึกการลาออกของพนักงานเรียบร้อย: E099`
  - `WorkStatus` เปลี่ยนเป็น `'Q'` และ `ResignDate` มีค่าเป็น `11/11/2026`

---

## Step 4: ทดสอบ Derived Attribute & Views

ทดสอบ View `V_Department_Total` ที่คำนวณจำนวนพนักงานในแต่ละแผนกแบบไดนามิก:

```sql
SELECT * FROM V_Department_Total ORDER BY DepartmentID;
```

* **ผลลัพธ์ที่คาดหวัง:**
  - แสดงรายชื่อแผนกทั้งหมด เช่น `D01`, `D02`, `D03`, `D04`, `D99`
  - คอลัมน์ `Total_Employee` ต้องนับจำนวนพนักงานในแผนกนั้นๆ อย่างถูกต้องตรงกับความเป็นจริง

---

## Step 5: ทดสอบรายงานเชิงซ้อน (Complex Reports)

ทดสอบรัน Query ที่มีการ JOIN หลายตารางเพื่อยืนยันว่า Dataset ทางธุรกิจทำงานถูกต้อง:

```sql
-- ทดสอบ JOIN 4 ตาราง: สินค้า + หมวดหมู่ + คลัง + WMS
SELECT 
    i.ItemID,
    c.CatagoryName,
    w.WareHouseID,
    w.Check_Approval,
    i.Counts,
    i.SalePrice,
    (i.Counts * i.SalePrice) AS Total_Stock_Value
FROM Item i
JOIN Category c ON i.CatagoryID = c.CatagoryID
JOIN WareHouse w ON i.WareHouseID = w.WareHouseID
JOIN WMS wms ON i.WMS_Address = wms.Address
WHERE i.ItemID = 'IT099';
```
* **ผลลัพธ์ที่คาดหวัง:** แสดงผลสินค้า `IT099` พร้อมชื่อหมวดหมู่ `อุปกรณ์บรรจุภัณฑ์` คลัง `WH99` ยอดคงเหลือ 80 ชิ้น ได้ถูกต้อง

---

## Step 6: ทดสอบข้อจำกัดทางธุรกิจ (Negative Testing / Error Case)

การทดสอบกรณีข้อมูลผิดพลาด เพื่อยืนยันว่า Database Constraints ป้องกันข้อมูลผิดกฎทางธุรกิจได้จริง:

### ❌ กรณีที่ 6.1: ลองตั้งเงินเดือนพนักงานเป็น 0 หรือติดลบ (`CK_Employee_Salary`)
```sql
INSERT INTO Employee VALUES (
    'E888','ทดสอบ','เงินเดือนลบ','W',-500,SYSDATE,NULL,'D01','WMSID1','E001','Arrival'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ต้องขึ้น Error **`ORA-02290: check constraint (...) violated`**

---

### ❌ กรณีที่ 6.2: ลองให้พนักงานเป็นหัวหน้าตัวเอง (`CK_Employee_Supervisor`)
```sql
INSERT INTO Employee VALUES (
    'E888','สมชาย','หัวหน้าตัวเอง','W',30000,SYSDATE,NULL,'D01','WMSID1','E888','Arrival'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ต้องขึ้น Error **`ORA-02290: check constraint (...) violated`** (เพราะ SupervisorId ห้ามตรงกับ EmployeeId)

---

### ❌ กรณีที่ 6.3: ใส่สถานะตรวจคลังนอกเหนือที่กำหนด (`CK_WareHouse_Approval`)
```sql
INSERT INTO WareHouse VALUES (
    'WH88','ที่อยู่ทดสอบ','WMSID1',SYSDATE,'Waiting'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ต้องขึ้น Error **`ORA-02290: check constraint (...) violated`** (เพราะสถานะต้องเป็น `'Pending'`, `'Approved'`, หรือ `'Rejected'` เท่านั้น)

---

### ❌ กรณีที่ 6.4: ใส่สต็อกสินค้าติดลบ (`CK_Item_Counts`)
```sql
INSERT INTO Item VALUES (
    'IT888', 100, SYSDATE, 50, 100, -10, 'WH01', 'CT01', 'WMSID1'
);
```
* **ผลลัพธ์ที่คาดหวัง:** ต้องขึ้น Error **`ORA-02290: check constraint (...) violated`** (สต็อกต้อง >= 0)

---

## Step 7: Check-List สรุปผลการทดสอบ

| ลำดับ | รายการทดสอบ | สถานะ (Pass / Fail) | หมายเหตุ |
|---|---|:---:|---|
| 1 | ตารางทั้ง 6 ตารางถูกสร้างครบถ้วน | [ ] | DDL/BA.sql |
| 2 | ข้อมูลตัวอย่าง DML เข้าครบทุกแถว | [ ] | DML/BA.sql |
| 3 | `sp_add_category` เพิ่มข้อมูลได้จริง | [ ] | |
| 4 | `sp_register_wms` ลงทะเบียนได้จริง | [ ] | |
| 5 | `sp_create_warehouse` เพิ่มคลังสำเร็จ | [ ] | |
| 6 | `sp_create_department` เพิ่มแผนกสำเร็จ | [ ] | |
| 7 | `sp_add_employee` เพิ่มพนักงานสำเร็จ | [ ] | |
| 8 | `sp_add_item` เพิ่มสินค้าสำเร็จ | [ ] | |
| 9 | `sp_update_item_stock` ปรับลดสต็อกได้ | [ ] | |
| 10 | `sp_approve_warehouse` ปรับผลตรวจได้ | [ ] | |
| 11 | `sp_update_employee_status` เปลี่ยนสถานะได้ | [ ] | |
| 12 | `sp_assign_department_manager` แต่งตั้งได้ | [ ] | |
| 13 | `sp_resign_employee` ลาออกเปลี่ยนเป็น 'Q' | [ ] | |
| 14 | View `V_Department_Total` แสดงตัวเลขตรง | [ ] | |
| 15 | Negative Test ดักจับข้อมูลผิดกฎได้ครบ | [ ] | |

---

*จบขั้นตอนการทดสอบส่วน BA (Warehouse Management System)*
