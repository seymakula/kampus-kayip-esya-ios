import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'claim.freezed.dart';
part 'claim.g.dart';

@freezed
abstract class Claim with _$Claim {
  const factory Claim({
    required int id,
    required int itemId,
    required String itemTitle,
    required ClaimKind kind,
    required ClaimStatus status,
    required int claimantId,

    /// Gizlilik için kısaltılmış ad ("Ad S.").
    required String claimantName,
    String? answer,
    required DateTime createdAt,
  }) = _Claim;

  factory Claim.fromJson(Map<String, dynamic> json) => _$ClaimFromJson(json);
}
