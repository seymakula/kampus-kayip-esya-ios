import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../app/providers/core_providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: const [
          _SectionTitle('Görünüm'),
          _ThemePlaceholder(),
          // Yalnızca debug derlemede: gösterimde ağ değişirse IP buradan girilir.
          if (kDebugMode) ...[
            Divider(),
            _SectionTitle('Geliştirici'),
            _ApiBaseUrlField(),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Hafta 8 (Şeyma): Sistem / Açık / Koyu seçimi çalışacak ve kalıcı olacak.
class _ThemePlaceholder extends StatelessWidget {
  const _ThemePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
                ButtonSegment(value: ThemeMode.light, label: Text('Açık')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Koyu')),
              ],
              selected: const {ThemeMode.system},
              onSelectionChanged: null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Şimdilik telefonun ayarını izliyor; tema seçimi yakında.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// `http://192.168.1.20:5080` gibi bir adresi doğrular; geçerliyse sondaki
/// `/` atılmış halini, değilse `null` döner.
String? normalizeApiBaseUrl(String input) {
  final text = input.trim().replaceFirst(RegExp(r'/+$'), '');
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  return text;
}

class _ApiBaseUrlField extends ConsumerStatefulWidget {
  const _ApiBaseUrlField();

  @override
  ConsumerState<_ApiBaseUrlField> createState() => _ApiBaseUrlFieldState();
}

class _ApiBaseUrlFieldState extends ConsumerState<_ApiBaseUrlField> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: ref.read(apiBaseUrlProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final url = normalizeApiBaseUrl(_controller.text)!;
    await ref.read(apiBaseUrlProvider.notifier).set(url);
    _controller.text = url;
    if (mounted) _showMessage('API adresi kaydedildi.');
  }

  Future<void> _reset() async {
    await ref.read(apiBaseUrlProvider.notifier).reset();
    _controller.text = apiBase;
    if (mounted) _showMessage('Varsayılan adrese dönüldü.');
  }

  @override
  Widget build(BuildContext context) {
    final overridden = ref.watch(
      apiBaseUrlProvider.select((url) => url != apiBase),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (value) => normalizeApiBaseUrl(value ?? '') == null
                  ? 'Geçerli bir adres gir (ör. http://192.168.1.20:5080).'
                  : null,
              decoration: InputDecoration(
                labelText: 'API adresi',
                prefixIcon: const Icon(Icons.dns_outlined),
                helperText: 'Varsayılan: $apiBase',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yalnızca debug derlemede görünür. Başka sunucuya geçince '
              'yeniden giriş yapman gerekebilir.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            // Temada düğmeler tam genişlik; yan yana değil alt alta.
            FilledButton(onPressed: _save, child: const Text('Kaydet')),
            if (overridden)
              TextButton(
                onPressed: _reset,
                child: const Text('Varsayılana dön'),
              ),
          ],
        ),
      ),
    );
  }
}
