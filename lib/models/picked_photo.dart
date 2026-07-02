import 'dart:io';
import 'dart:typed_data';

/// A platform-agnostic handle to one on-device photo.
///
/// This is the domain boundary that keeps the rest of the app testable: the
/// UI and [AppState] work with [PickablePhoto], while only [PhotoService]
/// knows about photo_manager's `AssetEntity`. The two closures defer the
/// (async, platform-channel) work of loading pixels until actually needed.
class PickablePhoto {
  const PickablePhoto({
    required this.id,
    required this.width,
    required this.height,
    required Future<Uint8List?> Function() thumbnailLoader,
    required Future<File?> Function() fileLoader,
  })  : _thumbnailLoader = thumbnailLoader,
        _fileLoader = fileLoader;

  final String id;
  final int width;
  final int height;

  final Future<Uint8List?> Function() _thumbnailLoader;
  final Future<File?> Function() _fileLoader;

  /// Small JPEG bytes for grid display.
  Future<Uint8List?> thumbnail() => _thumbnailLoader();

  /// The full-resolution file (from PhotoKit / MediaStore). Used once a real
  /// multipart ingest endpoint exists on the Cinemory API.
  Future<File?> originFile() => _fileLoader();
}

/// Outcome of asking for photo-library access.
enum PhotoPermission {
  /// Full library access granted.
  authorized,

  /// iOS 14+/Android 14+ "selected photos only" — still usable.
  limited,

  /// User said no.
  denied,

  /// Blocked by policy (parental controls / MDM).
  restricted,
}

extension PhotoPermissionX on PhotoPermission {
  bool get canAccess =>
      this == PhotoPermission.authorized || this == PhotoPermission.limited;
}
