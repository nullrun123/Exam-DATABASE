-------------------------------------------------------------
-- ระบบบริหารจัดการการเงินรายเดือน - Full DML Script (Oracle Compatible)
-- Version: Matched with DDL (MonthlyFinance_DDL_fixed.sql)
-- ลำดับการ INSERT: ตาราง Parent ก่อน Child เพื่อไม่ให้ผิด FK
-------------------------------------------------------------
 
-------------------------------------------------------------
-- 1. USERCURRENCYDATA
-------------------------------------------------------------
INSERT INTO UserCurrencyData VALUES ('ACC01');
INSERT INTO UserCurrencyData VALUES ('ACC02');
INSERT INTO UserCurrencyData VALUES ('ACC03');
INSERT INTO UserCurrencyData VALUES ('ACC04');
INSERT INTO UserCurrencyData VALUES ('ACC05');
 
-------------------------------------------------------------
-- 2. CURRENCYPLAN
-- (PlanID, AccountID, PlanName, PlanDescription, PlanDate, Amount, DateCreate, DateEdit)
-- DateEdit เป็น NULL ได้ = ยังไม่เคยแก้ไขแผน
-------------------------------------------------------------
INSERT INTO CurrencyPlan VALUES ('PL01','ACC01','ออมเงินซื้อโน้ตบุ๊ก','เก็บเงินเดือนละ 3,000 บาท เพื่อซื้อโน้ตบุ๊กเครื่องใหม่',TO_DATE('31/12/2026','DD/MM/YYYY'),36000,TO_DATE('05/01/2026','DD/MM/YYYY'),TO_DATE('10/06/2026','DD/MM/YYYY'));
INSERT INTO CurrencyPlan VALUES ('PL02','ACC01','ค่าเทอมภาคเรียนที่ 2','เตรียมเงินสำหรับชำระค่าเทอม',TO_DATE('15/11/2026','DD/MM/YYYY'),18000,TO_DATE('01/08/2026','DD/MM/YYYY'),NULL);
INSERT INTO CurrencyPlan VALUES ('PL03','ACC02','กองทุนฉุกเฉิน','เก็บเงินสำรองไว้ใช้ยามฉุกเฉิน 3 เดือน',TO_DATE('30/06/2027','DD/MM/YYYY'),60000,TO_DATE('15/02/2026','DD/MM/YYYY'),TO_DATE('20/09/2026','DD/MM/YYYY'));
INSERT INTO CurrencyPlan VALUES ('PL04','ACC02','ท่องเที่ยวเชียงใหม่','ทริปพักผ่อนปลายปี',TO_DATE('25/12/2026','DD/MM/YYYY'),12000,TO_DATE('01/09/2026','DD/MM/YYYY'),NULL);
INSERT INTO CurrencyPlan VALUES ('PL05','ACC03','ผ่อนรถจักรยานยนต์','ค่างวดรถประจำเดือน',TO_DATE('05/12/2026','DD/MM/YYYY'),3200,TO_DATE('10/03/2026','DD/MM/YYYY'),TO_DATE('01/07/2026','DD/MM/YYYY'));
INSERT INTO CurrencyPlan VALUES ('PL06','ACC03','ซื้อประกันสุขภาพ','เบี้ยประกันรายปี',TO_DATE('31/01/2027','DD/MM/YYYY'),15000,TO_DATE('12/10/2026','DD/MM/YYYY'),NULL);
INSERT INTO CurrencyPlan VALUES ('PL07','ACC04','ซื้อหูฟังไร้สาย','เก็บค่าขนมซื้อหูฟังตัวใหม่',TO_DATE('31/12/2026','DD/MM/YYYY'),2500,TO_DATE('01/10/2026','DD/MM/YYYY'),NULL);
INSERT INTO CurrencyPlan VALUES ('PL08','ACC05','ดาวน์บ้าน','เก็บเงินดาวน์บ้านหลังแรก',TO_DATE('31/12/2028','DD/MM/YYYY'),300000,TO_DATE('02/01/2026','DD/MM/YYYY'),TO_DATE('25/10/2026','DD/MM/YYYY'));
INSERT INTO CurrencyPlan VALUES ('PL09','ACC05','ลงทุนกองทุนรวม','ลงทุนกองทุนรวมแบบ DCA ทุกเดือน',TO_DATE('30/11/2026','DD/MM/YYYY'),5000,TO_DATE('20/05/2026','DD/MM/YYYY'),TO_DATE('20/05/2026','DD/MM/YYYY'));
 
