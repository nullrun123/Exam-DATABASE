# 🏭 BA — รายงาน SQL (Complex JOIN Queries)
> **ระบบจัดการคลังสินค้า (Warehouse Management System)**  
> รายงานที่เกิดจากการ JOIN หลายตาราง ได้ Dataset ที่สมบูรณ์

---

## 🧠 แนวคิด: โครงสร้าง JOIN ของ BA

```
Setup Table        Master Table        Transaction Table
   Category    ──►    Item         ◄──  (ข้อมูลรายการ)
   WMS         ──►    Employee
               ──►    WareHouse
                         │
                    Department
```

**ลำดับความสัมพันธ์:**
```
Category (1) ──► (N) Item (N) ◄── (1) WareHouse (1) ◄── (1) WMS
Department (1) ──► (N) Employee (N) ◄── (1) WMS
Employee (1) ──► (N) Employee  ← Self JOIN (Supervisor)
```

---

## 📊 Report 1: รายงานสินค้าในคลังสินค้า

> **เปรียบได้กับ:** รายการสต็อกสินค้า / ใบรับสินค้า  
> **ตาราง JOIN:** `Item` + `Category` + `WareHouse` + `WMS`

```sql
SELECT
    i.ItemID                                AS "รหัสสินค้า",
    c.CatagoryName                          AS "หมวดหมู่",
    w.WareHouseID                           AS "รหัสคลัง",
    w.Address                               AS "ที่อยู่คลัง",
    w.Check_Approval                        AS "สถานะคลัง",
    wms.RegisterDate                        AS "วันลงทะเบียน WMS",
    i.ArrivalDate                           AS "วันรับสินค้า",
    i.CostPrice                             AS "ราคาต้นทุน",
    i.SalePrice                             AS "ราคาขาย",
    i.SalePrice - i.CostPrice              AS "กำไรต่อชิ้น",
    i.Counts                                AS "จำนวนคงเหลือ",
    i.Counts * i.SalePrice                 AS "มูลค่าสต็อกรวม"
FROM  Item        i
JOIN  Category    c   ON i.CatagoryID  = c.CatagoryID
JOIN  WareHouse   w   ON i.WareHouseID = w.WareHouseID
JOIN  WMS         wms ON i.WMS_Address = wms.Address
ORDER BY c.CatagoryName, w.WareHouseID;
```

**ตัวอย่างผลลัพธ์:**

| รหัสสินค้า | หมวดหมู่ | รหัสคลัง | สถานะคลัง | ราคาต้นทุน | ราคาขาย | กำไรต่อชิ้น | จำนวน | มูลค่าสต็อก |
|-----------|---------|---------|----------|-----------|--------|------------|------|-----------|
| IT001 | อาหารสด | WH01 | Approved | 20.00 | 35.00 | 15.00 | 120 | 4,200.00 |
| IT002 | อาหารสด | WH01 | Approved | 5.00 | 10.00 | 5.00 | 350 | 3,500.00 |
| IT012 | อาหารแห้ง | WH03 | Pending | 60.00 | 100.00 | 40.00 | 25 | 2,500.00 |

> **ตาราง JOIN ทั้งหมด:** 4 ตาราง | **JOIN Type:** `INNER JOIN` ทั้งหมด

---

## 📊 Report 2: รายงานพนักงานพร้อมแผนกและหัวหน้า

> **เปรียบได้กับ:** สัญญาจ้างพนักงาน / บัตรพนักงาน / สายการบังคับบัญชา  
> **ตาราง JOIN:** `Employee` + `Department` + `WMS` + `Employee` (Self JOIN)

```sql
SELECT
    e.EmployeeId                                        AS "รหัสพนักงาน",
    e.FirstName || ' ' || e.LastName                   AS "ชื่อ-นามสกุล",
    e.WorkStatus                                        AS "สถานะ (W=ทำงาน Q=ออก)",
    e.Salary                                            AS "เงินเดือน",
    e.StartDate                                         AS "วันเริ่มงาน",
    e.Check_EmpStatus                                   AS "สถานะเข้างาน",
    d.DepartmentName                                    AS "แผนก",
    sup.FirstName || ' ' || sup.LastName               AS "ชื่อหัวหน้า",
    wms.Address                                         AS "ระบบ WMS ที่สังกัด",
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.StartDate) / 12)  AS "อายุงาน (ปี)"
FROM  Employee   e
JOIN  Department d    ON e.DepartmentId  = d.DepartmentID
JOIN  WMS        wms  ON e.WMSAddress    = wms.Address
LEFT JOIN Employee sup ON e.SupervisorId = sup.EmployeeId
WHERE e.WorkStatus = 'W'
ORDER BY d.DepartmentName, e.Salary DESC;
```

**ตัวอย่างผลลัพธ์:**

| รหัส | ชื่อ-นามสกุล | เงินเดือน | วันเริ่มงาน | แผนก | ชื่อหัวหน้า | อายุงาน |
|-----|-------------|---------|-----------|-----|-----------|-------|
| E001 | วิชัย สุขสวัสดิ์ | 52,000 | 15/01/2019 | คลังสินค้า | (ไม่มี) | 7 |
| E005 | กิตติพัฒน์ แก้วมณี | 22,000 | 01/03/2022 | คลังสินค้า | วิชัย สุขสวัสดิ์ | 4 |
| E006 | ปิยะนุช บุญเรือง | 21,000 | 15/07/2022 | คลังสินค้า | วิชัย สุขสวัสดิ์ | 4 |

