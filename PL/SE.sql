-- =====================================================================
-- finance_procedures.sql | S1G2 แอปพลิเคชันบริหารการเงินส่วนบุคคล
-- Stored Procedures (PL/SQL) ตามรูปแบบเดียวกับชุด Carry Market
-- ใช้ตาราง: UserCurrencyData, CurrencyPlan, Transactions, Tag, TagList
-- หมายเหตุ: RevenueFlag เป็น BOOLEAN (ต้อง Oracle 23ai ขึ้นไป)
--           procedure ไม่ COMMIT เอง ผู้เรียกเป็นคนสั่ง COMMIT
-- =====================================================================
SET SERVEROUTPUT ON
 
-------------------------------------------------------------
-- 1. Account: สร้างบัญชีผู้ใช้
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_create_account (
    p_accountid IN VARCHAR2
) AS
BEGIN
    INSERT INTO UserCurrencyData (AccountID)
    VALUES (p_accountid);
    DBMS_OUTPUT.PUT_LINE('สร้างบัญชีผู้ใช้เรียบร้อย: ' || p_accountid);
END;
/
 
-------------------------------------------------------------
-- 2. CurrencyPlan: สร้าง / แก้ไขแผนการเงิน (งบประมาณ)
-------------------------------------------------------------


CREATE OR REPLACE PROCEDURE sp_create_plan (
    p_planid     IN VARCHAR2,
    p_accountid  IN VARCHAR2,
    p_planname   IN VARCHAR2,
    p_plandesc   IN VARCHAR2,
    p_plandate   IN DATE,
    p_amount     IN NUMBER
) AS
BEGIN
    INSERT INTO CurrencyPlan (PlanID, AccountID, PlanName, PlanDescription,
                              PlanDate, Amount, DateCreate, DateEdit)
    VALUES (p_planid, p_accountid, p_planname, p_plandesc,
            p_plandate, p_amount, SYSDATE, NULL);
    DBMS_OUTPUT.PUT_LINE('สร้างแผนการเงินเรียบร้อย: ' || p_planid);
END;
/
 