-------------------------------------------------------------
-- 3. TAG
-------------------------------------------------------------
INSERT INTO Tag VALUES ('TG01','อาหาร');
INSERT INTO Tag VALUES ('TG02','เดินทาง');
INSERT INTO Tag VALUES ('TG03','ที่พัก');
INSERT INTO Tag VALUES ('TG04','ค่าน้ำค่าไฟ');
INSERT INTO Tag VALUES ('TG05','บันเทิง');
INSERT INTO Tag VALUES ('TG06','ช้อปปิ้ง');
INSERT INTO Tag VALUES ('TG07','รายได้');
INSERT INTO Tag VALUES ('TG08','การศึกษา');
INSERT INTO Tag VALUES ('TG09','สุขภาพ');
 
-------------------------------------------------------------
-- 4. TRANSACTIONS
-- (TransactionID, AccountID, TransName, TransDate, TransTime, Amount, RevenueFlag, TransDescription)
-- RevenueFlag: T = รายรับ, F = รายจ่าย
-------------------------------------------------------------
INSERT INTO Transactions VALUES ('TR001','ACC01','เงินเดือนกันยายน',TO_DATE('25/09/2026','DD/MM/YYYY'),'09:00:00',25000,'T','เงินเดือนประจำเดือนกันยายน');
INSERT INTO Transactions VALUES ('TR002','ACC01','ค่าข้าวกลางวัน',TO_DATE('26/09/2026','DD/MM/YYYY'),'12:15:00',85,'F','ข้าวมันไก่ร้านหน้าบริษัท');
INSERT INTO Transactions VALUES ('TR003','ACC01','ค่ารถไฟฟ้า BTS',TO_DATE('26/09/2026','DD/MM/YYYY'),'08:10:00',44,'F','เดินทางไปทำงาน');
INSERT INTO Transactions VALUES ('TR004','ACC01','ค่าห้องพัก',TO_DATE('01/10/2026','DD/MM/YYYY'),'18:30:00',4500,'F','ค่าเช่าห้องประจำเดือนตุลาคม');
INSERT INTO Transactions VALUES ('TR005','ACC02','ค่าจ้างฟรีแลนซ์',TO_DATE('05/10/2026','DD/MM/YYYY'),'14:00:00',8000,'T','งานออกแบบโลโก้');
INSERT INTO Transactions VALUES ('TR006','ACC02','ซื้อหนังสือเรียน',TO_DATE('06/10/2026','DD/MM/YYYY'),'16:45:00',650,'F','หนังสือเตรียมสอบ');
INSERT INTO Transactions VALUES ('TR007','ACC02','ดูหนัง',TO_DATE('10/10/2026','DD/MM/YYYY'),'19:20:00',280,'F','ตั๋วหนังพร้อมป๊อปคอร์น');
INSERT INTO Transactions VALUES ('TR008','ACC03','เงินเดือนตุลาคม',TO_DATE('25/10/2026','DD/MM/YYYY'),'09:00:00',32000,'T','เงินเดือนประจำเดือนตุลาคม');
INSERT INTO Transactions VALUES ('TR009','ACC03','ค่าไฟฟ้า',TO_DATE('28/10/2026','DD/MM/YYYY'),'10:30:00',1250,'F','ค่าไฟประจำเดือน');
INSERT INTO Transactions VALUES ('TR010','ACC03','ค่าน้ำประปา',TO_DATE('28/10/2026','DD/MM/YYYY'),'10:35:00',180,'F','ค่าน้ำประจำเดือน');
INSERT INTO Transactions VALUES ('TR011','ACC03','ช้อปปิ้งออนไลน์',TO_DATE('30/10/2026','DD/MM/YYYY'),'21:05:00',1590,'F','สั่งเสื้อผ้าและของใช้ในบ้าน');
INSERT INTO Transactions VALUES ('TR012','ACC04','ค่าขนมจากผู้ปกครอง',TO_DATE('01/10/2026','DD/MM/YYYY'),'07:30:00',6000,'T','ค่าใช้จ่ายรายเดือน');
INSERT INTO Transactions VALUES ('TR013','ACC04','ค่าอาหารเย็น',TO_DATE('03/10/2026','DD/MM/YYYY'),'18:45:00',120,'F','ข้าวผัดกับน้ำปั่น');
INSERT INTO Transactions VALUES ('TR014','ACC04','ค่ารถเมล์',TO_DATE('03/10/2026','DD/MM/YYYY'),'07:50:00',25,'F','นั่งรถเมล์ไปมหาวิทยาลัย');
INSERT INTO Transactions VALUES ('TR015','ACC05','เงินเดือนตุลาคม',TO_DATE('25/10/2026','DD/MM/YYYY'),'09:00:00',28000,'T','เงินเดือนประจำเดือนตุลาคม');
INSERT INTO Transactions VALUES ('TR016','ACC05','ค่ายาและพบแพทย์',TO_DATE('02/11/2026','DD/MM/YYYY'),'11:00:00',750,'F','ตรวจสุขภาพประจำปี');
INSERT INTO Transactions VALUES ('TR017','ACC05','ค่าแท็กซี่',TO_DATE('05/11/2026','DD/MM/YYYY'),'22:10:00',210,'F','เดินทางกลับบ้านหลังเลิกงานดึก');
INSERT INTO Transactions VALUES ('TR018','ACC05','โบนัสพิเศษ',TO_DATE('07/11/2026','DD/MM/YYYY'),'15:00:00',5000,'T','โบนัสจากโครงการพิเศษ');


