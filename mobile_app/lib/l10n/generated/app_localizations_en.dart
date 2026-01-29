// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NeuroAccess';

  @override
  String get welcomeGreeting => 'Hello!';

  @override
  String get communityHealthWorker => 'Community Health Worker';

  @override
  String get welcomeMessage =>
      'Start early Parkinson\'s disease screening through voice analysis.';

  @override
  String get startScreening => 'Start Screening';

  @override
  String get recentScreenings => 'Recent Screenings';

  @override
  String get noScreeningsYet =>
      'No screenings yet.\nTap the button above to start.';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalScreenings => 'Total Screenings';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get mediumRisk => 'Medium Risk';

  @override
  String get highRisk => 'High Risk';

  @override
  String yearsOld(int age) {
    return '$age years old';
  }

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get patientInformation => 'Patient Information';

  @override
  String get patientAge => 'Patient Age';

  @override
  String get patientGender => 'Patient Gender';

  @override
  String get consent => 'Consent';

  @override
  String get consentMessage =>
      'The patient consents to voice recording for Parkinson\'s disease screening purposes.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get voiceRecording => 'Voice Recording';

  @override
  String get holdPhoneInstruction => 'Hold phone 6 inches from mouth';

  @override
  String get sayAhInstruction => 'Say \'Ahhh\' clearly for the duration';

  @override
  String get tapToStart => 'Tap to Start';

  @override
  String get recording => 'Recording...';

  @override
  String get processing => 'Processing...';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get analyzing => 'Analyzing voice sample...';

  @override
  String get results => 'Results';

  @override
  String get riskAssessment => 'Risk Assessment';

  @override
  String get lowRiskMessage =>
      'No immediate concern. Continue routine health monitoring.';

  @override
  String get mediumRiskMessage =>
      'Possible early signs detected. We recommend re-screening in 6 months.';

  @override
  String get highRiskMessage =>
      'We recommend consultation with a neurologist for further evaluation.';

  @override
  String get referToHospital => 'Refer to Hospital';

  @override
  String get scheduleFollowUp => 'Schedule Follow-up';

  @override
  String get saveAndFinish => 'Save & Finish';

  @override
  String get recordAgain => 'Record Again';

  @override
  String get confidence => 'Confidence';

  @override
  String get viewDetails => 'View Details';

  @override
  String get hideDetails => 'Hide Details';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Swahili';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get screeningSaved => 'Screening saved successfully';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this screening?';

  @override
  String get pleaseEnterValidAge => 'Please enter a valid age (18-120)';

  @override
  String get pleaseSelectGender => 'Please select a gender';

  @override
  String get pleaseProvideConsent => 'Please provide consent to continue';

  @override
  String get screeningComplete => 'Screening Complete';

  @override
  String get recommendedAction => 'Recommended Action';

  @override
  String get noImmediateConcern => 'No Immediate Concern';

  @override
  String get monitorRecommended => 'Monitoring Recommended';

  @override
  String get consultationRecommended => 'Consultation Recommended';
}
