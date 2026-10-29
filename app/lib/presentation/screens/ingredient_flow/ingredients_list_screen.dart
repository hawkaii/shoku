import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class IngredientsListScreen extends ConsumerStatefulWidget {
  const IngredientsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IngredientsListScreen> createState() =>
      _IngredientsListScreenState();
}

class _IngredientsListScreenState
    extends ConsumerState<IngredientsListScreen> {
  final TextEditingController _addController = TextEditingController();

  void _addIngredient() {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    final current = ref.read(ingredientsListProvider);
    ref.read(ingredientsListProvider.notifier).state = [...current, text];
    _addController.clear();
  }

  void _removeIngredient(int index) {
    final current = ref.read(ingredientsListProvider);
    final updated = [...current]..removeAt(index);
    ref.read(ingredientsListProvider.notifier).state = updated;
  }

  Future<void> _getRecipes() async {
    final ingredients = ref.read(ingredientsListProvider);
    if (ingredients.isEmpty) return;

    showNeuLoadingDialog(
      context,
      message: 'Finding recipes...\nAnalyzing your ingredients',
    );

    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final dishes = await repository.suggestRecipes(ingredients);

      if (mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.push('/recipe-suggestions', extra: dishes);
        }
      }
    } catch (e) {
      if (mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showNeuErrorDialog(
            context,
            title: 'Suggestion Failed',
            message: e.toString(),
            onRetry: _getRecipes,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientsListProvider);

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
                    child: Text('Your Ingredients',
                        style: NeuTextStyles.heading1),
                  ),
                ],
              ),
            ),

            // Add ingredient input
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: NeuContainer(
                      borderRadius:
                          BorderRadius.circular(NeuSpacing.borderRadius),
                      color: NeuColors.neuWhite,
                      borderWidth: 3,
                      borderColor: NeuColors.neuBlack,
                      offset: const Offset(3, 3),
                      shadowColor: NeuColors.neuBlack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: NeuSpacing.md),
                        child: TextField(
                          controller: _addController,
                          style: NeuTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'Add an ingredient...',
                            hintStyle: NeuTextStyles.bodySmall
                                .copyWith(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: NeuSpacing.sm),
                  NeuIconButton(
                    borderRadius: BorderRadius.circular(8),
                    buttonColor: NeuColors.neuMint,
                    buttonHeight: 50,
                    buttonWidth: 50,
                    enableAnimation: true,
                    onPressed: _addIngredient,
                    icon:
                        const Icon(Icons.add, color: NeuColors.neuBlack),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeuSpacing.md),

            // Ingredients chips
            Expanded(
              child: ingredients.isEmpty
                  ? Center(
                      child: Text(
                        'No ingredients yet.\nAdd some above!',
                        textAlign: TextAlign.center,
                        style: NeuTextStyles.body
                            .copyWith(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NeuSpacing.md),
                      child: NeuContainer(
                        borderRadius: BorderRadius.circular(
                            NeuSpacing.borderRadius),
                        color: NeuColors.neuCream,
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
                                      style:
                                          TextStyle(fontSize: 24)),
                                  const SizedBox(
                                      width: NeuSpacing.sm),
                                  Text(
                                    'INGREDIENTS (${ingredients.length})',
                                    style: NeuTextStyles.heading3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeuSpacing.md),
                              Wrap(
                                spacing: NeuSpacing.sm,
                                runSpacing: NeuSpacing.sm,
                                children: ingredients
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final colors = [
                                    NeuColors.neuYellow,
                                    NeuColors.neuMint,
                                    NeuColors.neuPink,
                                    NeuColors.neuLavender,
                                    NeuColors.neuSkyBlue,
                                    NeuColors.neuCoral,
                                  ];
                                  return _buildChip(
                                    entry.value,
                                    colors[entry.key %
                                        colors.length],
                                    () => _removeIngredient(
                                        entry.key),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),

            // Get Recipes button
            Padding(
              padding: const EdgeInsets.all(NeuSpacing.md),
              child: GestureDetector(
                onTap: ingredients.isNotEmpty ? _getRecipes : null,
                child: NeuContainer(
                  borderRadius:
                      BorderRadius.circular(NeuSpacing.borderRadius),
                  color: ingredients.isNotEmpty
                      ? NeuColors.neuMint
                      : Colors.grey.shade300,
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
                        const Text('🍳',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: NeuSpacing.sm),
                        Text('GET RECIPES',
                            style: NeuTextStyles.button),
                        const SizedBox(width: NeuSpacing.sm),
                        const Icon(Icons.arrow_forward,
                            color: NeuColors.neuBlack),
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

  Widget _buildChip(String label, Color color, VoidCallback onRemove) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NeuColors.neuBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: NeuColors.neuBlack,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NeuTextStyles.tag),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16,
                color: NeuColors.neuBlack),
          ),
        ],
      ),
    );
  }
}
