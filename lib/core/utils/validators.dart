class Validators {
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;

    final youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/shorts/)[a-zA-Z0-9_-]+',
      caseSensitive: false,
    );

    return youtubeRegex.hasMatch(url);
  }

  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a YouTube URL';
    }

    if (!isValidYouTubeUrl(value)) {
      return 'Invalid YouTube URL format';
    }

    return null;
  }
}
