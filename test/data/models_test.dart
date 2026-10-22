import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';

void main() {
  test('Item JSON gidiş-dönüş kayıpsız', () {
    for (final item in mockItems) {
      expect(Item.fromJson(item.toJson()), item);
    }
  });

  test('enumlar camelCase string olarak yazılır', () {
    final json = mockItems.first.toJson();
    expect(json['type'], 'found');
    expect(json['status'], 'published');
    expect(json['category'], isA<Map<String, dynamic>>());
  });

  test('PagedResult API biçimini okur', () {
    final json = {
      'items': [mockCategories.first.toJson()],
      'page': 1,
      'pageSize': 10,
      'totalCount': 11,
    };
    final res = PagedResult<Category>.fromJson(
      json,
      (o) => Category.fromJson(o as Map<String, dynamic>),
    );
    expect(res.items.single.name, 'Elektronik');
    expect(res.hasMore, isTrue);
  });

  test('Claim, Message, AppNotification JSON gidiş-dönüş', () {
    for (final c in mockClaims) {
      expect(Claim.fromJson(c.toJson()), c);
    }
    for (final m in mockMessages) {
      expect(Message.fromJson(m.toJson()), m);
    }
    for (final n in mockNotifications) {
      expect(AppNotification.fromJson(n.toJson()), n);
    }
  });

  test('doğrulama sorusu yalnızca Bulundu ilanlarında', () {
    for (final i in mockItems) {
      if (i.type == ItemType.lost) expect(i.verificationQuestion, isNull);
    }
  });
}
