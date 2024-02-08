// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_stage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CurriculumStageCWProxy {
  CurriculumStage ref(DocumentReference<Map<String, dynamic>> ref);

  CurriculumStage name(String name);

  CurriculumStage studyYears(
      List<DocumentReference<Map<String, dynamic>>> studyYears);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurriculumStage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurriculumStage(...).copyWith(id: 12, name: "My name")
  /// ````
  CurriculumStage call({
    DocumentReference<Map<String, dynamic>>? ref,
    String? name,
    List<DocumentReference<Map<String, dynamic>>>? studyYears,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurriculumStage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurriculumStage.copyWith.fieldName(...)`
class _$CurriculumStageCWProxyImpl implements _$CurriculumStageCWProxy {
  const _$CurriculumStageCWProxyImpl(this._value);

  final CurriculumStage _value;

  @override
  CurriculumStage ref(DocumentReference<Map<String, dynamic>> ref) =>
      this(ref: ref);

  @override
  CurriculumStage name(String name) => this(name: name);

  @override
  CurriculumStage studyYears(
          List<DocumentReference<Map<String, dynamic>>> studyYears) =>
      this(studyYears: studyYears);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurriculumStage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurriculumStage(...).copyWith(id: 12, name: "My name")
  /// ````
  CurriculumStage call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? studyYears = const $CopyWithPlaceholder(),
  }) {
    return CurriculumStage(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Map<String, dynamic>>,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      studyYears:
          studyYears == const $CopyWithPlaceholder() || studyYears == null
              ? _value.studyYears
              // ignore: cast_nullable_to_non_nullable
              : studyYears as List<DocumentReference<Map<String, dynamic>>>,
    );
  }
}

extension $CurriculumStageCopyWith on CurriculumStage {
  /// Returns a callable class that can be used as follows: `instanceOfCurriculumStage.copyWith(...)` or like so:`instanceOfCurriculumStage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurriculumStageCWProxy get copyWith => _$CurriculumStageCWProxyImpl(this);
}
