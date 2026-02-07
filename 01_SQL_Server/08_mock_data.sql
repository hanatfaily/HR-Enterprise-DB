USE HR_Enterprise_Project
GO

INSERT INTO dbo.Department (dept_id, dept_name) VALUES
(1, 'HR'),
(2, 'Engineering'),
(3, 'Finance'),
(4, 'Operations'),
(5, 'Sales');
GO

SELECT * FROM dbo.Department;
GO

INSERT INTO dbo.JobPosition (position_id, title) VALUES
(1, 'HR Specialist'),
(2, 'Software Engineer'),
(3, 'Data Analyst'),
(4, 'Operations Officer'),
(5, 'Sales Representative'),
(6,'Manager');
GO
SELECT * FROM dbo.JobPosition;
GO

INSERT INTO dbo.LeaveType (type_id,type_name) VALUES
(1,'Annual'),
(2,'Sick'),
(3,'Maternity/Paternity'),
(4,'Unpaid');
GO
SELECT * FROM dbo.LeaveType;
GO

INSERT INTO dbo.ReviewCycle (cycle_id, cycle_name, start_date, end_date) VALUES
(1, '2025-Q3', '2025-07-01', '2025-09-30'),
(2, '2025-Q4', '2025-10-01', '2025-12-31');
GO
SELECT * FROM dbo.ReviewCycle;
GO

INSERT INTO dbo.Skill (skill_id, skill_name) VALUES
(1, 'Communication'),
(2, 'Teamwork'),
(3, 'SQL'),
(4, 'Python'),
(5, 'Leadership'),
(6, 'Time Management');
GO
SELECT * FROM dbo.Skill;
GO

INSERT INTO dbo.TrainingCourse(course_id, course_name, description, duration_hours) VALUES
(1,'SQL Fundamentals','Relational basics,joins,constraints', 12),
(2,'Workplace Communication','Email,meetings,collaboration',8),
(3,'Leadership Basics','Managing teams and feedback',10),
(4,'Time Management','Prioritization and planning',6);
GO
SELECT * FROM dbo.TrainingCourse;   
GO



;WITH N AS (
  SELECT TOP (40)
         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
)
INSERT INTO dbo.Person (person_id, full_name, email, phone_number)
SELECT
  n,
  CONCAT('Employee ', n),
  CONCAT('emp', n, '@company.com'),
  CONCAT('70', RIGHT('000000' + CAST(n AS VARCHAR(10)), 6))
FROM N;
GO

SELECT COUNT(*) AS persons FROM dbo.Person;

;WITH N AS (
  SELECT TOP (40)
         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
)
INSERT INTO dbo.Employee
  (emp_id, hire_date, status, dept_id, position_id, manager_id)
SELECT
  n,
  '2024-01-01',
  'Active',
  ((n - 1) % 5) + 1,        -- departments 1..5
  ((n - 1) % 6) + 1,        -- positions 1..6
  CASE WHEN n <= 5 THEN NULL ELSE 1 END
FROM N;
GO
SELECT COUNT(*) AS employees FROM dbo.Employee;


EXEC dbo.sp_BatchGenerateAttendance
  @start_date = '2025-12-01',
  @end_date   = '2025-12-30',
  @dept_id    = NULL;
GO

DECLARE @req INT = 1;
DECLARE @emp_id INT = 6;

WHILE @req <= 20
BEGIN
  DECLARE @type_id INT = ((@req - 1) % 4) + 1;
  DECLARE @sd DATE = DATEADD(DAY, @req, '2025-12-01');
  DECLARE @ed DATE = DATEADD(DAY, 2, @sd);

  EXEC dbo.sp_SubmitLeaveRequest
    @request_id = @req,
    @emp_id = @emp_id,
    @type_id = @type_id,
    @start_date = @sd,
    @end_date = @ed,
    @reason_text = 'Personal reasons';

  SET @req += 1;
  SET @emp_id += 1;
END;
GO

USE HR_Enterprise_Project;
GO

-- 1) Make employee 1..5 managers (position_id = 6)
UPDATE dbo.Employee
SET position_id = 6,
    manager_id = NULL
WHERE emp_id BETWEEN 1 AND 5;
GO

-- 2) Assign manager per department for everyone else
UPDATE e
SET e.manager_id =
  CASE e.dept_id
    WHEN 1 THEN 1
    WHEN 2 THEN 2
    WHEN 3 THEN 3
    WHEN 4 THEN 4
    WHEN 5 THEN 5
  END
FROM dbo.Employee e
WHERE e.emp_id > 5;
GO

UPDATE e
SET e.manager_id =
  CASE e.dept_id
    WHEN 1 THEN 1
    WHEN 2 THEN 2
    WHEN 3 THEN 3
    WHEN 4 THEN 4
    WHEN 5 THEN 5
  END
FROM dbo.Employee e
WHERE e.emp_id > 5;
GO

SELECT emp_id, dept_id, position_id, manager_id
FROM dbo.Employee
WHERE emp_id BETWEEN 1 AND 5;
GO

USE HR_Enterprise_Project;
GO

UPDATE dbo.Employee
SET position_id = 6
WHERE emp_id BETWEEN 1 AND 5;
GO

