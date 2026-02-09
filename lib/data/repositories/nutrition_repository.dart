import '../models/nutrition.dart';
import '../services/nutrition_api_service.dart';

class NutritionRepository {
  final NutritionApiService _apiService;

  NutritionRepository(this._apiService);

  Future<Map<String, dynamic>> healthCheck() async {
    return await _apiService.healthCheck();
  }

  Future<NutritionData> getNutrition({
    required String userId,
    required String food,
    required double amount,
  }) async {
    return await _apiService.getNutrition(
      userId: userId,
      food: food,
      amount: amount,
    );
  }

  Future<NutritionBoard> getNutritionBoard(String userId) async {
    return await _apiService.getNutritionBoard(userId);
  }

  Future<MealLog> logMeal({
    required String userId,
    required String dish,
    required NutritionData nutrition,
  }) async {
    return await _apiService.logMeal(
      userId: userId,
      dish: dish,
      nutrition: nutrition,
    );
  }

  Future<List<String>> suggestRecipes(List<String> ingredients) async {
    return await _apiService.suggestRecipes(ingredients);
  }

  Future<List<String>> scanGroceryBill({
    required String userId,
    required String imageBase64,
  }) async {
    return await _apiService.scanGroceryBill(
      userId: userId,
      imageBase64: imageBase64,
    );
  }
}
