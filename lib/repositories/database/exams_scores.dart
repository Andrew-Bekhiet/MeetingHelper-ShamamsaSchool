import 'package:churchdata_core/churchdata_core.dart';
import 'package:meetinghelper/models/data.dart';
import 'package:meetinghelper/repositories/database/table_base.dart';

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
