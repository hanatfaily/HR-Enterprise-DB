USE HR_Enterprise_Project;
GO


CREATE OR ALTER VIEW dbo.vw_HRDashboard
AS
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
LEFT JOIN dbo.Person mgrP ON mgrP.person_id = mgrE.emp_id;
GO


CREATE OR ALTER VIEW dbo.vw_PendingLeaveRequests
AS
SELECT
  lr.request_id,
  lr.emp_id,
  p.full_name,
  lt.type_name,
  lr.start_date,
  lr.end_date,
  dbo.fn_LeaveDays(lr.start_date, lr.end_date) AS requested_days,
  lr.status,
  lr.reason_text
FROM dbo.LeaveRequest lr
JOIN dbo.Employee e ON e.emp_id = lr.emp_id
JOIN dbo.Person p ON p.person_id = e.emp_id
JOIN dbo.LeaveType lt ON lt.type_id = lr.type_id
WHERE lr.status = 'Pending';
GO

 



CREATE OR ALTER VIEW dbo.vw_AIReadyReviews
AS
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
  dbo.fn_PreprocessTextForAI(pr.feedback_text) AS feedback_text_clean,
  pr.feedback_meta_json
FROM dbo.PerformanceReview pr
JOIN dbo.Employee e ON e.emp_id = pr.emp_id
JOIN dbo.Person p ON p.person_id = e.emp_id
JOIN dbo.Department d ON d.dept_id = e.dept_id
JOIN dbo.JobPosition jp ON jp.position_id = e.position_id
JOIN dbo.ReviewCycle rc ON rc.cycle_id = pr.cycle_id;
GO