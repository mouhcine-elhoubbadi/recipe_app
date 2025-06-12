import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../recipe_provider.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';
import 'recipe_search_screen.dart';

class RecipesHomeScreen extends StatelessWidget {
  const RecipesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<RecipeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Recipe App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryOrange,
            letterSpacing: 1.2,
          ),
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.search, color: Color.fromARGB(255, 81, 13, 216)),


            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecipeSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Beef Recipes'),
            _buildRecipeList(apiService, 'Beef'),
            _buildSectionHeader('Chicken Recipes'),
            _buildRecipeList(apiService, 'Chicken'),
            _buildSectionHeader('Dessert Recipes'),
            _buildRecipeList(apiService, 'Dessert'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
            ),
          ),
          const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(RecipeProvider provider, String category) {
    return SizedBox(
      height: 240,
      child: FutureBuilder<List<Recipe>>(
        future: provider.fetchRecipes(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryYellow),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.secondaryYellow, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load recipes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No recipes available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _buildRecipeCard(context, recipe, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, RecipeProvider provider) {
    bool isFavorite = provider.favorites.any((fav) => fav.id == recipe.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: recipe.image,
                  height: 190,
                  width: 140,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 190,
                    width: 140,
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryYellow),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 190,
                    width: 140,
                    color: AppTheme.surfaceColor,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : AppTheme.primaryOrange,
                            size: 20,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              provider.removeFavorite(recipe.id);
                            } else {
                              provider.addFavorite(recipe);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? '${recipe.title} removed from favorites'
                                      : '${recipe.title} added to favorites',
                                ),
                                backgroundColor: AppTheme.surfaceColor,
                              ),
                            );
                          },
                          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}