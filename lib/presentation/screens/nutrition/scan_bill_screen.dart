import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class ScanBillScreen extends ConsumerStatefulWidget {
  const ScanBillScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanBillScreen> createState() => _ScanBillScreenState();
}

class _ScanBillScreenState extends ConsumerState<ScanBillScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  List<String>? _scannedItems;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _scannedItems = null; // Clear previous results
        });
      }
    } catch (e) {
      if (mounted) {
        showNeuErrorDialog(
          context,
          title: 'Image Selection Failed',
          message: 'Could not select image from gallery. Please try again.',
        );
      }
    }
  }

  Future<void> _scanBill() async {
    if (_selectedImage == null) return;

    showNeuLoadingDialog(
      context,
      message: 'Scanning grocery bill...\nThis may take a few seconds',
    );

    try {
      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call API
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
          setState(() {
            _scannedItems = items;
          });
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
            onRetry: _scanBill,
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
                    child: Text('Scan Grocery Bill', style: NeuTextStyles.heading1),
                  ),
                ],
              ),
              const SizedBox(height: NeuSpacing.lg),

              // Instructions
              NeuContainer(
                borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
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
                          const Text('ℹ️', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: NeuSpacing.sm),
                          Text('HOW IT WORKS', style: NeuTextStyles.heading3),
                        ],
                      ),
                      const SizedBox(height: NeuSpacing.md),
                      Text(
                        '1. Select a photo of your grocery bill\n'
                        '2. Tap "SCAN BILL"\n'
                        '3. AI will extract item names\n'
                        '4. View your grocery list!',
                        style: NeuTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NeuSpacing.lg),

              // Select Image Button
              Center(
                child: GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: NeuContainer(
                    borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                    color: NeuColors.neuYellow,
                    borderWidth: 3,
                    borderColor: NeuColors.neuBlack,
                    offset: const Offset(5, 5),
                    shadowColor: NeuColors.neuBlack,
                    child: Container(
                      height: 60,
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library, color: NeuColors.neuBlack),
                          const SizedBox(width: 8),
                          Text('SELECT GALLERY', style: NeuTextStyles.button),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Selected Image Preview
              if (_selectedImage != null) ...[
                const SizedBox(height: NeuSpacing.lg),
                NeuContainer(
                  borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuCream,
                  borderWidth: 3,
                  borderColor: NeuColors.neuBlack,
                  offset: const Offset(4, 4),
                  shadowColor: NeuColors.neuBlack,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      height: 300,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: NeuSpacing.lg),

                // Scan Button
                Center(
                  child: GestureDetector(
                    onTap: _scanBill,
                    child: NeuContainer(
                      borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                      color: NeuColors.neuMint,
                      borderWidth: 3,
                      borderColor: NeuColors.neuBlack,
                      offset: const Offset(5, 5),
                      shadowColor: NeuColors.neuBlack,
                      child: Container(
                        height: 60,
                        width: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.document_scanner, color: NeuColors.neuBlack),
                            const SizedBox(width: 8),
                            Text('SCAN BILL', style: NeuTextStyles.button),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Scanned Items Results
              if (_scannedItems != null) ...[
                const SizedBox(height: NeuSpacing.xl),
                NeuContainer(
                  borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
                  color: NeuColors.neuLavender,
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
                            const Text('✅', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: NeuSpacing.sm),
                            Text(
                              'SCANNED ITEMS (${_scannedItems!.length})',
                              style: NeuTextStyles.heading2,
                            ),
                          ],
                        ),
                        const SizedBox(height: NeuSpacing.md),
                        if (_scannedItems!.isEmpty)
                          Text(
                            'No items detected. Try a clearer image.',
                            style: NeuTextStyles.body,
                          )
                        else
                          ..._scannedItems!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: NeuColors.neuBlack,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: NeuSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: NeuTextStyles.body,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ],
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
}