-------------------------------------------------------------
-- 5. TAGLIST
-- (TransactionID, LineNo, TagID) : LineNo นับใหม่ในแต่ละ Transaction
-------------------------------------------------------------
INSERT INTO TagList VALUES ('TR001',1,'TG07');
INSERT INTO TagList VALUES ('TR002',1,'TG01');
INSERT INTO TagList VALUES ('TR003',1,'TG02');
INSERT INTO TagList VALUES ('TR004',1,'TG03');
INSERT INTO TagList VALUES ('TR005',1,'TG07');
INSERT INTO TagList VALUES ('TR006',1,'TG08');
INSERT INTO TagList VALUES ('TR006',2,'TG06');
INSERT INTO TagList VALUES ('TR007',1,'TG05');
INSERT INTO TagList VALUES ('TR008',1,'TG07');
INSERT INTO TagList VALUES ('TR009',1,'TG04');
INSERT INTO TagList VALUES ('TR009',2,'TG03');
INSERT INTO TagList VALUES ('TR010',1,'TG04');
INSERT INTO TagList VALUES ('TR011',1,'TG06');
INSERT INTO TagList VALUES ('TR012',1,'TG07');
INSERT INTO TagList VALUES ('TR012',2,'TG08');
INSERT INTO TagList VALUES ('TR013',1,'TG01');
INSERT INTO TagList VALUES ('TR014',1,'TG02');
INSERT INTO TagList VALUES ('TR015',1,'TG07');
INSERT INTO TagList VALUES ('TR016',1,'TG09');
INSERT INTO TagList VALUES ('TR017',1,'TG02');
INSERT INTO TagList VALUES ('TR018',1,'TG07');
 
COMMIT;
 
-------------------------------------------------------------
-- ตรวจสอบผล: Useable Money / Outcome Yearly (Derived Attribute จาก View)
-------------------------------------------------------------
-- SELECT * FROM V_UserCurrencySummary ORDER BY AccountID;