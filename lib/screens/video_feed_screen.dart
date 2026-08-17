import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/storage_service.dart';
import '../widgets/video_player_item.dart';
import 'folder_picker_screen.dart';

class VideoFeedScreen extends StatefulWidget {
  final List<File> videos;
  final String folderPath;

  const VideoFeedScreen({
    super.key,
    required this.videos,
    required this.folderPath,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  static const _ahead = 3;
  static const _behind = 3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _updateControllers(0);
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

  Future<void> _changeFolder() async {
    for (final ctrl in _controllers.values.toList()) {
      ctrl.dispose();
    }
    _controllers.clear();
    await StorageService().clearFolderPath();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const FolderPickerScreen()),
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
        itemBuilder: (_, index) => VideoPlayerItem(
          controller: _controllers[index],
          isActive: index == _currentIndex,
          onChangeFolder: _changeFolder,
        ),
      ),
    );
  }
}
