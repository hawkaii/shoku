class NutritionApiConfig {
  // Both Recipe and Nutrition APIs are on the same server
  // Production: https://e0ae2d8b1eca.ngrok-free.app
  // Local: http://10.0.2.2:8000 (Android Emulator) or http://localhost:8000

  static const String baseUrl = String.fromEnvironment(
    'NUTRITION_API_BASE_URL',
    defaultValue: 'https://9767b3334c10.ngrok-free.app',
  );

  // API Endpoints (all use /api/ prefix)
  static const String health = '/api/health';
  static const String nutrition = '/api/nutrition';
  static const String nutritionBoard = '/api/nutrition/board';
  static const String nutritionLock = '/api/nutrition/lock';
  static const String recipeSuggest = '/api/recipes/suggest';
  static const String ocrGroceryBill = '/api/ocr/grocery-bill';
}
