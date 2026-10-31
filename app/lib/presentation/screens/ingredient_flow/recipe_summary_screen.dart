import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../data/models/recipe.dart';
import '../../../providers/providers.dart';

class RecipeSummaryScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeSummaryScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  NeuIconButton(
                    borderRadius: BorderRadius.circular(8),
                    buttonColor: NeuColors.neuYellow,
                    buttonHeight: 50,
                    buttonWidth: 50,
                    enableAnimation: true,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: NeuColors.neuBlack),
                  ),
                  const SizedBox(width: NeuSpacing.md),
                  Expanded(
                    child: Text('Recipe Summary',
                        style: NeuTextStyles.heading1),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: NeuSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title card
                    NeuContainer(
                      borderRadius: BorderRadius.circular(
                          NeuSpacing.borderRadius),
                      color: NeuColors.neuYellow,
                      borderWidth: 3,
                      borderColor: NeuColors.neuBlack,
                      offset: const Offset(4, 4),
                      shadowColor: NeuColors.neuBlack,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(NeuSpacing.md),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('🍽️ ${recipe.title}',
                                style: NeuTextStyles.heading2),
                            if (recipe.description.isNotEmpty) ...[
                              const SizedBox(
                                  height: NeuSpacing.sm),
                              Text(recipe.description,
                                  style: NeuTextStyles.body),
                            ],
                            const SizedBox(height: NeuSpacing.md),
                            // Time info
                            Row(
                              children: [
                                if (recipe.prepTime != null)
                                  _buildInfoChip(
                                      '⏱️ Prep: ${recipe.prepTime}min',
                                      NeuColors.neuMint),
                                if (recipe.prepTime != null)
                                  const SizedBox(
                                      width: NeuSpacing.sm),
                                if (recipe.cookTime != null)
                                  _buildInfoChip(
                                      '🔥 Cook: ${recipe.cookTime}min',
                                      NeuColors.neuCoral),
                                if (recipe.cookTime != null)
                                  const SizedBox(
                                      width: NeuSpacing.sm),
                                if (recipe.servings != null)
                                  _buildInfoChip(
                                      '👥 ${recipe.servings} servings',
                                      NeuColors.neuSkyBlue),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: NeuSpacing.md),

                    // Ingredients
                    if (recipe.ingredients.isNotEmpty) ...[
                      NeuContainer(
                        borderRadius: BorderRadius.circular(
                            NeuSpacing.borderRadius),
                        color: NeuColors.neuMint,
                        borderWidth: 3,
                        borderColor: NeuColors.neuBlack,
                        offset: const Offset(4, 4),
                        shadowColor: NeuColors.neuBlack,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(NeuSpacing.md),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🥘',
                                      style: TextStyle(
                                          fontSize: 24)),
                                  const SizedBox(
                                      width: NeuSpacing.sm),
                                  Text('INGREDIENTS',
                                      style:
                                          NeuTextStyles.heading3),
                                ],
                              ),
                              const SizedBox(
                                  height: NeuSpacing.md),
                              ...recipe.ingredients
                                  .map((ingredient) => Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets
                                                      .only(
                                                      top: 6),
                                              width: 8,
                                              height: 8,
                                              decoration:
                                                  BoxDecoration(
                                                color: NeuColors
                                                    .neuBlack,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            4),
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    NeuSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                ingredient.displayText,
                                                style:
                                                    NeuTextStyles
                                                        .body,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: NeuSpacing.md),
                    ],

                    // Steps
                    if (recipe.steps.isNotEmpty) ...[
                      NeuContainer(
                        borderRadius: BorderRadius.circular(
                            NeuSpacing.borderRadius),
                        color: NeuColors.neuLavender,
                        borderWidth: 3,
                        borderColor: NeuColors.neuBlack,
                        offset: const Offset(4, 4),
                        shadowColor: NeuColors.neuBlack,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(NeuSpacing.md),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('📝',
                                      style: TextStyle(
                                          fontSize: 24)),
                                  const SizedBox(
                                      width: NeuSpacing.sm),
                                  Text('STEPS',
                                      style:
                                          NeuTextStyles.heading3),
                                ],
                              ),
                              const SizedBox(
                                  height: NeuSpacing.md),
                              ...recipe.steps
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final step = entry.value;
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                          bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration:
                                            BoxDecoration(
                                          color: NeuColors
                                              .neuYellow,
                                          shape:
                                              BoxShape.circle,
                                          border: Border.all(
                                            color: NeuColors
                                                .neuBlack,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${step.stepNumber}',
                                            style: NeuTextStyles
                                                .tag,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              NeuSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          step.instruction,
                                          style: NeuTextStyles
                                              .body,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: NeuSpacing.md),
                    ],

                    // Tags
                    if (recipe.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: NeuSpacing.sm,
                        runSpacing: NeuSpacing.sm,
                        children: recipe.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: NeuColors.neuSkyBlue,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color: NeuColors.neuBlack,
                                  width: 2),
                            ),
                            child:
                                Text(tag, style: NeuTextStyles.tag),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: NeuSpacing.md),
                    ],

                    const SizedBox(height: NeuSpacing.lg),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(NeuSpacing.md),
              child: GestureDetector(
                onTap: () => _saveRecipe(context, ref),
                child: NeuContainer(
                  borderRadius:
                      BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuMint,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(5, 5),
                  shadowColor: NeuColors.neuBlack,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                        horizontal: NeuSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💾',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: NeuSpacing.sm),
                        Text('SAVE RECIPE',
                            style: NeuTextStyles.button),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: NeuColors.neuBlack, width: 2),
      ),
      child: Text(text, style: NeuTextStyles.tag),
    );
  }

  void _saveRecipe(BuildContext context, WidgetRef ref) {
    // Invalidate recipes list to refetch (the recipe is already saved on the backend
    // when extracted via /api/recipes/extract)
    ref.invalidate(recipesProvider);

    // Navigate to recipe detail
    context.go('/recipe/${recipe.id}');
  }
}
