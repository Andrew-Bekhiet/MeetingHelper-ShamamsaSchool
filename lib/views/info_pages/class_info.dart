import 'dart:async';

import 'package:churchdata_core/churchdata_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:meetinghelper/models.dart';
import 'package:meetinghelper/repositories.dart';
import 'package:meetinghelper/services.dart';
import 'package:meetinghelper/utils/globals.dart';
import 'package:meetinghelper/utils/helpers.dart';
import 'package:meetinghelper/views.dart';
import 'package:meetinghelper/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ClassInfo extends StatefulWidget {
  final Class class$;

  const ClassInfo({
    required this.class$,
    super.key,
  });

  @override
  _ClassInfoState createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfo> {
  final BehaviorSubject<OrderOptions> _orderOptions =
      BehaviorSubject<OrderOptions>.seeded(const OrderOptions());

  late final ListController<StudyYear?, Person> _listController;

  final _edit = GlobalKey();
  final _share = GlobalKey();
  final _moreOptions = GlobalKey();
  final _editHistory = GlobalKey();
  final _analytics = GlobalKey();
  final _add = GlobalKey();

  @override
  Future<void> dispose() async {
    super.dispose();
    await _orderOptions.close();
  }

  @override
  void initState() {
    super.initState();
    _listController = ListController<StudyYear?, Person>(
      groupByStream: MHDatabaseRepo.I.persons.groupPersonsByStudyYearRef,
      groupingStream: Stream.value(true),
      objectsPaginatableStream: PaginatableStream.loadAll(
        stream: _orderOptions.switchMap(
          (order) => widget.class$
              .getMembers(orderBy: order.orderBy, descending: !order.asc),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (([
        if (User.instance.permissions.write) 'Edit',
        'Share',
        'MoreOptions',
        'EditHistory',
        'Class.Analytics',
        if (User.instance.permissions.write) 'Add',
      ]..removeWhere(HivePersistenceProvider.instance.hasCompletedStep))
          .isNotEmpty) {
        TutorialCoachMark(
          focusAnimationDuration: const Duration(milliseconds: 200),
          targets: [
            if (User.instance.permissions.write)
              TargetFocus(
                enableOverlayTab: true,
                contents: [
                  TargetContent(
                    child: Text(
                      'تعديل بيانات الفصل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                  ),
                ],
                identify: 'Edit',
                keyTarget: _edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
            TargetFocus(
              enableOverlayTab: true,
              contents: [
                TargetContent(
                  child: Text(
                    'يمكنك مشاركة البيانات بلينك يفتح البيانات مباشرة داخل البرنامج',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                ),
              ],
              identify: 'Share',
              keyTarget: _share,
              color: Theme.of(context).colorScheme.secondary,
            ),
            TargetFocus(
              enableOverlayTab: true,
              contents: [
                TargetContent(
                  child: Text(
                    'يمكنك ايجاد المزيد من الخيارات من هنا مثل: اشعار المستخدمين عن الفصل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                ),
              ],
              identify: 'MoreOptions',
              keyTarget: _moreOptions,
              color: Theme.of(context).colorScheme.secondary,
            ),
            TargetFocus(
              shape: ShapeLightFocus.RRect,
              enableOverlayTab: true,
              contents: [
                TargetContent(
                  align: ContentAlign.top,
                  child: Text(
                    'الاطلاع على سجل التعديلات في بيانات الفصل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                ),
              ],
              identify: 'EditHistory',
              keyTarget: _editHistory,
              color: Theme.of(context).colorScheme.secondary,
            ),
            TargetFocus(
              shape: ShapeLightFocus.RRect,
              enableOverlayTab: true,
              contents: [
                TargetContent(
                  align: ContentAlign.top,
                  child: Text(
                    'الأن يمكنك عرض تحليل لبيانات حضور مخدومين الفصل خلال فترة معينة من هنا',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                ),
              ],
              identify: 'Class.Analytics',
              keyTarget: _analytics,
              color: Theme.of(context).colorScheme.secondary,
            ),
            if (User.instance.permissions.write)
              TargetFocus(
                enableOverlayTab: true,
                contents: [
                  TargetContent(
                    align: ContentAlign.top,
                    child: Text(
                      'يمكنك اضافة مخدوم داخل الفصل بسرعة وسهولة من هنا',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                  ),
                ],
                alignSkip: Alignment.topRight,
                identify: 'Add',
                keyTarget: _add,
                color: Theme.of(context).colorScheme.secondary,
              ),
          ],
          alignSkip: Alignment.bottomLeft,
          textSkip: 'تخطي',
          onClickOverlay: (t) async {
            await HivePersistenceProvider.instance.completeStep(t.identify);
          },
          onClickTarget: (t) async {
            await HivePersistenceProvider.instance.completeStep(t.identify);
          },
        ).show(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Class?>(
      initialData: widget.class$,
      stream: User.loggedInStream
          .distinct((o, n) => o.permissions.write == n.permissions.write)
          .switchMap(
            (value) => widget.class$.ref.snapshots().map(Class.fromDoc),
          ),
      builder: (context, data) {
        final Class? class$ = data.data;

        if (class$ == null) {
          return const Scaffold(
            body: Center(
              child: Text('تم حذف الفصل'),
            ),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => <Widget>[
              SliverAppBar(
                backgroundColor: class$.color != Colors.transparent
                    ? (Theme.of(context).brightness == Brightness.light
                        ? class$.color?.lighten()
                        : class$.color?.darken())
                    : null,
                actions: class$.ref.path.startsWith('Deleted')
                    ? <Widget>[
                        if (User.instance.permissions.write)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'استعادة',
                            onPressed: () {
                              MHDatabaseRepo.I
                                  .recoverDocument(context, class$.ref);
                            },
                          ),
                      ]
                    : <Widget>[
                        if (User.instance.permissions.write)
                          IconButton(
                            key: _edit,
                            icon: Builder(
                              builder: (context) => Stack(
                                children: <Widget>[
                                  const Positioned(
                                    left: 1.0,
                                    top: 2.0,
                                    child:
                                        Icon(Icons.edit, color: Colors.black54),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: IconTheme.of(context).color,
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () async {
                              final dynamic result =
                                  await navigator.currentState!.pushNamed(
                                'Data/EditClass',
                                arguments: class$,
                              );
                              if (result is JsonRef) {
                                scaffoldMessenger.currentState!.showSnackBar(
                                  const SnackBar(
                                    content: Text('تم الحفظ بنجاح'),
                                  ),
                                );
                              } else if (result == 'deleted') {
                                scaffoldMessenger.currentState!
                                    .hideCurrentSnackBar();
                                scaffoldMessenger.currentState!.showSnackBar(
                                  const SnackBar(
                                    content: Text('تم الحذف بنجاح'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                navigator.currentState!.pop();
                              }
                            },
                            tooltip: 'تعديل',
                          ),
                        IconButton(
                          key: _share,
                          icon: Builder(
                            builder: (context) => Stack(
                              children: <Widget>[
                                const Positioned(
                                  left: 1.0,
                                  top: 2.0,
                                  child:
                                      Icon(Icons.share, color: Colors.black54),
                                ),
                                Icon(
                                  Icons.share,
                                  color: IconTheme.of(context).color,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () async {
                            await MHShareService.I.shareText(
                              (await MHShareService.I.shareClass(class$))
                                  .toString(),
                            );
                          },
                          tooltip: 'مشاركة برابط',
                        ),
                        PopupMenuButton(
                          key: _moreOptions,
                          onSelected: (option) {
                            switch (option) {
                              case 'dump-images':
                                _dumpImages();

                              case 'send-notification':
                                MHNotificationsService.I
                                    .sendNotification(context, class$);
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              if (User.instance.permissions.dumpImages)
                                const PopupMenuItem(
                                  value: 'dump-images',
                                  child: Text('تنزيل ملف صور المخدومين'),
                                ),
                              const PopupMenuItem(
                                value: 'send-notification',
                                child: Text(
                                  'ارسال إشعار للمستخدمين عن الفصل',
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                expandedHeight: 280,
                stretch: true,
                pinned: true,
                flexibleSpace: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity:
                            constraints.biggest.height > kToolbarHeight * 1.7
                                ? 0
                                : 1,
                        child: Text(
                          class$.name,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      background: Theme(
                        data: Theme.of(context).copyWith(
                          progressIndicatorTheme: ProgressIndicatorThemeData(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        child: PhotoObjectWidget(class$, circleCrop: false),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        title: Text(
                          class$.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: const Text('السنوات الدراسية'),
                        subtitle: FutureBuilder<(String, String)>(
                          future: Future.wait([
                            class$.getStudyYearFromName(),
                            class$.getStudyYearToName(),
                          ]).then((v) => (v[0], v[1])),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }

                            return Text(
                              'من ${snapshot.data?.$1 ?? ''} '
                              'إلى ${snapshot.data?.$2 ?? ''}',
                            );
                          },
                        ),
                      ),
                      if (!class$.ref.path.startsWith('Deleted')) ...[
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.map),
                          onPressed: () => showMap(context, class$),
                          label: const Text('إظهار المخدومين على الخريطة'),
                        ),
                        const Divider(thickness: 1),
                        FilledButton.tonalIcon(
                          icon: const Icon(Symbols.overview),
                          label: const Text('نتائج الامتحانات'),
                          onPressed: () => _showExamsScores(context, class$),
                        ),
                        const Divider(thickness: 1),
                        if (User.instance.permissions.manageUsers ||
                            User.instance.permissions.manageAllowedUsers)
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.analytics_outlined),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              'ActivityAnalysis',
                              arguments: [class$],
                            ),
                            label: const Text('تحليل نشاط الخدام'),
                          ),
                        FilledButton.tonalIcon(
                          key: _analytics,
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('احصائيات الحضور'),
                          onPressed: () => _showAnalytics(context, class$),
                        ),
                      ],
                      const Divider(thickness: 1),
                      EditHistoryProperty(
                        'أخر تحديث للبيانات:',
                        class$.lastEdit,
                        class$.ref.collection('EditHistory'),
                        key: _editHistory,
                      ),
                      _ClassServants(class$: class$),
                      Text(
                        'المخدومين بالفصل:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SearchFilters(
                        Person,
                        options: _listController,
                        orderOptions: _orderOptions,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  return DataObjectListView<StudyYear?, Person>(
                    scrollController: PrimaryScrollController.maybeOf(context),
                    groupBuilder: _studyYearGroupBuilder,
                    controller: _listController,
                    autoDisposeController: true,
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircularNotchedRectangle(),
            child: StreamBuilder<List>(
              stream: _listController.objectsStream,
              builder: (context, snapshot) {
                return Text(
                  (snapshot.data?.length ?? 0).toString() + ' مخدوم',
                  textAlign: TextAlign.center,
                  strutStyle:
                      StrutStyle(height: IconTheme.of(context).size! / 7.5),
                  style: Theme.of(context).primaryTextTheme.bodyLarge,
                );
              },
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: User.instance.permissions.write &&
                  !class$.ref.path.startsWith('Deleted')
              ? FloatingActionButton(
                  key: _add,
                  onPressed: () => navigator.currentState!.pushNamed(
                    'Data/EditPerson',
                    arguments: widget.class$.ref,
                  ),
                  child: const Icon(Icons.person_add),
                )
              : null,
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
          (_listController.currentGroupedObjectsOrNull?[object]?.length ?? 0)
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

  Future<void> _dumpImages() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context)
      ..showSnackBar(
        const SnackBar(
          content: Text('جار التحميل...'),
          duration: Duration(minutes: 9),
        ),
      );

    try {
      final url = await MHFunctionsService.I.dumpImages(class$: widget.class$);

      scaffoldMessenger.hideCurrentSnackBar();

      await GetIt.I<LauncherService>().launchUrl(Uri.parse(url));
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      unawaited(showErrorDialog(context, e.toString(), title: 'حدث خطأ'));
    }
  }

  void showMap(BuildContext context, Class class$) {
    navigator.currentState!.push(
      MaterialPageRoute(
        builder: (context) => MHMapView(initialClass: class$),
      ),
    );
  }

  void _showAnalytics(BuildContext context, Class _class) {
    navigator.currentState!.pushNamed('Analytics', arguments: _class);
  }

  void _showExamsScores(BuildContext context, Class class$) {
    navigator.currentState!.pushNamed('ExamsScores', arguments: class$);
  }
}

class _ClassServants extends StatelessWidget {
  const _ClassServants({
    required this.class$,
  });

  final Class class$;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'خدام الفصل',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: class$.allowedUsers.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              shrinkWrap: true,
              itemCount: class$.allowedUsers.length > 7
                  ? 7
                  : class$.allowedUsers.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                if (class$.allowedUsers.length > 7 && i == 6) {
                  return SizedBox.expand(
                    child: ClipOval(
                      child: ColoredBox(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black26
                            : Colors.black54,
                        child: Center(
                          child: Text(
                            '+' + (class$.allowedUsers.length - 6).toString(),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return IgnorePointer(
                  child: User.photoFromUID(
                    class$.allowedUsers[i],
                    removeHero: true,
                  ),
                );
              },
            )
          : const Text('لا يوجد خدام محددين في هذا الفصل'),
      onTap: class$.allowedUsers.isNotEmpty
          ? () async {
              await showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<List<User>>(
                        future: Future.wait(
                          class$.allowedUsers
                              .map(MHDatabaseRepo.instance.users.getUserName),
                        ).then(
                          (u) => u.whereType<User>().toList(),
                        ),
                        builder: (context, data) {
                          if (data.hasError) return ErrorWidget(data.error!);
                          if (!data.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsetsDirectional.all(8),
                            shrinkWrap: true,
                            itemCount: class$.allowedUsers.length,
                            itemBuilder: (context, i) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: IgnorePointer(
                                  child: ViewableObjectWidget(
                                    data.requireData[i],
                                    showSubtitle: false,
                                    wrapInCard: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          : null,
    );
  }
}
