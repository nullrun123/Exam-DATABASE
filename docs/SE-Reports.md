# 💰 SE — รายงาน SQL (Complex JOIN Queries)
> **แอปพลิเคชันบริหารการเงินส่วนบุคคล (Personal Finance Management)**  
> รายงานที่เกิดจากการ JOIN หลายตาราง ได้ Dataset ที่สมบูรณ์

---

## 🧠 แนวคิด: โครงสร้าง JOIN ของ SE

```
Master Table              Transaction Table        Setup Table
UserCurrencyData ──► (N) Transactions ◄── (N) ── TagList ── (N) ──► Tag
UserCurrencyData ──► (N) CurrencyPlan
```

**ลำดับความสัมพันธ์:**
```
UserCurrencyData (1) ──► (N) CurrencyPlan
UserCurrencyData (1) ──► (N) Transactions
Transactions     (1) ──► (N) TagList (N) ◄── (1) Tag
```

---

## 📊 Report 1: รายงานประวัติรายการทรานแซ็กชันพร้อมแท็กทั้งหมด

> **เปรียบได้กับ:** ใบแจ้งยอดบัญชี / Statement รายเดือน  
> **ตาราง JOIN:** `Transactions` + `TagList` + `Tag`

```sql
SELECT
    t.AccountID                                         AS "รหัสบัญชี",
    t.TransactionID                                     AS "รหัสรายการ",
    t.TransName                                         AS "ชื่อรายการ",
    t.TransDate                                         AS "วันที่",
    t.TransTime                                         AS "เวลา",
    CASE WHEN t.RevenueFlag = 1
         THEN 'รายรับ' ELSE 'รายจ่าย' END             AS "ประเภท",
    t.Amount                                            AS "จำนวนเงิน",
    LISTAGG(tag.TagName, ', ')
        WITHIN GROUP (ORDER BY tl.LineNo)              AS "แท็กทั้งหมด",
    t.TransDescription                                  AS "หมายเหตุ"
FROM  Transactions t
LEFT JOIN TagList   tl  ON t.TransactionID = tl.TransactionID
LEFT JOIN Tag       tag ON tl.TagID        = tag.TagID
GROUP BY t.AccountID, t.TransactionID, t.TransName,
         t.TransDate, t.TransTime, t.RevenueFlag,
         t.Amount, t.TransDescription
ORDER BY t.AccountID, t.TransDate, t.TransTime;
```

**ตัวอย่างผลลัพธ์:**

| รหัสบัญชี | รหัสรายการ | ชื่อรายการ | วันที่ | ประเภท | จำนวนเงิน | แท็กทั้งหมด |
|---------|---------|---------|------|------|---------|-----------|
| ACC01 | TR001 | เงินเดือนกันยายน | 25/09/2026 | รายรับ | 25,000.00 | รายได้ |
| ACC01 | TR002 | ค่าข้าวกลางวัน | 26/09/2026 | รายจ่าย | 85.00 | อาหาร |
| ACC02 | TR006 | ซื้อหนังสือเรียน | 06/10/2026 | รายจ่าย | 650.00 | การศึกษา, ช้อปปิ้ง |

> **ตาราง JOIN:** 3 ตาราง | ใช้ `LEFT JOIN` เพราะบางรายการอาจไม่มีแท็ก  
> **เทคนิคพิเศษ:** `LISTAGG()` รวมหลายแท็กใน 1 แถว

---

## 📊 Report 2: รายงานเปรียบเทียบยอดจริงกับแผนการเงิน

> **เปรียบได้กับ:** รายงานการเบิกจ่ายงบประมาณ / ใบควบคุมงบ  
> **ตาราง JOIN:** `UserCurrencyData` + `CurrencyPlan` + `Transactions`

