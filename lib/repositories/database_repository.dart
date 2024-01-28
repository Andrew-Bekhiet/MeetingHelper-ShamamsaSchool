import 'package:churchdata_core/churchdata_core.dart';
import 'package:get_it/get_it.dart';
import 'package:meetinghelper/models.dart';

import 'database/classes.dart';
import 'database/exams.dart';
import 'database/persons.dart';
import 'database/services.dart';
import 'database/users.dart';

class MHDatabaseRepo extends DatabaseRepository {
  static MHDatabaseRepo get instance => GetIt.I<MHDatabaseRepo>();
  static MHDatabaseRepo get I => instance;

  late final users = Users(this);
  late final persons = Persons(this);
  late final classes = Classes(this);
  late final services = Services(this);
  late final exams = Exams(this);

  @override
  Future<Viewable?> getObjectFromLink(Uri deepLink) async {
    if (deepLink.pathSegments[0] == 'PersonInfo') {
      if (deepLink.queryParameters['Id'] == '') {
        throw Exception('Id has an empty value which is not allowed');
      }

      return persons.getById(
        deepLink.queryParameters['Id']!,
      );
    } else if (deepLink.pathSegments[0] == 'UserInfo') {
      if (deepLink.queryParameters['UID'] == '') {
        throw Exception('UID has an empty value which is not allowed');
      }

      return users.getUserData(
        deepLink.queryParameters['UID']!,
      );
    } else if (deepLink.pathSegments[0] == 'ClassInfo') {
      if (deepLink.queryParameters['Id'] == '') {
        throw Exception('Id has an empty value which is not allowed');
      }

      return classes.getById(
        deepLink.queryParameters['Id']!,
      );
    } else if (deepLink.pathSegments[0] == 'ServiceInfo') {
      if (deepLink.queryParameters['Id'] == '') {
        throw Exception('Id has an empty value which is not allowed');
      }

      return services.getById(
        deepLink.queryParameters['Id']!,
      );
    } else if (deepLink.pathSegments[0] == 'Day') {
      if (deepLink.queryParameters['Id'] == '') {
        throw Exception('Id has an empty value which is not allowed');
      }

      return getDay(
        deepLink.queryParameters['Id']!,
      );
    } else if (deepLink.pathSegments[0] == 'ServantsDay') {
      if (deepLink.queryParameters['Id'] == '') {
        throw Exception('Id has an empty value which is not allowed');
      }

      return getServantsDay(
        deepLink.queryParameters['Id']!,
      );
    } else if (deepLink.pathSegments[0] == 'viewQuery') {
      return QueryInfo.fromJson(deepLink.queryParameters);
    }

    return null;
  }

  @override
  Future<Person?> getPerson(String id) => persons.getById(id);

  Future<HistoryDay?> getDay(String id) async {
    final doc = await collection('History').doc(id).get();

    if (!doc.exists) return null;

    return HistoryDay.fromDoc(
      doc,
    );
  }

  Future<ServantsHistoryDay?> getServantsDay(String id) async {
    final doc = await collection('ServantsHistory').doc(id).get();

    if (!doc.exists) return null;

    return ServantsHistoryDay.fromDoc(
      doc,
    );
  }
}
