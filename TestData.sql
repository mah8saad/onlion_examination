----------------------Follow the following Steps one by one to insert the data in your database Correctly------------------------------

/*=====================================================================================================================
--1)admin login to the sql server and use the ITI_Project database then he be able to 
--=======================================================================================================================
====>Execute the stored procedure called addSuperManagerUser which will have id=2*/

EXEC addSuperManagerUser
    @UserName = 'amrtalat', @Password = 'Password123',@FName = 'Amr',@LName = 'Talat',
    @PhoneNumber = '01234567890',@Gender = 'Male',@Email = 'amr.talat@example.com',
    @Address = '123 Cairo Street, Cairo, Egypt',@NationalID = '29807231234567',
    @DateOfBirth = '1980-07-23',@Salary = 25000.00,@HireDate = '2025-08-18', @ExperienceYears = 15;

/*--=====================================================================================================================
--2)SuperManger login to the sql server and use the ITI_Project database he will be able to :
--=======================================================================================================================
====> [1]- Execute the stored procedure called Add branch managers(create new managers for branches like Cairo, Alexandria, Assiut).*/
EXEC addManagerUser
    @UserName = 'ahmedOsman',@Password = 'SecurePass123',@FName = 'ahmed',@LName = 'Othman',
    @PhoneNumber = '01001234567',@Gender = 'Male',@Email = 'ahmed.alaaOthman@iti-minia.edu.eg',
    @Address = '28 Nile Corniche, minia, Egypt',@NationalID = '29805151234567',@DateOfBirth = '1985-05-15',
    @Salary = 22000.00,@HireDate = '2025-01-10', @ExperienceYears = 12;
	
-- Manager 2 (Alexandria Branch)
EXEC addManagerUser
    @UserName = 'sara_mahmoud',@Password = 'AlexBranch456',@FName = 'Sara',
    @LName = 'Mahmoud',@PhoneNumber = '01234567891',@Gender = 'Female',
    @Email = 'sara.mahmoud@iti-alex.edu.eg', @Address = '15 El-Gaish Road, Alexandria, Egypt',
    @NationalID = '29909081234567',@DateOfBirth = '1990-09-08',@Salary = 23000.00,
    @HireDate = '2024-11-15', @ExperienceYears = 8;

-- Manager 3 (Assiut Branch)
EXEC addManagerUser
    @UserName = 'ahmed_sayed',@Password = 'UpperEgypt789',@FName = 'Ahmed',
    @LName = 'Sayed',@PhoneNumber = '01098765432',@Gender = 'Male',@Email = 'ahmed.sayed@iti-assiut.edu.eg',
    @Address = '10 University Street, Assiut, Egypt',@NationalID = '29711121234567',@DateOfBirth = '1987-11-12',
    @Salary = 20000.00,@HireDate = '2025-03-20', @ExperienceYears = 10;

/*====>[2]- Execute the stored procedure called updateManagerUser which update his details or update any other branch manger details such as
    (login credentials, personal info, salary, hire date, experience).
--That stored procedure can takes only the paramters you want to update not all parameters*/

EXEC updateManagerUser @ManagerID = 2 @LName = 'Talat Harb',@Email = 'amr.talatHarb2025@Gmail.com'
EXEC updateManagerUser @ManagerID = 3 @FName = 'AhmedAlaa',
EXEC updateManagerUser @ManagerID = 4 @LName = 'Ali',@Email = 'sara.Ali@iti-alex.edu.eg'


/*====>[3]- Execute the stored procedure called addBranch to Add new ITI branch */

EXEC addBranch @BranchID = 100, @BranchName = 'miniaBranch',  @BranchAddress = '123 Cairo St', 
    @BranchEmail = 'minia@iti.com', @BranchPhone = '01000000001', @BranchManagerID = 3;

EXEC addBranch @BranchID = 101, @BranchName = 'AlexBranch', @BranchAddress = '456 Alex St', 
    @BranchEmail = 'alex@iti.com', @BranchPhone = '01000000002', @BranchManagerID = 4;

EXEC addBranch @BranchID = 102, @BranchName = 'AssiutBranch', @BranchAddress = '789 Assiut St', 
    @BranchEmail = 'assiut@iti.com', @BranchPhone = '01000000003',@BranchManagerID = 5;
	

