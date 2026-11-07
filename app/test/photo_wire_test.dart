import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/sync/sync_repository.dart';

/// A cook's photo is either public or absent. A camera path belongs to one
/// phone, and a production pull carried `/data/user/0/.../scaled_42473.jpg` all
/// the way into the server — where every other device, and this phone after a
/// reinstall, points at a file that is not there.
void main() {
  late AppDatabase db;
  late SyncRepository sync;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sync = SyncRepository(db, JournalRepository(db));
    await db.into(db.dishRows).insert(DishRowsCompanion.insert(
          id: 'd1',
          title: 'Paneer',
          status: 'cooked',
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ));
  });

  tearDown(() async => db.close());

  var seq = 0;

  Future<String> pushedPhotoUrl(String photoUrl) async {
    await db.into(db.cookLogRows).insert(CookLogRowsCompanion.insert(
          id: 'c${++seq}',
          dishId: 'd1',
          versionNumber: 1,
          cookedAt: DateTime(2026, 11, 2),
          photoUrl: Value(photoUrl),
          outcome: 'good',
          mood: 'happy',
        ));
    final payload = await sync.dirtyPayload();
    return (payload['cook_logs'] as List).last['photo_url'] as String;
  }

  test('a camera path never leaves the phone', () async {
    expect(
      await pushedPhotoUrl(
          '/data/user/0/com.foodfinder.food_finder/cache/x.jpg'),
      '',
    );
    expect(await pushedPhotoUrl('file:///tmp/x.jpg'), '');
  });

  test('a real URL is sent as it is', () async {
    expect(
      await pushedPhotoUrl('https://storage.googleapis.com/shoku/x.jpg'),
      'https://storage.googleapis.com/shoku/x.jpg',
    );
  });
}
