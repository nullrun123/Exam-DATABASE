-------------------------------------------------------------
-- Stock Management + Stock Adjustment (WMS) - Full DML Script
-- (Oracle Compatible)
-- Version: Matched with DDL (Category, WMS, WareHouse,
--          Department, Employee, Item)
-- ลำดับการ INSERT เรียงตาม FK: แม่ -> ลูก
-------------------------------------------------------------

-------------------------------------------------------------
-- 1. CATEGORY
-------------------------------------------------------------
INSERT INTO Category VALUES ('CT01','อาหารสด');
INSERT INTO Category VALUES ('CT02','อาหารแห้ง');
INSERT INTO Category VALUES ('CT03','เครื่องดื่ม');
INSERT INTO Category VALUES ('CT04','ขนมหวาน');
INSERT INTO Category VALUES ('CT05','อาหารแช่แข็ง');

-------------------------------------------------------------
-- 2. WMS (ระบบ WMS)
--    Counts = จำนวนสินค้าคงคลังรวมของระบบ (ตรงกับผลรวม Item.Counts ของ WMS นั้น)
-------------------------------------------------------------
INSERT INTO WMS VALUES ('WMSID1',930,TO_DATE('10/01/2023','DD/MM/YYYY'));
INSERT INTO WMS VALUES ('WMSID2',610,TO_DATE('15/06/2023','DD/MM/YYYY'));
INSERT INTO WMS VALUES ('WMSID3',255,TO_DATE('01/02/2024','DD/MM/YYYY'));

-------------------------------------------------------------
-- 3. WAREHOUSE (1 คลัง : 1 ระบบ WMS)
-------------------------------------------------------------
INSERT INTO WareHouse VALUES ('WH01','คลังลาดกระบัง 99 ซ.ฉลองกรุง 1 แขวงลาดกระบัง เขตลาดกระบัง กรุงเทพฯ 10520','WMSID1',TO_DATE('28/10/2025','DD/MM/YYYY'),'Approved');
INSERT INTO WareHouse VALUES ('WH02','คลังบางพลี 88/8 ม.6 ถ.บางนา-ตราด ต.บางโฉลง อ.บางพลี จ.สมุทรปราการ 10540','WMSID2',TO_DATE('29/10/2025','DD/MM/YYYY'),'Approved');
INSERT INTO WareHouse VALUES ('WH03','คลังคลองหลวง 45/2 ม.1 ถ.พหลโยธิน ต.คลองหนึ่ง อ.คลองหลวง จ.ปทุมธานี 12120','WMSID3',TO_DATE('30/10/2025','DD/MM/YYYY'),'Pending');

-------------------------------------------------------------
-- 4. DEPARTMENT (MgrEmployeeID อ้างถึงพนักงานในข้อ 5)
-------------------------------------------------------------
INSERT INTO Department VALUES ('D01','คลังสินค้า','E001',TO_DATE('01/01/2020','DD/MM/YYYY'));
INSERT INTO Department VALUES ('D02','ควบคุมสต๊อก','E002',TO_DATE('01/01/2021','DD/MM/YYYY'));
INSERT INTO Department VALUES ('D03','จัดซื้อ','E003',TO_DATE('01/06/2021','DD/MM/YYYY'));
INSERT INTO Department VALUES ('D04','ไอทีและระบบ WMS','E004',TO_DATE('01/01/2019','DD/MM/YYYY'));

-------------------------------------------------------------
-- 5. EMPLOYEE
--    ลำดับคอลัมน์: EmployeeId, FirstName, LastName, WorkStatus (W=ทำงาน, Q=ลาออก),
--    Salary, StartDate, ResignDate, DepartmentId, WMSAddress, SupervisorId,
--    Check_EmpStatus (Arrival / Not_Arrival)
--    * INSERT หัวหน้า (E001-E004) ก่อน เพื่อให้ SupervisorId ของลูกน้องอ้างได้
-------------------------------------------------------------
INSERT INTO Employee VALUES ('E001','วิชัย','สุขสวัสดิ์','W',52000,TO_DATE('15/01/2019','DD/MM/YYYY'),NULL,'D01','WMSID1',NULL,'Arrival');
INSERT INTO Employee VALUES ('E002','อรุณี','ศรีสวัสดิ์','W',48000,TO_DATE('01/06/2019','DD/MM/YYYY'),NULL,'D02','WMSID1',NULL,'Arrival');
INSERT INTO Employee VALUES ('E003','ธีรพงศ์','มั่นคง','W',46000,TO_DATE('10/02/2020','DD/MM/YYYY'),NULL,'D03','WMSID2',NULL,'Arrival');
INSERT INTO Employee VALUES ('E004','ชนิดา','พรหมมา','W',55000,TO_DATE('05/08/2018','DD/MM/YYYY'),NULL,'D04','WMSID1',NULL,'Arrival');
INSERT INTO Employee VALUES ('E005','กิตติพัฒน์','แก้วมณี','W',22000,TO_DATE('01/03/2022','DD/MM/YYYY'),NULL,'D01','WMSID1','E001','Arrival');
INSERT INTO Employee VALUES ('E006','ปิยะนุช','บุญเรือง','W',21000,TO_DATE('15/07/2022','DD/MM/YYYY'),NULL,'D01','WMSID2','E001','Arrival');
INSERT INTO Employee VALUES ('E007','สุรเชษฐ์','เพชรรัตน์','W',24000,TO_DATE('02/01/2023','DD/MM/YYYY'),NULL,'D02','WMSID3','E002','Not_Arrival');
INSERT INTO Employee VALUES ('E008','วรัญญา','ทองดี','W',23000,TO_DATE('20/05/2023','DD/MM/YYYY'),NULL,'D02','WMSID1','E002','Arrival');
INSERT INTO Employee VALUES ('E009','ณัฐพล','จันทร์เพ็ญ','W',25000,TO_DATE('11/09/2021','DD/MM/YYYY'),NULL,'D03','WMSID3','E003','Arrival');
INSERT INTO Employee VALUES ('E010','มนัสนันท์','คำสิงห์','Q',19500,TO_DATE('01/11/2023','DD/MM/YYYY'),TO_DATE('30/06/2025','DD/MM/YYYY'),'D01','WMSID3','E001','Not_Arrival');
INSERT INTO Employee VALUES ('E011','ภูริพัฒน์','สายสุริยา','W',30000,TO_DATE('03/04/2022','DD/MM/YYYY'),NULL,'D04','WMSID2','E004','Arrival');