/*====>[4]- Execute updateBranch Stored procedure to update details of ITI branch Branch 
--That Stored procedure can be ecexuted also by traditional manger to update their branch details
--That stored procedure can takes only the paramters you want to update not all parameters*/
*/
EXEC updateBranch @BranchID = 100,@BranchPhone = '0109911445566'
GO
EXEC updateBranch @BranchID = 101,@BranchEmail = 'Alexiti@gmail.com'

/*====>[5]- Execute addIntake Stored procedure to add new Intake */
EXEC addIntake 2023,'intake23', '2023-01-01', '2023-06-30', 2023;
GO
EXEC addIntake 2024,'intake24', '2024-01-01', '2024-06-30', 2024;
GO
EXEC addIntake 2025,'intake25', '2025-01-01', '2025-06-30', 2025;

/*====>[6]- Execute updateIntake Stored procedure to update existing Intake details */
EXEC updateIntake@IntakeID = 2023 ,@EndDate = '2023-08-15',

/*====>[7]- Execute addDepartment Stored procedure to add new department  */

-- Add Department 1: Information System
EXEC addDepartment@DepartmentID = 1, @DepartmentName = 'Information System';

-- Add Department 2: Artificial Intelligence
EXEC addDepartment @DepartmentID = 2, @DepartmentName = 'Artificial Intelligence';

-- Add Department 3: Software Engineering
EXEC addDepartment @DepartmentID = 3, @DepartmentName = 'Software Engineering';

/*====>[8]- Execute updateDepartment Stored procedure to update existing department  */
EXEC updateDepartment @DepartmentID = 2, @DepartmentName = 'AI & Machine Learning';

/*====>[8]- Execute addTrack Stored procedure to add new Track linked to specific department */

EXEC addTrack @TrackID = 1,@TrackName = 'Data Engineering',
    @Description = 'Big data processing, ETL pipelines, and data architecture design', @DepartmentID = 1;

EXEC addTrack @TrackID = 2,@TrackName = 'Data Science',
    @Description = 'AI algorithms, neural networks, and predictive modeling',@DepartmentID = 2;

EXEC addTrack @TrackID = 3,@TrackName = 'Cloud Computing',
    @Description = 'Cloud platforms, distributed systems, and scalable infrastructure solutions',@DepartmentID = 3;
	
/*====>[9]- Execute updateTrack Stored procedure to update an existing Track details */
EXEC updateTrack @TrackID = 1, @TrackName = 'Data Engineering And big data'

/*====>[10]- Execute deleteTrack Stored procedure to delete an existing Track */
--Example :Add new track and delete it
EXEC addTrack @TrackID = 4,@TrackName = '3D Prinnting',
    @Description = 'Creating 3d printer', @DepartmentID = 3;
GO
EXEC deleteTrack @TrackID = 4;

/*=====================================================================================================================
-- Search / Reporting procedures ( SuperManager)
--   Massive execution examples for SearchStudents, SearchManagers, SearchInstructors, SearchBranches
=====================================================================================================================*/

/*====>[A]- SearchStudents */
EXEC SearchStudents; -- all visible students
EXEC SearchStudents @BranchID = 2;
EXEC SearchStudents @StudentID = 101;
EXEC SearchStudents @StudentName = 'Ali';
EXEC SearchStudents @DepartmentID = 3, @TrackID = 8;
EXEC SearchStudents @BranchID = 1, @DepartmentID = 2, @TrackID = 6, @IntakeID = 2025;
EXEC SearchStudents @BranchID = 3, @StudentName = 'Mohamed';
EXEC SearchStudents @StudentID = 555, @DepartmentID = 10;

/*====>[B]- SearchManagers */
EXEC SearchManagers; -- all managers
EXEC SearchManagers @ManagerID = 2;
EXEC SearchManagers @ManagerName = 'Sara';
EXEC SearchManagers @BranchID = 101;
EXEC SearchManagers @BranchID = 102, @ManagerName = 'Ahmed';

/*====>[C]- SearchInstructors */
EXEC SearchInstructors; -- all instructors
EXEC SearchInstructors @InstructorID = 2001;
EXEC SearchInstructors @InstructorName = 'Hossam';
EXEC SearchInstructors @BranchID = 100;
EXEC SearchInstructors @DepartmentID = 2, @TrackID = 7;
EXEC SearchInstructors @BranchID = 101, @InstructorName = 'Fatma';

