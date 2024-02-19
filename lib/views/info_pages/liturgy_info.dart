import 'dart:async';

import 'package:churchdata_core/churchdata_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meetinghelper/models.dart';
import 'package:meetinghelper/services/file_download_service.dart';
import 'package:path/path.dart' as p;

class LiturgyInfo extends StatelessWidget {
  final Liturgy liturgy;

  const LiturgyInfo({required this.liturgy, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(liturgy.name)),
      body: StreamBuilder<Liturgy?>(
        stream: liturgy.ref.snapshots().map(Liturgy.fromDoc),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorWidget(snapshot.error!);
          if (!snapshot.hasData) {
            return const Center(child: Text('تم حذف الدرس'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(
                    liturgy.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('السنوات الدراسية'),
                  subtitle: FutureBuilder<List<StudyYear>>(
                    future: Future.wait(
                      liturgy.studyYears
                          .map((r) => r.get().then(StudyYear.fromDoc)),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorWidget(snapshot.error!);
                      }
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }

                      return Text(
                        snapshot.requireData
                            .sortedByCompare((s) => s.grade, (a, b) => a - b)
                            .map((s) => s.name)
                            .join('، '),
                      );
                    },
                  ),
                ),
                if (liturgy.resources.isEmpty)
                  const Center(child: Text('لا يوجد عناصر'))
                else
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemCount: liturgy.resources.length,
                      itemBuilder: (context, index) {
                        final resource = liturgy.resourcesReferences[index];

                        final bool isPDF =
                            p.extension(resource.fullPath) == '.pdf';

                        final filename = p.basename(resource.fullPath);

                        return InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (isPDF)
                                const Icon(
                                  Icons.picture_as_pdf,
                                  size: 40,
                                )
                              else
                                IgnorePointer(
                                  child: SizedBox(
                                    height: (MediaQuery.of(context).size.width /
                                            4) -
                                        26,
                                    child: PhotoObjectWidget(
                                      PhotoObjectBase.reference(resource),
                                      circleCrop: false,
                                    ),
                                  ),
                                ),
                              Text(
                                p.withoutExtension(filename),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () => GetIt.I<FileDownloadService>()
                              .openOrDownloadFileWithProgress(
                            context,
                            resource,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
