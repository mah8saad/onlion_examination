-- =============================================================================
--=========================== SuperManager Permissions==========================
-- =============================================================================

/*==============================================================================
--================================CORE FUNCTION===============================
==============================================================================*/
Grant Execute On dbo.GetCurrentManagerID To SuperManagerRole;

/*==============================================================================
  VIEWS: SuperManager can Select; BranchManager cannot Select directly
==============================================================================*/
Grant Select On dbo.v_StudentDetails      To SuperManagerRole;
Grant Select On dbo.v_ManagerDetails      To SuperManagerRole;
Grant Select On dbo.v_InstructorDetails   To SuperManagerRole;
Grant Select On dbo.v_AllBranchesDetails  To SuperManagerRole;

/*==============================================================================
  ADMIN (SUPER) PROCEDURES — SuperManager only
==============================================================================*/
Grant Execute On dbo.addSuperManagerUser To SuperManagerRole;
Grant Execute On dbo.addManagerUser      To SuperManagerRole;
Grant Execute On dbo.updateManagerUser   To SuperManagerRole;

Grant Execute On dbo.addBranch           To SuperManagerRole;
Grant Execute On dbo.updateBranch        To SuperManagerRole;

Grant Execute On dbo.addIntake           To SuperManagerRole;
Grant Execute On dbo.updateIntake        To SuperManagerRole;

Grant Execute On dbo.addDepartment       To SuperManagerRole;
Grant Execute On dbo.updateDepartment    To SuperManagerRole;

Grant Execute On dbo.addTrack            To SuperManagerRole;
Grant Execute On dbo.updateTrack         To SuperManagerRole;
Grant Execute On dbo.deleteTrack         To SuperManagerRole;

/*==============================================================================
  SEARCH/REPORTING PROCEDURES — both roles can Execute
  (result sets are already filtered inside the procs by GetCurrentManagerID)
==============================================================================*/
Grant Execute On dbo.SearchStudents     To SuperManagerRole, BranchManagerRole;
Grant Execute On dbo.SearchManagers     To SuperManagerRole, BranchManagerRole;
Grant Execute On dbo.SearchInstructors  To SuperManagerRole, BranchManagerRole;
Grant Execute On dbo.SearchBranches     To SuperManagerRole, BranchManagerRole;

-- =============================================================================
--=========================== Manager Permissions===============================
-- =============================================================================
/*==============================================================================
  PERMISSIONS FOR BRANCH MANAGER & SUPER MANAGER
==============================================================================*/

/* ======================= FUNCTION ======================= */
GRANT EXECUTE ON dbo.GetCurrentManagerID TO SuperManagerRole, BranchManagerRole;

/* ======================= TRACKS ========================= */
GRANT EXECUTE ON dbo.AddTrackToIntake TO SuperManagerRole, BranchManagerRole;

/* ======================= STUDENTS ======================= */
GRANT EXECUTE ON dbo.addStudentUser     TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.updateStudentUser  TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.deleteStudentUser  TO SuperManagerRole, BranchManagerRole;

/* ======================= INSTRUCTORS ==================== */
GRANT EXECUTE ON dbo.addInstructorUser     TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.UpdateInstructorUser  TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.DeleteInstructorUser  TO SuperManagerRole, BranchManagerRole;

/* ======================= COURSES ======================== */
GRANT EXECUTE ON dbo.AddCourse    TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.UpdateCourse TO SuperManagerRole, BranchManagerRole;
GRANT EXECUTE ON dbo.DeleteCourse TO SuperManagerRole, BranchManagerRole;

/*==============================================================================
  SEARCH/REPORTING PROCEDURES — both roles can Execute
  (result sets are already filtered inside the procs by GetCurrentManagerID)
==============================================================================*/
Grant Execute On dbo.SearchStudents     To  BranchManagerRole;
Grant Execute On dbo.SearchManagers     To  BranchManagerRole;
Grant Execute On dbo.SearchInstructors  To  BranchManagerRole;
Grant Execute On dbo.SearchBranches     To  BranchManagerRole;

-- =============================================================================
--=========================== Instructor Permissions==========================
-- =============================================================================
-- Allow Instructor to execute Exam-related procedures
GRANT EXECUTE ON dbo.sp_createRandomExam           TO InstructorRole;   -- Create random exam
GRANT EXECUTE ON dbo.sp_createManualExam           TO InstructorRole;   -- Create manual exam
GRANT EXECUTE ON dbo.sp_updateExam                 TO InstructorRole;   -- Update exam details
GRANT EXECUTE ON dbo.sp_deleteExam                 TO InstructorRole;   -- Delete exam
GRANT EXECUTE ON dbo.sp_assignExamToCourseStudents TO InstructorRole;   -- Assign exam to course students

-- Allow Instructor to execute Question-related procedures
GRANT EXECUTE ON dbo.sp_addMCQQuestion             TO InstructorRole;   -- Add Multiple Choice Question
GRANT EXECUTE ON dbo.sp_addTFQuestion              TO InstructorRole;   -- Add True/False Question
GRANT EXECUTE ON dbo.sp_addTextQuestion            TO InstructorRole;   -- Add Text/Essay Question
GRANT EXECUTE ON dbo.sp_updateQuestion             TO InstructorRole;   -- Update an existing question
GRANT EXECUTE ON dbo.sp_deleteQuestion             TO InstructorRole;   -- Delete a question
GRANT EXECUTE ON dbo.sp_viewInstructorQuestions    TO InstructorRole;   -- View all questions created by the instructor

-- Allow Instructor to execute Student-Answer related procedures
GRANT EXECUTE ON dbo.sp_ViewStudentAnswers         TO InstructorRole;   -- View students’ answers
GRANT EXECUTE ON dbo.sp_CorrectExamManually        TO InstructorRole;   -- Manually correct student answers
GRANT EXECUTE ON dbo.sp_UpdateExamTotalGrade       TO InstructorRole;   -- Update total grade after corrections

-- Allow Instructor to view their courses
GRANT EXECUTE ON dbo.ShowCurrentInstructorCourses  TO InstructorRole;   -- Show courses taught by the current instructor

-- Allow Instructor to use the helper function
GRANT EXECUTE ON dbo.GetCurrentInstructorID        TO InstructorRole;   -- Retrieve the logged-in instructor’s ID


-- =============================================================================
--=========================== Student Permissions===============================
-- =============================================================================

-- Grant basic SELECT on Views
GRANT SELECT ON dbo.vw_CurrentStudentExamQuestions TO StudentRole;

-- Grant EXECUTE on Procedures & Functions
GRANT EXECUTE ON dbo.sp_StudentAnswerQuestion TO StudentRole;
GRANT EXECUTE ON dbo.fn_CompareTextAnswer TO StudentRole;
GRANT EXECUTE ON dbo.GetCurrentStudentID TO StudentRole;

