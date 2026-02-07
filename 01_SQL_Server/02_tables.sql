USE HR_Enterprise_Project;
GO

IF OBJECT_ID('dbo.Department','U') IS NULL
BEGIN
  CREATE TABLE dbo.Department(
    dept_id INT NOT NULL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE
);
END;
GO
IF OBJECT_ID('dbo.JobPosition', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.JobPosition(
    position_id INT NOT NULL PRIMARY KEY,
    title VARCHAR(100) NOT NULL UNIQUE
  );
END;
GO
IF OBJECT_ID('dbo.Person', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Person(
    person_id INT NOT NULL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone_number VARCHAR(30) NULL
);
END;
GO
IF OBJECT_ID('dbo.Employee','U') IS NULL
BEGIN
  CREATE TABLE dbo.Employee(
    emp_id INT NOT NULL PRIMARY KEY,
    hire_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    dept_id INT NOT NULL,
    position_id INT NOT NULL,
    manager_id INT NULL,

    CONSTRAINT fk_emp_person FOREIGN KEY (emp_id) REFERENCES dbo.Person(person_id),
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dbo.Department(dept_id),
    CONSTRAINT fk_emp_position FOREIGN KEY (position_id) REFERENCES dbo.JobPosition(position_id),
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT ck_emp_status CHECK (status IN ('Active', 'OnLeave', 'Terminated'))
);
END;
GO
IF OBJECT_ID('dbo.Contractor','U') IS NULL
BEGIN
  CREATE TABLE dbo.Contractor(
    contractor_id INT NOT NULL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    
    CONSTRAINT fk_contractor_person FOREIGN KEY (contractor_id) REFERENCES dbo.Person(person_id),
    CONSTRAINT ck_contractor_dates CHECK (end_date IS NULL OR end_date > start_date)
);
END;
GO

-- USE HR_Enterprise_Project;
-- GO
-- SELECT TABLE_NAME
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE TABLE_TYPE='BASE TABLE'
-- ORDER BY TABLE_NAME; ---To make sure tables exist :)

IF OBJECT_ID('dbo.Attendance', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Attendance(
    attendance_id INT NOT NULL PRIMARY KEY,
    emp_id INT NOT NULL,
    work_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    check_in_time TIME NULL,
    check_out_time TIME NULL,

    notes_json NVARCHAR(MAX) NULL,
    CONSTRAINT fk_att_emp FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT uq_att_emp_date UNIQUE (emp_id, work_date),
    CONSTRAINT ck_att_status CHECK (status IN ('Present', 'Absent', 'Remote', 'Late'))
);
END;
GO
IF OBJECT_ID('dbo.LeaveType', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.LeaveType(
    type_id INT NOT NULL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE
  );
END;
GO
IF OBJECT_ID('dbo.LeaveRequest', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.LeaveRequest(
    request_id INT NOT NULL PRIMARY KEY,
    emp_id INT NOT NULL,
    type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    reason_text NVARCHAR(500) NULL,
    
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT fk_leave_type FOREIGN KEY (type_id) REFERENCES dbo.LeaveType(type_id),
    CONSTRAINT ck_leave_status CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    CONSTRAINT ck_leave_dates CHECK (end_date >= start_date)
);
END;
GO

IF OBJECT_ID('dbo.ReviewCycle', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.ReviewCycle(
    cycle_id INT NOT NULL PRIMARY KEY,
    cycle_name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    CONSTRAINT ck_cycle_dates CHECK (end_date > start_date)
);
END;
GO
IF OBJECT_ID('dbo.PerformanceReview', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.PerformanceReview (
    review_id INT NOT NULL PRIMARY KEY,
    emp_id INT NOT NULL,
    cycle_id INT NOT NULL,
    rating INT NOT NULL,
    feedback_text NVARCHAR(1000) NULL,

    review_date DATE NULL,
    feedback_meta_json NVARCHAR(MAX) NULL,
    
    CONSTRAINT fk_rev_emp FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT fk_rev_cycle FOREIGN KEY (cycle_id) REFERENCES dbo.ReviewCycle(cycle_id),
    CONSTRAINT ck_review_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT uq_review_emp_cycle UNIQUE (emp_id, cycle_id)
);
END;
GO
IF OBJECT_ID('dbo.Skill', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Skill (
    skill_id INT NOT NULL PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE
  );
END;
GO


IF OBJECT_ID('dbo.EmployeeSkill', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.EmployeeSkill (
    emp_id INT NOT NULL,
    skill_id INT NOT NULL,
    skill_level VARCHAR(20) NOT NULL,
    last_updated DATE NOT NULL,

    CONSTRAINT pk_emp_skill PRIMARY KEY (emp_id, skill_id),
    CONSTRAINT fk_es_emp FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT fk_es_skill FOREIGN KEY (skill_id) REFERENCES dbo.Skill(skill_id),
    CONSTRAINT ck_skill_level CHECK (skill_level IN ('Beginner','Intermediate','Advanced'))
  );
END;
GO

IF OBJECT_ID('dbo.TrainingCourse', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.TrainingCourse(
    course_id INT NOT NULL PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    duration_hours INT NOT NULL
);
END;
GO

IF OBJECT_ID('dbo.EmployeeTraining', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.EmployeeTraining(
    emp_id INT NOT NULL,
    course_id INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    completion_date DATE NULL,
    
    CONSTRAINT pk_emp_training PRIMARY KEY (emp_id, course_id),
    CONSTRAINT fk_et_emp FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id),
    CONSTRAINT fk_et_course FOREIGN KEY (course_id) REFERENCES dbo.TrainingCourse(course_id),
    CONSTRAINT ck_training_status CHECK (status IN ('Enrolled', 'Completed', 'Dropped'))
);
END;
GO