import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionBoardAsync = ref.watch(nutritionBoardProvider);

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
                  Text('🥗', style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: NeuSpacing.sm),
                  Text('NUTRITION', style: NeuTextStyles.heading1),
                ],
              ),
            ),

            // Today's Totals
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
              child: nutritionBoardAsync.when(
                data: (board) => NeuContainer(
                  borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuMint,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Column(
                      children: [
                        Text("TODAY'S TOTALS", style: NeuTextStyles.heading2),
                        const SizedBox(height: NeuSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutrientColumn(
                              '🔥',
                              board.calories.toInt().toString(),
                              'KCAL',
                            ),
                            _buildNutrientColumn(
                              '💪',
                              board.protein.toInt().toString(),
                              'PROTEIN',
                            ),
                          ],
                        ),
                        const SizedBox(height: NeuSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutrientColumn(
                              '🍞',
                              board.carbs.toInt().toString(),
                              'CARBS',
                            ),
                            _buildNutrientColumn(
                              '🥑',
                              board.fat.toInt().toString(),
                              'FAT',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: NeuColors.neuBlack),
                ),
                error: (error, stack) => NeuContainer(
                  borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuPink,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Text(
                      'Error loading data: $error',
                      style: NeuTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: NeuSpacing.lg),

            // Action Buttons
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
                children: [
                  _buildActionCard(
                    context,
                    icon: '🔍',
                    title: 'LOOKUP FOOD',
                    description: 'Get nutrition info for any food',
                    color: NeuColors.neuYellow,
                    onTap: () => context.push('/nutrition/lookup'),
                  ),
                  const SizedBox(height: NeuSpacing.md),
                  _buildActionCard(
                    context,
                    icon: '✍️',
                    title: 'LOG MEAL',
                    description: 'Track your meals manually',
                    color: NeuColors.neuCoral,
                    onTap: () => context.push('/nutrition/log'),
                  ),
                  const SizedBox(height: NeuSpacing.md),
                  _buildActionCard(
                    context,
                    icon: '🍳',
                    title: 'RECIPE IDEAS',
                    description: 'Get suggestions from ingredients',
                    color: NeuColors.neuLavender,
                    onTap: () => context.push('/nutrition/recipes'),
                  ),
                  const SizedBox(height: NeuSpacing.md),
                  _buildActionCard(
                    context,
                    icon: '📸',
                    title: 'SCAN BILL',
                    description: 'Extract items from grocery bill',
                    color: NeuColors.neuSkyBlue,
                    onTap: () => context.push('/nutrition/scan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(value, style: NeuTextStyles.heading1.copyWith(fontSize: 28)),
        Text(label, style: NeuTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
        color: color,
        borderWidth: 3,
        borderColor: NeuColors.neuBlack,
        offset: const Offset(4, 4),
        shadowColor: NeuColors.neuBlack,
        child: Padding(
          padding: const EdgeInsets.all(NeuSpacing.md),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: NeuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: NeuTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(description, style: NeuTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: NeuColors.neuBlack),
            ],
          ),
        ),
      ),
    );
  }
}
