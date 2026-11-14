import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';

void main() {
  testWidgets('düğmeler Row içinde yan yana durabilir (çökmez)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Kaydet')),
              OutlinedButton(onPressed: () {}, child: const Text('İptal')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(FilledButton));
    expect(size.height, 48);
    expect(size.width, lessThan(400));
  });

  testWidgets('genişliği veren yerde tam genişlik kalır', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ListView(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Giriş yap')),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(FilledButton)).width,
      tester.getSize(find.byType(ListView)).width,
    );
  });
}
