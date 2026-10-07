import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab12_dart/services/recipe_service.dart';
import 'package:test/test.dart';

void main() {
  group('RecipeService', () {
    test('розбирає правильну відповідь API', () async {
      final client = MockClient((request) async {
        return http.Response('''
          {
            "meals": [
              {
                "idMeal": "52796",
                "strMeal": "Chicken Alfredo Primavera",
                "strCategory": "Chicken",
                "strArea": "Italian"
              }
            ]
          }
          ''', 200);
      });

      final service = RecipeService(client: client);

      final recipes = await service.searchRecipes('chicken');

      expect(recipes, hasLength(1));
      expect(recipes.first.name, equals('Chicken Alfredo Primavera'));
      expect(recipes.first.category.name, equals('Chicken'));
    });

    test('порожня відповідь повертає порожній список', () async {
      final client = MockClient((request) async {
        return http.Response('{"meals": null}', 200);
      });

      final service = RecipeService(client: client);

      final recipes = await service.searchRecipes('unknown');

      expect(recipes, isEmpty);
    });

    test('помилка сервера спричиняє exception', () async {
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = RecipeService(client: client);

      expect(() => service.searchRecipes('chicken'), throwsA(isA<Exception>()));
    });

    test('некоректний JSON спричиняє FormatException', () async {
      final client = MockClient((request) async {
        return http.Response('invalid json', 200);
      });

      final service = RecipeService(client: client);

      expect(
        () => service.searchRecipes('chicken'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
