import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../shared/utils/date_format.dart';
import '../../search/search_providers.dart';
import '../create_item_draft.dart';

/// 3. adım: başlık, kategori, açıklama, olay tarihi; doğrulama sorusu yalnızca
/// "Bulundu" ilanında.
class DetailsStep extends ConsumerStatefulWidget {
  const DetailsStep({super.key, required this.showErrors, required this.clock});

  /// İleri'ye basılıp hata çıktıysa alan hataları hemen görünür.
  final bool showErrors;
  final DateTime Function() clock;

  @override
  ConsumerState<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends ConsumerState<DetailsStep> {
  @override
  void initState() {
    super.initState();
    // Olay tarihi varsayılan olarak bugün.
    if (ref.read(createItemDraftProvider).eventDate == null) {
      Future.microtask(
        () => ref
            .read(createItemDraftProvider.notifier)
            .setEventDate(widget.clock()),
      );
    }
  }

  Future<void> _pickDate(DateTime? current) async {
    final now = widget.clock();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: 'Olay tarihi',
    );
    if (picked == null) return;
    // Bugün seçildiyse şu anki saat; geçmiş günde öğlen (gelecek olmasın).
    final value = DateUtils.isSameDay(picked, now)
        ? now
        : DateTime(picked.year, picked.month, picked.day, 12);
    ref.read(createItemDraftProvider.notifier).setEventDate(value);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createItemDraftProvider);
    final notifier = ref.read(createItemDraftProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final p = context.palette;
    final theme = Theme.of(context);
    final mode = widget.showErrors
        ? AutovalidateMode.always
        : AutovalidateMode.onUserInteraction;
    final dateError = widget.showErrors
        ? DraftRules.eventDate(draft.eventDate, widget.clock())
        : null;

    // Form alanları ekran dışına kayınca kaybolmasın diye tembel liste yerine
    // hepsini baştan kuran kaydırma görünümü.
    return Form(
      autovalidateMode: mode,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bilgiler', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: draft.title,
              onChanged: notifier.setTitle,
              validator: (v) => DraftRules.title(v ?? ''),
              maxLength: 100,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                hintText: 'ör. Siyah deri cüzdan',
              ),
            ),
            const SizedBox(height: 8),
            Text('Kategori', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            categories.when(
              data: (list) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in list)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: draft.categoryId == c.id,
                      onSelected: (_) => notifier.setCategory(c.id),
                    ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Row(
                children: [
                  const Expanded(child: Text('Kategoriler yüklenemedi.')),
                  TextButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: const Text('Tekrar dene'),
                  ),
                ],
              ),
            ),
            if (widget.showErrors && draft.categoryId == null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Kategori seçin.',
                  style: TextStyle(color: p.lostText, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  draft.type == ItemType.lost
                      ? 'Kaybolma tarihi'
                      : 'Bulunma tarihi',
                ),
                subtitle: Text(
                  draft.eventDate == null
                      ? 'Seçilmedi'
                      : formatDateTime(draft.eventDate!),
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _pickDate(draft.eventDate),
              ),
            ),
            if (dateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  dateError,
                  style: TextStyle(color: p.lostText, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: draft.description,
              onChanged: notifier.setDescription,
              validator: (v) => DraftRules.description(v ?? ''),
              maxLength: 2000,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Rengi, markası, nerede ve ne zaman…',
                alignLabelWithHint: true,
              ),
            ),
            if (draft.isFound) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: draft.verificationQuestion,
                onChanged: notifier.setVerificationQuestion,
                validator: (v) =>
                    DraftRules.verificationQuestion(v ?? '', found: true),
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Doğrulama sorusu',
                  hintText: 'ör. Cüzdandaki kart hangi bankanın?',
                  helperText:
                      'Yalnızca gerçek sahibin bilebileceği bir soru. '
                      'Soru ilanda görünmez, yalnızca talep edene sorulur.',
                  helperMaxLines: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
