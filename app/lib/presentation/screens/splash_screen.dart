import 'package:flutter/material.dart';

import '../../core/theme/shoku_theme.dart';
import '../widgets/kit/plate_mark.dart';

/// The first frame: the mark, on paper, while the session opens behind it.
///
/// It is a route, not a second MaterialApp: the app is one router from the
/// first frame, and the gate redirects here until auth has an answer.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.canvas,
      body: const Center(child: PlateMark(size: 64)),
    );
  }
}
