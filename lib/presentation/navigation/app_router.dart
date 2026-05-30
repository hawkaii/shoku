import 'package:go_router/go_router.dart';
import '../../data/models/recipe.dart';
import '../../data/models/dish_suggestion.dart';
import '../screens/home/home_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/shopping_list/shopping_list_screen.dart';
import '../screens/nutrition/nutrition_screen.dart';
import '../screens/nutrition/food_lookup_screen.dart';
import '../screens/nutrition/scan_bill_screen.dart';
import '../screens/ingredient_flow/ingredient_input_screen.dart';
import '../screens/ingredient_flow/ingredients_list_screen.dart';
import '../screens/ingredient_flow/recipe_suggestions_screen.dart';
import '../screens/ingredient_flow/youtube_webview_screen.dart';
import '../screens/ingredient_flow/recipe_summary_screen.dart';
import 'main_navigation.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/nutrition',
          builder: (context, state) => const NutritionScreen(),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddRecipeScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RecipeDetailScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: '/shopping-list/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ShoppingListScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: '/nutrition/lookup',
      builder: (context, state) => const FoodLookupScreen(),
    ),
    GoRoute(
      path: '/nutrition/log',
      builder: (context, state) => const FoodLookupScreen(), // Placeholder
    ),
    GoRoute(
      path: '/nutrition/recipes',
      builder: (context, state) => const FoodLookupScreen(), // Placeholder
    ),
    GoRoute(
      path: '/nutrition/scan',
      builder: (context, state) => const ScanBillScreen(),
    ),
    // Ingredient-to-Recipe Flow
    GoRoute(
      path: '/ingredient-input',
      builder: (context, state) => const IngredientInputScreen(),
    ),
    GoRoute(
      path: '/ingredients-list',
      builder: (context, state) => const IngredientsListScreen(),
    ),
    GoRoute(
      path: '/recipe-suggestions',
      builder: (context, state) {
        final dishes = state.extra as List<DishSuggestion>;
        return RecipeSuggestionsScreen(dishes: dishes);
      },
    ),
    GoRoute(
      path: '/youtube-webview',
      builder: (context, state) {
        final youtubeUrl = state.extra as String;
        return YouTubeWebViewScreen(youtubeUrl: youtubeUrl);
      },
    ),
    GoRoute(
      path: '/recipe-summary',
      builder: (context, state) {
        final recipe = state.extra as Recipe;
        return RecipeSummaryScreen(recipe: recipe);
      },
    ),
  ],
);
