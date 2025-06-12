import 'package:dio/dio.dart';
import '../models/recipe.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> fetchRecipesByCategory(String category) async {
    try {
      final response = await _dio.get('$_baseUrl/filter.php?c=$category');
      if (response.statusCode == 200) {
        final List meals = response.data['meals'] ?? [];
        return meals.map((meal) => Recipe.fromJson(meal)).toList();
      }
      throw Exception('Failed to load recipes');
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  Future<Recipe> fetchRecipeDetails(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/lookup.php?i=$id');
      if (response.statusCode == 200) {
        final meal = response.data['meals'][0];
        return Recipe.fromJsonDetails(meal);
      }
      throw Exception('Failed to load recipe details');
    } catch (e) {
      throw Exception('Error fetching recipe details: $e');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _dio.get('$_baseUrl/search.php?s=$query');
      if (response.statusCode == 200) {
        final List meals = response.data['meals'] ?? [];
        return meals.map((meal) => Recipe.fromJsonDetails(meal)).toList();
      }
      throw Exception('Failed to search recipes');
    } catch (e) {
      throw Exception('Error searching recipes: $e');
    }
  }
}