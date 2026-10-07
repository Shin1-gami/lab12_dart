import 'package:lab12_dart/models/category.dart';
import 'package:lab12_dart/models/recipe.dart';
import 'package:lab12_dart/services/recipe_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Recipe', () {
    final recipe = Recipe(
      id: 1,
      name: 'Borscht',
      category: Category(name: 'Soup'),
      area: 'Ukraine',
      status: RecipeStatus.completed,
    );

    test('toJson повертає правильну мапу', () {
      expect(recipe.toJson(), {
        'id': 1,
        'name': 'Borscht',
        'category': {'name': 'Soup'},
        'area': 'Ukraine',
        'status': 'completed',
      });
    });

    test('fromJson відновлює обʼєкт', () {
      final restored = Recipe.fromJson(recipe.toJson());

      expect(restored.id, equals(recipe.id));
      expect(restored.name, equals(recipe.name));
      expect(restored.category.name, equals(recipe.category.name));
      expect(restored.area, equals(recipe.area));
      expect(restored.status, equals(recipe.status));
    });

    test('працює пошук рецепта', () {
      final recipes = [
        recipe,
        Recipe(
          id: 2,
          name: 'Pizza',
          category: Category(name: 'Main'),
          area: 'Italy',
        ),
      ];

      final result = searchRecipes(recipes, 'bor');

      expect(result, hasLength(1));
      expect(result.first.name, equals('Borscht'));
    });

    test('пошук не залежить від регістру', () {
      final result = searchRecipes([recipe], 'BORSCHT');

      expect(result, hasLength(1));
    });

    test('працює сортування за назвою', () {
      final recipes = [
        recipe,
        Recipe(
          id: 2,
          name: 'Apple Pie',
          category: Category(name: 'Dessert'),
          area: 'American',
        ),
      ];

      final sorted = sortRecipesByName(recipes);

      expect(sorted.first.name, equals('Apple Pie'));
      expect(sorted.last.name, equals('Borscht'));
    });

    test('некоректний id перетворюється на 0', () {
      final restored = Recipe.fromJson({
        'id': 'abc',
        'name': 'Test',
        'category': {'name': 'Test'},
        'area': 'Test',
        'status': 'planned',
      });

      expect(restored.id, equals(0));
    });
  });
}
