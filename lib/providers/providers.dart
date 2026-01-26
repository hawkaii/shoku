import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_service.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/models/recipe.dart';
import '../data/models/shopping_list.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Repository Provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.read(apiServiceProvider));
});

// Recipes List Provider
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.read(recipeRepositoryProvider);
  return await repository.getRecipes(limit: 100);
});

// Single Recipe Provider
final recipeDetailProvider = FutureProvider.family<Recipe, int>((ref, id) async {
  final repository = ref.read(recipeRepositoryProvider);
  return await repository.getRecipeById(id);
});

// Shopping List Provider
final shoppingListProvider = FutureProvider.family<ShoppingList, int>((ref, recipeId) async {
  final repository = ref.read(recipeRepositoryProvider);
  return await repository.getShoppingList(recipeId);
});

// Current Navigation Index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Recipes Provider
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipesAsync = ref.watch(recipesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return recipesAsync.when(
    data: (recipes) {
      if (searchQuery.isEmpty) {
        return recipes;
      }
      return recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(searchQuery) ||
               recipe.description.toLowerCase().contains(searchQuery) ||
               recipe.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
