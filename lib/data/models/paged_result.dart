import 'package:json_annotation/json_annotation.dart';

part 'paged_result.g.dart';

/// API liste yanıtı: `{ items, page, pageSize, totalCount }`.
@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasMore => page * pageSize < totalCount;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagedResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PagedResultToJson(this, toJsonT);
}
