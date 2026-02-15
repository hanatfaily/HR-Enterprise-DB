# HR Enterprise Management System (Database Project)

## 📌 Project Overview
This project is a full **HR Management Database System** designed for enterprise companies.  
It supports core HR operations such as employee management, attendance tracking, leave workflows, training assignments, performance reviews, and role-based access control.

The system was developed using **Microsoft SQL Server** and demonstrates advanced database concepts including procedures, triggers, views, indexing, RBAC, and Row-Level Security (RLS).

---

## 🎯 Main Features

### 👥 Employee & Organization Management
- Departments and job positions
- Employees linked to person records
- Manager hierarchy support

### ⏱ Attendance Tracking
- Daily attendance records
- Status options: Present, Absent, Remote, Late
- Time validation enforced with triggers

### 🏖 Leave Request Workflow
- Leave submission and approval system
- Prevents overlapping approved leaves
- Audit logging of leave status changes

### 📊 Performance Reviews
- Quarterly review cycles
- Ratings + textual feedback
- AI-ready preprocessing view for future sentiment analysis 

### 🎓 Training & Skills Management
- Employee training enrollment and completion tracking
- Skills profile with levels (Beginner → Advanced)

---

## 🔐 Security Implementation

### Role-Based Access Control (RBAC)
Roles implemented:
- `rl_admin`
- `rl_hr_analyst`
- `rl_manager`
- `rl_employee`
- `rl_ai_service` (future)

Permissions are granted based on job responsibility.

### Row-Level Security (RLS)
Employees can only view their own data (attendance, leave, training, skills, reviews).  
HR/Admin roles can access full datasets.

---

## 🗂 Database Components

### Tables
- Department, JobPosition, Person, Employee, Contractor  
- Attendance, LeaveRequest, LeaveType  
- ReviewCycle, PerformanceReview  
- Skill, EmployeeSkill  
- TrainingCourse, EmployeeTraining  

### Views
- `vw_HRDashboard` – complete employee HR overview  
- `vw_PendingLeaveRequests` – pending leave workflow  
- `vw_AIReadyReviews` – AI-ready performance review dataset  
- Employee self-service views:
  - `vw_MyAttendanceSummary`
  - `vw_MyPerformanceReviews`
  - `vw_MyAssignedTraining`
  - `vw_MySkillsProfile`

### Stored Procedures
- `sp_AddEmployee`
- `sp_RecordAttendance`
- `sp_SubmitLeaveRequest`
- `sp_DecideLeaveRequest`
- `sp_BatchGenerateAttendance`
- `sp_HRReportingAndAIExport`

### Triggers
- Leave status audit trigger
- Overlapping leave prevention trigger
- Attendance time validation trigger

### Functions
- Leave days calculator
- Overlap detection
- Employee tenure years
- Average performance rating
- AI text preprocessing helper

---

## 🧪 Demo Scenarios Supported
- Add employee → appears in dashboard  
- Employee submits leave → manager approves → audit logged  
- Overlapping leave approval blocked  
- Employee sees only their own records using RLS  
- HR analyst can view pending requests and reports  

---

## 🚀 Future Enhancements (Next Semester)
- AI integration for performance feedback sentiment analysis  - Subject to change so the AI take actions
- MongoDB integration for semi-structured HR notes  
- Advanced analytics dashboards  

