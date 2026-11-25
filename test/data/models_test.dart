import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';

void main() {
  test('Item JSON gidiş-dönüş kayıpsız', () {
    for (final item in mockItems) {
      expect(Item.fromJson(item.toJson()), item);
    }
  });

  test('enumlar web API ile aynı metinle yazılır', () {
    final json = mockItems.first.toJson();
    expect(json['type'], 'Found');
    expect(json['status'], 'Published');
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

  test('Location web LocationDto biçimini okur', () {
    final l = Location.fromJson({
      'id': 3,
      'building': 'Merkezi Derslik',
      'floorOrRoom': 'Amfi',
      'latitude': null,
      'longitude': null,
    });
    expect(l.name, 'Merkezi Derslik – Amfi');
    expect(l.hasCoordinates, isFalse);
    expect(mockLocations.first.name, mockLocations.first.building);
  });

  test('enum API adı ve harf duyarsız okuma', () {
    expect(ItemType.found.apiValue, 'Found');
    expect(ItemStatus.published.apiValue, 'Published');
    expect(enumFromApi(ItemType.values, 'LOST'), ItemType.lost);
    expect(() => enumFromApi(ItemType.values, 'Kayip'), throwsFormatException);
  });
}
