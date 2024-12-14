import 'package:du_pert6/models/article.dart';
import 'package:du_pert6/services/api_service.dart';
import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final ApiService _apiService = ApiService();

  List<Article> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.get('posts');
      final articles =
          (data as List).map((json) => Article.fromJson(json)).toList();

      setState(() {
        _articles = articles;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addArticle(String title, String body) async {
    try {
      final newArticle = Article(
        id: _articles.length + 1,
        title: title,
        body: body,
      );

      final response = await _apiService.post('posts', newArticle.toJson());

      setState(() {
        _articles.insert(0,Article.fromJson(response));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article added successfully')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchArticles,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? const Center(child: Text('No data'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];

                    return ListTile(
                      title: Text(article.title),
                      subtitle: Text(article.body),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddArticleSheet(context),
      ),
    );
  }

  void _showAddArticleSheet(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final body = _bodyController.text;

                  if (title.isNotEmpty && body.isNotEmpty) {
                    _addArticle(title, body);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                  }
                },
                child: Text('Add Article'),
              ),
            ],
          ),
        );
      }
    );
  }
}
