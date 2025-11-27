// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Asset {

 String get id;
/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetCopyWith<Asset> get copyWith => _$AssetCopyWithImpl<Asset>(this as Asset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Asset&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'Asset(id: $id)';
}


}

/// @nodoc
abstract mixin class $AssetCopyWith<$Res>  {
  factory $AssetCopyWith(Asset value, $Res Function(Asset) _then) = _$AssetCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$AssetCopyWithImpl<$Res>
    implements $AssetCopyWith<$Res> {
  _$AssetCopyWithImpl(this._self, this._then);

  final Asset _self;
  final $Res Function(Asset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Asset].
extension AssetPatterns on Asset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FinancialAsset value)?  financial,TResult Function( PointAsset value)?  point,TResult Function( ExperienceAsset value)?  experience,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FinancialAsset() when financial != null:
return financial(_that);case PointAsset() when point != null:
return point(_that);case ExperienceAsset() when experience != null:
return experience(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FinancialAsset value)  financial,required TResult Function( PointAsset value)  point,required TResult Function( ExperienceAsset value)  experience,}){
final _that = this;
switch (_that) {
case FinancialAsset():
return financial(_that);case PointAsset():
return point(_that);case ExperienceAsset():
return experience(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FinancialAsset value)?  financial,TResult? Function( PointAsset value)?  point,TResult? Function( ExperienceAsset value)?  experience,}){
final _that = this;
switch (_that) {
case FinancialAsset() when financial != null:
return financial(_that);case PointAsset() when point != null:
return point(_that);case ExperienceAsset() when experience != null:
return experience(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String name,  double amount,  String currency)?  financial,TResult Function( String id,  String providerName,  int points,  double exchangeRate,  DateTime? expiryDate)?  point,TResult Function( String id,  String activityName,  Duration totalTime,  int accumulatedLevel)?  experience,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FinancialAsset() when financial != null:
return financial(_that.id,_that.name,_that.amount,_that.currency);case PointAsset() when point != null:
return point(_that.id,_that.providerName,_that.points,_that.exchangeRate,_that.expiryDate);case ExperienceAsset() when experience != null:
return experience(_that.id,_that.activityName,_that.totalTime,_that.accumulatedLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String name,  double amount,  String currency)  financial,required TResult Function( String id,  String providerName,  int points,  double exchangeRate,  DateTime? expiryDate)  point,required TResult Function( String id,  String activityName,  Duration totalTime,  int accumulatedLevel)  experience,}) {final _that = this;
switch (_that) {
case FinancialAsset():
return financial(_that.id,_that.name,_that.amount,_that.currency);case PointAsset():
return point(_that.id,_that.providerName,_that.points,_that.exchangeRate,_that.expiryDate);case ExperienceAsset():
return experience(_that.id,_that.activityName,_that.totalTime,_that.accumulatedLevel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String name,  double amount,  String currency)?  financial,TResult? Function( String id,  String providerName,  int points,  double exchangeRate,  DateTime? expiryDate)?  point,TResult? Function( String id,  String activityName,  Duration totalTime,  int accumulatedLevel)?  experience,}) {final _that = this;
switch (_that) {
case FinancialAsset() when financial != null:
return financial(_that.id,_that.name,_that.amount,_that.currency);case PointAsset() when point != null:
return point(_that.id,_that.providerName,_that.points,_that.exchangeRate,_that.expiryDate);case ExperienceAsset() when experience != null:
return experience(_that.id,_that.activityName,_that.totalTime,_that.accumulatedLevel);case _:
  return null;

}
}

}

/// @nodoc


class FinancialAsset implements Asset {
  const FinancialAsset({required this.id, required this.name, required this.amount, required this.currency});
  

@override final  String id;
 final  String name;
 final  double amount;
 final  String currency;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialAssetCopyWith<FinancialAsset> get copyWith => _$FinancialAssetCopyWithImpl<FinancialAsset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,amount,currency);

@override
String toString() {
  return 'Asset.financial(id: $id, name: $name, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $FinancialAssetCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory $FinancialAssetCopyWith(FinancialAsset value, $Res Function(FinancialAsset) _then) = _$FinancialAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double amount, String currency
});




}
/// @nodoc
class _$FinancialAssetCopyWithImpl<$Res>
    implements $FinancialAssetCopyWith<$Res> {
  _$FinancialAssetCopyWithImpl(this._self, this._then);

  final FinancialAsset _self;
  final $Res Function(FinancialAsset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? currency = null,}) {
  return _then(FinancialAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PointAsset implements Asset {
  const PointAsset({required this.id, required this.providerName, required this.points, required this.exchangeRate, this.expiryDate});
  

@override final  String id;
 final  String providerName;
 final  int points;
 final  double exchangeRate;
// 円換算レート
 final  DateTime? expiryDate;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointAssetCopyWith<PointAsset> get copyWith => _$PointAssetCopyWithImpl<PointAsset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.points, points) || other.points == points)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,providerName,points,exchangeRate,expiryDate);

@override
String toString() {
  return 'Asset.point(id: $id, providerName: $providerName, points: $points, exchangeRate: $exchangeRate, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class $PointAssetCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory $PointAssetCopyWith(PointAsset value, $Res Function(PointAsset) _then) = _$PointAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String providerName, int points, double exchangeRate, DateTime? expiryDate
});




}
/// @nodoc
class _$PointAssetCopyWithImpl<$Res>
    implements $PointAssetCopyWith<$Res> {
  _$PointAssetCopyWithImpl(this._self, this._then);

  final PointAsset _self;
  final $Res Function(PointAsset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? providerName = null,Object? points = null,Object? exchangeRate = null,Object? expiryDate = freezed,}) {
  return _then(PointAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ExperienceAsset implements Asset {
  const ExperienceAsset({required this.id, required this.activityName, required this.totalTime, required this.accumulatedLevel});
  

@override final  String id;
 final  String activityName;
 final  Duration totalTime;
 final  int accumulatedLevel;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperienceAssetCopyWith<ExperienceAsset> get copyWith => _$ExperienceAssetCopyWithImpl<ExperienceAsset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExperienceAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.activityName, activityName) || other.activityName == activityName)&&(identical(other.totalTime, totalTime) || other.totalTime == totalTime)&&(identical(other.accumulatedLevel, accumulatedLevel) || other.accumulatedLevel == accumulatedLevel));
}


@override
int get hashCode => Object.hash(runtimeType,id,activityName,totalTime,accumulatedLevel);

@override
String toString() {
  return 'Asset.experience(id: $id, activityName: $activityName, totalTime: $totalTime, accumulatedLevel: $accumulatedLevel)';
}


}

/// @nodoc
abstract mixin class $ExperienceAssetCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory $ExperienceAssetCopyWith(ExperienceAsset value, $Res Function(ExperienceAsset) _then) = _$ExperienceAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String activityName, Duration totalTime, int accumulatedLevel
});




}
/// @nodoc
class _$ExperienceAssetCopyWithImpl<$Res>
    implements $ExperienceAssetCopyWith<$Res> {
  _$ExperienceAssetCopyWithImpl(this._self, this._then);

  final ExperienceAsset _self;
  final $Res Function(ExperienceAsset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityName = null,Object? totalTime = null,Object? accumulatedLevel = null,}) {
  return _then(ExperienceAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityName: null == activityName ? _self.activityName : activityName // ignore: cast_nullable_to_non_nullable
as String,totalTime: null == totalTime ? _self.totalTime : totalTime // ignore: cast_nullable_to_non_nullable
as Duration,accumulatedLevel: null == accumulatedLevel ? _self.accumulatedLevel : accumulatedLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
