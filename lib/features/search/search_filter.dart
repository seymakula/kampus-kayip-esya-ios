import '../../data/models/models.dart';

/// Tarih filtresi: olayın (kaybolma / bulunma) ne kadar yakın olduğu.
enum DateRange {
  all('Tüm zamanlar', null),
  day('Son 24 saat', Duration(days: 1)),
  week('Son 7 gün', Duration(days: 7)),
  month('Son 30 gün', Duration(days: 30));

  const DateRange(this.label, this._window);

  final String label;
  final Duration? _window;

  DateTime? since(DateTime now) =>
      _window == null ? null : now.subtract(_window);
}

/// Ara ekranındaki tüm seçimler. Arama sonuçları provider'ının anahtarıdır;
/// bu yüzden değişmez ve `==` ile karşılaştırılabilir.
class SearchFilter {
  const SearchFilter({
    this.text = '',
    this.type,
    this.categoryId,
    this.locationId,
    this.range = DateRange.all,
  });

  final String text;
  final ItemType? type;
  final int? categoryId;
  final int? locationId;
  final DateRange range;

  /// Filtre panelindeki seçimlerin sayısı (simgedeki rozet).
  int get sheetFilterCount =>
      (categoryId != null ? 1 : 0) +
      (locationId != null ? 1 : 0) +
      (range != DateRange.all ? 1 : 0);

  /// Nullable alanları temizleyebilmek için değer yerine fonksiyon alır:
  /// `filter.copyWith(categoryId: () => null)`.
  SearchFilter copyWith({
    String? text,
    ItemType? Function()? type,
    int? Function()? categoryId,
    int? Function()? locationId,
    DateRange? range,
  }) => SearchFilter(
    text: text ?? this.text,
    type: type != null ? type() : this.type,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    locationId: locationId != null ? locationId() : this.locationId,
    range: range ?? this.range,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchFilter &&
      other.text == text &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.locationId == locationId &&
      other.range == range;

  @override
  int get hashCode => Object.hash(text, type, categoryId, locationId, range);
}
