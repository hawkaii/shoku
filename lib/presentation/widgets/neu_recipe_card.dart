import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/time_formatter.dart';
import '../../data/models/recipe.dart';

class NeuRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final Color backgroundColor;

  const NeuRecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
    this.backgroundColor = NeuColors.neuLavender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: NeuSpacing.md),
        child: NeuContainer(
          borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
          color: backgroundColor,
          borderWidth: NeuSpacing.borderWidth,
          borderColor: NeuColors.neuBlack,
          offset: const Offset(NeuSpacing.shadowOffsetX, NeuSpacing.shadowOffsetY),
          shadowColor: NeuColors.neuBlack,
          child: Padding(
            padding: const EdgeInsets.all(NeuSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  recipe.title,
                  style: NeuTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: NeuSpacing.sm),

                // Description
                if (recipe.description.isNotEmpty)
                  Text(
                    recipe.description,
                    style: NeuTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: NeuSpacing.md),

                // Time & servings
                Row(
                  children: [
                    if (recipe.totalTime != null) ...[
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        TimeFormatter.formatCookTime(recipe.totalTime),
                        style: NeuTextStyles.bodySmall,
                      ),
                    ],
                    if (recipe.servings != null) ...[
                      const SizedBox(width: NeuSpacing.md),
                      const Icon(Icons.restaurant, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} servings',
                        style: NeuTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),

                // Tags
                if (recipe.tags.isNotEmpty) ...[
                  const SizedBox(height: NeuSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recipe.tags.take(3).map((tag) => _buildTag(tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: NeuColors.neuBlack, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$tag',
        style: NeuTextStyles.tag,
      ),
    );
  }
}