-------------------------------------------------------------
-- 6. ITEM
--    ลำดับคอลัมน์: ItemID, Price, ArrivalDate, CostPrice, SalePrice, Counts,
--    WareHouseID, CatagoryID, WMS_Address
--    * ตาราง Item ไม่มีคอลัมน์ชื่อสินค้า จึงใส่ชื่อไว้เป็น comment ท้ายบรรทัด
--    * WMS_Address ของสินค้า = WMS ของคลังที่สินค้านั้นอยู่
-------------------------------------------------------------

-- คลัง WH01 (ลาดกระบัง)
INSERT INTO Item VALUES ('IT001',35,TO_DATE('01/10/2025','DD/MM/YYYY'),20,35,120,'WH01','CT01','WMSID1'); -- ยากิโซบะ
INSERT INTO Item VALUES ('IT002',10,TO_DATE('01/10/2025','DD/MM/YYYY'),5,10,350,'WH01','CT01','WMSID1'); -- ทาโกยากิ
INSERT INTO Item VALUES ('IT003',99,TO_DATE('05/10/2025','DD/MM/YYYY'),70,95,80,'WH01','CT06','WMSID1'); -- ซาชิมิปลาแซลมอน
INSERT INTO Item VALUES ('IT004',60,TO_DATE('05/10/2025','DD/MM/YYYY'),40,60,240,'WH01','CT06','WMSID1'); -- ปลาซาบะย่างเกลือ
INSERT INTO Item VALUES ('IT005',80,TO_DATE('08/10/2025','DD/MM/YYYY'),50,75,140,'WH01','CT06','WMSID1'); -- เกี๊ยวซ่าหมูพรีเมียม

-- คลัง WH02 (บางพลี)
INSERT INTO Item VALUES ('IT006',35,TO_DATE('10/10/2025','DD/MM/YYYY'),18,35,60,'WH02','CT04','WMSID2'); -- น้ำปั่นสตรอว์เบอร์รี่
INSERT INTO Item VALUES ('IT007',45,TO_DATE('10/10/2025','DD/MM/YYYY'),25,45,45,'WH02','CT04','WMSID2'); -- สมูทตี้มะม่วงโยเกิร์ต
INSERT INTO Item VALUES ('IT008',40,TO_DATE('12/10/2025','DD/MM/YYYY'),22,40,70,'WH02','CT04','WMSID2'); -- คาปูชิโน่เย็น
INSERT INTO Item VALUES ('IT009',35,TO_DATE('12/10/2025','DD/MM/YYYY'),18,35,85,'WH02','CT04','WMSID2'); -- โอวันตินเย็น
INSERT INTO Item VALUES ('IT010',59,TO_DATE('15/10/2025','DD/MM/YYYY'),35,55,150,'WH02','CT05','WMSID2'); -- โมจิโอริโอ้ครีมชีส
INSERT INTO Item VALUES ('IT011',49,TO_DATE('15/10/2025','DD/MM/YYYY'),28,49,200,'WH02','CT05','WMSID2'); -- โมจิถั่วแดง

-- คลัง WH03 (คลองหลวง)
INSERT INTO Item VALUES ('IT012',100,TO_DATE('18/09/2025','DD/MM/YYYY'),60,100,25,'WH03','CT02','WMSID3'); -- เสื้อวินเทจ Oversize
INSERT INTO Item VALUES ('IT013',100,TO_DATE('18/09/2025','DD/MM/YYYY'),65,90,10,'WH03','CT02','WMSID3'); -- ผ้าคลุมโฮคาเงะ
INSERT INTO Item VALUES ('IT014',45,TO_DATE('20/10/2025','DD/MM/YYYY'),25,45,130,'WH03','CT03','WMSID3'); -- คาจูบาร์ฟี
INSERT INTO Item VALUES ('IT015',75,TO_DATE('20/10/2025','DD/MM/YYYY'),40,70,90,'WH03','CT03','WMSID3'); -- ปานีปูรี

COMMIT;