import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_recipe_card.dart';
import 'widgets/home_search_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final filteredRecipes = ref.watch(filteredRecipesProvider);

    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(NeuSpacing.md),
              child: Row(
                children: [
                  Text('🍕', style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: NeuSpacing.sm),
                  Text('FOOD FINDER', style: NeuTextStyles.heading1),
                ],
              ),
            ),

            // Search Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: NeuSpacing.md),
              child: HomeSearchBar(),
            ),
            const SizedBox(height: NeuSpacing.md),

            // Recipe List
            Expanded(
              child: recipesAsync.when(
                data: (_) {
                  if (filteredRecipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🍽️', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: NeuSpacing.md),
                          Text(
                            'No recipes found',
                            style: NeuTextStyles.heading2,
                          ),
                          const SizedBox(height: NeuSpacing.sm),
                          Text(
                            'Add a recipe from YouTube!',
                            style: NeuTextStyles.body,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(recipesProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        final colors = [
                          NeuColors.neuLavender,
                          NeuColors.neuMint,
                          NeuColors.neuSkyBlue,
                          NeuColors.neuCoral,
                        ];

                        return NeuRecipeCard(
                          recipe: recipe,
                          backgroundColor: colors[index % colors.length],
                          onTap: () => context.push('/recipe/${recipe.id}'),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: NeuColors.neuBlack,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❌', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: NeuSpacing.md),
                      Text('Error loading recipes', style: NeuTextStyles.heading2),
                      const SizedBox(height: NeuSpacing.sm),
                      Text(
                        error.toString(),
                        style: NeuTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
