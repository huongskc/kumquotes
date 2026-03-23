import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _currentQuote = "Cây quất nhà bạn đang chờ được hái!";
  String _author = "";
  bool _isLoading = false;

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

          // 3. Lớp nội dung chính
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
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