import 'dart:async';
import 'dart:io';

import 'package:churchdata_core/churchdata_core.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Reference;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadService {
  const FileDownloadService();

  Future<File> _getFileForResource(Reference reference) async {
    final downloadsPath = await getDownloadsDirectory();
    final filePath = p.join(
      downloadsPath!.path,
      'مدرسة الشمامسة',
      p.basename(reference.fullPath),
    );

    final file = File(filePath);
    return file;
  }

  Future<bool> resourceExistsOnDevice(Reference reference) async {
    final File file = await _getFileForResource(reference);

    return file.existsSync();
  }

  Future<void> openOrDownloadFileWithProgress(
    BuildContext context,
    Reference reference,
  ) async {
    await Permission.storage.request();

    final file = await _getFileForResource(reference);

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
      unawaited(OpenFile.open(file.path));
    }
  }
}

/// A method returns a human readable string representing a file _size
String filesize(dynamic size, [int round = 2]) {
  /** 
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number 
   * of digits after comma/point (default is 2)
   */
  const divider = 1024;
  int _size;
  try {
    _size = int.parse(size.toString());
  } catch (e) {
    throw ArgumentError('Can not parse the size parameter: $e');
  }

  if (_size < divider) {
    return '$_size B';
  }

  if (_size < divider * divider && _size % divider == 0) {
    return '${(_size / divider).toStringAsFixed(0)} KB';
  }

  if (_size < divider * divider) {
    return '${(_size / divider).toStringAsFixed(round)} KB';
  }

  if (_size < divider * divider * divider && _size % divider == 0) {
    return '${(_size / (divider * divider)).toStringAsFixed(0)} MB';
  }

  if (_size < divider * divider * divider) {
    return '${(_size / divider / divider).toStringAsFixed(round)} MB';
  }

  if (_size < divider * divider * divider * divider && _size % divider == 0) {
    return '${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB';
  }

  if (_size < divider * divider * divider * divider) {
    return '${(_size / divider / divider / divider).toStringAsFixed(round)} GB';
  }

  if (_size < divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    final num r = _size / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)} TB';
  }

  if (_size < divider * divider * divider * divider * divider) {
    final num r = _size / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)} TB';
  }

  if (_size < divider * divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    final num r = _size / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)} PB';
  } else {
    final num r = _size / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)} PB';
  }
}
