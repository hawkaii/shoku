import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/cards.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';

class StashScreen extends ConsumerWidget {
  const StashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final collections = ref.watch(collectionsProvider);
    final notes = ref
        .watch(savedItemsProvider)
        .where((i) => i.kind == ItemKind.wisdom)
        .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Stash', style: ShokuType.h1.copyWith(color: c.ink)),
                const Spacer(),
                ShokuIconButton(
                  icon: Icons.create_new_folder_outlined,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Highlights, notes and places you kept from reels.',
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.lg),

            ShokuLabel('collections'),
            const SizedBox(height: ShokuSpace.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: ShokuSpace.sm,
              crossAxisSpacing: ShokuSpace.sm,
              childAspectRatio: 1.55,
              children: [
                for (final collection in collections)
                  ShokuCollectionCard(
                    collection: collection,
                    onTap: () {},
                  ),
                _NewCollectionTile(onTap: () {}),
              ],
            ),

            const SizedBox(height: ShokuSpace.xl),
            Row(
              children: [
                ShokuLabel('saved notes'),
                const Spacer(),
                Text(
                  '${notes.length}',
                  style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.sm),
            if (notes.isEmpty)
              ShokuEmptyState(
                icon: Icons.bookmark_border,
                title: 'Your stash is empty',
                body: 'Tap any line inside a reel and save it here.',
                actionLabel: 'See how it works',
                onAction: () {},
              )
            else
              ...notes.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: ShokuSpace.md),
                      child: ShokuWisdomCard(
                        item: e.value,
                        index: e.key + 1,
                        onTap: () {
                          ref.read(selectedItemProvider.notifier).state = e.value;
                          context.go('/discover');
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _NewCollectionTile extends StatelessWidget {
  final VoidCallback onTap;
  const _NewCollectionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: c.inkMuted),
            const SizedBox(height: 4),
            Text(
              'NEW COLLECTION',
              style: ShokuType.label.copyWith(fontSize: 9.5, color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
