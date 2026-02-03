import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/controller/article_controller.dart';
import 'package:no_sleep/src/feature/article/models/article.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_comment.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

class ArticleDesktopWidget extends StatefulWidget {
  const ArticleDesktopWidget({super.key});

  @override
  State<ArticleDesktopWidget> createState() => _ArticleDesktopWidgetState();
}

class _ArticleDesktopWidgetState extends State<ArticleDesktopWidget> {
  late final _config = ArticleConfigInhWidget.of(context);
  late final _controller = _config.articleController;
  late final _postId = _config.postId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (_, _) {
        final state = _controller.state;

        return switch (state) {
          Article$InitialState() ||
          Article$InProgressState() => const Center(child: CircularProgressIndicator()),

          Article$ErrorState() => Center(
            child: Text('Failed to load article', style: TextStyle(color: Colors.red.shade300)),
          ),

          Article$CompletedState(:final article) => _ArticleScrollView(article: article!),
        };
      },
    );
  }
}

class _ArticleScrollView extends StatelessWidget {
  const _ArticleScrollView({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final flatComments = _flatten(article.comments);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
          sliver: SliverToBoxAdapter(child: PostHeader(post: article.post)),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          sliver: SliverToBoxAdapter(child: PostBody(post: article.post)),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          sliver: SliverToBoxAdapter(child: PostStats(post: article.post)),
        ),

        const SliverToBoxAdapter(child: Divider(height: 1)),

        if (flatComments.isNotEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(32, 24, 32, 12),
            sliver: SliverToBoxAdapter(
              child: Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),

        if (flatComments.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 32, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final comment = flatComments[index];
                return CommentTile(comment: comment);
              }, childCount: flatComments.length),
            ),
          ),
      ],
    );
  }
}

List<RedditComment> _flatten(List<RedditComment> source) {
  final result = <RedditComment>[];

  void walk(List<RedditComment> items) {
    for (final c in items) {
      result.add(c);
      if (c.replies.isNotEmpty) {
        walk(c.replies);
      }
    }
  }

  walk(source);
  return result;
}

class PostHeader extends StatelessWidget {
  const PostHeader({super.key, required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('u/${post.author ?? "anonymous"}', style: const TextStyle(color: Colors.orange)),
            const SizedBox(width: 12),
            if (post.subreddit != null)
              Text('r/${post.subreddit}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class PostBody extends StatelessWidget {
  const PostBody({super.key, required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return SelectableText(post.selftext ?? '', style: const TextStyle(fontSize: 15, height: 1.6));
  }
}

class PostStats extends StatelessWidget {
  const PostStats({super.key, required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(Icons.arrow_upward, post.ups),
        _stat(Icons.arrow_downward, post.downs),
        _stat(Icons.chat_bubble_outline, post.numComments),
      ],
    );
  }

  Widget _stat(IconData icon, int? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 6), Text('${value ?? 0}')]),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: comment.depth * 20, top: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: comment.isStickied
                ? Colors.green
                : comment.isLocked
                ? Colors.red
                : Colors.grey.shade800,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                Text('${comment.score} points'),
                if (comment.isStickied) ...[
                  const SizedBox(width: 8),
                  const Text('[STICKIED]', style: TextStyle(color: Colors.green)),
                ],
                if (comment.isLocked) ...[
                  const SizedBox(width: 8),
                  const Text('[LOCKED]', style: TextStyle(color: Colors.red)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(comment.body, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