> **ตาราง JOIN:** 4 ตาราง | ใช้ `LEFT JOIN` กับ `Employee sup` เพราะหัวหน้าสุดไม่มี Supervisor

---

## 📊 Report 3: รายงานภาพรวมสต็อกแยกตามคลังและหมวดหมู่

> **เปรียบได้กับ:** รายงานการตรวจนับสต็อก (Inventory Audit) / ใบสรุปคลัง  
> **ตาราง JOIN:** `WareHouse` + `Item` + `Category` + **GROUP BY**

```sql
SELECT
    w.WareHouseID                                       AS "คลัง",
    w.Address                                           AS "ที่อยู่",
    w.Check_Approval                                    AS "สถานะคลัง",
    c.CatagoryName                                      AS "หมวดหมู่",
    COUNT(i.ItemID)                                     AS "จำนวนรายการสินค้า",
    SUM(i.Counts)                                       AS "จำนวนชิ้นรวม",
    MIN(i.SalePrice)                                    AS "ราคาต่ำสุด",
    MAX(i.SalePrice)                                    AS "ราคาสูงสุด",
    ROUND(AVG(i.SalePrice), 2)                         AS "ราคาเฉลี่ย",
    SUM(i.Counts * i.CostPrice)                        AS "มูลค่าต้นทุนรวม",
    SUM(i.Counts * i.SalePrice)                        AS "มูลค่าขายรวม",
    SUM(i.Counts * (i.SalePrice - i.CostPrice))       AS "กำไรรวม"
FROM  WareHouse w
JOIN  Item      i ON i.WareHouseID = w.WareHouseID
JOIN  Category  c ON i.CatagoryID  = c.CatagoryID
GROUP BY w.WareHouseID, w.Address, w.Check_Approval, c.CatagoryName
ORDER BY w.WareHouseID, c.CatagoryName;
```

**ตัวอย่างผลลัพธ์:**

| คลัง | สถานะ | หมวดหมู่ | จำนวนรายการ | ชิ้นรวม | มูลค่าต้นทุน | มูลค่าขาย | กำไรรวม |
|-----|------|---------|-----------|-------|-----------|---------|-------|
| WH01 | Approved | อาหารสด | 2 | 470 | 5,750.00 | 10,250.00 | 4,500.00 |
| WH02 | Approved | ขนมหวาน | 4 | 260 | 5,730.00 | 9,900.00 | 4,170.00 |
| WH03 | Pending | อาหารแห้ง | 2 | 35 | 2,750.00 | 4,500.00 | 1,750.00 |

---

## 📊 Report 4: รายงานพนักงานที่สังกัด WMS ในคลังที่ยัง Pending

> **เปรียบได้กับ:** รายงานการมอบหมายงาน / ตรวจสอบสิทธิ์ก่อนอนุมัติ  
> **ตาราง JOIN:** `Employee` + `Department` + `WMS` + `WareHouse`

```sql
SELECT
    e.EmployeeId                            AS "รหัสพนักงาน",
    e.FirstName || ' ' || e.LastName       AS "ชื่อพนักงาน",
    d.DepartmentName                        AS "แผนก",
    w.WareHouseID                           AS "คลังที่ทำงาน",
    w.Check_Approval                        AS "สถานะคลัง",
    w.Latest_Check                          AS "วันตรวจล่าสุด",
    'ต้องรอการอนุมัติ'                     AS "หมายเหตุ"
FROM  Employee   e
JOIN  Department d   ON e.DepartmentId  = d.DepartmentID
JOIN  WMS        wms ON e.WMSAddress    = wms.Address
JOIN  WareHouse  w   ON w.WMS_Address   = wms.Address
WHERE w.Check_Approval = 'Pending'
  AND e.WorkStatus     = 'W'
ORDER BY d.DepartmentName;
```

**ตัวอย่างผลลัพธ์:**

| รหัสพนักงาน | ชื่อพนักงาน | แผนก | คลัง | สถานะ | วันตรวจล่าสุด |
|-----------|-----------|-----|-----|------|-------------|
| E007 | สุรเชษฐ์ เพชรรัตน์ | ควบคุมสต๊อก | WH03 | Pending | 30/10/2025 |
| E009 | ณัฐพล จันทร์เพ็ญ | จัดซื้อ | WH03 | Pending | 30/10/2025 |

---

## 📌 สรุปตาราง JOIN ทั้งหมดของ BA

| Report | ตารางที่ JOIN | จำนวนตาราง | JOIN Type | จุดประสงค์ |
|--------|-------------|-----------|----------|-----------|
| Report 1 | Item, Category, WareHouse, WMS | 4 | INNER × 3 | ดูสต็อกครบทุกมิติ |
| Report 2 | Employee, Department, WMS, Employee (self) | 4 | INNER × 2, LEFT × 1 | สายบังคับบัญชา |
| Report 3 | WareHouse, Item, Category | 3 | INNER × 2 + GROUP BY | Inventory Audit |
| Report 4 | Employee, Department, WMS, WareHouse | 4 | INNER × 3 | ตรวจสอบสิทธิ์คลัง |

---

*S1G2 | BA Reports | November 2026*
