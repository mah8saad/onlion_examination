-- =====================================================================
-- Database: ITI_Project
-- Purpose : Training Management System Schema
-- =====================================================================
USE ITI_Project;
GO
-- =====================================================================
-- 1. UserAccount - Stores system login credentials
-- =====================================================================
CREATE TABLE UserAccount (
    UserID INT PRIMARY KEY IDENTITY(1,1),   -- Auto increment
    UserRole NVARCHAR(50) NOT NULL,                   -- Role (Admin, Instructor, etc.)
    UserName NVARCHAR(100) NOT NULL,                  -- Login username
    Password NVARCHAR(100) NOT NULL,               -- Hashed password
    CONSTRAINT UQ_UserAccount_UserName UNIQUE (UserName)  -- Unique constraint
)ON[PRIMARY];
GO
-- =====================================================================
-- 2. Person - Stores personal details for all users
-- =====================================================================
CREATE TABLE Person (
    PersonID INT PRIMARY KEY,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    PhoneNumber NVARCHAR(20),
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    NationalID VARCHAR(14),
    DateOfBirth DATE,
    UserID INT UNIQUE,                                -- One account per person
	FOREIGN KEY (UserID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 3. Department - Academic or administrative departments
-- =====================================================================
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(100)
)ON [PRIMARY];
GO
-- =====================================================================
-- 4. Manager - Special type of person with managerial role
-- =====================================================================
CREATE TABLE Manager (
    ManagerID INT PRIMARY KEY,
    Salary DECIMAL(10,2),
    HireDate DATE,
    ExperienceYears INT,
    PersonID INT UNIQUE,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
)ON [PRIMARY];
GO
-- =====================================================================
-- 5. Branch - Represents physical campus locations
-- =====================================================================
CREATE TABLE Branch (
    BranchID INT PRIMARY KEY,
    BranchName NVARCHAR(100),
    BranchAddress NVARCHAR(255),
    BranchEmail NVARCHAR(100),
    BranchPhone NVARCHAR(20),
    BranchManagerID INT UNIQUE,                       -- One manager per branch
    FOREIGN KEY (BranchManagerID) REFERENCES Manager(ManagerID) ON DELETE SET NULL
)ON [PRIMARY];
GO
-- =====================================================================
-- 6. Intake - Represents student intakes/batches
-- =====================================================================
CREATE TABLE Intake (
    IntakeID INT PRIMARY KEY,
    IntakeName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Year INT
)ON [PRIMARY];
GO
-- =====================================================================
-- 7. Track - Represents specialization tracks
-- =====================================================================
CREATE TABLE Track (
    TrackID INT PRIMARY KEY,
    TrackName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255),
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_Track_Department FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
);

