import 'package:churchdata_core/churchdata_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meetinghelper/models.dart';
import 'package:meetinghelper/repositories/database_repository.dart';

class CurriculumStageInfo extends StatelessWidget {
  static const List<(String, String)> categories = [
    ('الألحان', 'Hymns'),
    ('الطقس', 'Liturgy'),
    ('القبطي', 'CopticLanguage'),
  ];

  final CurriculumStage curriculum;

  const CurriculumStageInfo({required this.curriculum, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('منهج ' + curriculum.name)),
      body: Column(
        children: [
          ListTile(
            title: const Text('السنوات الدراسية'),
            subtitle: FutureBuilder<List<StudyYear>>(
              future: Future.wait(
                curriculum.studyYears
                    .map((r) => r.get().then(StudyYear.fromDoc)),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) return ErrorWidget(snapshot.error!);
                if (!snapshot.hasData) return const LinearProgressIndicator();

                return Text(
                  snapshot.requireData
                      .sortedByCompare((s) => s.grade, (a, b) => a - b)
                      .map((s) => s.name)
                      .join('، '),
                );
              },
            ),
          ),
          for (final category in categories)
            Builder(
              builder: (context) {
                final query =
                    GetIt.I<MHDatabaseRepo>().collection(category.$2).where(
                          'StudyYears',
                          arrayContainsAny: curriculum.studyYears,
                        );

                return Card(
                  child: ListTile(
                    onTap: _onCategoryTap(context, category, query),
                    title: Text(category.$1),
                    subtitle: FutureBuilder<AggregateQuerySnapshot>(
                      future: query.count().get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        }
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }

                        return Text(
                          snapshot.requireData.count.toString() + ' درس',
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void Function() _onCategoryTap(
    BuildContext context,
    (String, String) category,
    QueryOfJson query,
  ) {
    return () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CurriculumLessons(
              title: category.$1,
              controller: ListControllerBase(
                objectsPaginatableStream: PaginatableStream.query(
                  query: query.orderBy('Name'),
                  mapper: switch (category.$2) {
                    'Hymns' => Hymn.fromQueryDoc,
                    'Liturgy' => Liturgy.fromQueryDoc,
                    'CopticLanguage' => CopticLanguage.fromQueryDoc,
                    _ => throw UnimplementedError()
                  },
                ),
              ),
            ),
          ),
        );
  }
}

class CurriculumLessons extends StatelessWidget {
  final String title;
  final ListControllerBase controller;

  const CurriculumLessons({
    required this.title,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DataObjectListViewBase(
        autoDisposeController: true,
        controller: controller,
      ),
    );
  }
}
