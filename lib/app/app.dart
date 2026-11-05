import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_prefs.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class KampusKayipEsyaApp extends ConsumerStatefulWidget {
  const KampusKayipEsyaApp({super.key, required this.onboardingPrefs});

  final OnboardingPrefs onboardingPrefs;

  @override
  ConsumerState<KampusKayipEsyaApp> createState() => _KampusKayipEsyaAppState();
}

class _KampusKayipEsyaAppState extends ConsumerState<KampusKayipEsyaApp> {
  // Router'ın dinlediği oturum durumu; Riverpod'dan buraya aktarılır.
  final _authStatus = ValueNotifier(AuthStatus.unknown);

  // Router bir kez oluşturulur; build'de oluşturulursa gezinme durumu sıfırlanır.
  late final GoRouter _router = createAppRouter(
    onboardingPrefs: widget.onboardingPrefs,
    authStatus: _authStatus,
  );

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      authStateProvider,
      (_, next) => _authStatus.value = next.status,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authStatus.dispose();
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
