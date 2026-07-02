import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/occasion.dart';
import '../models/picked_photo.dart';
import '../models/reel.dart';

/// Thrown when the Cinemory API returns a non-2xx response or is unreachable.
class CinemoryApiException implements Exception {
  CinemoryApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'CinemoryApiException($statusCode): $message';
}

/// Typed client for the Cinemory API.
///
/// Endpoints (see `src/cinemory/api.py`):
///   GET  /health           liveness + mode
///   GET  /occasions        selectable occasion presets
///   POST /reels            generate a reel, returns provenance
///   GET  /reels/{name}     stored manifest for a reel
class CinemoryApi {
  CinemoryApi({required String baseUrl, http.Client? client})
      : _baseUrl = _normalize(baseUrl),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  static String _normalize(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<bool> health() async {
    try {
      final http.Response res = await _client.get(_uri('/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Occasion>> getOccasions() async {
    final http.Response res = await _get('/occasions');
    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    final List<dynamic> raw = (body['occasions'] as List<dynamic>?) ?? const [];
    if (raw.isEmpty) return Occasion.fallback;
    return raw
        .map((dynamic e) => Occasion.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Reel> createReel(ReelRequest request) async {
    final http.Response res = await _client.post(
      _uri('/reels'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    _ensureOk(res);
    return Reel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getReel(String name) async {
    final http.Response res = await _get('/reels/$name');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Upload the actual on-device photo bytes and generate a reel from them.
  ///
  /// BLOCKED: the current Cinemory API has no multipart photo-ingest endpoint —
  /// `POST /reels` generates from a synthetic spec. This method is the client
  /// seam that is ready the moment the server grows a `POST /reels/upload`
  /// (multipart: N image parts + occasion). Until then it throws so callers
  /// fall back to [createReel]. See README "Known gap: photo upload".
  Future<Reel> uploadPhotosAndGenerate({
    required String occasion,
    required List<PickablePhoto> photos,
    String? name,
  }) async {
    throw UnimplementedError(
      'The Cinemory API does not yet expose a multipart photo-ingest endpoint '
      '(POST /reels/upload). Use createReel() until the server endpoint lands.',
    );
    // Reference implementation once the endpoint exists:
    // final req = http.MultipartRequest('POST', _uri('/reels/upload'))
    //   ..fields['occasion'] = occasion
    //   ..fields['name'] = name ?? '';
    // for (final p in photos) {
    //   final File? f = await p.originFile();
    //   if (f != null) {
    //     req.files.add(await http.MultipartFile.fromPath('photos', f.path));
    //   }
    // }
    // final streamed = await _client.send(req);
    // final res = await http.Response.fromStream(streamed);
    // _ensureOk(res);
    // return Reel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<http.Response> _get(String path) async {
    try {
      final http.Response res = await _client.get(_uri(path));
      _ensureOk(res);
      return res;
    } on SocketException catch (e) {
      throw CinemoryApiException('Network error: ${e.message}');
    }
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw CinemoryApiException(
        'Request failed: ${res.reasonPhrase ?? res.body}',
        statusCode: res.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
