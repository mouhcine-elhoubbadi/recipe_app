class Recipe {
  final String id;
  final String title;
  final String image;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.instructions,
  });

  

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      image: json['strMealThumb'] ?? '',
      ingredients: [],
      instructions: '',
    );
  }

  factory Recipe.fromJsonDetails(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add(ingredient);
      }
    }
    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      image: json['strMealThumb'] ?? '',
      ingredients: ingredients,
      instructions: json['strInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': title,
      'strMealThumb': image,
      'strIngredients': ingredients.join(','),
      'strInstructions': instructions,
    };
  }
 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'ingredients': ingredients.join(','), 
      'instructions': instructions,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      ingredients: (map['ingredients'] as String).split(','),
      instructions: map['instructions'] ?? '',
    );
  }

}