```sql
SELECT
    u.AccountID                                         AS "รหัสบัญชี",
    p.PlanID                                            AS "รหัสแผน",
    p.PlanName                                          AS "ชื่อแผน",
    p.PlanDate                                          AS "วันเป้าหมาย",
    p.Amount                                            AS "งบประมาณ",
    NVL(SUM(
        CASE WHEN t.RevenueFlag = 0
              AND TRUNC(t.TransDate, 'MM') = TRUNC(p.PlanDate, 'MM')
        THEN t.Amount END
    ), 0)                                               AS "ยอดใช้จ่ายจริง",
    p.Amount - NVL(SUM(
        CASE WHEN t.RevenueFlag = 0
              AND TRUNC(t.TransDate, 'MM') = TRUNC(p.PlanDate, 'MM')
        THEN t.Amount END
    ), 0)                                               AS "คงเหลือ/เกินงบ",
    CASE
        WHEN p.Amount < NVL(SUM(
            CASE WHEN t.RevenueFlag = 0
                  AND TRUNC(t.TransDate, 'MM') = TRUNC(p.PlanDate, 'MM')
            THEN t.Amount END), 0)
        THEN 'เกินงบ'
        ELSE 'อยู่ในงบ'
    END                                                 AS "สถานะ",
    p.DateCreate                                        AS "วันสร้างแผน",
    p.DateEdit                                          AS "แก้ไขล่าสุด"
FROM  UserCurrencyData  u
JOIN  CurrencyPlan      p  ON u.AccountID = p.AccountID
LEFT JOIN Transactions  t  ON t.AccountID = u.AccountID
GROUP BY u.AccountID, p.PlanID, p.PlanName,
         p.PlanDate, p.Amount, p.DateCreate, p.DateEdit
ORDER BY u.AccountID, p.PlanDate;
```

**ตัวอย่างผลลัพธ์:**

| รหัสบัญชี | รหัสแผน | ชื่อแผน | งบประมาณ | ยอดจริง | คงเหลือ | สถานะ |
|---------|-------|-------|--------|-------|-------|------|
| ACC01 | PL01 | ออมเงินซื้อโน้ตบุ๊ก | 36,000.00 | 4,629.00 | 31,371.00 | อยู่ในงบ |
| ACC01 | PL02 | ค่าเทอมภาคเรียนที่ 2 | 18,000.00 | 0.00 | 18,000.00 | อยู่ในงบ |
| ACC02 | PL03 | กองทุนฉุกเฉิน | 60,000.00 | 930.00 | 59,070.00 | อยู่ในงบ |

> **ตาราง JOIN:** 3 ตาราง | ใช้ `LEFT JOIN` กับ Transactions เพราะแผนบางแผนยังไม่มีรายการ  
> **เทคนิคพิเศษ:** `TRUNC(date, 'MM')` เปรียบเทียบเดือนเดียวกับ PlanDate

---

## 📊 Report 3: รายงานสรุปรายรับ-รายจ่ายแยกตามหมวดแท็ก (พร้อม % สัดส่วน)

> **เปรียบได้กับ:** สรุปใบแจ้งหนี้บัตรเครดิต / Monthly Spending Breakdown  
> **ตาราง JOIN:** `Transactions` + `TagList` + `Tag` + **Window Function**

```sql
SELECT
    t.AccountID                                         AS "รหัสบัญชี",
    EXTRACT(YEAR  FROM t.TransDate)                    AS "ปี",
    EXTRACT(MONTH FROM t.TransDate)                    AS "เดือน",
    tag.TagName                                         AS "หมวดหมู่",
    COUNT(DISTINCT t.TransactionID)                    AS "จำนวนรายการ",
    SUM(t.Amount)                                       AS "ยอดรวม",
    ROUND(
        SUM(t.Amount) / SUM(SUM(t.Amount)) OVER (
            PARTITION BY t.AccountID,
                         EXTRACT(YEAR  FROM t.TransDate),
                         EXTRACT(MONTH FROM t.TransDate)
        ) * 100, 2
    )                                                   AS "สัดส่วน (%)"
FROM  Transactions t
JOIN  TagList      tl  ON t.TransactionID = tl.TransactionID
JOIN  Tag          tag ON tl.TagID        = tag.TagID
WHERE t.RevenueFlag = 0
GROUP BY t.AccountID,
         EXTRACT(YEAR  FROM t.TransDate),
         EXTRACT(MONTH FROM t.TransDate),
         tag.TagName
ORDER BY t.AccountID, "ปี", "เดือน", SUM(t.Amount) DESC;
```

**ตัวอย่างผลลัพธ์:**

| รหัสบัญชี | ปี | เดือน | หมวดหมู่ | จำนวนรายการ | ยอดรวม | สัดส่วน (%) |
|---------|---|-----|---------|-----------|------|-----------|
| ACC01 | 2026 | 9 | ที่พัก | 1 | 4,500.00 | 97.00% |
| ACC01 | 2026 | 9 | อาหาร | 1 | 85.00 | 1.84% |
| ACC01 | 2026 | 9 | เดินทาง | 1 | 44.00 | 0.95% |
| ACC02 | 2026 | 10 | การศึกษา | 1 | 650.00 | 69.89% |
| ACC02 | 2026 | 10 | บันเทิง | 1 | 280.00 | 30.11% |

> **ตาราง JOIN:** 3 ตาราง  
> **เทคนิคพิเศษ:** `SUM() OVER(PARTITION BY ...)` คือ **Window Function** คำนวณสัดส่วน % ต่อยอดรวมของเดือนนั้น โดยไม่ต้อง Subquery เพิ่ม

