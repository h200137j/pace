import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/ui_state_provider.dart';

class MontageScreen extends ConsumerStatefulWidget {
  const MontageScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<MontageScreen> createState() => _MontageScreenState();
}

class _MontageScreenState extends ConsumerState<MontageScreen> {
  int _currentIndex = 0;
  bool _isPlaying = false;
  // ms per photo: 2000 = 0.5fps, 1000 = 1fps, 500 = 2fps
  int _intervalMs = 1000;

  static const _intervals = [2000, 1000, 500];
  static const _intervalLabels = ['0.5fps', '1fps', '2fps'];

  String get _speedLabel =>
      _intervalLabels[_intervals.indexOf(_intervalMs)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hideNavBarProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    ref.read(hideNavBarProvider.notifier).state = false;
    super.dispose();
  }

  void _togglePlay(int total) {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) _startSlideshow(total);
  }

  void _cycleFps() {
    final next = (_intervals.indexOf(_intervalMs) + 1) % _intervals.length;
    setState(() {
      _intervalMs = _intervals[next];
      _isPlaying = false;
    });
  }

  Future<void> _startSlideshow(int total) async {
    while (_isPlaying && mounted) {
      await Future.delayed(Duration(milliseconds: _intervalMs));
      if (!_isPlaying || !mounted) break;
      if (_currentIndex < total - 1) {
        setState(() => _currentIndex++);
      } else {
        setState(() => _isPlaying = false);
      }
    }
  }

  void _goTo(int index, int total) {
    if (index < 0 || index >= total) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityByIdProvider(widget.activityId));
    final completionsAsync =
        ref.watch(completionsForActivityProvider(widget.activityId));

    final activityName = activityAsync.valueOrNull?.name ?? '';
    final accentColor = activityAsync.hasValue
        ? Color(activityAsync.value!.colorValue)
        : const Color(0xFF00F2FF);

    return Scaffold(
      backgroundColor: Colors.black,
      body: completionsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => const Center(
          child: Text('Error loading photos',
              style: TextStyle(color: Colors.white70)),
        ),
        data: (completions) {
          final photos = completions
              .where((c) => c.photoPath != null)
              .toList()
            ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

          if (photos.isEmpty) {
            return Stack(children: [
              const Center(
                child: Text('No photos uploaded yet.',
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
              ),
              _BottomBar(
                speedLabel: _speedLabel,
                isPlaying: _isPlaying,
                current: 0,
                total: 0,
                accentColor: accentColor,
                onClose: () => Navigator.pop(context),
                onPlayPause: () {},
                onCycleFps: _cycleFps,
              ),
            ]);
          }

          final total = photos.length;
          final current = photos[_currentIndex];
          final date = DateTime.parse(current.dateKey);

          return Stack(
            children: [
              // ── Photo card layout ──────────────────────────────────────
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        MediaQuery.of(context).size.height * 0.12,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) {
                        final half = MediaQuery.of(context).size.width / 2;
                        if (d.globalPosition.dx < half) {
                          _goTo(_currentIndex - 1, total);
                        } else {
                          _goTo(_currentIndex + 1, total);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // ── Ken Burns photo with crossfade ───────────
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(opacity: anim, child: child),
                                layoutBuilder: (current, previous) => Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ...previous,
                                    if (current != null) current,
                                  ],
                                ),
                                child: _KenBurnsPhoto(
                                  key: ValueKey(_currentIndex),
                                  path: current.photoPath!,
                                  index: _currentIndex,
                                  duration: Duration(
                                    milliseconds: _intervalMs.clamp(500, 4000),
                                  ),
                                ),
                              ),

                              // ── Gradient overlay ─────────────────────────
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x88000000),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Color(0xCC000000),
                                    ],
                                    stops: [0, 0.18, 0.6, 1],
                                  ),
                                ),
                              ),

                              // ── Activity name (top-left) ──────────────────
                              if (activityName.isNotEmpty)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    activityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 8,
                                            color: Colors.black87)
                                      ],
                                    ),
                                  ),
                                ),

                              // ── Date (bottom-left) ────────────────────────
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    DateFormat('EEEE, d MMMM yyyy').format(date),
                                    key: ValueKey(_currentIndex),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 12,
                                            color: Colors.black87)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 110),
                ],
              ),

              // ── Bottom control pill ────────────────────────────────────
              _BottomBar(
                speedLabel: _speedLabel,
                isPlaying: _isPlaying,
                current: _currentIndex + 1,
                total: total,
                accentColor: accentColor,
                onClose: () => Navigator.pop(context),
                onPlayPause: () => _togglePlay(total),
                onCycleFps: _cycleFps,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Ken Burns photo ────────────────────────────────────────────────────────

class _KenBurnsPhoto extends StatefulWidget {
  const _KenBurnsPhoto({
    super.key,
    required this.path,
    required this.index,
    required this.duration,
  });

  final String path;
  final int index;
  final Duration duration;

  @override
  State<_KenBurnsPhoto> createState() => _KenBurnsPhotoState();
}

class _KenBurnsPhotoState extends State<_KenBurnsPhoto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<Alignment> _align;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    // Alternate zoom-in / zoom-out
    final zoomIn = widget.index % 2 == 0;
    _scale = Tween<double>(
      begin: zoomIn ? 1.0 : 1.08,
      end: zoomIn ? 1.08 : 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // Subtle alignment drift — 4 directions cycling
    const anchors = <List<Alignment>>[
      [Alignment.centerLeft, Alignment.centerRight],
      [Alignment.topCenter, Alignment.bottomCenter],
      [Alignment.centerRight, Alignment.centerLeft],
      [Alignment.bottomCenter, Alignment.topCenter],
    ];
    final pair = anchors[widget.index % anchors.length];
    _align = AlignmentTween(begin: pair[0], end: pair[1])
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Image.file(
          File(widget.path),
          fit: BoxFit.cover,
          alignment: _align.value,
        ),
      ),
    );
  }
}

// ── Bottom control bar ─────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.speedLabel,
    required this.isPlaying,
    required this.current,
    required this.total,
    required this.accentColor,
    required this.onClose,
    required this.onPlayPause,
    required this.onCycleFps,
  });

  final String speedLabel;
  final bool isPlaying;
  final int current;
  final int total;
  final Color accentColor;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onCycleFps;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomInset + 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Btn(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 4),
              _Btn(
                onTap: onCycleFps,
                child: Text(
                  speedLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _Btn(
                onTap: onPlayPause,
                highlighted: true,
                color: accentColor,
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isPlaying ? Colors.white : const Color(0xFF0A0A0F),
                  size: 24,
                ),
              ),
              if (total > 0) ...[
                const SizedBox(width: 4),
                _Btn(
                  onTap: () {},
                  child: Text(
                    '$current / $total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.onTap,
    required this.child,
    this.highlighted = false,
    this.color,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool highlighted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: highlighted ? (color ?? Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: child,
      ),
    );
  }
}
