USE HR_Enterprise_Project;
GO
-- roles creation
USE HR_Enterprise_Project;
GO

-- rl_admin
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_admin')
BEGIN
    CREATE ROLE rl_admin;
END
GO

-- rl_hr_analyst
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_hr_analyst')
BEGIN
    CREATE ROLE rl_hr_analyst;
END
GO

-- rl_manager
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_manager')
BEGIN
    CREATE ROLE rl_manager;
END
GO

-- rl_employee
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_employee')
BEGIN
    CREATE ROLE rl_employee;
END
GO

-- rl_ai_service
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_ai_service')
BEGIN
    CREATE ROLE rl_ai_service;
END
GO

SELECT name FROM sys.database_principals
WHERE type_desc = 'DATABASE_ROLE'
ORDER BY name;
GO



