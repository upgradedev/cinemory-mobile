import 'dart:math' as math;

import '../config.dart';

/// Request body for `POST /reels`.
///
/// NOTE (server gap): the current Cinemory API generates a reel from a
/// *synthetic* spec — it derives `chapters` x `per_chapter` scenes internally
/// and does not yet accept uploaded photo bytes. So this request carries the
/// user's chosen occasion and a chapter/clip count *derived from how many
/// photos they picked*, but the pixels themselves are not sent. Wiring the
/// real photos through needs a new multipart ingest endpoint on the API
/// (see [ReelDraft.photoCount] and CinemoryApi.uploadPhotosAndGenerate).
class ReelRequest {
  const ReelRequest({
    required this.name,
    required this.chapters,
    required this.perChapter,
    required this.occasion,
  });

  final String name;
  final int chapters;
  final int perChapter;
  final String occasion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'chapters': chapters,
        'per_chapter': perChapter,
        'occasion': occasion,
      };

  /// Derive a request from a user's picked-photo count.
  ///
  /// Photos are grouped [AppConfig.photosPerChapter] per chapter, clamped to
  /// the API's [AppConfig.maxChapters] ceiling. A unique [name] is generated so
  /// `GET /reels/{name}` can resolve the manifest afterwards.
  factory ReelRequest.fromSelection({
    required String occasion,
    required int photoCount,
    String? name,
  }) {
    final int perChapter = AppConfig.photosPerChapter;
    final int rawChapters = (photoCount / perChapter).ceil();
    final int chapters = math.max(1, math.min(rawChapters, AppConfig.maxChapters));
    final String reelName = name ??
        'reel-$occasion-${DateTime.now().millisecondsSinceEpoch}';
    return ReelRequest(
      name: reelName,
      chapters: chapters,
      perChapter: perChapter,
      occasion: occasion,
    );
  }
}

/// Response from `POST /reels`.
class Reel {
  const Reel({
    required this.reelName,
    required this.occasion,
    required this.reelUrl,
    required this.reelSha256,
    required this.manifestUri,
    required this.manifestHash,
    required this.steps,
  });

  final String reelName;
  final String occasion;
  final String reelUrl;
  final String reelSha256;
  final String manifestUri;
  final String manifestHash;
  final int steps;

  /// Whether [reelUrl] looks like something a video player can open. The
  /// offline/fake API returns a non-HTTP content-addressed URI, so preview
  /// playback only works against a live-mode API.
  bool get isPlayable =>
      reelUrl.startsWith('http://') || reelUrl.startsWith('https://');

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      reelName: (json['reel_name'] ?? '') as String,
      occasion: (json['occasion'] ?? '') as String,
      reelUrl: (json['reel_url'] ?? '') as String,
      reelSha256: (json['reel_sha256'] ?? '') as String,
      manifestUri: (json['manifest_uri'] ?? '') as String,
      manifestHash: (json['manifest_hash'] ?? '') as String,
      steps: (json['steps'] as num?)?.toInt() ?? 0,
    );
  }
}
