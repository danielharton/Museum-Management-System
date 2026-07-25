DECLARE
    v_count NUMBER;
BEGIN
-- If any table from the presented schema exists I will delete it
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name= 'DONATIONS';
    IF v_count >0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Donations CASCADE CONSTRAINTS';
    END IF;
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name ='STAFF';
    IF v_count> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Staff CASCADE CONSTRAINTS';
    END IF;
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name ='FINANCIAL_REPORTS';
    IF v_count >0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Financial_Reports CASCADE CONSTRAINTS';
    END IF;
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name= 'EXHIBITS';
    IF v_count> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Exhibits CASCADE CONSTRAINTS';
    END IF;
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name= 'MUSEUM';
    IF v_count>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Museum CASCADE CONSTRAINTS';
    END IF;
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name='TICKETS';
    IF v_count>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Tickets CASCADE  CONSTRAINTS';
    END IF;
    -- q'' allows multiple row strings
    EXECUTE IMMEDIATE q'[CREATE TABLE Museum(
            MuseumID NUMBER PRIMARY KEY,
            Name VARCHAR2(100) NOT NULL,
            Location VARCHAR2(50),
            EstablishmentDate DATE,
            AnnualBudget NUMBER)]';
    EXECUTE IMMEDIATE q'[CREATE TABLE Exhibits(
            ExhibitID NUMBER PRIMARY KEY,
            MuseumID  NUMBER  NOT NULL,
            Name  VARCHAR2(100) NOT NULL,
            StartDate DATE,
            EndDate DATE,
            MaintenanceCost NUMBER,
            RevenueGenerated NUMBER,
            Description  VARCHAR2(300),
            CONSTRAINT FK_Exhibits_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID))]';
    EXECUTE IMMEDIATE q'[CREATE TABLE Tickets(
            TicketID NUMBER PRIMARY KEY,
            ExhibitID NUMBER NOT NULL,
            TicketDate DATE NOT NULL,
            VisitorName VARCHAR2(100),
            TicketPrice NUMBER NOT NULL,
            Quantity NUMBER NOT NULL,
            TotalAmount AS (TicketPrice*Quantity) VIRTUAL,
            CONSTRAINT FK_Tickets_Exhibits FOREIGN KEY (ExhibitID) REFERENCES Exhibits(ExhibitID))]';
    EXECUTE IMMEDIATE q'[CREATE TABLE Donations(
            DonationID NUMBER PRIMARY KEY,
            MuseumID NUMBER NOT NULL,
            DonorName VARCHAR2(100),
            DonationAmount NUMBER NOT NULL,
            DonationDate DATE NOT NULL,
            Purpose VARCHAR2(300),
            CONSTRAINT FK_Donations_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID))]';
    EXECUTE IMMEDIATE q'[CREATE TABLE Staff(
            StaffID NUMBER PRIMARY KEY,
            MuseumID NUMBER NOT NULL,
            Name VARCHAR2(100) NOT NULL,
            Role VARCHAR2(50),
            Salary NUMBER NOT NULL,
            SupervisorID NUMBER,
            CONSTRAINT FK_Staff_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID))]';
    EXECUTE IMMEDIATE 'ALTER TABLE Staff ADD HireDate DATE';
    EXECUTE IMMEDIATE q'[CREATE TABLE Financial_Reports (
            ReportID NUMBER  PRIMARY KEY,
            MuseumID NUMBER NOT NULL,
            Month DATE NOT NULL,
            TotalRevenue NUMBER,
            TotalExpenses NUMBER,
            ProfitOrLoss AS (TotalRevenue-TotalExpenses) VIRTUAL,
            CONSTRAINT FK_FinancialReports_Museum FOREIGN KEY (MuseumID) REFERENCES Museum(MuseumID))]';
    EXECUTE IMMEDIATE q'[INSERT INTO Museum(MuseumID,Name,Location,AnnualBudget)
                  VALUES(1,'National History Museum','New York',2311)]';
    EXECUTE IMMEDIATE q'[INSERT INTO Museum (MuseumID,Name,Location,EstablishmentDate,AnnualBudget)
              VALUES (2,'Grigore Antipa National Museum of Natural History',
              'Bucharest',TO_DATE('1999-11-23','YYYY-MM-DD'),500000)]';
    EXECUTE IMMEDIATE q'[ INSERT INTO Exhibits (ExhibitID,MuseumID,Name,MaintenanceCost,RevenueGenerated)
            VALUES (1,1,'Dinosaur Fossils',5000, 20000)]';
    EXECUTE IMMEDIATE q'[INSERT INTO Staff(StaffID,MuseumID, Name,Role, Salary,HireDate, SupervisorID)
            VALUES (2, 2,'Victor Dumitrescu','Manager',3500,
                TO_DATE('2018-10-20','YYYY-MM-DD'), NULL)]';
    EXECUTE IMMEDIATE q'[ INSERT INTO Staff(StaffID,MuseumID, Name,Role, Salary,HireDate,SupervisorID)
        VALUES (1, 2,'Daniel Harton','Receptionist', 
        3500,TO_DATE('2018-10-20','YYYY-MM-DD'), 2)]';
    EXECUTE IMMEDIATE q'[INSERT INTO Donations (DonationID,MuseumID, DonorName,DonationAmount, DonationDate)
            VALUES (1,1, 'Michael Johnson',1000, TO_DATE('2022-11-03','YYYY-MM-DD'))]';
    EXECUTE IMMEDIATE q'[ INSERT INTO Donations (DonationID,MuseumID,DonorName,DonationAmount,DonationDate,Purpose)
        VALUES (2,1, 'Daniel Harton',350, TO_DATE('2013-08-02','YYYY-MM-DD'),
                'Maintaining existing items in good shape')]';
    EXECUTE IMMEDIATE q'[INSERT INTO Financial_Reports(ReportID,MuseumID, Month,TotalRevenue,TotalExpenses)
        VALUES (1,1, TO_DATE('2023-02','YYYY-MM'),2000, 100)]';
    EXECUTE IMMEDIATE q'[ UPDATE Exhibits SET RevenueGenerated = 51000
            WHERE ExhibitID != 2]';
    EXECUTE IMMEDIATE q'[
        DELETE FROM Donations
            WHERE DonationID = 1
    ]';
    EXECUTE IMMEDIATE q'[MERGE INTO Financial_Reports FR
        USING (SELECT MuseumID,SUM(RevenueGenerated) AS TotalRevenue
        FROM Exhibits GROUP BY MuseumID) ER
        ON (FR.MuseumID=ER.MuseumID) WHEN MATCHED THEN
            UPDATE SET FR.TotalRevenue=ER.TotalRevenue]';
    COMMIT;
