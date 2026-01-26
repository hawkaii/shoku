import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/shopping_list/shopping_list_screen.dart';
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
  ],
);
