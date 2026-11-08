import 'dart:io';
import 'dart:math';
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

  /// Alternates between [shuffled] (random order) and the same files sorted by
  /// fewest views first, skipping files already taken. No duplicates.
  static List<File> mixedQueue(List<File> shuffled, int Function(File) views, [Random? rng]) {
    rng ??= Random();
    // Random tie-break: Dart's sort isn't stable, and equal-view files should stay random anyway.
    final tie = {for (final f in shuffled) f.path: rng.nextDouble()};
    final byViews = [...shuffled]..sort((a, b) {
        final c = views(a).compareTo(views(b));
        return c != 0 ? c : tie[a.path]!.compareTo(tie[b.path]!);
      });

    final used = <String>{};
    final result = <File>[];
    var i = 0, j = 0;
    while (i < shuffled.length || j < byViews.length) {
      while (i < shuffled.length && used.contains(shuffled[i].path)) {
        i++;
      }
      if (i < shuffled.length && used.add(shuffled[i].path)) result.add(shuffled[i]);
      while (j < byViews.length && used.contains(byViews[j].path)) {
        j++;
      }
      if (j < byViews.length && used.add(byViews[j].path)) result.add(byViews[j]);
    }
    return result;
  }
}
