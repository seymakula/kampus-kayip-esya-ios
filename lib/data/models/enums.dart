import 'package:json_annotation/json_annotation.dart';

/// İlan türü: kayıp mı, bulunan mı.
enum ItemType {
  @JsonValue('Lost')
  lost,
  @JsonValue('Found')
  found;

  String get label => switch (this) {
        ItemType.lost => 'Kayıp',
        ItemType.found => 'Bulundu',
      };

  /// Etiket rozetindeki büyük harfli yazı (web `.tag`).
  String get tagLabel => switch (this) {
        ItemType.lost => 'KAYIP',
        ItemType.found => 'BULUNDU',
      };
}

/// İlanın yaşam döngüsü. Onay web panelindeki görevlide.
enum ItemStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Published')
  published,
  @JsonValue('Rejected')
  rejected,
  @JsonValue('Resolved')
  resolved,
  @JsonValue('Archived')
  archived;

  String get label => switch (this) {
        ItemStatus.pending => 'Onay bekliyor',
        ItemStatus.published => 'Yayında',
        ItemStatus.rejected => 'Reddedildi',
        ItemStatus.resolved => 'Teslim edildi',
        ItemStatus.archived => 'Arşivlendi',
      };
}

/// Talep durumu: ilan sahibi onaylar veya reddeder.
enum ClaimStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected;

  String get label => switch (this) {
        ClaimStatus.pending => 'Bekliyor',
        ClaimStatus.approved => 'Onaylandı',
        ClaimStatus.rejected => 'Reddedildi',
      };
}

/// Talep türü: "Bu benim" (bulunan ilana) veya "Ben buldum" (kayıp ilana).
enum ClaimKind {
  @JsonValue('owner')
  owner,
  @JsonValue('finder')
  finder;

  String get label => switch (this) {
        ClaimKind.owner => 'Bu benim',
        ClaimKind.finder => 'Ben buldum',
      };
}

/// Web API enum'ları metin olarak ve büyük harfle başlayarak taşır
/// (`Lost`, `Published`). Sorgu parametresi ve istek gövdesi için.
extension ApiEnumName on Enum {
  String get apiValue => '${name[0].toUpperCase()}${name.substring(1)}';
}

/// API'den gelen metni enum'a çevirir; büyük/küçük harf duyarsız.
T enumFromApi<T extends Enum>(List<T> values, Object? raw) {
  final text = raw?.toString().toLowerCase();
  return values.firstWhere(
    (v) => v.name.toLowerCase() == text,
    orElse: () => throw FormatException('Bilinmeyen değer: $raw'),
  );
}
