import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:no_sleep/src/common/util/screen_util.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/data/github_reports_repository.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/controllers/github_reports_data_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/desktop/github_reports_desktop_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/mobile/github_reports_mobile_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/tablet/github_reports_tablet_widget.dart';

/// Inherited widgets that provides access to GithubReportsConfigWidgetState throughout the widgets tree.
class GithubReportsConfigInhWidget extends InheritedWidget {
  const GithubReportsConfigInhWidget({super.key, required this.state, required super.child});

  static GithubReportsConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GithubReportsConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'GithubReportsConfigInhWidget was not found in element tree');
    return (widget as GithubReportsConfigInhWidget).state;
  }

  final GithubReportsConfigWidgetState state;

  @override
  bool updateShouldNotify(GithubReportsConfigInhWidget old) {
    return false;
  }
}

class GithubReportsConfigWidget extends StatefulWidget {
  const GithubReportsConfigWidget({super.key});

  @override
  State<GithubReportsConfigWidget> createState() => GithubReportsConfigWidgetState();
}

class GithubReportsConfigWidgetState extends State<GithubReportsConfigWidget> {
  late final GithubReportsController githubReportsController;
  late final GithubReportsDataController githubReportsDataController;

  @override
  void initState() {
    super.initState();
    githubReportsDataController = GithubReportsDataController();
    githubReportsController = GithubReportsController(
      githubReportsRepository: GithubReportsRepositoryImpl(apiClient: http.Client()),
    );
  }

  @override
  void dispose() {
    githubReportsController.dispose();
    githubReportsDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GithubReportsConfigInhWidget(
      state: this,
      child: context.screenSizeMaybeWhen(
        orElse: () => const GithubReportsDesktopWidget(),
        phone: () => const GithubReportsMobileWidget(),
        tablet: () => const GithubReportsTabletWidget(),
      ),
    );
  }
}
