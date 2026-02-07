import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/util/screen_util.dart';
import 'package:no_sleep/src/feature/article/controller/article_controller.dart';
import 'package:no_sleep/src/feature/article/data/article_repository.dart';
import 'package:no_sleep/src/feature/article/widgets/desktop/article_desktop_widget.dart';
import 'package:no_sleep/src/feature/article/widgets/mobile/article_mobile_widget.dart';
import 'package:no_sleep/src/feature/article/widgets/tablet/article_tablet_widget.dart';

class ArticleConfigInhWidget extends InheritedWidget {
  const ArticleConfigInhWidget({super.key, required this.state, required super.child});

  static ArticleConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<ArticleConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'ArticleConfigInhWidget was not found in element tree');
    return (widget as ArticleConfigInhWidget).state;
  }

  final ArticleConfigWidgetState state;

  @override
  bool updateShouldNotify(ArticleConfigInhWidget old) {
    return false;
  }
}

class ArticleConfigWidget extends StatefulWidget {
  const ArticleConfigWidget({super.key, required this.postId});

  final String postId;

  @override
  State<ArticleConfigWidget> createState() => ArticleConfigWidgetState();
}

class ArticleConfigWidgetState extends State<ArticleConfigWidget> {
  late final ArticleController articleController;

  late final String postId = widget.postId;

  @override
  void initState() {
    super.initState();
    articleController = ArticleController(
      articleRepository: kIsWeb || kIsWasm ? ArticleJSRepositoryImpl() : ArticleRepositoryImpl(),
    );
    articleController.article(widget.postId);
  }

  @override
  void dispose() {
    articleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArticleConfigInhWidget(
      state: this,
      child: context.screenSizeMaybeWhen(
        orElse: () => const ArticleMobileWidget(),
        tablet: () => const ArticleTabletWidget(),
        desktop: () => const ArticleDesktopWidget(),
      ),
    );
  }
}
