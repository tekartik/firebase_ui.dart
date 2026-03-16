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
  String get authUserEmailCopiedToClipboard =>
      'Adresse e-mail de l\'utilisateur copiée dans le presse-papiers';

  @override
  String get authUserEmailLabel => 'Courriel de l\'utilisateur';

  @override
  String get authUserIdCopiedToClipboard =>
      'ID utilisateur copié dans le presse-papiers';

  @override
  String get authUserIdLabel => 'ID utilisateur';

  @override
  String get emailNotVerifiedMessage => 'Adresse e-mail non vérifiée';

  @override
  String get emailVerificationButtonLabel => 'Vérifier l\'e-mail';

  @override
  String get emailVerifiedMessage => 'Adresse e-mail vérifiée';

  @override
  String hello(String userName) {
    return 'Bonjour $userName';
  }

  @override
  String get loginButtonLabel => 'Se connecter';

  @override
  String get loginGenericError => 'Échec de la connexion';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get loginUserLabel => 'Utilisateur';

  @override
  String get logoutButtonLabel => 'Se déconnecter';

  @override
  String get profileButtonLabel => 'Profil';

  @override
  String profileLoggedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get signInWithGoogleButtonLabel => 'Se connecter avec Google';
}
