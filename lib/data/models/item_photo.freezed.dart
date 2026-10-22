// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemPhoto {

 int get id; String get url; int get sortOrder;
/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemPhotoCopyWith<ItemPhoto> get copyWith => _$ItemPhotoCopyWithImpl<ItemPhoto>(this as ItemPhoto, _$identity);

  /// Serializes this ItemPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItemPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItemPhoto;
  return Object.hash(runtimeType,_this.id,_this.url,_this.sortOrder);
}

@override
String toString() {
  final _this = this as ItemPhoto;
  return 'ItemPhoto(id: ${_this.id}, url: ${_this.url}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $ItemPhotoCopyWith<$Res>  {
  factory $ItemPhotoCopyWith(ItemPhoto value, $Res Function(ItemPhoto) _then) = _$ItemPhotoCopyWithImpl;
@useResult
$Res call({
 int id, String url, int sortOrder
});




}
/// @nodoc
class _$ItemPhotoCopyWithImpl<$Res>
    implements $ItemPhotoCopyWith<$Res> {
  _$ItemPhotoCopyWithImpl(this._self, this._then);

  final ItemPhoto _self;
  final $Res Function(ItemPhoto) _then;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? sortOrder = null,}) {
  return _then(ItemPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemPhoto].
extension ItemPhotoPatterns on ItemPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ItemPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String url,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemPhoto() when $default != null:
return $default(_that.id,_that.url,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String url,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ItemPhoto():
return $default(_that.id,_that.url,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String url,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ItemPhoto() when $default != null:
return $default(_that.id,_that.url,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemPhoto extends ItemPhoto {
  const _ItemPhoto({required this.id, required this.url, this.sortOrder = 0}): super._();
  factory _ItemPhoto.fromJson(Map<String, dynamic> json) => _$ItemPhotoFromJson(json);

@override final  int id;
@override final  String url;
@override@JsonKey() final  int sortOrder;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemPhotoCopyWith<_ItemPhoto> get copyWith => __$ItemPhotoCopyWithImpl<_ItemPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,sortOrder);
}

@override
String toString() {
    return 'ItemPhoto(id: $id, url: $url, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ItemPhotoCopyWith<$Res> implements $ItemPhotoCopyWith<$Res> {
  factory _$ItemPhotoCopyWith(_ItemPhoto value, $Res Function(_ItemPhoto) _then) = __$ItemPhotoCopyWithImpl;
@override @useResult
$Res call({
 int id, String url, int sortOrder
});




}
/// @nodoc
class __$ItemPhotoCopyWithImpl<$Res>
    implements _$ItemPhotoCopyWith<$Res> {
  __$ItemPhotoCopyWithImpl(this._self, this._then);

  final _ItemPhoto _self;
  final $Res Function(_ItemPhoto) _then;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? sortOrder = null,}) {
  return _then(_ItemPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
