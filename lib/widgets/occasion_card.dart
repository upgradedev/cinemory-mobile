import 'package:flutter/material.dart';

import '../models/occasion.dart';
import '../theme.dart';

/// A selectable occasion template card.
class OccasionCard extends StatelessWidget {
  const OccasionCard({
    super.key,
    required this.occasion,
    required this.selected,
    required this.onTap,
  });

  final Occasion occasion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CinemoryTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? CinemoryTheme.gold : Colors.white12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected ? Icons.movie_filter : Icons.movie_outlined,
              color: selected ? CinemoryTheme.gold : Colors.white54,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(occasion.label, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${occasion.musicStyle} · ${occasion.aspectRatio}',
                    style: text.bodySmall?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
