import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/providers.dart';

class YouTubeWebViewScreen extends ConsumerStatefulWidget {
  final String youtubeUrl;

  const YouTubeWebViewScreen({super.key, required this.youtubeUrl});

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
