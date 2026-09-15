// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get authTitle => 'Authentification';

  @override
  String get authWelcomeHeadline => 'Bienvenue';

  @override
  String get authWelcomeSubtitle =>
      'Connectez-vous pour accéder à votre compte';

  @override
  String get authCreateAccountButtonLabel => 'Créer un compte';

  @override
  String get authVerifiedBadge => 'Vérifié';

  @override
  String get authActiveSession => 'Session active';

  @override
  String get authAnonymousUser => 'Utilisateur anonyme';

  @override
  String get authAccountDetailsSection => 'Détails du compte';

  @override
  String get authPreferencesSection => 'Préférences';

  @override
  String get authUserEmailCopiedToClipboard =>
      'Adresse e-mail de l\'utilisateur copiée dans le presse-papiers';

  @override
  String get authUserEmailLabel => 'E-mail du compte';

  @override
  String get authPrimaryBadge => 'Principal';

  @override
  String get authUserIdCopiedToClipboard =>
      'ID utilisateur copié dans le presse-papiers';

  @override
  String get authUserIdLabel => 'ID utilisateur';

  @override
  String get authSecurityStatusLabel => 'Sécurité et statut';

  @override
  String get authConfirmedBadge => 'Confirmé';

  @override
  String get authPendingBadge => 'En attente';

  @override
  String get authSessionProviderLabel => 'Fournisseur de session';

  @override
  String get copyTooltip => 'Copier';

  @override
  String get emailNotVerifiedMessage => 'Adresse e-mail non vérifiée';

  @override
  String get emailVerificationButtonLabel => 'Vérifier l\'e-mail';

  @override
  String get emailVerificationRowSubtitle => 'Confirmez votre adresse e-mail';

  @override
  String get emailVerifiedMessage => 'Adresse e-mail vérifiée';

  @override
  String get emailVerificationTitle => 'Vérification de l\'e-mail';

  @override
  String get emailVerificationHeadline => 'Vérifiez votre e-mail';

  @override
  String emailVerificationSubtitle(String email) {
    return 'Nous devons confirmer que $email vous appartient. Envoyez-vous un e-mail de vérification et suivez le lien qu\'il contient.';
  }

  @override
  String get emailVerificationSendButtonLabel =>
      'Envoyer l\'e-mail de vérification';

  @override
  String get emailVerificationSentMessage =>
      'E-mail de vérification envoyé. Consultez votre boîte de réception.';

  @override
  String get emailVerificationCheckButtonLabel => 'J\'ai vérifié mon e-mail';

  @override
  String get emailVerificationNotYetVerifiedMessage =>
      'Votre e-mail n\'est pas encore vérifié.';

  @override
  String get emailVerificationGenericError =>
      'Impossible d\'envoyer l\'e-mail de vérification.';

  @override
  String hello(String userName) {
    return 'Bonjour $userName';
  }

  @override
  String get loginTitle => 'Accès au compte';

  @override
  String get loginHeadline => 'Bon retour';

  @override
  String get loginSubtitle =>
      'Veuillez saisir vos identifiants pour vous connecter à votre compte';

  @override
  String get loginUserLabel => 'E-mail ou nom d\'utilisateur';

  @override
  String get loginUserHint => 'nom@exemple.com';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get loginButtonLabel => 'Se connecter';

  @override
  String get loginOrContinueWith => 'Ou continuer avec';

  @override
  String get loginNoAccountText => 'Vous n\'avez pas de compte ?';

  @override
  String get loginSignUpLink => 'S\'inscrire';

  @override
  String get loginGenericError =>
      'Échec de la connexion. Vérifiez vos identifiants et réessayez.';

  @override
  String get logoutButtonLabel => 'Se déconnecter';

  @override
  String get passwordShowTooltip => 'Afficher le mot de passe';

  @override
  String get passwordHideTooltip => 'Masquer le mot de passe';

  @override
  String get profileButtonLabel => 'Profil';

  @override
  String get profileRowSubtitle => 'Consulter les informations de votre compte';

  @override
  String profileLoggedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerHeadline => 'Créez votre compte';

  @override
  String get registerSubtitle =>
      'Saisissez votre e-mail et choisissez un mot de passe pour commencer';

  @override
  String get registerPasswordConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get registerPasswordMismatchError =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerButtonLabel => 'S\'inscrire';

  @override
  String get registerHaveAccountText => 'Vous avez déjà un compte ?';

  @override
  String get registerSignInLink => 'Se connecter';

  @override
  String get registerGenericError =>
      'Échec de la création du compte. Veuillez réessayer.';

  @override
  String get lostPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get lostPasswordHeadline => 'Mot de passe oublié ?';

  @override
  String get lostPasswordSubtitle =>
      'Saisissez l\'e-mail de votre compte et nous vous enverrons un lien pour réinitialiser votre mot de passe';

  @override
  String get lostPasswordButtonLabel => 'Envoyer le lien';

  @override
  String get lostPasswordSentTitle => 'Consultez votre boîte de réception';

  @override
  String lostPasswordSentMessage(String email) {
    return 'Si un compte existe pour $email, un lien de réinitialisation du mot de passe a été envoyé.';
  }

  @override
  String get lostPasswordBackToSignInLink => 'Retour à la connexion';

  @override
  String get lostPasswordGenericError =>
      'Impossible d\'envoyer l\'e-mail de réinitialisation. Vérifiez l\'adresse et réessayez.';

  @override
  String get signInWithGoogleButtonLabel => 'Se connecter avec Google';

  @override
  String get googleButtonLabel => 'Google';

  @override
  String get googleSignInLinkMessage =>
      'Veuillez vous connecter en utilisant le lien suivant :';

  @override
  String get copyLinkButtonLabel => 'Copier le lien';

  @override
  String get doneButtonLabel => 'Terminé';
}
