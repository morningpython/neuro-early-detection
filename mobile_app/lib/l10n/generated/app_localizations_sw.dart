// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'NeuroAccess';

  @override
  String get welcomeGreeting => 'Habari!';

  @override
  String get communityHealthWorker => 'Mfanyakazi wa Afya ya Jamii';

  @override
  String get welcomeMessage =>
      'Anza uchunguzi wa mapema wa ugonjwa wa Parkinson kupitia uchambuzi wa sauti.';

  @override
  String get startScreening => 'Anza Uchunguzi';

  @override
  String get recentScreenings => 'Uchunguzi wa Hivi Karibuni';

  @override
  String get noScreeningsYet =>
      'Hakuna uchunguzi bado.\nGusa kitufe hapo juu kuanza.';

  @override
  String get statistics => 'Takwimu';

  @override
  String get totalScreenings => 'Jumla ya Uchunguzi';

  @override
  String get lowRisk => 'Hatari ya Chini';

  @override
  String get mediumRisk => 'Hatari ya Wastani';

  @override
  String get highRisk => 'Hatari Kubwa';

  @override
  String yearsOld(int age) {
    return 'Miaka $age';
  }

  @override
  String get male => 'Kiume';

  @override
  String get female => 'Kike';

  @override
  String get other => 'Nyingine';

  @override
  String get patientInformation => 'Taarifa za Mgonjwa';

  @override
  String get patientAge => 'Umri wa Mgonjwa';

  @override
  String get patientGender => 'Jinsia ya Mgonjwa';

  @override
  String get consent => 'Ridhaa';

  @override
  String get consentMessage =>
      'Mgonjwa anakubali kurekodi sauti kwa madhumuni ya uchunguzi wa ugonjwa wa Parkinson.';

  @override
  String get next => 'Endelea';

  @override
  String get back => 'Rudi';

  @override
  String get cancel => 'Ghairi';

  @override
  String get save => 'Hifadhi';

  @override
  String get delete => 'Futa';

  @override
  String get voiceRecording => 'Kurekodi Sauti';

  @override
  String get holdPhoneInstruction => 'Shika simu inchi 6 kutoka kinywani';

  @override
  String get sayAhInstruction => 'Sema \'Ahhh\' kwa uwazi kwa muda wote';

  @override
  String get tapToStart => 'Gusa Kuanza';

  @override
  String get recording => 'Inarekodi...';

  @override
  String get processing => 'Inachakata...';

  @override
  String secondsRemaining(int seconds) {
    return 'Sekunde $seconds';
  }

  @override
  String get analyzing => 'Inachambua sampuli ya sauti...';

  @override
  String get results => 'Matokeo';

  @override
  String get riskAssessment => 'Tathmini ya Hatari';

  @override
  String get lowRiskMessage =>
      'Hakuna wasiwasi wa haraka. Endelea na ufuatiliaji wa afya wa kawaida.';

  @override
  String get mediumRiskMessage =>
      'Huenda dalili za mapema zimegunduliwa. Tunapendekeza uchunguzi tena baada ya miezi 6.';

  @override
  String get highRiskMessage =>
      'Tunapendekeza mashauriano na daktari wa neva kwa tathmini zaidi.';

  @override
  String get referToHospital => 'Mpeleke Hospitali';

  @override
  String get scheduleFollowUp => 'Panga Ufuatiliaji';

  @override
  String get saveAndFinish => 'Hifadhi na Maliza';

  @override
  String get recordAgain => 'Rekodi Tena';

  @override
  String get confidence => 'Uhakika';

  @override
  String get viewDetails => 'Angalia Maelezo';

  @override
  String get hideDetails => 'Ficha Maelezo';

  @override
  String get settings => 'Mipangilio';

  @override
  String get language => 'Lugha';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get about => 'Kuhusu';

  @override
  String get version => 'Toleo';

  @override
  String get privacyPolicy => 'Sera ya Faragha';

  @override
  String get termsOfService => 'Masharti ya Huduma';

  @override
  String get errorOccurred => 'Kosa limetokea';

  @override
  String get tryAgain => 'Jaribu Tena';

  @override
  String get screeningSaved => 'Uchunguzi umehifadhiwa kwa mafanikio';

  @override
  String get confirmDelete => 'Thibitisha Kufuta';

  @override
  String get deleteConfirmMessage =>
      'Una uhakika unataka kufuta uchunguzi huu?';

  @override
  String get pleaseEnterValidAge => 'Tafadhali ingiza umri halali (18-120)';

  @override
  String get pleaseSelectGender => 'Tafadhali chagua jinsia';

  @override
  String get pleaseProvideConsent => 'Tafadhali toa ridhaa kuendelea';

  @override
  String get screeningComplete => 'Uchunguzi Umekamilika';

  @override
  String get recommendedAction => 'Hatua Inayopendekezwa';

  @override
  String get noImmediateConcern => 'Hakuna Wasiwasi wa Haraka';

  @override
  String get monitorRecommended => 'Ufuatiliaji Unapendekezwa';

  @override
  String get consultationRecommended => 'Mashauriano Yanapendekezwa';
}
