# 📚 คู่มือการรันฐานข้อมูล — ตั้งแต่ต้นจนถึง PL/SQL
> **S1G2 | Exam-DATABASE | ระบบจัดการคลังสินค้า (BA) + แอปบริหารการเงิน (SE)**

---

## 🗂️ โครงสร้างโปรเจกต์

```
Exam-DATABASE/
├── docs/
│   ├── BA-Documentation.md     ← เอกสาร BA ฉบับสมบูรณ์
│   ├── SE-Documentation.md     ← เอกสาร SE ฉบับสมบูรณ์
│   └── GUIDE.md                ← คู่มือนี้
├── DDL/
│   ├── BA.sql                  ← สร้างตาราง BA (WMS System)
│   └── SE.sql                  ← สร้างตาราง SE (Finance App)
├── DML/
│   ├── BA.sql                  ← ข้อมูลตัวอย่าง BA
│   └── SE.sql                  ← ข้อมูลตัวอย่าง SE
├── PL/
│   ├── BA.sql                  ← Stored Procedures BA
│   └── SE.sql                  ← Stored Procedures SE
└── เอกสาร/
    ├── BA/
    │   ├── BA.pdf
    │   └── S1G2 *.pdf
    └── SE/
        ├── SE.pdf
        ├── S1G2 Architectural.pdf
        ├── S1G2 Functional & Non Functional Requirements.pdf
        └── SE-redesign.png
```

---

## 🚀 การรันระบบตั้งแต่ต้น

### ขั้นตอนที่ 0 — ตรวจสอบ Oracle Version

```sql
SELECT * FROM v$version;
```

> - **Oracle 23ai** → รัน SQL ได้เลย (รองรับ BOOLEAN)  
> - **Oracle 19c / 21c** → ต้องแก้ BOOLEAN เป็น NUMBER(1) ในไฟล์ SE

---

## 🏭 BA — ระบบจัดการคลังสินค้า (WMS)

### Step 1: เชื่อมต่อ Database

```bash
sqlplus username/password@localhost:1521/XEPDB1
```

```sql
SET SERVEROUTPUT ON SIZE 1000000
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

### Step 2: รัน DDL — สร้างตาราง

```sql
-- วิธีที่ 1: รันไฟล์โดยตรง
@D:\year2\DB\final-exam\Exam-DATABASE\DDL\BA.sql

-- วิธีที่ 2: copy-paste เนื้อหาด้านล่างทั้งหมด
```

**ลำดับตาราง BA:**
```
1. Category        (ไม่มี FK)
2. WMS             (ไม่มี FK)
3. WareHouse       (FK → WMS)
4. Department      (FK → Employee*) ← * INSERT Employee ก่อน หรือ defer
5. Employee        (FK → Department, WMS, Employee self-join)
6. Item            (FK → WareHouse, Category, WMS)
```

> ⚠️ **หมายเหตุ:** ใน DDL/BA.sql มีการสร้าง Department ก่อน Employee แต่ Department มี FK ไปหา Employee — ดังนั้นจะ INSERT data ได้หลัง Employee ถูกสร้างแล้ว

### Step 3: รัน DML — ใส่ข้อมูลตัวอย่าง

```sql
@D:\year2\DB\final-exam\Exam-DATABASE\DML\BA.sql
```

**ลำดับ INSERT ที่ถูกต้อง:**
```
1. Category
2. WMS
3. WareHouse
4. Department (MgrEmployeeID ยังไม่ตรง FK ตอนนี้ ค่อย UPDATE ทีหลัง)
5. Employee (INSERT หัวหน้า E001-E004 ก่อน แล้วค่อย INSERT ลูกน้อง)
6. Item
```

### Step 4: รัน PL/SQL — สร้าง Stored Procedures

```sql
@D:\year2\DB\final-exam\Exam-DATABASE\PL\BA.sql
```

### Step 5: ทดสอบ BA System

```sql
SET SERVEROUTPUT ON

-- ทดสอบเพิ่มหมวดหมู่
EXEC sp_add_category('CT10', 'ของสด');

-- ทดสอบลงทะเบียน WMS ใหม่
EXEC sp_register_wms('WMSID4', SYSDATE);

-- ทดสอบเพิ่มคลังสินค้า
EXEC sp_create_warehouse('WH04', 'ที่อยู่ทดสอบ', 'WMSID4', SYSDATE, 'Pending');

-- ทดสอบเพิ่มพนักงาน
BEGIN
    sp_add_employee(
        'E012', 'ทดสอบ', 'ระบบ', 'W', 20000,
        SYSDATE, NULL, 'D01', 'WMSID1', 'E001', 'Arrival'
    );
    COMMIT;
