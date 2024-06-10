import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

part 'term.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class Term {
  final DocumentReference ref;
  final int order;
  final DateTime from;
  final DateTime to;

  const Term({
    required this.ref,
    required this.order,
    required this.from,
    required this.to,
  });

  factory Term.fromJson(JsonDoc doc) => Term(
        ref: doc.reference,
        order: doc['Order'] as int,
        from: DateTime.parse(doc['From'] as String),
        to: DateTime.parse(doc['To'] as String),
      );

  factory Term.fromDefaultTermData(JsonDoc doc) {
    final DateTime now = DateTime.now();
    final String from = now.year.toString() + '-' + doc['From'];
    final String to = now.year.toString() + '-' + doc['To'];

    return Term(
      ref: doc.reference,
      order: doc['Order'],
      from: DateTime.parse(from),
      to: DateTime.parse(to),
    );
  }

  String get id => ref.id;

  Json toJson() => {'Order': order, 'From': from, 'To': to};
}
