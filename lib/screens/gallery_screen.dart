import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/picked_photo.dart';
import '../state/app_state.dart';
import '../widgets/photo_grid_tile.dart';

/// Step 1: pick photos from the on-device library.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose photos'),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${state.selectionCount} selected'),
            ),
          ),
        ],
      ),
      body: state.photos.isEmpty
          ? const Center(child: Text('No photos found in your library.'))
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: state.photos.length,
              itemBuilder: (BuildContext context, int i) {
                final PickablePhoto photo = state.photos[i];
                return PhotoGridTile(
                  photo: photo,
                  selected: state.isSelected(photo.id),
                  onTap: () => state.toggleSelect(photo.id),
                );
              },
            ),
      floatingActionButton: state.selectionCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => state.goToOccasionStep(),
              label: const Text('Next: occasion'),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}
