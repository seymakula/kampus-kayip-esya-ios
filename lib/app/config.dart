/// API adresi derleme anında verilir:
///
/// ```bash
/// # Simülatör (API aynı Mac'te)
/// flutter run --dart-define=API_BASE=http://localhost:5080
/// # Gerçek iPhone (Mac'in yerel IP'si: ipconfig getifaddr en0)
/// flutter run --dart-define=API_BASE=http://192.168.1.20:5080
/// ```
const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:5080',
);

/// Tüm istekler için bağlanma / yanıt bekleme süresi.
const apiTimeout = Duration(seconds: 10);
