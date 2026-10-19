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
  String get rankingTitle => 'Classement';

  @override
  String get profileTitle => 'Profil';

  @override
  String get cameraTitle => 'Caméra';

  @override
  String mapPigeonsSpotted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons repérés aujourd\'hui',
      one: '1 pigeon repéré aujourd\'hui',
      zero: 'Aucun pigeon repéré aujourd\'hui',
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
}
