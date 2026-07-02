import 'package:photo_manager/photo_manager.dart';

import '../models/picked_photo.dart';

/// Abstraction over the on-device photo library so [AppState] can be unit
/// tested with a fake. The production implementation is [PhotoManagerGallery].
abstract class PhotoGallery {
  /// Prompt for (or read the current) photo-library permission.
  Future<PhotoPermission> ensurePermission();

  /// Most-recent photos from the library, newest first.
  Future<List<PickablePhoto>> recentPhotos({int limit = 100});

  /// Open the OS settings page so the user can change a denied/limited grant.
  Future<void> openSettings();
}

/// Real implementation backed by the `photo_manager` plugin:
///  * iOS/macOS  -> PhotoKit (this IS the Apple Photos / iCloud path; on-device
///    originals, with explicit permission — no server-side Apple API exists).
///  * Android    -> MediaStore.
class PhotoManagerGallery implements PhotoGallery {
  const PhotoManagerGallery();

  @override
  Future<PhotoPermission> ensurePermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    switch (state) {
      case PermissionState.authorized:
        return PhotoPermission.authorized;
      case PermissionState.limited:
        return PhotoPermission.limited;
      case PermissionState.restricted:
        return PhotoPermission.restricted;
      case PermissionState.denied:
      case PermissionState.notDetermined:
        return PhotoPermission.denied;
    }
  }

  @override
  Future<List<PickablePhoto>> recentPhotos({int limit = 100}) async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return <PickablePhoto>[];

    final AssetPathEntity recent = albums.first;
    final List<AssetEntity> assets =
        await recent.getAssetListPaged(page: 0, size: limit);

    return assets.map(_toPickable).toList(growable: false);
  }

  @override
  Future<void> openSettings() => PhotoManager.openSetting();

  PickablePhoto _toPickable(AssetEntity asset) {
    return PickablePhoto(
      id: asset.id,
      width: asset.width,
      height: asset.height,
      thumbnailLoader: () => asset.thumbnailDataWithSize(
        const ThumbnailSize.square(300),
      ),
      fileLoader: () => asset.file,
    );
  }
}
