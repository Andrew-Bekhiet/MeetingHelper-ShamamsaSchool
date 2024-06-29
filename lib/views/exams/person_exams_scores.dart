import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetinghelper/repositories/database/exams_scores.dart';
import 'package:meetinghelper/repositories/database_repository.dart';

import '../../models.dart' hide Term;

class PersonExamsScores extends StatefulWidget {
  final Person person;

  const PersonExamsScores({required this.person, super.key});

  @override
  State<PersonExamsScores> createState() => _PersonExamsScoresState();
}

class _PersonExamsScoresState extends State<PersonExamsScores> {
  late Stream<Map<Year, Map<TermOrder, List<ExamScore>>>>
      structuredScoresStream;

  final Map<String, Future<Subject?>> _subjectsDataFutures = {};

  @override
  void initState() {
    super.initState();

    structuredScoresStream = MHDatabaseRepo.I.examsScores.getStructuredScores(
      queryCompleter: (q, orderBy, descending) {
        return q
            .where('PersonId', isEqualTo: widget.person.ref)
            .orderBy(orderBy, descending: descending);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درجات الامتحانات'),
      ),
      body: StreamBuilder<Map<Year, Map<TermOrder, List<ExamScore>>>>(
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
              child: Text('لا توجد امتحانات سابقة ل${widget.person.name}'),
            );
          }

          final Map<Year, Map<TermOrder, List<ExamScore>>> scores =
              snapshot.data ?? {};

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, i) {
              final year = scores.keys.elementAt(i);
              final Map<TermOrder, List<ExamScore>> yearScores = scores[year]!;

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
                            person: widget.person,
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'إضافة نتيجة امتحان',
        onPressed: () => Navigator.of(context)
            .pushNamed('EditExamsScore', arguments: {Person: widget.person}),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExamScoreWidget extends StatelessWidget {
  const _ExamScoreWidget({
    required Map<String, Future<Subject?>> subjectsDataFutures,
    required this.score,
    required this.person,
  }) : _subjectsDataFutures = subjectsDataFutures;

  final Map<String, Future<Subject?>> _subjectsDataFutures;
  final ExamScore score;
  final Person person;

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
          onTap: () => Navigator.of(context).pushNamed(
            'EditExamsScore',
            arguments: {Person: person, ExamScore: score},
          ),
          title: Row(
            children: [
              Expanded(child: Text(snapshot.data!.name)),
              Text(
                score.score.toString() +
                    '/' +
                    snapshot.data!.fullMark.toString(),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('yyyy/M/d', 'ar-EG').format(score.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // arabic grade name based on score percentage
              Text(
                switch (score.score / snapshot.data!.fullMark) {
                  >= 0.9 => 'ممتاز',
                  >= 0.8 => 'جيد جداً',
                  >= 0.7 => 'جيد',
                  >= 0.5 => 'مقبول',
                  _ => 'لم يجتاز',
                },
              ),
            ],
          ),
          trailing: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            value: score.score / snapshot.data!.fullMark,
          ),
        );
      },
    );
  }
}
