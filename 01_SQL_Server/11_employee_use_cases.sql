USE HR_Enterprise_Project;
GO

CREATE OR ALTER VIEW dbo.vw_MyAttendanceSummary
AS
SELECT
  a.emp_id,
  COUNT(*) AS total_days,
  SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
  SUM(CASE WHEN a.status = 'Absent'  THEN 1 ELSE 0 END) AS absent_days,
  SUM(CASE WHEN a.status = 'Late'    THEN 1 ELSE 0 END) AS late_days,
  SUM(CASE WHEN a.status = 'Remote'  THEN 1 ELSE 0 END) AS remote_days
FROM dbo.Attendance a
GROUP BY a.emp_id;
GO

CREATE OR ALTER VIEW dbo.vw_MyPerformanceReviews
AS
SELECT
  pr.review_id,
  pr.emp_id,
  rc.cycle_name,
  pr.rating,
  pr.review_date,
  pr.feedback_text
FROM dbo.PerformanceReview pr
JOIN dbo.ReviewCycle rc ON rc.cycle_id = pr.cycle_id;
GO

CREATE OR ALTER VIEW dbo.vw_MyAssignedTraining
AS
SELECT
  et.emp_id,
  tc.course_name,
  et.status,
  et.completion_date
FROM dbo.EmployeeTraining et
JOIN dbo.TrainingCourse tc ON tc.course_id = et.course_id;
GO

CREATE OR ALTER VIEW dbo.vw_MySkillsProfile
AS
SELECT
  es.emp_id,
  s.skill_name,
  es.skill_level,
  es.last_updated
FROM dbo.EmployeeSkill es
JOIN dbo.Skill s ON s.skill_id = es.skill_id;
GO

CREATE OR ALTER FUNCTION dbo.fn_RLS_EmployeeOnly(@emp_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  SELECT 1 AS fn_access
  WHERE
    -- Allow HR/Admin/Manager to see everything (bypass)
    IS_MEMBER('rl_admin') = 1
    OR IS_MEMBER('rl_hr_analyst') = 1
    OR IS_MEMBER('rl_manager') = 1
    -- Employees: only their own rows
    OR @emp_id = TRY_CONVERT(INT, SESSION_CONTEXT(N'emp_id'));
GO

-- Security policy
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'SecurityPolicy_EmployeeSelfService')
BEGIN
  DROP SECURITY POLICY dbo.SecurityPolicy_EmployeeSelfService;
END
GO

CREATE SECURITY POLICY dbo.SecurityPolicy_EmployeeSelfService
ADD FILTER PREDICATE dbo.fn_RLS_EmployeeOnly(emp_id) ON dbo.Attendance,
ADD FILTER PREDICATE dbo.fn_RLS_EmployeeOnly(emp_id) ON dbo.LeaveRequest,
ADD FILTER PREDICATE dbo.fn_RLS_EmployeeOnly(emp_id) ON dbo.PerformanceReview,
ADD FILTER PREDICATE dbo.fn_RLS_EmployeeOnly(emp_id) ON dbo.EmployeeSkill,
ADD FILTER PREDICATE dbo.fn_RLS_EmployeeOnly(emp_id) ON dbo.EmployeeTraining
WITH (STATE = ON);
GO

-- Grant SELECT on views to employee role
GRANT SELECT ON dbo.vw_MyAttendanceSummary   TO rl_employee;
GRANT SELECT ON dbo.vw_MyPerformanceReviews  TO rl_employee;
GRANT SELECT ON dbo.vw_MyAssignedTraining    TO rl_employee;
GRANT SELECT ON dbo.vw_MySkillsProfile       TO rl_employee;
GO

-- HR can also read these (optional)
GRANT SELECT ON dbo.vw_MyAttendanceSummary   TO rl_hr_analyst;
GRANT SELECT ON dbo.vw_MyPerformanceReviews  TO rl_hr_analyst;
GRANT SELECT ON dbo.vw_MyAssignedTraining    TO rl_hr_analyst;
GRANT SELECT ON dbo.vw_MySkillsProfile       TO rl_hr_analyst;
GO

-- Test the security policy and views
EXEC sys.sp_set_session_context @key = N'emp_id', @value = 10;
GO

SELECT * FROM dbo.vw_MyAttendanceSummary;
SELECT * FROM dbo.vw_MyAssignedTraining;
SELECT * FROM dbo.vw_MySkillsProfile;
SELECT * FROM dbo.vw_MyPerformanceReviews;
GO

SELECT name, is_enabled
FROM sys.security_policies;
GO

USE HR_Enterprise_Project;
GO

SELECT name, type_desc
FROM sys.database_principals
WHERE type_desc IN ('SQL_USER', 'WINDOWS_USER', 'WINDOWS_GROUP')
  AND name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
ORDER BY name;
GO

--------------------
SELECT DB_NAME() AS CurrentDB;
GO

SELECT name, type_desc
FROM sys.database_principals
ORDER BY type_desc, name;
GO
--------------------
USE HR_Enterprise_Project;
GO

CREATE USER usr_emp10 WITHOUT LOGIN;
GO

EXEC sp_addrolemember 'rl_employee', 'usr_emp10';
GO

EXECUTE AS USER = 'usr_emp10';
GO

EXEC sys.sp_set_session_context @key = N'emp_id', @value = 10;
GO
---shouldn't retiurn other emp_id rows
EXEC sys.sp_set_session_context @key = N'emp_id', @value = 11;
GO

-------verification 

SELECT SESSION_CONTEXT(N'emp_id') AS emp_id_in_context;
GO

REVERT;
GO
