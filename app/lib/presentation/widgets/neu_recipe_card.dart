import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/time_formatter.dart';
import '../../data/models/recipe.dart';

class NeuRecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final Color backgroundColor;
  final bool isNew;

  const NeuRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.backgroundColor = NeuColors.neuLavender,
    this.isNew = false,
  });

  @override
  State<NeuRecipeCard> createState() => _NeuRecipeCardState();
}

class _NeuRecipeCardState extends State<NeuRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isNew) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: NeuSpacing.md),
          child: Stack(
            children: [
              NeuContainer(
                borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                color: widget.backgroundColor,
                borderWidth: widget.isNew ? 4 : NeuSpacing.borderWidth,
                borderColor: widget.isNew
                    ? NeuColors.neuYellow
                    : NeuColors.neuBlack,
                offset: const Offset(
                    NeuSpacing.shadowOffsetX, NeuSpacing.shadowOffsetY),
                shadowColor: NeuColors.neuBlack,
                child: Padding(
                  padding: const EdgeInsets.all(NeuSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.recipe.title,
                        style: NeuTextStyles.heading3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: NeuSpacing.sm),

                      // Description
                      if (widget.recipe.description.isNotEmpty)
                        Text(
                          widget.recipe.description,
                          style: NeuTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: NeuSpacing.md),

                      // Time & servings
                      Row(
                        children: [
                          if (widget.recipe.totalTime != null) ...[
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              TimeFormatter.formatCookTime(
                                  widget.recipe.totalTime),
                              style: NeuTextStyles.bodySmall,
                            ),
                          ],
                          if (widget.recipe.servings != null) ...[
                            const SizedBox(width: NeuSpacing.md),
                            const Icon(Icons.restaurant, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.recipe.servings} servings',
                              style: NeuTextStyles.bodySmall,
                            ),
                          ],
                        ],
                      ),

                      // Tags
                      if (widget.recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: NeuSpacing.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.recipe.tags
                              .take(3)
                              .map((tag) => _buildTag(tag))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // NEW badge
              if (widget.isNew)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NeuColors.neuYellow,
                      border:
                          Border.all(color: NeuColors.neuBlack, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: NeuColors.neuBlack,
                      ),
                    ),
                  ),
                ),
            ],
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
