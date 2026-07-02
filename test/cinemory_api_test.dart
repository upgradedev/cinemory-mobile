import 'dart:convert';

import 'package:cinemory_mobile/models/reel.dart';
import 'package:cinemory_mobile/services/cinemory_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CinemoryApi', () {
    test('getOccasions parses the /occasions envelope', () async {
      final MockClient client = MockClient((http.Request req) async {
        expect(req.url.path, '/occasions');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'occasions': <dynamic>[
              <String, dynamic>{'key': 'wedding', 'label': 'Wedding'},
              <String, dynamic>{'key': 'birthday', 'label': 'Birthday'},
            ],
          }),
          200,
        );
      });
      final CinemoryApi api =
          CinemoryApi(baseUrl: 'http://test.local/', client: client);
      final result = await api.getOccasions();
      expect(result.length, 2);
      expect(result.first.key, 'wedding');
    });

    test('getOccasions falls back to built-ins on an empty list', () async {
      final MockClient client = MockClient((http.Request req) async =>
          http.Response(jsonEncode(<String, dynamic>{'occasions': <dynamic>[]}), 200));
      final CinemoryApi api =
          CinemoryApi(baseUrl: 'http://test.local', client: client);
      expect((await api.getOccasions()).length, 6);
    });

    test('createReel posts the request and parses the reel', () async {
      final MockClient client = MockClient((http.Request req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/reels');
        final Map<String, dynamic> body =
            jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['occasion'], 'wedding');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'reel_name': body['name'],
            'occasion': body['occasion'],
            'reel_url': 'https://cdn/x.mp4',
            'reel_sha256': 'hash',
            'manifest_uri': 'b2://m',
            'manifest_hash': 'mh',
            'steps': 5,
          }),
          200,
        );
      });
      final CinemoryApi api =
          CinemoryApi(baseUrl: 'http://test.local', client: client);
      final Reel reel = await api.createReel(
        ReelRequest.fromSelection(occasion: 'wedding', photoCount: 4, name: 'r1'),
      );
      expect(reel.reelName, 'r1');
      expect(reel.steps, 5);
    });

    test('throws CinemoryApiException on a non-2xx response', () async {
      final MockClient client = MockClient(
          (http.Request req) async => http.Response('boom', 500));
      final CinemoryApi api =
          CinemoryApi(baseUrl: 'http://test.local', client: client);
      expect(
        () => api.createReel(
            ReelRequest.fromSelection(occasion: 'x', photoCount: 1)),
        throwsA(isA<CinemoryApiException>()),
      );
    });

    test('uploadPhotosAndGenerate is not wired yet (server gap)', () async {
      final api = CinemoryApi(
          baseUrl: 'http://test.local', client: MockClient((_) async => http.Response('', 200)));
      expect(
        () => api.uploadPhotosAndGenerate(occasion: 'wedding', photos: const []),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