/*====>[D]- SearchBranches */
EXEC SearchBranches; -- all branches
EXEC SearchBranches @BranchID = 100;
EXEC SearchBranches @BranchName = 'AlexBranch';
EXEC SearchBranches @BranchID = 101, @BranchName = 'AlexBranch';

/*--=====================================================================================================================
--3)Any BranchManger login to the sql server and use the ITI_Project database he will be able to :
--=======================================================================================================================
====> [1]- Execute the stored procedure called AddTrackToIntake to open track in a specific intake in the current manger branch.*/
EXEC AddTrackToIntake  @IntakeID = 2023,@TrackID = 1   --minia -intake23- dataenginering
EXEC AddTrackToIntake  @IntakeID = 2023,@TrackID = 2   --minia -intake23 - Data Science
EXEC AddTrackToIntake  @IntakeID = 2023,@TrackID = 3   --minia -intake23 - Cloud Computing
EXEC AddTrackToIntake  @IntakeID = 2024,@TrackID = 1   --minia -intake24  dataenginering
EXEC AddTrackToIntake  @IntakeID = 2024,@TrackID = 2   --minia -intake24 Cloud Computing
EXEC AddTrackToIntake  @IntakeID = 2024,@TrackID = 3   --minia -intake24 Data Science
EXEC AddTrackToIntake  @IntakeID = 2025,@TrackID = 1   --minia -intake25  dataenginering   --the important one 
EXEC AddTrackToIntake  @IntakeID = 2025,@TrackID = 2   --minia -intake25 Cloud Computing
EXEC AddTrackToIntake  @IntakeID = 2025,@TrackID = 3   --minia -intake25 Data Science

--====> [2]- Execute the stored procedure called addStudentUser to add student to his current  branch.*/

EXEC addStudentUser 
    @UserName = 'ahmed@Alaa',@Password = 'Ahmed123',@FName = 'Ahmed',@LName = 'Alaa',
    @PhoneNumber = '0100000001',@Gender = 'Male',@Email = 'ahmed.alaa@email.com',
    @Address = 'Minia',@NationalID = '30000000000123',@DateOfBirth = '2000-01-01',
    @MaritalStatus = 'Single',@GPA = 3.50,@MilitaryStatus = 'Completed',@Faculty = 'Engineering',
    @EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 7;

EXEC addStudentUser 
    @UserName = 'davidNeil',@Password = 'P@ssw0rd2',@FName = 'David',@LName = 'Neil',
    @PhoneNumber = '0100000002',@Gender = 'Male',@Email = 'david.neil@email.com',
	@Address = 'Minia',@NationalID = '30000000000234',@DateOfBirth = '2000-02-02',
    @MaritalStatus = 'Single',@GPA = 3.40,@MilitaryStatus = 'Completed',
    @Faculty = 'Computer Science',@EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 7;

EXEC addStudentUser 
    @UserName = 'rehabRamadan',@Password = 'Rehab123',@FName = 'Rehab',@LName = 'Ramadan',
    @PhoneNumber = '0100000003',@Gender = 'Female',@Email = 'rehab.ramadan@email.com',
    @Address = 'Minia',@NationalID = '30000000000345',@DateOfBirth = '2000-03-03',
    @MaritalStatus = 'Single',@GPA = 3.30,@MilitaryStatus = 'Completed',
    @Faculty = 'Science',@EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 8;
	
	EXEC addStudentUser 
    @UserName = 'rawanElsayed',@Password = 'P@ssw0rd4',@FName = 'Rawan',@LName = 'Elsayed',
    @PhoneNumber = '0100000004',@Gender = 'Female',@Email = 'rawan.elsayed@email.com',
    @Address = 'Minia',@NationalID = '30000000000456',@DateOfBirth = '2000-04-04',
	@MaritalStatus = 'Married', @GPA = 3.20,@MilitaryStatus = 'Completed',
    @Faculty = 'Arts',@EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 8;

EXEC addStudentUser 
    @UserName = 'mahmoudSaad',@Password = 'P@ssw0rd5',@FName = 'Mahmoud',@LName = 'Saad',
    @PhoneNumber = '0100000005',@Gender = 'Male',@Email = 'mahmoud.saad@email.com',
    @Address = 'Minia',@NationalID = '30000000000567',@DateOfBirth = '2000-05-05',
    @MaritalStatus = 'Single',@GPA = 3.60,@MilitaryStatus = 'Completed',
    @Faculty = 'Commerce', @EnrollmentDate = '2018-09-01',@GraduationYear = 2022, @BIT_ID = 9;

