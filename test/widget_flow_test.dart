import 'package:cinemory_mobile/models/occasion.dart';
import 'package:cinemory_mobile/screens/home_screen.dart';
import 'package:cinemory_mobile/state/app_state.dart';
import 'package:cinemory_mobile/theme.dart';
import 'package:cinemory_mobile/widgets/occasion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'app_state_test.dart' show FakeGallery;
import 'cinemory_api_test_helpers.dart';

void main() {
  testWidgets('OccasionCard shows its label and music style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CinemoryTheme.dark,
        home: Scaffold(
          body: OccasionCard(
            occasion: Occasion.fallback.first,
            selected: false,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Anniversary'), findsOneWidget);
    expect(find.textContaining('warm romantic strings'), findsOneWidget);
  });

  testWidgets('intro -> tap Choose photos -> gallery step renders',
      (tester) async {
    final AppState state = AppState(api: fakeApi(), gallery: FakeGallery(count: 3));
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Choose photos'), findsOneWidget); // intro button
    await tester.tap(find.text('Choose photos'));
    await tester.pumpAndSettle();

    // Now on the gallery step: the selection counter is visible.
    expect(find.textContaining('selected'), findsOneWidget);
  });
}