END;
/

-- ทดสอบปรับสต็อก (ลดจำนวน IT001 ลง 5)
EXEC sp_update_item_stock('IT001', 5);

-- ทดสอบอนุมัติคลัง
EXEC sp_approve_warehouse('WH03', 'Approved');

-- ทดสอบลาออก
EXEC sp_resign_employee('E007', SYSDATE);

COMMIT;

-- ตรวจสอบผล
SELECT * FROM Category ORDER BY CatagoryID;
SELECT * FROM WareHouse ORDER BY WareHouseID;
SELECT EmployeeId, FirstName, WorkStatus, Check_EmpStatus FROM Employee;
SELECT ItemID, Counts FROM Item ORDER BY ItemID;
SELECT * FROM V_Department_Total;
```

---

## 💰 SE — แอปบริหารการเงินส่วนบุคคล

### Step 1: เชื่อมต่อ Database (เหมือน BA)

```sql
SET SERVEROUTPUT ON SIZE 1000000
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
```

> ⚠️ **Oracle < 23ai?** ต้องแก้ไฟล์ DDL/SE.sql ก่อน:
> - เปลี่ยน `RevenueFlag BOOLEAN NOT NULL` → `RevenueFlag NUMBER(1) NOT NULL`
> - เปลี่ยน `CHECK (RevenueFlag IN (TRUE, FALSE))` → `CHECK (RevenueFlag IN (0, 1))`
> - เปลี่ยน DML: `'T'` → `1`, `'F'` → `0`
> - เปลี่ยน PL Procedure parameter: `IN BOOLEAN` → `IN NUMBER`

### Step 2: รัน DDL — สร้างตาราง

```sql
@D:\year2\DB\final-exam\Exam-DATABASE\DDL\SE.sql
```

**ลำดับตาราง SE:**
```
1. UserCurrencyData  (ไม่มี FK) ← ต้องสร้างก่อน CurrencyPlan!
2. CurrencyPlan      (FK → UserCurrencyData)
3. Tag               (ไม่มี FK)
4. Transactions      (FK → UserCurrencyData)
5. TagList           (FK → Transactions + Tag)
```

> ⚠️ **หมายเหตุ:** ในไฟล์ DDL/SE.sql ต้องสร้าง UserCurrencyData ก่อน CurrencyPlan จึงจะไม่ error

### Step 3: รัน DML — ใส่ข้อมูลตัวอย่าง

```sql
@D:\year2\DB\final-exam\Exam-DATABASE\DML\SE.sql
```

### Step 4: รัน PL/SQL — สร้าง Stored Procedures

```sql
@D:\year2\DB\final-exam\Exam-DATABASE\PL\SE.sql
```

### Step 5: ทดสอบ SE System

```sql
SET SERVEROUTPUT ON

-- สร้างบัญชีทดสอบ
BEGIN
    sp_create_account('TEST01');
    sp_create_plan('TP01', 'TEST01', N'งบอาหาร', N'งบอาหารต่อเดือน',
                   DATE '2026-11-30', 3000);
    sp_add_tag('TX01', N'อาหารทดสอบ');
    COMMIT;
END;
/

-- เพิ่มรายการทดสอบ
BEGIN
    sp_add_transaction('TX001', 'TEST01', N'เงินเดือนทดสอบ',
                       DATE '2026-11-01', '09:00:00', 20000, TRUE, 'เงินเดือน');
    sp_add_transaction('TX002', 'TEST01', N'ค่าข้าว',
                       DATE '2026-11-02', '12:00:00', 150, FALSE, 'ข้าวแกง');
    sp_add_transaction('TX003', 'TEST01', N'ค่ากาแฟ',
                       DATE '2026-11-03', '08:00:00', 80, FALSE, 'กาแฟเย็น');
    sp_tag_transaction('TX002', 'TX01');
    sp_tag_transaction('TX003', 'TX01');
    COMMIT;
END;
/

-- ดูสรุป
BEGIN
    sp_monthly_summary('TEST01', 2026, 11);
    sp_check_plan('TP01');
END;
/

-- ทดสอบแก้ไขและลบ
BEGIN
    sp_update_transaction('TX002', N'ค่าข้าวอัปเดต',
                          DATE '2026-11-02', '12:00:00', 180, FALSE, 'ข้าวแกง + น้ำ');
    sp_delete_transaction('TX003');
    COMMIT;
END;
/

-- ดูผลหลังแก้ไข
BEGIN
    sp_monthly_summary('TEST01', 2026, 11);
    sp_check_plan('TP01');
END;
/

