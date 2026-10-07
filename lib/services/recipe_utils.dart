import '../models/recipe.dart';

List<Recipe> searchRecipes(List<Recipe> recipes, String query) {
  final normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.isEmpty) {
    return List<Recipe>.from(recipes);
  }

  return recipes
      .where((recipe) => recipe.name.toLowerCase().contains(normalizedQuery))
      .toList();
}

List<Recipe> sortRecipesByName(List<Recipe> recipes) {
  final result = List<Recipe>.from(recipes);

  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return result;
}

List<Recipe> sortRecipesByCategory(List<Recipe> recipes) {
  final result = List<Recipe>.from(recipes);

  result.sort(
    (a, b) =>
        a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase()),
  );

  return result;
}
