import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neuro_access/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider', () {
    late LocaleProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = LocaleProvider();
    });

    test('should have default locale as English', () {
      expect(provider.locale, const Locale('en'));
    });

    test('should return correct currentLocaleName', () {
      expect(provider.currentLocaleName, 'English');
    });

    test('should have correct supportedLocales', () {
      expect(LocaleProvider.supportedLocales, contains(const Locale('en')));
      expect(LocaleProvider.supportedLocales, contains(const Locale('sw')));
      expect(LocaleProvider.supportedLocales.length, 2);
    });

    test('should have correct localeNames map', () {
      expect(LocaleProvider.localeNames['en'], 'English');
      expect(LocaleProvider.localeNames['sw'], 'Kiswahili');
    });

    test('getLocaleName should return correct name', () {
      expect(provider.getLocaleName('en'), 'English');
      expect(provider.getLocaleName('sw'), 'Kiswahili');
    });

    test('getLocaleName should return code for unknown locale', () {
      expect(provider.getLocaleName('fr'), 'fr');
    });

    test('setLocale should change locale and notify listeners', () async {
      bool notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('sw'));

      expect(provider.locale, const Locale('sw'));
      expect(provider.currentLocaleName, 'Kiswahili');
      expect(notified, true);
    });

    test('setLocale should not notify if same locale', () async {
      bool notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('en')); // same as default

      expect(notified, false);
    });

    test('setLocale should not accept unsupported locale', () async {
      bool notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('fr')); // unsupported

      expect(provider.locale, const Locale('en')); // unchanged
      expect(notified, false);
    });

    test('loadLocale should restore saved locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'sw'});
      final newProvider = LocaleProvider();

      await newProvider.loadLocale();

      expect(newProvider.locale, const Locale('sw'));
    });

    test('setLocale should persist to SharedPreferences', () async {
      await provider.setLocale(const Locale('sw'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'sw');
    });
  });
}
