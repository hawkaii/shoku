import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../data/models/nutrition.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class FoodLookupScreen extends ConsumerStatefulWidget {
  const FoodLookupScreen({super.key});

  @override
  ConsumerState<FoodLookupScreen> createState() => _FoodLookupScreenState();
}

class _FoodLookupScreenState extends ConsumerState<FoodLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();
  final _amountController = TextEditingController();
  NutritionData? _nutritionResult;

  @override
  void dispose() {
    _foodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _lookupFood() async {
    if (!_formKey.currentState!.validate()) return;

    showNeuLoadingDialog(context, message: 'Fetching nutrition info...');

    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final userId = ref.read(userIdProvider);
      final nutrition = await repository.getNutrition(
        userId: userId,
        food: _foodController.text.trim(),
        amount: double.parse(_amountController.text),
      );

      if (mounted) {
        hideNeuLoadingDialog(context);
        setState(() {
          _nutritionResult = nutrition;
        });
      }
    } catch (e) {
      if (mounted) {
        hideNeuLoadingDialog(context);
        showNeuErrorDialog(
          context,
          title: 'Lookup Failed',
          message: e.toString(),
          onRetry: _lookupFood,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NeuSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button
                Row(
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
                      child: Text('Lookup Food', style: NeuTextStyles.heading1),
                    ),
                  ],
                ),
                const SizedBox(height: NeuSpacing.lg),

                // Food Input
                NeuContainer(
                  borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuCream,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Food Item', style: NeuTextStyles.heading3),
                        const SizedBox(height: NeuSpacing.md),
                        TextFormField(
                          controller: _foodController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a food item';
                            }
                            return null;
                          },
                          style: NeuTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'e.g., banana, chicken breast',
                            hintStyle: NeuTextStyles.body.copyWith(
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: NeuColors.neuBlack,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(NeuSpacing.md),
                          ),
                        ),
                        const SizedBox(height: NeuSpacing.md),
                        Text('Amount', style: NeuTextStyles.heading3),
                        const SizedBox(height: NeuSpacing.md),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          style: NeuTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'e.g., 1 for 1 banana, 200 for 200g',
                            hintStyle: NeuTextStyles.body.copyWith(
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: NeuColors.neuBlack,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(NeuSpacing.md),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: NeuSpacing.lg),

                // Lookup Button
                Center(
                  child: NeuTextButton(
                    borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                    buttonColor: NeuColors.neuYellow,
                    buttonHeight: 60,
                    buttonWidth: 200,
                    enableAnimation: true,
                    onPressed: _lookupFood,
                    text: Text('🔍 LOOKUP', style: NeuTextStyles.button),
                  ),
                ),

                // Results
                if (_nutritionResult != null) ...[
                  const SizedBox(height: NeuSpacing.xl),
                  NeuContainer(
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
                          Text('NUTRITION INFO', style: NeuTextStyles.heading2),
                          const SizedBox(height: NeuSpacing.md),
                          _buildNutrientRow('🔥 Calories', '${_nutritionResult!.calories.toInt()} kcal'),
                          _buildNutrientRow('💪 Protein', '${_nutritionResult!.protein.toInt()}g'),
                          _buildNutrientRow('🍞 Carbs', '${_nutritionResult!.carbs.toInt()}g'),
                          _buildNutrientRow('🥑 Fat', '${_nutritionResult!.fat.toInt()}g'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NeuSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NeuTextStyles.body),
          Text(value, style: NeuTextStyles.heading3),
        ],
      ),
    );
  }
}
