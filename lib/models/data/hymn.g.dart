// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hymn.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HymnCWProxy {
  Hymn ref(DocumentReference<Map<String, dynamic>> ref);

  Hymn name(String name);

  Hymn level(int level);

  Hymn liturgicalInfo(String? liturgicalInfo);

  Hymn textPDFResource(String? textPDFResource);

  Hymn mediaLink(String? mediaLink);

  Hymn studyYears(List<DocumentReference<Map<String, dynamic>>> studyYears);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Hymn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Hymn(...).copyWith(id: 12, name: "My name")
  /// ````
  Hymn call({
    DocumentReference<Map<String, dynamic>>? ref,
    String? name,
    int? level,
    String? liturgicalInfo,
    String? textPDFResource,
    String? mediaLink,
    List<DocumentReference<Map<String, dynamic>>>? studyYears,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHymn.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHymn.copyWith.fieldName(...)`
class _$HymnCWProxyImpl implements _$HymnCWProxy {
  const _$HymnCWProxyImpl(this._value);

  final Hymn _value;

  @override
  Hymn ref(DocumentReference<Map<String, dynamic>> ref) => this(ref: ref);

  @override
  Hymn name(String name) => this(name: name);

  @override
  Hymn level(int level) => this(level: level);

  @override
  Hymn liturgicalInfo(String? liturgicalInfo) =>
      this(liturgicalInfo: liturgicalInfo);

  @override
  Hymn textPDFResource(String? textPDFResource) =>
      this(textPDFResource: textPDFResource);

  @override
  Hymn mediaLink(String? mediaLink) => this(mediaLink: mediaLink);

  @override
  Hymn studyYears(List<DocumentReference<Map<String, dynamic>>> studyYears) =>
      this(studyYears: studyYears);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Hymn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Hymn(...).copyWith(id: 12, name: "My name")
  /// ````
  Hymn call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
    Object? liturgicalInfo = const $CopyWithPlaceholder(),
    Object? textPDFResource = const $CopyWithPlaceholder(),
    Object? mediaLink = const $CopyWithPlaceholder(),
    Object? studyYears = const $CopyWithPlaceholder(),
  }) {
    return Hymn(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Map<String, dynamic>>,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      level: level == const $CopyWithPlaceholder() || level == null
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as int,
      liturgicalInfo: liturgicalInfo == const $CopyWithPlaceholder()
          ? _value.liturgicalInfo
          // ignore: cast_nullable_to_non_nullable
          : liturgicalInfo as String?,
      textPDFResource: textPDFResource == const $CopyWithPlaceholder()
          ? _value.textPDFResource
          // ignore: cast_nullable_to_non_nullable
          : textPDFResource as String?,
      mediaLink: mediaLink == const $CopyWithPlaceholder()
          ? _value.mediaLink
          // ignore: cast_nullable_to_non_nullable
          : mediaLink as String?,
      studyYears:
          studyYears == const $CopyWithPlaceholder() || studyYears == null
              ? _value.studyYears
              // ignore: cast_nullable_to_non_nullable
              : studyYears as List<DocumentReference<Map<String, dynamic>>>,
    );
  }
}

extension $HymnCopyWith on Hymn {
  /// Returns a callable class that can be used as follows: `instanceOfHymn.copyWith(...)` or like so:`instanceOfHymn.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HymnCWProxy get copyWith => _$HymnCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)` or `Hymn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Hymn(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  Hymn copyWithNull({
    bool liturgicalInfo = false,
    bool textPDFResource = false,
    bool mediaLink = false,
  }) {
    return Hymn(
      ref: ref,
      name: name,
      level: level,
      liturgicalInfo: liturgicalInfo == true ? null : this.liturgicalInfo,
      textPDFResource: textPDFResource == true ? null : this.textPDFResource,
      mediaLink: mediaLink == true ? null : this.mediaLink,
      studyYears: studyYears,
    );
  }
}