EXEC addStudentUser 
    @UserName = 'aliAbdallah',@Password = 'Ali123',@FName = 'Ali',@LName = 'Abdallah',
    @PhoneNumber = '0100000006',@Gender = 'Male',@Email = 'ali.abdallah@email.com',
	@Address = 'Minia',@NationalID = '30000000000678',@DateOfBirth = '2000-06-06',
    @MaritalStatus = 'Single',@GPA = 3.70,@MilitaryStatus = 'Completed',
    @Faculty = 'Law',@EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 9;

--====> [3] --Execute the stored procedure called deleteStudentUser to delete student from his current branch.*/
--add student and delete him
EXEC addStudentUser 
    @UserName = 'saaaamy',@Password = 'P@ssw0rd6',@FName = 'tramb22',
    @LName = 'tramb22',@PhoneNumber = '0100000006',@Gender = 'Male',
    @Email = 'ali.abdallah@email.com',@Address = 'Minia',@NationalID = '30000000000678',
    @DateOfBirth = '2000-06-06',@MaritalStatus = 'Single',@GPA = 3.70,@MilitaryStatus = 'Completed',
    @Faculty = 'Law',@EnrollmentDate = '2018-09-01',@GraduationYear = 2022,@BIT_ID = 9;

EXEC deleteStudentUser @StudentID = 12;        --last userid

--====> [4] --Execute the stored procedure called updateStudentUser to update the details of a student in his branch.*/
EXEC updateStudentUser
    @StudentID = 11,
    @Email = 'Ali123.abdallah@email.com'

--====> [5] --Execute the stored procedure called addInstructorUser to update the details of a student in his branch.*/

EXEC addInstructorUser
    @UserName = 'inst_sara',@Password = 'SaraP@ss123',@FName = 'Sara',@LName = 'Ali',
    @PhoneNumber = '01098765432',@Gender = 'Female',@Email = 'sara.ali@univ.edu',
    @Address = 'Minya, Egypt',@NationalID = '30011223344556',@DateOfBirth = '1997-03-15',
    @Salary = 9500.00,@HireDate  = '2020-02-01',@ExperienceYears= 5,
    @DepartmentID = 1,  @BIT_ID  = 7;   -- Minya-intake2025-data engineering

EXEC addInstructorUser
    @UserName       = 'inst_yoman',@Password = 'YomanP@ss123',@FName = 'Yoman',
    @LName          = 'Hassan',@PhoneNumber    = '01055554444', @Gender  = 'Female',
    @Email          = 'yoman.hassan@univ.edu',@Address = 'Minya, Egypt',
    @NationalID     = '29922334455667',@DateOfBirth = '1985-11-20',@Salary = 11000.00,
    @HireDate       = '2018-07-01',@ExperienceYears= 8, @DepartmentID   = 1,   -- ✅ Department 1
    @BIT_ID         = 7;   -- Minya-intake2025-data engineering
	
--====> [6] --Execute the stored procedure called UpdateInstructorUser  to update the details od an instructor.*/

EXEC UpdateInstructorUser @InstructorID = 14, @PhoneNumber = '010000001010'  --new phone number

--====> [7] --Execute the stored procedure called DeleteInstructorUser  to delete an instructor from his branch.*/
--add instructor then delete
EXEC addInstructorUser
    @UserName       = 'inst_alaa',@Password = 'Alaa123',@FName = 'alaa',@LName = 'osama',
    @PhoneNumber    = '01055554444',@Gender = 'Male',@Email = 'alaa.osama@univ.edu',
    @Address        = 'Minya, Egypt',@NationalID     = '29922334455667',
    @DateOfBirth    = '1985-11-20',@Salary = 11000.00,@HireDate       = '2018-07-01',
    @ExperienceYears= 8, @DepartmentID   = 1, @BIT_ID = 7;  

--delete alaa
Exec DeleteInstructorUser 15
 
--====> [7] --Execute the stored procedure called AddCourse to add a new course to track in the current manger branch.*/

-- Add SQL
EXEC AddCourse
    @CourseID = 101,@CourseName = 'SQL',@CourseDescription = 'Database query language course',
    @MinDegree = 50,@MaxDegree = 100, @InstructorID = 13, @TrackID = 1;                       --make sure of @InstructorID

