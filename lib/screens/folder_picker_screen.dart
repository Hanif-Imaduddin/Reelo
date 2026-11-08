import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../services/file_service.dart';
import 'home_screen.dart';

class FolderPickerScreen extends StatefulWidget {
  final bool permissionDenied;
  final bool noVideosFound;

  const FolderPickerScreen({
    super.key,
    this.permissionDenied = false,
    this.noVideosFound = false,
  });

  @override
  State<FolderPickerScreen> createState() => _FolderPickerScreenState();
}

class _FolderPickerScreenState extends State<FolderPickerScreen> {
  final _storageService = StorageService();
  final _permissionService = PermissionService();
  final _fileService = FileService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.permissionDenied) {
      _errorMessage = 'Izin akses storage ditolak. Buka Settings untuk mengizinkan.';
    } else if (widget.noVideosFound) {
      _errorMessage = 'Tidak ada video ditemukan di folder tersebut. Pilih folder lain.';
    }
  }

  Future<void> _pickFolder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final granted = await _permissionService.requestStoragePermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Izin akses storage ditolak. Buka Settings untuk mengizinkan.';
      });
      return;
    }

    final folderPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pilih Folder Video',
    );

    if (!mounted) return;

    if (folderPath == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak ada folder yang dipilih.';
      });
      return;
    }

    await _storageService.saveFolderPath(folderPath);

    final videos = await _fileService.getVideosFromFolder(folderPath);
    if (!mounted) return;

    if (videos.isEmpty) {
      await _storageService.clearFolderPath();
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak ada video (.mp4, .mkv, dll) di folder tersebut. Pilih folder lain.';
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(videos: videos, folderPath: folderPath),
      ),
    );
  }

  Future<void> _openSettings() async {
    await _permissionService.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.folder_open,
                size: 72,
                color: Colors.white70,
              ),
              const SizedBox(height: 24),
              const Text(
                'Reelo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih folder berisi video lokal kamu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.permissionDenied)
                  OutlinedButton(
                    onPressed: _openSettings,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Buka Settings'),
                  ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFolder,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.folder_open),
                label: Text(_isLoading ? 'Memuat...' : 'Pilih Folder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
