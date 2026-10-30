import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/onboarding/onboarding_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  runApp(KampusKayipEsyaApp(onboardingPrefs: prefs));
}
