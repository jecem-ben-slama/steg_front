// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String loginFailedError(Object error) {
    return 'Login Failed: $error';
  }

  @override
  String get unknownRole => 'Unknown user role. Logging out.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long.';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get deleteConfirmationContent =>
      'Are you sure you want to delete this internship? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get searchHint => 'Search by student, subject, supervisor, status...';

  @override
  String get statusLabel => 'Status';

  @override
  String get typeLabel => 'Type';

  @override
  String get all => 'All';

  @override
  String get validated => 'Validé';

  @override
  String get pending => 'En attente';

  @override
  String get rejected => 'Refusé';

  @override
  String get proposed => 'Proposé';

  @override
  String get pfa => 'PFA';

  @override
  String get pfe => 'PFE';

  @override
  String get ouvrierInternship => 'Stage Ouvrier';

  @override
  String get activeInternships => 'Active Internships';

  @override
  String get totalEncadrants => 'Total Supervisors';

  @override
  String get pendingEvaluations => 'Pending Evaluations';

  @override
  String errorLoadingStatistics(Object message) {
    return 'Error loading statistics: $message';
  }

  @override
  String get retryStats => 'Retry Stats';

  @override
  String get manageStudent => 'Manage Student';

  @override
  String get manageSubject => 'Manage Subject';

  @override
  String get manageSupervisor => 'Manage Supervisor';

  @override
  String get internships => 'Internships';

  @override
  String get addInternship => 'Add Internship';

  @override
  String get studentName => 'Student Name';

  @override
  String get subject => 'Subject';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get type => 'Type';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get na => 'N/A';

  @override
  String get internshipIdMissing => 'Internship ID is missing for deletion.';

  @override
  String get noMatchingInternships =>
      'No matching internships found for current filters.';

  @override
  String get noInternshipsFound => 'No internships found.';

  @override
  String get myProfile => 'My Profile';

  @override
  String get role => 'Role';

  @override
  String get username => 'Username';

  @override
  String get lastName => 'Last Name';

  @override
  String get pleaseEnterAUsername => 'Please enter a username';

  @override
  String get pleaseEnterALastName => 'Please enter a last name';

  @override
  String get pleaseEnterAnEmail => 'Please enter an email';

  @override
  String get enterAValidEmail => 'Enter a valid email';

  @override
  String get newPassword => 'New Password (leave blank to keep current)';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String errorLoadingInternships(Object message) {
    return 'Error loading internships: $message';
  }

  @override
  String get addNewInternship => 'Add New Internship';

  @override
  String get internshipType => 'Internship Type';

  @override
  String get pleaseSelectInternshipType => 'Please select an internship type.';

  @override
  String get pleaseEnterStartDate => 'Please enter start date.';

  @override
  String get pleaseEnterEndDate => 'Please enter end date.';

  @override
  String get isRemunerated => 'Is Remunerated?';

  @override
  String get remunerationAmount => 'Remuneration Amount';

  @override
  String get pleaseEnterRemunerationAmount =>
      'Please enter remuneration amount.';

  @override
  String get pleaseEnterAValidNumber => 'Please enter a valid number.';

  @override
  String get student => 'Student';

  @override
  String get pleaseSelectAStudent => 'Please select a student.';

  @override
  String errorLoadingStudents(Object message) {
    return 'Error loading students: $message';
  }

  @override
  String get pleaseSelectASupervisor => 'Please select a supervisor.';

  @override
  String errorLoadingSupervisors(Object message) {
    return 'Error loading supervisors: $message';
  }

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get pleaseSelectAllFields =>
      'Please select Internship Type, Student, and Supervisor.';

  @override
  String get endDateAfterStartDate => 'End Date cannot be before Start Date.';

  @override
  String get editInternship => 'Edit Internship';

  @override
  String get subjectTitle => 'Subject Title';

  @override
  String get noSupervisorsAvailable =>
      'No supervisors available. Cannot assign.';

  @override
  String get save => 'Save';

  @override
  String get noInternshipsForAttestation =>
      'No internships eligible for attestation yet.';

  @override
  String get period => 'Period';

  @override
  String get attestation => 'Attestation';

  @override
  String get payslip => 'Payslip';

  @override
  String get payslipGenerated => 'Payslip PDF generated!';

  @override
  String errorGeneratingPayslip(Object error) {
    return 'Error generating Payslip PDF: $error';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loadingAttestableInternships =>
      'Loading attestable internships...';

  @override
  String get attestationGenerated => 'Attestation PDF generated!';

  @override
  String errorGeneratingAttestation(Object error) {
    return 'Error generating Attestation PDF: $error';
  }

  @override
  String get manageStudents => 'Manage Students';

  @override
  String get pleaseFillRequiredFields => 'Please fill in all required fields.';

  @override
  String get confirmDeleteStudent =>
      'Are you sure you want to delete this Student?';

  @override
  String get addNewStudent => 'Add New Student';

  @override
  String get editStudent => 'Edit Student';

  @override
  String get hideForm => 'Hide Form';

  @override
  String get showForm => 'Show Form';

  @override
  String get firstName => 'First Name';

  @override
  String get lastNameCannotBeEmpty => 'Last Name cannot be empty.';

  @override
  String get emailCannotBeEmpty => 'Email cannot be empty.';

  @override
  String get cin => 'CIN';

  @override
  String get levelOfStudy => 'Level of Study';

  @override
  String get pleaseSelectLevelOfStudy => 'Please select a Level of Study.';

  @override
  String get faculty => 'Faculty';

  @override
  String get pleaseSelectFaculty => 'Please select a Faculty.';

  @override
  String get cycle => 'Cycle';

  @override
  String get pleaseSelectCycle => 'Please select a Cycle.';

  @override
  String get specialty => 'Specialty';

  @override
  String get pleaseSelectSpecialty => 'Please select a Specialty.';

  @override
  String get addStudent => 'Add Student';

  @override
  String get updateStudent => 'Update Student';

  @override
  String get existingStudents => 'Existing Students';

  @override
  String get searchStudents => 'Search Students';

  @override
  String get searchByNameEmailCin => 'Search by name, email, CIN...';

  @override
  String get noStudentsFound =>
      'No students found. Add one using the form above!';

  @override
  String noStudentsFoundMatching(Object query) {
    return 'No students found matching \"$query\".';
  }

  @override
  String get edit => 'Edit';

  @override
  String get noStudentsToDisplay => 'No students to display.';

  @override
  String get attestationDetails => 'Attestation Details';

  @override
  String get cti => 'CTI';

  @override
  String get selectAnOption => 'Select an option';

  @override
  String get manageSubjects => 'Manage Subjects';

  @override
  String get confirmDeleteSubject =>
      'Are you sure you want to delete this Subject?';

  @override
  String get addNewSubject => 'Add New Subject';

  @override
  String get subjectName => 'Subject Name';

  @override
  String get subjectNameCannotBeEmpty => 'Subject Name cannot be empty.';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get addSubject => 'Add Subject';

  @override
  String get updateSubject => 'Update Subject';

  @override
  String get existingSubjects => 'Existing Subjects';

  @override
  String get searchSubjects => 'Search subjects by name or description...';

  @override
  String noSubjectsFoundMatching(Object query) {
    return 'No subjects found matching \"$query\".';
  }

  @override
  String get noSubjectsFoundAddOne =>
      'No subjects found. Add one using the form above!';

  @override
  String get description => 'Description';

  @override
  String get startManagingSubjects =>
      'Start managing Subjects by adding one above.';

  @override
  String get manageSupervisors => 'Manage Supervisors';

  @override
  String get confirmDeleteUser => 'Are you sure you want to delete this user?';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get editUser => 'Edit User';

  @override
  String get firstNameCannotBeEmpty => 'First Name cannot be empty.';

  @override
  String get emailInvalid => 'Please enter a valid email address.';

  @override
  String get passwordRequiredForNewUsers =>
      'Password is required for new users.';

  @override
  String get addUser => 'Add User';

  @override
  String get updateUser => 'Update User';

  @override
  String get existingSupervisors => 'Existing Supervisors';

  @override
  String get searchSupervisors => 'Search supervisors by name or email...';

  @override
  String noSupervisorsFoundMatching(Object query) {
    return 'No supervisors found matching \"$query\".';
  }

  @override
  String get noSupervisorsFoundAddOne =>
      'No supervisors found. Add one using the form above!';

  @override
  String get startManagingUsers => 'Start managing users by adding one above.';

  @override
  String get internshipDistributions => 'Internship Distributions';

  @override
  String get internshipStatusDistribution => 'Internship Status Distribution';

  @override
  String get internshipTypeDistribution => 'Internship Type Distribution';

  @override
  String get internshipDurationDistribution =>
      'Internship Duration Distribution';

  @override
  String get encadrantWorkloadDistribution => 'Encadrant Workload Distribution';

  @override
  String get facultyInternshipSummary => 'Faculty Internship Summary';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get totalInternships => 'Total Internships';

  @override
  String get validatedInternships => 'Validated Internships';

  @override
  String get successRate => 'Success Rate';

  @override
  String get noFacultyInternshipSummary =>
      'No faculty internship summary data available.';

  @override
  String get subjectDistribution => 'Subject Distribution';

  @override
  String get loadingInternshipStatistics => 'Loading Internship Statistics...';

  @override
  String get noPendingInternshipsToReview =>
      'No pending internships to review.';

  @override
  String get noSubjectTitle => 'No Subject Title';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get remuneration => 'Remuneration';

  @override
  String get tnd => 'TND';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get chefPanel => 'Chef Panel';

  @override
  String get evaluationsPendingApproval => 'Evaluations Pending Your Approval';

  @override
  String get noEvaluationsPending =>
      'No evaluations currently require your validation.';

  @override
  String get internshipSubject => 'Internship Subject';

  @override
  String get encadrant => 'Encadrant';

  @override
  String get internshipStatus => 'Internship Status';

  @override
  String get encadrantEvaluation => 'Encadrant\'s Evaluation';

  @override
  String get evaluationDate => 'Evaluation Date';

  @override
  String get note => 'Note';

  @override
  String get comments => 'Comments';

  @override
  String get noCommentsProvided => 'No comments provided';

  @override
  String get validate => 'Validate';

  @override
  String get rejectEvaluation => 'Reject Evaluation';

  @override
  String get reasonForRejection => 'Reason for Rejection (Optional)';

  @override
  String failedToLoadEvaluations(Object message) {
    return 'Failed to load evaluations: $message';
  }

  @override
  String get allStaff => 'All Staff';

  @override
  String get gestionnaire => 'Gestionnaire';

  @override
  String get cannotDeleteUserWithoutId => 'Cannot delete user without an ID.';

  @override
  String noUsersFoundFor(Object query, Object role) {
    return 'No users found for \"$query\" in \"$role\".';
  }

  @override
  String noUsersFoundForRole(Object role) {
    return 'No $role users found.';
  }

  @override
  String get noUsersFoundAddOne =>
      'No users found. Add one using the form above!';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get addStaffUser => 'Add Staff User';

  @override
  String get updateStaffUser => 'Update Staff User';

  @override
  String get passwordRequiredForNewUser => 'Password is required for new user';

  @override
  String get pleaseSelectARole => 'Please select a role';

  @override
  String get addNewNote => 'Add New Note';

  @override
  String get noteContent => 'Note Content';

  @override
  String get enterYourNoteHere => 'Enter your note here...';

  @override
  String get pleaseEnterNoteContent => 'Please enter note content.';

  @override
  String get addNote => 'Add Note';

  @override
  String get assignSubject => 'Assign Subject';

  @override
  String get loadingSubjects => 'Loading subjects...';

  @override
  String get noSubjectsAvailable => 'No subjects available.';

  @override
  String get selectSubject => 'Select Subject';

  @override
  String errorLoadingSubjects(Object message) {
    return 'Error loading subjects: $message';
  }

  @override
  String get selectSubjectToAssign => 'Select a subject to assign.';

  @override
  String get noInternshipsAssigned => 'No internships assigned yet.';

  @override
  String get notAssigned => 'Not Assigned';

  @override
  String get assigningSubject => 'Assigning subject...';

  @override
  String get pleaseFetchInternships => 'Please fetch internships.';

  @override
  String get myAssignedInternshipsAndNotes => 'My Assigned Internships & Notes';

  @override
  String get internshipsAssignedToYou => 'Internships Assigned to You';

  @override
  String get noInternshipsAssignedToYou =>
      'No internships currently assigned to you.';

  @override
  String get notes => 'Notes';

  @override
  String get noNotesAdded => 'No notes added for this internship yet.';

  @override
  String get by => 'by';

  @override
  String get on => 'on';

  @override
  String errorLoadingNotes(Object message) {
    return 'Error loading notes: $message';
  }

  @override
  String evaluateInternship(Object id) {
    return 'Evaluate Internship ID: $id';
  }

  @override
  String get note0to10 => 'Note (0-10)';

  @override
  String get commentsOptional => 'Comments (Optional)';

  @override
  String get saveEvaluation => 'Save Evaluation';

  @override
  String get confirmUnvalidation => 'Confirm Unvalidation';

  @override
  String get unvalidationContent =>
      'Are you sure you want to mark this internship as \"Refused\"? This will set its status to \"Refusé\" and clear your evaluation.';

  @override
  String get confirm => 'Confirm';

  @override
  String get internshipsAwaitingFinalEvaluation =>
      'Internships Awaiting Your Final Evaluation';

  @override
  String get noFinishedInternships =>
      'No finished internships currently assigned to you.';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get yourEvaluation => 'Your Evaluation:';

  @override
  String get noComments => 'No comments';

  @override
  String get noEvaluationYet => 'No evaluation from you yet.';

  @override
  String get editEvaluation => 'Edit Evaluation';

  @override
  String get refuse => 'Refuse';

  @override
  String failedToLoadInternships(Object message) {
    return 'Failed to load internships: $message';
  }

  @override
  String get attestationOfInternship => 'Attestation of Internship';

  @override
  String get trainee => 'Trainee';

  @override
  String get traineeEmail => 'Trainee Email';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get evaluation => 'Evaluation';

  @override
  String get scanToVerifyAttestation => 'Scan to Verify Attestation:';

  @override
  String get attestationId => 'Attestation ID';

  @override
  String get createAttestationPdf => 'Create Attestation PDF';

  @override
  String get payslipTitle => 'Payslip';

  @override
  String get companyName => '[Your Company Name]';

  @override
  String get companyAddress => '[Your Company Address]';

  @override
  String get companyCityPostal => '[City, Postal Code]';

  @override
  String get employeeTrainee => 'Employee (Trainee)';

  @override
  String get name => 'Name';

  @override
  String get internshipDetails => 'Internship Details';

  @override
  String get remunerationDetails => 'Remuneration Details';

  @override
  String get grossAmount => 'Gross Amount';

  @override
  String get socialContributions => 'Social Contributions (Est.)';

  @override
  String get netPayableAmount => 'NET PAYABLE AMOUNT';

  @override
  String madeInCity(Object date) {
    return 'Made in [Your City], on $date';
  }

  @override
  String get employerSignature => 'Employer\'s Signature';

  @override
  String get directorName => '[Director/Manager Name]';

  @override
  String get titleFunction => '[Title/Function]';

  @override
  String get success => 'Oh hey!';

  @override
  String get failure => 'Oh Snap!';

  @override
  String get warning => 'Warning!';

  @override
  String get heyThere => 'Hey There!';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get certificates => 'Certificates';

  @override
  String get accountingAndFinance => 'Accounting and Finance';

  @override
  String get encadrantDashboard => 'Encadrant Dashboard';

  @override
  String get addNotes => 'Add Notes';

  @override
  String get evaluations => 'Evaluations';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get userManagement => 'User Management';

  @override
  String get validateEvaluations => 'Validate Evaluations';

  @override
  String get logOut => 'Log Out';
}
