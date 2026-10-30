import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/shared/widgets/async_value_view.dart';

Widget _wrap(AsyncValue<List<int>> value, {VoidCallback? onRetry}) =>
    MaterialApp(
      home: Scaffold(
        body: AsyncValueView<List<int>>(
          value: value,
          isEmpty: (l) => l.isEmpty,
          emptyTitle: 'Boş liste',
          onRetry: onRetry,
          data: (l) => Text('${l.length} kayıt'),
        ),
      ),
    );

void main() {
  testWidgets('yükleniyor', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('veri', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncData([1, 2, 3])));
    expect(find.text('3 kayıt'), findsOneWidget);
  });

  testWidgets('boş', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncData([])));
    expect(find.text('Boş liste'), findsOneWidget);
  });

  testWidgets('hata: AppException mesajı ve Tekrar dene', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        const AsyncError(NetworkException('Bağlantı yok'), StackTrace.empty),
        onRetry: () => retried = true,
      ),
    );
    expect(find.text('Bağlantı yok'), findsOneWidget);
    await tester.tap(find.text('Tekrar dene'));
    expect(retried, isTrue);
  });
}
