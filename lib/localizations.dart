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
      'msg_nowifiname': 'If you dont see the WifiName, please allow the app in Settings Privacy Protection Location.',
      'guide_wifi': 'Update Wifi',
      'guide_scan': 'Scan IP Address',
      'guide_upnp': 'Scan UPnP',
      'guide_dark': 'Darkmode',
    },
    'ja': {
      'msg_nowifiname': 'WifiName が出ない場合、設定 プライバシー保護 位置情報 でアプリを許可してください。',
      'guide_wifi': 'Wifi 情報を更新',
      'guide_scan': 'IP アドレススキャン',
      'guide_upnp': 'UPnP 機器スキャン',
      'guide_dark': 'ダークモード',
    },
  };

  String text(String text) {
    String? str;
    if (locale.languageCode == "ja")
      str = _localizedValues["ja"]?[text];
    else
      str = _localizedValues["en"]?[text];
    return str ?? '';
  }
}

