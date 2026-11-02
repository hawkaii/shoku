import 'journal_data.dart';

/// The one recipe a signed-out kitchen gets.
///
/// It exists so the loop — cook, debrief, fork, deduct — can be felt before an
/// account is made. It is written as a local row the sync layer never sees, and
/// it is deleted the first time somebody signs in: it must never become part of
/// somebody's journal.
class SampleRecipe {
  static const dishId = 'sample-paneer-tikka';

  static const ingredients = [
    '400 g paneer',
    '2 tbsp yoghurt',
    '1 tsp chilli powder',
    '2 tbsp oil',
    'salt',
  ];

  static const steps = [
    'Cube the paneer and pat it dry.',
    'Whisk the yoghurt with chilli powder and salt.',
    'Fold the paneer through the yoghurt and leave it ten minutes.',
    'Heat the oil in a wide pan until it shimmers.',
    'Sear the paneer in one layer, turning once, and serve at once.',
  ];

  static Dish dish() => Dish(
        id: dishId,
        title: 'Paneer Tikka',
        subtitle: 'A sample recipe — cook it once, make it yours',
        coverUrl: '',
        sourceHandle: '@shoku',
        status: DishStatus.toCook,
        minutes: 25,
        steps: steps,
        versions: [
          RecipeVersion(
            id: '$dishId-v1',
            number: 1,
            changes: const [],
            ingredients: ingredients,
            createdAt: DateTime(2026, 1, 1),
            steps: steps,
            tags: const ['sample'],
          ),
        ],
        cooks: const [],
      );
}
