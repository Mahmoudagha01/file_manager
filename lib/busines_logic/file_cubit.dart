import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';

import 'package:meta/meta.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dialogs.dart';
import '../utils/file_utils.dart';
import '../presentation/widgets/dialogs/add_file_dialog.dart';
import '../presentation/widgets/dialogs/rename_file_dialog.dart';

part 'file_state.dart';

class FileCubit extends Cubit<FileState> {
  FileCubit() : super(FileInitial());
  int sort = 0;
  int filter = 9;
  bool loading = false;
  final isolates = IsolateHandler();
  late String path;
  List<FileSystemEntity> nonThumbnailFiles = <FileSystemEntity>[];
  List<String> nonThumbnailTabs = <String>[];
  List<FileSystemEntity> currentFiles = [];

  List<String> paths = <String>[];

  List<FileSystemEntity> files = <FileSystemEntity>[];

  Future setSort(value) async {
    emit(FileInitial());
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setInt('sort', value);
    sort = value;
    emit(FilesSorted());
  }

  Future setFilter(value) async {
    emit(FileInitial());
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setInt('filter', value);
    filter = value;
    emit(FilesSorted());
  }

  List<FileSystemEntity> sortList(List<FileSystemEntity> list, int sort) {
    emit(FileInitial());
    switch (sort) {
      /// Sort by name
      case 0:
        list.sort((f1, f2) => basename(f1.path)
            .toLowerCase()
            .compareTo(basename(f2.path).toLowerCase()));
        break;

      case 1:
        list.sort((f1, f2) => basename(f2.path)
            .toLowerCase()
            .compareTo(basename(f1.path).toLowerCase()));
        break;

      /// Sort by date
      case 2:
        list.sort((FileSystemEntity f1, FileSystemEntity f2) =>
            f1.statSync().modified.compareTo(f2.statSync().modified));
        break;

      case 3:
        list.sort((FileSystemEntity f1, FileSystemEntity f2) =>
            f2.statSync().modified.compareTo(f1.statSync().modified));
        break;

      /// sort by size
      case 4:
        list.sort((FileSystemEntity f1, FileSystemEntity f2) =>
            f2.statSync().size.compareTo(f1.statSync().size));
        break;

      case 5:
        list.sort((FileSystemEntity f1, FileSystemEntity f2) =>
            f1.statSync().size.compareTo(f2.statSync().size));
        break;

      default:
        list.sort();
        emit(FilesUpdated());
    }

    return list;
  }

  navigateBack() {
    emit(FileInitial());
    paths.removeLast();
    path = paths.last;
    emit(FileInitial());
    getFiles();
  }

