import 'package:flutter/foundation.dart';

import '../models/occasion.dart';
import '../models/picked_photo.dart';
import '../models/reel.dart';
import '../services/cinemory_api.dart';
import '../services/photo_service.dart';

/// The steps of the create-and-share flow.
enum CinemoryStep { intro, gallery, occasion, generating, preview }

/// Central app state — drives the whole pick → occasion → generate → preview
/// flow. Injects [CinemoryApi] and [PhotoGallery] so it is fully unit testable
/// with fakes (no platform channels, no network).
class AppState extends ChangeNotifier {
  AppState({required CinemoryApi api, required PhotoGallery gallery})
      : _api = api,
        _gallery = gallery;

  final CinemoryApi _api;
  final PhotoGallery _gallery;

  CinemoryStep _step = CinemoryStep.intro;
  CinemoryStep get step => _step;

  List<Occasion> _occasions = Occasion.fallback;
  List<Occasion> get occasions => _occasions;

  Occasion? _selectedOccasion;
  Occasion? get selectedOccasion => _selectedOccasion;

  PhotoPermission? _permission;
  PhotoPermission? get permission => _permission;

  List<PickablePhoto> _photos = <PickablePhoto>[];
  List<PickablePhoto> get photos => _photos;

  final Set<String> _selectedIds = <String>{};
  Set<String> get selectedIds => Set<String>.unmodifiable(_selectedIds);
  int get selectionCount => _selectedIds.length;
  bool isSelected(String id) => _selectedIds.contains(id);

  bool _busy = false;
  bool get busy => _busy;

  String? _error;
  String? get error => _error;

  Reel? _reel;
  Reel? get reel => _reel;

  bool get canGenerate =>
      _selectedIds.isNotEmpty && _selectedOccasion != null && !_busy;

  /// Load the occasion catalogue from the API, falling back to the built-ins.
  Future<void> loadOccasions() async {
    try {
      _occasions = await _api.getOccasions();
    } catch (_) {
      _occasions = Occasion.fallback;
    }
    notifyListeners();
  }

  /// Ask for photo-library access and, if granted, load recent photos.
  Future<void> startPhotoAccess() async {
    _setBusy(true);
    _error = null;
    try {
      _permission = await _gallery.ensurePermission();
      if (_permission!.canAccess) {
        _photos = await _gallery.recentPhotos(limit: 100);
        _step = CinemoryStep.gallery;
      } else {
        _error = 'Cinemory needs access to your photos to build a reel.';
      }
    } catch (e) {
      _error = 'Could not open your photo library: $e';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> openPhotoSettings() => _gallery.openSettings();

  void toggleSelect(String id) {
    if (!_selectedIds.remove(id)) {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void goToOccasionStep() {
    if (_selectedIds.isEmpty) return;
    _step = CinemoryStep.occasion;
    notifyListeners();
  }

  void selectOccasion(Occasion occasion) {
    _selectedOccasion = occasion;
    notifyListeners();
  }

  /// Build the reel via the Cinemory API from the current selection.
  Future<void> generate() async {
    if (!canGenerate) return;
    _setBusy(true);
    _error = null;
    _step = CinemoryStep.generating;
    notifyListeners();
    try {
      final ReelRequest request = ReelRequest.fromSelection(
        occasion: _selectedOccasion!.key,
        photoCount: _selectedIds.length,
      );
      _reel = await _api.createReel(request);
      _step = CinemoryStep.preview;
    } catch (e) {
      _error = 'Reel generation failed: $e';
      _step = CinemoryStep.occasion;
    } finally {
      _setBusy(false);
    }
  }

  /// Return to the start for another reel (keeps loaded photos + occasions).
  void reset() {
    _selectedIds.clear();
    _selectedOccasion = null;
    _reel = null;
    _error = null;
    _step = _photos.isEmpty ? CinemoryStep.intro : CinemoryStep.gallery;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
