import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/theme/app_colors.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/shared/widgets/item_card.dart';

Future<void> _pump(WidgetTester tester, Item item, {VoidCallback? onTap}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ItemCard(
            item: item,
            onTap: onTap,
            now: item.eventDate.add(const Duration(hours: 3)),
          ),
        ),
      ),
    );

void main() {
  final found = mockItems.firstWhere((i) => i.id == 1);
  final noPhoto = mockItems.firstWhere((i) => i.photos.isEmpty);

  testWidgets('başlık, rozet, kategori, bina ve tarih görünür', (tester) async {
    await _pump(tester, found);

    expect(find.text(found.title), findsOneWidget);
    expect(find.text('Bulundu'), findsOneWidget);
    expect(find.text(found.category.name), findsOneWidget);
    expect(find.text(found.location.name), findsOneWidget);
    expect(find.text('3 saat önce'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('dokununca onTap çağrılır', (tester) async {
    var tapped = 0;
    await _pump(tester, found, onTap: () => tapped++);

    await tester.tap(find.byType(ItemCard));
    expect(tapped, 1);
  });

  testWidgets('fotoğrafsız ilanda yer tutucu simge', (tester) async {
    await _pump(tester, noPhoto);

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('rozet rengi ilan türüne göre', (tester) async {
    Color badgeColor(ItemType type) {
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ItemTypeBadge),
          matching: find.byType(DecoratedBox),
        ),
      );
      return (box.decoration as BoxDecoration).color!;
    }

    await tester.pumpWidget(
      const MaterialApp(home: ItemTypeBadge(type: ItemType.lost)),
    );
    expect(find.text('Kayıp'), findsOneWidget);
    expect(badgeColor(ItemType.lost), AppColors.lost);

    await tester.pumpWidget(
      const MaterialApp(home: ItemTypeBadge(type: ItemType.found)),
    );
    expect(badgeColor(ItemType.found), AppColors.found);
  });
}
