import 'package:cinemory_mobile/models/reel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReelRequest.fromSelection', () {
    test('groups photos two-per-chapter', () {
      final ReelRequest r =
          ReelRequest.fromSelection(occasion: 'wedding', photoCount: 6);
      expect(r.perChapter, 2);
      expect(r.chapters, 3);
      expect(r.occasion, 'wedding');
    });

    test('always yields at least one chapter', () {
      final ReelRequest r =
          ReelRequest.fromSelection(occasion: 'birthday', photoCount: 1);
      expect(r.chapters, 1);
    });

    test('clamps to the API six-chapter ceiling', () {
      final ReelRequest r =
          ReelRequest.fromSelection(occasion: 'year-in-review', photoCount: 40);
      expect(r.chapters, 6);
    });

    test('generates a unique name when none supplied', () {
      final ReelRequest a =
          ReelRequest.fromSelection(occasion: 'anniversary', photoCount: 2);
      expect(a.name, startsWith('reel-anniversary-'));
    });

    test('serialises to the API JSON contract', () {
      final ReelRequest r = ReelRequest.fromSelection(
        occasion: 'graduation',
        photoCount: 4,
        name: 'fixed',
      );
      expect(r.toJson(), <String, dynamic>{
        'name': 'fixed',
        'chapters': 2,
        'per_chapter': 2,
        'occasion': 'graduation',
      });
    });
  });

  group('Reel', () {
    test('parses the POST /reels response', () {
      final Reel reel = Reel.fromJson(<String, dynamic>{
        'reel_name': 'demo',
        'occasion': 'wedding',
        'reel_url': 'https://cdn.example/demo.mp4',
        'reel_sha256': 'abc',
        'manifest_uri': 'b2://x',
        'manifest_hash': 'def',
        'steps': 7,
      });
      expect(reel.reelName, 'demo');
      expect(reel.steps, 7);
      expect(reel.isPlayable, isTrue);
    });

    test('flags non-http placeholder URLs as not playable', () {
      final Reel reel = Reel.fromJson(<String, dynamic>{
        'reel_url': 'demo/reels/ab/cd/demo.mp4',
      });
      expect(reel.isPlayable, isFalse);
    });
  });
}
