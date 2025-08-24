-- =====================================================================
-- Create database with three filegroups
-- =====================================================================
CREATE DATABASE ITI_Project
ON PRIMARY
(
    NAME = ITI_PrimaryData, -- Default filegroup for small or core tables
    FILENAME = 'C:\ExaminationSystemProject\DatabaseFiles\ITI_PrimaryData.mdf',
    SIZE = 8MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
),
FILEGROUP FG_LargeTables --Stores large and frequently updated tables
(
    NAME = ITI_LargeTables,
    FILENAME = 'C:\ExaminationSystemProject\DatabaseFiles\ITI_LargeTables.ndf',
    SIZE = 20MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 20MB
),
FILEGROUP FG_Index  --Store non-clustered indexes 
(
    NAME = ITI_IndexData,
    FILENAME = 'C:\ExaminationSystemProject\DatabaseFiles\ITI_IndexData.ndf',
    SIZE = 20MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
)
LOG ON  --Transaction log	
(
    NAME = ITI_Log,
    FILENAME = 'C:\ExaminationSystemProject\DatabaseFiles\ITI_Log.ldf',
    SIZE = 20MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
);
GO

USE ITI_Project;
GO