  getFiles() async {
    emit(FileInitial());
    try {
      Directory dir = Directory(path);
      List<FileSystemEntity> dirFiles = dir.listSync();
      files.clear();

      for (FileSystemEntity file in dirFiles) {
        files.add(file);
      }

      files = sortList(files, sort);
      emit(FilesUpdated());
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        Dialogs.showToast('Permission Denied! cannot access this Directory!');
        navigateBack();
      }
    }
  }

  deleteFile(bool directory, var file) async {
    emit(FileInitial());
    try {
      if (directory) {
        await Directory(file.path).delete(recursive: true);
      } else {
        await File(file.path).delete(recursive: true);
      }
      Dialogs.showToast('Delete Successful');
      emit(FilesUpdated());
    } catch (e) {
      // print(e.toString());
      if (e.toString().contains('Permission denied')) {
        Dialogs.showToast('Cannot write to this Storage device!');
      }
    }
    getFiles();
  }

  addDialog(BuildContext context, String path) async {
    emit(FileInitial());
    await showDialog(
      context: context,
      builder: (context) => AddFileDialog(path: path),
    );
    getFiles();
  }

  renameDialog(BuildContext context, String path, String type) async {
    emit(FileInitial());
    await showDialog(
      context: context,
      builder: (context) => RenameFileDialog(path: path, type: type),
    );
    getFiles();
  }

  createFile(BuildContext context, String path) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController fileName = TextEditingController();

        TextEditingController fileExtension = TextEditingController();
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Name",
                    ),
                    controller: fileName,
                  ),
                ),
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Extension",
                    ),
                    controller: fileExtension,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    String folderPath = path;
                    try {
                      Directory folder = Directory(folderPath);
                      if (!await folder.exists()) {
                        await folder.create(recursive: true);
                      }
                      File file = File(
                          '$folderPath/${fileName.text}.${fileExtension.text}');
                      if (!await file.exists()) {
                        await file.create();
                        RandomAccessFile raf =
                            await file.open(mode: FileMode.write);

                        await raf.close().then((value) {
                          Navigator.pop(context);
                        });
                        emit(FilesUpdated());
                      } else {
                        Dialogs.showToast("File already exists!");
                        emit(FilesUpdated());
                      }
                    } catch (e) {
                      Dialogs.showToast("somthing went wrong");
                    }
                  },
                  child: const Text(
                    'Create File',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  getNonThumbnailFiles(String type) async {
    await getFilterdFiles(type, nonThumbnailFiles, nonThumbnailTabs);
  }

  Future<void> getFilterdFiles(
      String type, List<FileSystemEntity> files, List<String> tabs,
      [String? dirName]) async {
         setLoading(true);
    tabs.clear();
    files.clear();
    tabs.add('All');
    if (dirName != null) {
      List<Directory> storages = await FileUtils.getStorageList();
      for (var dir in storages) {
        if (Directory('${dir.path}$dirName').existsSync()) {
          List<FileSystemEntity> dirFiles =
              Directory('${dir.path}$dirName').listSync();
          for (var file in dirFiles) {
            if (FileSystemEntity.isFileSync(file.path)) {
              files.add(file);
              tabs.add(file.path.split('/')[file.path.split('/').length - 2]);
              tabs = tabs.toSet().toList();
              emit(FilesUpdated());
            }
          }
        }
      }
    } else {
      String isolateName = type;
      isolates.spawn<String>(
        getAllFilesWithIsolate,
        name: isolateName,
        onReceive: (val) {
          print('getAllFilesWithIsolate completed');
          isolates.kill(isolateName);
        },
        onInitialized: () => isolates.send('hey', to: isolateName),
      );
      ReceivePort port = ReceivePort();
      IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
      port.listen((filePaths) {
        processFilePaths(filePaths, type, files, tabs);
        currentFiles = files;
setLoading(false);
        print('getFiles completed');
        port.close();
        IsolateNameServer.removePortNameMapping('${isolateName}_2');
      });
    }
  }

  void processFilePaths(List<String> filePaths, String type,
      List<FileSystemEntity> files, List<String> tabs) {
    Set _tabs = tabs.toSet();
    filePaths.forEach((filePath) {
      File file = File(filePath);
      if (shouldAddFile(file, type)) {
        files.add(file);
        _tabs.add('${file.path.split('/')[file.path.split('/').length - 2]}');
      }
      emit(FilesUpdated());
    });
    tabs = _tabs.toList() as List<String>;
  }

  bool shouldAddFile(File file, String type) {
    switch (type) {
      case 'application':
        return extension(file.path) == '.apk';
      case 'archive':
        return ['.zip', '.rar', '.tar', '.gz', '.7z', '.zlib', 'bz2', '.xz']
            .contains(extension(file.path));
      case 'text':
        return ['.pdf', '.epub', '.mobi', '.doc', '.docx', '.json']
            .contains(extension(file.path));
      default:
        String mimeType = mime(file.path) ?? '';
        return mimeType.split('/')[0] == type;
    }
  }

  static getAllFilesWithIsolate(Map<String, dynamic> context) async {
    String isolateName = context['name'];
    List<FileSystemEntity> files =
        await FileUtils.getAllFiles(showHidden: false);
    final messenger = HandledIsolate.initialize(context);
    try {
      final SendPort? send =
          IsolateNameServer.lookupPortByName('${isolateName}_2');
      // Convert the FileSystemEntity objects to their paths before sending
      List<String> filePaths = files.map((file) => file.path).toList();
      print('Found ${filePaths.length} files');
      send!.send(filePaths);
      // Wait for the send operation to complete before sending 'done'
      await Future.delayed(Duration(seconds: 1));
      messenger.send('done');
    } catch (e) {
      print(e);
    }
  }

  static Future<List<FileSystemEntity>> getTabImages(List item) async {
    List items = item[0];
    String label = item[1];
    List<FileSystemEntity> files = [];
    for (var file in items) {
      if ('${file.path.split('/')[file.path.split('/').length - 2]}' == label) {
        files.add(file);
      }
    }
    return files;
  }

  switchCurrentFiles(List list, String label) async {
    List<FileSystemEntity> l = await compute(getTabImages, [list, label]);
    currentFiles = l;
    emit(FilesUpdated());
  }

  void setLoading(value) {
    loading = value;
emit(FilesUpdated());
  }
}
