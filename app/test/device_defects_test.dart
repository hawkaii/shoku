import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/feed_service.dart';
import 'package:food_finder/presentation/screens/journal/journal_screen.dart';
import 'package:food_finder/presentation/screens/wall/wall_screen.dart';
import 'package:food_finder/presentation/state/feed_providers.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/widgets/kit/dish_image.dart';
import 'package:food_finder/presentation/widgets/kit/photo.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An image that arrives after [delay], so a deadline can be tested without
/// waiting eight real seconds.
class _SlowImage extends ImageProvider<_SlowImage> {
  _SlowImage(this.delay, this.image);

  final Duration delay;
  final ui.Image image;

  @override
  Future<_SlowImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_SlowImage>(this);

  @override
  ImageStreamCompleter loadImage(_SlowImage key, ImageDecoderCallback decode) {
    final completer = Completer<ImageInfo>();
    Future<void>.delayed(delay, () {
      if (!completer.isCompleted) completer.complete(ImageInfo(image: image));
    });
    return OneFrameImageStreamCompleter(completer.future);
  }
}

Widget _app(Widget child) => MaterialApp(
      theme: ShokuTheme.light(),
      home: Scaffold(
          body: Center(child: SizedBox(width: 84, height: 84, child: child))),
    );

String _feed({bool hasMore = false, int items = 1}) => jsonEncode({
      'items': [
        for (var i = 0; i < items; i++)
          {
            'shortcode': 'SC$i',
            'title': 'Paneer Tikka',
            'thumbnail_url': '',
            'creator': 'Ravi',
            'creator_handle': '@ravi',
            'platform': 'instagram',
            'steps': ['Fry'],
            'tags': ['paneer'],
            'url': 'https://instagram.com/reel/SC$i/',
          },
      ],
      'cursor': null,
      'has_more': hasMore,
    });

void main() {
  group('§12.1 the image slot', () {
    testWidgets('a slot with no photo is its monogram, never grey',
        (tester) async {
      await tester
          .pumpWidget(_app(const ShokuDishImage(url: '', title: 'Paneer')));

      expect(find.text('P'), findsOneWidget);
      // No bare grey state exists: the well is a gradient, not a flat fill.
      final context = tester.element(find.text('P'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == context.colors.surfaceAlt,
        ),
        findsNothing,
      );
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('a photo that fails is the monogram, immediately',
        (tester) async {
      await tester.pumpWidget(_app(const ShokuDishImage(
        url: 'https://example.invalid/paneer.jpg',
        title: 'Paneer',
      )));
      // The test HTTP client refuses the request.
      await tester.pumpAndSettle();

      expect(find.text('P'), findsOneWidget);
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('a deleted local file is a failed image, not a grey box',
        (tester) async {
      await tester.pumpWidget(_app(const ShokuDishImage(
        url: '/tmp/shoku-no-such-file.jpg',
        title: 'Paneer',
      )));
      await tester.pumpAndSettle();

      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('a photo that misses the deadline never appears',
        (tester) async {
      final photo = (await tester.runAsync(
        () => createTestImage(width: 4, height: 4),
      ))!;
      await tester.pumpWidget(_app(
        ShokuPhoto(
          provider: _SlowImage(const Duration(milliseconds: 60), photo),
          deadline: const Duration(milliseconds: 10),
        ),
      ));

      // The deadline passes at 10 ms; the photo would have arrived at 60 ms.
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(RawImage), findsNothing,
          reason: 'expired is final, and it is the monogram underneath');
    });

    testWidgets('a photo that beats the deadline fades in', (tester) async {
      final photo = (await tester.runAsync(
        () => createTestImage(width: 4, height: 4),
      ))!;
      await tester.pumpWidget(_app(
        ShokuPhoto(
          provider: _SlowImage(const Duration(milliseconds: 60), photo),
          deadline: const Duration(seconds: 20),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // The control case: proof the deadline is what hides the other one.
      expect(find.byType(RawImage), findsOneWidget);
    });
  });

  group('§12.2 the Wall header', () {
    Widget wall(http.Client client) => ProviderScope(
          overrides: [
            feedServiceProvider.overrideWithValue(FeedService(
              api: ApiClient(
                baseUrl: 'https://api.test',
                tokenProvider: () => 'jwt',
                httpClient: client,
              ),
            )),
          ],
          child: MaterialApp(
            theme: ShokuTheme.light(),
            home: const Scaffold(body: WallScreen()),
          ),
        );

    testWidgets('no chip repeats what the subtitle already says',
        (tester) async {
      final client = MockClient((_) async => http.Response(_feed(), 200));
      await tester.pumpWidget(wall(client));
      await tester.pumpAndSettle();

      expect(find.text('SHARED'), findsNothing);
      expect(find.text('shared'), findsNothing);
      expect(find.text('1 reel'), findsOneWidget);
    });

    testWidgets('the footer does not invent a daily cadence', (tester) async {
      final client = MockClient((_) async => http.Response(_feed(), 200));
      await tester.pumpWidget(wall(client));
      await tester.pumpAndSettle();

      expect(find.text('That is every reel for now'), findsOneWidget);
      expect(find.text('That is everything shared today'), findsNothing);
    });
  });

  group('§12.3 tab-bar clearance', () {
    Dish dish() => Dish(
          id: 'd1',
          title: 'Paneer',
          subtitle: '',
          coverUrl: '',
          sourceHandle: '@ravi',
          status: DishStatus.toCook,
          minutes: 20,
          steps: const ['Fry'],
          versions: [
            RecipeVersion(
              id: 'v1',
              number: 1,
              changes: const [],
              ingredients: const ['paneer'],
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
          cooks: const [],
        );

    testWidgets('the empty cook-log card sits fully above the bar',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          dishesProvider.overrideWithValue([dish()])
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: JournalScreen()),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Your first page'), findsOneWidget);

      // The bar is 64 plus the 34 px gesture inset; nothing may hide behind it.
      const barTop = 800 - (64 + 34);
      final cardBottom = tester.getRect(find.text('Your first page')).bottom;
      expect(cardBottom, lessThan(barTop),
          reason: 'the card is the only thing on screen, so it may not clip');
    });

    testWidgets('with no inset the card still clears the bar', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = FakeViewPadding.zero;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          dishesProvider.overrideWithValue([dish()])
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: JournalScreen()),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      const barTop = 844 - 64;
      expect(tester.getRect(find.text('Your first page')).bottom,
          lessThan(barTop));
    });
  });
}
