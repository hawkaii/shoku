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

  /// Per-step ingredient indices, JSON. Empty means the parse predates the link.
  ///
  /// Local only: this is not on the sync wire, so a version that arrives from
  /// another device simply has none and renders no ingredient line.
  TextColumn get stepIngredients => text().withDefault(const Constant(''))();

  /// The extraction's tags, JSON. On the wire: the server stores what we send.
  TextColumn get tags => text().withDefault(const Constant('[]'))();

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

  /// The object key the API owns, for the sync wire. `photoUrl` is for display.
  TextColumn get photoKey => text().withDefault(const Constant(''))();
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

/// The kitchen timer, on disk.
///
/// One row, device-local. It carries no `dirty` flag on purpose: a timer running
/// on this phone means nothing to another device or to a server, so it never
/// enters the sync wire.
class CookTimerRows extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get versionId => text()();
  IntColumn get stepIndex => integer()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMs => integer()();
  IntColumn get pausedMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get pausedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The pantry: what is in the kitchen, not what a recipe says.
///
/// The only *mutable* synced list. Union by id, last-write-wins on [updatedAt],
/// tombstones for deletes. Recipe ingredients stay verbatim; this is the
/// confirmed layer beside them.
class PantryRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Null means "have it, amount unknown" — which never counts when deducting.
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();

  /// User-confirmed strings that join a receipt line to this item. JSON list.
  TextColumn get aliases => text().withDefault(const Constant('[]'))();
  IntColumn get wanted => integer().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The recipe chat, on this device only.
///
/// The server is stateless by design: it answers one question against one
/// version and forgets. What was said is the cook's own memory, so it lives
/// here and never enters the sync wire — no `dirty`, no `updatedAt`.
class AssistantTurnRows extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text().nullable()();

  /// `kitchen` or `dish`. The kitchen thread has no dish; a dish thread is one
  /// per dish. Two scopes, two threads, and they never mix.
  TextColumn get scope => text().withDefault(const Constant('dish'))();
  TextColumn get versionId => text().nullable()();

  /// `user` or `assistant`.
  TextColumn get role => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();

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

@DriftDatabase(tables: [
  DishRows,
  VersionRows,
  CookLogRows,
  CookTimerRows,
  PantryRows,
  AssistantTurnRows,
  MetaRows,
])
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
  int get schemaVersion => 10;

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
          if (from < 2) {
            // v1 wrote datetimes as unix seconds, which loses milliseconds and
            // can't be read as ISO-8601 text. The only v1 rows in existence are
            // the reproducible demo seed, so rebuild rather than convert.
            // `createAll` also creates the tables added since.
            await m.deleteTable('cook_log_rows');
            await m.deleteTable('version_rows');
            await m.deleteTable('dish_rows');
            await m.createAll();
            return;
          }
          if (from < 3) {
            // Provenance for imported versions: the creator's handle and the
            // platform, so a dish can link back to the reel it came from.
            await m.addColumn(versionRows, versionRows.originHandle);
            await m.addColumn(versionRows, versionRows.originPlatform);
          }
          if (from < 4) {
            // The kitchen timer, so a cook survives the app being killed.
            await m.createTable(cookTimerRows);
          }
          if (from < 5) {
            // Which ingredients each step uses, for the imported version only.
            await m.addColumn(versionRows, versionRows.stepIngredients);
          }
          if (from < 6) {
            // The extraction's tags, so a silent reel can say its amounts were
            // guesses — and so the server stores what only we can send.
            await m.addColumn(versionRows, versionRows.tags);
          }
          if (from < 7) {
            // The photo's object key, so a debrief photo travels on the wire
            // while `photo_url` keeps serving the picture to the UI.
            await m.addColumn(cookLogRows, cookLogRows.photoKey);
          }
          if (from < 8) {
            // The pantry, the fifth synced list and the only mutable one.
            await m.createTable(pantryRows);
          }
          if (from < 9) {
            // The recipe chat, local only: the server keeps no thread. Created
            // at today's shape, so a database older than v9 needs no second
            // step to gain the scope column.
            await m.createTable(assistantTurnRows);
          } else if (from < 10) {
            // One assistant, two kinds of thread: the kitchen's and each
            // dish's. Existing rows were dish chats.
            await m.addColumn(assistantTurnRows, assistantTurnRows.scope);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
