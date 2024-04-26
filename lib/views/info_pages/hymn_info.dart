import 'dart:async';

import 'package:churchdata_core/churchdata_core.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get_it/get_it.dart';
import 'package:meetinghelper/models.dart';
import 'package:meetinghelper/services/file_download_service.dart';
import 'package:meetinghelper/utils/helpers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HymnInfo extends StatelessWidget {
  final Hymn hymn;

  const HymnInfo({required this.hymn, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hymn.name)),
      body: StreamBuilder<Hymn?>(
        stream: hymn.ref.snapshots().map(Hymn.fromDoc),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorWidget(snapshot.error!);
          if (!snapshot.hasData) {
            return const Center(child: Text('تم حذف اللحن'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(
                    hymn.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('السنوات الدراسية'),
                  subtitle: FutureBuilder<List<StudyYear>>(
                    future: Future.wait(
                      hymn.studyYears
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
                ListTile(
                  title: const Text('مستوى الصعوبة'),
                  subtitle: Text(hymn.difficultyLevelDescription),
                ),
                ListTile(
                  title: const Text('معلومة طقسية'),
                  subtitle: Text(hymn.liturgicalInfo ?? ''),
                ),
                ListTile(
                  title: const Text('فيديو اللحن'),
                  subtitle: Linkify(
                    onOpen: (link) async {
                      if (await canLaunchUrlString(link.url)) {
                        await launchUrlString(link.url);
                      }
                    },
                    text: hymn.mediaLink ?? '',
                  ),
                ),
                if (hymn.textPDFResource != null)
                  StreamBuilder(
                    stream: Rx.combineLatest3(
                      GetIt.I<FileDownloadService>()
                          .resourceExistsOnDevice(hymn.textPDFReference!)
                          .asStream()
                          .startWith(false),
                      hymn.textPDFReference!
                          .getMetadata()
                          .asStream()
                          .map((m) => m.size)
                          .startWith(null),
                      Connectivity()
                          .onConnectivityChanged
                          .map((c) => c.isConnected)
                          .startWith(false),
                      (a, b, c) => (a, b, c),
                    ),
                    builder: (context, snapshot) {
                      final bool isDownloaded = snapshot.data?.$1 ?? false;
                      final int? sizeBytes = snapshot.data?.$2;
                      final bool isConnected = snapshot.data?.$3 ?? false;

                      return FilledButton.tonalIcon(
                        icon: const Icon(Icons.file_open),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDownloaded)
                              const Text('فتح PDF')
                            else
                              const Text('تنزيل PDF'),
                            if (sizeBytes != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(${filesize(sizeBytes)})',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        onPressed: isDownloaded || isConnected
                            ? _openPDF(context)
                            : null,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  VoidCallback _openPDF(BuildContext context) {
    return () => GetIt.I<FileDownloadService>().openOrDownloadFileWithProgress(
          context,
          hymn.textPDFReference!,
        );
  }
}