EXCEPTION WHEN OTHERS THEN ROLLBACK;
END;
/

set serveroutput on
DECLARE
  v_cost EXHIBITS.maintenancecost%TYPE;
  v_add NUMBER;
BEGIN
  SELECT maintenancecost INTO v_cost FROM exhibits WHERE exhibitid = 1;
  v_add :=CASE
              WHEN v_cost < 1000 THEN 200
              WHEN v_cost BETWEEN 1000 AND 5000 THEN 100
              ELSE 0
            END;
  v_cost := v_cost + v_add;
  DBMS_OUTPUT.PUT_LINE('Adjusted maintenance cost for Exhibit 1: ' || v_cost);
END;
/

SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION get_receptionist_name (p_staffid IN NUMBER) RETURN VARCHAR2 IS
    v_name Staff.Name%TYPE;
    v_role Staff.Role%TYPE;
BEGIN
    SELECT Name, Role INTO v_name, v_role FROM Staff
        WHERE StaffID = p_staffid;
    IF UPPER(v_role) = 'RECEPTIONIST' THEN
        RETURN v_name;
    ELSE
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END get_receptionist_name;
/

DECLARE
    v_recep_name VARCHAR2(100);
    v_input_id NUMBER:=1;
BEGIN
    v_recep_name := get_receptionist_name(v_input_id);
    IF v_recep_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Receptionist (StaffID='|| v_input_id || '): '|| v_recep_name);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No receptionist found for StaffID='|| v_input_id|| ' (either not a receptionist or does not exist).');
    END IF;
END;
/

SET serVerOutput on
DECLARE
  CURSOR c IS
    SELECT donationid, donationamount
      FROM donations WHERE museumid = 1 ORDER BY donationid;
  v_rec c%ROWTYPE;
  v_category VARCHAR2(20);
