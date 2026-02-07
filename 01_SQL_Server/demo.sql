USE HR_Enterprise_Project;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

SELECT 
  fk.name AS FK_Name,
  OBJECT_NAME(fk.parent_object_id) AS Child_Table,
  fk.delete_referential_action_desc AS On_Delete
FROM sys.foreign_keys fk
ORDER BY Child_Table;
GO

SELECT * FROM Department;
SELECT * FROM JobPosition;
SELECT * FROM Employee;
GO

SELECT name
FROM sys.procedures
ORDER BY name;
GO

USE HR_Enterprise_Project;
GO


EXEC dbo.sp_AddEmployee
  @person_id = 999,
  @full_name = 'Demo User',
  @email = 'demo@hr.com',
  @phone_number = '123456789',
  @dept_id = 1,
  @position_id = 1,
  @status = 'Active',
  @manager_id = 1,
  @hire_date = '2026-01-11';

SELECT DB_NAME() AS CurrentDB;
GO

USE HR_Enterprise_Project;
GO

SELECT 
  s.name AS [schema],
  p.name AS procedure_name
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
ORDER BY s.name, p.name;
GO

SELECT OBJECT_ID('dbo.sp_AddEmployee') AS sp_AddEmployee_ObjectId;
GO

SELECT 
  DB_NAME() AS current_db,
  OBJECT_SCHEMA_NAME(object_id) AS [schema],
  name
FROM sys.procedures
WHERE name LIKE '%AddEmployee%';
GO

SELECT DB_NAME() AS CurrentDB;

SELECT COUNT(*) AS ProcCount
FROM sys.procedures;
GO

USE HR_Enterprise_Project;
GO

SELECT 
    s.name AS schema_name,
    p.name AS procedure_name
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
ORDER BY s.name, p.name;
GO

USE HR_Enterprise_Project;
GO
---to drop
EXEC dbo.sp_AddEmployee
  @person_id    = 1201,
  @full_name    = 'Demo User',
  @email        = 'demo1005@hr.com',
  @phone_number = '123456789',
  @hire_date    = '2026-01-11',
  @status       = 'Active',
  @dept_id      = 1,
  @position_id  = 1,
  @manager_id   = NULL;
GO

USE HR_Enterprise_Project;
GO

EXEC dbo.sp_AddEmployee
  @person_id    = 1202,
  @full_name    = 'Demo User',
  @email        = 'demo1005@hr.com',
  @phone_number = '123456789',
  @hire_date    = '2026-01-11',
  @status       = 'Active',
  @dept_id      = 1,
  @position_id  = 1,
  @manager_id   = 1;
GO

USE HR_Enterprise_Project;
GO
EXEC sys.sp_refreshsqlmodule 'dbo.sp_AddEmployee';
GO

------------------------------
USE HR_Enterprise_Project;
GO

-- 0.1 Create HR analyst demo user (if missing)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_hr1')
BEGIN
    CREATE USER usr_hr1 WITHOUT LOGIN;
END
GO

-- 0.2 Add HR user to HR Analyst role (if not already)
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
    WHERE r.name = 'rl_hr_analyst' AND m.name = 'usr_hr1'
)
BEGIN
    EXEC sp_addrolemember 'rl_hr_analyst', 'usr_hr1';
END
GO

-- 0.3 Make sure HR Analyst can run reporting + approve/decide leave (RBAC)
GRANT SELECT  ON dbo.vw_HRDashboard            TO rl_hr_analyst;
GRANT SELECT  ON dbo.vw_PendingLeaveRequests   TO rl_hr_analyst;

GRANT EXECUTE ON dbo.sp_SubmitLeaveRequest     TO rl_hr_analyst;
GRANT EXECUTE ON dbo.sp_DecideLeaveRequest     TO rl_hr_analyst;

-- Optional: allow HR to view audit
GRANT SELECT  ON dbo.LeaveRequestAudit         TO rl_hr_analyst;
GO

-- 0.4 Confirm you are admin now
SELECT USER_NAME() AS CurrentUser;
GO


----admin show full access
SELECT TOP 10 *
FROM dbo.vw_HRDashboard
ORDER BY dept_name, full_name;
GO


----switch from admin to hr user
EXECUTE AS USER = 'usr_hr1';
GO

SELECT USER_NAME() AS CurrentUser,
       IS_MEMBER('rl_hr_analyst') AS is_hr_analyst;
GO

---- view pending leave requests
SELECT TOP 10 *
FROM dbo.vw_PendingLeaveRequests
ORDER BY request_id DESC;
GO

--- approve a leave request
EXEC dbo.sp_DecideLeaveRequest
  @request_id = 934365,
  @decision = 'Approved';
GO


-----return to admin

REVERT;
GO

SELECT USER_NAME() AS CurrentUser;
GO
