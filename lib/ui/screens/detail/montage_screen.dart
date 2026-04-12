import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';

class MontageScreen extends ConsumerStatefulWidget {
  const MontageScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<MontageScreen> createState() => _MontageScreenState();
}

class _MontageScreenState extends ConsumerState<MontageScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startSlideshow();
    }
  }

  Future<void> _startSlideshow() async {
    while (_isPlaying && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_isPlaying || !mounted) break;
      
      final completions = ref.read(completionsForActivityProvider(widget.activityId)).valueOrNull ?? [];
      final photoCompletions = completions.where((c) => c.photoPath != null).toList();
      
      if (_currentIndex < photoCompletions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      } else {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityByIdProvider(widget.activityId));
    final completionsAsync = ref.watch(completionsForActivityProvider(widget.activityId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white, onPressed: () => Navigator.pop(context)),
        actions: [
          if (completionsAsync.hasValue)
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
              onPressed: _togglePlay,
            ),
        ],
      ),
      body: completionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(child: Text('Error loading photos', style: TextStyle(color: Colors.white))),
        data: (completions) {
          final photoCompletions = completions
              .where((c) => c.photoPath != null)
              .toList()
              ..sort((a, b) => a.dateKey.compareTo(b.dateKey)); // Chronological

          if (photoCompletions.isEmpty) {
            return const Center(
              child: Text(
                'No photos uploaded for this challenge yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: photoCompletions.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (ctx, i) {
                  final completion = photoCompletions[i];
                  final date = DateTime.parse(completion.dateKey);
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // High quality image
                      Image.file(
                        File(completion.photoPath!),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      // Gradient overlay for text readability
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black45, Colors.transparent, Colors.transparent, Colors.black87],
                            stops: [0, 0.2, 0.7, 1],
                          ),
                        ),
                      ),
                      // Date label
                      Positioned(
                        bottom: 60,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('MMMM d, yyyy').format(date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (completion.note != null && completion.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  completion.note!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Progress indicator
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (photoCompletions.length > 1) 
                        ? (_currentIndex / (photoCompletions.length - 1))
                        : 1.0,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      activityAsync.hasValue ? Color(activityAsync.value!.colorValue) : Colors.white,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
