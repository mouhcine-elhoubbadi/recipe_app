import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/recipe.dart';
import '../recipe_provider.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  // إعداد البحث الصوتي
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_debouncedSearch);
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في البحث الصوتي: ${error.errorMsg}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('البحث الصوتي غير متاح على هذا الجهاز'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        localeId: 'en_Us', // اللغة العربية المغربية (يمكنك تغييرها إلى 'en_US' إذا كنتي بغيتي الإنجليزية)
      );
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  bool _debounceActive = false;
  Future<void> _debouncedSearch() async {
    if (_debounceActive) return;

    final query = _controller.text.trim();
    if (query == _lastQuery || query.isEmpty) {
      if (query.isEmpty && _searchResults.isNotEmpty) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }

    _debounceActive = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _debounceActive = false;

    if (_controller.text.trim() != query) return;

    _lastQuery = query;
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      final results = await provider.searchRecipes(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل البحث: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _searchResults = [];
      _lastQuery = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 188, 193, 49),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'ابحث عن وصفة...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange), // تغيير اللون إلى برتقالي
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : AppTheme.primaryOrange,
                    ),
                    onPressed: _startListening,
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_searchResults.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surfaceColor,
              child: Row(
                children: [
                  Text(
                    '${_searchResults.length} نتيجة لـ "${_controller.text}"',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildSearchContent()),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_controller.text.isEmpty) return _buildEmptySearchState();

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري البحث عن "${_controller.text}"...',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج لـ "${_controller.text}"',
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'جرب كلمات مفتاحية أخرى',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) => _buildRecipeListItem(_searchResults[index]),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 72, color: AppTheme.secondaryYellow),
          const SizedBox(height: 16),
          const Text(
            'ابحث عن وصفة',
            style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'اكتب اسم وصفة أو كلمة مفتاحية لإيجاد وصفاتك المفضلة',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildPopularSearches(),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    final popularSearches = ['Beef', 'Chicken', 'Dessert', 'Pasta', 'Seafood', 'Vegetarian'];

    return Column(
      children: [
        const Text(
          'بحث شائع',
          style: TextStyle(
            color: AppTheme.primaryOrange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: popularSearches.map((category) {
            return InkWell(
              onTap: () {
                _controller.text = category;
                _debouncedSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecipeListItem(Recipe recipe) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: recipe.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: recipe.image,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 90,
                        color: AppTheme.surfaceColor,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryYellow),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 90,
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 90,
                      color: AppTheme.surfaceColor,
                      child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.ingredients.take(3).join(', '),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}