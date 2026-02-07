USE HR_Enterprise_Project;
GO

-- Set CASCADE DELETE rules for bridge tables

-- EmployeeSkill.emp_id -> Employee.emp_id
IF OBJECT_ID('dbo.fk_es_emp','F') IS NOT NULL
  ALTER TABLE dbo.EmployeeSkill DROP CONSTRAINT fk_es_emp;
GO
ALTER TABLE dbo.EmployeeSkill
ADD CONSTRAINT fk_es_emp
FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id)
ON DELETE CASCADE;
GO

-- EmployeeSkill.skill_id -> Skill.skill_id
IF OBJECT_ID('dbo.fk_es_skill','F') IS NOT NULL
  ALTER TABLE dbo.EmployeeSkill DROP CONSTRAINT fk_es_skill;
GO
ALTER TABLE dbo.EmployeeSkill
ADD CONSTRAINT fk_es_skill
FOREIGN KEY (skill_id) REFERENCES dbo.Skill(skill_id)
ON DELETE CASCADE;
GO

-- EmployeeTraining.course_id -> TrainingCourse.course_id
IF OBJECT_ID('dbo.fk_et_course','F') IS NOT NULL
  ALTER TABLE dbo.EmployeeTraining DROP CONSTRAINT fk_et_course;
GO
ALTER TABLE dbo.EmployeeTraining
ADD CONSTRAINT fk_et_course
FOREIGN KEY (course_id) REFERENCES dbo.TrainingCourse(course_id)
ON DELETE CASCADE;
GO

-- EmployeeTraining.emp_id -> Employee.emp_id
IF OBJECT_ID('dbo.fk_et_emp','F') IS NOT NULL
  ALTER TABLE dbo.EmployeeTraining DROP CONSTRAINT fk_et_emp;
GO
ALTER TABLE dbo.EmployeeTraining
ADD CONSTRAINT fk_et_emp
FOREIGN KEY (emp_id) REFERENCES dbo.Employee(emp_id)
ON DELETE CASCADE;
GO