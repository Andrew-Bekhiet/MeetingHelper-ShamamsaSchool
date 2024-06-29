import 'package:churchdata_core/churchdata_core.dart';
import 'package:flutter/material.dart';
import 'package:meetinghelper/models/data.dart';
import 'package:meetinghelper/models/meta/term.dart';
import 'package:meetinghelper/repositories/database/exams_scores.dart';
import 'package:meetinghelper/repositories/database_repository.dart';
import 'package:rxdart/rxdart.dart' hide Subject;

class ClassExamsScores extends StatefulWidget {
  final Class class$;

  const ClassExamsScores({required this.class$, super.key});

  @override
  State<ClassExamsScores> createState() => _ClassExamsScoresState();
}

class _ClassExamsScoresState extends State<ClassExamsScores> {
  late final ListController<StudyYear?, Person> _personsListController;
  late Stream<Map<String, ExamScore>> structuredScoresStream;

  final BehaviorSubject<Year> _selectedYear =
      BehaviorSubject<Year>.seeded(DateTime.now().year);
  final BehaviorSubject<TermOrder> _selectedTerm =
      BehaviorSubject<TermOrder>.seeded(1);
  final BehaviorSubject<Subject?> _selectedSubject =
      BehaviorSubject<Subject?>();

  @override
  void initState() {
    super.initState();

    _personsListController = ListController<StudyYear?, Person>(
      groupByStream: MHDatabaseRepo.I.persons.groupPersonsByStudyYearRef,
      groupingStream: Stream.value(true),
      objectsPaginatableStream: PaginatableStream.loadAll(
        stream: widget.class$.getMembers(),
      ),
    );

    structuredScoresStream = Rx.combineLatest3(
      _selectedYear,
      _selectedTerm,
      _selectedSubject,
      (a, b, c) {
        print('a: $a, b: $b, c: $c');
        return (a, b, c);
      },
    )
        .switchMap(
          (arg) {
            final (int year, int term, Subject? subject) = arg;

            return MHDatabaseRepo.I.examsScores.getAll(
              queryCompleter: (q, orderBy, descending) {
                QueryOfJson baseQuery = q
                    .where('Year', isEqualTo: year)
                    .where('Term', isEqualTo: term);

                if (subject != null) {
                  baseQuery =
                      baseQuery.where('Subject', isEqualTo: subject.ref);
                }
                return baseQuery
                    .where('ClassId', isEqualTo: widget.class$.ref)
                    .orderBy(orderBy, descending: descending);
              },
            );
          },
        )
        .map((scores) => {for (final score in scores) score.personId.id: score})
        .shareValue();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final width = MediaQuery.sizeOf(context).width;
    final nowYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: Text('امتحانات فصل ${widget.class$.name}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownMenu<Year>(
                  label: const Text('السنة'),
                  inputDecorationTheme: inputDecorationTheme,
                  width: width / 2 - 12,
                  initialSelection: _selectedYear.value,
                  dropdownMenuEntries:
                      List.generate(15, (i) => nowYear - i, growable: false)
                          .map(
                    (year) {
                      return DropdownMenuEntry<Year>(
                        value: year,
                        label: year.toString(),
                      );
                    },
                  ).toList(),
                  onSelected: (v) => _selectedYear.add(v!),
                ),
                StreamBuilder<List<TermOrder>>(
                  stream: MHDatabaseRepo.I
                      .collection('DefaultTerms')
                      .snapshots()
                      .map(
                        (c) => c.docs
                            .map(Term.fromDefaultTermData)
                            .map((t) => t.order)
                            .toSet()
                            .toList(),
                      ),
                  builder: (context, snapshot) {
                    return DropdownMenu<int>(
                      label: const Text('الترم'),
                      inputDecorationTheme: inputDecorationTheme,
                      width: width / 2 - 12,
                      initialSelection: _selectedTerm.value,
                      dropdownMenuEntries:
                          (snapshot.data ?? [_selectedTerm.valueOrNull ?? 1])
                              .map(
                        (term) {
                          return DropdownMenuEntry<int>(
                            value: term,
                            label: term.toString(),
                          );
                        },
                      ).toList(),
                      onSelected: (v) => _selectedTerm.add(v!),
                    );
                  },
                ),
              ],
            ),
          ),
          StreamBuilder<List<Subject>>(
            stream: MHDatabaseRepo.I.subjects.getAll(),
            builder: (context, snapshot) {
              return DropdownMenu<Subject>(
                label: const Text('المادة'),
                inputDecorationTheme: inputDecorationTheme,
                width: width - 16,
                initialSelection: _selectedSubject.valueOrNull,
                dropdownMenuEntries: snapshot.data?.map(
                      (subject) {
                        return DropdownMenuEntry<Subject>(
                          value: subject,
                          label: subject.name,
                        );
                      },
                    ).toList() ??
                    [],
                onSelected: _selectedSubject.add,
              );
            },
          ),
          Expanded(
            child: DataObjectListView<StudyYear?, Person>(
              groupBuilder: _studyYearGroupBuilder,
              controller: _personsListController,
              itemBuilder: (
                person, {
                void Function(Person)? onLongPress,
                void Function(Person)? onTap,
                subtitle,
                trailing,
              }) =>
                  StreamBuilder<Subject?>(
                stream: _selectedSubject,
                builder: (context, snapshot) {
                  return _personItemBuilder(person, snapshot.data);
                },
              ),
              autoDisposeController: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personItemBuilder(Person person, Subject? subject) {
    return StreamBuilder<ExamScore?>(
      stream: structuredScoresStream.map((scores) => scores[person.id]),
      builder: (context, scoreSnapshot) {
        return ViewableObjectWidget<Person>(
          person,
          trailing: scoreSnapshot.data != null && subject != null
              ? CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  value: scoreSnapshot.requireData!.score / subject.fullMark,
                )
              : null,
          subtitle: scoreSnapshot.data != null && subject != null
              ? Text(
                  scoreSnapshot.requireData!.score.toString() +
                      '/' +
                      subject.fullMark.toString(),
                )
              : null,
          onTap: () {
            if (scoreSnapshot.data == null && subject != null) {
              Navigator.of(context).pushNamed(
                'EditExamsScore',
                arguments: {
                  Person: person,
                  ExamScore: ExamScore(
                    ref: MHDatabaseRepo.I.collection('ExamScores').doc('null'),
                    score: 21,
                    date: DateTime.now().copyWith(year: _selectedYear.value),
                    personId: person.ref,
                    term: _selectedTerm.value,
                    classId: widget.class$.ref,
                    subject: subject.ref,
                  ),
                },
              );
            } else {
              Navigator.of(context).pushNamed(
                'ExamsScores',
                arguments: person,
              );
            }
          },
          onLongPress: () => Navigator.of(context).pushNamed(
            'PersonInfo',
            arguments: person,
          ),
        );
      },
    );
  }

  Widget _studyYearGroupBuilder(
    StudyYear? object, {
    void Function(StudyYear)? onLongPress,
    void Function(StudyYear)? onTap,
    void Function()? onTapOnNull,
    bool? showSubtitle = true,
    Widget? trailing,
    Widget? subtitle,
  }) {
    subtitle ??= Text(
      'يتم عرض ' +
          (_personsListController
                      .currentGroupedObjectsOrNull?[object]?.length ??
                  0)
              .toString() +
          ' مخدوم داخل الفصل',
    );

    if (object == null) {
      return ListTile(
        title: const Text('غير محددة'),
        subtitle: showSubtitle ?? false ? subtitle : null,
        onTap:
            onTap != null && object != null ? () => onTap(object) : onTapOnNull,
        onLongPress: onLongPress != null && object != null
            ? () => onLongPress(object)
            : null,
        trailing: trailing,
      );
    }

    return ViewableObjectWidget<StudyYear>(
      object,
      wrapInCard: false,
      showSubtitle: showSubtitle ?? false,
      subtitle: showSubtitle ?? false ? subtitle : null,
      onTap: onTap != null ? () => onTap(object) : null,
      onLongPress: onLongPress != null ? () => onLongPress(object) : null,
      trailing: trailing,
    );
  }

  @override
  void dispose() {
    _selectedYear.close();
    _selectedTerm.close();
    _selectedSubject.close();

    super.dispose();
  }
}
