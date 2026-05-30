import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../data/models/recipe.dart';
import '../../../providers/providers.dart';

class YouTubeWebViewScreen extends ConsumerStatefulWidget {
  final String youtubeUrl;

  const YouTubeWebViewScreen({Key? key, required this.youtubeUrl})
      : super(key: key);

  @override
  ConsumerState<YouTubeWebViewScreen> createState() =>
      _YouTubeWebViewScreenState();
}

class _YouTubeWebViewScreenState extends ConsumerState<YouTubeWebViewScreen> {
  String _currentUrl = '';
  bool _isLoading = true;
  bool _isExtracting = false;

  bool get _isVideoUrl {
    return _currentUrl.contains('youtube.com/watch?v=') ||
        _currentUrl.contains('youtu.be/') ||
        _currentUrl.contains('m.youtube.com/watch?v=');
  }

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.youtubeUrl;
  }

  Future<void> _extractRecipe() async {
    if (!_isVideoUrl || _isExtracting) return;

    setState(() => _isExtracting = true);

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipe = await repository.extractRecipe(_currentUrl);

      if (mounted) {
        setState(() => _isExtracting = false);
        // Set the last added recipe ID for highlighting
        ref.read(lastAddedRecipeIdProvider.notifier).state = recipe.id;
        // Invalidate recipes to refresh the list
        ref.invalidate(recipesProvider);
        // Redirect to home page
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        _showErrorSheet(e.toString());
      }
    }
  }

  void _showRecipeSummarySheet(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: NeuColors.neuWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: NeuColors.neuBlack, width: 3),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(NeuSpacing.md),
                  children: [
                    // Title
                    Text(recipe.title, style: NeuTextStyles.heading2),
                    const SizedBox(height: NeuSpacing.sm),

                    // Description
                    if (recipe.description.isNotEmpty) ...[
                      Text(recipe.description, style: NeuTextStyles.body),
                      const SizedBox(height: NeuSpacing.md),
                    ],

                    // Meta info
                    if (recipe.cookTime != null ||
                        recipe.servings != null) ...[
                      Wrap(
                        spacing: NeuSpacing.sm,
                        children: [
                          if (recipe.cookTime != null)
                            _buildMetaChip(
                                Icons.timer, '${recipe.cookTime} min'),
                          if (recipe.servings != null)
                            _buildMetaChip(Icons.restaurant,
                                '${recipe.servings} servings'),
                        ],
                      ),
                      const SizedBox(height: NeuSpacing.md),
                    ],

                    // Ingredients
                    NeuContainer(
                      borderRadius: BorderRadius.circular(
                          NeuSpacing.borderRadius),
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
                            Text('Ingredients',
                                style: NeuTextStyles.heading3),
                            const SizedBox(height: NeuSpacing.sm),
                            ...recipe.ingredients
                                .map((i) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('  - ',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          Expanded(
                                            child: Text(i.displayText,
                                                style: NeuTextStyles
                                                    .bodySmall),
                                          ),
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: NeuSpacing.md),

                    // Steps
                    NeuContainer(
                      borderRadius: BorderRadius.circular(
                          NeuSpacing.borderRadius),
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
                            Text('Steps',
                                style: NeuTextStyles.heading3),
                            const SizedBox(height: NeuSpacing.sm),
                            ...recipe.steps.map((s) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: NeuSpacing.sm),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: NeuColors.neuBlack,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${s.stepNumber}',
                                            style: NeuTextStyles.bodySmall
                                                .copyWith(
                                                    color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: NeuSpacing.sm),
                                      Expanded(
                                        child: Text(s.instruction,
                                            style:
                                                NeuTextStyles.bodySmall),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: NeuSpacing.lg),

                    // Save button
                    Center(
                      child: NeuTextButton(
                        borderRadius: BorderRadius.circular(
                            NeuSpacing.borderRadius),
                        buttonColor: NeuColors.neuYellow,
                        buttonHeight: 60,
                        buttonWidth: 220,
                        enableAnimation: true,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ref.invalidate(recipesProvider);
                          context.go('/recipe/${recipe.id}');
                        },
                        text: Text('VIEW RECIPE',
                            style: NeuTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: NeuSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSheet(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(NeuSpacing.lg),
        decoration: BoxDecoration(
          color: NeuColors.neuPink,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: NeuColors.neuBlack, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Extraction Failed',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: NeuSpacing.md),
            Text(message, style: NeuTextStyles.body),
            const SizedBox(height: NeuSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeuTextButton(
                  borderRadius: BorderRadius.circular(8),
                  buttonColor: NeuColors.neuYellow,
                  buttonHeight: 50,
                  enableAnimation: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _extractRecipe();
                  },
                  text: Text('Retry', style: NeuTextStyles.button),
                ),
                NeuTextButton(
                  borderRadius: BorderRadius.circular(8),
                  buttonColor: NeuColors.neuWhite,
                  buttonHeight: 50,
                  enableAnimation: true,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  text: Text('Close', style: NeuTextStyles.button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NeuColors.neuCream,
        border: Border.all(color: NeuColors.neuBlack, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: NeuTextStyles.tag),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishName = ref.watch(selectedDishProvider);

    return Scaffold(
      backgroundColor: NeuColors.neuWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(NeuSpacing.sm),
              color: NeuColors.neuWhite,
              child: Row(
                children: [
                  NeuIconButton(
                    borderRadius: BorderRadius.circular(8),
                    buttonColor: NeuColors.neuYellow,
                    buttonHeight: 44,
                    buttonWidth: 44,
                    enableAnimation: true,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: NeuColors.neuBlack, size: 20),
                  ),
                  const SizedBox(width: NeuSpacing.sm),
                  Expanded(
                    child: Text(
                      dishName.isNotEmpty ? dishName : 'YouTube',
                      style: NeuTextStyles.heading3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // WebView
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.youtubeUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      useWideViewPort: true,
                      useShouldOverrideUrlLoading: true,
                      supportMultipleWindows: false,
                      javaScriptCanOpenWindowsAutomatically: false,
                      userAgent:
                          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                    ),
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      final url = uri?.toString() ?? '';

                      // Block intent:// URLs (Android app deep links)
                      if (url.startsWith('intent://')) {
                        // Extract the fallback URL from the intent
                        final fallbackMatch =
                            RegExp(r'S\.browser_fallback_url=([^;]+)')
                                .firstMatch(url);
                        if (fallbackMatch != null) {
                          final fallbackUrl =
                              Uri.decodeFull(fallbackMatch.group(1)!);
                          controller.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri(fallbackUrl)),
                          );
                        }
                        return NavigationActionPolicy.CANCEL;
                      }

                      // Block other custom schemes (market://, vnd.youtube://, etc.)
                      if (uri != null &&
                          uri.scheme != 'http' &&
                          uri.scheme != 'https' &&
                          uri.scheme != 'about' &&
                          uri.scheme != 'data') {
                        return NavigationActionPolicy.CANCEL;
                      }

                      // Allow all http/https navigation inside WebView
                      return NavigationActionPolicy.ALLOW;
                    },
                    onWebViewCreated: (controller) {
                      // WebView controller available if needed
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _isLoading = true;
                        if (url != null) {
                          _currentUrl = url.toString();
                        }
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        _isLoading = false;
                        if (url != null) {
                          _currentUrl = url.toString();
                        }
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, isReload) {
                      if (url != null) {
                        setState(() {
                          _currentUrl = url.toString();
                        });
                      }
                    },
                  ),
                  if (_isLoading)
                    const Center(
                      child: SpinKitThreeBounce(
                        color: NeuColors.neuBlack,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),

            // Extract Recipe button bar
            Container(
              padding: const EdgeInsets.all(NeuSpacing.sm),
              decoration: const BoxDecoration(
                color: NeuColors.neuWhite,
                border: Border(
                  top: BorderSide(color: NeuColors.neuBlack, width: 2),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // URL indicator
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isVideoUrl
                              ? NeuColors.neuMint
                              : NeuColors.neuCream,
                          border: Border.all(
                              color: NeuColors.neuBlack, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isVideoUrl
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              size: 16,
                              color: NeuColors.neuBlack,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _isVideoUrl
                                    ? 'Video detected - ready to extract!'
                                    : 'Open a video to extract recipe',
                                style: NeuTextStyles.tag,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: NeuSpacing.sm),

                    // Extract button
                    GestureDetector(
                      onTap: _isVideoUrl && !_isExtracting
                          ? _extractRecipe
                          : null,
                      child: NeuContainer(
                        borderRadius: BorderRadius.circular(8),
                        color: _isVideoUrl
                            ? NeuColors.neuYellow
                            : Colors.grey[300]!,
                        borderWidth: 2,
                        borderColor: NeuColors.neuBlack,
                        offset: const Offset(3, 3),
                        shadowColor: NeuColors.neuBlack,
                        child: SizedBox(
                          height: 44,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Center(
                              child: _isExtracting
                                  ? const SizedBox(
                                      width: 80,
                                      child: SpinKitThreeBounce(
                                        color: NeuColors.neuBlack,
                                        size: 18,
                                      ),
                                    )
                                  : Text('EXTRACT',
                                      style: NeuTextStyles.button
                                          .copyWith(fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
