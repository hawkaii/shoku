import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/spacing.dart';

class NeuErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const NeuErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeuContainer(
        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
        color: NeuColors.neuPink,
        borderWidth: 4,
        borderColor: NeuColors.neuBlack,
        offset: const Offset(6, 6),
        shadowColor: NeuColors.neuBlack,
        child: Padding(
          padding: const EdgeInsets.all(NeuSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '❌',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: NeuSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: NeuTextStyles.heading2,
              ),
              const SizedBox(height: NeuSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: NeuTextStyles.body,
              ),
              const SizedBox(height: NeuSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onRetry != null)
                    Expanded(
                      child: NeuTextButton(
                        borderRadius: BorderRadius.circular(8),
                        buttonColor: NeuColors.neuYellow,
                        buttonHeight: 50,
                        enableAnimation: true,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRetry?.call();
                        },
                        text: Text('Retry', style: NeuTextStyles.button),
                      ),
                    ),
                  if (onRetry != null) const SizedBox(width: NeuSpacing.sm),
                  Expanded(
                    child: NeuTextButton(
                      borderRadius: BorderRadius.circular(8),
                      buttonColor: NeuColors.neuWhite,
                      buttonHeight: 50,
                      enableAnimation: true,
                      onPressed: () => Navigator.of(context).pop(),
                      text: Text('Close', style: NeuTextStyles.button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showNeuErrorDialog(
  BuildContext context, {
  String title = 'Error',
  required String message,
  VoidCallback? onRetry,
}) {
  showDialog(
    context: context,
    builder: (context) => NeuErrorDialog(
      title: title,
      message: message,
      onRetry: onRetry,
    ),
  );
}
