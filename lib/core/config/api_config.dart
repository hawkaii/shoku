class ApiConfig {
  // For Android Emulator use: http://10.0.2.2:8000
  // For Physical Device use: http://YOUR_COMPUTER_IP:8000 (e.g., http://192.168.1.5:8000)
  // For Production use: https://your-api-domain.com

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://9767b3334c10.ngrok-free.app',
  );

  // API Endpoints
  static const String recipes = '/api/recipes';
  static const String extractRecipe = '/api/recipes/extract';

  static String recipeById(int id) => '/api/recipes/$id';
  static String deleteRecipe(int id) => '/api/recipes/$id';
  static String shoppingList(int recipeId) =>
      '/api/recipes/$recipeId/shopping-list';
}
