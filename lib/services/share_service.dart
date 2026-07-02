import 'dart:io';
import 'dart:ui' show Rect;

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Downloads the finished reel and hands it to the OS: the native share sheet
/// (Instagram / Facebook / LinkedIn / YouTube — no per-platform API review) and
/// save-to-gallery.
class ShareService {
  ShareService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Download [reelUrl] into the app cache and return the local file path.
  /// Returns null if the URL is not an HTTP(S) resource (e.g. the offline API's
  /// content-addressed placeholder).
  Future<String?> downloadReel(String reelUrl, {String? fileName}) async {
    if (!(reelUrl.startsWith('http://') || reelUrl.startsWith('https://'))) {
      return null;
    }
    final http.Response res = await _client.get(Uri.parse(reelUrl));
    if (res.statusCode != 200) return null;

    final Directory dir = await getTemporaryDirectory();
    final String name = fileName ?? 'cinemory-reel.mp4';
    final File file = File('${dir.path}/$name');
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file.path;
  }

  /// Open the native share sheet for a local video [path].
  ///
  /// [origin] is required on iPad to anchor the share popover (pass the sharing
  /// button's global rect) and is ignored elsewhere.
  Future<void> shareVideo(String path, {String? text, Rect? origin}) async {
    await Share.shareXFiles(
      <XFile>[XFile(path)],
      text: text ?? 'Made with Cinemory',
      sharePositionOrigin: origin,
    );
  }

  /// Save a local video [path] into the device photo gallery.
  Future<void> saveToGallery(String path) async {
    final bool hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }
    await Gal.putVideo(path, album: 'Cinemory');
  }

  void dispose() => _client.close();
}
