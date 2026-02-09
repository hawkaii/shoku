import 'package:equatable/equatable.dart';

class NutritionData extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  @override
  List<Object?> get props => [calories, protein, carbs, fat];
}

class NutritionBoard extends Equatable {
  final String userId;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionBoard({
    required this.userId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionBoard.fromJson(Map<String, dynamic> json) {
    return NutritionBoard(
      userId: json['user_id'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  @override
  List<Object?> get props => [userId, calories, protein, carbs, fat];
}

class MealLog extends Equatable {
  final String timestamp;
  final String userId;
  final String food;
  final int amount;
  final NutritionData nutrition;

  const MealLog({
    required this.timestamp,
    required this.userId,
    required this.food,
    required this.amount,
    required this.nutrition,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      timestamp: json['timestamp'] as String,
      userId: json['user_id'] as String,
      food: json['food'] as String,
      amount: json['amount'] as int,
      nutrition: NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'user_id': userId,
      'food': food,
      'amount': amount,
      'nutrition': nutrition.toJson(),
    };
  }

  @override
  List<Object?> get props => [timestamp, userId, food, amount, nutrition];
}
