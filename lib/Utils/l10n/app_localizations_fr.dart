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
      'Le mot de passe doit contenir au moins 8 caractères';

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

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get role => 'Rôle';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get pleaseEnterAUsername => 'Veuillez saisir un nom d\'utilisateur';

  @override
  String get pleaseEnterALastName => 'Veuillez saisir un nom de famille';

  @override
  String get pleaseEnterAnEmail => 'Veuillez saisir un e-mail';

  @override
  String get enterAValidEmail => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get newPassword =>
      'Nouveau mot de passe (laisser vide pour conserver l\'actuel)';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String errorLoadingInternships(Object message) {
    return 'Erreur de chargement des stages : $message';
  }

  @override
  String get addNewInternship => 'Ajouter un nouveau stage';

  @override
  String get internshipType => 'Type de stage';

  @override
  String get pleaseSelectInternshipType =>
      'Veuillez sélectionner un type de stage.';

  @override
  String get pleaseEnterStartDate => 'Veuillez saisir la date de début.';

  @override
  String get pleaseEnterEndDate => 'Veuillez saisir la date de fin.';

  @override
  String get isRemunerated => 'Est rémunéré ?';

  @override
  String get remunerationAmount => 'Montant de la rémunération';

  @override
  String get pleaseEnterRemunerationAmount =>
      'Veuillez saisir le montant de la rémunération.';

  @override
  String get pleaseEnterAValidNumber => 'Veuillez saisir un numéro valide.';

  @override
  String get student => 'Étudiant';

  @override
  String get pleaseSelectAStudent => 'Veuillez sélectionner un étudiant.';

  @override
  String errorLoadingStudents(Object message) {
    return 'Erreur de chargement des étudiants : $message';
  }

  @override
  String get pleaseSelectASupervisor => 'Veuillez sélectionner un encadrant.';

  @override
  String errorLoadingSupervisors(Object message) {
    return 'Erreur de chargement des encadrants : $message';
  }

  @override
  String get clear => 'Effacer';

  @override
  String get close => 'Fermer';

  @override
  String get pleaseSelectAllFields =>
      'Veuillez sélectionner le type de stage, l\'étudiant et l\'encadrant.';

  @override
  String get endDateAfterStartDate =>
      'La date de fin ne peut pas être antérieure à la date de début.';

  @override
  String get editInternship => 'Modifier le stage';

  @override
  String get subjectTitle => 'Titre du sujet';

  @override
  String get noSupervisorsAvailable =>
      'Aucun encadrant disponible. Impossible d\'assigner.';

  @override
  String get save => 'Enregistrer';

  @override
  String get noInternshipsForAttestation =>
      'Aucun stage éligible pour une attestation pour le moment.';

  @override
  String get period => 'Période';

  @override
  String get attestation => 'Attestation';

  @override
  String get payslip => 'Fiche de Paie';

  @override
  String get payslipGenerated => 'Fiche de paie PDF générée !';

  @override
  String errorGeneratingPayslip(Object error) {
    return 'Erreur lors de la génération de la fiche de paie PDF : $error';
  }

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get loadingAttestableInternships =>
      'Chargement des stages attestables...';

  @override
  String get attestationGenerated => 'Attestation PDF générée !';

  @override
  String errorGeneratingAttestation(Object error) {
    return 'Erreur lors de la génération de l\'attestation PDF : $error';
  }

  @override
  String get manageStudents => 'Gérer les étudiants';

  @override
  String get pleaseFillRequiredFields =>
      'Veuillez remplir tous les champs obligatoires.';

  @override
  String get confirmDeleteStudent =>
      'Êtes-vous sûr de vouloir supprimer cet étudiant ?';

  @override
  String get addNewStudent => 'Ajouter un nouvel étudiant';

  @override
  String get editStudent => 'Modifier l\'étudiant';

  @override
  String get hideForm => 'Masquer le formulaire';

  @override
  String get showForm => 'Afficher le formulaire';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastNameCannotBeEmpty =>
      'Le nom de famille ne peut pas être vide.';

  @override
  String get emailCannotBeEmpty => 'L\'e-mail ne peut pas être vide.';

  @override
  String get cin => 'CIN';

  @override
  String get levelOfStudy => 'Niveau d\'étude';

  @override
  String get pleaseSelectLevelOfStudy =>
      'Veuillez sélectionner un niveau d\'étude.';

  @override
  String get faculty => 'Faculté';

  @override
  String get pleaseSelectFaculty => 'Veuillez sélectionner une faculté.';

  @override
  String get cycle => 'Cycle';

  @override
  String get pleaseSelectCycle => 'Veuillez sélectionner un cycle.';

  @override
  String get specialty => 'Spécialité';

  @override
  String get pleaseSelectSpecialty => 'Veuillez sélectionner une spécialité.';

  @override
  String get addStudent => 'Ajouter l\'étudiant';

  @override
  String get updateStudent => 'Mettre à jour l\'étudiant';

  @override
  String get existingStudents => 'Étudiants existants';

  @override
  String get searchStudents => 'Rechercher des étudiants';

  @override
  String get searchByNameEmailCin => 'Rechercher par nom, e-mail, CIN...';

  @override
  String get noStudentsFound =>
      'Aucun étudiant trouvé. Ajoutez-en un à l\'aide du formulaire ci-dessus !';

  @override
  String noStudentsFoundMatching(Object query) {
    return 'Aucun étudiant trouvé correspondant à \"$query\".';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get noStudentsToDisplay => 'Aucun étudiant à afficher.';

  @override
  String get attestationDetails => 'Détails de l\'attestation';

  @override
  String get cti => 'CTI';

  @override
  String get selectAnOption => 'Sélectionnez une option';

  @override
  String get manageSubjects => 'Gérer les sujets';

  @override
  String get confirmDeleteSubject =>
      'Êtes-vous sûr de vouloir supprimer ce sujet ?';

  @override
  String get addNewSubject => 'Ajouter un nouveau sujet';

  @override
  String get subjectName => 'Nom du sujet';

  @override
  String get subjectNameCannotBeEmpty =>
      'Le nom du sujet ne peut pas être vide.';

  @override
  String get descriptionOptional => 'Description (Facultatif)';

  @override
  String get addSubject => 'Ajouter un sujet';

  @override
  String get updateSubject => 'Mettre à jour le sujet';

  @override
  String get existingSubjects => 'Sujets existants';

  @override
  String get searchSubjects =>
      'Rechercher des sujets par nom ou description...';

  @override
  String noSubjectsFoundMatching(Object query) {
    return 'Aucun sujet trouvé correspondant à \"$query\".';
  }

  @override
  String get noSubjectsFoundAddOne =>
      'Aucun sujet trouvé. Ajoutez-en un à l\'aide du formulaire ci-dessus !';

  @override
  String get description => 'Description';

  @override
  String get startManagingSubjects =>
      'Commencez à gérer les sujets en en ajoutant un ci-dessus.';

  @override
  String get manageSupervisors => 'Gérer les encadrants';

  @override
  String get confirmDeleteUser =>
      'Êtes-vous sûr de vouloir supprimer cet utilisateur ?';

  @override
  String get addNewUser => 'Ajouter un nouvel utilisateur';

  @override
  String get editUser => 'Modifier l\'utilisateur';

  @override
  String get firstNameCannotBeEmpty => 'Le prénom ne peut pas être vide.';

  @override
  String get emailInvalid => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get passwordRequiredForNewUsers =>
      'Le mot de passe est requis pour les nouveaux utilisateurs.';

  @override
  String get addUser => 'Ajouter un utilisateur';

  @override
  String get updateUser => 'Mettre à jour l\'utilisateur';

  @override
  String get existingSupervisors => 'Encadrants existants';

  @override
  String get searchSupervisors =>
      'Rechercher des encadrants par nom ou e-mail...';

  @override
  String noSupervisorsFoundMatching(Object query) {
    return 'Aucun encadrant trouvé correspondant à \"$query\".';
  }

  @override
  String get noSupervisorsFoundAddOne =>
      'Aucun encadrant trouvé. Ajoutez-en un à l\'aide du formulaire ci-dessus !';

  @override
  String get startManagingUsers =>
      'Commencez à gérer les utilisateurs en en ajoutant un ci-dessus.';

  @override
  String get internshipDistributions => 'Distributions des stages';

  @override
  String get internshipStatusDistribution =>
      'Distribution des statuts de stage';

  @override
  String get internshipTypeDistribution => 'Distribution des types de stage';

  @override
  String get internshipDurationDistribution =>
      'Distribution de la durée des stages';

  @override
  String get encadrantWorkloadDistribution =>
      'Distribution de la charge de travail des encadrants';

  @override
  String get facultyInternshipSummary => 'Résumé des stages par faculté';

  @override
  String get totalStudents => 'Total des étudiants';

  @override
  String get totalInternships => 'Total des stages';

  @override
  String get validatedInternships => 'Stages validés';

  @override
  String get successRate => 'Taux de réussite';

  @override
  String get noFacultyInternshipSummary =>
      'Aucune donnée de résumé des stages par faculté disponible.';

  @override
  String get subjectDistribution => 'Distribution des sujets';

  @override
  String get loadingInternshipStatistics =>
      'Chargement des statistiques de stage...';

  @override
  String get noPendingInternshipsToReview =>
      'Aucun stage en attente à examiner.';

  @override
  String get noSubjectTitle => 'Aucun titre de sujet';

  @override
  String get from => 'Du';

  @override
  String get to => 'À';

  @override
  String get remuneration => 'Rémunération';

  @override
  String get tnd => 'TND';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Rejeter';

  @override
  String get chefPanel => 'Panneau du Chef';

  @override
  String get evaluationsPendingApproval =>
      'Évaluations en attente de votre approbation';

  @override
  String get noEvaluationsPending =>
      'Aucune évaluation ne nécessite actuellement votre validation.';

  @override
  String get internshipSubject => 'Sujet du stage';

  @override
  String get encadrant => 'Encadrant';

  @override
  String get internshipStatus => 'Statut du stage';

  @override
  String get encadrantEvaluation => 'Évaluation de l\'encadrant';

  @override
  String get evaluationDate => 'Date d\'évaluation';

  @override
  String get note => 'Note';

  @override
  String get comments => 'Commentaires';

  @override
  String get noCommentsProvided => 'Aucun commentaire fourni';

  @override
  String get validate => 'Valider';

  @override
  String get rejectEvaluation => 'Rejeter l\'évaluation';

  @override
  String get reasonForRejection => 'Raison du rejet (Facultatif)';

  @override
  String failedToLoadEvaluations(Object message) {
    return 'Échec du chargement des évaluations : $message';
  }

  @override
  String get allStaff => 'Tout le personnel';

  @override
  String get gestionnaire => 'Gestionnaire';

  @override
  String get cannotDeleteUserWithoutId =>
      'Impossible de supprimer l\'utilisateur sans ID.';

  @override
  String noUsersFoundFor(Object query, Object role) {
    return 'Aucun utilisateur trouvé pour \"$query\" dans \"$role\".';
  }

  @override
  String noUsersFoundForRole(Object role) {
    return 'Aucun utilisateur $role trouvé.';
  }

  @override
  String get noUsersFoundAddOne =>
      'Aucun utilisateur trouvé. Ajoutez-en un à l\'aide du formulaire ci-dessus !';

  @override
  String get deleteUser => 'Supprimer l\'utilisateur';

  @override
  String get addStaffUser => 'Ajouter un utilisateur du personnel';

  @override
  String get updateStaffUser => 'Mettre à jour l\'utilisateur du personnel';

  @override
  String get passwordRequiredForNewUser =>
      'Le mot de passe est requis pour le nouvel utilisateur';

  @override
  String get pleaseSelectARole => 'Veuillez sélectionner un rôle';

  @override
  String get addNewNote => 'Ajouter une nouvelle note';

  @override
  String get noteContent => 'Contenu de la note';

  @override
  String get enterYourNoteHere => 'Saisissez votre note ici...';

  @override
  String get pleaseEnterNoteContent => 'Veuillez saisir le contenu de la note.';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get assignSubject => 'Assigner un sujet';

  @override
  String get loadingSubjects => 'Chargement des sujets...';

  @override
  String get noSubjectsAvailable => 'Aucun sujet disponible.';

  @override
  String get selectSubject => 'Sélectionner un sujet';

  @override
  String errorLoadingSubjects(Object message) {
    return 'Erreur de chargement des sujets : $message';
  }

  @override
  String get selectSubjectToAssign => 'Sélectionnez un sujet à assigner.';

  @override
  String get noInternshipsAssigned => 'Aucun stage assigné pour le moment.';

  @override
  String get notAssigned => 'Non assigné';

  @override
  String get assigningSubject => 'Assignation du sujet...';

  @override
  String get pleaseFetchInternships => 'Veuillez récupérer les stages.';

  @override
  String get myAssignedInternshipsAndNotes => 'Mes stages assignés et notes';

  @override
  String get internshipsAssignedToYou => 'Stages qui vous sont assignés';

  @override
  String get noInternshipsAssignedToYou =>
      'Aucun stage ne vous est actuellement assigné.';

  @override
  String get notes => 'Notes';

  @override
  String get noNotesAdded =>
      'Aucune note ajoutée pour ce stage pour le moment.';

  @override
  String get by => 'par';

  @override
  String get on => 'le';

  @override
  String errorLoadingNotes(Object message) {
    return 'Erreur de chargement des notes : $message';
  }

  @override
  String evaluateInternship(Object id) {
    return 'Évaluer le stage ID : $id';
  }

  @override
  String get note0to10 => 'Note (0-10)';

  @override
  String get commentsOptional => 'Commentaires (Facultatif)';

  @override
  String get saveEvaluation => 'Enregistrer l\'évaluation';

  @override
  String get confirmUnvalidation => 'Confirmer l\'invalidation';

  @override
  String get unvalidationContent =>
      'Êtes-vous sûr de vouloir marquer ce stage comme \"Refusé\" ? Cela définira son statut à \"Refusé\" et effacera votre évaluation.';

  @override
  String get confirm => 'Confirmer';

  @override
  String get internshipsAwaitingFinalEvaluation =>
      'Stages en attente de votre évaluation finale';

  @override
  String get noFinishedInternships =>
      'Aucun stage terminé ne vous est actuellement assigné.';

  @override
  String get currentStatus => 'Statut actuel';

  @override
  String get yourEvaluation => 'Votre évaluation :';

  @override
  String get noComments => 'Aucun commentaire';

  @override
  String get noEvaluationYet =>
      'Aucune évaluation de votre part pour le moment.';

  @override
  String get editEvaluation => 'Modifier l\'évaluation';

  @override
  String get refuse => 'Refuser';

  @override
  String failedToLoadInternships(Object message) {
    return 'Échec du chargement des stages : $message';
  }

  @override
  String get attestationOfInternship => 'Attestation de stage';

  @override
  String get trainee => 'Stagiaire';

  @override
  String get traineeEmail => 'E-mail du stagiaire';

  @override
  String get unspecified => 'Non spécifié';

  @override
  String get evaluation => 'Évaluation';

  @override
  String get scanToVerifyAttestation =>
      'Scanner pour vérifier l\'attestation :';

  @override
  String get attestationId => 'ID de l\'attestation';

  @override
  String get createAttestationPdf => 'Créer l\'attestation PDF';

  @override
  String get payslipTitle => 'Fiche de paie';

  @override
  String get companyName => '[Nom de votre entreprise]';

  @override
  String get companyAddress => '[Adresse de votre entreprise]';

  @override
  String get companyCityPostal => '[Ville, Code Postal]';

  @override
  String get employeeTrainee => 'Employé (Stagiaire)';

  @override
  String get name => 'Nom';

  @override
  String get internshipDetails => 'Détails du stage';

  @override
  String get remunerationDetails => 'Détails de la rémunération';

  @override
  String get grossAmount => 'Montant brut';

  @override
  String get socialContributions => 'Cotisations Sociales (Est.)';

  @override
  String get netPayableAmount => 'MONTANT NET À PAYER';

  @override
  String madeInCity(Object date) {
    return 'Fait à [Votre Ville], le $date';
  }

  @override
  String get employerSignature => 'Signature de l\'Employeur';

  @override
  String get directorName => '[Nom du Directeur/Responsable]';

  @override
  String get titleFunction => '[Titre/Fonction]';

  @override
  String get success => 'Oh hey!';

  @override
  String get failure => 'Oh Snap!';

  @override
  String get warning => 'Attention !';

  @override
  String get heyThere => 'Salut !';

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
