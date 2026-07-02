/// App-wide configuration.
///
/// The Cinemory API base URL is a compile-time constant supplied via
/// `--dart-define=CINEMORY_API_BASE_URL=https://...`. No secrets live here.
///
/// Defaults are dev-friendly:
///  * Android emulator reaches the host machine on `10.0.2.2`.
///  * iOS simulator reaches the host on `localhost`.
/// Override for a real deployment, e.g.
///   flutter run --dart-define=CINEMORY_API_BASE_URL=https://api.cinemory.app
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'CINEMORY_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String appName = 'Cinemory';

  /// How many photos map into a single reel chapter when we derive a
  /// [ReelRequest] from the user's selection.
  static const int photosPerChapter = 2;

  /// The API caps a reel at six chapters; keep the client in step.
  static const int maxChapters = 6;
}
