import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'hymn.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class Hymn extends DataObject {
  final String? liturgicalInfo;
  final int level;
  final String? textPDFResource;
  final String? mediaLink;
  final List<JsonRef> studyYears;

  Reference? get textPDFReference => textPDFResource != null
      ? GetIt.I<StorageRepository>().ref(textPDFResource)
      : null;

  const Hymn({
    required JsonRef ref,
    required String name,
    required this.level,
    this.liturgicalInfo,
    this.textPDFResource,
    this.mediaLink,
    this.studyYears = const [],
  }) : super(ref, name);

  factory Hymn.empty() {
    return Hymn(
      ref: GetIt.I<DatabaseRepository>().collection('Hymns').doc('null'),
      name: '',
      level: 0,
    );
  }

  static Hymn? fromDoc(JsonDoc doc) =>
      doc.data() != null ? Hymn.fromJson(doc.data()!, doc.reference) : null;

  factory Hymn.fromQueryDoc(JsonQueryDoc doc) =>
      Hymn.fromJson(doc.data(), doc.reference);

  Hymn.fromJson(Json json, JsonRef ref)
      : this(
          ref: ref,
          name: json['Name'],
          liturgicalInfo: json['LiturgicalInfo'],
          level: json['Level'],
          studyYears: (json['StudyYears'] as List?)?.cast() ?? [],
          textPDFResource: json['TextPDFResource'],
          mediaLink: json['MediaLink'],
        );

  String get difficultyLevelDescription => switch (level) {
        0 => 'سهل',
        1 => 'متوسط',
        2 => 'صعب',
        _ => 'غير معروف',
      };

  @override
  Future<String?> getSecondLine() {
    return Future.value(difficultyLevelDescription);
  }

  @override
  Json toJson() {
    return {
      'Name': name,
      'LiturgicalInfo': liturgicalInfo,
      'Level': level,
      'TextPDFResource': textPDFResource,
      'MediaLink': mediaLink,
      'StudyYears': studyYears,
    };
  }
}
