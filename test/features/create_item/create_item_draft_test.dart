import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/features/create_item/create_item_draft.dart';
import 'package:kampus_kayip_esya/features/create_item/device_services.dart';

final _now = DateTime(2026, 11, 25, 15);

CreateItemDraft _valid({ItemType type = ItemType.found}) => CreateItemDraft(
  type: type,
  title: 'Siyah deri cüzdan',
  categoryId: 2,
  description: 'Amfinin arka sıralarında buldum.',
  eventDate: _now.subtract(const Duration(hours: 2)),
  verificationQuestion: type == ItemType.found ? 'Hangi bankanın kartı?' : '',
  location: mockLocations.first,
);

void main() {
  group('adım kuralları (web ItemWriteRequest ile aynı)', () {
    test('tür seçilmeden ilk adım geçilmez', () {
      expect(
        DraftRules.stepError(CreateStep.type, const CreateItemDraft(), _now),
        'İlan türünü seçin.',
      );
    });

    test('fotoğraf isteğe bağlı', () {
      expect(
        DraftRules.stepError(CreateStep.photos, const CreateItemDraft(), _now),
        isNull,
      );
    });

    test('bilgiler: başlık, kategori, açıklama, tarih', () {
      final d = _valid();
      expect(DraftRules.stepError(CreateStep.details, d, _now), isNull);
      expect(
        DraftRules.stepError(
          CreateStep.details,
          d.copyWith(title: 'abc'),
          _now,
        ),
        'Başlık 5–100 karakter olmalıdır.',
      );
      expect(
        DraftRules.stepError(
          CreateStep.details,
          const CreateItemDraft(type: ItemType.lost, title: 'Gümüş bilezik'),
          _now,
        ),
        'Kategori seçin.',
      );
      expect(
        DraftRules.stepError(
          CreateStep.details,
          d.copyWith(description: 'kısa'),
          _now,
        ),
        'Açıklama 10–2000 karakter olmalıdır.',
      );
      expect(
        DraftRules.stepError(
          CreateStep.details,
          d.copyWith(eventDate: _now.add(const Duration(days: 1))),
          _now,
        ),
        'Olay tarihi bugünden sonra olamaz.',
      );
    });

    test('doğrulama sorusu yalnızca Bulundu ilanında zorunlu', () {
      expect(
        DraftRules.stepError(
          CreateStep.details,
          _valid().copyWith(verificationQuestion: '  '),
          _now,
        ),
        'Bulunan eşya için doğrulama sorusu zorunludur.',
      );
      expect(
        DraftRules.stepError(
          CreateStep.details,
          _valid(type: ItemType.lost),
          _now,
        ),
        isNull,
      );
    });

    test('konum seçilmeden yayınlanmaz', () {
      expect(
        DraftRules.stepError(
          CreateStep.location,
          const CreateItemDraft(),
          _now,
        ),
        'Konum seçin.',
      );
    });
  });

  test('istek gövdesi: kayıp ilanda soru gönderilmez, metinler kırpılır', () {
    final lost = _valid(type: ItemType.lost)
        .copyWith(title: '  Gümüş bilezik  ', verificationQuestion: 'x?')
        .toNewItem()
        .toJson();
    expect(lost['type'], 'Lost');
    expect(lost['title'], 'Gümüş bilezik');
    expect(lost['verificationQuestion'], isNull);
    expect(lost['locationId'], mockLocations.first.id);

    final found = _valid().toNewItem().toJson();
    expect(found['type'], 'Found');
    expect(found['verificationQuestion'], 'Hangi bankanın kartı?');
    expect(found['eventDate'], endsWith('Z'));
  });

  group('fotoğraflar', () {
    late ProviderContainer c;
    late CreateItemDraftNotifier n;
    setUp(() {
      c = ProviderContainer();
      n = c.read(createItemDraftProvider.notifier);
    });
    tearDown(() => c.dispose());

    List<String> photos() => c.read(createItemDraftProvider).photos;

    test('en fazla 5; fazlası eklenmez', () {
      expect(n.addPhotos(['a', 'b', 'c']), 3);
      expect(n.addPhotos(['d', 'e', 'f', 'g']), 2);
      expect(photos(), ['a', 'b', 'c', 'd', 'e']);
      expect(n.addPhotos(['h']), 0);
    });

    test('silme ve sıralama (ilk fotoğraf kapak)', () {
      n.addPhotos(['a', 'b', 'c']);
      n.movePhoto(2, 0);
      expect(photos(), ['c', 'a', 'b']);
      n.movePhoto(0, 2);
      expect(photos(), ['a', 'b', 'c']);
      n.removePhoto(1);
      expect(photos(), ['a', 'c']);
    });

    test('reset taslağı temizler', () {
      n
        ..setType(ItemType.lost)
        ..setTitle('Bir şey')
        ..addPhotos(['a']);
      n.reset();
      expect(c.read(createItemDraftProvider).type, isNull);
      expect(photos(), isEmpty);
    });
  });

  group('en yakın bina', () {
    test('konuma en yakın bina seçilir', () {
      // Merkez Yemekhane (39.7785, 32.8040) yakınında bir nokta.
      final b = nearestBuilding(39.77855, 32.80395, mockLocations);
      expect(b!.building, 'Merkez Yemekhane');
    });

    test('koordinatı olmayan binalar atlanır; hiç yoksa null', () {
      const noCoords = [
        Location(id: 1, building: 'Kantin'),
        Location(id: 2, building: 'Kütüphane'),
      ];
      expect(nearestBuilding(39.78, 32.80, noCoords), isNull);
      expect(
        nearestBuilding(39.78, 32.80, [...noCoords, mockLocations.first]),
        mockLocations.first,
      );
    });
  });
}
