import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/recipe.dart';

class RecipeService {
  final http.Client client;

  RecipeService({required this.client});

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
      's': query,
    });

    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Помилка сервера: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Некоректний формат JSON.');
      }

      final meals = data['meals'];

      if (meals == null) {
        return [];
      }

      if (meals is! List) {
        throw const FormatException('Поле meals має бути списком.');
      }

      return meals.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Некоректний обʼєкт рецепта.');
        }

        return Recipe(
          id: int.tryParse('${item['idMeal']}') ?? 0,
          name: item['strMeal'] as String? ?? 'Без назви',
          category: Category(
            name: item['strCategory'] as String? ?? 'Без категорії',
          ),
          area: item['strArea'] as String? ?? 'Невідомо',
        );
      }).toList();
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Не вдалося отримати рецепти: $e');
    }
  }
}