SELECT emp_id, dept_id, position_id, manager_id
FROM dbo.Employee
WHERE emp_id BETWEEN 1 AND 5;
GO

UPDATE e
SET position_id =
  CASE e.dept_id
    WHEN 1 THEN 1
    WHEN 2 THEN 2
    WHEN 3 THEN 3
    WHEN 4 THEN 4
    WHEN 5 THEN 5
  END
FROM dbo.Employee e
WHERE e.emp_id > 5;
GO

UPDATE e
SET e.manager_id =
  CASE e.dept_id
    WHEN 1 THEN 1
    WHEN 2 THEN 2
    WHEN 3 THEN 3
    WHEN 4 THEN 4
    WHEN 5 THEN 5
  END
FROM dbo.Employee e
WHERE e.emp_id > 5;
GO

SELECT emp_id, dept_id, position_id
FROM dbo.Employee
WHERE position_id = 6
ORDER BY emp_id;
GO

DECLARE @req INT = 1;
DECLARE @emp_id INT = 6;

WHILE @req <= 20
BEGIN
  DECLARE @type_id INT = ((@req - 1) % 4) + 1;
  DECLARE @sd DATE = DATEADD(DAY, @req, '2025-12-01');
  DECLARE @ed DATE = DATEADD(DAY, 2, @sd);

  EXEC dbo.sp_SubmitLeaveRequest
    @request_id = @req,
    @emp_id = @emp_id,
    @type_id = @type_id,
    @start_date = @sd,
    @end_date = @ed,
    @reason_text = NULL;

  SET @req += 1;
  SET @emp_id += 1;
END;
GO

SELECT COUNT(*) AS leave_requests
FROM dbo.LeaveRequest;
GO

;WITH N AS (
  SELECT TOP (10) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
)
INSERT INTO dbo.Person(person_id, full_name, email, phone_number)
SELECT
  1000 + n,
  CONCAT('Contractor ', n),
  CONCAT('contractor', n, '@vendor.com'),
  CONCAT('71', RIGHT('000000' + CAST(n AS VARCHAR(10)), 6))
FROM N;
GO

;WITH N AS (
  SELECT TOP (10) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
)
INSERT INTO dbo.Contractor(contractor_id, company_name, start_date, end_date)
SELECT
  1000 + n,
  CONCAT('Vendor Co ', ((n - 1) % 3) + 1),
  DATEADD(DAY, -30 * n, CAST('2025-12-31' AS DATE)),
  NULL
FROM N;
GO

DECLARE @e INT = 6;   -- start from non-managers, optional
WHILE @e <= 40
BEGIN
  INSERT INTO dbo.EmployeeSkill(emp_id, skill_id, skill_level, last_updated)
  VALUES
    (@e, ((@e - 1) % 6) + 1, 'Intermediate', '2025-12-15'),
    (@e, ((@e) % 6) + 1, 'Beginner', '2025-12-15');

  SET @e += 1;
END;
GO

DECLARE @e2 INT = 6;
WHILE @e2 <= 40
BEGIN
  INSERT INTO dbo.EmployeeTraining(emp_id, course_id, status, completion_date)
  VALUES
    (@e2, ((@e2 - 1) % 4) + 1, 'Completed', '2025-11-30');

  -- add second course for some employees
  IF (@e2 % 3 = 0)
  BEGIN
    INSERT INTO dbo.EmployeeTraining(emp_id, course_id, status, completion_date)
    VALUES
      (@e2, ((@e2) % 4) + 1, 'Enrolled', NULL);
  END

  SET @e2 += 1;
END;
GO

UPDATE dbo.LeaveRequest
SET status = 'Approved'
WHERE request_id = 15;
GO

UPDATE dbo.LeaveRequest
SET status = 'Rejected'
WHERE request_id = 2;
GO

UPDATE dbo.EmployeeTraining
SET status = 'Enrolled'
WHERE status = 'InProgress';
GO

USE HR_Enterprise_Project;
GO

SELECT * FROM dbo.ReviewCycle;
GO

USE HR_Enterprise_Project;
GO

-- Insert reviews for emp 10 in cycle 1 and 2
INSERT INTO dbo.PerformanceReview
(review_id, emp_id, cycle_id, rating, feedback_text, review_date, feedback_meta_json)
VALUES
(99002, 10, 1, 4, N'Good performance, strong teamwork and punctuality.', '2025-09-30', N'{"source":"HR","type":"quarterly"}'),
(99003, 10, 2, 5, N'Excellent improvement, leadership and consistent delivery.', '2025-12-31', N'{"source":"Manager","type":"quarterly"}');

-- Insert reviews for other employees (cycle 2)
INSERT INTO dbo.PerformanceReview
(review_id, emp_id, cycle_id, rating, feedback_text, review_date, feedback_meta_json)
VALUES
(99004, 11, 2, 3, N'Average performance, needs better communication.', '2025-12-31', N'{"source":"Manager"}'),
(99005, 12, 2, 2, N'Late tasks, needs training and time management.', '2025-12-31', N'{"source":"HR"}');
GO

SELECT TOP 20 *
FROM dbo.PerformanceReview
ORDER BY review_id DESC;
GO
