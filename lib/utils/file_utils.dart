import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static String waPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';
  static bool decompressing = false;

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  /// Get mime information of a file
  static String getMime(String path) {
    File file = File(path);
    String mimeType = mime(file.path) ?? '';
    return mimeType;
  }

  /// Return all available Storage path
  static Future<List<Directory>> getStorageList() async {
    List<Directory> paths = (await getExternalStorageDirectories())!;
    List<Directory> filteredPaths = <Directory>[];
    for (Directory dir in paths) {
      filteredPaths.add(removeDataDirectory(dir.path));
    }
    return filteredPaths;
  }

  static Directory removeDataDirectory(String path) {
    return Directory(path.split('Android')[0]);
  }

  /// Get all Files and Directories in a Directory
  static Future<List<FileSystemEntity>> getFilesInPath(String path) async {
    Directory dir = Directory(path);
    return dir.listSync();
  }

  static Future<List<FileSystemEntity>> getAllFilesInPath(String path,
      {bool showHidden = false}) async {
    List<FileSystemEntity> files = <FileSystemEntity>[];
    Directory d = Directory(path);
    List<FileSystemEntity> l = d.listSync();
    for (FileSystemEntity file in l) {
      if (FileSystemEntity.isFileSync(file.path)) {
        files.add(file);
      } else {
        if (!file.path.contains('/storage/emulated/0/Android')) {
//          print(file.path);

          files.addAll(
              await getAllFilesInPath(file.path, showHidden: showHidden));
        }
      }
    }
//    print(files);
    return files;
  }

  /// Get all Files on the Device
  static Future<List<FileSystemEntity>> getAllFiles(
      {bool showHidden = false}) async {
    List<Directory> storages = await getStorageList();
    List<FileSystemEntity> files = <FileSystemEntity>[];
    for (Directory dir in storages) {
      List<FileSystemEntity> allFilesInPath = [];
      // This is important to catch storage errors
      try {
        allFilesInPath =
            await getAllFilesInPath(dir.path, showHidden: showHidden);
      } catch (e) {
        allFilesInPath = [];
        // print(e);
      }
      files.addAll(allFilesInPath);
    }
    return files;
  }

  static String formatTime(String iso) {
    DateTime date = DateTime.parse(iso);
    DateTime now = DateTime.now();
    DateTime yDay = DateTime.now().subtract(const Duration(days: 1));
    DateTime dateFormat = DateTime.parse(
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00.000Z');
    DateTime today = DateTime.parse(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T00:00:00.000Z');
    DateTime yesterday = DateTime.parse(
        '${yDay.year}-${yDay.month.toString().padLeft(2, '0')}-${yDay.day.toString().padLeft(2, '0')}T00:00:00.000Z');

    if (dateFormat == today) {
      return 'Today ${DateFormat('HH:mm').format(DateTime.parse(iso))}';
    } else if (dateFormat == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(DateTime.parse(iso))}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(DateTime.parse(iso));
    }
  }
}
