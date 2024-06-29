import 'package:churchdata_core/churchdata_core.dart';
import 'package:collection/collection.dart';
import 'package:meetinghelper/models/data.dart';
import 'package:meetinghelper/models/meta.dart';
import 'package:meetinghelper/repositories/database/table_base.dart';

typedef Year = int;
typedef TermOrder = int;

class ExamsScores extends TableBase<ExamScore> {
  ExamsScores(super.repository);

  @override
  Stream<List<ExamScore>> getAll({
    String orderBy = 'Year',
    bool descending = true,
    QueryCompleter queryCompleter = kDefaultQueryCompleter,
  }) {
    return queryCompleter(
      repository.collection('ExamsScores'),
      orderBy,
      descending,
    ).snapshots().map((c) => c.docs.map(ExamScore.fromDoc).toList());
  }

  Stream<Map<Year, Map<TermOrder, List<ExamScore>>>> getStructuredScores({
    String orderBy = 'Year',
    bool descending = true,
    QueryCompleter queryCompleter = kDefaultQueryCompleter,
  }) {
    return getAll(
      queryCompleter: queryCompleter,
      descending: descending,
      orderBy: orderBy,
    ).map(
      (scores) => _sortStructuredScores(_organizeScores(scores)),
    );
  }

  Map<Year, Map<TermOrder, List<ExamScore>>> _organizeScores(
    List<ExamScore> scores,
  ) {
    return scores.groupFoldBy<Year, Map<TermOrder, List<ExamScore>>>(
      (score) => score.date.year,
      (yearScores, score) => {
        ...yearScores ?? {},
        score.term: [
          ...yearScores?[score.term] ?? [],
          score,
        ],
      },
    );
  }

  Map<Year, Map<TermOrder, List<ExamScore>>> _sortStructuredScores(
    Map<Year, Map<TermOrder, List<ExamScore>>> structuredScores,
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

  Future<Term?> getTermForDate(DateTime examDate) async {
    final Timestamp examTimestamp = examDate.toTimestamp();

    final snapshot = await repository
        .collection('Terms')
        .where('From', isLessThanOrEqualTo: examTimestamp)
        .where('To', isGreaterThanOrEqualTo: examTimestamp)
        .get();

    if (snapshot.docs.isEmpty) {
      final String examMonthDay = examDate.month.toString().padLeft(2, '0') +
          '-' +
          examDate.day.toString().padLeft(2, '0');

      final defaultTermsSnapshot = await repository
          .collection('DefaultTerms')
          .where('From', isLessThanOrEqualTo: examMonthDay)
          .where('To', isGreaterThanOrEqualTo: examMonthDay)
          .get();

      return defaultTermsSnapshot.docs
          .map(Term.fromDefaultTermData)
          .toList()
          .singleOrNull;
    } else {
      return snapshot.docs.map(Term.fromJson).toList().singleOrNull;
    }
  }

  @override
  Future<ExamScore?> getById(String id) async {
    final doc = await repository.collection('ExamsScores').doc(id).get();

    if (!doc.exists) return null;

    return ExamScore.fromDoc(doc);
  }

  Future<void> add(ExamScore score) async {
    await repository.collection('ExamsScores').add(score.toJson());
  }

  Future<void> update(String id, ExamScore score) async {
    await repository.collection('ExamsScores').doc(id).update(score.toJson());
  }

  Future<void> delete(String id) async {
    await repository.collection('ExamsScores').doc(id).delete();
  }
}
