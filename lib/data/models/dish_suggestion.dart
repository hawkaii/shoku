import 'package:equatable/equatable.dart';

class DishSuggestion extends Equatable {
  final String dishName;
  final String youtubeUrl;

  const DishSuggestion({
    required this.dishName,
    required this.youtubeUrl,
  });

  factory DishSuggestion.fromJson(Map<String, dynamic> json) {
    return DishSuggestion(
      dishName: json['dish_name'] as String,
      youtubeUrl: json['youtube_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish_name': dishName,
      'youtube_url': youtubeUrl,
    };
  }

  @override
  List<Object?> get props => [dishName, youtubeUrl];
}
