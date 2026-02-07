USE HR_Enterprise_Project;

GO

CREATE OR ALTER FUNCTION dbo.fn_LeaveDays(
    @start_date DATE,
    @end_date DATE
)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @start_date, @end_date) + 1;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_IsLeaveOverlapping(
    @emp_id INT,
    @start_date DATE,
    @end_date DATE,
    @exclude_request_id INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT=0;
    IF EXISTS (
        SELECT 1
        FROM dbo.LeaveRequest
        WHERE emp_id = @emp_id
          AND status = 'Approved'
          AND (@exclude_request_id IS NULL OR request_id <> @exclude_request_id)
          AND (
                @start_date BETWEEN start_date AND end_date
             OR @end_date BETWEEN start_date AND end_date
             OR start_date BETWEEN @start_date AND @end_date
          )
    )
       SET @result = 1;
    RETURN @result;

END;
GO

CREATE OR ALTER FUNCTION dbo.fn_EmployeeTenureYears(
    @emp_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @years INT;
    SELECT @years = DATEDIFF(YEAR, hire_date, GETDATE())
    FROM dbo.Employee
    WHERE emp_id = @emp_id;
    RETURN @years;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_AvgPerformanceRating(
    @emp_id INT
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @avg_rating DECIMAL(4,2);
    SELECT @avg_rating = AVG(CAST(rating AS DECIMAL(4,2)))
    FROM dbo.PerformanceReview
    WHERE emp_id = @emp_id;
    RETURN @avg_rating;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_PreprocessTextForAI(
    @input_text NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @input_text IS NULL
        RETURN NULL;
    
    RETURN LOWER(LTRIM(RTRIM(@input_text)));
END;
GO


