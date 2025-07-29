import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginFailedError.
  ///
  /// In en, this message translates to:
  /// **'Login Failed: {error}'**
  String loginFailedError(Object error);

  /// No description provided for @unknownRole.
  ///
  /// In en, this message translates to:
  /// **'Unknown user role. Logging out.'**
  String get unknownRole;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordTooShort;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @deleteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this internship? This action cannot be undone.'**
  String get deleteConfirmationContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by student, subject, supervisor, status...'**
  String get searchHint;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @validated.
  ///
  /// In en, this message translates to:
  /// **'Validé'**
  String get validated;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Refusé'**
  String get rejected;

  /// No description provided for @proposed.
  ///
  /// In en, this message translates to:
  /// **'Proposé'**
  String get proposed;

  /// No description provided for @pfa.
  ///
  /// In en, this message translates to:
  /// **'PFA'**
  String get pfa;

  /// No description provided for @pfe.
  ///
  /// In en, this message translates to:
  /// **'PFE'**
  String get pfe;

  /// No description provided for @ouvrierInternship.
  ///
  /// In en, this message translates to:
  /// **'Stage Ouvrier'**
  String get ouvrierInternship;

  /// No description provided for @activeInternships.
  ///
  /// In en, this message translates to:
  /// **'Active Internships'**
  String get activeInternships;

  /// No description provided for @totalEncadrants.
  ///
  /// In en, this message translates to:
  /// **'Total Supervisors'**
  String get totalEncadrants;

  /// No description provided for @pendingEvaluations.
  ///
  /// In en, this message translates to:
  /// **'Pending Evaluations'**
  String get pendingEvaluations;

  /// No description provided for @errorLoadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {message}'**
  String errorLoadingStatistics(Object message);

  /// No description provided for @retryStats.
  ///
  /// In en, this message translates to:
  /// **'Retry Stats'**
  String get retryStats;

  /// No description provided for @manageStudent.
  ///
  /// In en, this message translates to:
  /// **'Manage Student'**
  String get manageStudent;

  /// No description provided for @manageSubject.
  ///
  /// In en, this message translates to:
  /// **'Manage Subject'**
  String get manageSubject;

  /// No description provided for @manageSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Manage Supervisor'**
  String get manageSupervisor;

  /// No description provided for @internships.
  ///
  /// In en, this message translates to:
  /// **'Internships'**
  String get internships;

  /// No description provided for @addInternship.
  ///
  /// In en, this message translates to:
  /// **'Add Internship'**
  String get addInternship;

  /// No description provided for @studentName.
  ///
  /// In en, this message translates to:
  /// **'Student Name'**
  String get studentName;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @internshipIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Internship ID is missing for deletion.'**
  String get internshipIdMissing;

  /// No description provided for @noMatchingInternships.
  ///
  /// In en, this message translates to:
  /// **'No matching internships found for current filters.'**
  String get noMatchingInternships;

  /// No description provided for @noInternshipsFound.
  ///
  /// In en, this message translates to:
  /// **'No internships found.'**
  String get noInternshipsFound;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @pleaseEnterAUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterAUsername;

  /// No description provided for @pleaseEnterALastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a last name'**
  String get pleaseEnterALastName;

  /// No description provided for @pleaseEnterAnEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterAnEmail;

  /// No description provided for @enterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterAValidEmail;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password (leave blank to keep current)'**
  String get newPassword;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @errorLoadingInternships.
  ///
  /// In en, this message translates to:
  /// **'Error loading internships: {message}'**
  String errorLoadingInternships(Object message);

  /// No description provided for @addNewInternship.
  ///
  /// In en, this message translates to:
  /// **'Add New Internship'**
  String get addNewInternship;

  /// No description provided for @internshipType.
  ///
  /// In en, this message translates to:
  /// **'Internship Type'**
  String get internshipType;

  /// No description provided for @pleaseSelectInternshipType.
  ///
  /// In en, this message translates to:
  /// **'Please select an internship type.'**
  String get pleaseSelectInternshipType;

  /// No description provided for @pleaseEnterStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter start date.'**
  String get pleaseEnterStartDate;

  /// No description provided for @pleaseEnterEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter end date.'**
  String get pleaseEnterEndDate;

  /// No description provided for @isRemunerated.
  ///
  /// In en, this message translates to:
  /// **'Is Remunerated?'**
  String get isRemunerated;

  /// No description provided for @remunerationAmount.
  ///
  /// In en, this message translates to:
  /// **'Remuneration Amount'**
  String get remunerationAmount;

  /// No description provided for @pleaseEnterRemunerationAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter remuneration amount.'**
  String get pleaseEnterRemunerationAmount;

  /// No description provided for @pleaseEnterAValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get pleaseEnterAValidNumber;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @pleaseSelectAStudent.
  ///
  /// In en, this message translates to:
  /// **'Please select a student.'**
  String get pleaseSelectAStudent;

  /// No description provided for @errorLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Error loading students: {message}'**
  String errorLoadingStudents(Object message);

  /// No description provided for @pleaseSelectASupervisor.
  ///
  /// In en, this message translates to:
  /// **'Please select a supervisor.'**
  String get pleaseSelectASupervisor;

  /// No description provided for @errorLoadingSupervisors.
  ///
  /// In en, this message translates to:
  /// **'Error loading supervisors: {message}'**
  String errorLoadingSupervisors(Object message);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @pleaseSelectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please select Internship Type, Student, and Supervisor.'**
  String get pleaseSelectAllFields;

  /// No description provided for @endDateAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End Date cannot be before Start Date.'**
  String get endDateAfterStartDate;

  /// No description provided for @editInternship.
  ///
  /// In en, this message translates to:
  /// **'Edit Internship'**
  String get editInternship;

  /// No description provided for @subjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject Title'**
  String get subjectTitle;

  /// No description provided for @noSupervisorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No supervisors available. Cannot assign.'**
  String get noSupervisorsAvailable;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noInternshipsForAttestation.
  ///
  /// In en, this message translates to:
  /// **'No internships eligible for attestation yet.'**
  String get noInternshipsForAttestation;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @attestation.
  ///
  /// In en, this message translates to:
  /// **'Attestation'**
  String get attestation;

  /// No description provided for @payslip.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payslip;

  /// No description provided for @payslipGenerated.
  ///
  /// In en, this message translates to:
  /// **'Payslip PDF generated!'**
  String get payslipGenerated;

  /// No description provided for @errorGeneratingPayslip.
  ///
  /// In en, this message translates to:
  /// **'Error generating Payslip PDF: {error}'**
  String errorGeneratingPayslip(Object error);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @loadingAttestableInternships.
  ///
  /// In en, this message translates to:
  /// **'Loading attestable internships...'**
  String get loadingAttestableInternships;

  /// No description provided for @attestationGenerated.
  ///
  /// In en, this message translates to:
  /// **'Attestation PDF generated!'**
  String get attestationGenerated;

  /// No description provided for @errorGeneratingAttestation.
  ///
  /// In en, this message translates to:
  /// **'Error generating Attestation PDF: {error}'**
  String errorGeneratingAttestation(Object error);

  /// No description provided for @manageStudents.
  ///
  /// In en, this message translates to:
  /// **'Manage Students'**
  String get manageStudents;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get pleaseFillRequiredFields;

  /// No description provided for @confirmDeleteStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Student?'**
  String get confirmDeleteStudent;

  /// No description provided for @addNewStudent.
  ///
  /// In en, this message translates to:
  /// **'Add New Student'**
  String get addNewStudent;

  /// No description provided for @editStudent.
  ///
  /// In en, this message translates to:
  /// **'Edit Student'**
  String get editStudent;

  /// No description provided for @hideForm.
  ///
  /// In en, this message translates to:
  /// **'Hide Form'**
  String get hideForm;

  /// No description provided for @showForm.
  ///
  /// In en, this message translates to:
  /// **'Show Form'**
  String get showForm;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Last Name cannot be empty.'**
  String get lastNameCannotBeEmpty;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty.'**
  String get emailCannotBeEmpty;

  /// No description provided for @cin.
  ///
  /// In en, this message translates to:
  /// **'CIN'**
  String get cin;

  /// No description provided for @levelOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Level of Study'**
  String get levelOfStudy;

  /// No description provided for @pleaseSelectLevelOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Please select a Level of Study.'**
  String get pleaseSelectLevelOfStudy;

  /// No description provided for @faculty.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get faculty;

  /// No description provided for @pleaseSelectFaculty.
  ///
  /// In en, this message translates to:
  /// **'Please select a Faculty.'**
  String get pleaseSelectFaculty;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @pleaseSelectCycle.
  ///
  /// In en, this message translates to:
  /// **'Please select a Cycle.'**
  String get pleaseSelectCycle;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @pleaseSelectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Please select a Specialty.'**
  String get pleaseSelectSpecialty;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudent;

  /// No description provided for @updateStudent.
  ///
  /// In en, this message translates to:
  /// **'Update Student'**
  String get updateStudent;

  /// No description provided for @existingStudents.
  ///
  /// In en, this message translates to:
  /// **'Existing Students'**
  String get existingStudents;

  /// No description provided for @searchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search Students'**
  String get searchStudents;

  /// No description provided for @searchByNameEmailCin.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, CIN...'**
  String get searchByNameEmailCin;

  /// No description provided for @noStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No students found. Add one using the form above!'**
  String get noStudentsFound;

  /// No description provided for @noStudentsFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No students found matching \"{query}\".'**
  String noStudentsFoundMatching(Object query);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noStudentsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No students to display.'**
  String get noStudentsToDisplay;

  /// No description provided for @attestationDetails.
  ///
  /// In en, this message translates to:
  /// **'Attestation Details'**
  String get attestationDetails;

  /// No description provided for @cti.
  ///
  /// In en, this message translates to:
  /// **'CTI'**
  String get cti;

  /// No description provided for @selectAnOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectAnOption;

  /// No description provided for @manageSubjects.
  ///
  /// In en, this message translates to:
  /// **'Manage Subjects'**
  String get manageSubjects;

  /// No description provided for @confirmDeleteSubject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Subject?'**
  String get confirmDeleteSubject;

  /// No description provided for @addNewSubject.
  ///
  /// In en, this message translates to:
  /// **'Add New Subject'**
  String get addNewSubject;

  /// No description provided for @subjectName.
  ///
  /// In en, this message translates to:
  /// **'Subject Name'**
  String get subjectName;

  /// No description provided for @subjectNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Subject Name cannot be empty.'**
  String get subjectNameCannotBeEmpty;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get addSubject;

  /// No description provided for @updateSubject.
  ///
  /// In en, this message translates to:
  /// **'Update Subject'**
  String get updateSubject;

  /// No description provided for @existingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Existing Subjects'**
  String get existingSubjects;

  /// No description provided for @searchSubjects.
  ///
  /// In en, this message translates to:
  /// **'Search subjects by name or description...'**
  String get searchSubjects;

  /// No description provided for @noSubjectsFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No subjects found matching \"{query}\".'**
  String noSubjectsFoundMatching(Object query);

  /// No description provided for @noSubjectsFoundAddOne.
  ///
  /// In en, this message translates to:
  /// **'No subjects found. Add one using the form above!'**
  String get noSubjectsFoundAddOne;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @startManagingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Start managing Subjects by adding one above.'**
  String get startManagingSubjects;

  /// No description provided for @manageSupervisors.
  ///
  /// In en, this message translates to:
  /// **'Manage Supervisors'**
  String get manageSupervisors;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get confirmDeleteUser;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @firstNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'First Name cannot be empty.'**
  String get firstNameCannotBeEmpty;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordRequiredForNewUsers.
  ///
  /// In en, this message translates to:
  /// **'Password is required for new users.'**
  String get passwordRequiredForNewUsers;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @updateUser.
  ///
  /// In en, this message translates to:
  /// **'Update User'**
  String get updateUser;

  /// No description provided for @existingSupervisors.
  ///
  /// In en, this message translates to:
  /// **'Existing Supervisors'**
  String get existingSupervisors;

  /// No description provided for @searchSupervisors.
  ///
  /// In en, this message translates to:
  /// **'Search supervisors by name or email...'**
  String get searchSupervisors;

  /// No description provided for @noSupervisorsFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No supervisors found matching \"{query}\".'**
  String noSupervisorsFoundMatching(Object query);

  /// No description provided for @noSupervisorsFoundAddOne.
  ///
  /// In en, this message translates to:
  /// **'No supervisors found. Add one using the form above!'**
  String get noSupervisorsFoundAddOne;

  /// No description provided for @startManagingUsers.
  ///
  /// In en, this message translates to:
  /// **'Start managing users by adding one above.'**
  String get startManagingUsers;

  /// No description provided for @internshipDistributions.
  ///
  /// In en, this message translates to:
  /// **'Internship Distributions'**
  String get internshipDistributions;

  /// No description provided for @internshipStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Internship Status Distribution'**
  String get internshipStatusDistribution;

  /// No description provided for @internshipTypeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Internship Type Distribution'**
  String get internshipTypeDistribution;

  /// No description provided for @internshipDurationDistribution.
  ///
  /// In en, this message translates to:
  /// **'Internship Duration Distribution'**
  String get internshipDurationDistribution;

  /// No description provided for @encadrantWorkloadDistribution.
  ///
  /// In en, this message translates to:
  /// **'Encadrant Workload Distribution'**
  String get encadrantWorkloadDistribution;

  /// No description provided for @facultyInternshipSummary.
  ///
  /// In en, this message translates to:
  /// **'Faculty Internship Summary'**
  String get facultyInternshipSummary;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @totalInternships.
  ///
  /// In en, this message translates to:
  /// **'Total Internships'**
  String get totalInternships;

  /// No description provided for @validatedInternships.
  ///
  /// In en, this message translates to:
  /// **'Validated Internships'**
  String get validatedInternships;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @noFacultyInternshipSummary.
  ///
  /// In en, this message translates to:
  /// **'No faculty internship summary data available.'**
  String get noFacultyInternshipSummary;

  /// No description provided for @subjectDistribution.
  ///
  /// In en, this message translates to:
  /// **'Subject Distribution'**
  String get subjectDistribution;

  /// No description provided for @loadingInternshipStatistics.
  ///
  /// In en, this message translates to:
  /// **'Loading Internship Statistics...'**
  String get loadingInternshipStatistics;

  /// No description provided for @noPendingInternshipsToReview.
  ///
  /// In en, this message translates to:
  /// **'No pending internships to review.'**
  String get noPendingInternshipsToReview;

  /// No description provided for @noSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'No Subject Title'**
  String get noSubjectTitle;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @remuneration.
  ///
  /// In en, this message translates to:
  /// **'Remuneration'**
  String get remuneration;

  /// No description provided for @tnd.
  ///
  /// In en, this message translates to:
  /// **'TND'**
  String get tnd;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @chefPanel.
  ///
  /// In en, this message translates to:
  /// **'Chef Panel'**
  String get chefPanel;

  /// No description provided for @evaluationsPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Evaluations Pending Your Approval'**
  String get evaluationsPendingApproval;

  /// No description provided for @noEvaluationsPending.
  ///
  /// In en, this message translates to:
  /// **'No evaluations currently require your validation.'**
  String get noEvaluationsPending;

  /// No description provided for @internshipSubject.
  ///
  /// In en, this message translates to:
  /// **'Internship Subject'**
  String get internshipSubject;

  /// No description provided for @encadrant.
  ///
  /// In en, this message translates to:
  /// **'Encadrant'**
  String get encadrant;

  /// No description provided for @internshipStatus.
  ///
  /// In en, this message translates to:
  /// **'Internship Status'**
  String get internshipStatus;

  /// No description provided for @encadrantEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Encadrant\'s Evaluation'**
  String get encadrantEvaluation;

  /// No description provided for @evaluationDate.
  ///
  /// In en, this message translates to:
  /// **'Evaluation Date'**
  String get evaluationDate;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noCommentsProvided.
  ///
  /// In en, this message translates to:
  /// **'No comments provided'**
  String get noCommentsProvided;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @rejectEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Reject Evaluation'**
  String get rejectEvaluation;

  /// No description provided for @reasonForRejection.
  ///
  /// In en, this message translates to:
  /// **'Reason for Rejection (Optional)'**
  String get reasonForRejection;

  /// No description provided for @failedToLoadEvaluations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load evaluations: {message}'**
  String failedToLoadEvaluations(Object message);

  /// No description provided for @allStaff.
  ///
  /// In en, this message translates to:
  /// **'All Staff'**
  String get allStaff;

  /// No description provided for @gestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Gestionnaire'**
  String get gestionnaire;

  /// No description provided for @cannotDeleteUserWithoutId.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete user without an ID.'**
  String get cannotDeleteUserWithoutId;

  /// No description provided for @noUsersFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{query}\" in \"{role}\".'**
  String noUsersFoundFor(Object query, Object role);

  /// No description provided for @noUsersFoundForRole.
  ///
  /// In en, this message translates to:
  /// **'No {role} users found.'**
  String noUsersFoundForRole(Object role);

  /// No description provided for @noUsersFoundAddOne.
  ///
  /// In en, this message translates to:
  /// **'No users found. Add one using the form above!'**
  String get noUsersFoundAddOne;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @addStaffUser.
  ///
  /// In en, this message translates to:
  /// **'Add Staff User'**
  String get addStaffUser;

  /// No description provided for @updateStaffUser.
  ///
  /// In en, this message translates to:
  /// **'Update Staff User'**
  String get updateStaffUser;

  /// No description provided for @passwordRequiredForNewUser.
  ///
  /// In en, this message translates to:
  /// **'Password is required for new user'**
  String get passwordRequiredForNewUser;

  /// No description provided for @pleaseSelectARole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get pleaseSelectARole;

  /// No description provided for @addNewNote.
  ///
  /// In en, this message translates to:
  /// **'Add New Note'**
  String get addNewNote;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Note Content'**
  String get noteContent;

  /// No description provided for @enterYourNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your note here...'**
  String get enterYourNoteHere;

  /// No description provided for @pleaseEnterNoteContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter note content.'**
  String get pleaseEnterNoteContent;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @assignSubject.
  ///
  /// In en, this message translates to:
  /// **'Assign Subject'**
  String get assignSubject;

  /// No description provided for @loadingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Loading subjects...'**
  String get loadingSubjects;

  /// No description provided for @noSubjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subjects available.'**
  String get noSubjectsAvailable;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get selectSubject;

  /// No description provided for @errorLoadingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Error loading subjects: {message}'**
  String errorLoadingSubjects(Object message);

  /// No description provided for @selectSubjectToAssign.
  ///
  /// In en, this message translates to:
  /// **'Select a subject to assign.'**
  String get selectSubjectToAssign;

  /// No description provided for @noInternshipsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No internships assigned yet.'**
  String get noInternshipsAssigned;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not Assigned'**
  String get notAssigned;

  /// No description provided for @assigningSubject.
  ///
  /// In en, this message translates to:
  /// **'Assigning subject...'**
  String get assigningSubject;

  /// No description provided for @pleaseFetchInternships.
  ///
  /// In en, this message translates to:
  /// **'Please fetch internships.'**
  String get pleaseFetchInternships;

  /// No description provided for @myAssignedInternshipsAndNotes.
  ///
  /// In en, this message translates to:
  /// **'My Assigned Internships & Notes'**
  String get myAssignedInternshipsAndNotes;

  /// No description provided for @internshipsAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'Internships Assigned to You'**
  String get internshipsAssignedToYou;

  /// No description provided for @noInternshipsAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'No internships currently assigned to you.'**
  String get noInternshipsAssignedToYou;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noNotesAdded.
  ///
  /// In en, this message translates to:
  /// **'No notes added for this internship yet.'**
  String get noNotesAdded;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get by;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @errorLoadingNotes.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes: {message}'**
  String errorLoadingNotes(Object message);

  /// No description provided for @evaluateInternship.
  ///
  /// In en, this message translates to:
  /// **'Evaluate Internship ID: {id}'**
  String evaluateInternship(Object id);

  /// No description provided for @note0to10.
  ///
  /// In en, this message translates to:
  /// **'Note (0-10)'**
  String get note0to10;

  /// No description provided for @commentsOptional.
  ///
  /// In en, this message translates to:
  /// **'Comments (Optional)'**
  String get commentsOptional;

  /// No description provided for @saveEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Save Evaluation'**
  String get saveEvaluation;

  /// No description provided for @confirmUnvalidation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Unvalidation'**
  String get confirmUnvalidation;

  /// No description provided for @unvalidationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this internship as \"Refused\"? This will set its status to \"Refusé\" and clear your evaluation.'**
  String get unvalidationContent;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @internshipsAwaitingFinalEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Internships Awaiting Your Final Evaluation'**
  String get internshipsAwaitingFinalEvaluation;

  /// No description provided for @noFinishedInternships.
  ///
  /// In en, this message translates to:
  /// **'No finished internships currently assigned to you.'**
  String get noFinishedInternships;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @yourEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Your Evaluation:'**
  String get yourEvaluation;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments'**
  String get noComments;

  /// No description provided for @noEvaluationYet.
  ///
  /// In en, this message translates to:
  /// **'No evaluation from you yet.'**
  String get noEvaluationYet;

  /// No description provided for @editEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Edit Evaluation'**
  String get editEvaluation;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @failedToLoadInternships.
  ///
  /// In en, this message translates to:
  /// **'Failed to load internships: {message}'**
  String failedToLoadInternships(Object message);

  /// No description provided for @attestationOfInternship.
  ///
  /// In en, this message translates to:
  /// **'Attestation of Internship'**
  String get attestationOfInternship;

  /// No description provided for @trainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get trainee;

  /// No description provided for @traineeEmail.
  ///
  /// In en, this message translates to:
  /// **'Trainee Email'**
  String get traineeEmail;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecified;

  /// No description provided for @evaluation.
  ///
  /// In en, this message translates to:
  /// **'Evaluation'**
  String get evaluation;

  /// No description provided for @scanToVerifyAttestation.
  ///
  /// In en, this message translates to:
  /// **'Scan to Verify Attestation:'**
  String get scanToVerifyAttestation;

  /// No description provided for @attestationId.
  ///
  /// In en, this message translates to:
  /// **'Attestation ID'**
  String get attestationId;

  /// No description provided for @createAttestationPdf.
  ///
  /// In en, this message translates to:
  /// **'Create Attestation PDF'**
  String get createAttestationPdf;

  /// No description provided for @payslipTitle.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payslipTitle;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'[Your Company Name]'**
  String get companyName;

  /// No description provided for @companyAddress.
  ///
  /// In en, this message translates to:
  /// **'[Your Company Address]'**
  String get companyAddress;

  /// No description provided for @companyCityPostal.
  ///
  /// In en, this message translates to:
  /// **'[City, Postal Code]'**
  String get companyCityPostal;

  /// No description provided for @employeeTrainee.
  ///
  /// In en, this message translates to:
  /// **'Employee (Trainee)'**
  String get employeeTrainee;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @internshipDetails.
  ///
  /// In en, this message translates to:
  /// **'Internship Details'**
  String get internshipDetails;

  /// No description provided for @remunerationDetails.
  ///
  /// In en, this message translates to:
  /// **'Remuneration Details'**
  String get remunerationDetails;

  /// No description provided for @grossAmount.
  ///
  /// In en, this message translates to:
  /// **'Gross Amount'**
  String get grossAmount;

  /// No description provided for @socialContributions.
  ///
  /// In en, this message translates to:
  /// **'Social Contributions (Est.)'**
  String get socialContributions;

  /// No description provided for @netPayableAmount.
  ///
  /// In en, this message translates to:
  /// **'NET PAYABLE AMOUNT'**
  String get netPayableAmount;

  /// No description provided for @madeInCity.
  ///
  /// In en, this message translates to:
  /// **'Made in [Your City], on {date}'**
  String madeInCity(Object date);

  /// No description provided for @employerSignature.
  ///
  /// In en, this message translates to:
  /// **'Employer\'s Signature'**
  String get employerSignature;

  /// No description provided for @directorName.
  ///
  /// In en, this message translates to:
  /// **'[Director/Manager Name]'**
  String get directorName;

  /// No description provided for @titleFunction.
  ///
  /// In en, this message translates to:
  /// **'[Title/Function]'**
  String get titleFunction;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Oh hey!'**
  String get success;

  /// No description provided for @failure.
  ///
  /// In en, this message translates to:
  /// **'Oh Snap!'**
  String get failure;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get warning;

  /// No description provided for @heyThere.
  ///
  /// In en, this message translates to:
  /// **'Hey There!'**
  String get heyThere;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @accountingAndFinance.
  ///
  /// In en, this message translates to:
  /// **'Accounting and Finance'**
  String get accountingAndFinance;

  /// No description provided for @encadrantDashboard.
  ///
  /// In en, this message translates to:
  /// **'Encadrant Dashboard'**
  String get encadrantDashboard;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// No description provided for @evaluations.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get evaluations;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @validateEvaluations.
  ///
  /// In en, this message translates to:
  /// **'Validate Evaluations'**
  String get validateEvaluations;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
