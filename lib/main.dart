import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/onboarding_prefs.dart';
import 'features/onboarding/onboarding_screen.dart';

// GEÇİCİ: Barış'ın tema + go_router iskeleti gelince MaterialApp.router'a
// geçilecek; tanıtım kararı router redirect'ine taşınacak.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  runApp(KampusKayipEsyaApp(onboardingPrefs: prefs));
}

class KampusKayipEsyaApp extends StatefulWidget {
  const KampusKayipEsyaApp({super.key, required this.onboardingPrefs});

  final OnboardingPrefs onboardingPrefs;

  @override
  State<KampusKayipEsyaApp> createState() => _KampusKayipEsyaAppState();
}

class _KampusKayipEsyaAppState extends State<KampusKayipEsyaApp> {
  late bool _showOnboarding = !widget.onboardingPrefs.seen;

  Future<void> _finishOnboarding() async {
    await widget.onboardingPrefs.markSeen();
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kampüs Kayıp Eşya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: _showOnboarding
          ? OnboardingScreen(onFinished: _finishOnboarding)
          : const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Ana sayfa (Barış: 5 sekmeli menü)')),
    );
  }
}
