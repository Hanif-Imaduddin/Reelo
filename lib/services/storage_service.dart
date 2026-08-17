import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _folderPathKey = 'folder_path';

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
}
