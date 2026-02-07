USE HR_Enterprise_Project;
GO

/* ===== Employee join indexes ===== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Employee_Dept' AND object_id=OBJECT_ID('dbo.Employee'))
  CREATE INDEX IX_Employee_Dept ON dbo.Employee(dept_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Employee_Position' AND object_id=OBJECT_ID('dbo.Employee'))
  CREATE INDEX IX_Employee_Position ON dbo.Employee(position_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Employee_Manager' AND object_id=OBJECT_ID('dbo.Employee'))
  CREATE INDEX IX_Employee_Manager ON dbo.Employee(manager_id);

/* ===== LeaveRequest workflow/reporting indexes ===== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_LeaveRequest_Emp_Status' AND object_id=OBJECT_ID('dbo.LeaveRequest'))
  CREATE INDEX IX_LeaveRequest_Emp_Status ON dbo.LeaveRequest(emp_id, status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_LeaveRequest_Dates' AND object_id=OBJECT_ID('dbo.LeaveRequest'))
  CREATE INDEX IX_LeaveRequest_Dates ON dbo.LeaveRequest(start_date, end_date);

/* ===== PerformanceReview analysis indexes ===== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PerformanceReview_Emp' AND object_id=OBJECT_ID('dbo.PerformanceReview'))
  CREATE INDEX IX_PerformanceReview_Emp ON dbo.PerformanceReview(emp_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PerformanceReview_Cycle' AND object_id=OBJECT_ID('dbo.PerformanceReview'))
  CREATE INDEX IX_PerformanceReview_Cycle ON dbo.PerformanceReview(cycle_id);

/* ===== Junction tables: reverse lookup indexes ===== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EmployeeSkill_Skill' AND object_id=OBJECT_ID('dbo.EmployeeSkill'))
  CREATE INDEX IX_EmployeeSkill_Skill ON dbo.EmployeeSkill(skill_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EmployeeTraining_Course' AND object_id=OBJECT_ID('dbo.EmployeeTraining'))
  CREATE INDEX IX_EmployeeTraining_Course ON dbo.EmployeeTraining(course_id);
GO

SELECT t.name AS TableName, i.name AS IndexName, i.type_desc
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
ORDER BY t.name, i.name;
GO