-- =====================================================================
-- 8. BranchIntakeTrack - Links branch, intake, and track
-- =====================================================================
CREATE TABLE BranchIntakeTrack(
    BIT_ID INT PRIMARY KEY,
    BranchID INT,
    IntakeID INT,
    TrackID INT,
    UNIQUE (BranchID, IntakeID, TrackID),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON DELETE CASCADE,
    FOREIGN KEY (IntakeID) REFERENCES Intake(IntakeID) ON DELETE CASCADE,
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 9. Student - Academic records for students
-- =====================================================================
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    MaritalStatus NVARCHAR(20),
    GPA DECIMAL(4,2),
    MilitaryStatus NVARCHAR(20),
    Faculty NVARCHAR(100),
    EnrollmentDate DATE,
    GraduationYear INT,
    BIT_ID INT,
    PersonID INT UNIQUE,
    FOREIGN KEY (BIT_ID) REFERENCES BranchIntakeTrack(BIT_ID) ON DELETE CASCADE,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 10. Instructor - Teaching staff
-- =====================================================================
CREATE TABLE Instructor (
    InstructorID INT PRIMARY KEY,
    Salary DECIMAL(10,2),
    HireDate DATE,
    ExperienceYears INT,
    DepartmentID INT,
    PersonID INT UNIQUE,
    BIT_ID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID) ON DELETE SET NULL,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE,
    FOREIGN KEY (BIT_ID) REFERENCES BranchIntakeTrack(BIT_ID) ON DELETE SET NULL
)ON FG_LargeTables;
GO
-- =====================================================================
-- 11. Course - Academic courses
-- =====================================================================
CREATE TABLE Course (
    CourseID INT PRIMARY KEY,
    CourseName NVARCHAR(50),
    CourseDescription NVARCHAR(MAX),
    MinDegree DECIMAL(6,2),
    MaxDegree DECIMAL(6,2),
    CourseStatus NVARCHAR(20) DEFAULT 'Active',
    InstructorID INT,
	TrackID INT,
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID) ON DELETE SET NULL,
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID) ON DELETE SET NULL
)ON FG_LargeTables;
GO
-- =====================================================================
-- 12. StudentCourse - Links students to enrolled courses
-- =====================================================================
CREATE TABLE StudentCourse (
    StudentID INT,
    CourseID INT,
    StudGrade DECIMAL(6,2),
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 13. Exam - Exams assigned for courses
-- =====================================================================
CREATE TABLE Exam (
    ExamID INT PRIMARY KEY,
    ExamType NVARCHAR(50),
    BIT_ID INT,
    Duration INT,     -- Duration in minutes
    No_Of_MCQ INT,
    No_Of_TextQ INT,
    No_Of_TFQ INT,
    MaxGrade DECIMAL(6,2),
    AllowanceOptions NVARCHAR(100),
    InstructorID INT,
    CourseID INT,
    FOREIGN KEY (BIT_ID) REFERENCES BranchIntakeTrack(BIT_ID) ON DELETE CASCADE,
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID) ON DELETE SET NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 14. Question - Stores exam questions
-- =====================================================================
CREATE TABLE Question (
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    QuestionType NVARCHAR(50) NOT NULL,               -- MCQ, TF, Text
    QuestionText NVARCHAR(MAX) NOT NULL,
    DifficultyLevel VARCHAR(20) DEFAULT 'Medium',
    QuestionMark DECIMAL(6,2) NOT NULL,
    CourseID INT NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 15. Choices - Options for MCQ/TF questions
-- =====================================================================
CREATE TABLE Choices (
    ChoiceID INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID INT NOT NULL,
    ChoiceText NVARCHAR(255) NOT NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 16. TextQuestion - Model answers for text questions
-- =====================================================================
CREATE TABLE TextQuestion (
    QuestionID INT PRIMARY KEY,
    BestTextAnswer NVARCHAR(MAX) NULL,
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID) ON DELETE CASCADE
)ON FG_LargeTables;
GO
-- =====================================================================
-- 17. ExamQuestion - Links exams to their assigned questions
-- =====================================================================
CREATE TABLE ExamQuestion (
    ExamID INT,
    QuestionID INT,
    PRIMARY KEY (ExamID, QuestionID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
)ON FG_LargeTables;
GO
-- =====================================================================
-- 18. StudentExamQuestion - Stores student answers for each question
-- =====================================================================
CREATE TABLE StudentExamQuestion(
    SEQ INT PRIMARY KEY,
    StudentID INT,
    ExamID INT,
    QuestionID INT,
    StudentQAnswer NVARCHAR(MAX),
    UNIQUE (StudentID, ExamID, QuestionID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID) ON DELETE NO ACTION,
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID) ON DELETE NO ACTION,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE
)ON FG_LargeTables
GO
-- =====================================================================
--19. Table to store which students are assigned to which exam
-- =====================================================================
CREATE TABLE StudentExam (
    StudentExamID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    ExamDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    StudentGrade DECIMAL(5,2) NULL, -- percentage or score
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
    CONSTRAINT UQ_Student_Exam UNIQUE (StudentID, ExamID) -- ensures one exam per student
)ON FG_LargeTables;