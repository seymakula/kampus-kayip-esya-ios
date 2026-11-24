import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/theme/app_colors.dart';
import 'package:kampus_kayip_esya/shared/widgets/tag_badge.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/shared/widgets/item_card.dart';

Future<void> _pump(WidgetTester tester, Item item, {VoidCallback? onTap}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              ItemCard(
                item: item,
                onTap: onTap,
                now: item.eventDate.add(const Duration(hours: 3)),
              ),
            ],
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
    expect(find.text('BULUNDU'), findsOneWidget);
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

  testWidgets('fotoğrafsız ilanda türüne göre etiket yer tutucu', (
    tester,
  ) async {
    await _pump(tester, noPhoto);

    expect(find.byType(Image), findsNothing);
    final placeholder = tester.widget<PlaceholderTag>(
      find.byType(PlaceholderTag),
    );
    expect(placeholder.type, noPhoto.type);
    expect(placeholder.icon, categoryIcon(noPhoto.category.icon));
  });

  testWidgets('tür etiketi: büyük harf, türe göre dolgu', (tester) async {
    Color fill() {
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(TagBadge),
          matching: find.byType(CustomPaint),
        ),
      );
      // ignore: avoid_dynamic_calls
      return (paint.painter as dynamic).fill as Color;
    }

    for (final (type, label, color) in [
      (ItemType.lost, 'KAYIP', AppPalette.light.lost),
      (ItemType.found, 'BULUNDU', AppPalette.light.found),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Center(child: ItemTypeBadge(type: type)),
        ),
      );
      expect(find.text(label), findsOneWidget);
      expect(fill(), color, reason: '$type');
    }
  });

  testWidgets('koyu temada ve küçük ekranda taşma yok', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    for (final item in [found, noPhoto]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: ListView(children: [ItemCard(item: item)]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
