import 'package:equatable/equatable.dart';
import 'ingredient.dart';

class ShoppingCategory extends Equatable {
  final String category;
  final List<Ingredient> items;

  const ShoppingCategory({
    required this.category,
    required this.items,
  });

  factory ShoppingCategory.fromJson(Map<String, dynamic> json) {
    return ShoppingCategory(
      category: json['category'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  String get emoji {
    switch (category.toLowerCase()) {
      case 'produce':
        return '🥬';
      case 'protein':
        return '🍗';
      case 'dairy':
        return '🥛';
      case 'spices':
        return '🌶️';
      default:
        return '📦';
    }
  }

  @override
  List<Object?> get props => [category, items];
}

class ShoppingList extends Equatable {
  final int recipeId;
  final String recipeTitle;
  final List<ShoppingCategory> categories;

  const ShoppingList({
    required this.recipeId,
    required this.recipeTitle,
    required this.categories,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      recipeId: json['recipe_id'] as int,
      recipeTitle: json['recipe_title'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => ShoppingCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'recipe_title': recipeTitle,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  int get totalItems {
    return categories.fold(0, (sum, category) => sum + category.items.length);
  }

  @override
  List<Object?> get props => [recipeId, recipeTitle, categories];
}
