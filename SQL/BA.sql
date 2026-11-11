--รายงานสินค้าในคลังสินค้า
SELECT
    i.ItemID                                AS "รหัสสินค้า",
    i.ItemName                              AS "ชื่อสินค้า",
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


-- รายงานพนักงานพร้อมแผนกและหัวหน้า

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
