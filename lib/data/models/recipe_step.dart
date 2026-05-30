import 'package:equatable/equatable.dart';

class RecipeStep extends Equatable {
  final int id;
  final int stepNumber;
  final String instruction;

  const RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as int,
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_number': stepNumber,
      'instruction': instruction,
    };
  }

  @override
  List<Object?> get props => [id, stepNumber, instruction];
}
