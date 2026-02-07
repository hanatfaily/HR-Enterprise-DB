USE HR_Enterprise_Project;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AddEmployee
  @person_id   INT,
  @full_name   VARCHAR(150),
  @email       VARCHAR(150),
  @phone_number VARCHAR(30) = NULL,
  @hire_date   DATE,
  @status      VARCHAR(20),
  @dept_id     INT,
  @position_id INT,
  @manager_id  INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    IF @status NOT IN ('Active','OnLeave','Terminated')
      THROW 50001, 'Invalid employee status.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE dept_id = @dept_id)
      THROW 50002, 'Department does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.JobPosition WHERE position_id = @position_id)
      THROW 50003, 'Job position does not exist.', 1;

    IF @manager_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE emp_id = @manager_id)
      THROW 50004, 'Manager does not exist.', 1;

    INSERT INTO dbo.Person(person_id, full_name, email, phone_number)
    VALUES (@person_id, @full_name, @email, @phone_number);

    INSERT INTO dbo.Employee(emp_id, hire_date, status, dept_id, position_id, manager_id)
    VALUES (@person_id, @hire_date, @status, @dept_id, @position_id, @manager_id);

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO
------------------------------------------------------------procedure2
CREATE OR ALTER PROCEDURE dbo.sp_RecordAttendance
  @attendance_id INT,
  @emp_id INT,
  @work_date DATE,
  @status VARCHAR(20),
  @check_in_time TIME = NULL,
  @check_out_time TIME = NULL,
  @notes_json NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Validate employee exists
  IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE emp_id = @emp_id)
    THROW 51001, 'Employee does not exist.', 1;

  -- Validate status
  IF @status NOT IN ('Present','Absent','Remote','Late')
    THROW 51002, 'Invalid attendance status.', 1;

  -- Validate time rules
  IF @status IN ('Present','Late') AND @check_in_time IS NULL
    THROW 51003, 'check_in_time is required for Present/Late.', 1;

  IF @check_out_time IS NOT NULL AND @check_in_time IS NOT NULL AND @check_out_time < @check_in_time
    THROW 51004, 'check_out_time cannot be earlier than check_in_time.', 1;

  -- Insert attendance row
  INSERT INTO dbo.Attendance(attendance_id, emp_id, work_date, status, check_in_time, check_out_time, notes_json)
  VALUES (@attendance_id, @emp_id, @work_date, @status, @check_in_time, @check_out_time, @notes_json);
END;
GO
-----------------------------------------------procedure 3
CREATE OR ALTER PROCEDURE dbo.sp_SubmitLeaveRequest
  @request_id INT,
  @emp_id INT,
  @type_id INT,
  @start_date DATE,
  @end_date DATE,
  @reason_text VARCHAR(400) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Validate employee exists
  IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE emp_id = @emp_id)
    THROW 52001, 'Employee does not exist.', 1;

  -- Validate leave type exists
  IF NOT EXISTS (SELECT 1 FROM dbo.LeaveType WHERE type_id = @type_id)
    THROW 52002, 'Leave type does not exist.', 1;

  -- Validate dates
  IF @end_date < @start_date
    THROW 52003, 'Leave end_date must be >= start_date.', 1;

  -- Insert as Pending (workflow rule)
  INSERT INTO dbo.LeaveRequest(request_id, emp_id, type_id, start_date, end_date, status, reason_text)
  VALUES (@request_id, @emp_id, @type_id, @start_date, @end_date, 'Pending', @reason_text);
END;
GO
-------------------------------------------procedure 4

