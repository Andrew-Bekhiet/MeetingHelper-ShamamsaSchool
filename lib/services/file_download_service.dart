import 'dart:async';
import 'dart:io';

import 'package:churchdata_core/churchdata_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:meetinghelper/utils/helpers.dart';
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

    return File(filePath);
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
      final url = await reference.getCachedDownloadUrl(
        onCacheChanged: (_, __) => reference.deleteCache(),
      );

      final cacheManager = GetIt.I.isRegistered<BaseCacheManager>()
          ? GetIt.I<BaseCacheManager>()
          : DefaultCacheManager();

      final downloadStream = cacheManager
          .getFileStream(url, withProgress: true)
          .asBroadcastStream();

      final AsyncSnapshot<FileResponse>? lastSnapshot = await showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder<FileResponse>(
            stream: downloadStream,
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data is FileInfo) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) async => Navigator.of(context).pop(snapshot),
                );

                return const AlertDialog(
                  title: Text('جار التنزيل'),
                  content: LinearProgressIndicator(value: 1),
                );
              }

              final progress = snapshot.data as DownloadProgress?;

              return AlertDialog(
                title: const Text('جار التنزيل'),
                content: LinearProgressIndicator(
                  value: progress?.progress,
                ),
              );
            },
          );
        },
      );

      final lastSnapshotData = lastSnapshot?.data;

      if (lastSnapshotData is FileInfo) {
        await file.create(recursive: true);
        await lastSnapshotData.file.copy(file.path);
      } else {
        await reference.deleteCache();

        if (lastSnapshot?.hasError ?? false) {
          unawaited(
            showErrorDialog(
              context,
              'حدث خطأ أثناء تنزيل الملف',
            ),
          );
        }
      }
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
