--============================================================================================================
-- -------------1- login to sql server as Admin and Create the four roles in the database system==============
--============================================================================================================
-- Drop roles if they already exist (safe re-run)
If Exists (Select * From sys.database_principals Where name = 'SuperManagerRole')
    Drop Role SuperManagerRole;
If Exists (Select * From sys.database_principals Where name = 'ManagerRole')
    Drop Role BranchManagerRole;
If Exists (Select * From sys.database_principals Where name = 'InstructorRole')
    Drop Role InstructorRole;
If Exists (Select * From sys.database_principals Where name = 'StudentRole')
    Drop Role StudentRole;
Go

-- Create roles
Create Role SuperManagerRole;
Create Role BranchManagerRole;
Create Role InstructorRole;
Create Role StudentRole;
Go

--==============================================================================================================
-----------------2- Creating Stored procedure to add SuperManger and assign to SuperManagerRole-----------------
-----------------------That stored procedure can't be executed only by the Admin -------------------------------
--==============================================================================================================
Create Procedure addSuperManagerUser
    @UserName Nvarchar(100),@Password Nvarchar(100),@FName Nvarchar(50),@LName Nvarchar(50),
    @PhoneNumber Nvarchar(20),@Gender Nvarchar(10),@Email Nvarchar(100),@Address Nvarchar(255),
    @NationalID Varchar(14),@DateOfBirth Date,@Salary Decimal(10,2),@HireDate Date,@ExperienceYears Int
