// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'engineer_bio_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EngineerBioEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngineerBioEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EngineerBioEvent()';
}


}

/// @nodoc
class $EngineerBioEventCopyWith<$Res>  {
$EngineerBioEventCopyWith(EngineerBioEvent _, $Res Function(EngineerBioEvent) __);
}


/// Adds pattern-matching-related methods to [EngineerBioEvent].
extension EngineerBioEventPatterns on EngineerBioEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _UploadEngBio value)?  uploadEngBio,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _UploadEngBio() when uploadEngBio != null:
return uploadEngBio(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _UploadEngBio value)  uploadEngBio,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _UploadEngBio():
return uploadEngBio(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _UploadEngBio value)?  uploadEngBio,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _UploadEngBio() when uploadEngBio != null:
return uploadEngBio(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( int engineerId,  String projectName,  int categoryId,  double cent,  double squareFeet,  int expectedAmount,  int additionalAmount,  double totalAmount,  List<int> additionalFeatures,  String timeDuration,  List<File> images,  File? profileImage)?  uploadEngBio,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _UploadEngBio() when uploadEngBio != null:
return uploadEngBio(_that.engineerId,_that.projectName,_that.categoryId,_that.cent,_that.squareFeet,_that.expectedAmount,_that.additionalAmount,_that.totalAmount,_that.additionalFeatures,_that.timeDuration,_that.images,_that.profileImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( int engineerId,  String projectName,  int categoryId,  double cent,  double squareFeet,  int expectedAmount,  int additionalAmount,  double totalAmount,  List<int> additionalFeatures,  String timeDuration,  List<File> images,  File? profileImage)  uploadEngBio,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _UploadEngBio():
return uploadEngBio(_that.engineerId,_that.projectName,_that.categoryId,_that.cent,_that.squareFeet,_that.expectedAmount,_that.additionalAmount,_that.totalAmount,_that.additionalFeatures,_that.timeDuration,_that.images,_that.profileImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( int engineerId,  String projectName,  int categoryId,  double cent,  double squareFeet,  int expectedAmount,  int additionalAmount,  double totalAmount,  List<int> additionalFeatures,  String timeDuration,  List<File> images,  File? profileImage)?  uploadEngBio,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _UploadEngBio() when uploadEngBio != null:
return uploadEngBio(_that.engineerId,_that.projectName,_that.categoryId,_that.cent,_that.squareFeet,_that.expectedAmount,_that.additionalAmount,_that.totalAmount,_that.additionalFeatures,_that.timeDuration,_that.images,_that.profileImage);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements EngineerBioEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EngineerBioEvent.started()';
}


}




/// @nodoc


class _UploadEngBio implements EngineerBioEvent {
  const _UploadEngBio({required this.engineerId, required this.projectName, required this.categoryId, required this.cent, required this.squareFeet, required this.expectedAmount, required this.additionalAmount, required this.totalAmount, required final  List<int> additionalFeatures, required this.timeDuration, required final  List<File> images, this.profileImage}): _additionalFeatures = additionalFeatures,_images = images;
  

 final  int engineerId;
 final  String projectName;
 final  int categoryId;
 final  double cent;
 final  double squareFeet;
 final  int expectedAmount;
 final  int additionalAmount;
 final  double totalAmount;
 final  List<int> _additionalFeatures;
 List<int> get additionalFeatures {
  if (_additionalFeatures is EqualUnmodifiableListView) return _additionalFeatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_additionalFeatures);
}

 final  String timeDuration;
 final  List<File> _images;
 List<File> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  File? profileImage;

/// Create a copy of EngineerBioEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadEngBioCopyWith<_UploadEngBio> get copyWith => __$UploadEngBioCopyWithImpl<_UploadEngBio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadEngBio&&(identical(other.engineerId, engineerId) || other.engineerId == engineerId)&&(identical(other.projectName, projectName) || other.projectName == projectName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.cent, cent) || other.cent == cent)&&(identical(other.squareFeet, squareFeet) || other.squareFeet == squareFeet)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.additionalAmount, additionalAmount) || other.additionalAmount == additionalAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&const DeepCollectionEquality().equals(other._additionalFeatures, _additionalFeatures)&&(identical(other.timeDuration, timeDuration) || other.timeDuration == timeDuration)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage));
}


