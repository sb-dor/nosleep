import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

class RedditTabletWidget extends StatefulWidget {
  const RedditTabletWidget({super.key});

  @override
  State<RedditTabletWidget> createState() => _RedditTabletWidgetState();
}

class _RedditTabletWidgetState extends State<RedditTabletWidget> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    redditController.load('noSleep');
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
      redditController.paginate('noSleep');
    }
  }

  @override
  Widget build(BuildContext context) => StateConsumer<RedditController, RedditState>(
    controller: redditController,
    builder: (context, state, child) => Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Row(
          children: [
            Icon(Icons.eighteen_mp, color: Color(0xFFd41132), size: 32),
            SizedBox(width: 12),
            Text(
              'NoSleep',
              style: TextStyle(
                color: Color(0xFFd41132),
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.4)),
              color: const Color(0xFFd41132).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFd41132).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Icon(Icons.search, color: Color(0xFFd41132), size: 28),
                        ),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Search the darkness...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                            icon: const Icon(Icons.cancel, color: Colors.grey, size: 24),
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildSortButton('Newest', true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSortButton('Top Rated', false)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildSortButton('Classic', false)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSortButton('Urban Legends', false)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Results Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${redditController.state is Reddit$LoadedState ? (redditController.state as Reddit$LoadedState).posts.length : 0} RESULTS MANIFESTED',
                      style: TextStyle(
                        fontSize: 14,
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
                Reddit$ErrorState() => const SliverFillRemaining(
                  child: Center(child: Text('Something went wrong')),
                ),
                Reddit$LoadedState() => SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 320,
                  ),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleConfigWidget(postId: post.id),
                          ),
                        );
                      },
                      child: _buildPostCard(post, index),
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
    ),
  );

  Widget _buildSortButton(String text, bool isSelected) => ElevatedButton(
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    ),
  );

  Widget _buildPostCard(RedditPost post, int index) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.grey[900]?.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFd41132).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'HALL OF FAME',
                  style: TextStyle(
                    color: Color(0xFFd41132),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: [
                    Text(
                      'u/${post.author ?? "Anonymous"}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFd41132),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    Text(
                      post.createdUtc.toString(),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    post.selftext ?? 'No description available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd41132).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.masks, color: Color(0xFFd41132), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${(post.score ?? 0).toInt()}k SPOOKS',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFd41132),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        '${post.numComments ?? 0}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFd41132), size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}
