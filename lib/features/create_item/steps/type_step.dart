import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../create_item_draft.dart';

/// 1. adım: Kayıp mı, Bulundu mu?
class TypeStep extends ConsumerWidget {
  const TypeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(createItemDraftProvider.select((d) => d.type));
    final notifier = ref.read(createItemDraftProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ne oldu?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'İlanın türünü seç.',
          style: TextStyle(color: context.palette.muted),
        ),
        const SizedBox(height: 16),
        _TypeCard(
          type: ItemType.lost,
          icon: Icons.search,
          title: 'Bir şeyimi kaybettim',
          subtitle: 'Eşyanı bulan kişi sana uygulama içinden ulaşır.',
          selected: selected == ItemType.lost,
          onTap: () => notifier.setType(ItemType.lost),
        ),
        const SizedBox(height: 12),
        _TypeCard(
          type: ItemType.found,
          icon: Icons.volunteer_activism_outlined,
          title: 'Bir eşya buldum',
          subtitle: 'Sahibinin bilebileceği bir doğrulama sorusu ekleyeceksin.',
          selected: selected == ItemType.found,
          onTap: () => notifier.setType(ItemType.found),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final ItemType type;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fill = type == ItemType.lost ? p.lost : p.found;
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? p.accent : p.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: fill,
                  child: Icon(icon, color: p.onTag),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: p.muted)),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? p.accentText : p.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
