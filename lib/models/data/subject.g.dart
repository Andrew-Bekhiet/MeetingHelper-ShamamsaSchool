// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubjectCWProxy {
  Subject ref(DocumentReference<Map<String, dynamic>> ref);

  Subject name(String name);

  Subject fullMark(int fullMark);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({
    DocumentReference<Map<String, dynamic>>? ref,
    String? name,
    int? fullMark,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubject.copyWith.fieldName(...)`
class _$SubjectCWProxyImpl implements _$SubjectCWProxy {
  const _$SubjectCWProxyImpl(this._value);

  final Subject _value;

  @override
  Subject ref(DocumentReference<Map<String, dynamic>> ref) => this(ref: ref);

  @override
  Subject name(String name) => this(name: name);

  @override
  Subject fullMark(int fullMark) => this(fullMark: fullMark);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? fullMark = const $CopyWithPlaceholder(),
  }) {
    return Subject(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Map<String, dynamic>>,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      fullMark: fullMark == const $CopyWithPlaceholder() || fullMark == null
          ? _value.fullMark
          // ignore: cast_nullable_to_non_nullable
          : fullMark as int,
    );
  }
}

extension $SubjectCopyWith on Subject {
  /// Returns a callable class that can be used as follows: `instanceOfSubject.copyWith(...)` or like so:`instanceOfSubject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubjectCWProxy get copyWith => _$SubjectCWProxyImpl(this);
}
