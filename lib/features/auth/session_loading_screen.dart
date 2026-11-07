import 'package:flutter/material.dart';

/// Açılışta kayıtlı oturum kontrol edilirken görünür (Keychain + `/api/auth/me`).
/// Sonuca göre router ana sayfaya veya girişe yönlendirir.
class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
