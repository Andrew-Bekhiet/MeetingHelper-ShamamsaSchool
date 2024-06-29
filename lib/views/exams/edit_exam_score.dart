import 'package:churchdata_core/churchdata_core.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:meetinghelper/models.dart';
import 'package:meetinghelper/repositories.dart';
import 'package:meetinghelper/utils/helpers.dart';

class EditExamScore extends StatefulWidget {
  final Person person;
  final ExamScore? initialExamScore;

  const EditExamScore({required this.person, super.key, this.initialExamScore});

  @override
  State<EditExamScore> createState() => _EditExamScoreState();
}

// Term document:
//  From: Timestamp
//  To: Timestamp
//  Order: int
// Default Term document:
//  From: MM-DD String
//  To: MM-DD String
//  Order: int

class _EditExamScoreState extends State<EditExamScore> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ExamScore examScore;

  late final Stream<List<Subject>> subjectsStream;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    examScore = widget.initialExamScore ??
        ExamScore(
          ref: MHDatabaseRepo.I.collection('ExamScores').doc('null'),
          date: now,
          term: 0,
          subject: MHDatabaseRepo.I.collection('Subjects').doc('null'),
          score: 21,
          personId: widget.person.ref,
          classId: widget.person.classId,
        );

    subjectsStream = MHDatabaseRepo.I.subjects.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة نتيجة امتحان ل${widget.person.name}'),
        actions: [
          if (widget.initialExamScore != null &&
              widget.initialExamScore!.id != 'null')
            IconButton(
              icon: const Icon(Symbols.delete),
              onPressed: () async {
                final confirmation = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('هل تريد حذف هذه النتيجة؟'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('لا'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('نعم'),
                      ),
                    ],
                  ),
                );

                if (confirmation != true) return;

                final bool connected =
                    (await Connectivity().checkConnectivity()).isConnected;

                await _awaitIf(
                  MHDatabaseRepo.I.examsScores
                      .delete(widget.initialExamScore!.id),
                  connected,
                );

                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TappableFormField<DateTime?>(
                labelText: 'تاريخ الامتحان',
                initialValue: examScore.date,
                onTap: (state) async {
                  final now = DateTime.now();

                  state.didChange(
                    await showDatePicker(
                          context: context,
                          initialDate: state.value ?? now,
                          firstDate:
                              now.subtract(const Duration(days: 365 * 100)),
                          lastDate: now,
                        ) ??
                        state.value!,
                  );

                  setState(() {
                    examScore = examScore.copyWith(date: state.value);
                    MHDatabaseRepo.I.examsScores.getTermForDate(state.value!);
                  });
                },
                onSaved: (d) => examScore = examScore.copyWith(date: d),
                decoration: (context, state) => InputDecoration(
                  labelText: 'تاريخ الامتحان',
                  errorText: state.errorText,
                ),
                builder: (context, state) {
                  return state.value != null
                      ? Text(DateFormat('yyyy/M/d').format(state.value!))
                      : null;
                },
                validator: (_) => null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: StreamBuilder<List<Subject>>(
                  stream: subjectsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }

                    return FormField(
                      initialValue: examScore.subject,
                      builder: (state) => DropdownMenu<JsonRef>(
                        width: MediaQuery.of(context).size.width - 16,
                        initialSelection: state.value,
                        errorText: state.errorText,
                        inputDecorationTheme:
                            Theme.of(context).inputDecorationTheme,
                        dropdownMenuEntries: snapshot.data
                                ?.map(
                                  (s) => DropdownMenuEntry(
                                    value: s.ref,
                                    label: s.name,
                                  ),
                                )
                                .toList() ??
                            [],
                        onSelected: (value) {
                          state.didChange(value);
                          examScore = examScore.copyWith(subject: value);
                          setState(() {});
                        },
                        label: const Text('المادة'),
                      ),
                      onSaved: (s) =>
                          examScore = examScore.copyWith(subject: s),
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء إدخال المادة';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ),
              StreamBuilder<List<Subject>>(
                stream: subjectsStream,
                builder: (context, snapshot) {
                  final int? fullMark = (snapshot.data ?? [])
                      .where((s) => s.id == examScore.subject.id)
                      .singleOrNull
                      ?.fullMark;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      initialValue: examScore.score.toString(),
                      enabled: fullMark != null,
                      decoration: InputDecoration(
                        labelText: 'الدرجة',
                        suffixText: fullMark != null ? 'من $fullMark' : null,
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (s) => examScore =
                          examScore.copyWith(score: double.parse(s!)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الدرجة';
                        } else if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صالح';
                        } else if (fullMark != null &&
                            double.parse(value) > fullMark) {
                          return 'الدرجة يجب أن تكون أقل من أو تساوي $fullMark';
                        } else if (double.parse(value) < 0) {
                          return 'الدرجة يجب أن تكون أكبر من أو تساوي 0';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
              // TODO: Add person picker
              /* Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TappableFormField<Person>(
                  labelText: 'المخدوم',
                  initialValue: widget.person,
                  onTap: (state) async {
                    final person = await showPersonPicker(
                      context: context,
                      initialPerson: state.value,
                    );

                    state.didChange(person);
                    examScore = examScore.copyWith(personId: person.ref, classId: person.classId);
                    setState(() {});
                  },
                  onSaved: (p) => examScore = examScore.copyWith(personId: p?.ref, classId: p?.classId),
                  decoration: (context, state) => InputDecoration(
                    labelText: 'المخدوم',
                    errorText: state.errorText,
                  ),
                  builder: (context, state) {
                    return state.value != null
                        ? Text(state.value!.name)
                        : null;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء إدخال المخدوم';
                    }
                    return null;
                  },
                ),
              ), */
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'حفظ',
        onPressed: () async {
          if (_isSaving) return;

          _isSaving = true;
          await _saveScore().catchError((e) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  duration: const Duration(minutes: 2),
                ),
              );
          }).whenComplete(() => _isSaving = false);
        },
        child: const Icon(Symbols.save),
      ),
    );
  }

  Future<int?> _enterTermValue() async {
    final _termFormKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController();

    final int? termOrder = await showDialog<int>(
      context: context,
      builder: (context) => Form(
        key: _termFormKey,
        child: AlertDialog(
          title: const Text('لم يتم تحديد الترم\nبرجاء إدخال رقم الترم'),
          content: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'رقم الترم',
            ),
            onEditingComplete: () {
              if (_termFormKey.currentState!.validate()) {
                Navigator.of(context).pop(int.parse(controller.text));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال رقم الترم';
              } else if (int.tryParse(value) == null) {
                return 'الرجاء إدخال رقم صالح';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_termFormKey.currentState!.validate()) {
                  Navigator.of(context).pop(int.parse(controller.text));
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    return termOrder;
  }

  Future<void> _saveScore() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
        ..showSnackBar(
          const SnackBar(
            content: Text('جاري الحفظ...'),
            duration: Duration(minutes: 1),
          ),
        );

      final bool update = widget.initialExamScore != null &&
          widget.initialExamScore!.id != 'null';
      final bool connected =
          (await Connectivity().checkConnectivity()).isConnected;

      final int? termOrder =
          (await MHDatabaseRepo.I.examsScores.getTermForDate(examScore.date))
                  ?.order ??
              await _enterTermValue();

      if (termOrder == null) {
        messenger.hideCurrentSnackBar();

        return;
      }

      examScore = examScore.copyWith(
        term: termOrder,
        personId: widget.person.ref,
        classId: widget.person.classId,
      );

      if (update) {
        await _awaitIf(
          MHDatabaseRepo.I.examsScores
              .update(widget.initialExamScore!.id, examScore),
          connected,
        );
      } else {
        await _awaitIf(
          MHDatabaseRepo.I.examsScores.add(examScore),
          connected,
        );
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تم الحفظ بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );

      navigator.pop();
    }
  }

  Future<void> _awaitIf(Future<void> future, bool condition) async {
    if (condition) await future;

    return SynchronousFuture(null);
  }
}