BEGIN
  OPEN c;
  LOOP
    FETCH c INTO v_rec;
    EXIT WHEN c%NOTFOUND;
    IF v_rec.donationamount>=10000 THEN
        v_category:= 'Large';
    ELSIF v_rec.donationamount BETWEEN 1031 AND 9963 THEN
        v_category :='Medium';
    ELSE
        v_category:='Small';
    END IF;
    DBMS_OUTPUT.PUT_LINE('Donation '|| v_rec.donationid||' amount '|| v_rec.donationamount||' classified as '||v_category);
  END LOOP;
  CLOSE c;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: '|| SQLERRM);
END;
/

SET SERVEROUTPUT ON;
DECLARE
    CURSOR c(p_mid NUMBER) IS SELECT exhibitid, name
                                FROM exhibits WHERE museumid = p_mid
    FOR UPDATE;
    v_rec c%ROWTYPE;
BEGIN
    OPEN c(1);
    LOOP
        FETCH c INTO v_rec;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ExhibitID=' || v_rec.exhibitid ||
                            ', Name=' || v_rec.name);
        UPDATE exhibits
        SET description =NVL(description,'')|| ' (Reviewed)'
        WHERE CURRENT OF c;
    END LOOP;
    CLOSE c;
    COMMIT;
END;
/

SET SERVEROUTPUT ON
DECLARE
  v_name VARCHAR2(100);
  i PLS_INTEGER:=1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Exhibits with odd IDs:');
    WHILE i<=20 LOOP
    BEGIN
        SELECT name INTO v_name FROM exhibits
                WHERE exhibitid = i;
        DBMS_OUTPUT.PUT_LINE(i||' --> '||v_name);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    i:= i+2;
    END LOOP;
END;
/

SET SERVEROUTPUT ON
DECLARE
    TYPE t_staff_email_tab IS TABLE OF STAFF%ROWTYPE INDEX BY PLS_INTEGER;
    v_tab t_staff_email_tab;
    v_index PLS_INTEGER:=0;
BEGIN
    FOR r IN (SELECT staffid,name FROM staff ORDER BY staffid) LOOP
        v_index:=v_index + 1;
        v_tab(v_index).staffid:= r.staffid;
        v_tab(v_index).name :=r.name;
    END LOOP;
    
    v_index :=v_tab.FIRST;
    WHILE v_index IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE( 'StaffID=' || v_tab(v_index).staffid ||
                            ', Name=' || v_tab(v_index).name);
    v_index:= v_tab.NEXT(v_index);
    END LOOP;
END;
/

SET SERVEROUTPUT ON
DECLARE
    TYPE t_don IS TABLE OF DONATIONS%ROWTYPE;
    v_dons t_don;
    idx PLS_INTEGER;
BEGIN
    SELECT * BULK COLLECT INTO v_dons
    FROM donations WHERE museumid=1
    ORDER BY donationid;
    idx:=v_dons.FIRST;
    WHILE idx IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE('DonationID='||v_dons(idx).donationid||
          ', Amount='|| v_dons(idx).donationamount||
          ', Date=' ||TO_CHAR(v_dons(idx).donationdate,'YYYY-MM-DD'));
        idx :=v_dons.NEXT(idx);
    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/

DECLARE
  TYPE t_mv_rec IS RECORD(
    museumid      MUSEUM.museumid%TYPE,
    total_revenue NUMBER
  );
  TYPE t_top3_mv IS VARRAY(3) OF t_mv_rec;
  v_top t_top3_mv := t_top3_mv();
  CURSOR c_rev IS
    SELECT m.museumid, NVL(SUM(e.revenuegenerated),0) AS totrev
      FROM museum m LEFT JOIN exhibits e ON m.museumid = e.museumid
     GROUP BY m.museumid
     ORDER BY totrev DESC
     FETCH FIRST 3 ROWS ONLY;
  v_rec t_mv_rec;
  idx   PLS_INTEGER := 0;
BEGIN
  OPEN c_rev;
  LOOP
    FETCH c_rev INTO v_rec;
    EXIT WHEN c_rev%NOTFOUND OR idx = 3;
    idx := idx + 1;
    v_top.EXTEND;
    v_top(idx) := v_rec;
  END LOOP;
  CLOSE c_rev;
  FOR i IN 1..v_top.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Rank ' || i || ': MuseumID=' || v_top(i).museumid ||
      ', Revenue=' || v_top(i).total_revenue
    );
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

