import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'services/cinemory_api.dart';
import 'services/photo_service.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CinemoryApp());
}

/// Root widget. Wires the production services into [AppState] and provides it
/// to the tree. Tests build [HomeScreen] with their own provider + fakes.
class CinemoryApp extends StatelessWidget {
  const CinemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(
        api: CinemoryApi(baseUrl: AppConfig.apiBaseUrl),
        gallery: const PhotoManagerGallery(),
      )..loadOccasions(),
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: CinemoryTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
