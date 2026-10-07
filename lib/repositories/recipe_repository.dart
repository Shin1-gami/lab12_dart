import 'dart:convert';
import 'dart:io';

import '../models/recipe.dart';

class RecipeRepository {
  final String filePath;

  RecipeRepository({this.filePath = 'data.json'});

  Future<List<Recipe>> load() async {
    final file = File(filePath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final raw = await file.readAsString();

      if (raw.trim().isEmpty) {
        return [];
      }

      final data = jsonDecode(raw);

      if (data is! List) {
        throw const FormatException('Файл повинен містити JSON-масив.');
      }

      return data
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Помилка читання data.json: $e');
    }
  }

  Future<void> save(List<Recipe> recipes) async {
    final file = File(filePath);

    final encoder = const JsonEncoder.withIndent('  ');

    final json = encoder.convert(
      recipes.map((recipe) => recipe.toJson()).toList(),
    );

    await file.writeAsString(json);
  }
}
