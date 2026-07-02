import 'dart:convert';

import 'package:cinemory_mobile/services/cinemory_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A CinemoryApi backed by an in-memory MockClient — shared across widget and
/// state tests so nothing touches the network.
CinemoryApi fakeApi() {
  final MockClient client = MockClient((http.Request req) async {
    if (req.url.path == '/occasions') {
      return http.Response(
          jsonEncode(<String, dynamic>{'occasions': <dynamic>[]}), 200);
    }
    if (req.url.path == '/reels') {
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode(<String, dynamic>{
          'reel_name': body['name'],
          'occasion': body['occasion'],
          'reel_url': 'https://cdn/x.mp4',
          'reel_sha256': 'hash',
          'manifest_uri': 'b2://m',
          'manifest_hash': 'mh',
          'steps': 4,
        }),
        200,
      );
    }
    return http.Response('{}', 200);
  });
  return CinemoryApi(baseUrl: 'http://test.local', client: client);
}