@override
int get hashCode => Object.hash(runtimeType,engineerId,projectName,categoryId,cent,squareFeet,expectedAmount,additionalAmount,totalAmount,const DeepCollectionEquality().hash(_additionalFeatures),timeDuration,const DeepCollectionEquality().hash(_images),profileImage);

@override
String toString() {
  return 'EngineerBioEvent.uploadEngBio(engineerId: $engineerId, projectName: $projectName, categoryId: $categoryId, cent: $cent, squareFeet: $squareFeet, expectedAmount: $expectedAmount, additionalAmount: $additionalAmount, totalAmount: $totalAmount, additionalFeatures: $additionalFeatures, timeDuration: $timeDuration, images: $images, profileImage: $profileImage)';
}


}

/// @nodoc
abstract mixin class _$UploadEngBioCopyWith<$Res> implements $EngineerBioEventCopyWith<$Res> {
  factory _$UploadEngBioCopyWith(_UploadEngBio value, $Res Function(_UploadEngBio) _then) = __$UploadEngBioCopyWithImpl;
@useResult
$Res call({
 int engineerId, String projectName, int categoryId, double cent, double squareFeet, int expectedAmount, int additionalAmount, double totalAmount, List<int> additionalFeatures, String timeDuration, List<File> images, File? profileImage
});




}
/// @nodoc
class __$UploadEngBioCopyWithImpl<$Res>
    implements _$UploadEngBioCopyWith<$Res> {
  __$UploadEngBioCopyWithImpl(this._self, this._then);

  final _UploadEngBio _self;
  final $Res Function(_UploadEngBio) _then;

/// Create a copy of EngineerBioEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? engineerId = null,Object? projectName = null,Object? categoryId = null,Object? cent = null,Object? squareFeet = null,Object? expectedAmount = null,Object? additionalAmount = null,Object? totalAmount = null,Object? additionalFeatures = null,Object? timeDuration = null,Object? images = null,Object? profileImage = freezed,}) {
  return _then(_UploadEngBio(
engineerId: null == engineerId ? _self.engineerId : engineerId // ignore: cast_nullable_to_non_nullable
as int,projectName: null == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,cent: null == cent ? _self.cent : cent // ignore: cast_nullable_to_non_nullable
as double,squareFeet: null == squareFeet ? _self.squareFeet : squareFeet // ignore: cast_nullable_to_non_nullable
as double,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as int,additionalAmount: null == additionalAmount ? _self.additionalAmount : additionalAmount // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,additionalFeatures: null == additionalFeatures ? _self._additionalFeatures : additionalFeatures // ignore: cast_nullable_to_non_nullable
as List<int>,timeDuration: null == timeDuration ? _self.timeDuration : timeDuration // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<File>,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as File?,
  ));
}


}

/// @nodoc
mixin _$EngineerBioState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngineerBioState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EngineerBioState()';
}


}

/// @nodoc
class $EngineerBioStateCopyWith<$Res>  {
$EngineerBioStateCopyWith(EngineerBioState _, $Res Function(EngineerBioState) __);
}


/// Adds pattern-matching-related methods to [EngineerBioState].
extension EngineerBioStatePatterns on EngineerBioState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( EngineerBioModel response)?  success,TResult Function( String error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.response);case _Error() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( EngineerBioModel response)  success,required TResult Function( String error)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Success():
return success(_that.response);case _Error():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( EngineerBioModel response)?  success,TResult? Function( String error)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.response);case _Error() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements EngineerBioState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EngineerBioState.initial()';
}


}




/// @nodoc


class _Loading implements EngineerBioState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EngineerBioState.loading()';
}


}




/// @nodoc


class _Success implements EngineerBioState {
  const _Success({required this.response});
  

 final  EngineerBioModel response;

/// Create a copy of EngineerBioState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'EngineerBioState.success(response: $response)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $EngineerBioStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 EngineerBioModel response
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of EngineerBioState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(_Success(
response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as EngineerBioModel,
  ));
}


}

/// @nodoc


class _Error implements EngineerBioState {
  const _Error({required this.error});
  

 final  String error;

/// Create a copy of EngineerBioState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'EngineerBioState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $EngineerBioStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of EngineerBioState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Error(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
