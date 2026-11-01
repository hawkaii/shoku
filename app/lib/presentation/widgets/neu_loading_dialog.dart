import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/spacing.dart';

class NeuLoadingDialog extends StatelessWidget {
  final String message;
  final double? progress;

  const NeuLoadingDialog({
    super.key,
    this.message = 'Loading...',
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeuContainer(
        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
        color: NeuColors.neuYellow,
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
                '🤖',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: NeuSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: NeuTextStyles.heading3,
              ),
              const SizedBox(height: NeuSpacing.md),

              if (progress != null)
                _buildProgressBar(progress!)
              else
                const SpinKitThreeBounce(
                  color: NeuColors.neuBlack,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: NeuColors.neuBlack, width: 3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: NeuColors.neuMint,
              border: Border.all(color: NeuColors.neuBlack, width: 3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

void showNeuLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => NeuLoadingDialog(message: message),
  );
}

void hideNeuLoadingDialog(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}
