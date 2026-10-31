import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../data/models/dish_suggestion.dart';
import '../../../providers/providers.dart';

class RecipeSuggestionsScreen extends ConsumerWidget {
  final List<DishSuggestion> dishes;

  const RecipeSuggestionsScreen({Key? key, required this.dishes})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = [
      NeuColors.neuYellow,
      NeuColors.neuMint,
      NeuColors.neuPink,
      NeuColors.neuLavender,
      NeuColors.neuSkyBlue,
      NeuColors.neuCoral,
    ];

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
                    child: Text('Recipe Ideas',
                        style: NeuTextStyles.heading1),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
              child: NeuContainer(
                borderRadius:
                    BorderRadius.circular(NeuSpacing.borderRadius),
                color: NeuColors.neuSkyBlue,
                borderWidth: 3,
                borderColor: NeuColors.neuBlack,
                offset: const Offset(4, 4),
                shadowColor: NeuColors.neuBlack,
                child: Padding(
                  padding: const EdgeInsets.all(NeuSpacing.md),
                  child: Row(
                    children: [
                      const Text('👨‍🍳',
                          style: TextStyle(fontSize: 32)),
                      const SizedBox(width: NeuSpacing.md),
                      Expanded(
                        child: Text(
                          'Tap a dish to browse YouTube videos and extract a recipe!',
                          style: NeuTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: NeuSpacing.lg),

            // Dish suggestions
            Expanded(
              child: dishes.isEmpty
                  ? Center(
                      child: Text(
                        'No suggestions found.\nTry different ingredients!',
                        textAlign: TextAlign.center,
                        style: NeuTextStyles.body
                            .copyWith(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NeuSpacing.md),
                      itemCount: dishes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: NeuSpacing.md),
                      itemBuilder: (context, index) {
                        return _buildDishCard(
                          context,
                          ref,
                          dish: dishes[index],
                          color: colors[index % colors.length],
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(
    BuildContext context,
    WidgetRef ref, {
    required DishSuggestion dish,
    required Color color,
    required int index,
  }) {
    final emojis = ['🍛', '🍝', '🥘', '🍲', '🫕', '🥗'];

    return GestureDetector(
      onTap: () {
        ref.read(selectedDishProvider.notifier).state = dish.dishName;
        context.push('/youtube-webview', extra: dish.youtubeUrl);
      },
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
              Text(emojis[index % emojis.length],
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: NeuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.dishName,
                      style: NeuTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to browse YouTube recipes',
                      style: NeuTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_outline,
                  color: NeuColors.neuBlack, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
