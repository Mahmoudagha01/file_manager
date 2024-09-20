part of 'file_cubit.dart';

abstract class FileState {
  const FileState();
}

class FileInitial extends FileState {}

class FilesSorted extends FileState {}

class FilesUpdated extends FileState {}
