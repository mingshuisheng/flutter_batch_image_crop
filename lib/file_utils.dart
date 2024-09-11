import 'dart:io';

import 'package:cross_file/cross_file.dart';

import 'image_format.dart';

Future<List<XFile>> getImageFileByXFile(List<XFile> files) {
  return getImageFile(files.map((file) => file.path));
}

Future<List<XFile>> getImageFile(Iterable<String> paths) async {
  final files = paths.toList();
  final tasks = files.map((path) => File(path).stat()).toList();
  final stats = await Future.wait(tasks);
  final result = <XFile>[];
  final dirTasks = <Future<List<FileSystemEntity>>>[];
  for (var entry in stats.asMap().entries) {
    if (entry.value.type == FileSystemEntityType.file) {
      final path = files[entry.key];
      if (isSupportedImage(path)) {
        result.add(XFile(path));
      }
    } else if (entry.value.type == FileSystemEntityType.directory) {
      final path = files[entry.key];
      final dir = Directory(path);
      dirTasks.add(dir.list(recursive: true).toList());
    }
  }

  var entities = (await Future.wait(dirTasks)).expand((i) => i);
  for (var entity in entities) {
    final path = entity.path;
    if (isSupportedImage(path)) {
      result.add(XFile(path));
    }
  }
  return result;
}
