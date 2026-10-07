import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:lab12_dart/models/category.dart';
import 'package:lab12_dart/models/recipe.dart';
import 'package:lab12_dart/repositories/recipe_repository.dart';
import 'package:lab12_dart/services/recipe_service.dart';
import 'package:lab12_dart/services/recipe_utils.dart';

Future<void> main() async {
  final repository = RecipeRepository();
  final service = RecipeService(client: http.Client());

  final recipes = <Recipe>[];

  try {
    recipes.addAll(await repository.load());
    print('Завантажено рецептів: ${recipes.length}');
  } catch (e) {
    print('Не вдалося завантажити дані: $e');
  }

  while (true) {
    print('\n========== КУЛІНАРНА КНИГА ==========');
    print('1. Показати список рецептів');
    print('2. Додати рецепт');
    print('3. Видалити рецепт');
    print('4. Пошук рецепта');
    print('5. Сортування');
    print('6. Отримати рецепти з TheMealDB');
    print('7. Змінити статус рецепта');
    print('0. Вихід');

    stdout.write('Оберіть пункт: ');
    final input = stdin.readLineSync();

    switch (input) {
      case '1':
        showRecipes(recipes);
        break;

      case '2':
        addRecipe(recipes);
        await saveRecipes(repository, recipes);
        break;

      case '3':
        deleteRecipe(recipes);
        await saveRecipes(repository, recipes);
        break;

      case '4':
        searchMenu(recipes);
        break;

      case '5':
        sortMenu(recipes);
        await saveRecipes(repository, recipes);
        break;

      case '6':
        await loadFromApi(recipes, service);
        await saveRecipes(repository, recipes);
        break;

      case '7':
        changeStatus(recipes);
        await saveRecipes(repository, recipes);
        break;

      case '0':
        await saveRecipes(repository, recipes);
        service.client.close();
        print('Дані збережено. Програму завершено.');
        return;

      default:
        print('Некоректний пункт меню. Спробуйте ще раз.');
    }
  }
}

void showRecipes(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    print('Список рецептів порожній.');
    return;
  }

  print('\n========== РЕЦЕПТИ ==========');

  for (var i = 0; i < recipes.length; i++) {
    print('${i + 1}. ${recipes[i]}');
  }
}

void addRecipe(List<Recipe> recipes) {
  print('\n========== ДОДАВАННЯ РЕЦЕПТА ==========');

  stdout.write('ID: ');
  final idInput = stdin.readLineSync();

  final id = int.tryParse(idInput ?? '');

  if (id == null || id <= 0) {
    print('ID повинен бути додатним числом.');
    return;
  }

  stdout.write('Назва: ');
  final name = stdin.readLineSync()?.trim();

  if (name == null || name.isEmpty) {
    print('Назва не може бути порожньою.');
    return;
  }

  stdout.write('Категорія: ');
  final categoryName = stdin.readLineSync()?.trim();

  if (categoryName == null || categoryName.isEmpty) {
    print('Категорія не може бути порожньою.');
    return;
  }

  stdout.write('Країна/регіон кухні: ');
  final area = stdin.readLineSync()?.trim();

  if (area == null || area.isEmpty) {
    print('Країна або регіон не може бути порожнім.');
    return;
  }

  recipes.add(
    Recipe(
      id: id,
      name: name,
      category: Category(name: categoryName),
      area: area,
    ),
  );

  print('Рецепт успішно додано.');
}

void deleteRecipe(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    print('Список рецептів порожній.');
    return;
  }

  showRecipes(recipes);

  stdout.write('Введіть номер рецепта для видалення: ');
  final input = stdin.readLineSync();
  final index = int.tryParse(input ?? '');

  if (index == null || index < 1 || index > recipes.length) {
    print('Некоректний номер.');
    return;
  }

  final removed = recipes.removeAt(index - 1);

  print('Видалено: ${removed.name}');
}

void searchMenu(List<Recipe> recipes) {
  stdout.write('Введіть назву або частину назви: ');
  final query = stdin.readLineSync() ?? '';

  final result = searchRecipes(recipes, query);

  if (result.isEmpty) {
    print('Рецептів не знайдено.');
    return;
  }

  print('\n========== РЕЗУЛЬТАТ ПОШУКУ ==========');

  for (final recipe in result) {
    print(recipe);
  }
}

void sortMenu(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    print('Список рецептів порожній.');
    return;
  }

  print('1. За назвою');
  print('2. За категорією');

  stdout.write('Оберіть тип сортування: ');
  final input = stdin.readLineSync();

  List<Recipe> sorted;

  switch (input) {
    case '1':
      sorted = sortRecipesByName(recipes);
      break;

    case '2':
      sorted = sortRecipesByCategory(recipes);
      break;

    default:
      print('Некоректний вибір.');
      return;
  }

  recipes
    ..clear()
    ..addAll(sorted);

  print('Сортування виконано.');
}

Future<void> loadFromApi(List<Recipe> recipes, RecipeService service) async {
  stdout.write('Введіть назву рецепта для пошуку: ');
  final query = stdin.readLineSync()?.trim();

  if (query == null || query.isEmpty) {
    print('Запит не може бути порожнім.');
    return;
  }

  try {
    print('Виконується запит до TheMealDB...');

    final result = await service.searchRecipes(query);

    if (result.isEmpty) {
      print('API не повернуло рецептів.');
      return;
    }

    var added = 0;

    for (final recipe in result) {
      final exists = recipes.any((item) => item.id == recipe.id);

      if (!exists) {
        recipes.add(recipe);
        added++;
      }
    }

    print('Отримано рецептів: ${result.length}');
    print('Додано нових рецептів: $added');
  } catch (e) {
    print('Помилка отримання даних: $e');
  }
}

void changeStatus(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    print('Список рецептів порожній.');
    return;
  }

  showRecipes(recipes);

  stdout.write('Номер рецепта: ');
  final index = int.tryParse(stdin.readLineSync() ?? '');

  if (index == null || index < 1 || index > recipes.length) {
    print('Некоректний номер.');
    return;
  }

  print('1. Заплановано');
  print('2. Готується');
  print('3. Приготовано');

  stdout.write('Новий статус: ');
  final status = stdin.readLineSync();

  switch (status) {
    case '1':
      recipes[index - 1].status = RecipeStatus.planned;
      break;

    case '2':
      recipes[index - 1].status = RecipeStatus.cooking;
      break;

    case '3':
      recipes[index - 1].status = RecipeStatus.completed;
      break;

    default:
      print('Некоректний статус.');
      return;
  }

  print('Статус змінено.');
}

Future<void> saveRecipes(
  RecipeRepository repository,
  List<Recipe> recipes,
) async {
  try {
    await repository.save(recipes);
  } catch (e) {
    print('Не вдалося зберегти дані: $e');
  }
}
