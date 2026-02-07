USE HR_Enterprise_Project;
GO

/* =========================
   1) HR dashboard view demo
   ========================= */
SELECT TOP 10 *
FROM dbo.vw_HRDashboard
ORDER BY dept_name, full_name;
GO

---Adding employee
USE HR_Enterprise_Project;
GO

DECLARE @new_id INT;

SELECT @new_id = ISNULL(MAX(person_id),0) + 1
FROM dbo.Person;

EXEC dbo.sp_AddEmployee
  @person_id    = 1204,
  @full_name    = 'Demo User1 ',
  @email        = 'demo101@hr.com',
  @phone_number = '1234567899',
  @hire_date    = '2024-01-15',
  @status       = 'Active',
  @dept_id      = 3,
  @position_id  = 5,
  @manager_id   = 3;
GO

EXECUTE AS USER = 'usr_emp10';
GO
SELECT USER_NAME() AS CurrentUser;
GO

EXEC sys.sp_set_session_context @key = N'emp_id', @value = 10;
GO
SELECT SESSION_CONTEXT(N'emp_id') AS emp_id_context;
GO

SELECT * FROM dbo.vw_MyAttendanceSummary WHERE emp_id = 10;
SELECT TOP 10 * FROM dbo.vw_MyAssignedTraining WHERE emp_id = 10;
SELECT TOP 10 * FROM dbo.vw_MySkillsProfile WHERE emp_id = 10;
GO

----should not return other emp_id rows
SELECT * FROM dbo.vw_MyAttendanceSummary WHERE emp_id = 11;
SELECT TOP 10 * FROM dbo.vw_MyAssignedTraining WHERE emp_id = 11;
SELECT TOP 10 * FROM dbo.vw_MySkillsProfile WHERE emp_id = 11;
GO

REVERT;
GO

USE HR_Enterprise_Project;
GO

GRANT EXECUTE ON dbo.sp_SubmitLeaveRequest TO rl_employee;
GO

EXEC dbo.sp_SubmitLeaveRequest
  @request_id = 8002,
  @emp_id = 10,
  @type_id = 1,
  @start_date = '2026-02-10',
  @end_date   = '2026-02-12',
  @reason_text = 'Doctor demo: personal leave';
GO
---------------
USE HR_Enterprise_Project;
GO

DECLARE @req INT;
SELECT @req = ISNULL(MAX(request_id),0) + 1
FROM dbo.LeaveRequest;

SELECT @req AS next_request_id;
GO

DECLARE @req INT;
SELECT @req = ISNULL(MAX(request_id),0) + 1
FROM dbo.LeaveRequest;

EXEC dbo.sp_SubmitLeaveRequest
  @request_id = @req,
  @emp_id = 10,
  @type_id = 1,
  @start_date = '2026-02-10',
  @end_date   = '2026-02-12',
  @reason_text = 'Doctor demo: personal leave';

SELECT @req AS inserted_request_id;
GO

-----------

SELECT *
FROM dbo.vw_PendingLeaveRequests
WHERE request_id = 8002;
GO

SELECT TOP 10 *
FROM dbo.LeaveRequest
ORDER BY request_id DESC;
GO

SELECT TOP 10 *
FROM dbo.vw_PendingLeaveRequests
ORDER BY request_id DESC;
GO


REVERT;
GO
EXEC sys.sp_set_session_context @key = N'emp_id', @value = NULL;
GO

SELECT TOP 20 *
FROM dbo.LeaveRequest
ORDER BY request_id DESC;
GO

USE HR_Enterprise_Project;
GO

EXEC sp_helptext 'dbo.sp_SubmitLeaveRequest';
GO

INSERT INTO dbo.LeaveRequest(request_id, emp_id, type_id, start_date, end_date, status, reason_text)
VALUES (9999, 10, 1, '2026-02-10', '2026-02-12', 'Pending', 'Direct insert test');
GO

SELECT COUNT(*) AS LeaveRequestCount FROM dbo.LeaveRequest;
GO
SELECT * FROM dbo.LeaveRequest WHERE request_id = 9999;
GO


USE HR_Enterprise_Project;
GO

-- A) Confirm context
SELECT
  DB_NAME() AS CurrentDB,
  USER_NAME() AS CurrentUser,
  SESSION_CONTEXT(N'emp_id') AS emp_id_context;
GO

-- B) Check if RLS policy exists/enabled
SELECT name, is_enabled
FROM sys.security_policies;
GO

