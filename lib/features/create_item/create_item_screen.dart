import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/core_providers.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../data/api/app_exception.dart';
import '../../data/models/models.dart';
import 'create_item_draft.dart';
import 'steps/details_step.dart';
import 'steps/location_step.dart';
import 'steps/photo_step.dart';
import 'steps/type_step.dart';

/// İlan aç: 4 adım (tür → fotoğraf → bilgiler → konum ve önizleme).
/// Taslak [createItemDraftProvider]'da; adımlar arasında kaybolmaz.
class CreateItemScreen extends ConsumerStatefulWidget {
  const CreateItemScreen({super.key, this.clock = DateTime.now});

  /// "Şimdi"; testlerde sabitlenir.
  final DateTime Function() clock;

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final _pages = PageController();
  var _step = CreateStep.type;

  /// İleri'ye basılıp hata çıkan adımlar; alan hataları bunlarda görünür.
  final _showErrors = <CreateStep>{};
  var _publishing = false;

  /// Düğmelerin üstünde gösterilen hata (snackbar düğmeleri örterdi).
  String? _error;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _goTo(CreateStep step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _error = null;
    });
    _pages.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    final draft = ref.read(createItemDraftProvider);
    final error = DraftRules.stepError(_step, draft, widget.clock());
    if (error != null) {
      setState(() {
        _showErrors.add(_step);
        _error = error;
      });
      return;
    }
    if (_step == CreateStep.location) {
      _publish();
    } else {
      _goTo(CreateStep.values[_step.index + 1]);
    }
  }

  Future<void> _publish() async {
    final notifier = ref.read(createItemDraftProvider.notifier);
    final draft = ref.read(createItemDraftProvider);
    final repo = ref.read(itemRepositoryProvider);
    setState(() {
      _publishing = true;
      _error = null;
    });
    try {
      final item = await repo.createItem(draft.toNewItem());
      if (draft.photos.isNotEmpty && mounted) {
        final uploaded = await _uploadWithRetry(item.id, draft.photos);
        if (!uploaded || !mounted) return;
      }
      if (!mounted) return;
      notifier.reset();
      _showErrors.clear();
      _step = CreateStep.type;
      _pages.jumpToPage(0);
      _message('İlanın görevli onayından sonra yayınlanacak.');
      // Hafta 6 (Barış): "İlanlarım" hazır olunca oraya yönlendir.
      context.go(AppRoutes.home);
    } on ValidationException catch (e) {
      final messages = e.errors.values.expand((m) => m).join('\n');
      setState(() => _error = messages.ifEmpty(e.message));
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  /// İlan açıldıktan sonra fotoğraflar yüklenir. Hata olursa ilan açık kalır;
  /// kullanıcı tekrar deneyebilir ya da fotoğrafsız devam edebilir.
  Future<bool> _uploadWithRetry(int itemId, List<String> photos) async {
    final repo = ref.read(itemRepositoryProvider);
    while (true) {
      if (!mounted) return false;
      final progress = ValueNotifier<double>(0);
      final dialog = showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _UploadDialog(progress: progress),
      );
      AppException? error;
      try {
        await repo.uploadPhotos(
          itemId,
          photos,
          onProgress: (p) => progress.value = p,
        );
      } on AppException catch (e) {
        error = e;
      }
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      await dialog;
      progress.dispose();
      if (error == null) return true;
      if (!mounted) return false;
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fotoğraflar yüklenemedi'),
          content: Text(
            'İlanın açıldı ama fotoğraflar yüklenemedi.\n${error!.message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Fotoğrafsız devam et'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
      if (retry != true) return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _step == CreateStep.location;
    // Adımların mesajları bu ekranın içinde, düğmelerin üstünde çıksın;
    // yoksa alt menünün üstündeki ortak alanda açılıp düğmeleri örterdi.
    // "Yayınlandı" mesajı bu State'in context'iyle ana alanda gösterilir.
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(title: const Text('Yeni İlan')),
        body: Column(
          children: [
            _StepHeader(step: _step),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const TypeStep(),
                  const PhotoStep(),
                  DetailsStep(
                    showErrors: _showErrors.contains(CreateStep.details),
                    clock: widget.clock,
                  ),
                  LocationStep(
                    showErrors: _showErrors.contains(CreateStep.location),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) _ErrorLine(text: _error!),
                Row(
                  children: [
                    if (_step != CreateStep.type)
                      OutlinedButton(
                        onPressed: _publishing
                            ? null
                            : () => _goTo(CreateStep.values[_step.index - 1]),
                        child: const Text('Geri'),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _publishing ? null : _next,
                      child: _publishing
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(last ? 'Yayınla' : 'İleri'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.lostText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final CreateStep step;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final s in CreateStep.values) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    decoration: BoxDecoration(
                      color: s.index <= step.index ? p.accent : p.surface2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (s != CreateStep.location) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Adım ${step.index + 1}/${CreateStep.values.length} · ${step.label}',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: p.muted),
          ),
        ],
      ),
    );
  }
}

class _UploadDialog extends StatelessWidget {
  const _UploadDialog({required this.progress});

  final ValueNotifier<double> progress;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fotoğraflar yükleniyor'),
      content: ValueListenableBuilder(
        valueListenable: progress,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: value),
            const SizedBox(height: 8),
            Text('%${(value * 100).round()}'),
          ],
        ),
      ),
    );
  }
}

/// Önizleme için taslaktan geçici ilan (henüz gönderilmedi).
Item previewItem(CreateItemDraft d, List<Category> categories, DateTime now) =>
    Item(
      id: 0,
      type: d.type ?? ItemType.found,
      status: ItemStatus.pending,
      title: d.title.trim().isEmpty ? 'Başlık' : d.title.trim(),
      description: d.description,
      category: categories.firstWhere(
        (c) => c.id == d.categoryId,
        orElse: () => const Category(id: 0, name: 'Kategori'),
      ),
      location: d.location ?? const Location(id: 0, building: 'Konum'),
      eventDate: d.eventDate ?? now,
      createdAt: now,
      isOwner: true,
      photos: [
        for (final (i, path) in d.photos.indexed)
          ItemPhoto(id: i, url: 'file://$path', sortOrder: i),
      ],
    );
