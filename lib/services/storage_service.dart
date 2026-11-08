import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

typedef ViewStat = ({int total, int weekly});

class StorageService {
  static const String _folderPathKey = 'folder_path';
  static const String _viewsKey = 'views';
  static const String _modeKey = 'mode';
  static const String _basisKey = 'basis';
  static const _week = Duration(days: 7);

  Future<String?> getFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_folderPathKey);
  }

  Future<void> saveFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_folderPathKey, path);
  }

  Future<void> clearFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_folderPathKey);
  }

  /// Last chosen playback mode ('random' | 'mixed') and views basis ('all' | 'weekly').
  Future<(String, String)> getModeAndBasis() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_modeKey) ?? 'random', prefs.getString(_basisKey) ?? 'all');
  }

  Future<void> saveModeAndBasis(String mode, String basis) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode);
    await prefs.setString(_basisKey, basis);
  }

  // Stored as JSON: {path: {"t": allTimeCount, "r": [epochMs of views in last 7 days]}}
  Map<String, dynamic> _rawViews(SharedPreferences prefs) {
    final s = prefs.getString(_viewsKey);
    if (s == null) return {};
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, ViewStat>> loadViews() async {
    final prefs = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().subtract(_week).millisecondsSinceEpoch;
    return _rawViews(prefs).map((path, v) => MapEntry(path, (
          total: (v['t'] as num).toInt(),
          weekly: (v['r'] as List).where((ms) => (ms as num) > cutoff).length,
        )));
  }

  // ponytail: rewrites the whole map on every view; fine for thousands of files, move to sqflite if it gets slow.
  Future<void> recordView(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - _week.inMilliseconds;
    final raw = _rawViews(prefs);
    final v = raw[path] as Map<String, dynamic>? ?? {'t': 0, 'r': []};
    raw[path] = {
      't': (v['t'] as num).toInt() + 1,
      'r': [...(v['r'] as List).where((ms) => (ms as num) > cutoff), now],
    };
    await prefs.setString(_viewsKey, jsonEncode(raw));
  }

  Future<void> resetViews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_viewsKey);
  }
}
