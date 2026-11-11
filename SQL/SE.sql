-- รายงานประวัติรายการทรานแซ็กชันพร้อมแท็กทั้งหมด

SELECT
    t.AccountID                                         AS Account_ID,
    t.TransactionID                                     AS Trans_ID,
    t.TransName                                         AS Trans_Name,
    t.TransDate                                         AS Trans_Date,
    t.TransTime                                         AS Trans_Time,
    (CASE WHEN t.RevenueFlag = 1 THEN 'Income' ELSE 'Expense' END) AS Trans_Type,
    t.Amount                                            AS Amount,
    t.TransDescription                                  AS Description
FROM Transactions t
LEFT JOIN TagList tl ON t.TransactionID = tl.TransactionID
LEFT JOIN Tag tag ON tl.TagID = tag.TagID
GROUP BY t.AccountID, t.TransactionID, t.TransName,
         t.TransDate, t.TransTime, t.RevenueFlag,
         t.Amount, t.TransDescription
ORDER BY t.AccountID, t.TransDate, t.TransTime;


-- รายงานเปรียบเทียบยอดจริงกับแผนการเงิน

SELECT
    u.AccountID  AS Account_ID,
    p.PlanID     AS Plan_ID,
    p.PlanName   AS Plan_Name,
    p.PlanDate   AS Plan_Date,
    p.Amount     AS Amount,
    NVL(SUM(t.Amount), 0)             AS Actual_Spending,
    p.Amount - NVL(SUM(t.Amount), 0)  AS RemainingBudget,
    CASE
        WHEN NVL(SUM(t.Amount), 0) > p.Amount THEN 'เกินงบ'
        ELSE 'อยู่ในงบ'
    END          AS BudgetStatus,
    p.DateCreate AS CreatedDate,
    p.DateEdit   AS LastEdited
FROM UserCurrencyData u
JOIN CurrencyPlan p ON u.AccountID = p.AccountID
LEFT JOIN Transactions t
       ON t.AccountID = u.AccountID
      AND t.RevenueFlag = 0
      AND TO_CHAR(t.TransDate, 'YYYY-MM') = TO_CHAR(p.PlanDate, 'YYYY-MM')
GROUP BY u.AccountID, p.PlanID, p.PlanName, p.PlanDate,
         p.Amount, p.DateCreate, p.DateEdit
ORDER BY u.AccountID, p.PlanDate;