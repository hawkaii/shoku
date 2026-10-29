import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _extractRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    showNeuLoadingDialog(
      context,
      message: 'Analyzing video...\nThis may take 30-60s',
    );

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipe = await repository.extractRecipe(_urlController.text.trim());

      if (mounted) {
        hideNeuLoadingDialog(context);
        ref.invalidate(recipesProvider);
        // Use a slight delay to ensure dialog is fully dismissed
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.go('/recipe/${recipe.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showNeuErrorDialog(
            context,
            title: 'Extraction Failed',
            message: e.toString(),
            onRetry: _extractRecipe,
          );
        }
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
                // Header
                Text('Add Recipe', style: NeuTextStyles.heading1),
                const SizedBox(height: NeuSpacing.lg),

                // URL Input
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
                        Row(
                          children: [
                            const Text('📺', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: NeuSpacing.sm),
                            Text('YouTube Video Link', style: NeuTextStyles.heading3),
                          ],
                        ),
                        const SizedBox(height: NeuSpacing.md),
                        TextFormField(
                          controller: _urlController,
                          validator: Validators.validateYouTubeUrl,
                          style: NeuTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'Paste YouTube URL here...',
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: NeuColors.neuBlack,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: NeuColors.neuBlack,
                                width: 3,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
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

                // Extract Button
                Center(
                  child: NeuTextButton(
                    borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                    buttonColor: NeuColors.neuYellow,
                    buttonHeight: 60,
                    buttonWidth: 200,
                    enableAnimation: true,
                    onPressed: _extractRecipe,
                    text: Text('🔍 EXTRACT', style: NeuTextStyles.button),
                  ),
                ),
                const SizedBox(height: NeuSpacing.xl),

                // How it works
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOW IT WORKS:', style: NeuTextStyles.heading3),
                        const SizedBox(height: NeuSpacing.md),
                        _buildStep('1', 'Copy a YouTube cooking video link'),
                        _buildStep('2', 'Paste it in the field above'),
                        _buildStep('3', 'Tap EXTRACT button'),
                        _buildStep('4', 'AI extracts the recipe! 🤖'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NeuSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: NeuColors.neuBlack,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: NeuTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: NeuSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: NeuTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}
