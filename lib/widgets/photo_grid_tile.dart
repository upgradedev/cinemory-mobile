import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/picked_photo.dart';
import '../theme.dart';

/// One selectable photo in the picker grid. Loads its thumbnail lazily.
class PhotoGridTile extends StatelessWidget {
  const PhotoGridTile({
    super.key,
    required this.photo,
    required this.selected,
    required this.onTap,
  });

  final PickablePhoto photo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FutureBuilder<Uint8List?>(
            future: photo.thumbnail(),
            builder: (BuildContext context, AsyncSnapshot<Uint8List?> snap) {
              final Uint8List? bytes = snap.data;
              if (bytes == null) {
                return Container(color: CinemoryTheme.surface);
              }
              return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
            },
          ),
          if (selected)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CinemoryTheme.gold, width: 3),
                color: Colors.black26,
              ),
              child: const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.check_circle,
                      color: CinemoryTheme.gold, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
