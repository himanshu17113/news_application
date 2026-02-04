// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_source_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ArticleSourceModel _$ArticleSourceModelFromJson(Map<String, dynamic> json) {
  return _ArticleSourceModel.fromJson(json);
}

/// @nodoc
mixin _$ArticleSourceModel {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this ArticleSourceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleSourceModelCopyWith<ArticleSourceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleSourceModelCopyWith<$Res> {
  factory $ArticleSourceModelCopyWith(
          ArticleSourceModel value, $Res Function(ArticleSourceModel) then) =
      _$ArticleSourceModelCopyWithImpl<$Res, ArticleSourceModel>;
  @useResult
  $Res call({String? id, String? name});
}

/// @nodoc
class _$ArticleSourceModelCopyWithImpl<$Res, $Val extends ArticleSourceModel>
    implements $ArticleSourceModelCopyWith<$Res> {
  _$ArticleSourceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArticleSourceModelImplCopyWith<$Res>
    implements $ArticleSourceModelCopyWith<$Res> {
  factory _$$ArticleSourceModelImplCopyWith(_$ArticleSourceModelImpl value,
          $Res Function(_$ArticleSourceModelImpl) then) =
      __$$ArticleSourceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? name});
}

/// @nodoc
class __$$ArticleSourceModelImplCopyWithImpl<$Res>
    extends _$ArticleSourceModelCopyWithImpl<$Res, _$ArticleSourceModelImpl>
    implements _$$ArticleSourceModelImplCopyWith<$Res> {
  __$$ArticleSourceModelImplCopyWithImpl(_$ArticleSourceModelImpl _value,
      $Res Function(_$ArticleSourceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArticleSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$ArticleSourceModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleSourceModelImpl implements _ArticleSourceModel {
  const _$ArticleSourceModelImpl({this.id, this.name});

  factory _$ArticleSourceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleSourceModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'ArticleSourceModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleSourceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of ArticleSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleSourceModelImplCopyWith<_$ArticleSourceModelImpl> get copyWith =>
      __$$ArticleSourceModelImplCopyWithImpl<_$ArticleSourceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleSourceModelImplToJson(
      this,
    );
  }
}

abstract class _ArticleSourceModel implements ArticleSourceModel {
  const factory _ArticleSourceModel({final String? id, final String? name}) =
      _$ArticleSourceModelImpl;

  factory _ArticleSourceModel.fromJson(Map<String, dynamic> json) =
      _$ArticleSourceModelImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;

  /// Create a copy of ArticleSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleSourceModelImplCopyWith<_$ArticleSourceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
