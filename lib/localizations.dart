import 'package:flutter/material.dart';

class SampleLocalizationsDelegate extends LocalizationsDelegate<Localized> {
  const SampleLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);
  @override
  Future<Localized> load(Locale locale) async => Localized(locale);
  @override
  bool shouldReload(SampleLocalizationsDelegate old) => false;
}

class Localized {
  Localized(this.locale);
  final Locale locale;

  static Localized of(BuildContext context) {
    return Localizations.of (context, Localized)!;
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings_title': 'If you dont see the WifiName, please allow the app in Settings Privacy Protection Location.',
    },
    'ja': {
      'settings_title': 'WifiNameが出ない場合、設定 プライバシー保護 位置情報 でアプリを許可してください。',
    },
  };

  String? get title {
    return _localizedValues[locale.languageCode]?['title'];
  }
  String? text(String text) {
    if (locale.languageCode == "ja")
      return _localizedValues["ja"]?[text];
    else
      return _localizedValues["en"]?[text];
  }
}

