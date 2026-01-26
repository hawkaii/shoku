import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../providers/providers.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: NeuColors.neuBlack, width: 3),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(NeuSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildNavButton(
                    context,
                    ref,
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isActive: currentIndex == 0,
                    onTap: () {
                      ref.read(navigationIndexProvider.notifier).state = 0;
                      context.go('/');
                    },
                  ),
                ),
                const SizedBox(width: NeuSpacing.sm),
                Expanded(
                  child: _buildNavButton(
                    context,
                    ref,
                    icon: Icons.add_circle,
                    label: 'Add',
                    index: 1,
                    isActive: currentIndex == 1,
                    onTap: () {
                      ref.read(navigationIndexProvider.notifier).state = 1;
                      context.go('/add');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? NeuColors.neuYellow : Colors.white,
        borderWidth: 3,
        borderColor: NeuColors.neuBlack,
        offset: const Offset(3, 3),
        shadowColor: NeuColors.neuBlack,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: NeuColors.neuBlack, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: NeuColors.neuBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
