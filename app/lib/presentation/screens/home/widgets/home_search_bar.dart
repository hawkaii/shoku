import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../providers/providers.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: NeuColors.neuBlack, width: 3),
        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: NeuColors.neuBlack,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        style: NeuTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          hintStyle: NeuTextStyles.body.copyWith(
            color: Colors.grey[600],
          ),
          prefixIcon: const Icon(Icons.search, color: NeuColors.neuBlack),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NeuSpacing.md,
            vertical: NeuSpacing.md,
          ),
        ),
      ),
    );
  }
}
