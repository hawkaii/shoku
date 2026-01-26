import '../models/recipe.dart';
import '../models/shopping_list.dart';
import '../services/api_service.dart';

class RecipeRepository {
  final ApiService _apiService;

  RecipeRepository(this._apiService);

  Future<List<Recipe>> getRecipes({int skip = 0, int limit = 10}) async {
    return await _apiService.getRecipes(skip: skip, limit: limit);
  }

  Future<Recipe> extractRecipe(String url) async {
    return await _apiService.extractRecipe(url);
  }

  Future<Recipe> getRecipeById(int id) async {
    return await _apiService.getRecipeById(id);
  }

  Future<void> deleteRecipe(int id) async {
    await _apiService.deleteRecipe(id);
  }

  Future<ShoppingList> getShoppingList(int recipeId) async {
    return await _apiService.getShoppingList(recipeId);
  }
}
