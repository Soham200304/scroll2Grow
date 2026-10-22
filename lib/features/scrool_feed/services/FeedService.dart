import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scrool2grow/features/scrool_feed/models/FeedPostModel.dart';


class FeedPage {
  final List<FeedPost> posts;
  final int total;
  final int skip;
  final int limit;

  const FeedPage({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory FeedPage.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'] as List<dynamic>? ?? [];

    return FeedPage(
      posts: rawPosts
          .whereType<Map<String, dynamic>>()
          .map(FeedPost.fromJson)
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}

class FeedService {
  static const String _baseUrl = 'https://dummyjson.com/posts';
  static const int pageSize = 10;

  final http.Client _client;

  FeedService({http.Client? client})
      : _client = client ?? http.Client();

  Future<FeedPage> fetchPosts({
    int skip = 0,
    int limit = pageSize,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load posts. HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response received from the feed API.');
    }

    return FeedPage.fromJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}