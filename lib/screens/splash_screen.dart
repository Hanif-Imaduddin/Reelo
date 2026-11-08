import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../services/file_service.dart';
import '../main.dart';
import 'folder_picker_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storageService = StorageService();
  final _permissionService = PermissionService();
  final _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final folderPath = await _storageService.getFolderPath();
    if (!mounted) return;

    if (folderPath == null) {
      _goToFolderPicker();
      return;
    }

    final hasPermission = await _permissionService.requestStoragePermission();
    if (!mounted) return;

    if (!hasPermission) {
      _goToFolderPicker(permissionDenied: true);
      return;
    }

    final videos = await _fileService.getVideosFromFolder(folderPath);
    if (!mounted) return;

    if (videos.isEmpty) {
      // Folder saved but contains no supported videos; re-pick
      await _storageService.clearFolderPath();
      _goToFolderPicker(noVideosFound: true);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(videos: videos, folderPath: folderPath),
      ),
    );
  }

  void _goToFolderPicker({
    bool permissionDenied = false,
    bool noVideosFound = false,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FolderPickerScreen(
          permissionDenied: permissionDenied,
          noVideosFound: noVideosFound,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Reelo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(appVersion, style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
