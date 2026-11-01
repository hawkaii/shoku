import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final int id;
  final String name;
  final double? quantity;
  final String? unit;
  final String? notes;

  const Ingredient({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  String get displayText {
    final parts = <String>[];

    if (quantity != null) {
      parts.add(quantity!.toString());
    }

    if (unit != null) {
      parts.add(unit!);
    }

    parts.add(name);

    if (notes != null && notes!.isNotEmpty) {
      parts.add('($notes)');
    }

    return parts.join(' ');
  }

  @override
  List<Object?> get props => [id, name, quantity, unit, notes];
}
