import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/config/api_config.dart';
import '../models/recipe.dart';
import '../models/shopping_list.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logger for debugging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // Get all recipes with pagination
  Future<List<Recipe>> getRecipes({int skip = 0, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConfig.recipes,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      return (response.data as List)
          .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Extract recipe from YouTube URL
  Future<Recipe> extractRecipe(String url) async {
    try {
      final response = await _dio.post(
        ApiConfig.extractRecipe,
        data: {'url': url},
      );

      return Recipe.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get recipe by ID
  Future<Recipe> getRecipeById(int id) async {
    try {
      final response = await _dio.get(ApiConfig.recipeById(id));
      return Recipe.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(int id) async {
    try {
      await _dio.delete(ApiConfig.deleteRecipe(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get shopping list for recipe
  Future<ShoppingList> getShoppingList(int recipeId) async {
    try {
      final response = await _dio.post(ApiConfig.shoppingList(recipeId));
      return ShoppingList.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          return error.response?.data['detail'] ?? 'Invalid request';
        } else if (statusCode == 404) {
          return 'Recipe not found';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Something went wrong ($statusCode)';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      default:
        return 'Network error. Please check your connection.';
    }
  }
}
