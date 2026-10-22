// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claim.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Claim {

 int get id; int get itemId; String get itemTitle; ClaimKind get kind; ClaimStatus get status; int get claimantId;/// Gizlilik için kısaltılmış ad ("Ad S.").
 String get claimantName; String? get answer; DateTime get createdAt;
/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaimCopyWith<Claim> get copyWith => _$ClaimCopyWithImpl<Claim>(this as Claim, _$identity);

  /// Serializes this Claim to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Claim;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Claim&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.itemTitle, _this.itemTitle) || other.itemTitle == _this.itemTitle)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.claimantId, _this.claimantId) || other.claimantId == _this.claimantId)&&(identical(other.claimantName, _this.claimantName) || other.claimantName == _this.claimantName)&&(identical(other.answer, _this.answer) || other.answer == _this.answer)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Claim;
  return Object.hash(runtimeType,_this.id,_this.itemId,_this.itemTitle,_this.kind,_this.status,_this.claimantId,_this.claimantName,_this.answer,_this.createdAt);
}

@override
String toString() {
  final _this = this as Claim;
  return 'Claim(id: ${_this.id}, itemId: ${_this.itemId}, itemTitle: ${_this.itemTitle}, kind: ${_this.kind}, status: ${_this.status}, claimantId: ${_this.claimantId}, claimantName: ${_this.claimantName}, answer: ${_this.answer}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ClaimCopyWith<$Res>  {
  factory $ClaimCopyWith(Claim value, $Res Function(Claim) _then) = _$ClaimCopyWithImpl;
@useResult
$Res call({
 int id, int itemId, String itemTitle, ClaimKind kind, ClaimStatus status, int claimantId, String claimantName, String? answer, DateTime createdAt
});




}
/// @nodoc
class _$ClaimCopyWithImpl<$Res>
    implements $ClaimCopyWith<$Res> {
  _$ClaimCopyWithImpl(this._self, this._then);

  final Claim _self;
  final $Res Function(Claim) _then;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemTitle = null,Object? kind = null,Object? status = null,Object? claimantId = null,Object? claimantName = null,Object? answer = freezed,Object? createdAt = null,}) {
  return _then(Claim(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,itemTitle: null == itemTitle ? _self.itemTitle : itemTitle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ClaimKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClaimStatus,claimantId: null == claimantId ? _self.claimantId : claimantId // ignore: cast_nullable_to_non_nullable
as int,claimantName: null == claimantName ? _self.claimantName : claimantName // ignore: cast_nullable_to_non_nullable
as String,answer: freezed == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Claim].
extension ClaimPatterns on Claim {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Claim value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Claim value)  $default,){
final _that = this;
switch (_that) {
case _Claim():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Claim value)?  $default,){
final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int itemId,  String itemTitle,  ClaimKind kind,  ClaimStatus status,  int claimantId,  String claimantName,  String? answer,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that.id,_that.itemId,_that.itemTitle,_that.kind,_that.status,_that.claimantId,_that.claimantName,_that.answer,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int itemId,  String itemTitle,  ClaimKind kind,  ClaimStatus status,  int claimantId,  String claimantName,  String? answer,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Claim():
return $default(_that.id,_that.itemId,_that.itemTitle,_that.kind,_that.status,_that.claimantId,_that.claimantName,_that.answer,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int itemId,  String itemTitle,  ClaimKind kind,  ClaimStatus status,  int claimantId,  String claimantName,  String? answer,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that.id,_that.itemId,_that.itemTitle,_that.kind,_that.status,_that.claimantId,_that.claimantName,_that.answer,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Claim implements Claim {
  const _Claim({required this.id, required this.itemId, required this.itemTitle, required this.kind, required this.status, required this.claimantId, required this.claimantName, this.answer, required this.createdAt});
  factory _Claim.fromJson(Map<String, dynamic> json) => _$ClaimFromJson(json);

@override final  int id;
@override final  int itemId;
@override final  String itemTitle;
@override final  ClaimKind kind;
@override final  ClaimStatus status;
@override final  int claimantId;
/// Gizlilik için kısaltılmış ad ("Ad S.").
@override final  String claimantName;
@override final  String? answer;
@override final  DateTime createdAt;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaimCopyWith<_Claim> get copyWith => __$ClaimCopyWithImpl<_Claim>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaimToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Claim&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemTitle, itemTitle) || other.itemTitle == itemTitle)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.claimantId, claimantId) || other.claimantId == claimantId)&&(identical(other.claimantName, claimantName) || other.claimantName == claimantName)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,itemId,itemTitle,kind,status,claimantId,claimantName,answer,createdAt);
}

@override
String toString() {
    return 'Claim(id: $id, itemId: $itemId, itemTitle: $itemTitle, kind: $kind, status: $status, claimantId: $claimantId, claimantName: $claimantName, answer: $answer, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClaimCopyWith<$Res> implements $ClaimCopyWith<$Res> {
  factory _$ClaimCopyWith(_Claim value, $Res Function(_Claim) _then) = __$ClaimCopyWithImpl;
@override @useResult
$Res call({
 int id, int itemId, String itemTitle, ClaimKind kind, ClaimStatus status, int claimantId, String claimantName, String? answer, DateTime createdAt
});




}
/// @nodoc
class __$ClaimCopyWithImpl<$Res>
    implements _$ClaimCopyWith<$Res> {
  __$ClaimCopyWithImpl(this._self, this._then);

  final _Claim _self;
  final $Res Function(_Claim) _then;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemTitle = null,Object? kind = null,Object? status = null,Object? claimantId = null,Object? claimantName = null,Object? answer = freezed,Object? createdAt = null,}) {
  return _then(_Claim(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,itemTitle: null == itemTitle ? _self.itemTitle : itemTitle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ClaimKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClaimStatus,claimantId: null == claimantId ? _self.claimantId : claimantId // ignore: cast_nullable_to_non_nullable
as int,claimantName: null == claimantName ? _self.claimantName : claimantName // ignore: cast_nullable_to_non_nullable
as String,answer: freezed == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
