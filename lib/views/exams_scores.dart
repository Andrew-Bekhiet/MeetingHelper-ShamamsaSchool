import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetinghelper/repositories/database_repository.dart';

import '../models.dart';

typedef Year = int;
typedef Term = int;

class ExamsScores extends StatefulWidget {
  final Person? person;

  const ExamsScores({super.key, this.person});

  @override
  State<ExamsScores> createState() => _ExamsScoresState();
}

class _ExamsScoresState extends State<ExamsScores> {
  // static const _minSearchYear = 2024;
  // final List<int> searchYears = [
  //   for (int y = _minSearchYear; y <= DateTime.now().year; y++) y,
  // ];

  late final Stream<List<ExamScore>> scoresStream;
  late final Stream<Map<Year, Map<Term, List<ExamScore>>>>
      structuredScoresStream;

  final Map<String, Future<Subject?>> _subjectsDataFutures = {};

  @override
  void initState() {
    super.initState();

    _initStreams();
  }

  void _initStreams() {
    scoresStream = MHDatabaseRepo.I.examsScores.getAll(
      queryCompleter: (q, orderBy, descending) {
        if (widget.person != null) {
          return q
              .where('PersonId', isEqualTo: widget.person!.ref)
              .orderBy(orderBy, descending: descending);
        }
        return q.orderBy(orderBy, descending: descending);
      },
    );

    structuredScoresStream = scoresStream.map(
      (scores) => _sortStructuredScores(_organizeScores(scores)),
    );
  }

  Map<Year, Map<Term, List<ExamScore>>> _organizeScores(
    List<ExamScore> scores,
  ) {
    return scores.groupFoldBy<Year, Map<Term, List<ExamScore>>>(
      (score) => score.year,
      (yearScores, score) => {
        ...yearScores ?? {},
        score.term: [
          ...yearScores?[score.term] ?? [],
          score,
        ],
      },
    );
  }

  Map<Year, Map<Term, List<ExamScore>>> _sortStructuredScores(
    Map<Year, Map<Term, List<ExamScore>>> structuredScores,
  ) {
    return structuredScores.map(
      (year, yearScores) => MapEntry(
        year,
        Map.fromEntries(
          yearScores.entries
              .sortedByCompare(
                (e) => e.key,
                (a, b) => a.compareTo(b),
              )
              .map(
                (e) => MapEntry(
                  e.key,
                  e.value.sortedByCompare(
                    (s) => s.id,
                    (a, b) => a.compareTo(b),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درجات الامتحانات'),
      ),
      body: StreamBuilder<Map<Year, Map<Term, List<ExamScore>>>>(
        stream: structuredScoresStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget.builder(
              FlutterErrorDetails(
                exception: snapshot.error!,
                stack: snapshot.stackTrace,
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text('لا توجد امتحانات سابقة ل${widget.person?.name}'),
            );
          }

          final Map<Year, Map<Term, List<ExamScore>>> scores =
              snapshot.data ?? {};

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, i) {
              final year = scores.keys.elementAt(i);
              final Map<Term, List<ExamScore>> yearScores = scores[year]!;

              return ExpansionTile(
                title: Text(year.toString()),
                childrenPadding: const EdgeInsets.only(right: 8),
                children: [
                  for (final term in yearScores.keys)
                    ExpansionTile(
                      title: Text('ترم $term'),
                      childrenPadding: const EdgeInsets.only(right: 8),
                      children: [
                        for (final score in yearScores[term]!)
                          _ExamScoreWidget(
                            subjectsDataFutures: _subjectsDataFutures,
                            score: score,
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ExamScoreWidget extends StatelessWidget {
  const _ExamScoreWidget({
    required Map<String, Future<Subject?>> subjectsDataFutures,
    required this.score,
  }) : _subjectsDataFutures = subjectsDataFutures;

  final Map<String, Future<Subject?>> _subjectsDataFutures;
  final ExamScore score;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _subjectsDataFutures[score.subject.id] ??=
          MHDatabaseRepo.I.subjects.getById(score.subject.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (!snapshot.hasData) {
          return const Text('غير معروف');
        }

        return ListTile(
          title: Row(
            children: [
              Expanded(child: Text(snapshot.data!.name)),
              Text(
                DateFormat('yyyy/M/d', 'ar-EG').format(score.date),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(score.score.toString()),
              ),
              // arabic grade name based on score percentage
              Text(
                switch (score.score / snapshot.data!.fullMark) {
                  >= 0.9 => 'امتياز',
                  >= 0.8 => 'جيد جداً',
                  >= 0.7 => 'جيد',
                  >= 0.5 => 'مقبول',
                  _ => 'لم يجتاز',
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
