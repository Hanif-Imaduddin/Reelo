import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelo/services/file_service.dart';

void main() {
  List<String> names(List<File> fs) => fs.map((f) => f.path).toList();

  test('mixedQueue matches the example from the spec', () {
    // ARR_1 (random): vid_1, vid_3, vid_2, vid_4 ; views ascending gives vid_2/vid_3 (0), vid_1 (1), vid_4
    final arr1 = ['vid_1.mp4', 'vid_3.mp4', 'vid_2.mp4', 'vid_4.mp4'].map(File.new).toList();
    const views = {'vid_1.mp4': 1, 'vid_2.mp4': 0, 'vid_3.mp4': 0, 'vid_4.mp4': 4};
    // Make vid_2 win the 0-views tie by trying seeds until it sorts first, then check interleave.
    for (var seed = 0; seed < 50; seed++) {
      final q = FileService.mixedQueue(arr1, (f) => views[f.path]!, Random(seed));
      expect(names(q).toSet().length, 4);
      expect(q.first.path, 'vid_1.mp4');
      if (q[1].path == 'vid_2.mp4') {
        expect(names(q), ['vid_1.mp4', 'vid_2.mp4', 'vid_3.mp4', 'vid_4.mp4']);
        return;
      }
    }
    fail('tie-break never chose vid_2');
  });

  test('mixedQueue keeps every file exactly once', () {
    final files = List.generate(37, (i) => File('v$i.mp4'))..shuffle(Random(1));
    final q = FileService.mixedQueue(files, (f) => f.path.length % 3, Random(2));
    expect(q.length, files.length);
    expect(names(q).toSet(), names(files).toSet());
  });

  test('mixedQueue handles empty and single lists', () {
    expect(FileService.mixedQueue([], (_) => 0), isEmpty);
    expect(names(FileService.mixedQueue([File('a.mp4')], (_) => 0)), ['a.mp4']);
  });
}
