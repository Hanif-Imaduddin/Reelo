import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import 'folder_picker_screen.dart';
import 'video_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<File> videos;
  final String folderPath;

  const HomeScreen({super.key, required this.videos, required this.folderPath});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  String _mode = 'random';
  String _basis = 'all';

  @override
  void initState() {
    super.initState();
    _storage.getModeAndBasis().then((mb) {
      if (mounted) {
        setState(() {
          _mode = mb.$1;
          _basis = mb.$2;
        });
      }
    });
  }

  Future<void> _start() async {
    await _storage.saveModeAndBasis(_mode, _basis);
    final views = await _storage.loadViews();
    if (!mounted) return;

    final shuffled = widget.videos.toList()..shuffle();
    final queue = _mode == 'random'
        ? shuffled
        : FileService.mixedQueue(shuffled, (f) {
            final v = views[f.path];
            return v == null ? 0 : (_basis == 'weekly' ? v.weekly : v.total);
          });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoFeedScreen(videos: queue, views: views)),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _changeFolder() async {
    await _storage.clearFolderPath();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FolderPickerScreen()),
    );
  }

  Future<void> _resetViews() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset views?'),
        content: const Text('Data views semua video akan dihapus dan tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true) return;
    await _storage.resetViews();
    VideoFeedScreen.countedThisRun.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data views sudah direset')),
    );
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
              const Icon(Icons.play_circle_fill, size: 72, color: Colors.white),
              const SizedBox(height: 16),
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
              const Text(
                appVersion,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.videos.length} video · ${widget.folderPath}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 40),
              const Text('Mode', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'random', label: Text('Random'), icon: Icon(Icons.shuffle)),
                  ButtonSegment(value: 'mixed', label: Text('Campuran'), icon: Icon(Icons.merge_type)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              if (_mode == 'mixed') ...[
                const SizedBox(height: 16),
                const Text('Urutkan views (paling sedikit duluan)',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All-time')),
                    ButtonSegment(value: 'weekly', label: Text('7 hari')),
                  ],
                  selected: {_basis},
                  onSelectionChanged: (s) => setState(() => _basis = s.first),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _changeFolder,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Ganti folder'),
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _resetViews,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset views'),
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
