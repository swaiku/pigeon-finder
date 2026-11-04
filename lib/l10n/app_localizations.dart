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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pigeon Finder'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Spot it. Snap it. Score it.'**
  String get tagline;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navPigeondex.
  ///
  /// In en, this message translates to:
  /// **'Pigeondex'**
  String get navPigeondex;

  /// No description provided for @navRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @pigeondexTitle.
  ///
  /// In en, this message translates to:
  /// **'Pigeondex'**
  String get pigeondexTitle;

  /// No description provided for @rankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get rankingTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraTitle;

  /// No description provided for @mapPigeonsAround.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pigeons around you} =1{1 pigeon around you} other{{count} pigeons around you}}'**
  String mapPigeonsAround(int count);

  /// No description provided for @mapPigeonsInArea.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pigeons in this area} =1{1 pigeon in this area} other{{count} pigeons in this area}}'**
  String mapPigeonsInArea(int count);

  /// No description provided for @mapExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours} h {minutes} min'**
  String mapExpiresIn(int hours, int minutes);

  /// No description provided for @mapPigeonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pigeon} other{{count} pigeons}}'**
  String mapPigeonCount(int count);

  /// No description provided for @mapReports.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 report} other{{count} reports}}'**
  String mapReports(int count);

  /// No description provided for @mapLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the map'**
  String get mapLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mapRecenter.
  ///
  /// In en, this message translates to:
  /// **'Center on my location'**
  String get mapRecenter;

  /// No description provided for @mapNorthLock.
  ///
  /// In en, this message translates to:
  /// **'Lock north'**
  String get mapNorthLock;

  /// No description provided for @mapNorthUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock north'**
  String get mapNorthUnlock;

  /// No description provided for @postDetailAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String postDetailAgoMinutes(int minutes);

  /// No description provided for @postDetailAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String postDetailAgoHours(int hours);

  /// No description provided for @postDetailCoo.
  ///
  /// In en, this message translates to:
  /// **'Coo · {count}'**
  String postDetailCoo(int count);

  /// No description provided for @postDetailReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get postDetailReport;

  /// No description provided for @postDetailReported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get postDetailReported;

  /// No description provided for @postDetailReportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Report sent'**
  String get postDetailReportThanks;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong?'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'At 3 reports, the AI double-checks and the photo may disappear. A valid report earns you +2 pts.'**
  String get reportSubtitle;

  /// No description provided for @reportReasonNotPigeon.
  ///
  /// In en, this message translates to:
  /// **'It\'s not a pigeon'**
  String get reportReasonNotPigeon;

  /// No description provided for @reportReasonGull.
  ///
  /// In en, this message translates to:
  /// **'It\'s a gull / seagull'**
  String get reportReasonGull;

  /// No description provided for @reportReasonStolen.
  ///
  /// In en, this message translates to:
  /// **'Photo found on the internet'**
  String get reportReasonStolen;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSubmit;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph the pigeons of your city and climb your neighborhood\'s ranking.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authStep1.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a pigeon'**
  String get authStep1;

  /// No description provided for @authStep2.
  ///
  /// In en, this message translates to:
  /// **'The AI checks it\'s a real one'**
  String get authStep2;

  /// No description provided for @authStep3.
  ///
  /// In en, this message translates to:
  /// **'It stays on the map for 24 h, and in your Pigeondex forever'**
  String get authStep3;

  /// No description provided for @authContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with my email'**
  String get authContinueWithEmail;

  /// No description provided for @authNoPassword.
  ///
  /// In en, this message translates to:
  /// **'No password: a code by email is enough.'**
  String get authNoPassword;

  /// No description provided for @authEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get authEmailTitle;

  /// No description provided for @authEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a 6-digit code. No password to remember.'**
  String get authEmailSubtitle;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Get the code'**
  String get authReceiveCode;

  /// No description provided for @authEmailPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your email stays private: it never shows on the map or in the ranking.'**
  String get authEmailPrivacy;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, try again.'**
  String get authError;

  /// No description provided for @authCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Wrong or expired code.'**
  String get authCodeInvalid;

  /// No description provided for @authCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your emails'**
  String get authCodeTitle;

  /// No description provided for @authCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}'**
  String authCodeSentTo(String email);

  /// No description provided for @authEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get authEdit;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend the code in {time}'**
  String authResendIn(String time);

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Resend the code'**
  String get authResend;

  /// No description provided for @authValidate.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authValidate;

  /// No description provided for @authCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Nothing received? Check your spam. The code expires after 1 hour.'**
  String get authCodeHelp;

  /// No description provided for @authEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get authEmailVerified;

  /// No description provided for @authPseudoTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the flock'**
  String get authPseudoTitle;

  /// No description provided for @authPseudoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your username will show on the map and in the ranking.'**
  String get authPseudoSubtitle;

  /// No description provided for @authPseudoLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authPseudoLabel;

  /// No description provided for @authPseudoHint.
  ///
  /// In en, this message translates to:
  /// **'camille_coo'**
  String get authPseudoHint;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use and promise to only post real pigeons.'**
  String get authAcceptTerms;

  /// No description provided for @authTrainingConsent.
  ///
  /// In en, this message translates to:
  /// **'I allow my photos to be used to train the AI (optional).'**
  String get authTrainingConsent;

  /// No description provided for @authLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get authLetsGo;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are the pigeons?'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use your location to center the map on you and place your photos. It is never shown to others.'**
  String get locationSubtitle;

  /// No description provided for @locationAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get locationAllow;

  /// No description provided for @locationLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get locationLater;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get authUsernameTaken;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied. Allow it in your phone\'s settings to photograph pigeons.'**
  String get cameraDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available on this device.'**
  String get cameraUnavailable;

  /// No description provided for @cameraShutter.
  ///
  /// In en, this message translates to:
  /// **'Take the photo'**
  String get cameraShutter;

  /// No description provided for @cameraCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t take the photo, try again.'**
  String get cameraCaptureFailed;

  /// No description provided for @postDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description (optional)'**
  String get postDescriptionHint;

  /// No description provided for @postPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get postPublish;

  /// No description provided for @postRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get postRetake;

  /// No description provided for @postPublished.
  ///
  /// In en, this message translates to:
  /// **'Published! Your pigeon is on the map for 24 h.'**
  String get postPublished;

  /// No description provided for @postErrorLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied: we need it to place your photo on the map.'**
  String get postErrorLocationDenied;

  /// No description provided for @postErrorLocation.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find your position. Check that location is on.'**
  String get postErrorLocation;

  /// No description provided for @postErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get postErrorNetwork;

  /// No description provided for @postErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'ve posted a lot in the last hour. Try again later.'**
  String get postErrorRateLimited;

  /// No description provided for @postErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo is too large (5 MB max).'**
  String get postErrorTooLarge;

  /// No description provided for @postErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Publishing failed, try again.'**
  String get postErrorUnknown;
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
