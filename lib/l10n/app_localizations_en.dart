// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pigeon Finder';

  @override
  String get tagline => 'Spot it. Snap it. Score it.';

  @override
  String get navMap => 'Map';

  @override
  String get navPigeondex => 'Pigeondex';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navProfile => 'Profile';

  @override
  String get mapTitle => 'Map';

  @override
  String get pigeondexTitle => 'Pigeondex';

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get profileTitle => 'Profile';

  @override
  String get cameraTitle => 'Camera';

  @override
  String mapPigeonsSpotted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons spotted today',
      one: '1 pigeon spotted today',
      zero: 'No pigeons spotted today',
    );
    return '$_temp0';
  }

  @override
  String mapExpiresIn(int hours, int minutes) {
    return 'Expires in $hours h $minutes min';
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
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get mapLoadError => 'Couldn\'t load the map';

  @override
  String get retry => 'Retry';

  @override
  String get mapRecenter => 'Center on my location';

  @override
  String get mapNorthLock => 'Lock north';

  @override
  String get mapNorthUnlock => 'Unlock north';

  @override
  String postDetailAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String postDetailAgoHours(int hours) {
    return '$hours h ago';
  }

  @override
  String postDetailCoo(int count) {
    return 'Coo · $count';
  }

  @override
  String get postDetailReport => 'Report';

  @override
  String get postDetailReported => 'Reported';

  @override
  String get postDetailReportThanks => 'Thanks! Report sent';

  @override
  String get reportTitle => 'What\'s wrong?';

  @override
  String get reportSubtitle =>
      'At 3 reports, the AI double-checks and the photo may disappear. A valid report earns you +2 pts.';

  @override
  String get reportReasonNotPigeon => 'It\'s not a pigeon';

  @override
  String get reportReasonGull => 'It\'s a gull / seagull';

  @override
  String get reportReasonStolen => 'Photo found on the internet';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportSubmit => 'Send report';
}