DECLARE
    e_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_exists,-955);
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE Museum_Log(log_id NUMBER PRIMARY KEY,action VARCHAR2(20),ts TIMESTAMP)';
    EXCEPTION WHEN e_exists THEN
        EXECUTE IMMEDIATE 'DROP TABLE Museum_Log';
        EXECUTE IMMEDIATE 'CREATE TABLE Museum_Log(log_id NUMBER PRIMARY KEY,action VARCHAR2(20),ts TIMESTAMP)';
END;
/

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE museum_pkg IS
    FUNCTION func_exhibit_profit(p_eid EXHIBITS.exhibitid%TYPE) RETURN NUMBER;
    FUNCTION func_total_donations(p_mid IN DONATIONS.museumid%TYPE,p_month DATE) RETURN NUMBER;
    FUNCTION func_next_staffid RETURN NUMBER;
    PROCEDURE proc_add_exhibit(p_eid EXHIBITS.exhibitid%TYPE,
                                p_mid EXHIBITS.museumid%TYPE,
                                p_name EXHIBITS.name%TYPE,
                                p_start EXHIBITS.startdate%TYPE,
                                p_end EXHIBITS.enddate%TYPE,
                                p_cost EXHIBITS.maintenancecost%TYPE,
                                p_desc EXHIBITS.description%TYPE);
    PROCEDURE proc_record_ticket(p_tid TICKETS.ticketid%TYPE,
                                p_eid TICKETS.exhibitid%TYPE,
                                p_date TICKETS.ticketdate%TYPE,
                                p_price TICKETS.ticketprice%TYPE,
                                p_qty TICKETS.quantity%TYPE);
    PROCEDURE proc_gen_monthly_report(p_month DATE);
END museum_pkg;
/

