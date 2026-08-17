import 'dart:io';
import 'package:path/path.dart' as p;

class FileService {
  static const List<String> _supportedExtensions = [
    '.mp4',
    '.mkv',
    '.avi',
    '.mov',
    '.webm',
    '.3gp',
  ];

  Future<List<File>> getVideosFromFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) return [];

    final files = <File>[];
    await for (final entity in directory.list(recursive: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (_supportedExtensions.contains(ext)) {
          files.add(entity);
        }
      }
    }

    files.shuffle();
    return files;
  }
}
