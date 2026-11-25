import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/item_repository.dart';

/// Bir ilana en fazla kaç fotoğraf eklenebilir (web `PhotoService`).
const maxPhotos = 5;

/// Formun adımları; sıra ekrandaki sırayla aynı.
enum CreateStep {
  type('Tür'),
  photos('Fotoğraf'),
  details('Bilgiler'),
  location('Konum');

  const CreateStep(this.label);
  final String label;
}

/// İlan açma formunun taslağı. Adımlar arasında gidip gelince ya da sekme
/// değişince bilgiler kaybolmasın diye provider'da tutulur.
class CreateItemDraft {
  const CreateItemDraft({
    this.type,
    this.photos = const [],
    this.title = '',
    this.categoryId,
    this.description = '',
    this.eventDate,
    this.verificationQuestion = '',
    this.location,
  });

  final ItemType? type;

  /// Telefondaki dosya yolları; ilki kapak fotoğrafı.
  final List<String> photos;
  final String title;
  final int? categoryId;
  final String description;
  final DateTime? eventDate;
  final String verificationQuestion;
  final Location? location;

  bool get isFound => type == ItemType.found;

  CreateItemDraft copyWith({
    ItemType? type,
    List<String>? photos,
    String? title,
    int? categoryId,
    String? description,
    DateTime? eventDate,
    String? verificationQuestion,
    Location? location,
  }) => CreateItemDraft(
    type: type ?? this.type,
    photos: photos ?? this.photos,
    title: title ?? this.title,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    eventDate: eventDate ?? this.eventDate,
    verificationQuestion: verificationQuestion ?? this.verificationQuestion,
    location: location ?? this.location,
  );

  /// Gönderilecek istek. Yalnızca bütün adımlar geçerliyse çağrılır.
  NewItem toNewItem() => NewItem(
    type: type!,
    title: title.trim(),
    categoryId: categoryId!,
    locationId: location!.id,
    eventDate: eventDate!,
    description: description.trim(),
    verificationQuestion: isFound ? verificationQuestion.trim() : null,
  );
}

/// Web'deki `ItemWriteRequest` kurallarıyla aynı doğrulamalar.
/// Geçerliyse `null`, değilse Türkçe hata.
abstract final class DraftRules {
  static String? title(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Başlık zorunludur.';
    if (v.length < 5 || v.length > 100) {
      return 'Başlık 5–100 karakter olmalıdır.';
    }
    return null;
  }

  static String? description(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Açıklama zorunludur.';
    if (v.length < 10 || v.length > 2000) {
      return 'Açıklama 10–2000 karakter olmalıdır.';
    }
    return null;
  }

  static String? verificationQuestion(String value, {required bool found}) {
    if (!found) return null;
    final v = value.trim();
    if (v.isEmpty) {
      return 'Bulunan eşya için doğrulama sorusu zorunludur.';
    }
    if (v.length > 300) {
      return 'Doğrulama sorusu en fazla 300 karakter olabilir.';
    }
    return null;
  }

  static String? eventDate(DateTime? value, DateTime now) {
    if (value == null) return 'Olay tarihini seçin.';
    if (value.isAfter(now)) return 'Olay tarihi bugünden sonra olamaz.';
    return null;
  }

  /// Adımın geçilmesine engel olan ilk hata; adım geçerliyse `null`.
  static String? stepError(CreateStep step, CreateItemDraft d, DateTime now) =>
      switch (step) {
        CreateStep.type => d.type == null ? 'İlan türünü seçin.' : null,
        CreateStep.photos => null, // Fotoğraf isteğe bağlı (0–5).
        CreateStep.details =>
          title(d.title) ??
              (d.categoryId == null ? 'Kategori seçin.' : null) ??
              description(d.description) ??
              eventDate(d.eventDate, now) ??
              verificationQuestion(d.verificationQuestion, found: d.isFound),
        CreateStep.location => d.location == null ? 'Konum seçin.' : null,
      };
}

class CreateItemDraftNotifier extends Notifier<CreateItemDraft> {
  @override
  CreateItemDraft build() => const CreateItemDraft();

  void setType(ItemType type) => state = state.copyWith(type: type);

  /// Sınırı aşan fotoğraflar eklenmez; eklenen sayıyı döndürür.
  int addPhotos(List<String> paths) {
    final room = maxPhotos - state.photos.length;
    final added = paths.take(room).toList();
    if (added.isNotEmpty) {
      state = state.copyWith(photos: [...state.photos, ...added]);
    }
    return added.length;
  }

  void removePhoto(int index) =>
      state = state.copyWith(photos: [...state.photos]..removeAt(index));

  /// [newIndex]: fotoğrafın taşındıktan sonraki sırası.
  void movePhoto(int oldIndex, int newIndex) {
    final photos = [...state.photos];
    photos.insert(newIndex, photos.removeAt(oldIndex));
    state = state.copyWith(photos: photos);
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setCategory(int id) => state = state.copyWith(categoryId: id);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setEventDate(DateTime v) => state = state.copyWith(eventDate: v);
  void setVerificationQuestion(String v) =>
      state = state.copyWith(verificationQuestion: v);
  void setLocation(Location v) => state = state.copyWith(location: v);

  void reset() => state = const CreateItemDraft();
}

final createItemDraftProvider =
    NotifierProvider<CreateItemDraftNotifier, CreateItemDraft>(
      CreateItemDraftNotifier.new,
    );
