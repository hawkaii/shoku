import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_data.dart';

/// Web preview helpers: `?screen=home&theme=dark` opens a screen directly.
/// On a real device Uri.base carries no query, so nothing changes.
final previewScreen = Uri.base.queryParameters['screen'];
final previewTheme = Uri.base.queryParameters['theme'];
final previewStatic = Uri.base.queryParameters.containsKey('static');

/// Theme mode — Account → Appearance writes here.
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => previewTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
);

/// Onboarding gate. Previewing a screen skips the flow.
final onboardingDoneProvider = StateProvider<bool>((ref) => previewScreen != null);

/// Feed filter for Home / Stash.
enum FeedFilter { all, recipes, wisdom }

final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);

final savedItemsProvider = Provider<List<SavedItem>>((ref) => MockData.items);

final filteredItemsProvider = Provider<List<SavedItem>>((ref) {
  final filter = ref.watch(feedFilterProvider);
  final items = ref.watch(savedItemsProvider);
  switch (filter) {
    case FeedFilter.all:
      return items;
    case FeedFilter.recipes:
      return items.where((i) => i.kind == ItemKind.recipe).toList();
    case FeedFilter.wisdom:
      return items.where((i) => i.kind == ItemKind.wisdom).toList();
  }
});

final selectedItemProvider = StateProvider<SavedItem?>((ref) => null);

final collectionsProvider = Provider<List<StashCollection>>((ref) => MockData.collections);

final pantryProvider = Provider<List<PantryItem>>((ref) => MockData.pantry);

/// Shopping list with local toggle state (mock only).
class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingNotifier() : super(MockData.shoppingSeed());

  void toggle(int index) {
    final item = state[index];
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          ShoppingItem(item.name, item.quantity, item.category, done: !item.done)
        else
          state[i],
    ];
  }

  void add(ShoppingItem item) => state = [...state, item];

  void remove(int index) =>
      state = [for (var i = 0; i < state.length; i++) if (i != index) state[i]];
}

final shoppingProvider =
    StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>((ref) => ShoppingNotifier());

/// Gamification — deliberately quiet: one number each.
final savesBalanceProvider = StateProvider<int>((ref) => 17);
final weeklySavesUsedProvider = StateProvider<int>((ref) => 3);
final streakDaysProvider = StateProvider<int>((ref) => 4);
final levelProvider = StateProvider<int>((ref) => 3);
final xpProvider = StateProvider<int>((ref) => 240);
final xpToNextProvider = StateProvider<int>((ref) => 320);

/// The live timer on a recipe step. Mock: a running countdown per step index.
final activeTimerStepProvider = StateProvider<int?>((ref) => null);

final plansProvider = Provider<List<PlanTier>>((ref) => MockData.plans);
final helpTopicsProvider = Provider<List<Map<String, String>>>((ref) => MockData.helpTopics);

final profileNameProvider = StateProvider<String>((ref) => 'Parthib');
final profileHandleProvider = StateProvider<String>((ref) => '@parthib');
