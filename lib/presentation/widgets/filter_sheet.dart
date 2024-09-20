// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../busines_logic/file_cubit.dart';
import '../../utils/theme_config.dart';


class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  List filterList = [
    'Text',
    'Images',
    'Application',
    'Archive',
    'Audio',
    'Video',
  ];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileCubit, FileState>(
      builder: (context, state) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Filter by:',
                  style: TextStyle(fontSize: 18.0, color: ThemeConfig.accent2),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: filterList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          switch (index) {
                            case 0:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('text');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;

                            case 1:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('image');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;

                            case 2:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('application');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;

                            case 3:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('archive');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;

                            case 4:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('audio');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;
                            case 5:
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .getNonThumbnailFiles('video');

                              BlocProvider.of<FileCubit>(context, listen: false)
                                  .files = BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .currentFiles;
                              await BlocProvider.of<FileCubit>(context,
                                      listen: false)
                                  .setFilter(index);

                              break;
                          }

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.all(0),
                        trailing: index ==
                                BlocProvider.of<FileCubit>(context,
                                        listen: false)
                                    .filter
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              )
                            : const SizedBox(),
                        title: Text(
                          '${filterList[index]}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: index ==
                                    BlocProvider.of<FileCubit>(context,
                                            listen: false)
                                        .filter
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