CREATE OR REPLACE PACKAGE BODY museum_pkg IS
    PROCEDURE priv_log(p_op IN VARCHAR2,p_tbl VARCHAR2)
    IS
        v_next NUMBER;
    BEGIN
        SELECT NVL(MAX(log_id),0)+1 INTO v_next FROM Museum_Log;
        INSERT INTO Museum_Log(log_id,action,ts) VALUES(v_next,p_op||' ON '||p_tbl,SYSTIMESTAMP);
        COMMIT;
        EXCEPTION WHEN OTHERS THEN NULL;
    END priv_log;
    FUNCTION func_exhibit_profit(p_eid IN EXHIBITS.exhibitid%TYPE) RETURN NUMBER
    IS
        v_cost EXHIBITS.maintenancecost%TYPE;
        v_revenue EXHIBITS.revenuegenerated%TYPE;
    BEGIN
        SELECT maintenancecost,revenuegenerated INTO v_cost,v_revenue
            FROM exhibits WHERE exhibitid=p_eid;
        RETURN v_revenue-v_cost;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 0;
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001,'Error in func_exhibit_profit:'||SQLERRM);
    END func_exhibit_profit;
    FUNCTION func_total_donations(p_mid  DONATIONS.museumid%TYPE,
                                    p_month DATE) RETURN NUMBER
    IS
    v_sum NUMBER;
    BEGIN
        SELECT NVL(SUM(donationamount),0) INTO v_sum
        FROM donations WHERE museumid=p_mid
                             AND TRUNC(donationdate,'MM')=TRUNC(p_month,'MM');
        RETURN v_sum;
        EXCEPTION
            WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Error in func_total_donations:'||SQLERRM);
    END func_total_donations;
    FUNCTION func_next_staffid RETURN NUMBER
    IS
        v_next NUMBER;
    BEGIN
        SELECT NVL(MAX(staffid),0)+1 INTO v_next FROM staff;
        RETURN v_next;
        EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003,'Error in func_next_staffid:'||SQLERRM);
    END func_next_staffid;
    PROCEDURE proc_add_exhibit(p_eid EXHIBITS.exhibitid%TYPE,
                                p_mid EXHIBITS.museumid%TYPE,
                                p_name IN EXHIBITS.name%TYPE,
                                p_start EXHIBITS.startdate%TYPE,
                                p_end EXHIBITS.enddate%TYPE,
                                p_cost EXHIBITS.maintenancecost%TYPE,
                                p_desc EXHIBITS.description%TYPE )
    IS
    e_no_museum EXCEPTION;
    e_bad_dates EXCEPTION;
    v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM museum WHERE museumid=p_mid;
        IF v_cnt=0 THEN 
            RAISE e_no_museum;
        END IF;
        IF p_start>p_end THEN
            RAISE e_bad_dates;
        END IF;
        INSERT INTO exhibits(exhibitid,museumid,name,startdate,enddate,maintenancecost,revenuegenerated,description)
            VALUES( p_eid,p_mid,p_name,p_start,p_end,p_cost,0,p_desc);
        COMMIT;
        priv_log('INSERT','EXHIBITS');
        EXCEPTION
            WHEN e_no_museum THEN
                RAISE_APPLICATION_ERROR(-20011,'No such museum:'||p_mid);
            WHEN e_bad_dates THEN
                RAISE_APPLICATION_ERROR(-20012,'StartDate>EndDate');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20014,'ExhibitID already exists:'||p_eid);
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20013,'Error in proc_add_exhibit:'||SQLERRM);
    END proc_add_exhibit;
    PROCEDURE proc_record_ticket( p_tid TICKETS.ticketid%TYPE,
                                    p_eid TICKETS.exhibitid%TYPE,
                                    p_date TICKETS.ticketdate%TYPE,
                                    p_price TICKETS.ticketprice%TYPE,
                                    p_qty TICKETS.quantity%TYPE )
    IS
        e_bad_date EXCEPTION;
        v_start EXHIBITS.startdate%TYPE;
        v_end EXHIBITS.enddate%TYPE;
        v_rows NUMBER;
    BEGIN
        SELECT startdate,enddate INTO v_start,v_end
                FROM exhibits WHERE exhibitid=p_eid;
        IF p_date<v_start OR p_date>v_end THEN 
            RAISE e_bad_date;
        END IF;
        INSERT INTO tickets(ticketid,exhibitid,ticketdate,ticketprice,quantity) 
            VALUES(p_tid,p_eid,p_date,p_price,p_qty);
        v_rows:=SQL%ROWCOUNT;
        UPDATE exhibits SET revenuegenerated=NVL(revenuegenerated,0)+(p_price*p_qty)
                    WHERE exhibitid=p_eid;
        COMMIT;
        priv_log('INSERT TICKET','TICKETS');
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20021,'No such exhibit:'||p_eid);
            WHEN e_bad_date THEN
                RAISE_APPLICATION_ERROR(-20022,'Ticket date out of range');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20024,'TicketID already exists:'||p_tid);
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20023,'Error in proc_record_ticket:'||SQLERRM);
    END proc_record_ticket;
    
    PROCEDURE proc_gen_monthly_report(p_month DATE)
    IS
    TYPE t_mid_tab IS TABLE OF MUSEUM.museumid%TYPE INDEX BY PLS_INTEGER;
    v_mids t_mid_tab;
    v_count PLS_INTEGER:=0;
    v_rev NUMBER;
    v_exp NUMBER;
    v_next NUMBER;
    BEGIN
        FOR m IN (SELECT museumid FROM museum ORDER BY museumid) LOOP
            v_count:=v_count+1;
            v_mids(v_count):=m.museumid;
        END LOOP;
        FOR i IN 1..v_count LOOP
            SELECT NVL(SUM(e.revenuegenerated),0) INTO v_rev
                FROM exhibits e WHERE e.museumid=v_mids(i)
                                AND TRUNC(e.startdate,'MM')=TRUNC(p_month,'MM');
            SELECT NVL(SUM(s.salary),0) INTO v_exp
            FROM staff s WHERE s.museumid=v_mids(i)
                        AND TRUNC(s.hiredate,'MM')<=TRUNC(p_month,'MM');
            BEGIN
                UPDATE financial_reports
                SET totalrevenue=v_rev,totalexpenses=v_exp
                WHERE museumid=v_mids(i)
                        AND TRUNC(month,'MM')=TRUNC(p_month,'MM');
                IF SQL%ROWCOUNT=0 THEN
                    SELECT NVL(MAX(reportid),0)+1 INTO v_next FROM financial_reports;
                    INSERT INTO financial_reports(reportid,museumid,month,totalrevenue,totalexpenses) 
                    VALUES( v_next,v_mids(i),p_month,v_rev,v_exp);
                END IF;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
        END LOOP;
        COMMIT;
        priv_log('EXECUTE','PROC_GEN_MONTHLY_REPORT');
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20031,'Error in proc_gen_monthly_report:'||SQLERRM);
    END proc_gen_monthly_report;