-- ดู View
SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;
```

---

## 📊 ตรวจสอบข้อมูลหลังรัน

### BA — ตรวจสอบ

```sql
-- ดูข้อมูลทั้งหมด
SELECT 'Category' as tbl, COUNT(*) as cnt FROM Category
UNION ALL SELECT 'WMS', COUNT(*) FROM WMS
UNION ALL SELECT 'WareHouse', COUNT(*) FROM WareHouse
UNION ALL SELECT 'Department', COUNT(*) FROM Department
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Item', COUNT(*) FROM Item;

-- ดู Derived Attribute
SELECT * FROM V_Department_Total;

-- ดูสินค้าในแต่ละคลัง
SELECT w.WareHouseID, w.Address, COUNT(i.ItemID) AS ItemCount, SUM(i.Counts) AS TotalStock
FROM WareHouse w
LEFT JOIN Item i ON i.WareHouseID = w.WareHouseID
GROUP BY w.WareHouseID, w.Address;
```

### SE — ตรวจสอบ

```sql
-- ดูข้อมูลทั้งหมด
SELECT 'UserCurrencyData' as tbl, COUNT(*) as cnt FROM UserCurrencyData
UNION ALL SELECT 'CurrencyPlan', COUNT(*) FROM CurrencyPlan
UNION ALL SELECT 'Tag', COUNT(*) FROM Tag
UNION ALL SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL SELECT 'TagList', COUNT(*) FROM TagList;

-- ดูสรุปยอดเงินต่อบัญชี
SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;

-- ดูรายการรายรับ
SELECT TransactionID, AccountID, TransName, TransDate, Amount
FROM Transactions
WHERE RevenueFlag = TRUE
ORDER BY TransDate;

-- ดูรายการรายจ่าย
SELECT TransactionID, AccountID, TransName, TransDate, Amount
FROM Transactions
WHERE RevenueFlag = FALSE
ORDER BY TransDate;
```

---

## 🔧 Troubleshooting ที่พบบ่อย

| Error | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `ORA-00904: "BOOLEAN"` | Oracle < 23ai | เปลี่ยนเป็น `NUMBER(1)` |
| `ORA-02291` | FK ไม่พบ parent row | INSERT parent ก่อน |
| `ORA-00001` | PK/UQ ซ้ำ | เปลี่ยน ID ที่ใส่ |
| `ORA-02290` | ค่าไม่ผ่าน CHECK | ตรวจสอบค่าตาม constraint |
| `ORA-01031` | ไม่มีสิทธิ์ | ติดต่อ DBA |
| `ORA-04098: trigger invalid` | trigger error | `SHOW ERRORS TRIGGER trigger_name` |
| `PLS-00201: identifier must be declared` | ชื่อตาราง/คอลัมน์ผิด | ตรวจสอบ spelling |

### คำสั่งช่วย Debug

```sql
-- ดู errors ล่าสุด
SHOW ERRORS;

-- ดู procedures ที่มีอยู่
SELECT object_name, status FROM user_objects WHERE object_type = 'PROCEDURE';

-- ดู tables ทั้งหมด
SELECT table_name FROM user_tables ORDER BY 1;

-- ดู constraints ของตาราง
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'TRANSACTIONS';

-- Drop ทุกอย่างแล้วเริ่มใหม่
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
    FOR p IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE') LOOP
        EXECUTE IMMEDIATE 'DROP PROCEDURE ' || p.object_name;
    END LOOP;
    FOR v IN (SELECT view_name FROM user_views) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;
END;
/
PURGE RECYCLEBIN;
```

---

## 📌 Notes สำคัญ

### ความแตกต่างระหว่าง BA และ SE

| ด้าน | BA (WMS) | SE (Finance) |
|------|----------|-------------|
| **Domain** | คลังสินค้า | การเงินส่วนบุคคล |
| **ตารางหลัก** | Category, WMS, WareHouse, Department, Employee, Item | UserCurrencyData, CurrencyPlan, Tag, Transactions, TagList |
| **Oracle Feature** | ไม่มีข้อจำกัดพิเศษ | ต้องการ **Oracle 23ai** สำหรับ BOOLEAN |
| **Views** | V_Department_Total | V_UserCurrencySummary |
| **SP จำนวน** | 11 Procedures | 14 Procedures |

### Best Practices

1. **เสมอ `SET SERVEROUTPUT ON`** ก่อนรัน Procedure
2. **COMMIT** หลัง DML สำคัญ
3. **INSERT Parent ก่อน Child** เสมอ
4. **ทดสอบ** ด้วยข้อมูลขนาดเล็กก่อน

---

*คู่มือโดย S1G2 | Updated: November 2026*
