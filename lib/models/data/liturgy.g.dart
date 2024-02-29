// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liturgy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LiturgyCWProxy {
  Liturgy ref(DocumentReference<Map<String, dynamic>> ref);

  Liturgy name(String name);

  Liturgy resources(List<String> resources);

  Liturgy studyYears(List<DocumentReference<Map<String, dynamic>>> studyYears);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Liturgy(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Liturgy(...).copyWith(id: 12, name: "My name")
  /// ````
  Liturgy call({
    DocumentReference<Map<String, dynamic>>? ref,
    String? name,
    List<String>? resources,
    List<DocumentReference<Map<String, dynamic>>>? studyYears,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLiturgy.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLiturgy.copyWith.fieldName(...)`
class _$LiturgyCWProxyImpl implements _$LiturgyCWProxy {
  const _$LiturgyCWProxyImpl(this._value);

  final Liturgy _value;

  @override
  Liturgy ref(DocumentReference<Map<String, dynamic>> ref) => this(ref: ref);

  @override
  Liturgy name(String name) => this(name: name);

  @override
  Liturgy resources(List<String> resources) => this(resources: resources);

  @override
  Liturgy studyYears(
          List<DocumentReference<Map<String, dynamic>>> studyYears) =>
      this(studyYears: studyYears);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Liturgy(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Liturgy(...).copyWith(id: 12, name: "My name")
  /// ````
  Liturgy call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? resources = const $CopyWithPlaceholder(),
    Object? studyYears = const $CopyWithPlaceholder(),
  }) {
    return Liturgy(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Map<String, dynamic>>,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      resources: resources == const $CopyWithPlaceholder() || resources == null
          ? _value.resources
          // ignore: cast_nullable_to_non_nullable
          : resources as List<String>,
      studyYears:
          studyYears == const $CopyWithPlaceholder() || studyYears == null
              ? _value.studyYears
              // ignore: cast_nullable_to_non_nullable
              : studyYears as List<DocumentReference<Map<String, dynamic>>>,
    );
  }
}

extension $LiturgyCopyWith on Liturgy {
  /// Returns a callable class that can be used as follows: `instanceOfLiturgy.copyWith(...)` or like so:`instanceOfLiturgy.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LiturgyCWProxy get copyWith => _$LiturgyCWProxyImpl(this);
}
