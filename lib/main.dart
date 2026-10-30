import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/onboarding/onboarding_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  runApp(
    ProviderScope(
      // Otomatik yeniden deneme kapalı: hata ekranda görünür,
      // kullanıcı "Tekrar dene" ile kendisi yeniler.
      retry: (retryCount, error) => null,
      child: KampusKayipEsyaApp(onboardingPrefs: prefs),
    ),
  );
}