CREATE OR REPLACE PROCEDURE sp_update_plan (
    p_planid     IN VARCHAR2,
    p_planname   IN VARCHAR2,
    p_plandesc   IN VARCHAR2,
    p_plandate   IN DATE,
    p_amount     IN NUMBER
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
 
-------------------------------------------------------------
-- 3. Transaction: เพิ่ม / แก้ไข / ลบ รายการรายรับ-รายจ่าย
--    p_isrevenue: TRUE = รายรับ, FALSE = รายจ่าย
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_add_transaction (
    p_transid    IN VARCHAR2,
    p_accountid  IN VARCHAR2,
    p_transname  IN VARCHAR2,
    p_transdate  IN DATE,
    p_transtime  IN VARCHAR2,          -- รูปแบบ HH24:MI:SS
    p_amount     IN NUMBER,
    p_isrevenue  IN BOOLEAN,
    p_desc       IN VARCHAR2
) AS
BEGIN
    INSERT INTO Transactions (TransactionID, AccountID, TransName, TransDate,
                              TransTime, Amount, RevenueFlag, TransDescription)
    VALUES (p_transid, p_accountid, p_transname, p_transdate,
            p_transtime, p_amount, p_isrevenue, p_desc);
 
    IF p_isrevenue THEN
        DBMS_OUTPUT.PUT_LINE('บันทึกรายรับเรียบร้อย: ' || p_transid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('บันทึกรายจ่ายเรียบร้อย: ' || p_transid);
    END IF;
END;
/
 
CREATE OR REPLACE PROCEDURE sp_update_transaction (
    p_transid    IN VARCHAR2,
    p_transname  IN VARCHAR2,
    p_transdate  IN DATE,
    p_transtime  IN VARCHAR2,
    p_amount     IN NUMBER,
    p_isrevenue  IN BOOLEAN,
    p_desc       IN VARCHAR2
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
 
CREATE OR REPLACE PROCEDURE sp_delete_transaction (
    p_transid IN VARCHAR2
) AS
BEGIN
    -- ลบแท็กที่ผูกกับรายการก่อน (TagList อ้างอิง Transactions)
    DELETE FROM TagList WHERE TransactionID = p_transid;
 
    DELETE FROM Transactions WHERE TransactionID = p_transid;
 
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบรายการ: ' || p_transid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('ลบรายการเรียบร้อย: ' || p_transid);
    END IF;
END;
/
 
-------------------------------------------------------------
-- 4. Tag (ใช้เป็นหมวดหมู่): สร้าง / แก้ไข / ลบ / ติดแท็กให้รายการ
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_add_tag (
    p_tagid    IN VARCHAR2,
    p_tagname  IN VARCHAR2
) AS
BEGIN
    INSERT INTO Tag (TagID, TagName)
    VALUES (p_tagid, p_tagname);
    DBMS_OUTPUT.PUT_LINE('สร้างแท็กเรียบร้อย: ' || p_tagid);
END;
/


 
CREATE OR REPLACE PROCEDURE sp_update_tag (
    p_tagid    IN VARCHAR2,
    p_tagname  IN VARCHAR2
) AS
BEGIN
    UPDATE Tag
       SET TagName = p_tagname
     WHERE TagID = p_tagid;
 
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแท็ก: ' || p_tagid);
    ELSE
        DBMS_OUTPUT.PUT_LINE('แก้ไขแท็กเรียบร้อย: ' || p_tagid);
    END IF;
END;
/
 
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
 
CREATE OR REPLACE PROCEDURE sp_tag_transaction (
    p_transid  IN VARCHAR2,
    p_tagid    IN VARCHAR2
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
 
-------------------------------------------------------------
-- 5. Summary: สรุปรายเดือน / รายปี / เปรียบเทียบสองเดือน
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_monthly_summary (
    p_accountid IN VARCHAR2,
    p_year      IN NUMBER,
    p_month     IN NUMBER
) AS
    v_income  NUMBER(14,2);
    v_expense NUMBER(14,2);
BEGIN
    SELECT NVL(SUM(CASE WHEN RevenueFlag = TRUE  THEN Amount END), 0),
           NVL(SUM(CASE WHEN RevenueFlag = FALSE THEN Amount END), 0)
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
 

CREATE OR REPLACE PROCEDURE sp_yearly_summary (
    p_accountid IN VARCHAR2,
    p_year      IN NUMBER
) AS
    v_total_income  NUMBER(14,2) := 0;
    v_total_expense NUMBER(14,2) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('สรุปรายปี ' || p_year || ' ของบัญชี ' || p_accountid);
 
    FOR r IN (SELECT EXTRACT(MONTH FROM TransDate) AS m,
                     NVL(SUM(CASE WHEN RevenueFlag = TRUE  THEN Amount END), 0) AS income,
                     NVL(SUM(CASE WHEN RevenueFlag = FALSE THEN Amount END), 0) AS expense
                FROM Transactions
               WHERE AccountID = p_accountid
                 AND EXTRACT(YEAR FROM TransDate) = p_year
               GROUP BY EXTRACT(MONTH FROM TransDate)
               ORDER BY EXTRACT(MONTH FROM TransDate))
    LOOP
        DBMS_OUTPUT.PUT_LINE('  เดือน ' || LPAD(r.m, 2, '0')
            || ' | รายรับ ' || TO_CHAR(r.income,  'FM999,999,990.00')
            || ' | รายจ่าย ' || TO_CHAR(r.expense, 'FM999,999,990.00'));
        v_total_income  := v_total_income  + r.income;
        v_total_expense := v_total_expense + r.expense;
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE('  รวมทั้งปี | รายรับ ' || TO_CHAR(v_total_income,  'FM999,999,990.00')
        || ' | รายจ่าย ' || TO_CHAR(v_total_expense, 'FM999,999,990.00')
        || ' | คงเหลือ ' || TO_CHAR(v_total_income - v_total_expense, 'FM999,999,990.00'));
END;
/
 
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
     WHERE AccountID = p_accountid AND RevenueFlag = FALSE
       AND EXTRACT(YEAR  FROM TransDate) = p_year1
       AND EXTRACT(MONTH FROM TransDate) = p_month1;
 
    SELECT NVL(SUM(Amount), 0) INTO v_exp2
      FROM Transactions
     WHERE AccountID = p_accountid AND RevenueFlag = FALSE
       AND EXTRACT(YEAR  FROM TransDate) = p_year2
       AND EXTRACT(MONTH FROM TransDate) = p_month2;
 
    v_diff := v_exp2 - v_exp1;
 
    DBMS_OUTPUT.PUT_LINE('เปรียบเทียบรายจ่าย ' || p_month1 || '/' || p_year1
        || ' กับ ' || p_month2 || '/' || p_year2);
    DBMS_OUTPUT.PUT_LINE('  ' || p_month1 || '/' || p_year1 || ' : ' || TO_CHAR(v_exp1, 'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('  ' || p_month2 || '/' || p_year2 || ' : ' || TO_CHAR(v_exp2, 'FM999,999,990.00'));
 
    IF v_exp1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ผลต่าง : ' || TO_CHAR(v_diff, 'FM999,999,990.00') || ' (เดือนแรกไม่มีรายจ่าย คำนวณเปอร์เซ็นต์ไม่ได้)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ผลต่าง : ' || TO_CHAR(v_diff, 'FM999,999,990.00')
            || ' (' || ROUND(v_diff / v_exp1 * 100, 2) || '%)');
    END IF;
END;
/
 
-------------------------------------------------------------
-- 6. Budget: เทียบรายจ่ายกับแผนการเงิน
--    ASSUMPTION: Amount ของแผน = งบของเดือนที่ตรงกับ PlanDate
-------------------------------------------------------------
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
       AND RevenueFlag = FALSE
       AND TRUNC(TransDate, 'MM') = TRUNC(v_date, 'MM');
 
    DBMS_OUTPUT.PUT_LINE('แผน ' || p_planid || ' | งบ ' || TO_CHAR(v_budget, 'FM999,999,990.00')
        || ' | ใช้ไป ' || TO_CHAR(v_spent, 'FM999,999,990.00'));
 
    IF v_spent > v_budget THEN
        DBMS_OUTPUT.PUT_LINE('  เกินงบ ' || TO_CHAR(v_spent - v_budget, 'FM999,999,990.00'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('  คงเหลือ ' || TO_CHAR(v_budget - v_spent, 'FM999,999,990.00'));
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ไม่พบแผนการเงิน: ' || p_planid);
END;
/





COMMIT;


-- =====================================================================
-- ชุดทดสอบ (รันหลังสร้างตารางและ procedure ครบ)
-- =====================================================================

BEGIN
    sp_create_account('A001');
    sp_create_plan('P001', 'A001', N'งบอาหาร', N'งบอาหารประจำเดือน', DATE '2026-11-01', 5000);
    sp_add_tag('T001', N'อาหาร');
 
    sp_add_transaction('TR001', 'A001', N'เงินเดือน',   DATE '2026-11-01', '09:00:00', 30000, TRUE,  'เงินเดือน พ.ย.');
    sp_add_transaction('TR002', 'A001', N'ข้าวกลางวัน', DATE '2026-11-02', '12:30:00',   120, FALSE, 'ร้านข้าวแกง');
    sp_add_transaction('TR003', 'A001', N'ค่ากาแฟ',     DATE '2026-11-05', '08:15:00',   450, FALSE, 'ร้านกาแฟ');
    sp_add_transaction('TR004', 'A001', N'ค่าเดินทาง',  DATE '2026-10-10', '18:00:00',   300, FALSE, 'รถไฟฟ้า');
 
    sp_tag_transaction('TR002', 'T001');
    sp_tag_transaction('TR003', 'T001');
 
    sp_monthly_summary('A001', 2026, 11);
    sp_yearly_summary('A001', 2026);
    sp_compare_months('A001', 2026, 10, 2026, 11);
    sp_check_plan('P001');
 
    sp_update_transaction('TR002', N'ข้าวกลางวัน', DATE '2026-11-02', '12:30:00', 150, FALSE, 'ร้านข้าวแกง');
    sp_delete_transaction('TR003');
    sp_monthly_summary('A001', 2026, 11);
 
    COMMIT;
END;
/





-------------------------------------------------------------
-- 3.1 ดึงรายการรายรับ / รายจ่าย ด้วย RevenueFlag
--     TRUE  = รายรับ (Income)
--     FALSE = รายจ่าย (Expense)
-- ดึงรายรับทั้งหมดของ A001
-- BEGIN
--     sp_get_transactions_by_flag('A001', TRUE);
-- END;
-- /

-- ========== รายการรายรับ ==========
-- รหัสรายการ : TR001
-- ชื่อรายการ : เงินเดือน
-- วันที่      : 01/11/2026
-- จำนวนเงิน  : 30,000.00
-- รายละเอียด : เงินเดือน พ.ย.
-- ------------------------------
-- จำนวนรายการทั้งหมด: 1
-------------------------------------------------------------

-- CREATE OR REPLACE PROCEDURE sp_get_transactions_by_flag (
--     p_accountid     IN VARCHAR2,
--     p_revenue_flag  IN BOOLEAN
-- ) AS
--     v_count NUMBER := 0;
-- BEGIN
--     -- ตรวจสอบว่ามีการส่งค่า TRUE/FALSE หรือไม่
--     IF p_revenue_flag IS NULL THEN
--         RAISE_APPLICATION_ERROR(
--             -20001,
--             'กรุณาระบุประเภท TRUE หรือ FALSE'
--         );
--     END IF;

--     -- แสดงหัวข้อ
--     IF p_revenue_flag THEN
--         DBMS_OUTPUT.PUT_LINE('========== รายการรายรับ ==========');
--     ELSE
--         DBMS_OUTPUT.PUT_LINE('========== รายการรายจ่าย ==========');
--     END IF;

--     -- ดึงรายการตาม RevenueFlag
--     FOR r IN (
--         SELECT TransactionID,
--                TransName,
--                TransDate,
--                TransTime,
--                Amount,
--                TransDescription
--         FROM Transactions
--         WHERE AccountID = p_accountid
--           AND RevenueFlag = p_revenue_flag
--         ORDER BY TransDate, TransTime
--     )
--     LOOP
--         v_count := v_count + 1;

--         DBMS_OUTPUT.PUT_LINE(
--             'รหัสรายการ : ' || r.TransactionID
--         );

--         DBMS_OUTPUT.PUT_LINE(
--             'ชื่อรายการ : ' || r.TransName
--         );

--         DBMS_OUTPUT.PUT_LINE(
--             'วันที่      : ' || TO_CHAR(r.TransDate, 'DD/MM/YYYY')
--         );

--         DBMS_OUTPUT.PUT_LINE(
--             'จำนวนเงิน  : ' || TO_CHAR(r.Amount, 'FM999,999,990.00')
--         );

--         DBMS_OUTPUT.PUT_LINE(
--             'รายละเอียด : ' || r.TransDescription
--         );

--         DBMS_OUTPUT.PUT_LINE('------------------------------');
--     END LOOP;

--     -- กรณีไม่พบข้อมูล
--     IF v_count = 0 THEN
--         DBMS_OUTPUT.PUT_LINE('ไม่พบรายการ');
--     END IF;

--     DBMS_OUTPUT.PUT_LINE('จำนวนรายการทั้งหมด: ' || v_count);

-- END;
-- /
 