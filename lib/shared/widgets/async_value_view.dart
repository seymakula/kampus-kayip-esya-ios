import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/app_exception.dart';
import 'placeholder_view.dart';

/// Her veri ekranının ortak yükleniyor / hata / boş / veri gösterimi.
///
/// ```dart
/// AsyncValueView(
///   value: ref.watch(itemListProvider(null)),
///   isEmpty: (items) => items.isEmpty,
///   onRetry: () => ref.invalidate(itemListProvider(null)),
///   data: (items) => ListView(...),
/// )
/// ```
///
/// Hafta 8'de iskelet kartlar (shimmer) ve hata türüne göre ikonlar eklenecek.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Henüz bir şey yok',
    this.emptyMessage = 'Burada gösterilecek kayıt bulunamadı.',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final VoidCallback? onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      // Yenilenirken eski veri ekranda kalır.
      AsyncValue(:final value?) =>
        (isEmpty?.call(value) ?? false)
            ? PlaceholderView(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage,
              )
            : data(value),
      AsyncError(:final error) => _ErrorView(error: error, onRetry: onRetry),
      _ => const Center(child: CircularProgressIndicator.adaptive()),
    };
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppException
        ? (error as AppException).message
        : 'Beklenmeyen bir hata oluştu.';
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
