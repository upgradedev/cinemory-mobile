/// An occasion template, mirroring the Cinemory API `GET /occasions` payload.
///
/// The six presets ship as a fallback so the picker works before the network
/// call returns (or offline); the live list from the API takes precedence.
class Occasion {
  const Occasion({
    required this.key,
    required this.label,
    this.musicStyle = '',
    this.tempo = 0,
    this.secondsPerClip = 0,
    this.transition = '',
    this.titleStyle = '',
    this.aspectRatio = '16:9',
  });

  final String key;
  final String label;
  final String musicStyle;
  final double tempo;
  final double secondsPerClip;
  final String transition;
  final String titleStyle;
  final String aspectRatio;

  bool get isVertical => aspectRatio == '9:16';

  factory Occasion.fromJson(Map<String, dynamic> json) {
    return Occasion(
      key: (json['key'] ?? '') as String,
      label: (json['label'] ?? json['key'] ?? '') as String,
      musicStyle: (json['music_style'] ?? '') as String,
      tempo: (json['tempo'] as num?)?.toDouble() ?? 0,
      secondsPerClip: (json['seconds_per_clip'] as num?)?.toDouble() ?? 0,
      transition: (json['transition'] ?? '') as String,
      titleStyle: (json['title_style'] ?? '') as String,
      aspectRatio: (json['aspect_ratio'] ?? '16:9') as String,
    );
  }

  /// Built-in fallback presets — kept in step with `src/cinemory/occasions.py`.
  static const List<Occasion> fallback = <Occasion>[
    Occasion(
      key: 'anniversary',
      label: 'Anniversary',
      musicStyle: 'warm romantic strings',
      tempo: 96,
      secondsPerClip: 3.5,
      transition: 'soft cross-dissolve',
      titleStyle: 'elegant serif, gold foil',
      aspectRatio: '16:9',
    ),
    Occasion(
      key: 'graduation',
      label: 'Graduation',
      musicStyle: 'uplifting orchestral build',
      tempo: 112,
      secondsPerClip: 2.8,
      transition: 'bright light-leak wipe',
      titleStyle: 'bold modern sans, class-year accent',
      aspectRatio: '16:9',
    ),
    Occasion(
      key: 'birthday',
      label: 'Birthday',
      musicStyle: 'playful upbeat pop',
      tempo: 124,
      secondsPerClip: 2.2,
      transition: 'quick punch-in cut',
      titleStyle: 'rounded playful display, confetti accents',
      aspectRatio: '9:16',
    ),
    Occasion(
      key: 'wedding',
      label: 'Wedding',
      musicStyle: 'cinematic emotional piano',
      tempo: 88,
      secondsPerClip: 4.0,
      transition: 'slow film-dissolve',
      titleStyle: 'fine script, ivory and blush',
      aspectRatio: '16:9',
    ),
    Occasion(
      key: 'year-in-review',
      label: 'Year in Review',
      musicStyle: 'driving indie montage',
      tempo: 120,
      secondsPerClip: 1.8,
      transition: 'rhythmic beat-cut',
      titleStyle: 'calendar-stamp mono, month markers',
      aspectRatio: '9:16',
    ),
    Occasion(
      key: 'business-event',
      label: 'Business Event / Award Ceremony',
      musicStyle: 'confident corporate cinematic',
      tempo: 104,
      secondsPerClip: 3.2,
      transition: 'clean linear slide',
      titleStyle: 'sharp geometric sans, brand-accent bar',
      aspectRatio: '16:9',
    ),
  ];
}
