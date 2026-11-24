// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Pigeon Finder';

  @override
  String get tagline => 'Repère-le. Photographie-le. Marque des points.';

  @override
  String get navMap => 'Carte';

  @override
  String get navPigeondex => 'Pigeondex';

  @override
  String get navRanking => 'Classement';

  @override
  String get navProfile => 'Profil';

  @override
  String get mapTitle => 'Carte';

  @override
  String get pigeondexTitle => 'Pigeondex';

  @override
  String get pigeondexSortDate => 'Date';

  @override
  String get pigeondexSortPlace => 'Lieu';

  @override
  String get pigeondexSortTop => 'Top';

  @override
  String get pigeondexOnMap => 'Sur la carte';

  @override
  String get pigeondexEmpty =>
      'Pas encore de photo. Capture ton premier pigeon !';

  @override
  String get pigeondexUnknownPlace => 'Lieu inconnu';

  @override
  String get pigeondexLoadError => 'Impossible de charger ton Pigeondex';

  @override
  String get rankingTitle => 'Classement';

  @override
  String get profileTitle => 'Profil';

  @override
  String get cameraTitle => 'Caméra';

  @override
  String mapPigeonsAround(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons autour de toi',
      one: '1 pigeon autour de toi',
      zero: 'Aucun pigeon autour de toi',
    );
    return '$_temp0';
  }

  @override
  String mapPigeonsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons dans cette zone',
      one: '1 pigeon dans cette zone',
      zero: 'Aucun pigeon dans cette zone',
    );
    return '$_temp0';
  }

  @override
  String mapExpiresIn(int hours, int minutes) {
    return 'Expire dans $hours h $minutes min';
  }

  @override
  String mapPigeonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons',
      one: '1 pigeon',
    );
    return '$_temp0';
  }

  @override
  String mapReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '1 signalement',
    );
    return '$_temp0';
  }

  @override
  String get mapLoadError => 'Impossible de charger la carte';

  @override
  String get retry => 'Réessayer';

  @override
  String get mapRecenter => 'Recentrer sur ma position';

  @override
  String get mapNorthLock => 'Verrouiller le nord';

  @override
  String get mapNorthUnlock => 'Déverrouiller le nord';

  @override
  String postDetailAgoMinutes(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String postDetailAgoHours(int hours) {
    return 'il y a $hours h';
  }

  @override
  String postDetailCoo(int count) {
    return 'Roucoule · $count';
  }

  @override
  String get postDetailReport => 'Signaler';

  @override
  String get postDetailReported => 'Signalé';

  @override
  String get postDetailReportThanks => 'Merci ! Signalement envoyé';

  @override
  String get reportTitle => 'Qu\'est-ce qui cloche ?';

  @override
  String get reportSubtitle =>
      'À 3 signalements, l\'IA revérifie et la photo peut disparaître. Un signalement juste te rapporte +2 pts.';

  @override
  String get reportReasonNotPigeon => 'Ce n\'est pas un pigeon';

  @override
  String get reportReasonGull => 'C\'est un goéland / une mouette';

  @override
  String get reportReasonStolen => 'Photo trouvée sur internet';

  @override
  String get reportReasonInappropriate => 'Contenu inapproprié';

  @override
  String get reportSubmit => 'Envoyer le signalement';

  @override
  String get authWelcomeSubtitle =>
      'Photographie les pigeons de ta ville et grimpe au classement de ton quartier.';

  @override
  String get authStep1 => 'Prends un pigeon en photo';

  @override
  String get authStep2 => 'L\'IA vérifie que c\'est un vrai';

  @override
  String get authStep3 =>
      'Il reste 24 h sur la carte, pour toujours dans ton Pigeondex';

  @override
  String get authContinueWithEmail => 'Continuer avec mon email';

  @override
  String get authNoPassword =>
      'Pas de mot de passe : un code par email suffit.';

  @override
  String get authEmailTitle => 'Ton adresse email';

  @override
  String get authEmailSubtitle =>
      'On t\'envoie un code à 6 chiffres. Aucun mot de passe à retenir.';

  @override
  String get authEmailHint => 'toi@exemple.fr';

  @override
  String get authReceiveCode => 'Recevoir le code';

  @override
  String get authEmailPrivacy =>
      'Ton email reste privé : il n\'apparaît jamais sur la carte ni au classement.';

  @override
  String get authError => 'Une erreur est survenue, réessaie.';

  @override
  String get authCodeInvalid => 'Code incorrect ou expiré.';

  @override
  String get authCodeTitle => 'Vérifie tes emails';

  @override
  String authCodeSentTo(String email) {
    return 'Code envoyé à $email';
  }

  @override
  String get authEdit => 'Modifier';

  @override
  String authResendIn(String time) {
    return 'Renvoyer le code dans $time';
  }

  @override
  String get authResend => 'Renvoyer le code';

  @override
  String get authValidate => 'Valider';

  @override
  String get authCodeHelp =>
      'Rien reçu ? Regarde dans tes spams. Le code expire au bout de 1 heure.';

  @override
  String get authEmailVerified => 'Email vérifié';

  @override
  String get authPseudoTitle => 'Rejoins la nuée';

  @override
  String get authPseudoSubtitle =>
      'Ton pseudo apparaîtra sur la carte et au classement.';

  @override
  String get authPseudoLabel => 'Pseudo';

  @override
  String get authPseudoHint => 'camille_roucoule';

  @override
  String get authAcceptTerms =>
      'J\'accepte les conditions d\'utilisation et je promets de ne poster que de vrais pigeons.';

  @override
  String get authTrainingConsent =>
      'J\'autorise l\'utilisation de mes photos pour entraîner l\'IA (facultatif).';

  @override
  String get authLetsGo => 'C\'est parti';

  @override
  String get locationTitle => 'Où sont les pigeons ?';

  @override
  String get locationSubtitle =>
      'On utilise ta position pour centrer la carte sur toi et placer tes photos. Elle n\'est jamais affichée aux autres.';

  @override
  String get locationAllow => 'Autoriser la localisation';

  @override
  String get locationLater => 'Plus tard';

  @override
  String get authUsernameTaken => 'Ce pseudo est déjà pris.';

  @override
  String get cameraDenied =>
      'Accès à la caméra refusé. Autorise-le dans les réglages du téléphone pour photographier des pigeons.';

  @override
  String get cameraUnavailable => 'Aucune caméra disponible sur cet appareil.';

  @override
  String get cameraShutter => 'Prendre la photo';

  @override
  String get cameraCaptureFailed => 'Impossible de prendre la photo, réessaie.';

  @override
  String get postDescriptionHint => 'Ajoute une description (facultatif)';

  @override
  String get postPublish => 'Publier';

  @override
  String get postRetake => 'Reprendre';

  @override
  String get postPublished =>
      'Publié ! Ton pigeon est sur la carte pendant 24 h.';

  @override
  String get postErrorLocationDenied =>
      'Accès à la position refusé : on en a besoin pour placer ta photo sur la carte.';

  @override
  String get postErrorLocation =>
      'Impossible de trouver ta position. Vérifie que la localisation est activée.';

  @override
  String get postErrorNetwork =>
      'Pas de connexion. Vérifie ton réseau et réessaie.';

  @override
  String get postErrorRateLimited =>
      'Tu as beaucoup publié cette dernière heure. Réessaie plus tard.';

  @override
  String get postErrorTooLarge => 'La photo est trop lourde (5 Mo max).';

  @override
  String get postErrorUnknown => 'La publication a échoué, réessaie.';

  @override
  String get analysisRunning => 'L\'IA inspecte ton oiseau…';

  @override
  String get analysisRunningHint =>
      'Elle compte les pigeons, directement sur ton téléphone';

  @override
  String analysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons dans le cadre',
      one: '1 pigeon dans le cadre',
    );
    return '$_temp0';
  }

  @override
  String analysisConfidence(String species, int percent) {
    return '$species · $percent %';
  }

  @override
  String get analysisNone => 'Aucun pigeon en vue.';

  @override
  String get analysisNoneChip => '0 pigeon';

  @override
  String get analysisNoneHint =>
      'L\'IA n\'a trouvé aucun pigeon. Rapproche-toi ou cadre mieux, puis reprends la photo.';

  @override
  String get analysisFailed => 'L\'analyse a échoué.';

  @override
  String get analysisFailedHint =>
      'Le modèle n\'a pas pu tourner sur ce téléphone. Réessaie, ou reprends la photo.';

  @override
  String get analysisOnDevice =>
      'Compté sur ton téléphone · rien ne part avant de publier';

  @override
  String get postRetakePhoto => 'Reprendre la photo';

  @override
  String get speciesFeralPigeon => 'Pigeon biset';

  @override
  String get speciesWoodPigeon => 'Pigeon ramier';

  @override
  String get speciesCollaredDove => 'Tourterelle turque';

  @override
  String get speciesOther => 'Autre oiseau';

  @override
  String get speciesUncertain => 'Incertain';

  @override
  String get speciesUncertainHint => 'Incertain · espèce à confirmer';

  @override
  String analysisModel(String version, String source) {
    return 'Modèle $version · $source';
  }

  @override
  String get analysisModelDownloaded => 'téléchargé';

  @override
  String get analysisModelBundled => 'intégré';
}
