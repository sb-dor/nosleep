import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

class RedditMobileWidget extends StatefulWidget {
  const RedditMobileWidget({super.key});

  @override
  State<RedditMobileWidget> createState() => _RedditMobileWidgetState();
}

class _RedditMobileWidgetState extends State<RedditMobileWidget> {
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
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.4)),
              color: const Color(0xFFd41132).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            await redditController.load('noSleep');
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
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
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortButton('Newest', true),
                        const SizedBox(width: 8),
                        _buildSortButton('Top Rated', false),
                        const SizedBox(width: 8),
                        _buildSortButton('Classic', false),
                        const SizedBox(width: 8),
                        _buildSortButton('Urban Legends', false),
                      ],
                    ),
                  ),
                ),
              ),

              // Results Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    '${redditController.state is Reddit$LoadedState ? (redditController.state as Reddit$LoadedState).posts.length : 0} RESULTS MANIFESTED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
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
                Reddit$LoadedState() => SliverFixedExtentList.builder(
                  itemExtent: 245,
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

  Widget _buildSortButton(String text, bool isSelected) => Container(
    margin: const EdgeInsets.only(right: 8),
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

  Widget _buildPostCard(RedditPost post, int index) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: .spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41132).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    ),
  );
}