-- Add Python
EXEC AddCourse @CourseID = 102,@CourseName = 'Python',@CourseDescription = 'Python programming fundamentals',
    @MinDegree = 50,@MaxDegree = 100, @InstructorID = 13, @TrackID = 1;

-- Add Linux
EXEC AddCourse
    @CourseID = 103,@CourseName = 'Linux',@CourseDescription = 'Linux administration and shell basics',
    @MinDegree = 50,@MaxDegree = 100,@InstructorID = 13 ,@TrackID = 1;

--====> [7] --Execute the stored procedure called UpdateCourse to update the details of a course.*/

Exec UpdateCourse @CourseID = 101 , @CourseDescription = 'DATABASE QUERY language course'

--====> [8]--Execute the stored procedure called DeleteCourse to delete course.*/
--add the course then delete it
-- Add Linux
EXEC AddCourse
    @CourseID = 104,@CourseName = 'Linux',@CourseDescription = 'Linux administration and shell basics',
    @MinDegree = 50,@MaxDegree = 100,@InstructorID = 13 ,@TrackID = 1;

EXEC DeleteCourse 104

--====> [9]--Execute the stored procedure called assignStudentToCourse to assign student to a course.*/

Exec assignStudentToCourse 101 ,6
Exec assignStudentToCourse 101 ,7
Exec assignStudentToCourse 101 ,8
Exec assignStudentToCourse 101 ,9
Exec assignStudentToCourse 101 ,10
Exec assignStudentToCourse 101 ,11


/*=====================================================================================================================
-- [10] Search / Reporting procedures ( BranchManager)
--   Massive execution examples for SearchStudents, SearchManagers, SearchInstructors, SearchBranches
=====================================================================================================================*/
/*====>[A]- SearchStudents in the current manger branch*/
EXEC SearchStudents; -- all visible students in the current manger branch
EXEC SearchStudents @StudentID = 101;
EXEC SearchStudents @StudentName = 'Ali';
EXEC SearchStudents @DepartmentID = 3, @TrackID = 8;
EXEC SearchStudents @DepartmentID = 2, @TrackID = 6, @IntakeID = 2025;
EXEC SearchStudents @StudentName = 'Mohamed';
EXEC SearchStudents @StudentID = 555, @DepartmentID = 10;

/*====>[B]- current manger details */
EXEC SearchManagers; -- all managers

/*====>[C]- SearchInstructors  in the current manger branch*/
EXEC SearchInstructors; -- all instructors
EXEC SearchInstructors @InstructorID = 2001;
EXEC SearchInstructors @InstructorName = 'Hossam';
EXEC SearchInstructors @DepartmentID = 2, @TrackID = 7;
EXEC SearchInstructors @BranchID = 101, @InstructorName = 'Fatma';

/*====>[D]- SearchBranches current manger branch -intakes and tracks   */
EXEC SearchBranches; -- all branches
EXEC SearchBranches @BranchID = 100;

/*--=====================================================================================================================
--3)Any Instructor login to the sql server and use the ITI_Project database he will be able to :
--=======================================================================================================================*/
--====> [1]--Execute the stored procedure called sp_addMCQQuestion to add MCQ Question to specific course he teaches.*/

EXEC sp_addMCQQuestion
    @QuestionText = 'Which SQL command is used to remove a table permanently?',@CourseID = 101,@Choice1 = 'DELETE TABLE table_name;',
    @Choice2 = 'DROP TABLE table_name;',@Choice3 = 'REMOVE TABLE table_name;',@Choice4 = 'TRUNCATE TABLE table_name;',@CorrectChoice = 'B';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which keyword is used to sort results in SQL?',@CourseID = 101,@Choice1 = 'ORDER BY',
    @Choice2 = 'SORT BY',@Choice3 = 'GROUP BY',@Choice4 = 'HAVING',@CorrectChoice = 'A';
