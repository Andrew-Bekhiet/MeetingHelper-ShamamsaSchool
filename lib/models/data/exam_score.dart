import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

part 'exam_score.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class ExamScore extends DataObject {
  final int year;
  final DateTime date;
  final JsonRef subject;
  final int term;
  final int score;
  final JsonRef personId;
  final JsonRef classId;

  ExamScore({
    required JsonRef ref,
    required this.year,
    required this.date,
    required this.subject,
    required this.term,
    required this.score,
    required this.personId,
    required this.classId,
  }) : super(ref, 'ExamScore: ${ref.id}');

  ExamScore.fromJson(super.data, super.ref)
      : year = data['Year'],
        date = DateTime.parse(data['Date']),
        subject = data['Subject'],
        term = data['Term'],
        score = data['Score'],
        personId = data['PersonId'],
        classId = data['ClassId'],
        super.fromJson();

  ExamScore.fromDoc(JsonDoc doc) : this.fromJson(doc.data()!, doc.reference);

  @override
  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Date': date.toIso8601String().split('T').first,
      'Subject': subject,
      'Term': term,
      'Score': score,
      'PersonId': personId,
      'ClassId': classId,
    };
  }
}
