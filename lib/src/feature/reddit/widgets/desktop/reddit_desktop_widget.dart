import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

class RedditDesktopWidget extends StatefulWidget {
  const RedditDesktopWidget({super.key});

  @override
  State<RedditDesktopWidget> createState() => _RedditDesktopWidgetState();
}

class _RedditDesktopWidgetState extends State<RedditDesktopWidget> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;
  late final ScrollController _scrollController = ScrollController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    redditController.load('noSleep');
    _scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }

  void _listener() {
    if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
      redditController.paginate('noSleep');
    }
  }

  Widget? _selectedPost;

  @override
  Widget build(BuildContext context) => StateConsumer<RedditController, RedditState>(
    controller: redditController,
    builder: (context, state, child) => Scaffold(
      body: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 300,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFF0a0505)),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.eighteen_mp, color: Color(0xFFd41132), size: 28),
                          SizedBox(width: 8),
                          Text(
                            'NoSleep',
                            style: TextStyle(
                              color: Color(0xFFd41132),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFd41132).withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(Icons.search, color: Color(0xFFd41132)),
                            ),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Search the darkness...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    redditController.load(value);
                                    redditDataController.setSelectedSubreddit(value);
                                  }
                                },
                              ),
                            ),
                            if (searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sort Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildSortButton('Newest', true)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildSortButton('Top Rated', false)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildSortButton('Classic', false),
                        ],
                      ),
                    ),
                  ),

                  // Popular Subreddits
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'POPULAR Articles',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  switch (state) {
                    Reddit$InitialState() => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    Reddit$LoadingState() => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    ),
                    Reddit$ErrorState() => SliverFillRemaining(
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        children: [
                          Text('Error: ${state.message}'),
                          ElevatedButton(
                            onPressed: () {
                              final subreddit = redditDataController.selectedSubreddit ?? 'popular';
                              redditController.load(subreddit);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    Reddit$LoadedState() => SliverFixedExtentList.builder(
                      itemExtent: 100,
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPost = ArticleConfigWidget(
                                  postId: post.id,
                                  key: ValueKey(post.id),
                                );
                              });
                            },
                            child: _buildSidebarPostItem(post, index),
                          ),
                        );
                      },
                    ),
                  },

                  if (state is Reddit$LoadedState && state.hasMore)
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    ),
                ],
              ),
            ),
          ),

          if (_selectedPost != null) Expanded(child: _selectedPost!),
        ],
      ),
    ),
  );

  Widget _buildSortButton(String text, bool isSelected) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFd41132) : Colors.grey[900],
        foregroundColor: isSelected ? Colors.white : Colors.grey[400],
        side: isSelected ? null : BorderSide(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(
            color: isSelected ? Colors.transparent : const Color(0xFFd41132).withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );

  Widget _buildSidebarPostItem(RedditPost post, int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[900]?.withValues(alpha: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFd41132).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
              ),
              child: Text(
                'r/${post.subreddit ?? "unknown"}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFd41132),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.masks, color: Color(0xFFd41132), size: 12),
                const SizedBox(width: 4),
                Text(
                  '${(post.score ?? 0).toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildMainPostCard(RedditPost post, int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd41132).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'HALL OF FAME',
                      style: TextStyle(
                        color: Color(0xFFd41132),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'u/${post.author ?? "Anonymous"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFd41132),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                  ),
                  const Text('6h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.selftext ?? 'No description available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd41132).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.masks, color: Color(0xFFd41132), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${(post.score ?? 0).toInt()} SPOOKS',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFd41132),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${post.numComments ?? 0}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFd41132), size: 16),
            ],
          ),
        ),
      ],
    ),
  );
}
