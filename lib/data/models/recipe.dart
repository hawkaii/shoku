import 'package:equatable/equatable.dart';
import 'ingredient.dart';
import 'recipe_step.dart';

class Recipe extends Equatable {
  final int id;
  final String title;
  final String description;
  final String sourceUrl;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceUrl,
    this.prepTime,
    this.cookTime,
    this.servings,
    required this.tags,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      sourceUrl: json['source_url'] as String,
      prepTime: json['prep_time'] as int?,
      cookTime: json['cook_time'] as int?,
      servings: json['servings'] as int?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source_url': sourceUrl,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'tags': tags,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  int? get totalTime {
    if (prepTime == null && cookTime == null) return null;
    return (prepTime ?? 0) + (cookTime ?? 0);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        sourceUrl,
        prepTime,
        cookTime,
        servings,
        tags,
        ingredients,
        steps,
        createdAt,
      ];
}
