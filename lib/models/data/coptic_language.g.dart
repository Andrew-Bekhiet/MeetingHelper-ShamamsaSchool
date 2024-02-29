// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coptic_language.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CopticLanguageCWProxy {
  CopticLanguage ref(DocumentReference<Map<String, dynamic>> ref);

  CopticLanguage name(String name);

  CopticLanguage resources(List<String> resources);

  CopticLanguage studyYears(
      List<DocumentReference<Map<String, dynamic>>> studyYears);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CopticLanguage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CopticLanguage(...).copyWith(id: 12, name: "My name")
  /// ````
  CopticLanguage call({
    DocumentReference<Map<String, dynamic>>? ref,
    String? name,
    List<String>? resources,
    List<DocumentReference<Map<String, dynamic>>>? studyYears,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCopticLanguage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCopticLanguage.copyWith.fieldName(...)`
class _$CopticLanguageCWProxyImpl implements _$CopticLanguageCWProxy {
  const _$CopticLanguageCWProxyImpl(this._value);

  final CopticLanguage _value;

  @override
  CopticLanguage ref(DocumentReference<Map<String, dynamic>> ref) =>
      this(ref: ref);

  @override
  CopticLanguage name(String name) => this(name: name);

  @override
  CopticLanguage resources(List<String> resources) =>
      this(resources: resources);

  @override
  CopticLanguage studyYears(
          List<DocumentReference<Map<String, dynamic>>> studyYears) =>
      this(studyYears: studyYears);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CopticLanguage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CopticLanguage(...).copyWith(id: 12, name: "My name")
  /// ````
  CopticLanguage call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? resources = const $CopyWithPlaceholder(),
    Object? studyYears = const $CopyWithPlaceholder(),
  }) {
    return CopticLanguage(
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

extension $CopticLanguageCopyWith on CopticLanguage {
  /// Returns a callable class that can be used as follows: `instanceOfCopticLanguage.copyWith(...)` or like so:`instanceOfCopticLanguage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CopticLanguageCWProxy get copyWith => _$CopticLanguageCWProxyImpl(this);
}
