import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'curriculum_stage.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class CurriculumStage extends DataObject implements PhotoObjectBase {
  final List<JsonRef> studyYears;

  CurriculumStage({
    required JsonRef ref,
    required String name,
    required this.studyYears,
  }) : super(ref, name);

  factory CurriculumStage.empty() {
    return CurriculumStage(
      ref: GetIt.I<DatabaseRepository>()
          .collection('CurriculaStages')
          .doc('null'),
      name: '',
      studyYears: const [],
    );
  }

  static CurriculumStage? fromDoc(JsonDoc doc) => doc.data() != null
      ? CurriculumStage.fromJson(doc.data()!, doc.reference)
      : null;

  factory CurriculumStage.fromQueryDoc(JsonQueryDoc doc) =>
      CurriculumStage.fromJson(doc.data(), doc.reference);

  CurriculumStage.fromJson(Json json, JsonRef ref)
      : this(
          ref: ref,
          name: json['Name'],
          studyYears: (json['StudyYears'] as List?)?.cast() ?? [],
        );

  @override
  bool get hasPhoto => false;

  @override
  Reference? get photoRef => null;

  @override
  final AsyncMemoizerCache<String> photoUrlCache = AsyncMemoizerCache<String>();

  @override
  IconData get defaultIcon => Icons.library_books;

  @override
  Json toJson() {
    return {
      'Name': name,
      'StudyYears': studyYears,
    };
  }
}
