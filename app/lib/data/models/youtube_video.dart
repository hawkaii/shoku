import 'package:equatable/equatable.dart';

class YouTubeVideo extends Equatable {
  final String title;
  final String url;
  final String? thumbnail;

  const YouTubeVideo({
    required this.title,
    required this.url,
    this.thumbnail,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
    };
  }

  @override
  List<Object?> get props => [title, url, thumbnail];
}
