// lib/utils/shared_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _consentKey = 'user_consent_given';

  static Future<bool> getUserConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  static Future<void> setUserConsent(bool given) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, given);
  }
}
