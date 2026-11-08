import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isActive;
  final String fileName;
  final int position;
  final int total;
  final int allTimeViews;
  final int weeklyViews;
  final VoidCallback onShowQueue;
  final VoidCallback onHome;

  const VideoPlayerItem({
    super.key,
    required this.controller,
    required this.isActive,
    required this.fileName,
    required this.position,
    required this.total,
    required this.allTimeViews,
    required this.weeklyViews,
    required this.onShowQueue,
    required this.onHome,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  String? _seekLabel;
  bool _prevInitialized = false;
  bool _prevPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(VideoPlayerItem old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onControllerUpdate);
      widget.controller?.addListener(_onControllerUpdate);
      _prevInitialized = false;
      _prevPlaying = false;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final ctrl = widget.controller;
    final initialized = ctrl?.value.isInitialized ?? false;
    final playing = ctrl?.value.isPlaying ?? false;
    if (initialized != _prevInitialized || playing != _prevPlaying) {
      _prevInitialized = initialized;
      _prevPlaying = playing;
      setState(() {});
    }
  }

  void _togglePlayPause() {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
  }

  void _seek(int seconds) {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final newPos = ctrl.value.position + Duration(seconds: seconds);
    final duration = ctrl.value.duration;
    final clamped = newPos < Duration.zero ? Duration.zero : (newPos > duration ? duration : newPos);
    ctrl.seekTo(clamped);
    setState(() => _seekLabel = seconds > 0 ? '+${seconds}s' : '${seconds}s');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekLabel = null);
    });
  }

  void _copyFileName() {
    Clipboard.setData(ClipboardData(text: widget.fileName));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Nama file disalin'),
        duration: Duration(seconds: 1),
      ));
  }

  Widget _buildInfo(BuildContext context) {
    const shadow = [Shadow(blurRadius: 4, color: Colors.black)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _copyFileName,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.copy, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      shadows: shadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          'Dilihat ${widget.allTimeViews}× · 7 hari: ${widget.weeklyViews}×',
          style: const TextStyle(color: Colors.white70, fontSize: 12, shadows: shadow),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onShowQueue,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.queue_play_next, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${widget.position} / ${widget.total}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final initialized = ctrl != null && ctrl.value.isInitialized;
    final showPauseOverlay = initialized && !ctrl.value.isPlaying && widget.isActive;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (initialized)
            Center(
              child: AspectRatio(
                aspectRatio: ctrl.value.aspectRatio,
                child: VideoPlayer(ctrl),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ),
          if (showPauseOverlay) ...[
            const Positioned.fill(child: ColoredBox(color: Color(0x55000000))),
            Positioned(
              top: 48,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onHome,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 24),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SeekButton(icon: Icons.replay_10, onTap: () => _seek(-10)),
                  const SizedBox(width: 24),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 52),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _SeekButton(icon: Icons.forward_10, onTap: () => _seek(10)),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildInfo(context),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: VideoProgressIndicator(
                      ctrl,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_seekLabel != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _seekLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SeekButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SeekButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: Colors.white, size: 44),
      ),
    );
  }
}
