import 'dart:io';

import 'package:file_manager/presentation/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


import '../../busines_logic/file_cubit.dart';
import '../../utils/theme_config.dart';
import '../widgets/custom_divider.dart';

import '../widgets/dir_item.dart';
import '../widgets/file/file_item.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/path_bar.dart';
import '../widgets/sort_sheet.dart';

class Folder extends StatefulWidget {
  final String path;

  const Folder({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> with WidgetsBindingObserver {
  TextEditingController fileName = TextEditingController();

  TextEditingController fileExtension = TextEditingController();
  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<FileCubit>(context);
    cubit.path = widget.path;
    cubit.getFiles();
    cubit.paths.add(widget.path);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<FileCubit>(context);
    return WillPopScope(
      onWillPop: () async {
        if (cubit.paths.length == 1) {
          return true;
        } else {
          cubit.paths.removeLast();
          setState(() {
            cubit.path = cubit.paths.last;
          });
          cubit.getFiles();
          return false;
        }
      },
      child: BlocBuilder<FileCubit, FileState>(
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                leading: cubit.paths.length > 1
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (cubit.paths.length > 1) {
                            cubit.navigateBack();
                          }
                        },
                      )
                    : SizedBox(),
                elevation: 4,
                title: Text(
                  cubit.paths.length > 1 ? cubit.path : "",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                bottom: PathBar(
                  paths: cubit.paths,
                  icon: Icons.smartphone,
                  onChanged: (index) {
                    // print(paths[index]);
                    cubit.path = cubit.paths[index];
                    cubit.paths.removeRange(index + 1, cubit.paths.length);
                    setState(() {});
                    cubit.getFiles();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) => const SortSheet(),
                      );
                      cubit.getFiles();
                    },
                    tooltip: 'Sort by',
                    icon: const Icon(Icons.sort_by_alpha_sharp),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) => const FilterSheet(),
                      );
                    },
                    tooltip: 'Filter by',
                    icon: const Icon(Icons.filter_list_sharp),
                  ),
                ],
              ),
              body:cubit.loading? const Center(child: CustomLoader()): Visibility(
                replacement: const Center(child: Text('There\'s nothing here')),
                visible: cubit.files.isNotEmpty,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 80, left: 10, right: 10),
                  itemCount: cubit.files.length,
                  itemBuilder: (BuildContext context, int index) {
                    FileSystemEntity file = cubit.files[index];
                    if (file.toString().split(':')[0] == 'Directory') {
                      return DirectoryItem(
                        popTap: (v) async {
                          if (v == 0) {
                            cubit.renameDialog(context, file.path, 'dir');
                          } else if (v == 1) {
                            cubit.deleteFile(true, file);
                          }
                        },
                        file: file,
                        tap: () {
                          cubit.paths.add(file.path);
                          cubit.path = file.path;
                          setState(() {});
                          cubit.getFiles();
                        },
                      );
                    }
                    return FileItem(
                      file: file,
                      popTap: (v) async {
                        if (v == 0) {
                          cubit.renameDialog(context, file.path, 'file');
                        } else if (v == 1) {
                          cubit.deleteFile(false, file);
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const CustomDivider();
                  },
                ),
              ),
              floatingActionButton: SpeedDial(
                backgroundColor: ThemeConfig.primary,
                //   ponPressed: () => cubit.addDialog(context, cubit.path),
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.folder),
                    label: 'Add Folder',
                    onTap: () => cubit.addDialog(context, cubit.path),
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.file_copy),
                    label: 'Add File',
                    onTap: () => cubit.createFile(context, cubit.path),
                  ),
                ],
                child: const Icon(Icons.add),
              ));
        },
      ),
    );
  }
}
