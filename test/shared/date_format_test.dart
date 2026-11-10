import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/shared/utils/date_format.dart';

void main() {
  final now = DateTime(2026, 10, 30, 12);
  String rel(DateTime d) => formatRelative(d, now: now);

  test('dakika ve saat', () {
    expect(rel(now.subtract(const Duration(seconds: 20))), 'Az önce');
    expect(rel(now.subtract(const Duration(minutes: 5))), '5 dk önce');
    expect(rel(now.subtract(const Duration(hours: 3))), '3 saat önce');
  });

  test('gün sınırı saate değil takvim gününe göre', () {
    // 13 saat önce ama dün gece: "Dün"
    expect(rel(DateTime(2026, 10, 29, 23)), 'Dün');
    expect(rel(DateTime(2026, 10, 26, 18)), '4 gün önce');
  });

  test('bir haftadan eski tarihler gün ve ay olarak', () {
    expect(rel(DateTime(2026, 10, 12)), '12 Eki');
    expect(rel(DateTime(2025, 8, 3)), '3 Ağu 2025');
  });

  test('formatDateTime gün, ay, yıl ve saat', () {
    expect(formatDateTime(DateTime(2026, 10, 30, 9, 5)), '30 Eki 2026, 09:05');
    expect(formatDateTime(DateTime(2026, 1, 2, 23, 59)), '2 Oca 2026, 23:59');
  });
}
