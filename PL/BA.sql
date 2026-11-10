CREATE OR REPLACE PROCEDURE sp_add_category (
    p_catid     IN VARCHAR2,
    p_catname   IN VARCHAR2
) AS
BEGIN
    INSERT INTO Category (CatagoryID, CatagoryName)
    VALUES (p_catid, p_catname);
    DBMS_OUTPUT.PUT_LINE('เพิ่มหมวดหมู่สินค้าเรียบร้อย: ' || p_catid);
END;
/
CREATE OR REPLACE PROCEDURE sp_register_wms (
    p_address    IN VARCHAR2,
    p_regdate    IN DATE
) AS
BEGIN
    INSERT INTO WMS (Address, RegisterDate)
    VALUES (p_address, NVL(p_regdate, SYSDATE));
    DBMS_OUTPUT.PUT_LINE('ลงทะเบียนระบบ WMS เรียบร้อย: ' || p_address);
END;
/
CREATE OR REPLACE PROCEDURE sp_create_warehouse (
    p_whid          IN VARCHAR2,
    p_address       IN VARCHAR2,
    p_wms_address   IN VARCHAR2,
    p_latest_check  IN DATE,
    p_approval      IN VARCHAR2
) AS
BEGIN
    INSERT INTO WareHouse (WareHouseID, Address, WMS_Address, Latest_Check, Check_Approval)
    VALUES (p_whid, p_address, p_wms_address, p_latest_check, TRIM(p_approval));
    DBMS_OUTPUT.PUT_LINE('เพิ่มคลังสินค้าใหม่เรียบร้อย: ' || p_whid);
END;
/
CREATE OR REPLACE PROCEDURE sp_create_department (
    p_depid       IN VARCHAR2,
    p_depname     IN VARCHAR2,
    p_mgr_empid   IN VARCHAR2,
    p_mgrdate     IN DATE
) AS
BEGIN
    INSERT INTO Department (DepartmentID, DepartmentName, MgrEmployeeID, MgrDate)
    VALUES (p_depid, p_depname, p_mgr_empid, p_mgrdate);
    DBMS_OUTPUT.PUT_LINE('เพิ่มแผนกใหม่เรียบร้อย: ' || p_depid);
END;
/
CREATE OR REPLACE PROCEDURE sp_add_employee (
    p_empid         IN VARCHAR2,
    p_firstname     IN VARCHAR2,
    p_lastname      IN VARCHAR2,
    p_workstatus    IN VARCHAR2,
    p_salary        IN NUMBER,
    p_startdate     IN DATE,
    p_resigndate    IN DATE,
    p_depid         IN VARCHAR2,
    p_wmsaddress    IN VARCHAR2,
    p_supervisorid  IN VARCHAR2,
    p_empstatus     IN VARCHAR2
) AS
BEGIN
    INSERT INTO Employee (EmployeeId, FirstName, LastName, WorkStatus, Salary, StartDate,
                          ResignDate, DepartmentId, WMSAddress, SupervisorId, Check_EmpStatus)
    VALUES (p_empid, p_firstname, p_lastname, TRIM(p_workstatus), p_salary, p_startdate,
            p_resigndate, p_depid, p_wmsaddress, p_supervisorid, TRIM(p_empstatus));
    DBMS_OUTPUT.PUT_LINE('เพิ่มพนักงานใหม่เรียบร้อย: ' || p_empid);
END;
/
CREATE OR REPLACE PROCEDURE sp_add_item (
    p_itemid       IN VARCHAR2,
    p_price        IN NUMBER,
    p_arrivaldate  IN DATE,
    p_costprice    IN NUMBER,
    p_saleprice    IN NUMBER,
    p_counts       IN NUMBER,
    p_whid         IN VARCHAR2,
    p_catid        IN VARCHAR2,
    p_wms_address  IN VARCHAR2
) AS
BEGIN
    INSERT INTO Item (ItemID, Price, ArrivalDate, CostPrice, SalePrice, Counts,
                      WareHouseID, CatagoryID, WMS_Address)
    VALUES (p_itemid, p_price, p_arrivaldate, p_costprice, p_saleprice, p_counts,
            p_whid, p_catid, p_wms_address);
    DBMS_OUTPUT.PUT_LINE('เพิ่มสินค้าใหม่เรียบร้อย: ' || p_itemid);
END;
/
CREATE OR REPLACE PROCEDURE sp_update_item_stock (
    p_itemid IN VARCHAR2,
    p_amount IN NUMBER
) AS
BEGIN
    UPDATE Item
    SET Counts = Counts - p_amount
    WHERE ItemID = p_itemid;
    DBMS_OUTPUT.PUT_LINE('ปรับจำนวนสินค้าเรียบร้อย: ' || p_itemid);
END;
/
CREATE OR REPLACE PROCEDURE sp_approve_warehouse (
    p_whid      IN VARCHAR2,
    p_approval  IN VARCHAR2
) AS
BEGIN
    UPDATE WareHouse
    SET Check_Approval = TRIM(p_approval),
        Latest_Check = SYSDATE
    WHERE WareHouseID = p_whid;
    DBMS_OUTPUT.PUT_LINE('อัปเดตผลการตรวจคลังสินค้าเรียบร้อย: ' || p_whid);
END;
/
CREATE OR REPLACE PROCEDURE sp_update_employee_status (
    p_empid     IN VARCHAR2,
    p_empstatus IN VARCHAR2
) AS
BEGIN
    UPDATE Employee
    SET Check_EmpStatus = TRIM(p_empstatus)
    WHERE EmployeeId = p_empid;
    DBMS_OUTPUT.PUT_LINE('อัปเดตสถานะการเข้างานเรียบร้อย: ' || p_empid);
END;
/
CREATE OR REPLACE PROCEDURE sp_resign_employee (
    p_empid       IN VARCHAR2,
    p_resigndate  IN DATE
) AS
BEGIN
    UPDATE Employee
    SET WorkStatus = 'Q',
        ResignDate = NVL(p_resigndate, SYSDATE)
    WHERE EmployeeId = p_empid;
    DBMS_OUTPUT.PUT_LINE('บันทึกการลาออกของพนักงานเรียบร้อย: ' || p_empid);
END;
/
CREATE OR REPLACE PROCEDURE sp_assign_department_manager (
    p_depid       IN VARCHAR2,
    p_mgr_empid   IN VARCHAR2
) AS
BEGIN
    UPDATE Department
    SET MgrEmployeeID = p_mgr_empid,
        MgrDate = SYSDATE
    WHERE DepartmentID = p_depid;
    DBMS_OUTPUT.PUT_LINE('แต่งตั้งหัวหน้าแผนกเรียบร้อย: ' || p_depid);
END;
/
COMMIT;