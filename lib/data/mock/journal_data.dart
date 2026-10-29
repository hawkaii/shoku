import 'package:flutter/material.dart';

/// The journal model: a Dish you cook repeatedly, each attempt a version,
/// each night a cook log. This is the whole product.
enum DishStatus { wantToTry, inProgress, signature }

enum CookOutcome {
  needsWork,
  good,
  nailedIt;

  String get label => switch (this) {
        CookOutcome.nailedIt => 'Nailed it',
        CookOutcome.good => 'Good',
        CookOutcome.needsWork => 'Needs work',
      };

  String get upper => switch (this) {
        CookOutcome.nailedIt => 'NAILED IT',
        CookOutcome.good => 'GOOD',
        CookOutcome.needsWork => 'NEEDS WORK',
      };
}

class RecipeVersion {
  final int number;
  final List<String> changes;
  final List<String> ingredients;
  final DateTime createdAt;

  const RecipeVersion({
    required this.number,
    required this.changes,
    required this.ingredients,
    required this.createdAt,
  });
}

class CookLog {
  final String id;
  final DateTime cookedAt;
  final int versionNumber;
  final String photoUrl;
  final CookOutcome outcome;
  final String note;
  final List<String> changes;

  const CookLog({
    required this.id,
    required this.cookedAt,
    required this.versionNumber,
    required this.photoUrl,
    required this.outcome,
    required this.note,
    required this.changes,
  });
}

class Dish {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final String sourceHandle;
  final DishStatus status;
  final List<RecipeVersion> versions;
  final List<CookLog> cooks;
  final int minutes;

  const Dish({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.sourceHandle,
    required this.status,
    required this.versions,
    required this.cooks,
    required this.minutes,
  });

  int get cookCount => cooks.length;
  int get currentVersion => versions.length;
  CookLog? get lastCook => cooks.isEmpty ? null : cooks.first;
  bool get hasPhoto => coverUrl.isNotEmpty;

  String get outcomeLabel => switch (lastCook?.outcome) {
        CookOutcome.nailedIt => 'Nailed it',
        CookOutcome.good => 'Good',
        CookOutcome.needsWork => 'Needs work',
        null => 'Not cooked yet',
      };
}

const _u = 'https://images.unsplash.com/';
const _q = '?auto=format&fit=crop&w=900&q=70';

class JournalData {
  static final DateTime _now = DateTime.now();

  static DateTime _ago(int days) => _now.subtract(Duration(days: days));

