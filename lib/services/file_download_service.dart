import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadService {
  const FileDownloadService();

  Future<void> openOrDownloadFileWithProgress(
    BuildContext context,
    Reference reference,
  ) async {
    await Permission.storage.request();

    final downloadsPath = await getDownloadsDirectory();
    final filePath = p.join(
      downloadsPath!.path,
      'مدرسة الشمامسة',
      p.basename(reference.fullPath),
    );

    final file = File(filePath);
    if (!file.existsSync()) {
      await file.create(recursive: true);

      final downloadTask = reference.writeToFile(file);

      unawaited(
        showDialog(
          context: context,
          builder: (context) {
            return StreamBuilder<TaskSnapshot>(
              stream: downloadTask.snapshotEvents,
              builder: (context, snapshot) {
                if ({TaskState.success, TaskState.canceled, TaskState.error}
                    .contains(snapshot.data?.state)) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => Navigator.pop(context));
                }

                return AlertDialog(
                  title: const Text('جار التنزيل'),
                  content: LinearProgressIndicator(
                    value: (snapshot.data?.bytesTransferred ?? 0) /
                        (snapshot.data?.totalBytes ?? 1),
                  ),
                );
              },
            );
          },
        ).then((_) {
          if (downloadTask.snapshot.state == TaskState.running) {
            file.delete();
            downloadTask.cancel();
          }
        }),
      );

      await downloadTask.catchError((error) {
        file.delete();
        throw error;
      });
    }

    if (file.existsSync()) {
      unawaited(OpenFile.open(filePath));
    }
  }
}