---

## 📊 Report 4: รายงานสรุปยอดเงินต่อบัญชี (Derived Attribute จาก View)

> **เปรียบได้กับ:** หน้า Dashboard ยอดเงินคงเหลือ  
> **ตาราง JOIN:** `UserCurrencyData` + `Transactions`

```sql
-- ดูผ่าน View ที่สร้างไว้แล้ว
SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;

-- หรือ Query ตรงๆ:
SELECT
    u.AccountID                                         AS "รหัสบัญชี",
    COUNT(t.TransactionID)                             AS "จำนวนรายการทั้งหมด",
    NVL(SUM(CASE WHEN t.RevenueFlag = 1
                 THEN t.Amount END), 0)                AS "รายรับรวม",
    NVL(SUM(CASE WHEN t.RevenueFlag = 0
                 THEN t.Amount END), 0)                AS "รายจ่ายรวม",
    NVL(SUM(CASE WHEN t.RevenueFlag = 1  THEN  t.Amount
                 WHEN t.RevenueFlag = 0 THEN -t.Amount END), 0)
                                                        AS "เงินคงเหลือ",
    NVL(SUM(CASE WHEN t.RevenueFlag = 0
                  AND EXTRACT(YEAR FROM t.TransDate) = EXTRACT(YEAR FROM SYSDATE)
                 THEN t.Amount END), 0)                AS "รายจ่ายปีนี้"
FROM  UserCurrencyData u
LEFT JOIN Transactions  t ON t.AccountID = u.AccountID
GROUP BY u.AccountID
ORDER BY u.AccountID;
```

**ตัวอย่างผลลัพธ์:**

| รหัสบัญชี | จำนวนรายการ | รายรับรวม | รายจ่ายรวม | เงินคงเหลือ | รายจ่ายปีนี้ |
|---------|-----------|--------|--------|---------|----------|
| ACC01 | 4 | 25,000.00 | 4,629.00 | 20,371.00 | 4,629.00 |
| ACC02 | 3 | 8,000.00 | 930.00 | 7,070.00 | 930.00 |
| ACC03 | 4 | 32,000.00 | 3,020.00 | 28,980.00 | 3,020.00 |
| ACC05 | 3 | 33,000.00 | 960.00 | 32,040.00 | 960.00 |

> **ตาราง JOIN:** 2 ตาราง | ใช้ `LEFT JOIN` เพราะบัญชีที่ยังไม่มีรายการก็ต้องแสดงด้วย  
> **เทคนิคพิเศษ:** `CASE WHEN ... END` ใน `SUM()` เพื่อแยกรายรับ/รายจ่ายในคำสั่งเดียว

---

## 📌 สรุปตาราง JOIN ทั้งหมดของ SE

| Report | ตารางที่ JOIN | จำนวนตาราง | JOIN Type | จุดประสงค์ |
|--------|-------------|-----------|----------|-----------|
| Report 1 | Transactions, TagList, Tag | 3 | LEFT × 2 + LISTAGG | Statement บัญชี |
| Report 2 | UserCurrencyData, CurrencyPlan, Transactions | 3 | INNER + LEFT | ควบคุมงบประมาณ |
| Report 3 | Transactions, TagList, Tag | 3 | INNER × 2 + Window Fn | วิเคราะห์พฤติกรรมใช้จ่าย |
| Report 4 | UserCurrencyData, Transactions | 2 | LEFT × 1 + CASE/SUM | Dashboard ยอดเงิน |

---

## 🔖 เทคนิค SQL ที่ใช้ในรายงาน SE

| เทคนิค | ใช้ใน | อธิบาย |
|-------|------|-------|
| `LEFT JOIN` | ทุก Report | บัญชีที่ไม่มีรายการก็ยังแสดง (ไม่หาย) |
| `LISTAGG()` | Report 1 | รวม Tag หลายตัวเป็น 1 แถว คั่นด้วย `,` |
| `CASE WHEN ... END` | Report 2, 4 | แยก RevenueFlag ใน SELECT เดียว |
| `TRUNC(date, 'MM')` | Report 2 | เปรียบเทียบเดือน ignoring วัน |
| `SUM() OVER(PARTITION BY ...)` | Report 3 | Window Function หาสัดส่วน % |
| `EXTRACT(YEAR/MONTH FROM ...)` | Report 3, 4 | ดึงปี/เดือนจากวันที่ |
| `NVL(expr, 0)` | Report 2, 4 | ป้องกัน NULL กลายเป็น 0 |

---

*S1G2 | SE Reports | November 2026*
