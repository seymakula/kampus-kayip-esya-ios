import 'package:flutter/material.dart';

import '../../../data/api/app_exception.dart';

/// Giriş / kayıt formlarının ortak gönderme davranışı: klavyeyi kapatır,
/// doğrular, istek sürerken düğmeyi kilitler. Sunucunun alan hataları
/// ([ValidationException]) ilgili alanın altında, diğer hatalar kısa mesajla
/// gösterilir.
mixin AuthSubmitMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  bool busy = false;

  /// İlk gönderme denemesinden sonra alanlar yazarken doğrulanır.
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  /// Sunucu hatası gösterilebilen alanlar: API alan adı → form alanı.
  Map<String, TextEditingController> get serverFields;

  /// Sunucunun reddettiği alanlar; hata yalnızca reddedilen değer alanda
  /// durduğu sürece gösterilir, kullanıcı yazınca kaybolur.
  final _serverErrors = <String, ({String message, String value})>{};

  /// Alanın doğrulayıcısını sunucu hatasını da gösterecek şekilde sarar.
  FormFieldValidator<String> withServerError(
    String field,
    FormFieldValidator<String> validator,
  ) => (value) {
    final error = _serverErrors[field];
    return error != null && error.value == value
        ? error.message
        : validator(value);
  };

  Future<void> submitForm(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    _serverErrors.clear();
    if (!formKey.currentState!.validate()) {
      setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => busy = true);
    try {
      await action();
    } on ValidationException catch (e) {
      if (mounted) _showValidationErrors(e);
    } on AppException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      // Ör. Keychain yazılamadı: düğme sessizce eski haline dönmesin.
      if (mounted) _showMessage('Beklenmeyen bir hata oluştu. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _showValidationErrors(ValidationException e) {
    for (final MapEntry(key: field, value: controller)
        in serverFields.entries) {
      final message = e.errorFor(field);
      if (message != null) {
        _serverErrors[field] = (message: message, value: controller.text);
      }
    }
    setState(() => autovalidateMode = AutovalidateMode.onUserInteraction);
    formKey.currentState!.validate();

    // Hiçbir alana bağlanamayan hatalar (ör. Identity şifre kuralları) kaybolmasın.
    final fields = serverFields.keys.map((f) => f.toLowerCase()).toSet();
    final others = [
      for (final MapEntry(:key, :value) in e.errors.entries)
        if (!fields.contains(key.toLowerCase())) ...value,
    ];
    if (others.isNotEmpty) {
      _showMessage(others.join('\n'));
    } else if (_serverErrors.isEmpty) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
