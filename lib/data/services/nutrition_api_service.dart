import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/config/nutrition_api_config.dart';
import '../models/nutrition.dart';
import '../models/dish_suggestion.dart';
import '../models/youtube_video.dart';

class NutritionApiService {
  late final Dio _dio;

  NutritionApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: NutritionApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get(NutritionApiConfig.health);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get nutrition for a food
  Future<NutritionData> getNutrition({
    required String userId,
    required String food,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.nutrition,
        data: {
          'user_id': userId,
          'food': food,
          'amount': amount,
        },
      );
      return NutritionData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's nutrition board (totals)
  Future<NutritionBoard> getNutritionBoard(String userId) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.nutritionBoard,
        data: {'user_id': userId},
      );
      return NutritionBoard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Log a meal (lock dish)
  Future<MealLog> logMeal({
    required String userId,
    required String dish,
    required NutritionData nutrition,
  }) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.nutritionLock,
        data: {
          'user_id': userId,
          'dish': dish,
          'nutrition': nutrition.toJson(),
        },
      );
      return MealLog.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get recipe suggestions from ingredients
  Future<List<DishSuggestion>> suggestRecipes(List<String> ingredients) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.recipeSuggest,
        data: {'ingredients': ingredients},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['dishes'] as List<dynamic>)
          .map((e) => DishSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Scan grocery bill (OCR)
  Future<List<String>> scanGroceryBill({
    required String userId,
    required String imageBase64,
  }) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.ocrGroceryBill,
        data: {
          'user_id': userId,
          'image_base64': imageBase64,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return (data['items'] as List<dynamic>).map((e) => e as String).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search YouTube videos for a dish (placeholder endpoint)
  Future<List<YouTubeVideo>> searchYouTubeVideos(String query) async {
    try {
      final response = await _dio.post(
        NutritionApiConfig.youtubeSearch,
        data: {'query': query},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['videos'] as List<dynamic>)
          .map((e) => YouTubeVideo.fromJson(e as Map<String, dynamic>))
          .toList();
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
          return 'Resource not found';
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
