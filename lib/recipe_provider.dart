import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();

  List<Recipe> _recipes = [];
  List<Recipe> _favorites = [];

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favorites => _favorites;
Future<List<Recipe>> fetchRecipes(String category) async {
  try {
    final recipes = await _apiService.fetchRecipesByCategory(category);
    _recipes = recipes;
    notifyListeners();
    return recipes;
  } catch (e) {
    debugPrint('خطأ أثناء جلب الوصفات للفئة [$category]: $e');
    _recipes = []; // إفراغ القائمة في حالة الخطأ
    notifyListeners();
    return []; // إرجاع لائحة فارغة بدل استثناء لتفادي crash
  }
}


  Future<Recipe> fetchRecipeById(String id) async {
    try {
      return await _apiService.fetchRecipeDetails(id);
    } catch (e) {
      throw Exception('فشل جلب تفاصيل الوصفة: $e');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      return await _apiService.searchRecipes(query);
    } catch (e) {
      throw Exception('فشل البحث عن الوصفات: $e');
    }
  }

  Future<void> addFavorite(Recipe recipe) async {
    await _databaseService.insertRecipe(recipe);
    _favorites = await _databaseService.getRecipes();
    notifyListeners();
  }

  Future<void> removeFavorite(String id) async {
    await _databaseService.deleteRecipe(id);
    _favorites = await _databaseService.getRecipes();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _favorites = await _databaseService.getRecipes();
    notifyListeners();
  }
}