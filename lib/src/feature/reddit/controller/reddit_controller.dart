import 'package:control/Control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/common/util/local_pagination_util.dart';
import 'package:no_sleep/src/feature/reddit/data/reddit_repository.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

part 'reddit_controller.freezed.dart';

@freezed
sealed class RedditState with _$RedditState {
  const factory RedditState.initial() = Reddit$InitialState;

  const factory RedditState.loading() = Reddit$LoadingState;

  const factory RedditState.error(String message) = Reddit$ErrorState;

  const factory RedditState.loaded({
    required final List<RedditPost> posts,
    required final bool hasMore,
    required final String? nextPage,
  }) = Reddit$LoadedState;
}

final class RedditController extends StateController<RedditState> with DroppableControllerHandler {
  RedditController({
    required final IRedditRepository redditRepository,
    required final LocalPaginationUtil localPaginationUtil,
    super.initialState = const RedditState.initial(),
  }) : _redditRepository = redditRepository,
       _localPaginationUtil = localPaginationUtil;

  final IRedditRepository _redditRepository;
  final LocalPaginationUtil _localPaginationUtil;

  Future<void> load(final String subreddit, {final int limit = 10}) => handle(() async {
    setState(const RedditState.loading());
    final data = await _redditRepository.getPosts(subreddit, limit: limit);

    final hasMore = _localPaginationUtil.checkIsListHasMorePageBool(
      list: data.posts,
      limitInPage: limit,
    );

    setState(RedditState.loaded(posts: data.posts, hasMore: hasMore, nextPage: data.nextPage));
  });

  Future<void> paginate(final String subreddit, {final int limit = 10}) => handle(() async {
    if (state is! Reddit$LoadedState) return;

    final currentState = state as Reddit$LoadedState;

    if (!currentState.hasMore) return;

    final currentList = List.of(currentState.posts);

    final data = await _redditRepository.getPosts(
      subreddit,
      limit: limit,
      nextPage: currentState.nextPage,
    );

    final hasMore = _localPaginationUtil.checkIsListHasMorePageBool(
      list: data.posts,
      limitInPage: limit,
    );

    currentList.addAll(data.posts);

    setState(RedditState.loaded(posts: currentList, hasMore: hasMore, nextPage: data.nextPage));
  });
}