CREATE OR ALTER PROCEDURE dbo.sp_DecideLeaveRequest
  @request_id INT,
  @decision VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE
    @emp_id INT,
    @start_date DATE,
    @end_date DATE;

  BEGIN TRY
    BEGIN TRAN;

    -- Validate decision
    IF @decision NOT IN ('Approved', 'Rejected')
      THROW 53001, 'Decision must be Approved or Rejected.', 1;

    -- Get request details
    SELECT
      @emp_id = emp_id,
      @start_date = start_date,
      @end_date = end_date
    FROM dbo.LeaveRequest
    WHERE request_id = @request_id;

    IF @emp_id IS NULL
      THROW 53002, 'Leave request does not exist.', 1;

    -- Prevent overlapping approved leave
    IF @decision = 'Approved'
    AND EXISTS (
      SELECT 1
      FROM dbo.LeaveRequest
      WHERE emp_id = @emp_id
        AND status = 'Approved'
        AND request_id <> @request_id
        AND (
          @start_date BETWEEN start_date AND end_date
          OR
          @end_date BETWEEN start_date AND end_date
          OR
          start_date BETWEEN @start_date AND @end_date
        )
    )
      THROW 53003, 'Approved leave overlaps with an existing approved leave.', 1;

    -- Update status
    UPDATE dbo.LeaveRequest
    SET status = @decision
    WHERE request_id = @request_id;

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO
-------------------------------------------------procedure 5
CREATE OR ALTER PROCEDURE dbo.sp_BatchGenerateAttendance
  @start_date DATE,
  @end_date DATE,
  @dept_id INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  IF @end_date < @start_date
    THROW 54001, 'end_date must be >= start_date.', 1;

  DECLARE @d DATE = @start_date;

  WHILE @d <= @end_date
  BEGIN
    INSERT INTO dbo.Attendance(attendance_id, emp_id, work_date, status, check_in_time, check_out_time, notes_json)
    SELECT
      -- generate attendance_id safely based on current max
      (SELECT ISNULL(MAX(attendance_id), 0) FROM dbo.Attendance)
      + ROW_NUMBER() OVER (ORDER BY e.emp_id) AS attendance_id,
      e.emp_id,
      @d AS work_date,
      'Present' AS status,
      CAST('09:00' AS TIME) AS check_in_time,
      CAST('17:00' AS TIME) AS check_out_time,
      NULL AS notes_json
    FROM dbo.Employee e
    WHERE (@dept_id IS NULL OR e.dept_id = @dept_id)
      AND NOT EXISTS (
        SELECT 1 FROM dbo.Attendance a
        WHERE a.emp_id = e.emp_id AND a.work_date = @d
      );

    SET @d = DATEADD(DAY, 1, @d);
  END
END;
GO
--------------------------------------------procedure 6
CREATE OR ALTER PROCEDURE dbo.sp_HRReportingAndAIExport
  @mode VARCHAR(20),               -- 'DASHBOARD' or 'AI_DATASET'
  @cycle_id INT = NULL             -- optional filter for AI dataset
AS
BEGIN
  SET NOCOUNT ON;

  IF @mode NOT IN ('DASHBOARD', 'AI_DATASET')
    THROW 55001, 'mode must be DASHBOARD or AI_DATASET.', 1;

  /* =========================
     MODE 1: HR DASHBOARD REPORT
     ========================= */
  IF @mode = 'DASHBOARD'
  BEGIN
    SELECT
      e.emp_id,
      p.full_name,
      p.email,
      p.phone_number,
      d.dept_name,
      jp.title AS position_title,
      e.status,
      e.hire_date,
      mgrP.full_name AS manager_name
    FROM dbo.Employee e
    JOIN dbo.Person p ON p.person_id = e.emp_id
    JOIN dbo.Department d ON d.dept_id = e.dept_id
    JOIN dbo.JobPosition jp ON jp.position_id = e.position_id
    LEFT JOIN dbo.Employee mgrE ON mgrE.emp_id = e.manager_id
    LEFT JOIN dbo.Person mgrP ON mgrP.person_id = mgrE.emp_id
    ORDER BY d.dept_name, p.full_name;
    RETURN;
  END

  /* =========================
     MODE 2: AI DATASET EXPORT
     Clean formatted dataset for Spring AI sentiment
     ========================= */
  IF @mode = 'AI_DATASET'
  BEGIN
    SELECT
      pr.review_id,
      pr.emp_id,
      p.full_name,
      d.dept_name,
      jp.title AS position_title,
      rc.cycle_id,
      rc.cycle_name,
      pr.rating,
      pr.review_date,
      pr.feedback_text,
      pr.feedback_meta_json
    FROM dbo.PerformanceReview pr
    JOIN dbo.Employee e ON e.emp_id = pr.emp_id
    JOIN dbo.Person p ON p.person_id = e.emp_id
    JOIN dbo.Department d ON d.dept_id = e.dept_id
    JOIN dbo.JobPosition jp ON jp.position_id = e.position_id
    JOIN dbo.ReviewCycle rc ON rc.cycle_id = pr.cycle_id
    WHERE (@cycle_id IS NULL OR pr.cycle_id = @cycle_id)
    ORDER BY rc.start_date, d.dept_name, p.full_name;
    RETURN;
  END
END;
GO

USE HR_Enterprise_Project;
GO
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PerformanceReview'
ORDER BY ORDINAL_POSITION;
GO

USE HR_Enterprise_Project;
GO