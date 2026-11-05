import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    /// ASP.NET Identity kimliği: sayı değil, metin (GUID).
    required String id,
    required String fullName,
    required String email,

    /// Web'de isteğe bağlı (personel hesaplarında boş olabilir).
    String? studentNo,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
