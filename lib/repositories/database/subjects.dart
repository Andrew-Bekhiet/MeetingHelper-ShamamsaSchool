import 'package:churchdata_core/churchdata_core.dart';
import 'package:meetinghelper/models/data/subject.dart';
import 'package:meetinghelper/repositories/database/table_base.dart';

class Subjects extends TableBase<Subject> {
  Subjects(super.repository);

  @override
  Stream<List<Subject>> getAll({
    String orderBy = 'Name',
    bool descending = false,
    QueryCompleter queryCompleter = kDefaultQueryCompleter,
  }) {
    return queryCompleter(
      repository.collection('Subjects'),
      orderBy,
      descending,
    ).snapshots().map((c) => c.docs.map(Subject.fromDoc).toList());
  }

  @override
  Future<Subject?> getById(String id) async {
    final doc = await repository.collection('Subjects').doc(id).get();

    if (!doc.exists) return null;

    return Subject.fromDoc(doc);
  }
}
