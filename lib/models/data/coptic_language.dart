import 'package:churchdata_core/churchdata_core.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'coptic_language.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class CopticLanguage extends DataObject {
  final List<String> resources;
  final List<JsonRef> studyYears;

  List<Reference> get resourcesReferences =>
      resources.map(GetIt.I<StorageRepository>().ref).toList();

  const CopticLanguage({
    required JsonRef ref,
    required String name,
    this.resources = const [],
    this.studyYears = const [],
  }) : super(ref, name);

  factory CopticLanguage.empty() {
    return CopticLanguage(
      ref: GetIt.I<DatabaseRepository>()
          .collection('CopticLanguage')
          .doc('null'),
      name: '',
    );
  }

  static CopticLanguage? fromDoc(JsonDoc doc) => doc.data() != null
      ? CopticLanguage.fromJson(doc.data()!, doc.reference)
      : null;

  factory CopticLanguage.fromQueryDoc(JsonQueryDoc doc) =>
      CopticLanguage.fromJson(doc.data(), doc.reference);

  CopticLanguage.fromJson(Json json, JsonRef ref)
      : this(
          ref: ref,
          name: json['Name'],
          resources: (json['Resources'] as List?)?.cast() ?? [],
          studyYears: (json['StudyYears'] as List?)?.cast() ?? [],
        );

  @override
  Json toJson() {
    return {
      'Name': name,
      'Resources': resources,
      'StudyYears': studyYears,
    };
  }
}
