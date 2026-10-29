import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/navigation/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FoodFinderApp(),
    ),
  );
}

class FoodFinderApp extends StatelessWidget {
  const FoodFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SpaceGrotesk',
      ),
      routerConfig: appRouter,
    );
  }
}
