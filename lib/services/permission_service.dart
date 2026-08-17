import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Request both; the OS determines which is needed based on API level.
    // READ_MEDIA_VIDEO (API 33+) or READ_EXTERNAL_STORAGE (API 26–32).
    final statuses = await [
      Permission.storage,
      Permission.videos,
    ].request();

    return statuses[Permission.storage]!.isGranted ||
        statuses[Permission.videos]!.isGranted;
  }

  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    return await Permission.storage.isGranted ||
        await Permission.videos.isGranted;
  }

  Future<void> openSettings() => openAppSettings();
}
