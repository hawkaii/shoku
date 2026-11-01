import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../data/models/youtube_video.dart';
import '../../../providers/providers.dart';
import '../../widgets/neu_loading_dialog.dart';
import '../../widgets/neu_error_dialog.dart';

class YouTubeVideosScreen extends ConsumerWidget {
  final List<YouTubeVideo> videos;

  const YouTubeVideosScreen({super.key, required this.videos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDish = ref.watch(selectedDishProvider);

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
                    child: Text('Video Recipes',
                        style: NeuTextStyles.heading1),
                  ),
                ],
              ),
            ),

            // Dish name subtitle
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: NeuSpacing.md),
              child: NeuContainer(
                borderRadius:
                    BorderRadius.circular(NeuSpacing.borderRadius),
                color: NeuColors.neuCoral,
                borderWidth: 3,
                borderColor: NeuColors.neuBlack,
                offset: const Offset(4, 4),
                shadowColor: NeuColors.neuBlack,
                child: Padding(
                  padding: const EdgeInsets.all(NeuSpacing.md),
                  child: Row(
                    children: [
                      const Text('🎬',
                          style: TextStyle(fontSize: 28)),
                      const SizedBox(width: NeuSpacing.md),
                      Expanded(
                        child: Text(
                          'Videos for "$selectedDish"',
                          style: NeuTextStyles.heading3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: NeuSpacing.md),

            // Video list
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: Text(
                        'No videos found.\nTry a different dish!',
                        textAlign: TextAlign.center,
                        style: NeuTextStyles.body
                            .copyWith(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NeuSpacing.md),
                      itemCount: videos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: NeuSpacing.md),
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        final colors = [
                          NeuColors.neuYellow,
                          NeuColors.neuMint,
                          NeuColors.neuPink,
                          NeuColors.neuLavender,
                          NeuColors.neuSkyBlue,
                        ];
                        return _buildVideoCard(
                          context,
                          ref,
                          video: video,
                          color: colors[index % colors.length],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    WidgetRef ref, {
    required YouTubeVideo video,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _extractRecipe(context, ref, video.url),
      child: NeuContainer(
        borderRadius: BorderRadius.circular(NeuSpacing.borderRadius),
        color: color,
        borderWidth: 3,
        borderColor: NeuColors.neuBlack,
        offset: const Offset(4, 4),
        shadowColor: NeuColors.neuBlack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            if (video.thumbnail != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft:
                      Radius.circular(NeuSpacing.borderRadius),
                  topRight:
                      Radius.circular(NeuSpacing.borderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.video_library,
                              size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),

            // Title
            Padding(
              padding: const EdgeInsets.all(NeuSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      video.title,
                      style: NeuTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: NeuSpacing.sm),
                  const Icon(Icons.arrow_forward,
                      color: NeuColors.neuBlack),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _extractRecipe(
    BuildContext context,
    WidgetRef ref,
    String videoUrl,
  ) async {
    ref.read(selectedVideoUrlProvider.notifier).state = videoUrl;

    showNeuLoadingDialog(
      context,
      message: 'Extracting recipe from video...\nThis may take a moment',
    );

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipe = await repository.extractRecipe(videoUrl);

      if (context.mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          // Set the last added recipe ID for highlighting
          ref.read(lastAddedRecipeIdProvider.notifier).state = recipe.id;
          // Redirect to home page
          context.go('/');
        }
      }
    } catch (e) {
      if (context.mounted) {
        hideNeuLoadingDialog(context);
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          showNeuErrorDialog(
            context,
            title: 'Extraction Failed',
            message: e.toString(),
          );
        }
      }
    }
  }
}
