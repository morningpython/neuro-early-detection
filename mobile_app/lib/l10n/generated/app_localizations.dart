import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('sw'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'NeuroAccess'**
  String get appTitle;

  /// Welcome greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get welcomeGreeting;

  /// CHW title
  ///
  /// In en, this message translates to:
  /// **'Community Health Worker'**
  String get communityHealthWorker;

  /// Welcome message explaining the app purpose
  ///
  /// In en, this message translates to:
  /// **'Start early Parkinson\'s disease screening through voice analysis.'**
  String get welcomeMessage;

  /// Button text to start a new screening
  ///
  /// In en, this message translates to:
  /// **'Start Screening'**
  String get startScreening;

  /// Section title for recent screenings list
  ///
  /// In en, this message translates to:
  /// **'Recent Screenings'**
  String get recentScreenings;

  /// Empty state message when no screenings exist
  ///
  /// In en, this message translates to:
  /// **'No screenings yet.\nTap the button above to start.'**
  String get noScreeningsYet;

  /// Section title for statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Label for total screenings count
  ///
  /// In en, this message translates to:
  /// **'Total Screenings'**
  String get totalScreenings;

  /// Low risk category label
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// Medium risk category label
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// High risk category label
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// Age display format
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Title for patient info screen
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformation;

  /// Label for age input
  ///
  /// In en, this message translates to:
  /// **'Patient Age'**
  String get patientAge;

  /// Label for gender selection
  ///
  /// In en, this message translates to:
  /// **'Patient Gender'**
  String get patientGender;

  /// Label for consent section
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consent;

  /// Consent checkbox message
  ///
  /// In en, this message translates to:
  /// **'The patient consents to voice recording for Parkinson\'s disease screening purposes.'**
  String get consentMessage;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for voice recording screen
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// Instruction for phone positioning
  ///
  /// In en, this message translates to:
  /// **'Hold phone 6 inches from mouth'**
  String get holdPhoneInstruction;

  /// Instruction for voice task
  ///
  /// In en, this message translates to:
  /// **'Say \'Ahhh\' clearly for the duration'**
  String get sayAhInstruction;

  /// Button text before recording starts
  ///
  /// In en, this message translates to:
  /// **'Tap to Start'**
  String get tapToStart;

  /// Text shown while recording
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// Text shown while processing
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Countdown timer display
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String secondsRemaining(int seconds);

  /// Message shown during AI analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing voice sample...'**
  String get analyzing;

  /// Title for results screen
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Section title for risk assessment
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get riskAssessment;

  /// Message for low risk result
  ///
  /// In en, this message translates to:
  /// **'No immediate concern. Continue routine health monitoring.'**
  String get lowRiskMessage;

  /// Message for medium risk result
  ///
  /// In en, this message translates to:
  /// **'Possible early signs detected. We recommend re-screening in 6 months.'**
  String get mediumRiskMessage;

  /// Message for high risk result
  ///
  /// In en, this message translates to:
  /// **'We recommend consultation with a neurologist for further evaluation.'**
  String get highRiskMessage;

  /// Button text for hospital referral
  ///
  /// In en, this message translates to:
  /// **'Refer to Hospital'**
  String get referToHospital;

  /// Button text for scheduling follow-up
  ///
  /// In en, this message translates to:
  /// **'Schedule Follow-up'**
  String get scheduleFollowUp;

  /// Button text to save and return home
  ///
  /// In en, this message translates to:
  /// **'Save & Finish'**
  String get saveAndFinish;

  /// Button text to re-record
  ///
  /// In en, this message translates to:
  /// **'Record Again'**
  String get recordAgain;

  /// Label for confidence score
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Button text to expand details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Button text to collapse details
  ///
  /// In en, this message translates to:
  /// **'Hide Details'**
  String get hideDetails;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Swahili language name
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// Label for about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Label for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Label for terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Button text to retry action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Success message after saving screening
  ///
  /// In en, this message translates to:
  /// **'Screening saved successfully'**
  String get screeningSaved;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Message for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this screening?'**
  String get deleteConfirmMessage;

  /// Age validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age (18-120)'**
  String get pleaseEnterValidAge;

  /// Gender validation error message
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get pleaseSelectGender;

  /// Consent validation error message
  ///
  /// In en, this message translates to:
  /// **'Please provide consent to continue'**
  String get pleaseProvideConsent;

  /// Title shown when screening is complete
  ///
  /// In en, this message translates to:
  /// **'Screening Complete'**
  String get screeningComplete;

  /// Section title for recommended action
  ///
  /// In en, this message translates to:
  /// **'Recommended Action'**
  String get recommendedAction;

  /// Low risk status title
  ///
  /// In en, this message translates to:
  /// **'No Immediate Concern'**
  String get noImmediateConcern;

  /// Medium risk status title
  ///
  /// In en, this message translates to:
  /// **'Monitoring Recommended'**
  String get monitorRecommended;

  /// High risk status title
  ///
  /// In en, this message translates to:
  /// **'Consultation Recommended'**
  String get consultationRecommended;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
