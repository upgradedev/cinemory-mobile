import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'gallery_screen.dart';
import 'generating_screen.dart';
import 'occasion_screen.dart';
import 'preview_screen.dart';

/// Top-level shell. Renders the current step of the create-and-share flow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    switch (state.step) {
      case CinemoryStep.intro:
        return const _IntroScreen();
      case CinemoryStep.gallery:
        return const GalleryScreen();
      case CinemoryStep.occasion:
        return const OccasionScreen();
      case CinemoryStep.generating:
        return const GeneratingScreen();
      case CinemoryStep.preview:
        return const PreviewScreen();
    }
  }
}

class _IntroScreen extends StatelessWidget {
  const _IntroScreen();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.theaters, size: 96, color: CinemoryTheme.gold),
            const SizedBox(height: 24),
            Text(
              'Your memories, made into film.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Pick photos from your library, choose an occasion, and Cinemory '
              'turns them into a cinematic reel to share.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 32),
            if (state.error != null) ...<Widget>[
              _PermissionNotice(state: state),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: state.busy ? null : () => state.startPhotoAccess(),
              icon: state.busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(state.busy ? 'Opening…' : 'Choose photos'),
            ),
            const SizedBox(height: 12),
            const Text(
              'On-device only. Photos never leave your phone without your '
              'explicit action.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CinemoryTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent, width: 1),
      ),
      child: Column(
        children: <Widget>[
          Text(
            state.error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orangeAccent),
          ),
          TextButton(
            onPressed: () => state.openPhotoSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
