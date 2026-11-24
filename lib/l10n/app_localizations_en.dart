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
  String get pigeondexSortDate => 'Date';

  @override
  String get pigeondexSortPlace => 'Place';

  @override
  String get pigeondexSortTop => 'Top';

  @override
  String get pigeondexOnMap => 'On the map';

  @override
  String get pigeondexEmpty => 'No photos yet. Snap your first pigeon!';

  @override
  String get pigeondexUnknownPlace => 'Unknown place';

  @override
  String get pigeondexLoadError => 'Couldn\'t load your Pigeondex';

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get profileTitle => 'Profile';

  @override
  String get cameraTitle => 'Camera';

  @override
  String mapPigeonsAround(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons around you',
      one: '1 pigeon around you',
      zero: 'No pigeons around you',
    );
    return '$_temp0';
  }

  @override
  String mapPigeonsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons in this area',
      one: '1 pigeon in this area',
      zero: 'No pigeons in this area',
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

  @override
  String get authWelcomeSubtitle =>
      'Photograph the pigeons of your city and climb your neighborhood\'s ranking.';

  @override
  String get authStep1 => 'Take a photo of a pigeon';

  @override
  String get authStep2 => 'The AI checks it\'s a real one';

  @override
  String get authStep3 =>
      'It stays on the map for 24 h, and in your Pigeondex forever';

  @override
  String get authContinueWithEmail => 'Continue with my email';

  @override
  String get authNoPassword => 'No password: a code by email is enough.';

  @override
  String get authEmailTitle => 'Your email address';

  @override
  String get authEmailSubtitle =>
      'We\'ll send you a 6-digit code. No password to remember.';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authReceiveCode => 'Get the code';

  @override
  String get authEmailPrivacy =>
      'Your email stays private: it never shows on the map or in the ranking.';

  @override
  String get authError => 'Something went wrong, try again.';

  @override
  String get authCodeInvalid => 'Wrong or expired code.';

  @override
  String get authCodeTitle => 'Check your emails';

  @override
  String authCodeSentTo(String email) {
    return 'Code sent to $email';
  }

  @override
  String get authEdit => 'Edit';

  @override
  String authResendIn(String time) {
    return 'Resend the code in $time';
  }

  @override
  String get authResend => 'Resend the code';

  @override
  String get authValidate => 'Confirm';

  @override
  String get authCodeHelp =>
      'Nothing received? Check your spam. The code expires after 1 hour.';

  @override
  String get authEmailVerified => 'Email verified';

  @override
  String get authPseudoTitle => 'Join the flock';

  @override
  String get authPseudoSubtitle =>
      'Your username will show on the map and in the ranking.';

  @override
  String get authPseudoLabel => 'Username';

  @override
  String get authPseudoHint => 'camille_coo';

  @override
  String get authAcceptTerms =>
      'I accept the terms of use and promise to only post real pigeons.';

  @override
  String get authTrainingConsent =>
      'I allow my photos to be used to train the AI (optional).';

  @override
  String get authLetsGo => 'Let\'s go';

  @override
  String get locationTitle => 'Where are the pigeons?';

  @override
  String get locationSubtitle =>
      'We use your location to center the map on you and place your photos. It is never shown to others.';

  @override
  String get locationAllow => 'Allow location';

  @override
  String get locationLater => 'Later';

  @override
  String get authUsernameTaken => 'This username is already taken.';

  @override
  String get cameraDenied =>
      'Camera access denied. Allow it in your phone\'s settings to photograph pigeons.';

  @override
  String get cameraUnavailable => 'No camera available on this device.';

  @override
  String get cameraShutter => 'Take the photo';

  @override
  String get cameraCaptureFailed => 'Couldn\'t take the photo, try again.';

  @override
  String get postDescriptionHint => 'Add a description (optional)';

  @override
  String get postPublish => 'Publish';

  @override
  String get postRetake => 'Retake';

  @override
  String get postPublished => 'Published! Your pigeon is on the map for 24 h.';

  @override
  String get postErrorLocationDenied =>
      'Location access denied: we need it to place your photo on the map.';

  @override
  String get postErrorLocation =>
      'Couldn\'t find your position. Check that location is on.';

  @override
  String get postErrorNetwork =>
      'No connection. Check your network and try again.';

  @override
  String get postErrorRateLimited =>
      'You\'ve posted a lot in the last hour. Try again later.';

  @override
  String get postErrorTooLarge => 'The photo is too large (5 MB max).';

  @override
  String get postErrorUnknown => 'Publishing failed, try again.';

  @override
  String get analysisRunning => 'The AI is inspecting your bird…';

  @override
  String get analysisRunningHint => 'Counting the pigeons, right on your phone';

  @override
  String analysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pigeons in the frame',
      one: '1 pigeon in the frame',
    );
    return '$_temp0';
  }

  @override
  String analysisConfidence(String species, int percent) {
    return '$species · $percent %';
  }

  @override
  String get analysisNone => 'No pigeon in sight.';

  @override
  String get analysisNoneChip => '0 pigeons';

  @override
  String get analysisNoneHint =>
      'The AI found no pigeon. Get closer or frame it better, then retake the photo.';

  @override
  String get analysisFailed => 'The analysis failed.';

  @override
  String get analysisFailedHint =>
      'The model couldn\'t run on this phone. Try again, or retake the photo.';

  @override
  String get analysisOnDevice =>
      'Counted on your phone · nothing leaves before you publish';

  @override
  String get postRetakePhoto => 'Retake the photo';

  @override
  String get speciesFeralPigeon => 'Feral pigeon';

  @override
  String get speciesWoodPigeon => 'Wood pigeon';

  @override
  String get speciesCollaredDove => 'Collared dove';

  @override
  String get speciesOther => 'Other bird';

  @override
  String get speciesUncertain => 'Uncertain';

  @override
  String get speciesUncertainHint => 'Uncertain · species to confirm';

  @override
  String analysisModel(String version, String source) {
    return 'Model $version · $source';
  }

  @override
  String get analysisModelDownloaded => 'downloaded';

  @override
  String get analysisModelBundled => 'bundled';
}
