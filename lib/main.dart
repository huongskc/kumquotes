import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const KumQuotesApp());
}

class KumQuotesApp extends StatelessWidget {
  const KumQuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KumQuotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const QuoteScreen(),
    );
  }
}

class FavoriteQuote {
  final String quote;
  final String author;

  FavoriteQuote({required this.quote, required this.author});

  Map<String, dynamic> toJson() => {'quote': quote, 'author': author};

  factory FavoriteQuote.fromJson(Map<String, dynamic> json) =>
      FavoriteQuote(quote: json['quote'], author: json['author']);
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _currentQuote = "Cây quất nhà bạn đang chờ được hái!";
  String _author = "";
  bool _isLoading = false;
  List<FavoriteQuote> _favorites = [];

  static const String _favoritesKey = 'kumquotes_favorites';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _favorites = jsonList.map((e) => FavoriteQuote.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_favorites.map((f) => f.toJson()).toList());
    await prefs.setString(_favoritesKey, jsonString);
  }

  bool get _isCurrentFavorited {
    return _favorites.any((f) => f.quote == _currentQuote && f.author == _author);
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/quotes/random'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentQuote = data['quote'];
          _author = data['author'];
        });
      } else {
        setState(() {
          _currentQuote = "Vườn quất đang bảo trì. Vui lòng thử lại sau!";
          _author = "";
        });
      }
    } catch (e) {
      setState(() {
        _currentQuote = "Mất mạng rồi! Hãy kiểm tra lại kết nối nhé!";
        _author = "";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_author.isEmpty) return;
    setState(() {
      if (_isCurrentFavorited) {
        _favorites.removeWhere((f) => f.quote == _currentQuote && f.author == _author);
      } else {
        _favorites.add(FavoriteQuote(quote: _currentQuote, author: _author));
      }
    });
    await _saveFavorites();
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favorites: _favorites,
          onRemove: (fav) async {
            setState(() {
              _favorites.remove(fav);
            });
            await _saveFavorites();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.yellow.shade100,
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -20,
            right: -20,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.eco, color: Colors.green, size: 60),
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: const Text('🍊', style: TextStyle(fontSize: 80)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.park, color: Colors.green, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'KumQuotes',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.deepOrange.shade700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: _openFavorites,
                              icon: Icon(
                                _favorites.isEmpty
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.deepOrange.shade300,
                                size: 30,
                              ),
                              tooltip: 'Favourited Quotes',
                            ),
                            if (_favorites.isNotEmpty)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Colors.deepOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_favorites.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.orange.shade200, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withValues(alpha: 0.15),
                                    spreadRadius: 5,
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.format_quote_rounded, size: 56, color: Colors.deepOrange.shade400),
                                  const SizedBox(height: 16),

                                  _isLoading
                                      ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(color: Colors.deepOrange.shade400),
                                  )
                                      : Column(
                                    children: [
                                      Text(
                                        _currentQuote,
                                        style: TextStyle(
                                          fontSize: 24,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_author.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "~ $_author ~",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange.shade600,
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 56),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _fetchQuote,
                                    icon: const Icon(Icons.eco),
                                    label: Text(
                                      _author.isEmpty ? 'Hái Quả Đầu Tiên' : 'Hái Quất Mới',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.deepOrange,
                                      disabledBackgroundColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(horizontal: 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                      shadowColor: Colors.deepOrange.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                if (_author.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _toggleFavorite,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: _isCurrentFavorited
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        backgroundColor: _isCurrentFavorited
                                            ? Colors.deepOrange
                                            : Colors.white,
                                        disabledBackgroundColor: Colors.grey.shade300,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          side: const BorderSide(
                                            color: Colors.deepOrange,
                                            width: 2,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.deepOrange.withValues(alpha: 0.5),
                                      ),
                                      child: Icon(
                                        _isCurrentFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final List<FavoriteQuote> favorites;
  final void Function(FavoriteQuote) onRemove;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.yellow.shade100,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.eco, color: Colors.green, size: 60),
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: const Text('🍊', style: TextStyle(fontSize: 80)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.deepOrange.shade400, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            'My Quote Basket',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.deepOrange.shade700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back_ios_new, color: Colors.deepOrange.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: widget.favorites.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 72, color: Colors.deepOrange.shade200),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có quất nào trong giỏ.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepOrange.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hái quất và thả tim để thêm vào giỏ nhé! 🍊',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.orange.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: widget.favorites.length,
                    itemBuilder: (context, index) {
                      final fav = widget.favorites[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade200, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.10),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote_rounded, color: Colors.deepOrange.shade300, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fav.quote,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                  if (fav.author.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      "~ ${fav.author} ~",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                widget.onRemove(fav);
                                setState(() {});
                              },
                              icon: Icon(Icons.favorite, color: Colors.deepOrange.shade400, size: 22),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}