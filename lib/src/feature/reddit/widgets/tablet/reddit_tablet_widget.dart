import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
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

  @override
  void initState() {
    super.initState();
    // Load default subreddit on init
    redditController.loadPosts('popular');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Reddit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar for subreddit
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter subreddit name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        redditController.loadPosts(value);
                        redditDataController.setSelectedSubreddit(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final textEditingController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enter Subreddit'),
                        content: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., funny, worldnews',
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              redditController.loadPosts(value);
                              redditDataController.setSelectedSubreddit(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (textEditingController.text.isNotEmpty) {
                                redditController.loadPosts(textEditingController.text);
                                redditDataController.setSelectedSubreddit(textEditingController.text);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Load'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Popular subreddits quick access
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSubredditChip('Popular', 'popular'),
                  _buildSubredditChip('AskReddit', 'AskReddit'),
                  _buildSubredditChip('WorldNews', 'worldnews'),
                  _buildSubredditChip('Technology', 'technology'),
                  _buildSubredditChip('Funny', 'funny'),
                  _buildSubredditChip('Gaming', 'gaming'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Posts list
            Expanded(
              child: ListenableBuilder(
                listenable: redditController,
                builder: (context, child) {
                  final state = redditController.state;

                  switch (state) {
                    case Reddit$InitialState():
                      return const SizedBox.shrink();
                    case Reddit$LoadingState():
                      return const Center(child: CircularProgressIndicator());
                    case Reddit$ErrorState():
                      return ElevatedButton(onPressed: () {}, child: const Icon(Icons.refresh));
                    case Reddit$LoadedState():
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                // Show comments for this post
                                redditController.loadComments(
                                  redditDataController.selectedSubreddit ?? 'popular',
                                  post.id,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'by ${post.author ?? "unknown"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${post.score ?? 0} upvotes | ${post.numComments ?? 0} comments',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    if (post.selftext != null && post.selftext!.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          post.selftext!,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildSubredditChip(String label, String subreddit) => Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: redditDataController.selectedSubreddit == subreddit,
        onSelected: (selected) {
          redditController.loadPosts(subreddit);
          redditDataController.setSelectedSubreddit(subreddit);
        },
      ),
    );
}
