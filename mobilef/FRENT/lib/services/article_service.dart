import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../config.dart';
class ArticleService {
  final String baseUrl;
  final Duration timeoutDuration;

  ArticleService({
    this.baseUrl = '${AppConfig.baseUrl}/api/articles',
    this.timeoutDuration = const Duration(seconds: 15),
  });

  Future<List<Article>> fetchAllArticles() async {
    try {
      final url = Uri.parse(baseUrl);
      debugPrint('🔗 Fetching articles from: $url');

      final response = await http.get(
        url,
        headers: _defaultHeaders,
      ).timeout(timeoutDuration);

      debugPrint('⚡ Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      return _handleResponse<List<Article>>(
        response,
        onSuccess: () => _parseArticles(response.body),
      );
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout after $timeoutDuration');
    } catch (e) {
      debugPrint('❌ Error in fetchAllArticles: $e');
      rethrow;
    }
  }

  Future<Article> fetchArticleById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.get(
        url,
        headers: _defaultHeaders,
      ).timeout(timeoutDuration);

      return _handleResponse<Article>(
        response,
        onSuccess: () => Article.fromJson(jsonDecode(response.body)),
        notFound: () => throw Exception('Article not found'),
      );
    } catch (e) {
      debugPrint('❌ Error in fetchArticleById: $e');
      rethrow;
    }
  }

 Future<Article> createArticle(Article article) async {
  try {
    // Validation renforcée
    if (article.nomArticle.isEmpty) {
      throw ArgumentError('Le nom de l\'article est requis');
    }
    if (article.reference.isEmpty) {
      throw ArgumentError('La référence est requise');
    }

    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: _defaultHeaders,
      body: jsonEncode(article.toJson()),
    ).timeout(timeoutDuration);

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return Article.fromJson(responseData);
    } else {
      throw HttpException(
        'Échec de la création - Code: ${response.statusCode}',
        uri: url,
      );
    }
  } catch (e) {
    debugPrint('Erreur création article: $e');
    rethrow;
  }
}
  Future<Article> updateArticle(Article article) async {
    try {
      final url = Uri.parse('$baseUrl/${article.id}');
      final response = await http.put(
        url,
        headers: _defaultHeaders,
        body: jsonEncode(article.toJson()),
      ).timeout(timeoutDuration);

      return _handleResponse<Article>(
        response,
        onSuccess: () => Article.fromJson(jsonDecode(response.body)),
      );
    } catch (e) {
      debugPrint('❌ Error in updateArticle: $e');
      rethrow;
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(
        url,
        headers: _defaultHeaders,
      ).timeout(timeoutDuration);

      _handleResponse<void>(
        response,
        expectedStatus: 204,
        onSuccess: () {},
      );
    } catch (e) {
      debugPrint('❌ Error in deleteArticle: $e');
      rethrow;
    }
  }

  // Helper methods
  Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  T _handleResponse<T>(
    http.Response response, {
    required T Function() onSuccess,
    T Function()? notFound,
    int expectedStatus = 200,
  }) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return onSuccess();
      case 204:
        return onSuccess(); // Pour les réponses sans contenu (comme delete)
      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        if (notFound != null) return notFound();
        throw NotFoundException();
      case 500:
        throw ServerErrorException();
      default:
        throw HttpException(
          'Request failed with status: ${response.statusCode}\nBody: ${response.body}',
          uri: response.request?.url,
        );
    }
  }

  List<Article> _parseArticles(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      
      if (decoded is List) {
        return decoded.map<Article>((json) => Article.fromJson(json)).toList();
      } 
      
      if (decoded is Map) {
        if (decoded['data'] is List) {
          return (decoded['data'] as List).map<Article>((json) => Article.fromJson(json)).toList();
        }
        if (decoded['items'] is List) {
          return (decoded['items'] as List).map<Article>((json) => Article.fromJson(json)).toList();
        }
      }
      
      throw const FormatException('Invalid response format - Expected array or object with data/items array');
    } on FormatException catch (e) {
      debugPrint('❌ JSON parsing error: $e');
      throw DataParsingException(e.message);
    }
  }
}

// Custom exceptions
class BadRequestException implements Exception {
  final String message;
  BadRequestException([this.message = 'Bad request']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'Forbidden']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Resource not found']);
}

class ServerErrorException implements Exception {
  final String message;
  ServerErrorException([this.message = 'Server error']);
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
}