GO	
EXEC sp_addMCQQuestion
    @QuestionText = 'Which SQL function is used to count rows?',@CourseID = 101,@Choice1 = 'TOTAL()',
    @Choice2 = 'COUNT()',@Choice3 = 'SUM()',@Choice4 = 'ROWCOUNT()',@CorrectChoice = 'B';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which join returns all rows from both tables?',@CourseID = 101,@Choice1 = 'INNER JOIN',
    @Choice2 = 'LEFT JOIN',@Choice3 = 'RIGHT JOIN',@Choice4 = 'FULL OUTER JOIN',@CorrectChoice = 'D';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which normal form removes partial dependency?',@CourseID = 101,@Choice1 = '1NF',
    @Choice2 = '2NF',@Choice3 = '3NF',@Choice4 = 'BCNF',@CorrectChoice = 'B';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which SQL command is used to modify table structure?',@CourseID = 101,@Choice1 = 'ALTER TABLE',
    @Choice2 = 'UPDATE TABLE',@Choice3 = 'MODIFY TABLE',@Choice4 = 'CHANGE TABLE',@CorrectChoice = 'A';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which operator is used for pattern matching in SQL?',@CourseID = 101,@Choice1 = 'LIKE',
    @Choice2 = 'MATCH',@Choice3 = 'PATTERN',@Choice4 = 'REGEX',@CorrectChoice = 'A';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which constraint ensures unique values in a column?',@CourseID = 101, @Choice1 = 'PRIMARY KEY',
    @Choice2 = 'FOREIGN KEY',@Choice3 = 'UNIQUE',@Choice4 = 'CHECK',@CorrectChoice = 'C';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which SQL function returns the current system date?',
    @CourseID = 101,@Choice1 = 'NOW()',@Choice2 = 'GETDATE()',@Choice3 = 'CURRENT_DATE',
    @Choice4 = 'SYSDATE()',@CorrectChoice = 'B';
GO
EXEC sp_addMCQQuestion
    @QuestionText = 'Which SQL command is used to add a new column to a table?', @CourseID = 101,
    @Choice1 = 'ALTER TABLE ... ADD COLUMN ...',@Choice2 = 'UPDATE TABLE ... ADD COLUMN ...',@Choice3 = 'MODIFY TABLE ... ADD ...',
    @Choice4 = 'INSERT COLUMN ...',@CorrectChoice = 'A';
--===========================================================================================================================
--====> [2]--Execute the stored procedure called sp_addTFQuestion to add TF Question to specific course he teaches.*/
--===========================================================================================================================
EXEC sp_addTFQuestion @QuestionText = 'The UPDATE statement can modify multiple rows at once.',@CourseID = 101, @CorrectChoice = 'A';  -- True
GO
EXEC sp_addTFQuestion @QuestionText = 'The DELETE statement does not remove data from a table.',@CourseID = 101,@CorrectChoice = 'B';  -- False
GO
EXEC sp_addTFQuestion @QuestionText = 'A PRIMARY KEY column can contain NULL values.',@CourseID = 101, @CorrectChoice = 'B';  -- False
GO
EXEC sp_addTFQuestion @QuestionText = 'SQL is case-insensitive for keywords.', @CourseID = 101, @CorrectChoice = 'A';  -- True
GO
EXEC sp_addTFQuestion @QuestionText = 'The TRUNCATE TABLE command can be rolled back if inside a transaction.', @CourseID = 101, @CorrectChoice = 'B';  -- False
GO
EXEC sp_addTFQuestion @QuestionText = 'INNER JOIN returns only matching rows between tables.', @CourseID = 101, @CorrectChoice = 'A';  -- True
GO
EXEC sp_addTFQuestion @QuestionText = 'A foreign key must always reference a primary key in another table.', @CourseID = 101, @CorrectChoice = 'A';  -- True
GO
EXEC sp_addTFQuestion @QuestionText = 'The GROUP BY clause is used to filter rows before aggregation.', @CourseID = 101, @CorrectChoice = 'B';  -- False
GO
EXEC sp_addTFQuestion @QuestionText = 'The DISTINCT keyword removes duplicate rows from the result set.', @CourseID = 101, @CorrectChoice = 'A';  -- True
GO
EXEC sp_addTFQuestion @QuestionText = 'A table can have multiple primary keys.', @CourseID = 101, @CorrectChoice = 'B';  -- False
--===========================================================================================================================
--====> [3]--Execute the stored procedure called sp_addTextQuestion to add Text Question to specific course he teach.*/
--===========================================================================================================================
EXEC sp_addTextQuestion @QuestionText = 'Explain the difference between INNER JOIN and LEFT JOIN.', @CourseID = 101,
    @BestTextAnswer = 'INNER JOIN returns only matching rows, LEFT JOIN returns all rows from the left table and matching from the right.';
GO
EXEC sp_addTextQuestion @QuestionText = 'Describe the ACID properties in database transactions.', @CourseID = 101,
    @BestTextAnswer = 'ACID stands for Atomicity, Consistency, Isolation, Durability which ensures reliable transactions.';