-- C) Count rows (if RLS is filtering, counts will also look small/zero)
SELECT
  (SELECT COUNT(*) FROM dbo.LeaveRequest) AS LeaveRequestCount,
  (SELECT COUNT(*) FROM dbo.Person) AS PersonCount,
  (SELECT COUNT(*) FROM dbo.Employee) AS EmployeeCount;
GO

-- D) Show newest rows (if any)
SELECT TOP 20 request_id, emp_id, status, start_date, end_date, reason_text
FROM dbo.LeaveRequest
ORDER BY request_id DESC;
GO



SELECT *
FROM dbo.vw_PendingLeaveRequests
WHERE request_id = 8001;
GO

REVERT;
GO

SELECT OBJECT_ID('dbo.sp_SubmitLeaveRequest') AS proc_id;
GO



SELECT COUNT(*) AS leave_count
FROM dbo.LeaveRequest;
GO


REVERT;
GO






USE HR_Enterprise_Project;
GO
SELECT DB_NAME() AS CurrentDB;
GO


SELECT 
  request_id,
  emp_id,
  type_id,
  start_date,
  end_date,
  status,
  reason_text
FROM dbo.LeaveRequest
WHERE emp_id = 10
ORDER BY request_id DESC;
GO

USE HR_Enterprise_Project;
GO

SELECT DB_NAME() AS CurrentDB;

SELECT TOP 10 request_id, emp_id, status, start_date, end_date
FROM dbo.LeaveRequest
ORDER BY request_id DESC;

SELECT TOP 10 *
FROM dbo.vw_PendingLeaveRequests
ORDER BY request_id DESC;
GO

USE HR_Enterprise_Project;
GO

SELECT name, is_enabled
FROM sys.security_policies;
GO



SELECT TOP 20 request_id, emp_id, type_id, start_date, end_date, status, reason_text
FROM dbo.LeaveRequest
ORDER BY request_id DESC;
GO
SELECT *
FROM dbo.LeaveRequest
WHERE request_id = 8001;
GO

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'LeaveRequest'
ORDER BY ORDINAL_POSITION;
GO

---------

USE HR_Enterprise_Project;
GO

SELECT s.name AS schema_name, p.name AS procedure_name
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
WHERE p.name LIKE '%Leave%'
ORDER BY p.name;
GO

SELECT DB_NAME() AS CurrentDB;
GO

USE HR_Enterprise_Project;
GO

SELECT 
    s.name AS schema_name,
    p.name AS procedure_name,
    p.create_date,
    p.modify_date
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
ORDER BY s.name, p.name;
GO
----------------
SELECT DB_NAME() AS CurrentDB;
GO

USE master;
GO

SELECT name
FROM sys.databases
ORDER BY name;
GO

USE HR_Enterprise_Project;
GO
SELECT name FROM sys.procedures ORDER BY name;
GO
-----------------------
USE HR_Enterprise_Project;
GO

DECLARE @req INT = 900000 + ABS(CHECKSUM(NEWID())) % 90000;  -- 900000..989999

-- make sure it doesn't exist
WHILE EXISTS (SELECT 1 FROM dbo.LeaveRequest WHERE request_id = @req)
BEGIN
  SET @req = 900000 + ABS(CHECKSUM(NEWID())) % 90000;
END

EXEC dbo.sp_SubmitLeaveRequest
  @request_id = @req,
  @emp_id = 10,
  @type_id = 1,
  @start_date = '2026-02-10',
  @end_date   = '2026-02-12',
  @reason_text = 'Doctor demo: personal leave';

USE HR_Enterprise_Project;
GO
--- Approve the leave request
EXEC dbo.sp_DecideLeaveRequest
  @request_id = 934365,
  @decision = 'Approved';
GO

SELECT request_id, emp_id, status
FROM dbo.LeaveRequest
WHERE request_id = 934365;
GO
--overlapping leave test
EXEC dbo.sp_DecideLeaveRequest
  @request_id = 9999,
  @decision = 'Approved';
GO




SELECT *
FROM dbo.LeaveRequest
WHERE request_id = (SELECT MAX(request_id) FROM dbo.LeaveRequest);
GO

EXEC sys.sp_set_session_context @key = N'emp_id', @value = 10;
GO

SELECT TOP 10 *
FROM dbo.LeaveRequest
ORDER BY request_id DESC;
GO
