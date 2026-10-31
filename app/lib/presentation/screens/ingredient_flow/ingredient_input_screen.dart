import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class IngredientInputScreen extends ConsumerStatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  ConsumerState<IngredientInputScreen> createState() =>
      _IngredientInputScreenState();
}

class _IngredientInputScreenState
    extends ConsumerState<IngredientInputScreen> {
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        showNeuErrorDialog(
          context,
          title: 'Camera Failed',
          message: 'Could not capture image. Please try again.',
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        showNeuErrorDialog(
          context,
          title: 'Gallery Failed',
          message: 'Could not select image. Please try again.',
        );
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    showNeuLoadingDialog(
      context,
      message: 'Scanning for ingredients...\nThis may take a few seconds',
    );

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final repository = ref.read(nutritionRepositoryProvider);
      final userId = ref.read(userIdProvider);
      final items = await repository.scanGroceryBill(
        userId: userId,
        imageBase64: base64Image,
      );

      if (mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ref.read(ingredientsListProvider.notifier).state = items;
          context.push('/ingredients-list');
        }
      }
    } catch (e) {
      if (mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showNeuErrorDialog(
            context,
            title: 'Scan Failed',
            message: e.toString(),
          );
        }
      }
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (!available) {
      if (mounted) {
        showNeuErrorDialog(
          context,
          title: 'Voice Unavailable',
          message:
              'Speech recognition is not available on this device. Please use camera or gallery instead.',
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });

        if (result.finalResult) {
          _stopListening();
          _processVoiceInput(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _processVoiceInput(String text) {
    // Split spoken text by common delimiters
    final ingredients = text
        .split(RegExp(r'[,\.\;and]+', caseSensitive: false))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (ingredients.isNotEmpty) {
      ref.read(ingredientsListProvider.notifier).state = ingredients;
      context.push('/ingredients-list');
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NeuSpacing.md),
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
                    icon: const Icon(Icons.arrow_back,
                        color: NeuColors.neuBlack),
                  ),
                  const SizedBox(width: NeuSpacing.md),
                  Expanded(
                    child: Text('Add Ingredients',
                        style: NeuTextStyles.heading1),
                  ),
                ],
              ),
              const SizedBox(height: NeuSpacing.lg),

              // Instructions
              NeuContainer(
                borderRadius:
                    BorderRadius.circular(NeuSpacing.borderRadius),
                color: NeuColors.neuSkyBlue,
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
                          const Text('ℹ️',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(width: NeuSpacing.sm),
                          Text('HOW IT WORKS',
                              style: NeuTextStyles.heading3),
                        ],
                      ),
                      const SizedBox(height: NeuSpacing.md),
                      Text(
                        '1. Add ingredients using camera, gallery, or voice\n'
                        '2. Review and edit the ingredients list\n'
                        '3. Get recipe suggestions based on your ingredients\n'
                        '4. Find YouTube videos and extract recipes!',
                        style: NeuTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NeuSpacing.xl),

              // Camera button
              _buildInputCard(
                icon: Icons.camera_alt,
                emoji: '📷',
                title: 'CAMERA',
                description: 'Take a photo of your ingredients or grocery bill',
                color: NeuColors.neuYellow,
                onTap: _captureFromCamera,
              ),
              const SizedBox(height: NeuSpacing.md),

              // Gallery button
              _buildInputCard(
                icon: Icons.photo_library,
                emoji: '🖼️',
                title: 'GALLERY',
                description: 'Select an image from your photo library',
                color: NeuColors.neuMint,
                onTap: _pickFromGallery,
              ),
              const SizedBox(height: NeuSpacing.md),

              // Voice button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: NeuContainer(
                  borderRadius:
                      BorderRadius.circular(NeuSpacing.borderRadius),
                  color: _isListening
                      ? NeuColors.neuCoral
                      : NeuColors.neuLavender,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Row(
                      children: [
                        Text(_isListening ? '🔴' : '🎤',
                            style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: NeuSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isListening ? 'LISTENING...' : 'VOICE',
                                style: NeuTextStyles.heading3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isListening
                                    ? 'Tap to stop'
                                    : 'Say your ingredients out loud',
                                style: NeuTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: NeuColors.neuBlack,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Show spoken text while listening
              if (_isListening && _spokenText.isNotEmpty) ...[
                const SizedBox(height: NeuSpacing.md),
                NeuContainer(
                  borderRadius:
                      BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuCream,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: Padding(
                    padding: const EdgeInsets.all(NeuSpacing.md),
                    child: Text(
                      _spokenText,
                      style: NeuTextStyles.body,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String emoji,
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
              Text(emoji, style: const TextStyle(fontSize: 40)),
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
