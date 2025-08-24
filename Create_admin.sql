--------------------------------------
-- 1) Create login on the server (if not exists)
--------------------------------------
If Not Exists (Select 1 From sys.server_principals Where name = 'Admin')
Begin
    Create Login Admin 
    With Password = 'StrongPassword123';  -- Change password as needed
End
Go

--------------------------------------
-- 2) Map the login to ITI_Project database user
--------------------------------------
Use ITI_Project;
Go

If Not Exists (Select 1 From sys.database_principals Where name = 'Admin')
Begin
    Create User Admin For Login Admin;
End
Go

--------------------------------------
-- 3) Grant full permissions (db_owner role) for the admin
--------------------------------------
Alter Role db_owner Add Member Admin;
Go

--------------------------------------
-- 4) Add Admin account to UserAccount table
-- Assumes UserAccount has: UserName, Password, UserRole
--------------------------------------
Declare @Password NVARCHAR(100) = 'StrongPassword123';

If Not Exists (Select 1 From UserAccount Where UserName = 'Admin')
Begin
    Insert Into UserAccount (UserName, Password, UserRole)
    Values ('Admin', HashBytes('SHA2_256', @Password), 'Admin');
End
Go

--------------------------------------
-- Now you can log in with:
-- Username: Admin
-- Password: StrongPassword123
--------------------------------------
