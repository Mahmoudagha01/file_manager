import 'package:file_manager/busines_logic/file_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class SortSheet extends StatefulWidget {
  const SortSheet({super.key});

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
     List sortList = [
    'File name (A to Z)',
    'File name (Z to A)',
    'Date (oldest first)',
    'Date (newest first)',
    'Size (largest first)',
    'Size (Smallest first)',
  ];
  @override
  Widget build(BuildContext context) {
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
              'Sort by'.toUpperCase(),
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              child: ListView.builder(
                itemCount: sortList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () async {
                      await BlocProvider.of<FileCubit>(context,
                              listen: false)
                          .setSort(index);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    trailing: index ==
                           BlocProvider.of<FileCubit>(context,
                                    listen: false)
                                .sort
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          )
                        : const SizedBox(),
                    title: Text(
                      '${sortList[index]}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: index ==
                               BlocProvider.of<FileCubit>(context,
                                        listen: false)
                                    .sort
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.titleMedium!.color,
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
  }
}
