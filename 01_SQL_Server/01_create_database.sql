USE master;
GO

IF DB_ID('HR_Enterprise_Project') IS NOT NULL
BEGIN
    ALTER DATABASE HR_Enterprise_Project
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HR_Enterprise_Project;
END
GO

CREATE DATABASE HR_Enterprise_Project

-- SELECT name
-- FROM sys.databases
-- WHERE name = 'HR_Enterprise_Project';
-- GO ---To make sure it exists :)

