USE HR_Enterprise_Project;
GO

CREATE TABLE dbo.LeaveRequestAudit (
  audit_id INT IDENTITY(1,1) PRIMARY KEY,
  request_id INT NOT NULL,
  emp_id INT NOT NULL,
  old_status VARCHAR(20) NULL,
  new_status VARCHAR(20) NOT NULL,
  changed_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE OR ALTER TRIGGER dbo.trg_AuditLeaveStatusChange
ON dbo.LeaveRequest
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.LeaveRequestAudit (request_id, emp_id, old_status, new_status)
  SELECT
    i.request_id,
    i.emp_id,
    d.status AS old_status,
    i.status AS new_status
  FROM inserted i
  JOIN deleted d ON d.request_id = i.request_id
  WHERE ISNULL(i.status,'') <> ISNULL(d.status,'');
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_BlockOverlappingApprovedLeave
ON dbo.LeaveRequest
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  -- If any inserted/updated row is Approved, ensure it doesn't overlap another Approved leave
  IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN dbo.LeaveRequest lr
      ON lr.emp_id = i.emp_id
     AND lr.status = 'Approved'
     AND lr.request_id <> i.request_id
     AND i.status = 'Approved'
     AND (
          i.start_date BETWEEN lr.start_date AND lr.end_date
       OR i.end_date BETWEEN lr.start_date AND lr.end_date
       OR lr.start_date BETWEEN i.start_date AND i.end_date
     )
  )
  BEGIN
    ROLLBACK TRANSACTION;
    THROW 56001, 'Approved leave overlaps existing approved leave (blocked by trigger).', 1;
  END
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_AttendanceCheckTimes
ON dbo.Attendance
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  -- Present/Late must have check_in_time
  IF EXISTS (
    SELECT 1 FROM inserted
    WHERE status IN ('Present','Late') AND check_in_time IS NULL
  )
  BEGIN
    ROLLBACK TRANSACTION;
    THROW 56002, 'check_in_time is required for Present/Late.', 1;
  END

  -- check_out_time cannot be earlier than check_in_time
  IF EXISTS (
    SELECT 1 FROM inserted
    WHERE check_in_time IS NOT NULL
      AND check_out_time IS NOT NULL
      AND check_out_time < check_in_time
  )
  BEGIN
    ROLLBACK TRANSACTION;
    THROW 56003, 'check_out_time cannot be earlier than check_in_time.', 1;
  END
END;
GO
