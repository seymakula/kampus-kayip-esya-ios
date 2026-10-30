/// Giriş ve kayıt formlarının doğrulayıcıları. Hepsi `TextFormField.validator`
/// imzasındadır: geçerliyse `null`, değilse Türkçe hata mesajı döner.
/// Sunucu da aynı kuralları uygular; buradaki kontrol yalnızca hızlı geri bildirim içindir.
abstract final class AuthValidators {
  /// Öğrenci (`@ogrenci.ankara.edu.tr`) ve personel (`@ankara.edu.tr`) adresleri.
  static const schoolDomain = 'ankara.edu.tr';

  static const minPasswordLength = 8;

  static final _emailPattern = RegExp(r'^[^\s@]+@([a-z0-9-]+\.)+[a-z]{2,}$');
  static final _digitsOnly = RegExp(r'^\d+$');

  static String? schoolEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'E-posta adresini gir.';
    if (!_emailPattern.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi gir.';
    }
    final domain = email.split('@').last;
    if (domain != schoolDomain && !domain.endsWith('.$schoolDomain')) {
      return 'Okul e-postanı kullan (@$schoolDomain).';
    }
    return null;
  }

  /// Girişte yalnızca boş olmaması aranır; kurallar kayıtta uygulanır.
  static String? loginPassword(String? value) =>
      (value ?? '').isEmpty ? 'Şifreni gir.' : null;

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Bir şifre belirle.';
    if (password.length < minPasswordLength) {
      return 'Şifre en az $minPasswordLength karakter olmalı.';
    }
    if (!password.contains(RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]')) ||
        !password.contains(RegExp(r'\d'))) {
      return 'Şifre en az bir harf ve bir rakam içermeli.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() password,
  ) => (value) {
    if ((value ?? '').isEmpty) return 'Şifreni tekrar gir.';
    return value == password() ? null : 'Şifreler eşleşmiyor.';
  };

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Adını ve soyadını gir.';
    if (name.split(RegExp(r'\s+')).length < 2) {
      return 'Ad ve soyadını birlikte yaz.';
    }
    return null;
  }

  static String? studentNo(String? value) {
    final no = value?.trim() ?? '';
    if (no.isEmpty) return 'Öğrenci / personel numaranı gir.';
    if (!_digitsOnly.hasMatch(no)) {
      return 'Numara yalnızca rakamlardan oluşmalı.';
    }
    if (no.length < 5 || no.length > 12) return 'Numara 5–12 haneli olmalı.';
    return null;
  }
}
