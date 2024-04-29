// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_score.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamScoreCWProxy {
  ExamScore ref(DocumentReference<Map<String, dynamic>> ref);

  ExamScore year(int year);

  ExamScore date(DateTime date);

  ExamScore subject(DocumentReference<Map<String, dynamic>> subject);

  ExamScore term(int term);

  ExamScore score(int score);

  ExamScore personId(DocumentReference<Map<String, dynamic>> personId);

  ExamScore classId(DocumentReference<Map<String, dynamic>> classId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamScore(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamScore(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamScore call({
    DocumentReference<Map<String, dynamic>>? ref,
    int? year,
    DateTime? date,
    DocumentReference<Map<String, dynamic>>? subject,
    int? term,
    int? score,
    DocumentReference<Map<String, dynamic>>? personId,
    DocumentReference<Map<String, dynamic>>? classId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamScore.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamScore.copyWith.fieldName(...)`
class _$ExamScoreCWProxyImpl implements _$ExamScoreCWProxy {
  const _$ExamScoreCWProxyImpl(this._value);

  final ExamScore _value;

  @override
  ExamScore ref(DocumentReference<Map<String, dynamic>> ref) => this(ref: ref);

  @override
  ExamScore year(int year) => this(year: year);

  @override
  ExamScore date(DateTime date) => this(date: date);

  @override
  ExamScore subject(DocumentReference<Map<String, dynamic>> subject) =>
      this(subject: subject);

  @override
  ExamScore term(int term) => this(term: term);

  @override
  ExamScore score(int score) => this(score: score);

  @override
  ExamScore personId(DocumentReference<Map<String, dynamic>> personId) =>
      this(personId: personId);

  @override
  ExamScore classId(DocumentReference<Map<String, dynamic>> classId) =>
      this(classId: classId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamScore(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamScore(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamScore call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? subject = const $CopyWithPlaceholder(),
    Object? term = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? personId = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
  }) {
    return ExamScore(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Map<String, dynamic>>,
      year: year == const $CopyWithPlaceholder() || year == null
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int,
      date: date == const $CopyWithPlaceholder() || date == null
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      subject: subject == const $CopyWithPlaceholder() || subject == null
          ? _value.subject
          // ignore: cast_nullable_to_non_nullable
          : subject as DocumentReference<Map<String, dynamic>>,
      term: term == const $CopyWithPlaceholder() || term == null
          ? _value.term
          // ignore: cast_nullable_to_non_nullable
          : term as int,
      score: score == const $CopyWithPlaceholder() || score == null
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as int,
      personId: personId == const $CopyWithPlaceholder() || personId == null
          ? _value.personId
          // ignore: cast_nullable_to_non_nullable
          : personId as DocumentReference<Map<String, dynamic>>,
      classId: classId == const $CopyWithPlaceholder() || classId == null
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as DocumentReference<Map<String, dynamic>>,
    );
  }
}

extension $ExamScoreCopyWith on ExamScore {
  /// Returns a callable class that can be used as follows: `instanceOfExamScore.copyWith(...)` or like so:`instanceOfExamScore.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamScoreCWProxy get copyWith => _$ExamScoreCWProxyImpl(this);
}
