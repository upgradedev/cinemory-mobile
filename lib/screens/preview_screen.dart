import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/reel.dart';
import '../services/share_service.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Step 4: preview the finished reel, then share it or save it to the device.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ShareService _share = ShareService();
  final GlobalKey _shareButtonKey = GlobalKey();
  VideoPlayerController? _controller;
  String? _localPath;
  String? _status;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final Reel? reel = context.read<AppState>().reel;
    if (reel == null || !reel.isPlayable) return;
    final VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(reel.reelUrl));
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      await controller.dispose();
    }
  }

  Future<String?> _ensureDownloaded(Reel reel) async {
    _localPath ??= await _share.downloadReel(
      reel.reelUrl,
      fileName: '${reel.reelName}.mp4',
    );
    return _localPath;
  }

  Future<void> _onShare(Reel reel) async {
    setState(() => _working = true);
    try {
      final String? path = await _ensureDownloaded(reel);
      if (path == null) {
        _toast('This reel URL is a placeholder — run against a live API to share.');
        return;
      }
      await _share.shareVideo(
        path,
        text: 'Made with Cinemory',
        origin: _shareOrigin(),
      );
    } catch (e) {
      _toast('Share failed: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _onSave(Reel reel) async {
    setState(() => _working = true);
    try {
      final String? path = await _ensureDownloaded(reel);
      if (path == null) {
        _toast('Nothing to save — the offline API returns a placeholder URL.');
        return;
      }
      await _share.saveToGallery(path);
      _toast('Saved to your gallery.');
    } catch (e) {
      _toast('Save failed: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  /// The share button's screen rect — required by iOS/iPad to anchor the share
  /// popover (a null origin can crash the sheet on iPad).
  Rect? _shareOrigin() {
    final RenderObject? box =
        _shareButtonKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  void _toast(String message) {
    if (!mounted) return;
    setState(() => _status = message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _share.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Reel? reel = state.reel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your reel'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start over',
            onPressed: () => state.reset(),
          ),
        ],
      ),
      body: reel == null
          ? const Center(child: Text('No reel to show.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _preview(reel),
                const SizedBox(height: 16),
                _ProvenanceCard(reel: reel),
                if (_status != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(_status!,
                      style: const TextStyle(color: Colors.white54)),
                ],
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        key: _shareButtonKey,
                        onPressed: _working ? null : () => _onShare(reel),
                        icon: const Icon(Icons.ios_share),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _working ? null : () => _onSave(reel),
                        icon: const Icon(Icons.download),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _preview(Reel reel) {
    final VideoPlayerController? c = _controller;
    if (c != null && c.value.isInitialized) {
      return AspectRatio(
        aspectRatio: c.value.aspectRatio,
        child: VideoPlayer(c),
      );
    }
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: CinemoryTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.movie, size: 48, color: CinemoryTheme.gold),
            const SizedBox(height: 8),
            Text(
              reel.isPlayable
                  ? 'Loading preview…'
                  : 'Preview needs a live API.\nReel generated and provenance sealed.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProvenanceCard extends StatelessWidget {
  const _ProvenanceCard({required this.reel});
  final Reel reel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CinemoryTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(reel.reelName,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _kv('Occasion', reel.occasion),
          _kv('Steps', '${reel.steps}'),
          _kv('SHA-256', _shortHash(reel.reelSha256)),
        ],
      ),
    );
  }

  static String _shortHash(String hash) {
    if (hash.isEmpty) return '—';
    final int end = hash.length < 16 ? hash.length : 16;
    return '${hash.substring(0, end)}…';
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 84,
              child: Text(k, style: const TextStyle(color: Colors.white54)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
