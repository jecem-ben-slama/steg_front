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
}
