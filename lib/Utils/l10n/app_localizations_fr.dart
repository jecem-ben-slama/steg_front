// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get welcomeBack => 'Bienvenue de retour !';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String loginFailedError(Object error) {
    return 'Échec de connexion : $error';
  }

  @override
  String get unknownRole => 'Rôle d\'utilisateur inconnu. Déconnexion.';

  @override
  String get emailRequired => 'L\'e-mail est requis.';

  @override
  String get passwordRequired => 'Le mot de passe est requis.';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get deleteConfirmationContent =>
      'Êtes-vous sûr de vouloir supprimer ce stage ? Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get searchHint =>
      'Rechercher par étudiant, sujet, encadrant, statut...';

  @override
  String get statusLabel => 'Statut';

  @override
  String get typeLabel => 'Type';

  @override
  String get all => 'Tout';

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
  String get activeInternships => 'Stages Actifs';

  @override
  String get totalEncadrants => 'Total Encadrants';

  @override
  String get pendingEvaluations => 'Évaluations en attente';

  @override
  String errorLoadingStatistics(Object message) {
    return 'Erreur lors du chargement des statistiques : $message';
  }

  @override
  String get retryStats => 'Réessayer les statistiques';

  @override
  String get manageStudent => 'Gérer les étudiants';

  @override
  String get manageSubject => 'Gérer les sujets';

  @override
  String get manageSupervisor => 'Gérer les encadrants';

  @override
  String get internships => 'Stages';

  @override
  String get addInternship => 'Ajouter un stage';

  @override
  String get studentName => 'Nom de l\'étudiant';

  @override
  String get subject => 'Sujet';

  @override
  String get supervisor => 'Encadrant';

  @override
  String get type => 'Type';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get status => 'Statut';

  @override
  String get actions => 'Actions';

  @override
  String get na => 'N/A';

  @override
  String get internshipIdMissing =>
      'L\'ID du stage est manquant pour la suppression.';

  @override
  String get noMatchingInternships =>
      'Aucun stage correspondant aux filtres actuels.';

  @override
  String get noInternshipsFound => 'Aucun stage trouvé.';
}
