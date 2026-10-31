import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';

class ShoppingListScreen extends ConsumerWidget {
  final int recipeId;

  const ShoppingListScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider(recipeId));

    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: shoppingListAsync.when(
        data: (shoppingList) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      icon: const Icon(Icons.arrow_back, color: NeuColors.neuBlack),
                    ),
                    const SizedBox(width: NeuSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shopping List', style: NeuTextStyles.heading2),
                          Text(
                            shoppingList.recipeTitle,
                            style: NeuTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Total Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
                child: NeuContainer(
                  borderRadius: BorderRadius.circular(8),
                  color: NeuColors.neuPink,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(3, 3),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🛒', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: NeuSpacing.sm),
                        Text(
                          '${shoppingList.totalItems} Items',
                          style: NeuTextStyles.heading3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: NeuSpacing.md),

              // Categories
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
                  itemCount: shoppingList.categories.length,
                  itemBuilder: (context, index) {
                    final category = shoppingList.categories[index];
                    final color = NeuColors.getCategoryColor(category.category);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: NeuSpacing.md),
                      child: NeuContainer(
                        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                        color: color,
                        borderWidth: 3,
                        borderColor: NeuColors.neuBlack,
                        offset: const Offset(4, 4),
                        shadowColor: NeuColors.neuBlack,
                        child: Padding(
                          padding: const EdgeInsets.all(NeuSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(category.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: NeuSpacing.sm),
                                  Text(
                                    category.category.toUpperCase(),
                                    style: NeuTextStyles.heading3,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeuColors.neuBlack,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${category.items.length}',
                                      style: NeuTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeuSpacing.md),
                              ...category.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: NeuColors.neuBlack,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: NeuSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          item.displayText,
                                          style: NeuTextStyles.body,
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
                    );
                  },
                ),
              ),
            ],
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
              Text('Error loading shopping list', style: NeuTextStyles.heading2),
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
}
