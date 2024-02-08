import 'package:churchdata_core/churchdata_core.dart';
import 'package:meetinghelper/models/data.dart';
import 'package:meetinghelper/repositories/database/table_base.dart';

class CurriculaStages extends TableBase<CurriculumStage> {
  const CurriculaStages(super.repository);

  @override
  Future<CurriculumStage?> getById(String id) async {
    final doc = await repository.collection('CurriculaStages').doc(id).get();

    if (!doc.exists) return null;

    return CurriculumStage.fromDoc(doc);
  }

  @override
  Stream<List<CurriculumStage>> getAll({
    String orderBy = 'Name',
    bool descending = true,
    QueryCompleter queryCompleter = kDefaultQueryCompleter,
  }) {
    return queryCompleter(
      repository.collection('CurriculaStages'),
      orderBy,
      descending,
    ).snapshots().map((c) => c.docs.map(CurriculumStage.fromQueryDoc).toList());
  }
}
