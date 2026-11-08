import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import '../services/storage_service.dart';
import '../widgets/video_player_item.dart';

class VideoFeedScreen extends StatefulWidget {
  final List<File> videos;
  final Map<String, ViewStat> views;

  /// Paths already counted since the app started: one view per video per app run.
  static final countedThisRun = <String>{};

  const VideoFeedScreen({
    super.key,
    required this.videos,
    required this.views,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final _pageController = PageController();
  final _storage = StorageService();
  late final Map<String, ViewStat> _views = Map.of(widget.views);
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  static const _ahead = 3;
  static const _behind = 3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _updateControllers(0);
    _countView(0);
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _controllers[_currentIndex]?.pause();
    _controllers[index]?.play();
    setState(() => _currentIndex = index);
    _updateControllers(index);
    _countView(index);
  }

  ViewStat _statOf(String path) => _views[path] ?? (total: 0, weekly: 0);

  void _countView(int index) {
    final path = widget.videos[index].path;
    if (!VideoFeedScreen.countedThisRun.add(path)) return;
    final s = _statOf(path);
    _views[path] = (total: s.total + 1, weekly: s.weekly + 1);
    _storage.recordView(path);
  }

  Future<void> _updateControllers(int current) async {
    if (!mounted) return;
    final count = widget.videos.length;
    final start = (current - _behind).clamp(0, count - 1);
    final end = (current + _ahead).clamp(0, count - 1);

    // Dispose controllers outside the keep window
    for (final i in _controllers.keys.where((i) => i < start || i > end).toList()) {
      _controllers.remove(i)!.dispose();
    }

    // Initialize missing controllers within the window
    for (var i = start; i <= end; i++) {
      if (_controllers.containsKey(i)) continue;
      final ctrl = VideoPlayerController.file(widget.videos[i]);
      _controllers[i] = ctrl;
      ctrl.initialize().then((_) {
        if (!mounted || _controllers[i] != ctrl) return;
        ctrl.setLooping(true);
        if (i == _currentIndex) ctrl.play();
        setState(() {});
      });
    }
  }

  static String _fileDate(File f) {
    try {
      final d = f.lastModifiedSync();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.day)}/${two(d.month)}/${d.year}';
    } catch (_) {
      return '-';
    }
  }

  void _showQueue() {
    const rowHeight = 72.0;
    final scroll = ScrollController(
      initialScrollOffset: ((_currentIndex - 2) * rowHeight).clamp(0, double.infinity),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181818),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Antrian · ${widget.videos.length} video',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemExtent: rowHeight,
                itemCount: widget.videos.length,
                itemBuilder: (_, i) {
                  final f = widget.videos[i];
                  final s = _statOf(f.path);
                  return ListTile(
                    selected: i == _currentIndex,
                    selectedTileColor: Colors.white12,
                    selectedColor: Colors.white,
                    textColor: Colors.white70,
                    leading: SizedBox(
                      width: 40,
                      child: Text('${i + 1}', textAlign: TextAlign.right),
                    ),
                    title: Text(p.basename(f.path), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${_fileDate(f)} · 👁 ${s.total}× · 7 hari: ${s.weekly}×',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (i != _currentIndex) _pageController.jumpToPage(i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: widget.videos.length,
        itemBuilder: (_, index) {
          final path = widget.videos[index].path;
          final s = _statOf(path);
          return VideoPlayerItem(
            controller: _controllers[index],
            isActive: index == _currentIndex,
            fileName: p.basename(path),
            position: index + 1,
            total: widget.videos.length,
            allTimeViews: s.total,
            weeklyViews: s.weekly,
            onShowQueue: _showQueue,
            onHome: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}