As
Begin
    Set Nocount On;

    Declare @NewUserID Int;
    Declare @sql Nvarchar(Max);

    -----------------------------
    -- 1. Create SQL Server login
    -----------------------------
    Set @sql = 'Create Login [' + @UserName + '] With Password = ''' + @Password + ''';';
    Exec(@sql);

    -- 2. Create database user mapped to login
    Set @sql = 'Create User [' + @UserName + '] For Login [' + @UserName + '];';
    Exec(@sql);

    -- 2b. Add user to SuperManagerRole
    Set @sql = 'Alter Role SuperManagerRole Add Member [' + @UserName + '];';
    Exec(@sql);

    -----------------------------
    -- 3. Insert into UserAccount (identity)
    -----------------------------
    Insert Into UserAccount (UserRole, UserName, Password)
    Values ('SuperManager', @UserName, Convert(Varchar(64), Hashbytes('Sha2_256', @Password), 2));

    Set @NewUserID = Scope_identity();

    -----------------------------
    -- 4. Insert into Person (PersonID = UserID)
    -----------------------------
    Insert Into Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    Values (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -----------------------------
    -- 5. Insert into Manager (ManagerID = PersonID = UserID)
    -----------------------------
    Insert Into Manager (ManagerID, Salary, HireDate, ExperienceYears, PersonID)
    Values (@NewUserID, @Salary, @HireDate, @ExperienceYears, @NewUserID);

    Print 'Super Manager user created successfully!';
End;
Go

--===========================================================================  
--  Ensure you login as admin to perform these operations  
--===========================================================================  
Select 
    System_User        As [Server_Login],
    Suser_Sname()      As [Session_Login],
    Current_User       As [Database_User],
    User_Name()        As [Database_User_From_ID];


--==================================================================================================
--=====================================SuperManager objects=========================================
--==================================================================================================


-- Function: GetCurrentManagerID  
-- Returns the ManagerID for the logged-in user or 1 for Admin/SuperManager  
--===========================================================================  
Create Or Alter Function dbo.GetCurrentManagerID()
Returns Int
As
Begin
    Declare @ManagerID Int;

    -- Get ManagerID based on logged-in SQL user
    Select @ManagerID = M.ManagerID
    From Manager M
    Join Person P On M.PersonID = P.PersonID
    Join UserAccount U On U.UserID = P.UserID
    Where U.UserName = Suser_Sname();

    -- Return 1 if user is Admin
    If Exists (
        Select 1
        From UserAccount U
        Where U.UserName = Suser_Sname()
          And U.UserID = 1
    )
        Return 1;

    -- Return 1 for special ManagerID = 2
    If @ManagerID = 2
        Return 1;

    -- Otherwise return actual ManagerID
    Return @ManagerID;
End;
Go  

--===========================================================================  
-- Procedure: addManagerUser  
-- Adds a new super manager or branch manager including login, user account, person, manager tables  
--===========================================================================  
Create Procedure addManagerUser
    @UserName Nvarchar(100), @Password Nvarchar(100), @FName Nvarchar(50), @LName Nvarchar(50),
    @PhoneNumber Nvarchar(20), @Gender Nvarchar(10), @Email Nvarchar(100), @Address Nvarchar(255),
    @NationalID Varchar(14), @DateOfBirth Date, @Salary Decimal(10,2), @HireDate Date, @ExperienceYears Int
As
Begin
    Set Nocount On;
    Declare @NewUserID Int;
    Declare @sql Nvarchar(Max);

    -- 1. Create SQL Server login
    Set @sql = 'Create Login [' + @UserName + '] With Password = ''' + @Password + ''';';
    Exec(@sql);

    -- 2. Create database user mapped to login
    Set @sql = 'Create User [' + @UserName + '] For Login [' + @UserName + '];';
    Exec(@sql);

    -- 2b. Add user to BranchManagerRole
    Set @sql = 'Alter Role BranchManagerRole Add Member [' + @UserName + '];';
    Exec(@sql);

    -- 3. Insert into UserAccount
    Insert Into UserAccount (UserRole, UserName, Password)
    Values ('Manager', @UserName, Convert(Varchar(64), Hashbytes('Sha2_256', @Password), 2));
    Set @NewUserID = Scope_identity();

    -- 4. Insert into Person table
    Insert Into Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    Values (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- 5. Insert into Manager table
    Insert Into Manager (ManagerID, Salary, HireDate, ExperienceYears, PersonID)
    Values (@NewUserID, @Salary, @HireDate, @ExperienceYears, @NewUserID);

    Print 'Super Manager user created successfully!';
End;
Go  

--===========================================================================  
-- Procedure: updateManagerUser  
-- Updates manager details, executed only by Admin or Super Manager  
--===========================================================================  
Create Or Alter Procedure updateManagerUser
    @ManagerID Int,
    @UserName Nvarchar(100) = Null,
    @Password Nvarchar(100) = Null,
    @FName Nvarchar(50) = Null,
    @LName Nvarchar(50) = Null,
    @PhoneNumber Nvarchar(20) = Null,
    @Gender Nvarchar(10) = Null,
    @Email Nvarchar(100) = Null,
    @Address Nvarchar(255) = Null,
    @NationalID Varchar(14) = Null,
    @DateOfBirth Date = Null,
    @Salary Decimal(10,2) = Null,
    @HireDate Date = Null,
    @ExperienceYears Int = Null
As
Begin
    Set Nocount On;

    -- 1. Update UserAccount table
    If @UserName Is Not Null
        Update UserAccount Set UserName = @UserName Where UserID = @ManagerID;
    If @Password Is Not Null
        Update UserAccount Set Password = Convert(Varchar(64), Hashbytes('SHA2_256', @Password), 2) Where UserID = @ManagerID;

    -- 2. Update Person table
    Update Person
    Set 
        FName = Coalesce(@FName, FName),
        LName = Coalesce(@LName, LName),
        PhoneNumber = Coalesce(@PhoneNumber, PhoneNumber),
        Gender = Coalesce(@Gender, Gender),
        Email = Coalesce(@Email, Email),
        Address = Coalesce(@Address, Address),
        NationalID = Coalesce(@NationalID, NationalID),
        DateOfBirth = Coalesce(@DateOfBirth, DateOfBirth)
    Where PersonID = @ManagerID;

    -- 3. Update Manager table
    Update Manager
    Set
        Salary = Coalesce(@Salary, Salary),
        HireDate = Coalesce(@HireDate, HireDate),
        ExperienceYears = Coalesce(@ExperienceYears, ExperienceYears)
    Where ManagerID = @ManagerID;

    Print 'Manager updated successfully!';
End;
Go  
--===========================================================================  
-- Procedure: addBranch  
-- Adds a new branch to the system  
--===========================================================================  
Create Or Alter Procedure addBranch
    @BranchID Int,
    @BranchName Nvarchar(100),
    @BranchAddress Nvarchar(255),
    @BranchEmail Nvarchar(100),
    @BranchPhone Nvarchar(20),
    @BranchManagerID Int
As
Begin
    Set Nocount On;

    -- Insert new branch into Branch table
    Insert Into Branch (BranchID, BranchName, BranchAddress, BranchEmail, BranchPhone, BranchManagerID)
    Values (@BranchID, @BranchName, @BranchAddress, @BranchEmail, @BranchPhone, @BranchManagerID);

    Print 'Branch added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateBranch  
-- Updates branch details, only Super Manager or assigned Branch Manager can update  
--===========================================================================  
Create Or Alter Procedure updateBranch
    @BranchID Int,
    @BranchName Nvarchar(100) = Null,
    @BranchAddress Nvarchar(255) = Null,
    @BranchEmail Nvarchar(100) = Null,
    @BranchPhone Nvarchar(20) = Null,
    @BranchManagerID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();
    Declare @BranchManagerID_DB Int;

    -- 1. Check if branch exists
    If Not Exists (Select 1 From dbo.Branch Where BranchID = @BranchID)
    Begin
        Raiserror('Branch with ID %d does not exist.', 16, 1, @BranchID);
        Return;
    End;

    -- 2. Get current branch manager
    Select @BranchManagerID_DB = BranchManagerID From dbo.Branch Where BranchID = @BranchID;

    -- 3. Authorization: Super Manager or assigned manager only
    If @CurrentManagerID <> 1 And @CurrentManagerID <> @BranchManagerID_DB
    Begin
        Raiserror('You are not authorized to update this branch.', 16, 1);
        Return;
    End;

    -- 4. Update branch details
    Update dbo.Branch
    Set
        BranchName      = Isnull(@BranchName, BranchName),
        BranchAddress   = Isnull(@BranchAddress, BranchAddress),
        BranchEmail     = Isnull(@BranchEmail, BranchEmail),
        BranchPhone     = Isnull(@BranchPhone, BranchPhone),
        BranchManagerID = Isnull(@BranchManagerID, BranchManagerID)
    Where BranchID = @BranchID;

    Print 'Branch updated successfully.';
End;
Go

--===========================================================================  
-- Procedure: addIntake  
-- Adds a new intake to the system  
--===========================================================================  
Create Or Alter Procedure addIntake
    @IntakeID Int,
    @IntakeName Nvarchar(100),
    @StartDate Date,
    @EndDate Date,
    @Year Int
As
Begin
    Set Nocount On;

    Insert Into Intake (IntakeID, IntakeName, StartDate, EndDate, Year)
    Values (@IntakeID, @IntakeName, @StartDate, @EndDate, @Year);

    Print 'Intake added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateIntake  
-- Updates existing intake details  
--===========================================================================  
Create Or Alter Procedure dbo.updateIntake
    @IntakeID Int,
    @IntakeName Nvarchar(100) = Null,
    @StartDate Date = Null,
    @EndDate Date = Null,
    @Year Int = Null
As
Begin
    Set Nocount On;

    -- 1. Check if intake exists
    If Not Exists (Select 1 From dbo.Intake Where IntakeID = @IntakeID)
    Begin
        Raiserror('Intake with ID %d does not exist.', 16, 1, @IntakeID);
        Return;
    End;

    -- 2. Update provided fields
    Update dbo.Intake
    Set
        IntakeName = Isnull(@IntakeName, IntakeName),
        StartDate  = Isnull(@StartDate, StartDate),
        EndDate    = Isnull(@EndDate, EndDate),
        Year       = Isnull(@Year, Year)
    Where IntakeID = @IntakeID;

    Print 'Intake updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: addDepartment  
-- Adds a new department  
--===========================================================================  
Create Or Alter Procedure addDepartment
    @DepartmentID Int,
    @DepartmentName Nvarchar(100)
As
Begin
    Set Nocount On;

    Insert Into Department (DepartmentID, DepartmentName)
    Values (@DepartmentID, @DepartmentName);

    Print 'Department created successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateDepartment  
-- Updates existing department name  
--===========================================================================  
Create Or Alter Procedure updateDepartment
    @DepartmentID Int,
    @DepartmentName Nvarchar(100)
As
Begin
    Set Nocount On;

    -- Check if department exists
    If Not Exists (Select 1 From dbo.Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- Update department name
    Update dbo.Department
    Set DepartmentName = @DepartmentName
    Where DepartmentID = @DepartmentID;

    Print 'Department updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: addTrack  
-- Adds a new track linked to a department  
--===========================================================================  
Create Or Alter Procedure addTrack
    @TrackID Int,
    @TrackName Nvarchar(50),
    @Description Nvarchar(255) = Null,
    @DepartmentID Int
As
Begin
    Set Nocount On;

    -- Validate department exists
    If Not Exists (Select 1 From Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- Insert new track
    Insert Into Track (TrackID, TrackName, Description, DepartmentID)
    Values (@TrackID, @TrackName, @Description, @DepartmentID);

    Print 'Track added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateTrack  
-- Updates track details  
--===========================================================================  
Create Or Alter Procedure updateTrack
    @TrackID Int,
    @TrackName Nvarchar(50) = Null,
    @Description Nvarchar(255) = Null,
    @DepartmentID Int = Null
As
Begin
    Set Nocount On;

    -- 1. Check if track exists
    If Not Exists (Select 1 From dbo.Track Where TrackID = @TrackID)
    Begin
        Raiserror('Track with ID %d does not exist.', 16, 1, @TrackID);
        Return;
    End;

    -- 2. Validate new DepartmentID if provided
    If @DepartmentID Is Not Null And Not Exists (Select 1 From dbo.Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- 3. Update track
    Update dbo.Track
    Set
        TrackName    = Isnull(@TrackName, TrackName),
        Description  = Isnull(@Description, Description),
        DepartmentID = Isnull(@DepartmentID, DepartmentID)
    Where TrackID = @TrackID;

    Print 'Track updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: deleteTrack  
-- Deletes a track if it is not assigned to any branch intake  
--===========================================================================  
Create Or Alter Procedure deleteTrack
    @TrackID Int
As
Begin
    Set Nocount On;

    -- Check if track exists
    If Not Exists (Select 1 From Track Where TrackID = @TrackID)
    Begin
        Raiserror('Track with ID %d does not exist.', 16, 1, @TrackID);
        Return;
    End;

    -- Check if track is used in BranchIntakeTrack
    If Exists (Select 1 From BranchIntakeTrack Where TrackID = @TrackID)
    Begin
        Raiserror('Cannot delete track. Track is currently assigned to branches.', 16, 1);
        Return;
    End;

    -- Delete track
    Delete From Track Where TrackID = @TrackID;

    Print 'Track deleted successfully!';
End;
Go
--===========================================================================  
-- View: v_StudentDetails  
-- Shows all students with branch, department, track, and intake info  
--===========================================================================  
Create Or Alter View dbo.v_StudentDetails
As
Select 
    S.StudentID,
    P.FName + ' ' + P.LName As StudentName,
    S.GPA,
    S.MaritalStatus,
    S.MilitaryStatus,
    S.Faculty,
    S.EnrollmentDate,
    S.GraduationYear,
    B.BranchName,
    D.DepartmentName,
    T.TrackName,
    I.IntakeName
From Student S
Join Person P On S.PersonID = P.PersonID
Join BranchIntakeTrack BIT On S.BIT_ID = BIT.BIT_ID
Join Branch B On BIT.BranchID = B.BranchID
Join Department D On BIT.DepartmentID = D.DepartmentID
Join Track T On BIT.TrackID = T.TrackID
Join Intake I On BIT.IntakeID = I.IntakeID;
Go

--===========================================================================  
-- Procedure: SearchStudents  
-- Search students dynamically by optional filters  
-- Accessible to Super Manager (all branches) or Branch Manager (own branch)  
--===========================================================================  
Create Or Alter Procedure dbo.SearchStudents
    @BranchID Int = Null,
    @DepartmentID Int = Null,
    @TrackID Int = Null,
    @IntakeID Int = Null,
    @StudentID Int = Null,
    @StudentName Nvarchar(100) = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    -- Super Manager can see all students
    If @CurrentManagerID = 1
    Begin
        Select *
        From v_StudentDetails
        Where (@BranchID Is Null Or BranchName = @BranchID)
          And (@DepartmentID Is Null Or DepartmentName = @DepartmentID)
          And (@TrackID Is Null Or TrackName = @TrackID)
          And (@IntakeID Is Null Or IntakeName = @IntakeID)
          And (@StudentID Is Null Or StudentID = @StudentID)
          And (@StudentName Is Null Or StudentName Like '%' + @StudentName + '%');
    End
    Else
    Begin
        -- Branch Manager: only students in own branch
        Select V.*
        From v_StudentDetails V
        Join Branch B On V.BranchName = B.BranchName
        Where B.BranchManagerID = @CurrentManagerID
          And (@DepartmentID Is Null Or V.DepartmentName = @DepartmentID)
          And (@TrackID Is Null Or V.TrackName = @TrackID)
          And (@IntakeID Is Null Or V.IntakeName = @IntakeID)
          And (@StudentID Is Null Or V.StudentID = @StudentID)
          And (@StudentName Is Null Or V.StudentName Like '%' + @StudentName + '%');
    End
End;
Go

--===========================================================================  
-- View: v_ManagerDetails  
-- Shows all managers with personal info and assigned branch  
--===========================================================================  
Create Or Alter View dbo.v_ManagerDetails
As
Select 
    M.ManagerID,
    P.FName + ' ' + P.LName As ManagerName,
    P.Email,
    P.PhoneNumber,
    M.Salary,
    M.HireDate,
    M.ExperienceYears,
    B.BranchID,
    B.BranchName
From Manager M
Join Person P On M.PersonID = P.PersonID
Join Branch B On B.BranchManagerID = M.ManagerID;
Go

--===========================================================================  
-- Procedure: SearchManagers  
-- Search managers dynamically by BranchID, ManagerID, or Name  
--===========================================================================  
Create Or Alter Procedure dbo.SearchManagers
    @BranchID Int = Null,
    @ManagerID Int = Null,
    @ManagerName Nvarchar(100) = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all managers
        Select *
        From v_ManagerDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@ManagerID Is Null Or ManagerID = @ManagerID)
          And (@ManagerName Is Null Or ManagerName Like '%' + @ManagerName + '%');
    End
    Else
    Begin
        -- Regular manager: see only own info
        Select *
        From v_ManagerDetails V
        Where V.ManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@ManagerID Is Null Or V.ManagerID = @ManagerID)
          And (@ManagerName Is Null Or V.ManagerName Like '%' + @ManagerName + '%');
    End
End;
Go

--===========================================================================  
-- View: v_InstructorDetails  
-- Shows all instructors with personal, branch, and department info  
--===========================================================================  
Create Or Alter View v_InstructorDetails
As
Select 
    I.InstructorID,
    P.FName + ' ' + P.LName As InstructorName,
    P.PhoneNumber,
    P.Email,
    P.Gender,
    P.DateOfBirth,
    D.DepartmentID,
    D.DepartmentName,
    B.BranchID,
    B.BranchName,
    I.HireDate,
    I.Salary,
    I.ExperienceYears
From Instructor I
Join Person P On I.PersonID = P.PersonID
Join Department D On I.DepartmentID = D.DepartmentID
Join Branch B On D.BranchID = B.BranchID;
Go

--===========================================================================  
-- Procedure: SearchInstructors  
-- Search instructors dynamically with optional filters  
--===========================================================================  
Create Or Alter Procedure dbo.SearchInstructors
    @BranchID Int = Null,
    @InstructorID Int = Null,
    @InstructorName Nvarchar(100) = Null,
    @DepartmentID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all instructors
        Select *
        From v_InstructorDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@InstructorID Is Null Or InstructorID = @InstructorID)
          And (@InstructorName Is Null Or InstructorName Like '%' + @InstructorName + '%')
          And (@DepartmentID Is Null Or DepartmentID = @DepartmentID);
    End
    Else
    Begin
        -- Regular manager: see only instructors in own branch
        Select V.*
        From v_InstructorDetails V
        Join Branch B On V.BranchID = B.BranchID
        Where B.BranchManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@InstructorID Is Null Or V.InstructorID = @InstructorID)
          And (@InstructorName Is Null Or V.InstructorName Like '%' + @InstructorName + '%')
          And (@DepartmentID Is Null Or V.DepartmentID = @DepartmentID);
    End
End;
Go

--===========================================================================  
-- View: v_AllBranchesDetails  
-- Shows all branches with related department, track, and intake info  
--===========================================================================  
Create Or Alter View v_AllBranchesDetails
As
Select 
    BIT.BIT_ID,
    B.BranchID,
    B.BranchName,
    B.BranchManagerID,
    D.DepartmentID,
    D.DepartmentName,
    T.TrackID,
    T.TrackName,
    I.IntakeID,
    I.IntakeName,
    I.StartDate,
    I.EndDate,
    I.Year
From BranchIntakeTrack BIT
Join Branch B On BIT.BranchID = B.BranchID
Join Track T On BIT.TrackID = T.TrackID
Join Department D On T.DepartmentID = D.DepartmentID
Join Intake I On BIT.IntakeID = I.IntakeID;
Go

--===========================================================================  
-- Procedure: SearchBranches  
-- Search branches dynamically with optional filters  
--===========================================================================  
Create Or Alter Procedure dbo.SearchBranches
    @BranchID Int = Null,
    @DepartmentID Int = Null,
    @TrackID Int = Null,
    @IntakeID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all branches
        Select *
        From v_AllBranchesDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@DepartmentID Is Null Or DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or TrackID = @TrackID)
          And (@IntakeID Is Null Or IntakeID = @IntakeID);
    End
    Else
    Begin
        -- Regular manager: see only own branch
        Select V.*
        From v_AllBranchesDetails V
        Join Branch B On V.BranchID = B.BranchID
        Where B.BranchManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@DepartmentID Is Null Or V.DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or V.TrackID = @TrackID)
          And (@IntakeID Is Null Or V.IntakeID = @IntakeID);
    End
End;
Go
--==================================================================================================
--=====================================BranchManager objects=========================================
--==================================================================================================


-- ==============================================
-- Add Track To Intake Procedure
-- This procedure links a Track to an Intake for the branch of the current manager
-- ==============================================
CREATE OR ALTER PROCEDURE dbo.AddTrackToIntake
    @IntakeID INT,
    @TrackID  INT
AS
BEGIN
    SET NOCOUNT ON;  -- Prevent extra messages from interfering

    -- Get current logged-in manager
    DECLARE @CurrentManagerID INT = dbo.GetCurrentManagerID();

    -- Get BranchID managed by current manager
    DECLARE @BranchID INT = (
        SELECT BranchID
        FROM dbo.Branch
        WHERE BranchManagerID = @CurrentManagerID
    );

    -- Raise error if manager manages no branch
    IF @BranchID IS NULL
    BEGIN
        RAISERROR('Current manager does not manage any branch.', 16, 1);
        RETURN;
    END

    -- Check if branch exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE BranchID = @BranchID)
    BEGIN
        RAISERROR('Branch %d does not exist.', 16, 1, @BranchID);
        RETURN;
    END

    -- Check if intake exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE IntakeID = @IntakeID)
    BEGIN
        RAISERROR('Intake %d does not exist.', 16, 1, @IntakeID);
        RETURN;
    END

    -- Check if track exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Track WHERE TrackID = @TrackID)
    BEGIN
        RAISERROR('Track %d does not exist.', 16, 1, @TrackID);
        RETURN;
    END

    -- Prevent duplicate branch-intake-track entries
    IF EXISTS (
        SELECT 1
        FROM dbo.BranchIntakeTrack
        WHERE BranchID = @BranchID
          AND IntakeID = @IntakeID
          AND TrackID  = @TrackID
    )
    BEGIN
        RAISERROR('This Branch-Intake-Track combination already exists.', 16, 1);
        RETURN;
    END

    -- Insert new branch-intake-track mapping
    INSERT INTO dbo.BranchIntakeTrack (BranchID, IntakeID, TrackID)
    VALUES (@BranchID, @IntakeID, @TrackID);

    PRINT 'Track added to intake successfully.';
END;
GO

-- ==============================================
-- Add Student Procedure
-- Manager can only add students to their own branch
-- ==============================================
CREATE OR ALTER PROCEDURE addStudentUser
    @UserName NVARCHAR(100),
    @Password NVARCHAR(100),
    @FName NVARCHAR(50),
    @LName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20),
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @NationalID VARCHAR(14),
    @DateOfBirth DATE,
    @MaritalStatus NVARCHAR(20),
    @GPA DECIMAL(4,2),
    @MilitaryStatus NVARCHAR(20),
    @Faculty NVARCHAR(100),
    @EnrollmentDate DATE,
    @GraduationYear INT,
    @BIT_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewUserID INT;
    DECLARE @CurrentManagerID INT;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @CurrentLogin SYSNAME = SUSER_SNAME();

    -- Get current manager ID 
    SET @CurrentManagerID =dbo.GetCurrentManagerID() in production

    -- Validate branch ownership for manager
    IF @CurrentManagerID IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM BranchIntakeTrack BIT
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE BIT.BIT_ID = @BIT_ID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only add students to your own branch.', 16, 1);
        RETURN;
    END

    -- Create login for student
    SET @sql = 'CREATE LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
    EXEC(@sql);

    -- Create user mapped to login
    SET @sql = 'CREATE USER [' + @UserName + '] FOR LOGIN [' + @UserName + '];';
    EXEC(@sql);

    -- Add user to StudentRole
    SET @sql = 'ALTER ROLE StudentRole ADD MEMBER [' + @UserName + '];';
    EXEC(@sql);

    -- Insert into UserAccount table
    INSERT INTO UserAccount (UserRole, UserName, Password)
    VALUES ('Student', @UserName, CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2));

    SET @NewUserID = SCOPE_IDENTITY();

    -- Insert into Person table
    INSERT INTO Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    VALUES (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- Insert into Student table
    INSERT INTO Student (StudentID, MaritalStatus, GPA, MilitaryStatus, Faculty, EnrollmentDate, GraduationYear, BIT_ID, PersonID)
    VALUES (@NewUserID, @MaritalStatus, @GPA, @MilitaryStatus, @Faculty, @EnrollmentDate, @GraduationYear, @BIT_ID, @NewUserID);

    PRINT 'Student user [' + @UserName + '] created successfully by ' + @CurrentLogin;
END;
GO

-- ==============================================
-- Delete Student Procedure
-- Manager can only delete students from their own branch
-- ==============================================
CREATE OR ALTER PROCEDURE deleteStudentUser
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    DECLARE @UserName NVARCHAR(100);
    DECLARE @PersonID INT;
    DECLARE @sql NVARCHAR(MAX);

    SET @CurrentManagerID = dbo.GetCurrentManagerID()

    -- Verify student exists
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        RAISERROR('Student %d does not exist.', 16, 1, @StudentID);
        RETURN;
    END

    -- Check branch ownership
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Student S
            JOIN BranchIntakeTrack BIT ON S.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE S.StudentID = @StudentID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only delete students from your own branch.', 16, 1);
        RETURN;
    END

    -- Get UserName and PersonID
    SELECT 
        @PersonID = P.PersonID,
        @UserName = U.UserName
    FROM Student S
    JOIN Person P ON S.PersonID = P.PersonID
    JOIN UserAccount U ON U.UserID = P.UserID
    WHERE S.StudentID = @StudentID;

    -- Delete Student, Person, UserAccount
    DELETE FROM Student WHERE StudentID = @StudentID;
    DELETE FROM Person WHERE PersonID = @PersonID;
    DELETE FROM UserAccount WHERE UserID = @PersonID;

    -- Drop DB user + login if exists
    IF @UserName IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP USER [' + @UserName + ']';
            EXEC(@sql);
        END;

        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP LOGIN [' + @UserName + ']';
            EXEC(@sql);
        END;
    END

    PRINT 'Student deleted successfully by ' + SUSER_SNAME();
END;
GO

-- ==============================================
-- Update Student Procedure
-- Manager can only update students from their branch
-- ==============================================
CREATE OR ALTER PROCEDURE updateStudentUser
    @StudentID INT,
    @FName NVARCHAR(50) = NULL,
    @LName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,
    @NationalID VARCHAR(14) = NULL,
    @DateOfBirth DATE = NULL,
    @MaritalStatus NVARCHAR(20) = NULL,
    @GPA DECIMAL(4,2) = NULL,
    @MilitaryStatus NVARCHAR(20) = NULL,
    @Faculty NVARCHAR(100) = NULL,
    @EnrollmentDate DATE = NULL,
    @GraduationYear INT = NULL,
    @BIT_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    SET @CurrentManagerID = dbo.GetCurrentManagerID()

    -- Verify student exists
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        RAISERROR('Student %d does not exist.', 16, 1, @StudentID);
        RETURN;
    END

    -- Check branch ownership
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Student S
            JOIN BranchIntakeTrack BIT ON S.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE S.StudentID = @StudentID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only update students from your branch.', 16, 1);
        RETURN;
    END

    -- Update Person table
    UPDATE Person
    SET FName       = ISNULL(@FName, FName),
        LName       = ISNULL(@LName, LName),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Gender      = ISNULL(@Gender, Gender),
        Email       = ISNULL(@Email, Email),
        Address     = ISNULL(@Address, Address),
        NationalID  = ISNULL(@NationalID, NationalID),
        DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth)
    WHERE PersonID = @StudentID;

    -- Update Student table
    UPDATE Student
    SET MaritalStatus   = ISNULL(@MaritalStatus, MaritalStatus),
        GPA             = ISNULL(@GPA, GPA),
        MilitaryStatus  = ISNULL(@MilitaryStatus, MilitaryStatus),
        Faculty         = ISNULL(@Faculty, Faculty),
        EnrollmentDate  = ISNULL(@EnrollmentDate, EnrollmentDate),
        GraduationYear  = ISNULL(@GraduationYear, GraduationYear),
        BIT_ID          = ISNULL(@BIT_ID, BIT_ID)
    WHERE StudentID = @StudentID;

    PRINT 'Student updated successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Add Instructor User
--==========================================================================================================
CREATE OR ALTER PROCEDURE AddInstructorUser
    @UserName NVARCHAR(100),
    @Password NVARCHAR(100),
    @FName NVARCHAR(50),
    @LName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20),
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @NationalID VARCHAR(14),
    @DateOfBirth DATE,
    @Salary DECIMAL(10,2),
    @HireDate DATE,
    @ExperienceYears INT,
    @DepartmentID INT,
    @BIT_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewUserID INT;
    DECLARE @CurrentManagerID INT;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @CurrentLogin SYSNAME = SUSER_SNAME();

    -- Get current manager id (hardcoded for now)
    SET @CurrentManagerID = dbo.GetCurrentManagerID();

    -- Validate branch ownership if current user is a manager
    IF @CurrentManagerID IS NOT NULL
       AND @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM BranchIntakeTrack BIT
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE BIT.BIT_ID = @BIT_ID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only add instructors to your own branch.', 16, 1);
        RETURN;
    END;

    -- 1. Create SQL Server login
    SET @sql = 'CREATE LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
    EXEC(@sql);

    -- 2. Create database user mapped to login
    SET @sql = 'CREATE USER [' + @UserName + '] FOR LOGIN [' + @UserName + '];';
    EXEC(@sql);

    -- 3. Add user to InstructorRole
    SET @sql = 'ALTER ROLE [InstructorRole] ADD MEMBER [' + @UserName + '];';
    EXEC(@sql);

    -- 4. Insert into UserAccount
    INSERT INTO UserAccount (UserRole, UserName, Password)
    VALUES ('Instructor', @UserName, CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2));

    SET @NewUserID = SCOPE_IDENTITY();

    -- 5. Insert into Person table
    INSERT INTO Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    VALUES (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- 6. Insert into Instructor table
    INSERT INTO Instructor (InstructorID, Salary, HireDate, ExperienceYears, DepartmentID, PersonID, BIT_ID)
    VALUES (@NewUserID, @Salary, @HireDate, @ExperienceYears, @DepartmentID, @NewUserID, @BIT_ID);

    PRINT 'Instructor user created and added to InstructorRole successfully by ' + @CurrentLogin;
END;
GO

-- ==========================================================================================================
-- Update Instructor User
--==========================================================================================================

CREATE OR ALTER PROCEDURE UpdateInstructorUser
    @InstructorID INT,
    @Salary DECIMAL(10,2) = NULL,
    @HireDate DATE = NULL,
    @ExperienceYears INT = NULL,
    @DepartmentID INT = NULL,
    @BIT_ID INT = NULL,
    @FName NVARCHAR(50) = NULL,
    @LName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,
    @NationalID NVARCHAR(14) = NULL,
    @DOB DATE = NULL,
    @UserName NVARCHAR(100) = NULL,
    @Password NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    SET @CurrentManagerID = dbo.GetCurrentManagerID();

    -- 1. Verify instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('Instructor %d does not exist.', 16, 1, @InstructorID);
        RETURN;
    END;

    -- 2. Check branch ownership if not admin
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Instructor I
            JOIN BranchIntakeTrack BIT ON I.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE I.InstructorID = @InstructorID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only update instructors from your branch.', 16, 1);
        RETURN;
    END;

    -- 3. Update Person table
    UPDATE Person
    SET FName       = ISNULL(@FName, FName),
        LName       = ISNULL(@LName, LName),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Gender      = ISNULL(@Gender, Gender),
        Email       = ISNULL(@Email, Email),
        Address     = ISNULL(@Address, Address),
        NationalID  = ISNULL(@NationalID, NationalID),
        DateOfBirth = ISNULL(@DOB, DateOfBirth)
    WHERE PersonID = @InstructorID;

    -- 4. Update Instructor table
    UPDATE Instructor
    SET Salary          = ISNULL(@Salary, Salary),
        HireDate        = ISNULL(@HireDate, HireDate),
        ExperienceYears = ISNULL(@ExperienceYears, ExperienceYears),
        DepartmentID    = ISNULL(@DepartmentID, DepartmentID),
        BIT_ID          = ISNULL(@BIT_ID, BIT_ID)
    WHERE InstructorID = @InstructorID;

    -- 5. Update UserAccount if needed
    IF @UserName IS NOT NULL OR @Password IS NOT NULL
    BEGIN
        UPDATE UserAccount
        SET UserName = ISNULL(@UserName, UserName),
            Password = ISNULL(
                CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2),
                Password
            )
        WHERE UserID = @InstructorID;

        -- Update SQL Server login if password provided
        IF @Password IS NOT NULL AND @UserName IS NOT NULL
        BEGIN
            DECLARE @sql NVARCHAR(MAX);
            SET @sql = 'ALTER LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
            EXEC(@sql);
        END
    END

    PRINT 'Instructor updated successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Delete Instructor User
--==========================================================================================================

CREATE OR ALTER PROCEDURE DeleteInstructorUser
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    DECLARE @UserName NVARCHAR(100);
    DECLARE @sql NVARCHAR(MAX);

    SET @CurrentManagerID = dbo.GetCurrentManagerID();

    -- 1. Verify instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('Instructor %d does not exist.', 16, 1, @InstructorID);
        RETURN;
    END

    -- 2. Check branch ownership if not admin
    IF @CurrentManagerID IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM Instructor I
            JOIN BranchIntakeTrack BIT ON I.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE I.InstructorID = @InstructorID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only delete instructors from your own branch.', 16, 1);
        RETURN;
    END

    -- 3. Get username from UserAccount
    SELECT @UserName = UserName
    FROM UserAccount
    WHERE UserID = @InstructorID;

    -- 4. Delete Instructor, Person, and UserAccount
    DELETE FROM Instructor WHERE InstructorID = @InstructorID;
    DELETE FROM Person WHERE PersonID = @InstructorID;
    DELETE FROM UserAccount WHERE UserID = @InstructorID;

    -- 5. Drop database user and login if exists
    IF @UserName IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP USER [' + @UserName + ']';
            EXEC(@sql);
        END;

        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP LOGIN [' + @UserName + ']';
            EXEC(@sql);
        END;
    END

    PRINT 'Instructor deleted successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Add Course To track
--==========================================================================================================

CREATE OR ALTER PROCEDURE AddCourse
    @CourseID INT,
    @CourseName NVARCHAR(50),
    @CourseDescription NVARCHAR(MAX) = NULL,
    @MinDegree DECIMAL(6,2),
    @MaxDegree DECIMAL(6,2),
    @CourseStatus NVARCHAR(20) = 'Active',
    @InstructorID INT = NULL,
    @TrackID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Course (CourseID, CourseName, CourseDescription, MinDegree, MaxDegree, CourseStatus, InstructorID, TrackID)
    VALUES (@CourseID, @CourseName, @CourseDescription, @MinDegree, @MaxDegree, @CourseStatus, @InstructorID, @TrackID);

    PRINT 'Course added successfully.';
END;
GO

-- ==========================================================================================================
-- Update Course
--==========================================================================================================

CREATE OR ALTER PROCEDURE UpdateCourse
    @CourseID INT,
    @CourseName NVARCHAR(50) = NULL,
    @CourseDescription NVARCHAR(MAX) = NULL,
    @MinDegree DECIMAL(6,2) = NULL,
    @MaxDegree DECIMAL(6,2) = NULL,
    @CourseStatus NVARCHAR(20) = NULL,
    @InstructorID INT = NULL,
    @TrackID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- Update course
    UPDATE Course
    SET CourseName = COALESCE(@CourseName, CourseName),
        CourseDescription = COALESCE(@CourseDescription, CourseDescription),
        MinDegree = COALESCE(@MinDegree, MinDegree),
        MaxDegree = COALESCE(@MaxDegree, MaxDegree),
        CourseStatus = COALESCE(@CourseStatus, CourseStatus),
        InstructorID = COALESCE(@InstructorID, InstructorID),
        TrackID = COALESCE(@TrackID, TrackID)
    WHERE CourseID = @CourseID;

    PRINT 'Course updated successfully.';
END;
GO

-- ==========================================================================================================
-- Delete Course
-- ==========================================================================================================
CREATE OR ALTER PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- Delete course
    DELETE FROM Course WHERE CourseID = @CourseID;

    PRINT 'Course deleted successfully.';
END;
GO

-- ==========================================================================================================
-- Assign Student to Course
-- ==========================================================================================================

CREATE OR ALTER PROCEDURE AssignStudentToCourse
    @CourseID INT,
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT = dbo.GetCurrentManagerID();
    DECLARE @StudentBITID INT;
    DECLARE @BITManagerID INT;

    -- 1. Check course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- 2. Get student's BIT_ID
    SELECT @StudentBITID = BIT_ID
    FROM Student
    WHERE StudentID = @StudentID;

    IF @StudentBITID IS NULL
    BEGIN
        RAISERROR('Student does not exist or does not have a BIT assigned.', 16, 1);
        RETURN;
    END

    -- 3. Get manager for student's BIT
    SELECT @BITManagerID = BranchManagerID
    FROM Branch B
    JOIN BranchIntakeTrack BIT ON B.BranchID = BIT.BranchID
    WHERE BIT.BIT_ID = @StudentBITID;

    -- 4. Check manager authority unless admin
    IF @CurrentManagerID IS NOT NULL
       AND @CurrentManagerID <> 1
       AND @CurrentManagerID <> @BITManagerID
    BEGIN
        RAISERROR('You can only assign students from your own branch.', 16, 1);
        RETURN;
    END

    -- 5. Check if already assigned
    IF EXISTS (SELECT 1 FROM StudentCourse WHERE StudentID = @StudentID AND CourseID = @CourseID)
    BEGIN
        RAISERROR('Student is already assigned to this course.', 16, 1);
        RETURN;
    END

    -- 6. Assign student to course
    INSERT INTO StudentCourse (StudentID, CourseID)
    VALUES (@StudentID, @CourseID);

    PRINT 'Student assigned to course successfully.';
END;
GO

-- ==========================================================================================================
-- Trigger: Prevent deletion of active course
-- ==========================================================================================================

CREATE OR ALTER TRIGGER trg_PreventDeleteActiveCourse
ON Course
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Prevent deleting active course
    IF EXISTS (SELECT 1 FROM deleted d WHERE d.IsActive = 1)
    BEGIN
        RAISERROR('You cannot delete an active course. Please deactivate it first.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Allow delete if course is inactive
    DELETE C
    FROM Course C
    JOIN deleted d ON C.CourseID = d.CourseID;
END;
GO
-- ==========================================================================================================
--========================================================Instructor objects=================================
--===========================================================================================================

-- =======================
-- Function to get current instructor ID
-- =======================
Create Or Alter Function dbo.GetCurrentInstructorID()
Returns Int
As
Begin
    Declare @InstructorID Int;

    Select @InstructorID = I.InstructorID
    From Instructor I
    Join Person P On I.PersonID = P.PersonID
    Join UserAccount U On P.UserID = U.UserID
    Where SUSER_SNAME() = U.UserName;

    Return @InstructorID;
End;
Go

-- =======================
-- Procedure to update an exam
-- =======================
Create Or Alter Procedure sp_updateExam
    @ExamID Int,
    @ExamType NVarChar(50) = Null,
    @Duration Int = Null,
    @No_Of_MCQ Int = Null,
    @No_Of_TextQ Int = Null,
    @No_Of_TFQ Int = Null,
    @MaxGrade Decimal(6,2) = Null,
    @AllowanceOptions NVarChar(100) = Null
As
Begin
    Declare @InstructorID Int = 21; -- Replace with dbo.GetCurrentInstructorID();
    
    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Exam Where ExamID = @ExamID And InstructorID = @InstructorID)
        Throw 51001, 'You are not allowed to update this exam.', 1;

    Update Exam
    Set ExamType = IsNull(@ExamType, ExamType),
        Duration = IsNull(@Duration, Duration),
        No_Of_MCQ = IsNull(@No_Of_MCQ, No_Of_MCQ),
        No_Of_TextQ = IsNull(@No_Of_TextQ, No_Of_TextQ),
        No_Of_TFQ = IsNull(@No_Of_TFQ, No_Of_TFQ),
        MaxGrade = IsNull(@MaxGrade, MaxGrade),
        AllowanceOptions = IsNull(@AllowanceOptions, AllowanceOptions)
    Where ExamID = @ExamID And InstructorID = @InstructorID;
End;
Go

-- Example execution
Exec sp_updateExam @ExamID = 2, @AllowanceOptions = 'Calculator not allowed';

-- =======================
-- Procedure to delete an exam
-- =======================
Create Or Alter Procedure sp_deleteExam
    @ExamID Int
As
Begin
    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Exam Where ExamID = @ExamID And InstructorID = @InstructorID)
        Throw 51002, 'You are not allowed to delete this exam.', 1;

    Delete From StudentExam Where ExamID = @ExamID;
    Delete From ExamQuestion Where ExamID = @ExamID;
    Delete From Exam Where ExamID = @ExamID And InstructorID = @InstructorID;
End;
Go

-- Example execution of add then delete
Exec sp_createExam 
    @ExamID = 3,
    @ExamType = 'Exam',
    @BIT_ID = 7,
    @Duration = 60,
    @No_Of_MCQ = 5,
    @No_Of_TextQ = 2,
    @No_Of_TFQ = 5,
    @MaxGrade = 100,
    @AllowanceOptions = 'Calculator Allowed',
    @CourseID = 101,
    @MinGrade = 50;

Exec sp_deleteExam 3;

-- =======================
-- Procedure to add MCQ question
-- =======================
Create Or Alter Procedure sp_addMCQQuestion
    @QuestionText NVarChar(Max),
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @CourseID Int,
    @Choice1 NVarChar(255),
    @Choice2 NVarChar(255),
    @Choice3 NVarChar(255),
    @Choice4 NVarChar(255),
    @CorrectChoice Char(1)
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID()
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('MCQ', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into Choices (QuestionID, ChoiceText, IsCorrect, ChoiceLetter)
    Values 
        (@QID, @Choice1, Case When @CorrectChoice = 'A' Then 1 Else 0 End, 'A'),
        (@QID, @Choice2, Case When @CorrectChoice = 'B' Then 1 Else 0 End, 'B'),
        (@QID, @Choice3, Case When @CorrectChoice = 'C' Then 1 Else 0 End, 'C'),
        (@QID, @Choice4, Case When @CorrectChoice = 'D' Then 1 Else 0 End, 'D');

    Print 'MCQ question added successfully.';
End;



-- =======================
-- Procedure to add True/False question
-- =======================
Create Or Alter Procedure sp_addTFQuestion
    @QuestionText NVarChar(Max),
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @CourseID Int,
    @CorrectChoice Char(1) = 'A' -- 'A' = True, 'B' = False
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('TF', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into Choices (QuestionID, ChoiceText, IsCorrect, ChoiceLetter)
    Values
        (@QID, 'True', Case When @CorrectChoice = 'A' Then 1 Else 0 End, 'A'),
        (@QID, 'False', Case When @CorrectChoice = 'B' Then 1 Else 0 End, 'B');

    Print 'TF question added successfully.';
End;
Go

-- =======================
-- Procedure to add Text question
-- =======================
Create Or Alter Procedure sp_addTextQuestion
    @QuestionText NVarChar(Max),
    @CourseID Int,
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @BestTextAnswer NVarChar(Max) = Null
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('Text', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into TextQuestion (QuestionID, BestTextAnswer)
    Values (@QID, @BestTextAnswer);

    Print 'Text question added successfully for the course by current instructor.';
End;
Go

-- =======================
-- Procedure to update a question
-- =======================
Create Or Alter Procedure sp_updateQuestion
    @QuestionID Int,
    @QuestionText NVarChar(Max) = Null,
    @DifficultyLevel VarChar(20) = Null,
    @QuestionMark Decimal(6,2) = Null,
    @CourseID Int = Null,
    @QuestionType NVarChar(50) = Null
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (
        Select 1 
        From Question Q
        Join Course C On Q.CourseID = C.CourseID
        Where Q.QuestionID = @QuestionID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to update this question.', 1;

    Update Question
    Set
        QuestionText = Coalesce(@QuestionText, QuestionText),
        DifficultyLevel = Coalesce(@DifficultyLevel, DifficultyLevel),
        QuestionMark = Coalesce(@QuestionMark, QuestionMark),
        CourseID = Coalesce(@CourseID, CourseID),
        QuestionType = Coalesce(@QuestionType, QuestionType)
    Where QuestionID = @QuestionID;

    Print 'Question updated successfully.';
End;
Go

-- =======================
-- Procedure to delete a question
-- =======================
Create Or Alter Procedure sp_deleteQuestion
    @QuestionID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (
        Select 1
        From Question Q
        Join Course C On Q.CourseID = C.CourseID
        Where Q.QuestionID = @QuestionID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to delete this question.', 1;

    Delete From Question
    Where QuestionID = @QuestionID;

    Print 'Question deleted successfully.';
End;
Go

-- =======================
-- Procedure to create random exam
-- =======================
Create Or Alter Procedure sp_createRandomExam
    @ExamID Int,
    @ExamType NVarChar(50),
    @BIT_ID Int,
    @Duration Int,
    @No_Of_MCQ Int,
    @No_Of_TextQ Int,
    @No_Of_TFQ Int,
    @MaxGrade Decimal(6,2),
    @AllowanceOptions NVarChar(100),
    @CourseID Int,
    @MinGrade Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to create exams for this course.', 1;

    Insert Into Exam (ExamID, ExamType, BIT_ID, Duration, No_Of_MCQ, No_Of_TextQ, No_Of_TFQ, MaxGrade, AllowanceOptions, InstructorID, CourseID, MinGrade)
    Values (@ExamID, @ExamType, @BIT_ID, @Duration, @No_Of_MCQ, @No_Of_TextQ, @No_Of_TFQ, @MaxGrade, @AllowanceOptions, @InstructorID, @CourseID, @MinGrade);

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_MCQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'MCQ'
    Order By NewID();

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_TextQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'Text'
    Order By NewID();

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_TFQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'TF'
    Order By NewID();

    Print 'Exam created successfully and questions assigned.';
End;
Go

-- =======================
-- Procedure to create manual exam
-- =======================
Create Or Alter Procedure sp_createManualExam
    @ExamID Int,
    @ExamType NVarChar(50),
    @BIT_ID Int,
    @Duration Int,
    @MaxGrade Decimal(6,2),
    @AllowanceOptions NVarChar(100),
    @CourseID Int,
    @MinGrade Int,
    @No_Of_MCQ Int,
    @No_Of_TextQ Int,
    @No_Of_TFQ Int,
    @QuestionIDs NVarChar(Max)
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to create exams for this course.', 1;

    Declare @QuestionTable Table (QuestionID Int);
    Insert Into @QuestionTable (QuestionID)
    Select Try_Cast(value As Int)
    From String_Split(@QuestionIDs, ',');

    If Exists (Select 1 From @QuestionTable qt Left Join Question q On qt.QuestionID = q.QuestionID Where q.QuestionID Is Null Or q.CourseID <> @CourseID)
        Throw 51001, 'One or more QuestionIDs do not exist or do not belong to this course.', 1;

    Insert Into Exam (ExamID, ExamType, BIT_ID, Duration, MaxGrade, AllowanceOptions, InstructorID, CourseID, MinGrade, No_Of_MCQ, No_Of_TextQ, No_Of_TFQ)
    Values (@ExamID, @ExamType, @BIT_ID, @Duration, @MaxGrade, @AllowanceOptions, @InstructorID, @CourseID, @MinGrade, @No_Of_MCQ, @No_Of_TextQ, @No_Of_TFQ);

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select @ExamID, QuestionID
    From @QuestionTable;

    Print 'Manual exam created successfully.';
End;
Go

-- =======================
-- Procedure to assign exam to students of a course
-- =======================
Create Or Alter Procedure sp_assignExamToCourseStudents
    @ExamID Int,
    @CourseID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to assign exams for this course.', 1;

    Insert Into StudentExam (StudentID, ExamID, AssignedDate)
    Select StudentID, @ExamID, GetDate()
    From Enrollment
    Where CourseID = @CourseID;

    Print 'Exam assigned to all students of the course successfully.';
End;
Go

-- =======================
-- Procedure to manually correct student exam
-- =======================
Create Or Alter Procedure sp_CorrectExamManually
    @ExamID Int,
    @StudentID Int,
    @QuestionID Int,
    @MarkGiven Decimal(6,2)
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If Not Exists (
        Select 1
        From Exam E
        Join Course C On E.CourseID = C.CourseID
        Where E.ExamID = @ExamID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to correct this exam.', 1;

    If Not Exists (Select 1 From ExamQuestion Where ExamID = @ExamID And QuestionID = @QuestionID)
        Throw 51001, 'Question does not belong to this exam.', 1;

    Update StudentAnswer
    Set MarkGiven = @MarkGiven
    Where ExamID = @ExamID And StudentID = @StudentID And QuestionID = @QuestionID;

    Print 'Question corrected manually successfully.';
End;
Go

-- =======================
-- Procedure to update total exam grade for a student
-- =======================
Create Or Alter Procedure sp_UpdateExamTotalGrade
    @ExamID Int,
    @StudentID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = 21;

    If Not Exists (
        Select 1
        From Exam E
        Join Course C On E.CourseID = C.CourseID
        Where E.ExamID = @ExamID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to update total grade for this exam.', 1;

    Declare @Total Decimal(6,2);

    Select @Total = Sum(Coalesce(MarkGiven,0))
    From StudentAnswer
    Where ExamID = @ExamID And StudentID = @StudentID;

    Update StudentExam
    Set TotalGrade = @Total
    Where ExamID = @ExamID And StudentID = @StudentID;

    Print 'Total exam grade updated successfully.';
End;
Go

-- =======================
-- View to show current instructor courses
-- =======================
Create Or Alter View vw_CurrentInstructorCourses
As
Select CourseID, CourseName, Credits, Department
From Course
Where InstructorID = GetCurrentInstructorID();
Go

-- =======================
-- Procedure to show current instructor questions
-- =======================
Create Or Alter Procedure sp_viewInstructorQuestions
    @CourseID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = GetCurrentInstructorID();

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to view questions for this course.', 1;

    Select Q.QuestionID, Q.QuestionType, Q.QuestionText, Q.DifficultyLevel, Q.QuestionMark
    From Question Q
    Where Q.CourseID = @CourseID
    Order By Q.QuestionID;
End;
Go
--=================================================================================================================================
--============================================================Student objects======================================================
--=================================================================================================================================
-- ===============================================
-- Function: GetCurrentStudentID
-- Purpose: Return the current logged-in student's ID based on SQL Server login
-- ===============================================
Create Or Alter Function dbo.GetCurrentStudentID()
Returns Int
As
Begin
    Declare @StudentID Int;

    -- Select the student ID by joining Student, Person, and UserAccount
    Select @StudentID = S.StudentID
    From Student S
    Join Person P On S.PersonID = P.PersonID
    Join UserAccount U On P.PersonID = U.UserID
    Where Suser_sname() = U.UserName;

    Return @StudentID;
End;
Go
-- ===============================================
-- View: vw_CurrentStudentExamQuestions
-- Purpose: Show all questions for the current student's exams including choices (aggregated)
-- ===============================================
Create Or Alter View dbo.vw_CurrentStudentExamQuestions
As
Select 
    Q.QuestionID,
    Q.QuestionText,
    Q.QuestionType,
    Q.QuestionMark,
    String_Agg(Cast(C.ChoiceText As Nvarchar(Max)), ' | ') As Choices
From StudentExam SE
Join Exam E 
    On SE.ExamID = E.ExamID
Join ExamQuestion EQ 
    On E.ExamID = EQ.ExamID
Join Question Q 
    On EQ.QuestionID = Q.QuestionID
Left Join Choices C 
    On Q.QuestionID = C.QuestionID
Where SE.StudentID = GetCurrentStudentID()                                     
Group By Q.QuestionID, Q.QuestionText, Q.QuestionType, Q.QuestionMark;
Go
-- ===============================================
-- Function: fn_CompareTextAnswer
-- Purpose: Compare a student's text answer with model answer and return 1 if ≥50% words match
-- ===============================================
Create Or Alter Function dbo.fn_CompareTextAnswer
(
    @QuestionID Int,
    @StudentQAnswer Nvarchar(Max)
)
Returns Bit
As
Begin
    Declare @ModelAnswer Nvarchar(Max);
    Declare @WordCount Int;
    Declare @MatchedWords Int;
    Declare @Result Bit = 0;

    -- Get the correct model answer
    Select @ModelAnswer = BestTextAnswer
    From TextQuestion
    Where QuestionID = @QuestionID;

    -- Return 0 if model answer or student answer is empty
    If @ModelAnswer Is Null Or Ltrim(Rtrim(@StudentQAnswer)) = ''
        Return 0;

    -- Count total words in the model answer
    Select @WordCount = Count(*)
    From String_Split(@ModelAnswer, ' ') 
    Where Ltrim(Rtrim(Value)) <> '';

    -- Count matched words (case-insensitive)
    Select @MatchedWords = Count(*)
    From String_Split(@ModelAnswer, ' ') As m
    Where Ltrim(Rtrim(m.Value)) <> ''
      And Exists (
          Select 1
          From String_Split(@StudentQAnswer, ' ') As s
          Where Lower(Ltrim(Rtrim(s.Value))) = Lower(Ltrim(Rtrim(m.Value)))
      );

    -- If ≥50% words match, mark as correct
    If @WordCount > 0 And @MatchedWords * 2 >= @WordCount
        Set @Result = 1;

    Return @Result;
End;
Go

-- ===============================================
-- Procedure: sp_StudentAnswerQuestion
-- Purpose: Submit an answer for a student for a specific question and grade it if MCQ/TF
-- ===============================================
Create Or Alter Procedure sp_StudentAnswerQuestion
    @QuestionID Int,
    @StudentQAnswer Nvarchar(Max)
As
Begin
    Set Nocount On;

    -- Get current student ID (can switch to dbo.GetCurrentStudentID())
    Declare @StudentID Int = 13;   
    If @StudentID Is Null
        Throw 51010, 'Current student not found.', 1;

    -- Get the ExamID assigned to this student for the question
    Declare @ExamID Int = (
        Select Top 1 SE.ExamID
        From StudentExam SE
        Inner Join ExamQuestion EQ On SE.ExamID = EQ.ExamID
        Where SE.StudentID = @StudentID
          And EQ.QuestionID = @QuestionID
    );

    If @ExamID Is Null
        Throw 51011, 'No assigned exam found for this question.', 1;

    -- Determine next sequence number for StudentExamQuestion
    Declare @NextSEQ Int;
    Select @NextSEQ = Isnull(Max(SEQ), 0) + 1
    From StudentExamQuestion;

    -- Get question type
    Declare @QType Nvarchar(50) = (Select QuestionType From Question Where QuestionID = @QuestionID);
    Declare @CorrectAnswer Nvarchar(Max);

    -- If question is MCQ or TF, check against correct choice
    If @QType In ('MCQ','TF')
    Begin
        Select @CorrectAnswer = ChoiceLetter 
        From Choices 
        Where QuestionID = @QuestionID And IsCorrect = 1;

        Insert Into StudentExamQuestion(SEQ, StudentID, ExamID, QuestionID, StudentQAnswer, AnswerIsValid, StudentQGrade)
        Values (
            @NextSEQ,
            @StudentID, 
            @ExamID, 
            @QuestionID, 
            @StudentQAnswer,
            Case When @StudentQAnswer = @CorrectAnswer Then 1 Else 0 End,
            Case When @StudentQAnswer = @CorrectAnswer 
                 Then (Select QuestionMark From Question Where QuestionID = @QuestionID) 
                 Else 0 End
        );
    End
    Else If @QType = 'Text'
    Begin
        -- For text questions, validate using fn_CompareTextAnswer
        Declare @IsValid Bit;
        Set @IsValid = dbo.fn_CompareTextAnswer(@QuestionID, @StudentQAnswer);

        Insert Into StudentExamQuestion(SEQ, StudentID, ExamID, QuestionID, StudentQAnswer, AnswerIsValid, StudentQGrade)
        Values (
            @NextSEQ,
            @StudentID,
            @ExamID,
            @QuestionID,
            @StudentQAnswer,
            @IsValid,
            Null
        );
    End
End;
Go