GO
EXEC sp_addTextQuestion @QuestionText = 'What is the purpose of indexing in a database?', @CourseID = 101,
    @BestTextAnswer = 'Indexes improve query performance by allowing faster data retrieval but may slow down inserts/updates.';
GO
EXEC sp_addTextQuestion @QuestionText = 'Explain the difference between a primary key and a unique key.', @CourseID = 101,
    @BestTextAnswer = 'Primary key uniquely identifies rows and cannot be null, unique key also enforces uniqueness but allows nulls.';
GO
EXEC sp_addTextQuestion @QuestionText = 'What is normalization and why is it important?', @CourseID = 101,
    @BestTextAnswer = 'Normalization is organizing tables to reduce redundancy and improve data integrity.';
GO
EXEC sp_addTextQuestion @QuestionText = 'Explain the difference between clustered and non-clustered indexes.', @CourseID = 101,
    @BestTextAnswer = 'Clustered index determines the physical order of data, non-clustered index is a separate structure pointing to data.';
GO
EXEC sp_addTextQuestion
    @QuestionText = 'What is a stored procedure and its benefits?', @CourseID = 101,
    @BestTextAnswer = 'A stored procedure is a precompiled SQL block that improves performance, security, and code reusability.';
GO
EXEC sp_addTextQuestion @QuestionText = 'Explain the difference between DELETE, TRUNCATE, and DROP commands.', @CourseID = 101,
    @BestTextAnswer = 'DELETE removes rows, TRUNCATE removes all rows without logging each row, DROP deletes the table itself.';
GO
EXEC sp_addTextQuestion @QuestionText = 'What is the difference between a view and a table?', @CourseID = 101,
    @BestTextAnswer = 'A table stores data physically, a view is a virtual table representing the result of a query.';
GO
EXEC sp_addTextQuestion @QuestionText = 'Explain the difference between INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL OUTER JOIN.', @CourseID = 101,
    @BestTextAnswer = 'INNER JOIN returns matching rows, LEFT JOIN all left rows with matching right, RIGHT JOIN all right rows with matching left, FULL OUTER JOIN all rows from both tables.';
--===========================================================================================================================
--====> [4]--Execute the stored procedure called sp_updateQuestion to add update Question in a specific course he teaches.*/
--===========================================================================================================================
EXEC sp_updateQuestion @QuestionID = 1, @QuestionMark = 10,  @DifficultyLevel = 'Hard';
GO
EXEC sp_updateQuestion @QuestionID = 3,  @DifficultyLevel = 'Easy';
--===========================================================================================================================
--====> [5]--Execute the stored procedure called  sp_deleteQuestion to delete a question in a specific course he teaches.*/
--===========================================================================================================================
Exec sp_deleteQuestion 12

/*===========================================================================================================================
====> [6]--Execute the stored procedure called  sp_createRandomExam to generate an exam automatically/randomly 
in a specific course he teaches with specific structure.
--===========================================================================================================================*/
EXEC sp_createRandomExam
    @ExamID = 1001, @ExamType = 'Exam',
    @BIT_ID = 7, @Duration = 60,          -- minutes
    @No_Of_MCQ = 5,@No_Of_TextQ = 3,@No_Of_TFQ = 2,
    @MaxGrade = 100, @AllowanceOptions = 'None',
    @CourseID = 101,@MinGrade = 50;
GO
EXEC sp_createRandomExam
    @ExamID = 1002, @ExamType = 'Exam',
    @BIT_ID = 7,@Duration = 120,         -- minutes
    @No_Of_MCQ = 8,@No_Of_TextQ = 4,@No_Of_TFQ = 3,
    @MaxGrade = 150,@AllowanceOptions = 'Calculator Allowed',
    @CourseID = 101, @MinGrade = 60;

/*===========================================================================================================================
====> [7]--Execute the stored procedure called  sp_createManualExam to create an exam manuallyfor a specific course he teaches.
--===========================================================================================================================*/
EXEC sp_createManualExam
    @ExamID = 1003, @ExamType = 'Exam',@BIT_ID = 7,   --important
    @Duration = 90,@MaxGrade = 100,@AllowanceOptions = 'No Calculator',
    @CourseID = 101,@MinGrade = 50,@No_Of_MCQ = 3,@No_Of_TextQ = 2,@No_Of_TFQ = 2,
    @QuestionIDs = '2,3,4,5,6,7,8';  -- Comma-separated list of QuestionIDs
	
 Exec sp_updateExam
    @ExamID = 2,
    @AllowanceOptions = 'Calculator not allowed'
