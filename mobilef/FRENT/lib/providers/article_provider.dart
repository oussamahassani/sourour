import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class ArticleProvider with ChangeNotifier {
  final ArticleService _service;
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialLoad = false;
  DateTime? _lastFetchTime;

  ArticleProvider({required ArticleService service}) : _service = service;

  List<Article> get articles => List.unmodifiable(_articles);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialLoad => _hasInitialLoad;
  DateTime? get lastFetchTime => _lastFetchTime;

  Future<void> loadArticles({bool forceRefresh = false}) async {
    if ((_isLoading && !forceRefresh) || 
        (!forceRefresh && _hasInitialLoad && 
         _lastFetchTime != null && 
         DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 5))) {
      return;
    }

    _startLoading();
    
    try {
      final newArticles = await _service.fetchAllArticles();
      _articles = newArticles;
      _error = null;
      _hasInitialLoad = true;
      _lastFetchTime = DateTime.now();
      debugPrint('✅ ${_articles.length} articles loaded successfully');
    } catch (e) {
      _error = 'Load error: ${e.toString()}';
      debugPrint('❌ Error: $_error');
      _articles = [];
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  void _stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Article> addArticle(Article article) async {
    _startLoading();
    try {
      if (article.nomArticle.isEmpty || article.reference.isEmpty) {
        throw ArgumentError('Name and reference are required');
      }

      final newArticle = await _service.createArticle(article);
      _error = null;
      _articles.add(newArticle);
      notifyListeners();
      return newArticle;
    } catch (e) {
      _error = 'Add error: ${e.toString()}';
      debugPrint('❌ Add error: $_error');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<Article> updateArticle(Article article) async {
    _startLoading();
    try {
      if (article.id == null || article.id!.isEmpty) {
        throw ArgumentError('Article ID is required for update');
      }

      final updatedArticle = await _service.updateArticle(article);
      _error = null;
      final index = _articles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        _articles[index] = updatedArticle;
        notifyListeners();
      }
      return updatedArticle;
    } catch (e) {
      _error = 'Update error: ${e.toString()}';
      debugPrint('❌ Update error: $_error');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> deleteArticle(String id) async {
    _startLoading();
    try {
      if (id.isEmpty) {
        throw ArgumentError('Article ID is required for deletion');
      }

      await _service.deleteArticle(id);
      _error = null;
      _articles.removeWhere((article) => article.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Delete error: ${e.toString()}';
      debugPrint('❌ Delete error: $_error');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Article? findArticleById(String id) {
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Article> filterArticles(String query, {String? category}) {
    return _articles.where((article) {
      final matchesQuery = query.isEmpty || 
          article.nomArticle.toLowerCase().contains(query.toLowerCase()) ||
          article.reference.toLowerCase().contains(query.toLowerCase());
      
      final matchesCategory = category == null || 
          category.isEmpty || 
          article.categorie?.toLowerCase() == category.toLowerCase();
      
      return matchesQuery && matchesCategory;
    }).toList();
  }
}