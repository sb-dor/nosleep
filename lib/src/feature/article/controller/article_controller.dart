import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/feature/article/data/article_repository.dart';
import 'package:no_sleep/src/feature/article/models/article.dart';

part 'article_controller.freezed.dart';

@freezed
sealed class ArticleState with _$ArticleState {
  const factory ArticleState.initial() = Article$InitialState;

  const factory ArticleState.inProgress() = Article$InProgressState;

  const factory ArticleState.error() = Article$ErrorState;

  const factory ArticleState.completed(final Article? article) = Article$CompletedState;
}

final class ArticleController extends StateController<ArticleState>
    with SequentialControllerHandler {
  ArticleController({
    required final IArticleRepository articleRepository,
    super.initialState = const ArticleState.initial(),
  }) : _iArticleRepository = articleRepository;

  final IArticleRepository _iArticleRepository;

  void article(final String postId) => handle(() async {
    setState(const ArticleState.inProgress());

    final article = await _iArticleRepository.article(postId);

    setState(ArticleState.completed(article));
  }, error: (error, stackTrace) async => setState(const ArticleState.error()));
}