/*===========================================================================================================================
====> [8]--Execute the stored procedure called  sp_updateExam to update an exam a specific course he teaches.
--===========================================================================================================================*/
 Exec sp_updateExam @ExamID = 2, @AllowanceOptions = 'Calculator not allowed'
 
 /*===========================================================================================================================
====> [9]--Execute the stored procedure called  sp_deleteExam to delete an exam a specific course he teaches.
--===========================================================================================================================*/
--add course to be deleted later
EXEC sp_createExam 
    @ExamID = 3, @ExamType = 'Exam', @BIT_ID = 7,@Duration = 60,@No_Of_MCQ = 5,@No_Of_TextQ = 2,
    @No_Of_TFQ = 5,@MaxGrade = 100,@AllowanceOptions = 'Calculator Allowed',@CourseID = 101, @MinGrade = 50;

Exec sp_deleteExam 3

 /*===========================================================================================================================
====> [10]--Execute the stored procedure called  sp_assignExamToCourseStudents to assign an exam students in course he teaches.
--===========================================================================================================================*/
EXEC sp_assignExamToCourseStudents @ExamID = 1, @CourseID = 101, @ExamDate = '2025-09-01', 
     @StartTime = '09:00', @EndTime = '10:00';
	
 /*===========================================================================================================================
====> [11]--Execute the stored procedure called  sp_CorrectExamManually to correct text valid questions manually
--===========================================================================================================================*/
EXEC sp_CorrectExamManually @StudentID = 13, @ExamID = 1, @QuestionID = 22, @Grade = 8.00, @IsValid = 1;
 /*===========================================================================================================================
====> [12]--Execute the stored procedure called  sp_UpdateExamTotalGrade to update Exam total grade and course grade 
--===========================================================================================================================*/
EXEC sp_UpdateExamTotalGrade @StudentID = 6,@ExamID = 1
/*===================================================================================================================
====> [13]--Execute the stored procedure called  ShowCurrentInstructorCourses to show  current instructor course
=====================================================================================================================*/
EXEC ShowCurrentInstructorCourses
/*===================================================================================================================
====> [14]--Execute the stored procedure called sp_viewInstructorQuestions to show all questions for a course
 that is taught by the current instructor
=====================================================================================================================*/
Exec sp_viewInstructorQuestions 
Exec sp_viewInstructorQuestions @CourseID = 101
Exec sp_viewInstructorQuestions @CourseID = 101 , @DifficultyLevel = 'Easy'

--===============================================Views==================================================
--===>vw_StudentAnswers to view all students answers
Select * from vw_StudentAnswers

/*===================================================================================================================
====> [15]--Execute the stored procedure called sp_ViewStudentAnswers to view student answers based on different criteria 
 on a course which taught by the current instructor
=====================================================================================================================*/
-- Example 1: Instructor wants all MCQ answers for Exam 201
EXEC sp_ViewStudentAnswers @ExamID = 1, @QuestionType = 'MCQ';

-- Example 2: Instructor wants only Text answers for Student 13 in Course 101
EXEC sp_ViewStudentAnswers @StudentID = 6, @CourseID = 101, @QuestionType = 'Text';

-- Example 3: Instructor wants all answers (any type) in Exam 201
EXEC sp_ViewStudentAnswers @ExamID = 1;
/*--=====================================================================================================================
--5)Student login to the sql server and use the ITI_Project database he will be able to :
--=======================================================================================================================
/*===================================================================================================================
====> [1]--select from vw_CurrentStudentExamQuestions view  show exam questions for the current stident user
=====================================================================================================================*/
select*from  dbo.vw_CurrentStudentExamQuestions

/*===================================================================================================================
====> [2]-- Execute the stored procedure called sp_StudentAnswerQuestion to answer the given exam question
=====================================================================================================================*/
select*from  dbo.vw_CurrentStudentExamQuestions  
Exec sp_StudentAnswerQuestion 3 ,'A' 
Exec sp_StudentAnswerQuestion 17 ,'A' 
Exec sp_StudentAnswerQuestion 3 ,'A' 
Exec sp_StudentAnswerQuestion 3 ,'A' 

