import 'package:flutter/material.dart';

import '../../../data/api/app_exception.dart';

/// Hafta 3'e kadar API'ye gidilmez: form geçerliyse kısa bir bekleme sonrası
/// ana sayfaya geçilir.
const mockAuthDelay = Duration(milliseconds: 600);

/// Giriş / kayıt formlarının ortak gönderme davranışı: klavyeyi kapatır,
/// doğrular, istek sürerken düğmeyi kilitler, [AppException] mesajını gösterir.
mixin AuthSubmitMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  bool busy = false;

  /// İlk gönderme denemesinden sonra alanlar yazarken doğrulanır.
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  Future<void> submitForm(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => busy = true);
    try {
      await action();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

/// Gönderirken dönen göstergeye dönüşen ana düğme.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(label),
    );
  }
}
