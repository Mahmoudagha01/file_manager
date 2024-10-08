import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

import '../../../utils/file_utils.dart';
import 'file_icon.dart';
import 'file_popup.dart';

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function? popTap;

  const FileItem({
    Key? key,
    required this.file,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitleTextStyle: TextStyle(fontSize: 12,color: Colors.black),
      onTap: () => OpenFile.open(file.path),
      contentPadding: const EdgeInsets.all(0),
      leading: FileIcon(file: file),
      title: Text(
        basename(file.path),
        style: const TextStyle(fontSize: 14),
        maxLines: 2,
      ),
      subtitle: Row(
        
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${FileUtils.formatBytes(File(file.path).lengthSync(), 2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(30),
          Text(
            '${FileUtils.formatTime(File(file.path).lastModifiedSync().toIso8601String())}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing:
          popTap == null ? null : FilePopup(path: file.path, popTap: popTap!),
    );
  }
}
