import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

part 'subject.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class Subject extends DataObject {
  final int fullMark;

  const Subject({
    required JsonRef ref,
    required String name,
    required this.fullMark,
  }) : super(ref, name);

  Subject.fromJson(super.data, super.ref)
      : fullMark = data['FullMark'],
        super.fromJson();

  Subject.fromDoc(JsonDoc doc) : this.fromJson(doc.data()!, doc.reference);

  @override
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'FullMark': fullMark,
    };
  }
}
