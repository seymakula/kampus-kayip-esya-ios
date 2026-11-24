import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/tag_badge.dart';

/// Giriş / kayıt sayfa başlığı (web `.auth-wrap h1` + `.lede`).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.palette.muted,
          ),
        ),
      ],
    );
  }
}

/// Form kartı (web `.form-card`): yüzey dolgusu, ince çizgi, 10 px köşe.
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// "Nasıl çalışır?" adımları; web'de giriş ve kayıt sayfalarının altında.
class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  static const _steps = [
    (
      'İlanını aç',
      'Kaybettiğin ya da bulduğun eşyayı bina, tarih ve fotoğrafla yaz.',
    ),
    (
      'Büro onaylar',
      'Kayıp eşya bürosu görevlisi ilanı kontrol eder ve yayına alır.',
    ),
    (
      'Sahibine ulaşır',
      'İletişim yalnızca uygulama içinden kurulur; telefon ve e-posta '
          'paylaşılmaz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TagBadge(
              label: 'KAYIP EŞYA BÜROSU',
              background: p.accent,
              foreground: p.onAccent,
            ),
            const SizedBox(height: 12),
            Text('Nasıl çalışır?', style: theme.textTheme.headlineSmall),
            for (final (i, (title, text)) in _steps.indexed) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: p.lineStrong),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: p.accentText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