END museum_pkg;
/

BEGIN
    museum_pkg.proc_add_exhibit(p_eid =>10,
                                p_mid=>1,
                                p_name=> 'Modern Art Display',
                                p_start=> TO_DATE('2023-11-01','YYYY-MM-DD'),
                                p_end=>TO_DATE('2024-02-28','YYYY-MM-DD'),
                                p_cost =>2500,
                                p_desc=>'A rotating display of modern art pieces.');
    DBMS_OUTPUT.PUT_LINE('proc_add_exhibit succeeded');
    EXCEPTION
        WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

BEGIN
    museum_pkg.proc_record_ticket(p_tid =>100,
                                p_eid=> 10,
                                p_date=>TO_DATE('2023-11-05','YYYY-MM-DD'),
                                p_price =>20,
                                p_qty=>3);
    DBMS_OUTPUT.PUT_LINE('proc_record_ticket succeeded');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

BEGIN
    museum_pkg.proc_gen_monthly_report(TO_DATE('2024-03','YYYY-MM'));
    DBMS_OUTPUT.PUT_LINE('proc_gen_monthly_report succeeded');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_prevent_delete_museum
BEFORE DELETE ON museum FOR EACH ROW
DECLARE
    e_forbidden EXCEPTION;
BEGIN
    IF :OLD.annualbudget > 1000000 THEN
        RAISE_APPLICATION_ERROR(-20041,'Cannot delete Museum '
                            || :OLD.museumid || ': budget ' ||
                                :OLD.annualbudget || ' > 1000000' );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_validate_ticketdate
BEFORE INSERT OR UPDATE ON tickets
FOR EACH ROW
DECLARE
    v_start DATE;
    v_end   DATE;
BEGIN
    SELECT startdate, enddate INTO v_start, v_end
    FROM exhibits WHERE exhibitid= :NEW.exhibitid;
    IF :NEW.ticketdate < v_start OR :NEW.ticketdate>v_end THEN
        RAISE_APPLICATION_ERROR(-20051,'Ticket date out of range for ExhibitID='|| :NEW.exhibitid);
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20052,'No Exhibit '||:NEW.exhibitid);
END;
/

CREATE OR REPLACE TRIGGER trg_audit_donations
AFTER INSERT OR UPDATE ON donations
DECLARE
    v_next NUMBER;
    v_action VARCHAR2(30);
BEGIN
    SELECT NVL(MAX(log_id),0)+1 INTO v_next FROM Museum_Log;
    IF INSERTING THEN
        v_action:= 'INSERT ON DONATIONS';
    ELSIF UPDATING THEN
        v_action :='UPDATE ON DONATIONS';
    END IF;
    INSERT INTO Museum_Log(log_id,action,ts)
    VALUES(v_next,v_action,SYSTIMESTAMP);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_staff_supervisor
BEFORE INSERT OR UPDATE ON staff
FOR EACH ROW
DECLARE
    v_sup_mid NUMBER;
BEGIN
    IF :NEW.supervisorid IS NOT NULL THEN
        SELECT museumid INTO v_sup_mid FROM staff WHERE staffid = :NEW.supervisorid;
        IF v_sup_mid != :NEW.museumid THEN
            RAISE_APPLICATION_ERROR(-20061,
            'Supervisor ' || :NEW.supervisorid ||
            ' in Museum ' || v_sup_mid ||
            ' cannot supervise Staff in Museum ' || :NEW.museumid);
        END IF;
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20062,'No such Supervisor '||:NEW.supervisorid);
END;
/

CREATE OR REPLACE TRIGGER trg_stmt_log_museum_changes
AFTER INSERT OR UPDATE OR DELETE ON museum
BEGIN
  INSERT INTO Museum_Log(log_id,action,ts)
  VALUES((SELECT NVL(MAX(log_id),0)+1 FROM Museum_Log),
         'STATEMENT CHANGE ON MUSEUM', SYSTIMESTAMP);
END;
/