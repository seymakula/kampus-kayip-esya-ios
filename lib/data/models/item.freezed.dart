// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

 int get id; ItemType get type; ItemStatus get status; String get title; String get description; Category get category; Location get location; DateTime get eventDate; DateTime get createdAt;/// Bakan kişi ilanın sahibi mi (API detayda verir; sahibin kimliği verilmez).
 bool get isOwner;/// Sahibin kısaltılmış adı ("Ayşe Y."); yalnızca detayda.
 String? get ownerName;/// Eşya kayıp eşya bürosuna teslim edildi mi.
 bool get isAtOffice;/// Yalnızca "Bulundu" ilanlarında; API yalnızca sahibine ve görevliye verir.
 String? get verificationQuestion;/// Görevlinin ret sebebi; yalnızca sahibine görünür.
 String? get rejectionReason; List<ItemPhoto> get photos;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Item;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.eventDate, _this.eventDate) || other.eventDate == _this.eventDate)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isOwner, _this.isOwner) || other.isOwner == _this.isOwner)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.isAtOffice, _this.isAtOffice) || other.isAtOffice == _this.isAtOffice)&&(identical(other.verificationQuestion, _this.verificationQuestion) || other.verificationQuestion == _this.verificationQuestion)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&const DeepCollectionEquality().equals(other.photos, _this.photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Item;
  return Object.hash(runtimeType,_this.id,_this.type,_this.status,_this.title,_this.description,_this.category,_this.location,_this.eventDate,_this.createdAt,_this.isOwner,_this.ownerName,_this.isAtOffice,_this.verificationQuestion,_this.rejectionReason,const DeepCollectionEquality().hash(_this.photos));
}

@override
String toString() {
  final _this = this as Item;
  return 'Item(id: ${_this.id}, type: ${_this.type}, status: ${_this.status}, title: ${_this.title}, description: ${_this.description}, category: ${_this.category}, location: ${_this.location}, eventDate: ${_this.eventDate}, createdAt: ${_this.createdAt}, isOwner: ${_this.isOwner}, ownerName: ${_this.ownerName}, isAtOffice: ${_this.isAtOffice}, verificationQuestion: ${_this.verificationQuestion}, rejectionReason: ${_this.rejectionReason}, photos: ${_this.photos})';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 int id, ItemType type, ItemStatus status, String title, String description, Category category, Location location, DateTime eventDate, DateTime createdAt, bool isOwner, String? ownerName, bool isAtOffice, String? verificationQuestion, String? rejectionReason, List<ItemPhoto> photos
});


