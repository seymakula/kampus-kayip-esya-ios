import 'package:shared_preferences/shared_preferences.dart';

/// Tanıtımın daha önce görülüp görülmediğini saklar.
class OnboardingPrefs {
  OnboardingPrefs(this._prefs);

  static const _seenKey = 'onboarding_seen';

  final SharedPreferences _prefs;

  bool get seen => _prefs.getBool(_seenKey) ?? false;

  Future<void> markSeen() => _prefs.setBool(_seenKey, true);
}
