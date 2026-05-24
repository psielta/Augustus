// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registro_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistroModel {

 UsuarioModel get usuario; String get mensagem;
/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistroModelCopyWith<RegistroModel> get copyWith => _$RegistroModelCopyWithImpl<RegistroModel>(this as RegistroModel, _$identity);

  /// Serializes this RegistroModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistroModel&&(identical(other.usuario, usuario) || other.usuario == usuario)&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usuario,mensagem);

@override
String toString() {
  return 'RegistroModel(usuario: $usuario, mensagem: $mensagem)';
}


}

/// @nodoc
abstract mixin class $RegistroModelCopyWith<$Res>  {
  factory $RegistroModelCopyWith(RegistroModel value, $Res Function(RegistroModel) _then) = _$RegistroModelCopyWithImpl;
@useResult
$Res call({
 UsuarioModel usuario, String mensagem
});


$UsuarioModelCopyWith<$Res> get usuario;

}
/// @nodoc
class _$RegistroModelCopyWithImpl<$Res>
    implements $RegistroModelCopyWith<$Res> {
  _$RegistroModelCopyWithImpl(this._self, this._then);

  final RegistroModel _self;
  final $Res Function(RegistroModel) _then;

/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usuario = null,Object? mensagem = null,}) {
  return _then(_self.copyWith(
usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as UsuarioModel,mensagem: null == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsuarioModelCopyWith<$Res> get usuario {
  
  return $UsuarioModelCopyWith<$Res>(_self.usuario, (value) {
    return _then(_self.copyWith(usuario: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegistroModel].
extension RegistroModelPatterns on RegistroModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistroModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistroModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistroModel value)  $default,){
final _that = this;
switch (_that) {
case _RegistroModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistroModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegistroModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UsuarioModel usuario,  String mensagem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistroModel() when $default != null:
return $default(_that.usuario,_that.mensagem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UsuarioModel usuario,  String mensagem)  $default,) {final _that = this;
switch (_that) {
case _RegistroModel():
return $default(_that.usuario,_that.mensagem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UsuarioModel usuario,  String mensagem)?  $default,) {final _that = this;
switch (_that) {
case _RegistroModel() when $default != null:
return $default(_that.usuario,_that.mensagem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistroModel implements RegistroModel {
  const _RegistroModel({required this.usuario, required this.mensagem});
  factory _RegistroModel.fromJson(Map<String, dynamic> json) => _$RegistroModelFromJson(json);

@override final  UsuarioModel usuario;
@override final  String mensagem;

/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistroModelCopyWith<_RegistroModel> get copyWith => __$RegistroModelCopyWithImpl<_RegistroModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistroModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistroModel&&(identical(other.usuario, usuario) || other.usuario == usuario)&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usuario,mensagem);

@override
String toString() {
  return 'RegistroModel(usuario: $usuario, mensagem: $mensagem)';
}


}

/// @nodoc
abstract mixin class _$RegistroModelCopyWith<$Res> implements $RegistroModelCopyWith<$Res> {
  factory _$RegistroModelCopyWith(_RegistroModel value, $Res Function(_RegistroModel) _then) = __$RegistroModelCopyWithImpl;
@override @useResult
$Res call({
 UsuarioModel usuario, String mensagem
});


@override $UsuarioModelCopyWith<$Res> get usuario;

}
/// @nodoc
class __$RegistroModelCopyWithImpl<$Res>
    implements _$RegistroModelCopyWith<$Res> {
  __$RegistroModelCopyWithImpl(this._self, this._then);

  final _RegistroModel _self;
  final $Res Function(_RegistroModel) _then;

/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usuario = null,Object? mensagem = null,}) {
  return _then(_RegistroModel(
usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as UsuarioModel,mensagem: null == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RegistroModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsuarioModelCopyWith<$Res> get usuario {
  
  return $UsuarioModelCopyWith<$Res>(_self.usuario, (value) {
    return _then(_self.copyWith(usuario: value));
  });
}
}

// dart format on
