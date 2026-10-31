import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/cook_timer_repository.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/presentation/state/cook_timer_providers.dart';

void main() {
  late AppDatabase db;
  final start = DateTime(2026, 1, 1, 19, 0);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  /// A fresh store is what a relaunched app gets; the database is the only thing
  /// that survives, so every restoration test goes through a new one.
  Future<CookTimerStore> open() async {
    final store = CookTimerStore(CookTimerRepository(db));
    await pumpEventQueue();
    return store;
  }

  test('a timer started before a kill comes back on the same step', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 2,
      duration: const Duration(minutes: 10),
      now: start,
    );

    final after = await open();
    final timer = after.state;

    expect(timer, isNotNull);
    expect(timer!.stepIndex, 2);
    expect(timer.versionId, 'v1');
    expect(timer.dishId, 'd1');
    expect(timer.remainingMsAt(start.add(const Duration(minutes: 4))),
        6 * 60 * 1000);
  });

  test('a pause survives the app being killed', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 10),
      now: start,
    );
    await before.pause(now: start.add(const Duration(minutes: 1)));

    final after = await open();
    expect(after.state!.isPaused, isTrue);
    // Time spent paused is not time spent cooking.
    expect(after.state!.remainingMsAt(start.add(const Duration(minutes: 6))),
        9 * 60 * 1000);
  });

  test('resuming after a kill keeps the paused minutes out of the count',
      () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 10),
      now: start,
    );
    await before.pause(now: start.add(const Duration(minutes: 1)));

    final after = await open();
    await after.resume(now: start.add(const Duration(minutes: 5)));

    expect(after.state!.isPaused, isFalse);
    expect(after.state!.remainingMsAt(start.add(const Duration(minutes: 6))),
        8 * 60 * 1000);
  });

  test('stop clears the row, and a relaunch finds nothing', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 1,
      duration: const Duration(minutes: 3),
      now: start,
    );
    await before.stop();

    expect(before.state, isNull);
    final after = await open();
    expect(after.state, isNull);
  });

  test('a new version drops the timer instead of re-pointing it', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 4,
      duration: const Duration(minutes: 10),
      now: start,
    );

    // Same version: the timer is still about the instruction on screen.
    expect(
      await store.dropIfVersionChanged(dishId: 'd1', versionId: 'v1'),
      isFalse,
    );
    expect(store.state, isNotNull);

    // Another dish's version is not this timer's business.
    expect(
      await store.dropIfVersionChanged(dishId: 'd2', versionId: 'v9'),
      isFalse,
    );
    expect(store.state, isNotNull);

    // The fork: step 4 now means something else, so the timer goes.
    expect(
      await store.dropIfVersionChanged(dishId: 'd1', versionId: 'v2'),
      isTrue,
    );
    expect(store.state, isNull);
  });

  test('an absurd length is stored as the longest timer we accept', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(days: 40),
      now: start,
    );
    expect(store.state!.duration, CookTimer.maxDuration);

    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: Duration.zero,
      now: start,
    );
    expect(store.state!.duration, CookTimer.minDuration);
  });

  test('starting again replaces the running timer', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 2),
      now: start,
    );
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 3,
      duration: const Duration(minutes: 7),
      now: start,
    );

    expect(store.state!.stepIndex, 3);
    expect(store.state!.remainingMsAt(start), 7 * 60 * 1000);
  });
}
