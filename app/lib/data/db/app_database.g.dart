// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DishRowsTable extends DishRows with TableInfo<$DishRowsTable, DishRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceHandleMeta =
      const VerificationMeta('sourceHandle');
  @override
  late final GeneratedColumn<String> sourceHandle = GeneratedColumn<String>(
      'source_handle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _minutesMeta =
      const VerificationMeta('minutes');
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
      'minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baselineKcalMeta =
      const VerificationMeta('baselineKcal');
  @override
  late final GeneratedColumn<int> baselineKcal = GeneratedColumn<int>(
      'baseline_kcal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baselineProteinMeta =
      const VerificationMeta('baselineProtein');
  @override
  late final GeneratedColumn<int> baselineProtein = GeneratedColumn<int>(
      'baseline_protein', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
      'steps', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
      'dirty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        subtitle,
        coverUrl,
        sourceHandle,
        status,
        minutes,
        baselineKcal,
        baselineProtein,
        steps,
        createdAt,
        updatedAt,
        deletedAt,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dish_rows';
  @override
  VerificationContext validateIntegrity(Insertable<DishRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('source_handle')) {
      context.handle(
          _sourceHandleMeta,
          sourceHandle.isAcceptableOrUnknown(
              data['source_handle']!, _sourceHandleMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(_minutesMeta,
          minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta));
    }
    if (data.containsKey('baseline_kcal')) {
      context.handle(
          _baselineKcalMeta,
          baselineKcal.isAcceptableOrUnknown(
              data['baseline_kcal']!, _baselineKcalMeta));
    }
    if (data.containsKey('baseline_protein')) {
      context.handle(
          _baselineProteinMeta,
          baselineProtein.isAcceptableOrUnknown(
              data['baseline_protein']!, _baselineProteinMeta));
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DishRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DishRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle'])!,
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url'])!,
      sourceHandle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_handle'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      minutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes'])!,
      baselineKcal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baseline_kcal'])!,
      baselineProtein: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baseline_protein'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steps'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $DishRowsTable createAlias(String alias) {
    return $DishRowsTable(attachedDatabase, alias);
  }
}

class DishRow extends DataClass implements Insertable<DishRow> {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final String sourceHandle;
  final String status;
  final int minutes;
  final int baselineKcal;
  final int baselineProtein;
  final String steps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int dirty;
  const DishRow(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.coverUrl,
      required this.sourceHandle,
      required this.status,
      required this.minutes,
      required this.baselineKcal,
      required this.baselineProtein,
      required this.steps,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['cover_url'] = Variable<String>(coverUrl);
    map['source_handle'] = Variable<String>(sourceHandle);
    map['status'] = Variable<String>(status);
    map['minutes'] = Variable<int>(minutes);
    map['baseline_kcal'] = Variable<int>(baselineKcal);
    map['baseline_protein'] = Variable<int>(baselineProtein);
    map['steps'] = Variable<String>(steps);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  DishRowsCompanion toCompanion(bool nullToAbsent) {
    return DishRowsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      coverUrl: Value(coverUrl),
      sourceHandle: Value(sourceHandle),
      status: Value(status),
      minutes: Value(minutes),
      baselineKcal: Value(baselineKcal),
      baselineProtein: Value(baselineProtein),
      steps: Value(steps),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
    );
  }

  factory DishRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DishRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      sourceHandle: serializer.fromJson<String>(json['sourceHandle']),
      status: serializer.fromJson<String>(json['status']),
      minutes: serializer.fromJson<int>(json['minutes']),
      baselineKcal: serializer.fromJson<int>(json['baselineKcal']),
      baselineProtein: serializer.fromJson<int>(json['baselineProtein']),
      steps: serializer.fromJson<String>(json['steps']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'sourceHandle': serializer.toJson<String>(sourceHandle),
      'status': serializer.toJson<String>(status),
      'minutes': serializer.toJson<int>(minutes),
      'baselineKcal': serializer.toJson<int>(baselineKcal),
      'baselineProtein': serializer.toJson<int>(baselineProtein),
      'steps': serializer.toJson<String>(steps),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  DishRow copyWith(
          {String? id,
          String? title,
          String? subtitle,
          String? coverUrl,
          String? sourceHandle,
          String? status,
          int? minutes,
          int? baselineKcal,
          int? baselineProtein,
          String? steps,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? dirty}) =>
      DishRow(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        coverUrl: coverUrl ?? this.coverUrl,
        sourceHandle: sourceHandle ?? this.sourceHandle,
        status: status ?? this.status,
        minutes: minutes ?? this.minutes,
        baselineKcal: baselineKcal ?? this.baselineKcal,
        baselineProtein: baselineProtein ?? this.baselineProtein,
        steps: steps ?? this.steps,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        dirty: dirty ?? this.dirty,
      );
  DishRow copyWithCompanion(DishRowsCompanion data) {
    return DishRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      sourceHandle: data.sourceHandle.present
          ? data.sourceHandle.value
          : this.sourceHandle,
      status: data.status.present ? data.status.value : this.status,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      baselineKcal: data.baselineKcal.present
          ? data.baselineKcal.value
          : this.baselineKcal,
      baselineProtein: data.baselineProtein.present
          ? data.baselineProtein.value
          : this.baselineProtein,
      steps: data.steps.present ? data.steps.value : this.steps,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('sourceHandle: $sourceHandle, ')
          ..write('status: $status, ')
          ..write('minutes: $minutes, ')
          ..write('baselineKcal: $baselineKcal, ')
          ..write('baselineProtein: $baselineProtein, ')
          ..write('steps: $steps, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      subtitle,
      coverUrl,
      sourceHandle,
      status,
      minutes,
      baselineKcal,
      baselineProtein,
      steps,
      createdAt,
      updatedAt,
      deletedAt,
      dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.coverUrl == this.coverUrl &&
          other.sourceHandle == this.sourceHandle &&
          other.status == this.status &&
          other.minutes == this.minutes &&
          other.baselineKcal == this.baselineKcal &&
          other.baselineProtein == this.baselineProtein &&
          other.steps == this.steps &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty);
}

class DishRowsCompanion extends UpdateCompanion<DishRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> coverUrl;
  final Value<String> sourceHandle;
  final Value<String> status;
  final Value<int> minutes;
  final Value<int> baselineKcal;
  final Value<int> baselineProtein;
  final Value<String> steps;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> dirty;
  final Value<int> rowid;
  const DishRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.sourceHandle = const Value.absent(),
    this.status = const Value.absent(),
    this.minutes = const Value.absent(),
    this.baselineKcal = const Value.absent(),
    this.baselineProtein = const Value.absent(),
    this.steps = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishRowsCompanion.insert({
    required String id,
    required String title,
    this.subtitle = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.sourceHandle = const Value.absent(),
    required String status,
    this.minutes = const Value.absent(),
    this.baselineKcal = const Value.absent(),
    this.baselineProtein = const Value.absent(),
    this.steps = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DishRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? coverUrl,
    Expression<String>? sourceHandle,
    Expression<String>? status,
    Expression<int>? minutes,
    Expression<int>? baselineKcal,
    Expression<int>? baselineProtein,
    Expression<String>? steps,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (sourceHandle != null) 'source_handle': sourceHandle,
      if (status != null) 'status': status,
      if (minutes != null) 'minutes': minutes,
      if (baselineKcal != null) 'baseline_kcal': baselineKcal,
      if (baselineProtein != null) 'baseline_protein': baselineProtein,
      if (steps != null) 'steps': steps,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? subtitle,
      Value<String>? coverUrl,
      Value<String>? sourceHandle,
      Value<String>? status,
      Value<int>? minutes,
      Value<int>? baselineKcal,
      Value<int>? baselineProtein,
      Value<String>? steps,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? dirty,
      Value<int>? rowid}) {
    return DishRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceHandle: sourceHandle ?? this.sourceHandle,
      status: status ?? this.status,
      minutes: minutes ?? this.minutes,
      baselineKcal: baselineKcal ?? this.baselineKcal,
      baselineProtein: baselineProtein ?? this.baselineProtein,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (sourceHandle.present) {
      map['source_handle'] = Variable<String>(sourceHandle.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (baselineKcal.present) {
      map['baseline_kcal'] = Variable<int>(baselineKcal.value);
    }
    if (baselineProtein.present) {
      map['baseline_protein'] = Variable<int>(baselineProtein.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('sourceHandle: $sourceHandle, ')
          ..write('status: $status, ')
          ..write('minutes: $minutes, ')
          ..write('baselineKcal: $baselineKcal, ')
          ..write('baselineProtein: $baselineProtein, ')
          ..write('steps: $steps, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VersionRowsTable extends VersionRows
    with TableInfo<$VersionRowsTable, VersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dish_rows (id)'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _changesMeta =
      const VerificationMeta('changes');
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _ingredientsMeta =
      const VerificationMeta('ingredients');
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
      'ingredients', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
      'steps', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
      'kcal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
      'protein', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stepIngredientsMeta =
      const VerificationMeta('stepIngredients');
  @override
  late final GeneratedColumn<String> stepIngredients = GeneratedColumn<String>(
      'step_ingredients', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _originKindMeta =
      const VerificationMeta('originKind');
  @override
  late final GeneratedColumn<String> originKind = GeneratedColumn<String>(
      'origin_kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mine'));
  static const VerificationMeta _originCreatorMeta =
      const VerificationMeta('originCreator');
  @override
  late final GeneratedColumn<String> originCreator = GeneratedColumn<String>(
      'origin_creator', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originHandleMeta =
      const VerificationMeta('originHandle');
  @override
  late final GeneratedColumn<String> originHandle = GeneratedColumn<String>(
      'origin_handle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originPlatformMeta =
      const VerificationMeta('originPlatform');
  @override
  late final GeneratedColumn<String> originPlatform = GeneratedColumn<String>(
      'origin_platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originUrlMeta =
      const VerificationMeta('originUrl');
  @override
  late final GeneratedColumn<String> originUrl = GeneratedColumn<String>(
      'origin_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originShortcodeMeta =
      const VerificationMeta('originShortcode');
  @override
  late final GeneratedColumn<String> originShortcode = GeneratedColumn<String>(
      'origin_shortcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentVersionIdMeta =
      const VerificationMeta('parentVersionId');
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
      'parent_version_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extractionVersionMeta =
      const VerificationMeta('extractionVersion');
  @override
  late final GeneratedColumn<int> extractionVersion = GeneratedColumn<int>(
      'extraction_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
      'dirty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dishId,
        number,
        changes,
        ingredients,
        steps,
        kcal,
        protein,
        stepIngredients,
        tags,
        originKind,
        originCreator,
        originHandle,
        originPlatform,
        originUrl,
        originShortcode,
        parentVersionId,
        extractionVersion,
        createdAt,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'version_rows';
  @override
  VerificationContext validateIntegrity(Insertable<VersionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('changes')) {
      context.handle(_changesMeta,
          changes.isAcceptableOrUnknown(data['changes']!, _changesMeta));
    }
    if (data.containsKey('ingredients')) {
      context.handle(
          _ingredientsMeta,
          ingredients.isAcceptableOrUnknown(
              data['ingredients']!, _ingredientsMeta));
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    }
    if (data.containsKey('step_ingredients')) {
      context.handle(
          _stepIngredientsMeta,
          stepIngredients.isAcceptableOrUnknown(
              data['step_ingredients']!, _stepIngredientsMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('origin_kind')) {
      context.handle(
          _originKindMeta,
          originKind.isAcceptableOrUnknown(
              data['origin_kind']!, _originKindMeta));
    }
    if (data.containsKey('origin_creator')) {
      context.handle(
          _originCreatorMeta,
          originCreator.isAcceptableOrUnknown(
              data['origin_creator']!, _originCreatorMeta));
    }
    if (data.containsKey('origin_handle')) {
      context.handle(
          _originHandleMeta,
          originHandle.isAcceptableOrUnknown(
              data['origin_handle']!, _originHandleMeta));
    }
    if (data.containsKey('origin_platform')) {
      context.handle(
          _originPlatformMeta,
          originPlatform.isAcceptableOrUnknown(
              data['origin_platform']!, _originPlatformMeta));
    }
    if (data.containsKey('origin_url')) {
      context.handle(_originUrlMeta,
          originUrl.isAcceptableOrUnknown(data['origin_url']!, _originUrlMeta));
    }
    if (data.containsKey('origin_shortcode')) {
      context.handle(
          _originShortcodeMeta,
          originShortcode.isAcceptableOrUnknown(
              data['origin_shortcode']!, _originShortcodeMeta));
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
          _parentVersionIdMeta,
          parentVersionId.isAcceptableOrUnknown(
              data['parent_version_id']!, _parentVersionIdMeta));
    }
    if (data.containsKey('extraction_version')) {
      context.handle(
          _extractionVersionMeta,
          extractionVersion.isAcceptableOrUnknown(
              data['extraction_version']!, _extractionVersionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VersionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      changes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes'])!,
      ingredients: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredients'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steps'])!,
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kcal'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}protein'])!,
      stepIngredients: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}step_ingredients'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      originKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_kind'])!,
      originCreator: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_creator']),
      originHandle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_handle']),
      originPlatform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_platform']),
      originUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_url']),
      originShortcode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_shortcode']),
      parentVersionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_version_id']),
      extractionVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}extraction_version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $VersionRowsTable createAlias(String alias) {
    return $VersionRowsTable(attachedDatabase, alias);
  }
}

class VersionRow extends DataClass implements Insertable<VersionRow> {
  final String id;
  final String dishId;

  /// Ordinal *within the user's own lineage*. Imports are identified by their
  /// creator, not by a number, so this stays 0 for imported versions.
  final int number;
  final String changes;
  final String ingredients;
  final String steps;
  final int kcal;
  final int protein;

  /// Per-step ingredient indices, JSON. Empty means the parse predates the link.
  ///
  /// Local only: this is not on the sync wire, so a version that arrives from
  /// another device simply has none and renders no ingredient line.
  final String stepIngredients;

  /// The extraction's tags, JSON. On the wire: the server stores what we send.
  final String tags;
  final String originKind;
  final String? originCreator;
  final String? originHandle;
  final String? originPlatform;
  final String? originUrl;
  final String? originShortcode;
  final String? parentVersionId;
  final int extractionVersion;
  final DateTime createdAt;
  final int dirty;
  const VersionRow(
      {required this.id,
      required this.dishId,
      required this.number,
      required this.changes,
      required this.ingredients,
      required this.steps,
      required this.kcal,
      required this.protein,
      required this.stepIngredients,
      required this.tags,
      required this.originKind,
      this.originCreator,
      this.originHandle,
      this.originPlatform,
      this.originUrl,
      this.originShortcode,
      this.parentVersionId,
      required this.extractionVersion,
      required this.createdAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['number'] = Variable<int>(number);
    map['changes'] = Variable<String>(changes);
    map['ingredients'] = Variable<String>(ingredients);
    map['steps'] = Variable<String>(steps);
    map['kcal'] = Variable<int>(kcal);
    map['protein'] = Variable<int>(protein);
    map['step_ingredients'] = Variable<String>(stepIngredients);
    map['tags'] = Variable<String>(tags);
    map['origin_kind'] = Variable<String>(originKind);
    if (!nullToAbsent || originCreator != null) {
      map['origin_creator'] = Variable<String>(originCreator);
    }
    if (!nullToAbsent || originHandle != null) {
      map['origin_handle'] = Variable<String>(originHandle);
    }
    if (!nullToAbsent || originPlatform != null) {
      map['origin_platform'] = Variable<String>(originPlatform);
    }
    if (!nullToAbsent || originUrl != null) {
      map['origin_url'] = Variable<String>(originUrl);
    }
    if (!nullToAbsent || originShortcode != null) {
      map['origin_shortcode'] = Variable<String>(originShortcode);
    }
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    map['extraction_version'] = Variable<int>(extractionVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  VersionRowsCompanion toCompanion(bool nullToAbsent) {
    return VersionRowsCompanion(
      id: Value(id),
      dishId: Value(dishId),
      number: Value(number),
      changes: Value(changes),
      ingredients: Value(ingredients),
      steps: Value(steps),
      kcal: Value(kcal),
      protein: Value(protein),
      stepIngredients: Value(stepIngredients),
      tags: Value(tags),
      originKind: Value(originKind),
      originCreator: originCreator == null && nullToAbsent
          ? const Value.absent()
          : Value(originCreator),
      originHandle: originHandle == null && nullToAbsent
          ? const Value.absent()
          : Value(originHandle),
      originPlatform: originPlatform == null && nullToAbsent
          ? const Value.absent()
          : Value(originPlatform),
      originUrl: originUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(originUrl),
      originShortcode: originShortcode == null && nullToAbsent
          ? const Value.absent()
          : Value(originShortcode),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      extractionVersion: Value(extractionVersion),
      createdAt: Value(createdAt),
      dirty: Value(dirty),
    );
  }

  factory VersionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VersionRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      number: serializer.fromJson<int>(json['number']),
      changes: serializer.fromJson<String>(json['changes']),
      ingredients: serializer.fromJson<String>(json['ingredients']),
      steps: serializer.fromJson<String>(json['steps']),
      kcal: serializer.fromJson<int>(json['kcal']),
      protein: serializer.fromJson<int>(json['protein']),
      stepIngredients: serializer.fromJson<String>(json['stepIngredients']),
      tags: serializer.fromJson<String>(json['tags']),
      originKind: serializer.fromJson<String>(json['originKind']),
      originCreator: serializer.fromJson<String?>(json['originCreator']),
      originHandle: serializer.fromJson<String?>(json['originHandle']),
      originPlatform: serializer.fromJson<String?>(json['originPlatform']),
      originUrl: serializer.fromJson<String?>(json['originUrl']),
      originShortcode: serializer.fromJson<String?>(json['originShortcode']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      extractionVersion: serializer.fromJson<int>(json['extractionVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'number': serializer.toJson<int>(number),
      'changes': serializer.toJson<String>(changes),
      'ingredients': serializer.toJson<String>(ingredients),
      'steps': serializer.toJson<String>(steps),
      'kcal': serializer.toJson<int>(kcal),
      'protein': serializer.toJson<int>(protein),
      'stepIngredients': serializer.toJson<String>(stepIngredients),
      'tags': serializer.toJson<String>(tags),
      'originKind': serializer.toJson<String>(originKind),
      'originCreator': serializer.toJson<String?>(originCreator),
      'originHandle': serializer.toJson<String?>(originHandle),
      'originPlatform': serializer.toJson<String?>(originPlatform),
      'originUrl': serializer.toJson<String?>(originUrl),
      'originShortcode': serializer.toJson<String?>(originShortcode),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'extractionVersion': serializer.toJson<int>(extractionVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  VersionRow copyWith(
          {String? id,
          String? dishId,
          int? number,
          String? changes,
          String? ingredients,
          String? steps,
          int? kcal,
          int? protein,
          String? stepIngredients,
          String? tags,
          String? originKind,
          Value<String?> originCreator = const Value.absent(),
          Value<String?> originHandle = const Value.absent(),
          Value<String?> originPlatform = const Value.absent(),
          Value<String?> originUrl = const Value.absent(),
          Value<String?> originShortcode = const Value.absent(),
          Value<String?> parentVersionId = const Value.absent(),
          int? extractionVersion,
          DateTime? createdAt,
          int? dirty}) =>
      VersionRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        number: number ?? this.number,
        changes: changes ?? this.changes,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        kcal: kcal ?? this.kcal,
        protein: protein ?? this.protein,
        stepIngredients: stepIngredients ?? this.stepIngredients,
        tags: tags ?? this.tags,
        originKind: originKind ?? this.originKind,
        originCreator:
            originCreator.present ? originCreator.value : this.originCreator,
        originHandle:
            originHandle.present ? originHandle.value : this.originHandle,
        originPlatform:
            originPlatform.present ? originPlatform.value : this.originPlatform,
        originUrl: originUrl.present ? originUrl.value : this.originUrl,
        originShortcode: originShortcode.present
            ? originShortcode.value
            : this.originShortcode,
        parentVersionId: parentVersionId.present
            ? parentVersionId.value
            : this.parentVersionId,
        extractionVersion: extractionVersion ?? this.extractionVersion,
        createdAt: createdAt ?? this.createdAt,
        dirty: dirty ?? this.dirty,
      );
  VersionRow copyWithCompanion(VersionRowsCompanion data) {
    return VersionRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      number: data.number.present ? data.number.value : this.number,
      changes: data.changes.present ? data.changes.value : this.changes,
      ingredients:
          data.ingredients.present ? data.ingredients.value : this.ingredients,
      steps: data.steps.present ? data.steps.value : this.steps,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      stepIngredients: data.stepIngredients.present
          ? data.stepIngredients.value
          : this.stepIngredients,
      tags: data.tags.present ? data.tags.value : this.tags,
      originKind:
          data.originKind.present ? data.originKind.value : this.originKind,
      originCreator: data.originCreator.present
          ? data.originCreator.value
          : this.originCreator,
      originHandle: data.originHandle.present
          ? data.originHandle.value
          : this.originHandle,
      originPlatform: data.originPlatform.present
          ? data.originPlatform.value
          : this.originPlatform,
      originUrl: data.originUrl.present ? data.originUrl.value : this.originUrl,
      originShortcode: data.originShortcode.present
          ? data.originShortcode.value
          : this.originShortcode,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      extractionVersion: data.extractionVersion.present
          ? data.extractionVersion.value
          : this.extractionVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VersionRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('number: $number, ')
          ..write('changes: $changes, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('stepIngredients: $stepIngredients, ')
          ..write('tags: $tags, ')
          ..write('originKind: $originKind, ')
          ..write('originCreator: $originCreator, ')
          ..write('originHandle: $originHandle, ')
          ..write('originPlatform: $originPlatform, ')
          ..write('originUrl: $originUrl, ')
          ..write('originShortcode: $originShortcode, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('extractionVersion: $extractionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dishId,
      number,
      changes,
      ingredients,
      steps,
      kcal,
      protein,
      stepIngredients,
      tags,
      originKind,
      originCreator,
      originHandle,
      originPlatform,
      originUrl,
      originShortcode,
      parentVersionId,
      extractionVersion,
      createdAt,
      dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VersionRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.number == this.number &&
          other.changes == this.changes &&
          other.ingredients == this.ingredients &&
          other.steps == this.steps &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.stepIngredients == this.stepIngredients &&
          other.tags == this.tags &&
          other.originKind == this.originKind &&
          other.originCreator == this.originCreator &&
          other.originHandle == this.originHandle &&
          other.originPlatform == this.originPlatform &&
          other.originUrl == this.originUrl &&
          other.originShortcode == this.originShortcode &&
          other.parentVersionId == this.parentVersionId &&
          other.extractionVersion == this.extractionVersion &&
          other.createdAt == this.createdAt &&
          other.dirty == this.dirty);
}

class VersionRowsCompanion extends UpdateCompanion<VersionRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<int> number;
  final Value<String> changes;
  final Value<String> ingredients;
  final Value<String> steps;
  final Value<int> kcal;
  final Value<int> protein;
  final Value<String> stepIngredients;
  final Value<String> tags;
  final Value<String> originKind;
  final Value<String?> originCreator;
  final Value<String?> originHandle;
  final Value<String?> originPlatform;
  final Value<String?> originUrl;
  final Value<String?> originShortcode;
  final Value<String?> parentVersionId;
  final Value<int> extractionVersion;
  final Value<DateTime> createdAt;
  final Value<int> dirty;
  final Value<int> rowid;
  const VersionRowsCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.number = const Value.absent(),
    this.changes = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.steps = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.stepIngredients = const Value.absent(),
    this.tags = const Value.absent(),
    this.originKind = const Value.absent(),
    this.originCreator = const Value.absent(),
    this.originHandle = const Value.absent(),
    this.originPlatform = const Value.absent(),
    this.originUrl = const Value.absent(),
    this.originShortcode = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.extractionVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersionRowsCompanion.insert({
    required String id,
    required String dishId,
    this.number = const Value.absent(),
    this.changes = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.steps = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.stepIngredients = const Value.absent(),
    this.tags = const Value.absent(),
    this.originKind = const Value.absent(),
    this.originCreator = const Value.absent(),
    this.originHandle = const Value.absent(),
    this.originPlatform = const Value.absent(),
    this.originUrl = const Value.absent(),
    this.originShortcode = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.extractionVersion = const Value.absent(),
    required DateTime createdAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        createdAt = Value(createdAt);
  static Insertable<VersionRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<int>? number,
    Expression<String>? changes,
    Expression<String>? ingredients,
    Expression<String>? steps,
    Expression<int>? kcal,
    Expression<int>? protein,
    Expression<String>? stepIngredients,
    Expression<String>? tags,
    Expression<String>? originKind,
    Expression<String>? originCreator,
    Expression<String>? originHandle,
    Expression<String>? originPlatform,
    Expression<String>? originUrl,
    Expression<String>? originShortcode,
    Expression<String>? parentVersionId,
    Expression<int>? extractionVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (number != null) 'number': number,
      if (changes != null) 'changes': changes,
      if (ingredients != null) 'ingredients': ingredients,
      if (steps != null) 'steps': steps,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (stepIngredients != null) 'step_ingredients': stepIngredients,
      if (tags != null) 'tags': tags,
      if (originKind != null) 'origin_kind': originKind,
      if (originCreator != null) 'origin_creator': originCreator,
      if (originHandle != null) 'origin_handle': originHandle,
      if (originPlatform != null) 'origin_platform': originPlatform,
      if (originUrl != null) 'origin_url': originUrl,
      if (originShortcode != null) 'origin_shortcode': originShortcode,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (extractionVersion != null) 'extraction_version': extractionVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersionRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<int>? number,
      Value<String>? changes,
      Value<String>? ingredients,
      Value<String>? steps,
      Value<int>? kcal,
      Value<int>? protein,
      Value<String>? stepIngredients,
      Value<String>? tags,
      Value<String>? originKind,
      Value<String?>? originCreator,
      Value<String?>? originHandle,
      Value<String?>? originPlatform,
      Value<String?>? originUrl,
      Value<String?>? originShortcode,
      Value<String?>? parentVersionId,
      Value<int>? extractionVersion,
      Value<DateTime>? createdAt,
      Value<int>? dirty,
      Value<int>? rowid}) {
    return VersionRowsCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      number: number ?? this.number,
      changes: changes ?? this.changes,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      stepIngredients: stepIngredients ?? this.stepIngredients,
      tags: tags ?? this.tags,
      originKind: originKind ?? this.originKind,
      originCreator: originCreator ?? this.originCreator,
      originHandle: originHandle ?? this.originHandle,
      originPlatform: originPlatform ?? this.originPlatform,
      originUrl: originUrl ?? this.originUrl,
      originShortcode: originShortcode ?? this.originShortcode,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      extractionVersion: extractionVersion ?? this.extractionVersion,
      createdAt: createdAt ?? this.createdAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(changes.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (stepIngredients.present) {
      map['step_ingredients'] = Variable<String>(stepIngredients.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (originKind.present) {
      map['origin_kind'] = Variable<String>(originKind.value);
    }
    if (originCreator.present) {
      map['origin_creator'] = Variable<String>(originCreator.value);
    }
    if (originHandle.present) {
      map['origin_handle'] = Variable<String>(originHandle.value);
    }
    if (originPlatform.present) {
      map['origin_platform'] = Variable<String>(originPlatform.value);
    }
    if (originUrl.present) {
      map['origin_url'] = Variable<String>(originUrl.value);
    }
    if (originShortcode.present) {
      map['origin_shortcode'] = Variable<String>(originShortcode.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (extractionVersion.present) {
      map['extraction_version'] = Variable<int>(extractionVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersionRowsCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('number: $number, ')
          ..write('changes: $changes, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('stepIngredients: $stepIngredients, ')
          ..write('tags: $tags, ')
          ..write('originKind: $originKind, ')
          ..write('originCreator: $originCreator, ')
          ..write('originHandle: $originHandle, ')
          ..write('originPlatform: $originPlatform, ')
          ..write('originUrl: $originUrl, ')
          ..write('originShortcode: $originShortcode, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('extractionVersion: $extractionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CookLogRowsTable extends CookLogRows
    with TableInfo<$CookLogRowsTable, CookLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookLogRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dish_rows (id)'));
  static const VerificationMeta _versionIdMeta =
      const VerificationMeta('versionId');
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
      'version_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionNumberMeta =
      const VerificationMeta('versionNumber');
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
      'version_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cookedAtMeta =
      const VerificationMeta('cookedAt');
  @override
  late final GeneratedColumn<DateTime> cookedAt = GeneratedColumn<DateTime>(
      'cooked_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _photoKeyMeta =
      const VerificationMeta('photoKey');
  @override
  late final GeneratedColumn<String> photoKey = GeneratedColumn<String>(
      'photo_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _photoStateMeta =
      const VerificationMeta('photoState');
  @override
  late final GeneratedColumn<String> photoState = GeneratedColumn<String>(
      'photo_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _changesMeta =
      const VerificationMeta('changes');
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
      'dirty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dishId,
        versionId,
        versionNumber,
        cookedAt,
        photoUrl,
        photoKey,
        photoState,
        outcome,
        mood,
        note,
        changes,
        rating,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cook_log_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CookLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(_versionIdMeta,
          versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta));
    }
    if (data.containsKey('version_number')) {
      context.handle(
          _versionNumberMeta,
          versionNumber.isAcceptableOrUnknown(
              data['version_number']!, _versionNumberMeta));
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('cooked_at')) {
      context.handle(_cookedAtMeta,
          cookedAt.isAcceptableOrUnknown(data['cooked_at']!, _cookedAtMeta));
    } else if (isInserting) {
      context.missing(_cookedAtMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('photo_key')) {
      context.handle(_photoKeyMeta,
          photoKey.isAcceptableOrUnknown(data['photo_key']!, _photoKeyMeta));
    }
    if (data.containsKey('photo_state')) {
      context.handle(
          _photoStateMeta,
          photoState.isAcceptableOrUnknown(
              data['photo_state']!, _photoStateMeta));
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('changes')) {
      context.handle(_changesMeta,
          changes.isAcceptableOrUnknown(data['changes']!, _changesMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CookLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      versionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version_id']),
      versionNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version_number'])!,
      cookedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cooked_at'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      photoKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_key'])!,
      photoState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_state'])!,
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      changes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $CookLogRowsTable createAlias(String alias) {
    return $CookLogRowsTable(attachedDatabase, alias);
  }
}

class CookLogRow extends DataClass implements Insertable<CookLogRow> {
  final String id;
  final String dishId;
  final String? versionId;
  final int versionNumber;
  final DateTime cookedAt;
  final String photoUrl;

  /// The object key the API owns, for the sync wire. `photoUrl` is for display.
  final String photoKey;
  final String photoState;
  final String outcome;
  final String mood;
  final String note;
  final String changes;
  final int rating;
  final int dirty;
  const CookLogRow(
      {required this.id,
      required this.dishId,
      this.versionId,
      required this.versionNumber,
      required this.cookedAt,
      required this.photoUrl,
      required this.photoKey,
      required this.photoState,
      required this.outcome,
      required this.mood,
      required this.note,
      required this.changes,
      required this.rating,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    if (!nullToAbsent || versionId != null) {
      map['version_id'] = Variable<String>(versionId);
    }
    map['version_number'] = Variable<int>(versionNumber);
    map['cooked_at'] = Variable<DateTime>(cookedAt);
    map['photo_url'] = Variable<String>(photoUrl);
    map['photo_key'] = Variable<String>(photoKey);
    map['photo_state'] = Variable<String>(photoState);
    map['outcome'] = Variable<String>(outcome);
    map['mood'] = Variable<String>(mood);
    map['note'] = Variable<String>(note);
    map['changes'] = Variable<String>(changes);
    map['rating'] = Variable<int>(rating);
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  CookLogRowsCompanion toCompanion(bool nullToAbsent) {
    return CookLogRowsCompanion(
      id: Value(id),
      dishId: Value(dishId),
      versionId: versionId == null && nullToAbsent
          ? const Value.absent()
          : Value(versionId),
      versionNumber: Value(versionNumber),
      cookedAt: Value(cookedAt),
      photoUrl: Value(photoUrl),
      photoKey: Value(photoKey),
      photoState: Value(photoState),
      outcome: Value(outcome),
      mood: Value(mood),
      note: Value(note),
      changes: Value(changes),
      rating: Value(rating),
      dirty: Value(dirty),
    );
  }

  factory CookLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookLogRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      versionId: serializer.fromJson<String?>(json['versionId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      cookedAt: serializer.fromJson<DateTime>(json['cookedAt']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      photoKey: serializer.fromJson<String>(json['photoKey']),
      photoState: serializer.fromJson<String>(json['photoState']),
      outcome: serializer.fromJson<String>(json['outcome']),
      mood: serializer.fromJson<String>(json['mood']),
      note: serializer.fromJson<String>(json['note']),
      changes: serializer.fromJson<String>(json['changes']),
      rating: serializer.fromJson<int>(json['rating']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'versionId': serializer.toJson<String?>(versionId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'cookedAt': serializer.toJson<DateTime>(cookedAt),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'photoKey': serializer.toJson<String>(photoKey),
      'photoState': serializer.toJson<String>(photoState),
      'outcome': serializer.toJson<String>(outcome),
      'mood': serializer.toJson<String>(mood),
      'note': serializer.toJson<String>(note),
      'changes': serializer.toJson<String>(changes),
      'rating': serializer.toJson<int>(rating),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  CookLogRow copyWith(
          {String? id,
          String? dishId,
          Value<String?> versionId = const Value.absent(),
          int? versionNumber,
          DateTime? cookedAt,
          String? photoUrl,
          String? photoKey,
          String? photoState,
          String? outcome,
          String? mood,
          String? note,
          String? changes,
          int? rating,
          int? dirty}) =>
      CookLogRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        versionId: versionId.present ? versionId.value : this.versionId,
        versionNumber: versionNumber ?? this.versionNumber,
        cookedAt: cookedAt ?? this.cookedAt,
        photoUrl: photoUrl ?? this.photoUrl,
        photoKey: photoKey ?? this.photoKey,
        photoState: photoState ?? this.photoState,
        outcome: outcome ?? this.outcome,
        mood: mood ?? this.mood,
        note: note ?? this.note,
        changes: changes ?? this.changes,
        rating: rating ?? this.rating,
        dirty: dirty ?? this.dirty,
      );
  CookLogRow copyWithCompanion(CookLogRowsCompanion data) {
    return CookLogRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      cookedAt: data.cookedAt.present ? data.cookedAt.value : this.cookedAt,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoKey: data.photoKey.present ? data.photoKey.value : this.photoKey,
      photoState:
          data.photoState.present ? data.photoState.value : this.photoState,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      mood: data.mood.present ? data.mood.value : this.mood,
      note: data.note.present ? data.note.value : this.note,
      changes: data.changes.present ? data.changes.value : this.changes,
      rating: data.rating.present ? data.rating.value : this.rating,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookLogRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('versionId: $versionId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('cookedAt: $cookedAt, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoKey: $photoKey, ')
          ..write('photoState: $photoState, ')
          ..write('outcome: $outcome, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('changes: $changes, ')
          ..write('rating: $rating, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dishId,
      versionId,
      versionNumber,
      cookedAt,
      photoUrl,
      photoKey,
      photoState,
      outcome,
      mood,
      note,
      changes,
      rating,
      dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookLogRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.versionId == this.versionId &&
          other.versionNumber == this.versionNumber &&
          other.cookedAt == this.cookedAt &&
          other.photoUrl == this.photoUrl &&
          other.photoKey == this.photoKey &&
          other.photoState == this.photoState &&
          other.outcome == this.outcome &&
          other.mood == this.mood &&
          other.note == this.note &&
          other.changes == this.changes &&
          other.rating == this.rating &&
          other.dirty == this.dirty);
}

class CookLogRowsCompanion extends UpdateCompanion<CookLogRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String?> versionId;
  final Value<int> versionNumber;
  final Value<DateTime> cookedAt;
  final Value<String> photoUrl;
  final Value<String> photoKey;
  final Value<String> photoState;
  final Value<String> outcome;
  final Value<String> mood;
  final Value<String> note;
  final Value<String> changes;
  final Value<int> rating;
  final Value<int> dirty;
  final Value<int> rowid;
  const CookLogRowsCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.cookedAt = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoKey = const Value.absent(),
    this.photoState = const Value.absent(),
    this.outcome = const Value.absent(),
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
    this.changes = const Value.absent(),
    this.rating = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookLogRowsCompanion.insert({
    required String id,
    required String dishId,
    this.versionId = const Value.absent(),
    required int versionNumber,
    required DateTime cookedAt,
    this.photoUrl = const Value.absent(),
    this.photoKey = const Value.absent(),
    this.photoState = const Value.absent(),
    required String outcome,
    required String mood,
    this.note = const Value.absent(),
    this.changes = const Value.absent(),
    this.rating = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        versionNumber = Value(versionNumber),
        cookedAt = Value(cookedAt),
        outcome = Value(outcome),
        mood = Value(mood);
  static Insertable<CookLogRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? versionId,
    Expression<int>? versionNumber,
    Expression<DateTime>? cookedAt,
    Expression<String>? photoUrl,
    Expression<String>? photoKey,
    Expression<String>? photoState,
    Expression<String>? outcome,
    Expression<String>? mood,
    Expression<String>? note,
    Expression<String>? changes,
    Expression<int>? rating,
    Expression<int>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (versionId != null) 'version_id': versionId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (cookedAt != null) 'cooked_at': cookedAt,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoKey != null) 'photo_key': photoKey,
      if (photoState != null) 'photo_state': photoState,
      if (outcome != null) 'outcome': outcome,
      if (mood != null) 'mood': mood,
      if (note != null) 'note': note,
      if (changes != null) 'changes': changes,
      if (rating != null) 'rating': rating,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookLogRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String?>? versionId,
      Value<int>? versionNumber,
      Value<DateTime>? cookedAt,
      Value<String>? photoUrl,
      Value<String>? photoKey,
      Value<String>? photoState,
      Value<String>? outcome,
      Value<String>? mood,
      Value<String>? note,
      Value<String>? changes,
      Value<int>? rating,
      Value<int>? dirty,
      Value<int>? rowid}) {
    return CookLogRowsCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      versionId: versionId ?? this.versionId,
      versionNumber: versionNumber ?? this.versionNumber,
      cookedAt: cookedAt ?? this.cookedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      photoKey: photoKey ?? this.photoKey,
      photoState: photoState ?? this.photoState,
      outcome: outcome ?? this.outcome,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      changes: changes ?? this.changes,
      rating: rating ?? this.rating,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (cookedAt.present) {
      map['cooked_at'] = Variable<DateTime>(cookedAt.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoKey.present) {
      map['photo_key'] = Variable<String>(photoKey.value);
    }
    if (photoState.present) {
      map['photo_state'] = Variable<String>(photoState.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(changes.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookLogRowsCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('versionId: $versionId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('cookedAt: $cookedAt, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoKey: $photoKey, ')
          ..write('photoState: $photoState, ')
          ..write('outcome: $outcome, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('changes: $changes, ')
          ..write('rating: $rating, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CookTimerRowsTable extends CookTimerRows
    with TableInfo<$CookTimerRowsTable, CookTimerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookTimerRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionIdMeta =
      const VerificationMeta('versionId');
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
      'version_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepIndexMeta =
      const VerificationMeta('stepIndex');
  @override
  late final GeneratedColumn<int> stepIndex = GeneratedColumn<int>(
      'step_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pausedMsMeta =
      const VerificationMeta('pausedMs');
  @override
  late final GeneratedColumn<int> pausedMs = GeneratedColumn<int>(
      'paused_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pausedAtMeta =
      const VerificationMeta('pausedAt');
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
      'paused_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dishId,
        versionId,
        stepIndex,
        startedAt,
        durationMs,
        pausedMs,
        pausedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cook_timer_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CookTimerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(_versionIdMeta,
          versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta));
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('step_index')) {
      context.handle(_stepIndexMeta,
          stepIndex.isAcceptableOrUnknown(data['step_index']!, _stepIndexMeta));
    } else if (isInserting) {
      context.missing(_stepIndexMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('paused_ms')) {
      context.handle(_pausedMsMeta,
          pausedMs.isAcceptableOrUnknown(data['paused_ms']!, _pausedMsMeta));
    }
    if (data.containsKey('paused_at')) {
      context.handle(_pausedAtMeta,
          pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CookTimerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookTimerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      versionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version_id'])!,
      stepIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_index'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      pausedMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paused_ms'])!,
      pausedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at']),
    );
  }

  @override
  $CookTimerRowsTable createAlias(String alias) {
    return $CookTimerRowsTable(attachedDatabase, alias);
  }
}

class CookTimerRow extends DataClass implements Insertable<CookTimerRow> {
  final String id;
  final String dishId;
  final String versionId;
  final int stepIndex;
  final DateTime startedAt;
  final int durationMs;
  final int pausedMs;
  final DateTime? pausedAt;
  const CookTimerRow(
      {required this.id,
      required this.dishId,
      required this.versionId,
      required this.stepIndex,
      required this.startedAt,
      required this.durationMs,
      required this.pausedMs,
      this.pausedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['version_id'] = Variable<String>(versionId);
    map['step_index'] = Variable<int>(stepIndex);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['paused_ms'] = Variable<int>(pausedMs);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    return map;
  }

  CookTimerRowsCompanion toCompanion(bool nullToAbsent) {
    return CookTimerRowsCompanion(
      id: Value(id),
      dishId: Value(dishId),
      versionId: Value(versionId),
      stepIndex: Value(stepIndex),
      startedAt: Value(startedAt),
      durationMs: Value(durationMs),
      pausedMs: Value(pausedMs),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
    );
  }

  factory CookTimerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookTimerRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      versionId: serializer.fromJson<String>(json['versionId']),
      stepIndex: serializer.fromJson<int>(json['stepIndex']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      pausedMs: serializer.fromJson<int>(json['pausedMs']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'versionId': serializer.toJson<String>(versionId),
      'stepIndex': serializer.toJson<int>(stepIndex),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'pausedMs': serializer.toJson<int>(pausedMs),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
    };
  }

  CookTimerRow copyWith(
          {String? id,
          String? dishId,
          String? versionId,
          int? stepIndex,
          DateTime? startedAt,
          int? durationMs,
          int? pausedMs,
          Value<DateTime?> pausedAt = const Value.absent()}) =>
      CookTimerRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        versionId: versionId ?? this.versionId,
        stepIndex: stepIndex ?? this.stepIndex,
        startedAt: startedAt ?? this.startedAt,
        durationMs: durationMs ?? this.durationMs,
        pausedMs: pausedMs ?? this.pausedMs,
        pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
      );
  CookTimerRow copyWithCompanion(CookTimerRowsCompanion data) {
    return CookTimerRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      stepIndex: data.stepIndex.present ? data.stepIndex.value : this.stepIndex,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      pausedMs: data.pausedMs.present ? data.pausedMs.value : this.pausedMs,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookTimerRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('versionId: $versionId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('pausedMs: $pausedMs, ')
          ..write('pausedAt: $pausedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dishId, versionId, stepIndex, startedAt,
      durationMs, pausedMs, pausedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookTimerRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.versionId == this.versionId &&
          other.stepIndex == this.stepIndex &&
          other.startedAt == this.startedAt &&
          other.durationMs == this.durationMs &&
          other.pausedMs == this.pausedMs &&
          other.pausedAt == this.pausedAt);
}

class CookTimerRowsCompanion extends UpdateCompanion<CookTimerRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> versionId;
  final Value<int> stepIndex;
  final Value<DateTime> startedAt;
  final Value<int> durationMs;
  final Value<int> pausedMs;
  final Value<DateTime?> pausedAt;
  final Value<int> rowid;
  const CookTimerRowsCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.stepIndex = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.pausedMs = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookTimerRowsCompanion.insert({
    required String id,
    required String dishId,
    required String versionId,
    required int stepIndex,
    required DateTime startedAt,
    required int durationMs,
    this.pausedMs = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        versionId = Value(versionId),
        stepIndex = Value(stepIndex),
        startedAt = Value(startedAt),
        durationMs = Value(durationMs);
  static Insertable<CookTimerRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? versionId,
    Expression<int>? stepIndex,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMs,
    Expression<int>? pausedMs,
    Expression<DateTime>? pausedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (versionId != null) 'version_id': versionId,
      if (stepIndex != null) 'step_index': stepIndex,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (pausedMs != null) 'paused_ms': pausedMs,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookTimerRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? versionId,
      Value<int>? stepIndex,
      Value<DateTime>? startedAt,
      Value<int>? durationMs,
      Value<int>? pausedMs,
      Value<DateTime?>? pausedAt,
      Value<int>? rowid}) {
    return CookTimerRowsCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      versionId: versionId ?? this.versionId,
      stepIndex: stepIndex ?? this.stepIndex,
      startedAt: startedAt ?? this.startedAt,
      durationMs: durationMs ?? this.durationMs,
      pausedMs: pausedMs ?? this.pausedMs,
      pausedAt: pausedAt ?? this.pausedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (stepIndex.present) {
      map['step_index'] = Variable<int>(stepIndex.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (pausedMs.present) {
      map['paused_ms'] = Variable<int>(pausedMs.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookTimerRowsCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('versionId: $versionId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('pausedMs: $pausedMs, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PantryRowsTable extends PantryRows
    with TableInfo<$PantryRowsTable, PantryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aliasesMeta =
      const VerificationMeta('aliases');
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
      'aliases', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _wantedMeta = const VerificationMeta('wanted');
  @override
  late final GeneratedColumn<int> wanted = GeneratedColumn<int>(
      'wanted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
      'dirty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        quantity,
        unit,
        aliases,
        wanted,
        source,
        createdAt,
        updatedAt,
        deletedAt,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_rows';
  @override
  VerificationContext validateIntegrity(Insertable<PantryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('aliases')) {
      context.handle(_aliasesMeta,
          aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta));
    }
    if (data.containsKey('wanted')) {
      context.handle(_wantedMeta,
          wanted.isAcceptableOrUnknown(data['wanted']!, _wantedMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      aliases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases'])!,
      wanted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wanted'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $PantryRowsTable createAlias(String alias) {
    return $PantryRowsTable(attachedDatabase, alias);
  }
}

class PantryRow extends DataClass implements Insertable<PantryRow> {
  final String id;
  final String name;

  /// Null means "have it, amount unknown" — which never counts when deducting.
  final double? quantity;
  final String? unit;

  /// User-confirmed strings that join a receipt line to this item. JSON list.
  final String aliases;
  final int wanted;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int dirty;
  const PantryRow(
      {required this.id,
      required this.name,
      this.quantity,
      this.unit,
      required this.aliases,
      required this.wanted,
      required this.source,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['aliases'] = Variable<String>(aliases);
    map['wanted'] = Variable<int>(wanted);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    return map;
  }

  PantryRowsCompanion toCompanion(bool nullToAbsent) {
    return PantryRowsCompanion(
      id: Value(id),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      aliases: Value(aliases),
      wanted: Value(wanted),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
    );
  }

  factory PantryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      aliases: serializer.fromJson<String>(json['aliases']),
      wanted: serializer.fromJson<int>(json['wanted']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'aliases': serializer.toJson<String>(aliases),
      'wanted': serializer.toJson<int>(wanted),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
    };
  }

  PantryRow copyWith(
          {String? id,
          String? name,
          Value<double?> quantity = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          String? aliases,
          int? wanted,
          String? source,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? dirty}) =>
      PantryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity.present ? quantity.value : this.quantity,
        unit: unit.present ? unit.value : this.unit,
        aliases: aliases ?? this.aliases,
        wanted: wanted ?? this.wanted,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        dirty: dirty ?? this.dirty,
      );
  PantryRow copyWithCompanion(PantryRowsCompanion data) {
    return PantryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      wanted: data.wanted.present ? data.wanted.value : this.wanted,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('aliases: $aliases, ')
          ..write('wanted: $wanted, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, quantity, unit, aliases, wanted,
      source, createdAt, updatedAt, deletedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.aliases == this.aliases &&
          other.wanted == this.wanted &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty);
}

class PantryRowsCompanion extends UpdateCompanion<PantryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<String> aliases;
  final Value<int> wanted;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> dirty;
  final Value<int> rowid;
  const PantryRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.aliases = const Value.absent(),
    this.wanted = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PantryRowsCompanion.insert({
    required String id,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.aliases = const Value.absent(),
    this.wanted = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PantryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? aliases,
    Expression<int>? wanted,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (aliases != null) 'aliases': aliases,
      if (wanted != null) 'wanted': wanted,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PantryRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double?>? quantity,
      Value<String?>? unit,
      Value<String>? aliases,
      Value<int>? wanted,
      Value<String>? source,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? dirty,
      Value<int>? rowid}) {
    return PantryRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      aliases: aliases ?? this.aliases,
      wanted: wanted ?? this.wanted,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (wanted.present) {
      map['wanted'] = Variable<int>(wanted.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('aliases: $aliases, ')
          ..write('wanted: $wanted, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaRowsTable extends MetaRows with TableInfo<$MetaRowsTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_rows';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaRowsTable createAlias(String alias) {
    return $MetaRowsTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaRowsCompanion toCompanion(bool nullToAbsent) {
    return MetaRowsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory MetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) => MetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  MetaRow copyWithCompanion(MetaRowsCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaRowsCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaRowsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return MetaRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DishRowsTable dishRows = $DishRowsTable(this);
  late final $VersionRowsTable versionRows = $VersionRowsTable(this);
  late final $CookLogRowsTable cookLogRows = $CookLogRowsTable(this);
  late final $CookTimerRowsTable cookTimerRows = $CookTimerRowsTable(this);
  late final $PantryRowsTable pantryRows = $PantryRowsTable(this);
  late final $MetaRowsTable metaRows = $MetaRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dishRows, versionRows, cookLogRows, cookTimerRows, pantryRows, metaRows];
}

typedef $$DishRowsTableCreateCompanionBuilder = DishRowsCompanion Function({
  required String id,
  required String title,
  Value<String> subtitle,
  Value<String> coverUrl,
  Value<String> sourceHandle,
  required String status,
  Value<int> minutes,
  Value<int> baselineKcal,
  Value<int> baselineProtein,
  Value<String> steps,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> dirty,
  Value<int> rowid,
});
typedef $$DishRowsTableUpdateCompanionBuilder = DishRowsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> subtitle,
  Value<String> coverUrl,
  Value<String> sourceHandle,
  Value<String> status,
  Value<int> minutes,
  Value<int> baselineKcal,
  Value<int> baselineProtein,
  Value<String> steps,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> dirty,
  Value<int> rowid,
});

final class $$DishRowsTableReferences
    extends BaseReferences<_$AppDatabase, $DishRowsTable, DishRow> {
  $$DishRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VersionRowsTable, List<VersionRow>>
      _versionRowsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.versionRows,
              aliasName: 'dish_rows__id__version_rows__dish_id');

  $$VersionRowsTableProcessedTableManager get versionRowsRefs {
    final manager = $$VersionRowsTableTableManager($_db, $_db.versionRows)
        .filter((f) => f.dishId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_versionRowsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CookLogRowsTable, List<CookLogRow>>
      _cookLogRowsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.cookLogRows,
              aliasName: 'dish_rows__id__cook_log_rows__dish_id');

  $$CookLogRowsTableProcessedTableManager get cookLogRowsRefs {
    final manager = $$CookLogRowsTableTableManager($_db, $_db.cookLogRows)
        .filter((f) => f.dishId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cookLogRowsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DishRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DishRowsTable> {
  $$DishRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceHandle => $composableBuilder(
      column: $table.sourceHandle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutes => $composableBuilder(
      column: $table.minutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baselineKcal => $composableBuilder(
      column: $table.baselineKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baselineProtein => $composableBuilder(
      column: $table.baselineProtein,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  Expression<bool> versionRowsRefs(
      Expression<bool> Function($$VersionRowsTableFilterComposer f) f) {
    final $$VersionRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.versionRows,
        getReferencedColumn: (t) => t.dishId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersionRowsTableFilterComposer(
              $db: $db,
              $table: $db.versionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> cookLogRowsRefs(
      Expression<bool> Function($$CookLogRowsTableFilterComposer f) f) {
    final $$CookLogRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cookLogRows,
        getReferencedColumn: (t) => t.dishId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CookLogRowsTableFilterComposer(
              $db: $db,
              $table: $db.cookLogRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DishRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DishRowsTable> {
  $$DishRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceHandle => $composableBuilder(
      column: $table.sourceHandle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutes => $composableBuilder(
      column: $table.minutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baselineKcal => $composableBuilder(
      column: $table.baselineKcal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baselineProtein => $composableBuilder(
      column: $table.baselineProtein,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$DishRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishRowsTable> {
  $$DishRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceHandle => $composableBuilder(
      column: $table.sourceHandle, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get baselineKcal => $composableBuilder(
      column: $table.baselineKcal, builder: (column) => column);

  GeneratedColumn<int> get baselineProtein => $composableBuilder(
      column: $table.baselineProtein, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  Expression<T> versionRowsRefs<T extends Object>(
      Expression<T> Function($$VersionRowsTableAnnotationComposer a) f) {
    final $$VersionRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.versionRows,
        getReferencedColumn: (t) => t.dishId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersionRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.versionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> cookLogRowsRefs<T extends Object>(
      Expression<T> Function($$CookLogRowsTableAnnotationComposer a) f) {
    final $$CookLogRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cookLogRows,
        getReferencedColumn: (t) => t.dishId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CookLogRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.cookLogRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DishRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishRowsTable,
    DishRow,
    $$DishRowsTableFilterComposer,
    $$DishRowsTableOrderingComposer,
    $$DishRowsTableAnnotationComposer,
    $$DishRowsTableCreateCompanionBuilder,
    $$DishRowsTableUpdateCompanionBuilder,
    (DishRow, $$DishRowsTableReferences),
    DishRow,
    PrefetchHooks Function({bool versionRowsRefs, bool cookLogRowsRefs})> {
  $$DishRowsTableTableManager(_$AppDatabase db, $DishRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> subtitle = const Value.absent(),
            Value<String> coverUrl = const Value.absent(),
            Value<String> sourceHandle = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> minutes = const Value.absent(),
            Value<int> baselineKcal = const Value.absent(),
            Value<int> baselineProtein = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishRowsCompanion(
            id: id,
            title: title,
            subtitle: subtitle,
            coverUrl: coverUrl,
            sourceHandle: sourceHandle,
            status: status,
            minutes: minutes,
            baselineKcal: baselineKcal,
            baselineProtein: baselineProtein,
            steps: steps,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> subtitle = const Value.absent(),
            Value<String> coverUrl = const Value.absent(),
            Value<String> sourceHandle = const Value.absent(),
            required String status,
            Value<int> minutes = const Value.absent(),
            Value<int> baselineKcal = const Value.absent(),
            Value<int> baselineProtein = const Value.absent(),
            Value<String> steps = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishRowsCompanion.insert(
            id: id,
            title: title,
            subtitle: subtitle,
            coverUrl: coverUrl,
            sourceHandle: sourceHandle,
            status: status,
            minutes: minutes,
            baselineKcal: baselineKcal,
            baselineProtein: baselineProtein,
            steps: steps,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DishRowsTable, DishRow>(table),
                    $$DishRowsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {versionRowsRefs = false, cookLogRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (versionRowsRefs) db.versionRows,
                if (cookLogRowsRefs) db.cookLogRows
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (versionRowsRefs)
                    await $_getPrefetchedDataByColumns<DishRow, $DishRowsTable,
                            VersionRow, $VersionRowsTable>(
                        currentTable: table,
                        referencedTable:
                            $$DishRowsTableReferences._versionRowsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DishRowsTableReferences(db, table, p0)
                                .versionRowsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'dish_id',
                        typedResults: items),
                  if (cookLogRowsRefs)
                    await $_getPrefetchedDataByColumns<DishRow, $DishRowsTable,
                            CookLogRow, $CookLogRowsTable>(
                        currentTable: table,
                        referencedTable:
                            $$DishRowsTableReferences._cookLogRowsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DishRowsTableReferences(db, table, p0)
                                .cookLogRowsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'dish_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DishRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishRowsTable,
    DishRow,
    $$DishRowsTableFilterComposer,
    $$DishRowsTableOrderingComposer,
    $$DishRowsTableAnnotationComposer,
    $$DishRowsTableCreateCompanionBuilder,
    $$DishRowsTableUpdateCompanionBuilder,
    (DishRow, $$DishRowsTableReferences),
    DishRow,
    PrefetchHooks Function({bool versionRowsRefs, bool cookLogRowsRefs})>;
typedef $$VersionRowsTableCreateCompanionBuilder = VersionRowsCompanion
    Function({
  required String id,
  required String dishId,
  Value<int> number,
  Value<String> changes,
  Value<String> ingredients,
  Value<String> steps,
  Value<int> kcal,
  Value<int> protein,
  Value<String> stepIngredients,
  Value<String> tags,
  Value<String> originKind,
  Value<String?> originCreator,
  Value<String?> originHandle,
  Value<String?> originPlatform,
  Value<String?> originUrl,
  Value<String?> originShortcode,
  Value<String?> parentVersionId,
  Value<int> extractionVersion,
  required DateTime createdAt,
  Value<int> dirty,
  Value<int> rowid,
});
typedef $$VersionRowsTableUpdateCompanionBuilder = VersionRowsCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<int> number,
  Value<String> changes,
  Value<String> ingredients,
  Value<String> steps,
  Value<int> kcal,
  Value<int> protein,
  Value<String> stepIngredients,
  Value<String> tags,
  Value<String> originKind,
  Value<String?> originCreator,
  Value<String?> originHandle,
  Value<String?> originPlatform,
  Value<String?> originUrl,
  Value<String?> originShortcode,
  Value<String?> parentVersionId,
  Value<int> extractionVersion,
  Value<DateTime> createdAt,
  Value<int> dirty,
  Value<int> rowid,
});

final class $$VersionRowsTableReferences
    extends BaseReferences<_$AppDatabase, $VersionRowsTable, VersionRow> {
  $$VersionRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DishRowsTable _dishIdTable(_$AppDatabase db) =>
      db.dishRows.createAlias('version_rows__dish_id__dish_rows__id');

  $$DishRowsTableProcessedTableManager get dishId {
    final $_column = $_itemColumn<String>('dish_id')!;

    final manager = $$DishRowsTableTableManager($_db, $_db.dishRows)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dishIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VersionRowsTableFilterComposer
    extends Composer<_$AppDatabase, $VersionRowsTable> {
  $$VersionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredients => $composableBuilder(
      column: $table.ingredients, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stepIngredients => $composableBuilder(
      column: $table.stepIngredients,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originKind => $composableBuilder(
      column: $table.originKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originCreator => $composableBuilder(
      column: $table.originCreator, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originHandle => $composableBuilder(
      column: $table.originHandle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originPlatform => $composableBuilder(
      column: $table.originPlatform,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originUrl => $composableBuilder(
      column: $table.originUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originShortcode => $composableBuilder(
      column: $table.originShortcode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentVersionId => $composableBuilder(
      column: $table.parentVersionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get extractionVersion => $composableBuilder(
      column: $table.extractionVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  $$DishRowsTableFilterComposer get dishId {
    final $$DishRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableFilterComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VersionRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $VersionRowsTable> {
  $$VersionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredients => $composableBuilder(
      column: $table.ingredients, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stepIngredients => $composableBuilder(
      column: $table.stepIngredients,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originKind => $composableBuilder(
      column: $table.originKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originCreator => $composableBuilder(
      column: $table.originCreator,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originHandle => $composableBuilder(
      column: $table.originHandle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originPlatform => $composableBuilder(
      column: $table.originPlatform,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originUrl => $composableBuilder(
      column: $table.originUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originShortcode => $composableBuilder(
      column: $table.originShortcode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
      column: $table.parentVersionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get extractionVersion => $composableBuilder(
      column: $table.extractionVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  $$DishRowsTableOrderingComposer get dishId {
    final $$DishRowsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableOrderingComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VersionRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersionRowsTable> {
  $$VersionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<String> get ingredients => $composableBuilder(
      column: $table.ingredients, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<String> get stepIngredients => $composableBuilder(
      column: $table.stepIngredients, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get originKind => $composableBuilder(
      column: $table.originKind, builder: (column) => column);

  GeneratedColumn<String> get originCreator => $composableBuilder(
      column: $table.originCreator, builder: (column) => column);

  GeneratedColumn<String> get originHandle => $composableBuilder(
      column: $table.originHandle, builder: (column) => column);

  GeneratedColumn<String> get originPlatform => $composableBuilder(
      column: $table.originPlatform, builder: (column) => column);

  GeneratedColumn<String> get originUrl =>
      $composableBuilder(column: $table.originUrl, builder: (column) => column);

  GeneratedColumn<String> get originShortcode => $composableBuilder(
      column: $table.originShortcode, builder: (column) => column);

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
      column: $table.parentVersionId, builder: (column) => column);

  GeneratedColumn<int> get extractionVersion => $composableBuilder(
      column: $table.extractionVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  $$DishRowsTableAnnotationComposer get dishId {
    final $$DishRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VersionRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VersionRowsTable,
    VersionRow,
    $$VersionRowsTableFilterComposer,
    $$VersionRowsTableOrderingComposer,
    $$VersionRowsTableAnnotationComposer,
    $$VersionRowsTableCreateCompanionBuilder,
    $$VersionRowsTableUpdateCompanionBuilder,
    (VersionRow, $$VersionRowsTableReferences),
    VersionRow,
    PrefetchHooks Function({bool dishId})> {
  $$VersionRowsTableTableManager(_$AppDatabase db, $VersionRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<String> changes = const Value.absent(),
            Value<String> ingredients = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<int> protein = const Value.absent(),
            Value<String> stepIngredients = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> originKind = const Value.absent(),
            Value<String?> originCreator = const Value.absent(),
            Value<String?> originHandle = const Value.absent(),
            Value<String?> originPlatform = const Value.absent(),
            Value<String?> originUrl = const Value.absent(),
            Value<String?> originShortcode = const Value.absent(),
            Value<String?> parentVersionId = const Value.absent(),
            Value<int> extractionVersion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VersionRowsCompanion(
            id: id,
            dishId: dishId,
            number: number,
            changes: changes,
            ingredients: ingredients,
            steps: steps,
            kcal: kcal,
            protein: protein,
            stepIngredients: stepIngredients,
            tags: tags,
            originKind: originKind,
            originCreator: originCreator,
            originHandle: originHandle,
            originPlatform: originPlatform,
            originUrl: originUrl,
            originShortcode: originShortcode,
            parentVersionId: parentVersionId,
            extractionVersion: extractionVersion,
            createdAt: createdAt,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            Value<int> number = const Value.absent(),
            Value<String> changes = const Value.absent(),
            Value<String> ingredients = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<int> protein = const Value.absent(),
            Value<String> stepIngredients = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> originKind = const Value.absent(),
            Value<String?> originCreator = const Value.absent(),
            Value<String?> originHandle = const Value.absent(),
            Value<String?> originPlatform = const Value.absent(),
            Value<String?> originUrl = const Value.absent(),
            Value<String?> originShortcode = const Value.absent(),
            Value<String?> parentVersionId = const Value.absent(),
            Value<int> extractionVersion = const Value.absent(),
            required DateTime createdAt,
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VersionRowsCompanion.insert(
            id: id,
            dishId: dishId,
            number: number,
            changes: changes,
            ingredients: ingredients,
            steps: steps,
            kcal: kcal,
            protein: protein,
            stepIngredients: stepIngredients,
            tags: tags,
            originKind: originKind,
            originCreator: originCreator,
            originHandle: originHandle,
            originPlatform: originPlatform,
            originUrl: originUrl,
            originShortcode: originShortcode,
            parentVersionId: parentVersionId,
            extractionVersion: extractionVersion,
            createdAt: createdAt,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$VersionRowsTable, VersionRow>(table),
                    $$VersionRowsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dishId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (dishId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dishId,
                    referencedTable:
                        $$VersionRowsTableReferences._dishIdTable(db),
                    referencedColumn:
                        $$VersionRowsTableReferences._dishIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VersionRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VersionRowsTable,
    VersionRow,
    $$VersionRowsTableFilterComposer,
    $$VersionRowsTableOrderingComposer,
    $$VersionRowsTableAnnotationComposer,
    $$VersionRowsTableCreateCompanionBuilder,
    $$VersionRowsTableUpdateCompanionBuilder,
    (VersionRow, $$VersionRowsTableReferences),
    VersionRow,
    PrefetchHooks Function({bool dishId})>;
typedef $$CookLogRowsTableCreateCompanionBuilder = CookLogRowsCompanion
    Function({
  required String id,
  required String dishId,
  Value<String?> versionId,
  required int versionNumber,
  required DateTime cookedAt,
  Value<String> photoUrl,
  Value<String> photoKey,
  Value<String> photoState,
  required String outcome,
  required String mood,
  Value<String> note,
  Value<String> changes,
  Value<int> rating,
  Value<int> dirty,
  Value<int> rowid,
});
typedef $$CookLogRowsTableUpdateCompanionBuilder = CookLogRowsCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<String?> versionId,
  Value<int> versionNumber,
  Value<DateTime> cookedAt,
  Value<String> photoUrl,
  Value<String> photoKey,
  Value<String> photoState,
  Value<String> outcome,
  Value<String> mood,
  Value<String> note,
  Value<String> changes,
  Value<int> rating,
  Value<int> dirty,
  Value<int> rowid,
});

final class $$CookLogRowsTableReferences
    extends BaseReferences<_$AppDatabase, $CookLogRowsTable, CookLogRow> {
  $$CookLogRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DishRowsTable _dishIdTable(_$AppDatabase db) =>
      db.dishRows.createAlias('cook_log_rows__dish_id__dish_rows__id');

  $$DishRowsTableProcessedTableManager get dishId {
    final $_column = $_itemColumn<String>('dish_id')!;

    final manager = $$DishRowsTableTableManager($_db, $_db.dishRows)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dishIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CookLogRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CookLogRowsTable> {
  $$CookLogRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get versionId => $composableBuilder(
      column: $table.versionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get versionNumber => $composableBuilder(
      column: $table.versionNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cookedAt => $composableBuilder(
      column: $table.cookedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoKey => $composableBuilder(
      column: $table.photoKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoState => $composableBuilder(
      column: $table.photoState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  $$DishRowsTableFilterComposer get dishId {
    final $$DishRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableFilterComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CookLogRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CookLogRowsTable> {
  $$CookLogRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get versionId => $composableBuilder(
      column: $table.versionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get versionNumber => $composableBuilder(
      column: $table.versionNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cookedAt => $composableBuilder(
      column: $table.cookedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoKey => $composableBuilder(
      column: $table.photoKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoState => $composableBuilder(
      column: $table.photoState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  $$DishRowsTableOrderingComposer get dishId {
    final $$DishRowsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableOrderingComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CookLogRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CookLogRowsTable> {
  $$CookLogRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<int> get versionNumber => $composableBuilder(
      column: $table.versionNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get cookedAt =>
      $composableBuilder(column: $table.cookedAt, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get photoKey =>
      $composableBuilder(column: $table.photoKey, builder: (column) => column);

  GeneratedColumn<String> get photoState => $composableBuilder(
      column: $table.photoState, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  $$DishRowsTableAnnotationComposer get dishId {
    final $$DishRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dishId,
        referencedTable: $db.dishRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DishRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.dishRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CookLogRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CookLogRowsTable,
    CookLogRow,
    $$CookLogRowsTableFilterComposer,
    $$CookLogRowsTableOrderingComposer,
    $$CookLogRowsTableAnnotationComposer,
    $$CookLogRowsTableCreateCompanionBuilder,
    $$CookLogRowsTableUpdateCompanionBuilder,
    (CookLogRow, $$CookLogRowsTableReferences),
    CookLogRow,
    PrefetchHooks Function({bool dishId})> {
  $$CookLogRowsTableTableManager(_$AppDatabase db, $CookLogRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookLogRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookLogRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CookLogRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String?> versionId = const Value.absent(),
            Value<int> versionNumber = const Value.absent(),
            Value<DateTime> cookedAt = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<String> photoKey = const Value.absent(),
            Value<String> photoState = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<String> mood = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> changes = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookLogRowsCompanion(
            id: id,
            dishId: dishId,
            versionId: versionId,
            versionNumber: versionNumber,
            cookedAt: cookedAt,
            photoUrl: photoUrl,
            photoKey: photoKey,
            photoState: photoState,
            outcome: outcome,
            mood: mood,
            note: note,
            changes: changes,
            rating: rating,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            Value<String?> versionId = const Value.absent(),
            required int versionNumber,
            required DateTime cookedAt,
            Value<String> photoUrl = const Value.absent(),
            Value<String> photoKey = const Value.absent(),
            Value<String> photoState = const Value.absent(),
            required String outcome,
            required String mood,
            Value<String> note = const Value.absent(),
            Value<String> changes = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookLogRowsCompanion.insert(
            id: id,
            dishId: dishId,
            versionId: versionId,
            versionNumber: versionNumber,
            cookedAt: cookedAt,
            photoUrl: photoUrl,
            photoKey: photoKey,
            photoState: photoState,
            outcome: outcome,
            mood: mood,
            note: note,
            changes: changes,
            rating: rating,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CookLogRowsTable, CookLogRow>(table),
                    $$CookLogRowsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dishId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (dishId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dishId,
                    referencedTable:
                        $$CookLogRowsTableReferences._dishIdTable(db),
                    referencedColumn:
                        $$CookLogRowsTableReferences._dishIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CookLogRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CookLogRowsTable,
    CookLogRow,
    $$CookLogRowsTableFilterComposer,
    $$CookLogRowsTableOrderingComposer,
    $$CookLogRowsTableAnnotationComposer,
    $$CookLogRowsTableCreateCompanionBuilder,
    $$CookLogRowsTableUpdateCompanionBuilder,
    (CookLogRow, $$CookLogRowsTableReferences),
    CookLogRow,
    PrefetchHooks Function({bool dishId})>;
typedef $$CookTimerRowsTableCreateCompanionBuilder = CookTimerRowsCompanion
    Function({
  required String id,
  required String dishId,
  required String versionId,
  required int stepIndex,
  required DateTime startedAt,
  required int durationMs,
  Value<int> pausedMs,
  Value<DateTime?> pausedAt,
  Value<int> rowid,
});
typedef $$CookTimerRowsTableUpdateCompanionBuilder = CookTimerRowsCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> versionId,
  Value<int> stepIndex,
  Value<DateTime> startedAt,
  Value<int> durationMs,
  Value<int> pausedMs,
  Value<DateTime?> pausedAt,
  Value<int> rowid,
});

class $$CookTimerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CookTimerRowsTable> {
  $$CookTimerRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get versionId => $composableBuilder(
      column: $table.versionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepIndex => $composableBuilder(
      column: $table.stepIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pausedMs => $composableBuilder(
      column: $table.pausedMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnFilters(column));
}

class $$CookTimerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CookTimerRowsTable> {
  $$CookTimerRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get versionId => $composableBuilder(
      column: $table.versionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepIndex => $composableBuilder(
      column: $table.stepIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pausedMs => $composableBuilder(
      column: $table.pausedMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnOrderings(column));
}

class $$CookTimerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CookTimerRowsTable> {
  $$CookTimerRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<int> get stepIndex =>
      $composableBuilder(column: $table.stepIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get pausedMs =>
      $composableBuilder(column: $table.pausedMs, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);
}

class $$CookTimerRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CookTimerRowsTable,
    CookTimerRow,
    $$CookTimerRowsTableFilterComposer,
    $$CookTimerRowsTableOrderingComposer,
    $$CookTimerRowsTableAnnotationComposer,
    $$CookTimerRowsTableCreateCompanionBuilder,
    $$CookTimerRowsTableUpdateCompanionBuilder,
    (
      CookTimerRow,
      BaseReferences<_$AppDatabase, $CookTimerRowsTable, CookTimerRow>
    ),
    CookTimerRow,
    PrefetchHooks Function()> {
  $$CookTimerRowsTableTableManager(_$AppDatabase db, $CookTimerRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookTimerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookTimerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CookTimerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> versionId = const Value.absent(),
            Value<int> stepIndex = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> pausedMs = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookTimerRowsCompanion(
            id: id,
            dishId: dishId,
            versionId: versionId,
            stepIndex: stepIndex,
            startedAt: startedAt,
            durationMs: durationMs,
            pausedMs: pausedMs,
            pausedAt: pausedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String versionId,
            required int stepIndex,
            required DateTime startedAt,
            required int durationMs,
            Value<int> pausedMs = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookTimerRowsCompanion.insert(
            id: id,
            dishId: dishId,
            versionId: versionId,
            stepIndex: stepIndex,
            startedAt: startedAt,
            durationMs: durationMs,
            pausedMs: pausedMs,
            pausedAt: pausedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CookTimerRowsTable, CookTimerRow>(table),
                    BaseReferences<_$AppDatabase, $CookTimerRowsTable,
                        CookTimerRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CookTimerRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CookTimerRowsTable,
    CookTimerRow,
    $$CookTimerRowsTableFilterComposer,
    $$CookTimerRowsTableOrderingComposer,
    $$CookTimerRowsTableAnnotationComposer,
    $$CookTimerRowsTableCreateCompanionBuilder,
    $$CookTimerRowsTableUpdateCompanionBuilder,
    (
      CookTimerRow,
      BaseReferences<_$AppDatabase, $CookTimerRowsTable, CookTimerRow>
    ),
    CookTimerRow,
    PrefetchHooks Function()>;
typedef $$PantryRowsTableCreateCompanionBuilder = PantryRowsCompanion Function({
  required String id,
  required String name,
  Value<double?> quantity,
  Value<String?> unit,
  Value<String> aliases,
  Value<int> wanted,
  Value<String> source,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> dirty,
  Value<int> rowid,
});
typedef $$PantryRowsTableUpdateCompanionBuilder = PantryRowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double?> quantity,
  Value<String?> unit,
  Value<String> aliases,
  Value<int> wanted,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> dirty,
  Value<int> rowid,
});

class $$PantryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PantryRowsTable> {
  $$PantryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wanted => $composableBuilder(
      column: $table.wanted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));
}

class $$PantryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryRowsTable> {
  $$PantryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wanted => $composableBuilder(
      column: $table.wanted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$PantryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryRowsTable> {
  $$PantryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<int> get wanted =>
      $composableBuilder(column: $table.wanted, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$PantryRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PantryRowsTable,
    PantryRow,
    $$PantryRowsTableFilterComposer,
    $$PantryRowsTableOrderingComposer,
    $$PantryRowsTableAnnotationComposer,
    $$PantryRowsTableCreateCompanionBuilder,
    $$PantryRowsTableUpdateCompanionBuilder,
    (PantryRow, BaseReferences<_$AppDatabase, $PantryRowsTable, PantryRow>),
    PantryRow,
    PrefetchHooks Function()> {
  $$PantryRowsTableTableManager(_$AppDatabase db, $PantryRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PantryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PantryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PantryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String> aliases = const Value.absent(),
            Value<int> wanted = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PantryRowsCompanion(
            id: id,
            name: name,
            quantity: quantity,
            unit: unit,
            aliases: aliases,
            wanted: wanted,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<double?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String> aliases = const Value.absent(),
            Value<int> wanted = const Value.absent(),
            Value<String> source = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PantryRowsCompanion.insert(
            id: id,
            name: name,
            quantity: quantity,
            unit: unit,
            aliases: aliases,
            wanted: wanted,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PantryRowsTable, PantryRow>(table),
                    BaseReferences<_$AppDatabase, $PantryRowsTable, PantryRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PantryRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PantryRowsTable,
    PantryRow,
    $$PantryRowsTableFilterComposer,
    $$PantryRowsTableOrderingComposer,
    $$PantryRowsTableAnnotationComposer,
    $$PantryRowsTableCreateCompanionBuilder,
    $$PantryRowsTableUpdateCompanionBuilder,
    (PantryRow, BaseReferences<_$AppDatabase, $PantryRowsTable, PantryRow>),
    PantryRow,
    PrefetchHooks Function()>;
typedef $$MetaRowsTableCreateCompanionBuilder = MetaRowsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaRowsTableUpdateCompanionBuilder = MetaRowsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MetaRowsTable> {
  $$MetaRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaRowsTable> {
  $$MetaRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaRowsTable> {
  $$MetaRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetaRowsTable,
    MetaRow,
    $$MetaRowsTableFilterComposer,
    $$MetaRowsTableOrderingComposer,
    $$MetaRowsTableAnnotationComposer,
    $$MetaRowsTableCreateCompanionBuilder,
    $$MetaRowsTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $MetaRowsTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()> {
  $$MetaRowsTableTableManager(_$AppDatabase db, $MetaRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaRowsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaRowsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MetaRowsTable, MetaRow>(table),
                    BaseReferences<_$AppDatabase, $MetaRowsTable, MetaRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MetaRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetaRowsTable,
    MetaRow,
    $$MetaRowsTableFilterComposer,
    $$MetaRowsTableOrderingComposer,
    $$MetaRowsTableAnnotationComposer,
    $$MetaRowsTableCreateCompanionBuilder,
    $$MetaRowsTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $MetaRowsTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DishRowsTableTableManager get dishRows =>
      $$DishRowsTableTableManager(_db, _db.dishRows);
  $$VersionRowsTableTableManager get versionRows =>
      $$VersionRowsTableTableManager(_db, _db.versionRows);
  $$CookLogRowsTableTableManager get cookLogRows =>
      $$CookLogRowsTableTableManager(_db, _db.cookLogRows);
  $$CookTimerRowsTableTableManager get cookTimerRows =>
      $$CookTimerRowsTableTableManager(_db, _db.cookTimerRows);
  $$PantryRowsTableTableManager get pantryRows =>
      $$PantryRowsTableTableManager(_db, _db.pantryRows);
  $$MetaRowsTableTableManager get metaRows =>
      $$MetaRowsTableTableManager(_db, _db.metaRows);
}
