import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../recipe_provider.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';

class RecipesFavoritesScreen extends StatefulWidget {
  const RecipesFavoritesScreen({super.key});

  @override
  State<RecipesFavoritesScreen> createState() => _RecipesFavoritesScreenState();
}

class _RecipesFavoritesScreenState extends State<RecipesFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadFavorites();
    });
  }

  void _removeFromFavorites(Recipe recipe) {
    Provider.of<RecipeProvider>(context, listen: false).removeFavorite(recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.title} removed from favorites'),
        backgroundColor: AppTheme.surfaceColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppTheme.primaryOrange,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showIngredientsDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: recipe.ingredients.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppTheme.secondaryYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorite Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryOrange,
          ),
        ),
        backgroundColor: AppTheme.lightBackground,
        elevation: 0,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favorites;
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: AppTheme.primaryOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorite recipes yet',
                    style: TextStyle(color: Colors.black87, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text('Add Favorites'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final recipe = favorites[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                      ),
                    );
                  },
                  onLongPress: () => _showIngredientsDialog(context, recipe),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 100,
                            height: 100,
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryYellow),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 100,
                            height: 100,
                            color: AppTheme.surfaceColor,
                            child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFromFavorites(recipe),
                        tooltip: 'Remove from favorites',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite),
      //       label: 'Favorites',
      //     ),
      //   ],
      //   currentIndex: 1,
      //   selectedItemColor: AppTheme.primaryOrange,
      //   unselectedItemColor: Colors.grey,
      //   backgroundColor: AppTheme.surfaceColor,
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.pushReplacementNamed(context, '/');
      //     }
      //   },
      // ),
    );
  }
}