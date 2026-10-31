import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../providers/providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: recipeAsync.when(
        data: (recipe) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button
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
                        icon: const Icon(Icons.arrow_back, color: NeuColors.neuBlack),
                      ),
                      const SizedBox(width: NeuSpacing.md),
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: NeuTextStyles.heading2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Description
                      if (recipe.description.isNotEmpty) ...[
                        NeuContainer(
                          borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                          color: NeuColors.neuLavender,
                          borderWidth: 3,
                          borderColor: NeuColors.neuBlack,
                          offset: const Offset(4, 4),
                          shadowColor: NeuColors.neuBlack,
                          child: Padding(
                            padding: const EdgeInsets.all(NeuSpacing.md),
                            child: Text(recipe.description, style: NeuTextStyles.body),
                          ),
                        ),
                        const SizedBox(height: NeuSpacing.md),
                      ],

                      // Info Row
                      Row(
                        children: [
                          if (recipe.totalTime != null)
                            Expanded(
                              child: _buildInfoCard(
                                '⏱️',
                                TimeFormatter.formatCookTime(recipe.totalTime),
                                NeuColors.neuMint,
                              ),
                            ),
                          if (recipe.servings != null) ...[
                            const SizedBox(width: NeuSpacing.sm),
                            Expanded(
                              child: _buildInfoCard(
                                '🍽️',
                                '${recipe.servings} servings',
                                NeuColors.neuSkyBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: NeuSpacing.md),

                      // Tags
                      if (recipe.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.tags.map((tag) => _buildTag(tag)).toList(),
                        ),
                        const SizedBox(height: NeuSpacing.md),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: NeuTextButton(
                              borderRadius: BorderRadius.circular(8),
                              buttonColor: NeuColors.neuCoral,
                              buttonHeight: 50,
                              enableAnimation: true,
                              onPressed: () {
                                context.push('/shopping-list/$recipeId');
                              },
                              text: Text('🛒 SHOPPING LIST', style: NeuTextStyles.button),
                            ),
                          ),
                          const SizedBox(width: NeuSpacing.sm),
                          NeuIconButton(
                            borderRadius: BorderRadius.circular(8),
                            buttonColor: NeuColors.neuPink,
                            buttonHeight: 50,
                            buttonWidth: 50,
                            enableAnimation: true,
                            onPressed: () async {
                              final url = Uri.parse(recipe.sourceUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                            icon: const Icon(Icons.play_arrow, color: NeuColors.neuBlack),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeuSpacing.lg),

                      // Ingredients
                      Text('INGREDIENTS', style: NeuTextStyles.heading2),
                      const SizedBox(height: NeuSpacing.md),
                      NeuContainer(
                        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                        color: NeuColors.neuYellow,
                        borderWidth: 3,
                        borderColor: NeuColors.neuBlack,
                        offset: const Offset(4, 4),
                        shadowColor: NeuColors.neuBlack,
                        child: Padding(
                          padding: const EdgeInsets.all(NeuSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: recipe.ingredients.map((ingredient) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontSize: 20)),
                                    Expanded(
                                      child: Text(
                                        ingredient.displayText,
                                        style: NeuTextStyles.body,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: NeuSpacing.lg),

                      // Steps
                      Text('INSTRUCTIONS', style: NeuTextStyles.heading2),
                      const SizedBox(height: NeuSpacing.md),
                      ...recipe.steps.map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: NeuSpacing.md),
                          child: NeuContainer(
                            borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                            color: NeuColors.neuMint,
                            borderWidth: 3,
                            borderColor: NeuColors.neuBlack,
                            offset: const Offset(4, 4),
                            shadowColor: NeuColors.neuBlack,
                            child: Padding(
                              padding: const EdgeInsets.all(NeuSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: NeuColors.neuBlack,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${step.stepNumber}',
                                        style: NeuTextStyles.body.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: NeuSpacing.md),
                                  Expanded(
                                    child: Text(step.instruction, style: NeuTextStyles.body),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: NeuSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeuColors.neuBlack),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❌', style: TextStyle(fontSize: 64)),
              const SizedBox(height: NeuSpacing.md),
              Text('Error loading recipe', style: NeuTextStyles.heading2),
              const SizedBox(height: NeuSpacing.sm),
              Padding(
                padding: const EdgeInsets.all(NeuSpacing.md),
                child: Text(
                  error.toString(),
                  style: NeuTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String emoji, String text, Color color) {
    return NeuContainer(
      borderRadius: BorderRadius.circular(8),
      color: color,
      borderWidth: 3,
      borderColor: NeuColors.neuBlack,
      offset: const Offset(3, 3),
      shadowColor: NeuColors.neuBlack,
      child: Padding(
        padding: const EdgeInsets.all(NeuSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: NeuTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: NeuColors.neuBlack, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('#$tag', style: NeuTextStyles.tag),
    );
  }
}
