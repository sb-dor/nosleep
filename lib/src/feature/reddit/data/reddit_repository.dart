import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_json_converter.dart';

abstract interface class IRedditRepository {
  Future<List<RedditPost>> getPosts(String subreddit, {int limit = 10});

  Future<List<RedditPost>> getComments(String subreddit, String postId, {int limit = 10});
}

final class RedditRepositoryImpl implements IRedditRepository {
  RedditRepositoryImpl({final http.Client? httpClient}) : httpClient = httpClient ?? http.Client();

  final http.Client httpClient;

  @override
  Future<List<RedditPost>> getPosts(String subreddit, {int limit = 10}) async {
    final uri = Uri.parse('https://www.reddit.com/r/$subreddit/new.json?limit=$limit');

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, Object?>;
      final jsonConverter = RedditPostJsonConverter();

      return [];
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  @override
  Future<List<RedditPost>> getComments(String subreddit, String postId, {int limit = 10}) async {
    final uri = Uri.parse('https://www.reddit.com/r/$subreddit/comments/$postId/new.json');

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
    }
    return [];
  }
}
