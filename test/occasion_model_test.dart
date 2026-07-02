import 'package:cinemory_mobile/models/occasion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Occasion', () {
    test('parses the API payload shape', () {
      final Occasion o = Occasion.fromJson(<String, dynamic>{
        'key': 'birthday',
        'label': 'Birthday',
        'music_style': 'playful upbeat pop',
        'tempo': 124.0,
        'seconds_per_clip': 2.2,
        'transition': 'quick punch-in cut',
        'title_style': 'rounded playful display',
        'aspect_ratio': '9:16',
      });
      expect(o.key, 'birthday');
      expect(o.label, 'Birthday');
      expect(o.tempo, 124.0);
      expect(o.isVertical, isTrue);
    });

    test('tolerates missing fields', () {
      final Occasion o = Occasion.fromJson(<String, dynamic>{'key': 'x'});
      expect(o.key, 'x');
      expect(o.label, 'x');
      expect(o.aspectRatio, '16:9');
      expect(o.isVertical, isFalse);
    });

    test('ships all six fallback presets', () {
      expect(Occasion.fallback.length, 6);
      expect(
        Occasion.fallback.map((Occasion o) => o.key),
        containsAll(<String>[
          'anniversary',
          'graduation',
          'birthday',
          'wedding',
          'year-in-review',
          'business-event',
        ]),
      );
    });
  });
}
