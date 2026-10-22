import 'package:json_annotation/json_annotation.dart';

/// İlan türü: kayıp mı, bulunan mı.
enum ItemType {
  @JsonValue('lost')
  lost,
  @JsonValue('found')
  found;

  String get label => switch (this) {
        ItemType.lost => 'Kayıp',
        ItemType.found => 'Bulundu',
      };
}

/// İlanın yaşam döngüsü. Onay web panelindeki görevlide.
enum ItemStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('published')
  published,
  @JsonValue('rejected')
  rejected,
  @JsonValue('resolved')
  resolved,
  @JsonValue('archived')
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
