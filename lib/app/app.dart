import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_prefs.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class KampusKayipEsyaApp extends StatefulWidget {
  const KampusKayipEsyaApp({super.key, required this.onboardingPrefs});

  final OnboardingPrefs onboardingPrefs;

  @override
  State<KampusKayipEsyaApp> createState() => _KampusKayipEsyaAppState();
}

class _KampusKayipEsyaAppState extends State<KampusKayipEsyaApp> {
  // Router bir kez oluşturulur; build'de oluşturulursa gezinme durumu sıfırlanır.
  late final GoRouter _router =
      createAppRouter(onboardingPrefs: widget.onboardingPrefs);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kampüs Kayıp Eşya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