  static final List<Dish> dishes = [
    Dish(
      id: 'mousse',
      title: 'Protein Rich Mousse',
      subtitle: 'Four ingredients, no oven, set overnight.',
      coverUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=900&q=70',
      sourceHandle: '@highprotein.eats',
      status: DishStatus.signature,
      minutes: 12,
      versions: [
        RecipeVersion(
          number: 1,
          changes: const ['First attempt'],
          ingredients: const ['4 eggs', '3 tbsp cocoa', '2 tbsp honey', 'pinch of salt'],
          createdAt: _ago(46),
        ),
        RecipeVersion(
          number: 2,
          changes: const ['+1 tbsp cocoa', 'Chilled 4 h instead of 2'],
          ingredients: const ['4 eggs', '4 tbsp cocoa', '2 tbsp honey', 'pinch of salt'],
          createdAt: _ago(21),
        ),
        RecipeVersion(
          number: 3,
          changes: const ['Whipped whites separately', 'Flaked salt on top'],
          ingredients: const ['4 eggs', '4 tbsp cocoa', '2 tbsp honey', 'flaked salt'],
          createdAt: _ago(4),
        ),
      ],
      cooks: [
        CookLog(
          id: 'c1',
          cookedAt: _ago(4),
          versionNumber: 3,
          photoUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.nailedIt,
          note: 'Folding the whites separately is the whole trick. Never going back.',
          changes: const ['Whipped whites separately', 'Flaked salt on top'],
        ),
        CookLog(
          id: 'c2',
          cookedAt: _ago(21),
          versionNumber: 2,
          photoUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.good,
          note: 'Too sweet. The cocoa bump helped but honey needs to come down.',
          changes: const ['+1 tbsp cocoa', 'Chilled 4 h'],
        ),
        CookLog(
          id: 'c3',
          cookedAt: _ago(46),
          versionNumber: 1,
          photoUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.needsWork,
          note: 'Flat and dense. Whipping order was wrong.',
          changes: const ['First attempt'],
        ),
      ],
    ),
    Dish(
      id: 'chicken',
      title: 'Crispy Chilli Chicken',
      subtitle: 'Takeaway crunch without a deep fryer.',
      coverUrl: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&q=70',
      sourceHandle: 'Kitchen Sanctuary',
      status: DishStatus.inProgress,
      minutes: 35,
      versions: [
        RecipeVersion(
          number: 1,
          changes: const ['First attempt'],
          ingredients: const ['500 g thigh', '3 tbsp cornflour', '2 tbsp soy', '1 tbsp chilli paste'],
          createdAt: _ago(30),
        ),
        RecipeVersion(
          number: 2,
          changes: const ['Air-fried at 200°C', 'Sauce off the heat'],
          ingredients: const ['500 g thigh', '4 tbsp cornflour', '2 tbsp soy', '1 tbsp chilli paste'],
          createdAt: _ago(9),
        ),
      ],
      cooks: [
        CookLog(
          id: 'c4',
          cookedAt: _ago(9),
          versionNumber: 2,
          photoUrl: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.good,
          note: 'Crust held for five minutes, then went soft. Try a drier marinade next.',
          changes: const ['Air-fried at 200°C', 'Sauce off the heat'],
        ),
        CookLog(
          id: 'c5',
          cookedAt: _ago(30),
          versionNumber: 1,
          photoUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.needsWork,
          note: 'Bready crust, too much flour. Sauce drowned it.',
          changes: const ['First attempt'],
        ),
      ],
    ),
    Dish(
      id: 'focaccia',
      title: 'No-Knead Focaccia',
      subtitle: 'Eighteen hours of doing nothing.',
      coverUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=70',
      sourceHandle: 'Bread Code',
      status: DishStatus.inProgress,
      minutes: 25,
      versions: [
        RecipeVersion(
          number: 1,
          changes: const ['First attempt'],
          ingredients: const ['500 g flour', '400 ml water', '7 g yeast', '80 ml oil', '12 g salt'],
          createdAt: _ago(12),
        ),
      ],
      cooks: [
        CookLog(
          id: 'c6',
          cookedAt: _ago(12),
          versionNumber: 1,
          photoUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=70',
          outcome: CookOutcome.good,
          note: 'Pale top. Needs a hotter oven and three more minutes.',
          changes: const ['First attempt'],
        ),
      ],
    ),
    Dish(
      id: 'noodles',
      title: 'Chilli Garlic Noodles',
      subtitle: 'Fifteen minutes, one pan, too much garlic.',
      coverUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=900&q=70',
      sourceHandle: '@weeknight.kitchen',
      status: DishStatus.wantToTry,
      minutes: 15,
      versions: [
        RecipeVersion(
          number: 1,
          changes: const ['Not cooked yet'],
          ingredients: const ['200 g noodles', '6 garlic cloves', '2 tbsp soy', '1 tbsp chilli oil'],
          createdAt: _ago(2),
        ),
      ],
      cooks: const [],
    ),
  ];

  static List<CookLog> get allCooks {
    final logs = <CookLog>[];
    for (final dish in dishes) {
      logs.addAll(dish.cooks);
    }
    logs.sort((a, b) => b.cookedAt.compareTo(a.cookedAt));
    return logs;
  }

  static Dish dishFor(String id) =>
      dishes.firstWhere((d) => d.id == id, orElse: () => dishes.first);

  static int get totalCooks => allCooks.length;
  static int get totalUpgrades =>
      dishes.fold(0, (sum, d) => sum + (d.versions.length - 1));
  static int get signatureCount =>
      dishes.where((d) => d.status == DishStatus.signature).length;

  const JournalData._();
}
