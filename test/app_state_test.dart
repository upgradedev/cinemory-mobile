import 'dart:convert';

import 'package:cinemory_mobile/models/occasion.dart';
import 'package:cinemory_mobile/models/picked_photo.dart';
import 'package:cinemory_mobile/services/cinemory_api.dart';
import 'package:cinemory_mobile/services/photo_service.dart';
import 'package:cinemory_mobile/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// In-memory gallery for tests — never touches platform channels.
class FakeGallery implements PhotoGallery {
  FakeGallery({this.permission = PhotoPermission.authorized, this.count = 3});
  final PhotoPermission permission;
  final int count;
  bool settingsOpened = false;

  @override
  Future<PhotoPermission> ensurePermission() async => permission;

  @override
  Future<List<PickablePhoto>> recentPhotos({int limit = 100}) async {
    return List<PickablePhoto>.generate(
      count,
      (int i) => PickablePhoto(
        id: 'photo-$i',
        width: 100,
        height: 100,
        thumbnailLoader: () async => null,
        fileLoader: () async => null,
      ),
    );
  }

  @override
  Future<void> openSettings() async => settingsOpened = true;
}

CinemoryApi _api({int reelStatus = 200}) {
  final MockClient client = MockClient((http.Request req) async {
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
        reelStatus,
      );
    }
    return http.Response('{}', 200);
  });
  return CinemoryApi(baseUrl: 'http://test.local', client: client);
}

void main() {
  group('AppState flow', () {
    test('grants access and loads photos', () async {
      final AppState state =
          AppState(api: _api(), gallery: FakeGallery(count: 3));
      await state.startPhotoAccess();
      expect(state.permission, PhotoPermission.authorized);
      expect(state.photos.length, 3);
      expect(state.step, CinemoryStep.gallery);
      expect(state.error, isNull);
    });

    test('denied access surfaces an error and stays on intro', () async {
      final AppState state = AppState(
        api: _api(),
        gallery: FakeGallery(permission: PhotoPermission.denied),
      );
      await state.startPhotoAccess();
      expect(state.step, CinemoryStep.intro);
      expect(state.error, isNotNull);
    });

    test('selection and occasion gate the generate button', () async {
      final AppState state = AppState(api: _api(), gallery: FakeGallery());
      await state.startPhotoAccess();
      expect(state.canGenerate, isFalse);
      state.toggleSelect('photo-0');
      expect(state.canGenerate, isFalse); // no occasion yet
      state.selectOccasion(Occasion.fallback.first);
      expect(state.canGenerate, isTrue);
      state.toggleSelect('photo-0'); // deselect
      expect(state.canGenerate, isFalse);
    });

    test('generate produces a reel and advances to preview', () async {
      final AppState state = AppState(api: _api(), gallery: FakeGallery());
      await state.startPhotoAccess();
      state.toggleSelect('photo-0');
      state.toggleSelect('photo-1');
      state.selectOccasion(Occasion.fallback.first);
      await state.generate();
      expect(state.reel, isNotNull);
      expect(state.reel!.steps, 4);
      expect(state.step, CinemoryStep.preview);
    });

    test('generation failure returns to occasion step with an error', () async {
      final AppState state =
          AppState(api: _api(reelStatus: 500), gallery: FakeGallery());
      await state.startPhotoAccess();
      state.toggleSelect('photo-0');
      state.selectOccasion(Occasion.fallback.first);
      await state.generate();
      expect(state.reel, isNull);
      expect(state.step, CinemoryStep.occasion);
      expect(state.error, isNotNull);
    });

    test('reset clears the selection but keeps photos', () async {
      final AppState state = AppState(api: _api(), gallery: FakeGallery());
      await state.startPhotoAccess();
      state.toggleSelect('photo-0');
      state.selectOccasion(Occasion.fallback.first);
      state.reset();
      expect(state.selectionCount, 0);
      expect(state.selectedOccasion, isNull);
      expect(state.step, CinemoryStep.gallery); // photos still loaded
    });
  });
}
