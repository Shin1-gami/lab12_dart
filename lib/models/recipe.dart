import 'category.dart';
import 'storable.dart';

enum RecipeStatus { planned, cooking, completed }

class Recipe implements Storable {
  final int id;
  final String name;
  final Category category;
  final String area;
  RecipeStatus status;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    this.status = RecipeStatus.planned,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String?;

    final status = RecipeStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => RecipeStatus.planned,
    );

    return Recipe(
      id: _parseId(json['id']),
      name: json['name'] as String? ?? 'Без назви',
      category: Category.fromJson(
        json['category'] is Map<String, dynamic>
            ? json['category'] as Map<String, dynamic>
            : {'name': json['category'] ?? 'Без категорії'},
      ),
      area: json['area'] as String? ?? 'Невідомо',
      status: status,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toJson(),
      'area': area,
      'status': status.name,
    };
  }

  @override
  String toString() {
    return '#$id | $name | ${category.name} | $area | ${status.name}';
  }
}
