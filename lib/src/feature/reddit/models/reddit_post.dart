import 'package:flutter/foundation.dart';

@immutable
class RedditPost {
  const RedditPost({
    required this.id,
    required this.title,
    this.author,
    this.selftext,
    this.url,
    this.permalink,
    this.score,
    this.ups,
    this.downs,
    this.numComments,
    this.thumbnail,
    this.imageUrl,
    this.created,
    this.createdUtc,
    this.over18,
    this.spoiler,
    this.nsfw,
    this.subreddit,
    this.subredditType,
    this.subredditSubscribers,
    this.media,
  });

  final String id;
  final String title;
  final String? author;
  final String? selftext;
  final String? url;
  final String? permalink;
  final int? score;
  final int? ups;
  final int? downs;
  final int? numComments;
  final String? thumbnail;
  final String? imageUrl;
  final DateTime? created;
  final DateTime? createdUtc;
  final bool? over18;
  final bool? spoiler;
  final bool? nsfw;
  final String? subreddit;
  final String? subredditType;
  final int? subredditSubscribers;
  final Map<String, Object?>? media;
}
