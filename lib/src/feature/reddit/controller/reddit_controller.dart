import 'package:control/Control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/feature/reddit/data/reddit_repository.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

part 'reddit_controller.freezed.dart';

@freezed
sealed class RedditState with _$RedditState {
  const factory RedditState.initial() = Reddit$InitialState;

  const factory RedditState.loading() = Reddit$LoadingState;

  const factory RedditState.error(String message) = Reddit$ErrorState;

  const factory RedditState.loaded(List<RedditPost> posts) = Reddit$LoadedState;
}

final class RedditController extends StateController<RedditState> with SequentialControllerHandler {
  RedditController({
    required this.redditRepository,
    super.initialState = const RedditState.initial(),
  });

  final IRedditRepository redditRepository;

  Future<void> loadPosts(final String subreddit, {final int limit = 10}) => handle(() async {
    setState(const RedditState.loading());
    final posts = await redditRepository.getPosts(subreddit, limit: limit);
    setState(RedditState.loaded(posts));
  });

  Future<void> loadComments(final String subreddit, final String postId, {final int limit = 10}) =>
      handle(() async {
        setState(const RedditState.loading());
        final comments = await redditRepository.getComments(subreddit, postId, limit: limit);
        setState(RedditState.loaded(comments));
      });
}