$CategoryCopyWith<$Res> get category;$LocationCopyWith<$Res> get location;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? title = null,Object? description = null,Object? category = null,Object? location = null,Object? eventDate = null,Object? createdAt = null,Object? isOwner = null,Object? ownerName = freezed,Object? isAtOffice = null,Object? verificationQuestion = freezed,Object? rejectionReason = freezed,Object? photos = null,}) {
  return _then(Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItemType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,isAtOffice: null == isAtOffice ? _self.isAtOffice : isAtOffice // ignore: cast_nullable_to_non_nullable
as bool,verificationQuestion: freezed == verificationQuestion ? _self.verificationQuestion : verificationQuestion // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<ItemPhoto>,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ItemType type,  ItemStatus status,  String title,  String description,  Category category,  Location location,  DateTime eventDate,  DateTime createdAt,  bool isOwner,  String? ownerName,  bool isAtOffice,  String? verificationQuestion,  String? rejectionReason,  List<ItemPhoto> photos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.title,_that.description,_that.category,_that.location,_that.eventDate,_that.createdAt,_that.isOwner,_that.ownerName,_that.isAtOffice,_that.verificationQuestion,_that.rejectionReason,_that.photos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ItemType type,  ItemStatus status,  String title,  String description,  Category category,  Location location,  DateTime eventDate,  DateTime createdAt,  bool isOwner,  String? ownerName,  bool isAtOffice,  String? verificationQuestion,  String? rejectionReason,  List<ItemPhoto> photos)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.type,_that.status,_that.title,_that.description,_that.category,_that.location,_that.eventDate,_that.createdAt,_that.isOwner,_that.ownerName,_that.isAtOffice,_that.verificationQuestion,_that.rejectionReason,_that.photos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ItemType type,  ItemStatus status,  String title,  String description,  Category category,  Location location,  DateTime eventDate,  DateTime createdAt,  bool isOwner,  String? ownerName,  bool isAtOffice,  String? verificationQuestion,  String? rejectionReason,  List<ItemPhoto> photos)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.title,_that.description,_that.category,_that.location,_that.eventDate,_that.createdAt,_that.isOwner,_that.ownerName,_that.isAtOffice,_that.verificationQuestion,_that.rejectionReason,_that.photos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item extends Item {
  const _Item({required this.id, required this.type, required this.status, required this.title, this.description = '', required this.category, required this.location, required this.eventDate, required this.createdAt, this.isOwner = false, this.ownerName, this.isAtOffice = false, this.verificationQuestion, this.rejectionReason,  List<ItemPhoto> photos = const <ItemPhoto>[]}): _photos = photos,super._();
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  int id;
@override final  ItemType type;
@override final  ItemStatus status;
@override final  String title;
@override@JsonKey() final  String description;
@override final  Category category;
@override final  Location location;
@override final  DateTime eventDate;
@override final  DateTime createdAt;
/// Bakan kişi ilanın sahibi mi (API detayda verir; sahibin kimliği verilmez).
@override@JsonKey() final  bool isOwner;
/// Sahibin kısaltılmış adı ("Ayşe Y."); yalnızca detayda.
@override final  String? ownerName;
/// Eşya kayıp eşya bürosuna teslim edildi mi.
@override@JsonKey() final  bool isAtOffice;
/// Yalnızca "Bulundu" ilanlarında; API yalnızca sahibine ve görevliye verir.
@override final  String? verificationQuestion;
/// Görevlinin ret sebebi; yalnızca sahibine görünür.
@override final  String? rejectionReason;
 final  List<ItemPhoto> _photos;
@override@JsonKey() List<ItemPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}


/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.isAtOffice, isAtOffice) || other.isAtOffice == isAtOffice)&&(identical(other.verificationQuestion, verificationQuestion) || other.verificationQuestion == verificationQuestion)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&const DeepCollectionEquality().equals(other.photos, _photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,status,title,description,category,location,eventDate,createdAt,isOwner,ownerName,isAtOffice,verificationQuestion,rejectionReason,const DeepCollectionEquality().hash(_photos));
}

@override
String toString() {
    return 'Item(id: $id, type: $type, status: $status, title: $title, description: $description, category: $category, location: $location, eventDate: $eventDate, createdAt: $createdAt, isOwner: $isOwner, ownerName: $ownerName, isAtOffice: $isAtOffice, verificationQuestion: $verificationQuestion, rejectionReason: $rejectionReason, photos: $photos)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 int id, ItemType type, ItemStatus status, String title, String description, Category category, Location location, DateTime eventDate, DateTime createdAt, bool isOwner, String? ownerName, bool isAtOffice, String? verificationQuestion, String? rejectionReason, List<ItemPhoto> photos
});


@override $CategoryCopyWith<$Res> get category;@override $LocationCopyWith<$Res> get location;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? title = null,Object? description = null,Object? category = null,Object? location = null,Object? eventDate = null,Object? createdAt = null,Object? isOwner = null,Object? ownerName = freezed,Object? isAtOffice = null,Object? verificationQuestion = freezed,Object? rejectionReason = freezed,Object? photos = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItemType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,isAtOffice: null == isAtOffice ? _self.isAtOffice : isAtOffice // ignore: cast_nullable_to_non_nullable
as bool,verificationQuestion: freezed == verificationQuestion ? _self.verificationQuestion : verificationQuestion // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<ItemPhoto>,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
