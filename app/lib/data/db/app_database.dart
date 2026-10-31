import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The journal, on disk.
///
/// Column choices come from the sync design:
///   * every id is a client-generated UUID, so rows can be created offline
///   * versions and cooks are append-only — no `updatedAt`, they never change
///   * anything mutable carries `updatedAt` (LWW) and `deletedAt` (tombstone)
///   * `dirty` marks rows the server hasn't seen yet; sync is "select where dirty"
class DishRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  TextColumn get coverUrl => text().withDefault(const Constant(''))();
  TextColumn get sourceHandle => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  IntColumn get minutes => integer().withDefault(const Constant(0))();
  IntColumn get baselineKcal => integer().withDefault(const Constant(0))();
  IntColumn get baselineProtein => integer().withDefault(const Constant(0))();
  TextColumn get steps => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A recipe variant of a dish.
///
/// `originKind` is `mine` or `import`. An import is an immutable snapshot of
/// somebody else's reel — it is never written again, and editing it forks a new
/// `mine` version whose `parentVersionId` points back at it.
class VersionRows extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text().references(DishRows, #id)();

  /// Ordinal *within the user's own lineage*. Imports are identified by their
  /// creator, not by a number, so this stays 0 for imported versions.
  IntColumn get number => integer().withDefault(const Constant(0))();

  TextColumn get changes => text().withDefault(const Constant('[]'))();
  TextColumn get ingredients => text().withDefault(const Constant('[]'))();
  TextColumn get steps => text().withDefault(const Constant('[]'))();
  IntColumn get kcal => integer().withDefault(const Constant(0))();
  IntColumn get protein => integer().withDefault(const Constant(0))();

  TextColumn get originKind => text().withDefault(const Constant('mine'))();
  TextColumn get originCreator => text().nullable()();
  TextColumn get originHandle => text().nullable()();
  TextColumn get originPlatform => text().nullable()();
  TextColumn get originUrl => text().nullable()();
  TextColumn get originShortcode => text().nullable()();
  TextColumn get parentVersionId => text().nullable()();
  IntColumn get extractionVersion => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One night of cooking. Append-only: a cook is a thing that happened.
class CookLogRows extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text().references(DishRows, #id)();
  TextColumn get versionId => text().nullable()();
  IntColumn get versionNumber => integer()();
  DateTimeColumn get cookedAt => dateTime()();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  TextColumn get photoState =>
      text().withDefault(const Constant('none'))(); // none|local|synced
  TextColumn get outcome => text()();
  TextColumn get mood => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get changes => text().withDefault(const Constant('[]'))();
  IntColumn get rating => integer().withDefault(const Constant(3))();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key/value store for database-level facts. The seed marker lives here
/// rather than in SharedPreferences so that wiping the database also resets it —
/// the two can never disagree about whether the demo kitchen exists.
class MetaRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [DishRows, VersionRows, CookLogRows, MetaRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'shoku',
              // On the web the database runs on sqlite3.wasm inside a worker;
              // both files live in `web/` so Chrome behaves like the phone.
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ));

  @override
  int get schemaVersion => 3;

  /// Store timestamps as ISO-8601 text, not unix seconds.
  ///
  /// The default int format truncates to whole seconds, which destroys the
  /// precision last-write-wins needs and makes "newest first" ambiguous for two
  /// cooks in the same second. Changing this later is a full table rebuild.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            // Provenance for imported versions: the creator's handle and the
            // platform, so a dish can link back to the reel it came from.
            await m.addColumn(versionRows, versionRows.originHandle);
            await m.addColumn(versionRows, versionRows.originPlatform);
          }
          if (from < 2) {
            // v1 wrote datetimes as unix seconds, which loses milliseconds and
            // can't be read as ISO-8601 text. The only v1 rows in existence are
            // the reproducible demo seed, so rebuild rather than convert.
            await m.deleteTable('cook_log_rows');
            await m.deleteTable('version_rows');
            await m.deleteTable('dish_rows');
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
