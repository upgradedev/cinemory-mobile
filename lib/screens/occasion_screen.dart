import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/occasion.dart';
import '../state/app_state.dart';
import '../widgets/occasion_card.dart';

/// Step 2: choose the occasion template that shapes the reel.
class OccasionScreen extends StatelessWidget {
  const OccasionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an occasion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => state.reset(),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.occasions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int i) {
                final Occasion occasion = state.occasions[i];
                return OccasionCard(
                  occasion: occasion,
                  selected: state.selectedOccasion?.key == occasion.key,
                  onTap: () => state.selectOccasion(occasion),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.canGenerate ? () => state.generate() : null,
        backgroundColor: state.canGenerate ? null : Colors.grey,
        label: const Text('Generate reel'),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
